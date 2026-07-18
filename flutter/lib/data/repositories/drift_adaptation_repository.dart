import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/model/adaptation_models.dart';
import '../../core/model/nutrition_models.dart';
import '../local/database.dart';
import '../local/daos/personalization_dao.dart';
import '../local/daos/workout_dao.dart';
import 'adaptation_repository.dart';
import 'nutrition_repository.dart';

class DriftAdaptationRepository implements AdaptationRepository {
  final GymDatabase database;
  final NutritionRepository nutritionRepository;
  final int Function() nowEpochMillis;
  final int Function() todayEpochDay;

  DriftAdaptationRepository({
    required this.database,
    required this.nutritionRepository,
    required this.nowEpochMillis,
    required this.todayEpochDay,
  });

  PersonalizationDao get personalizationDao => database.personalizationDao;
  WorkoutDao get workoutDao => database.workoutDao;

  @override
  Stream<List<AdaptationDecisionData>> observeDecisions() {
    return personalizationDao.observeDecisionHistory();
  }

  @override
  Future<int> recordDecision(AdaptationDecision decision) async {
    final status = decision.mode == AdaptationMode.autoApply
        ? AdaptationStatus.applied
        : AdaptationStatus.proposed;

    final companion = AdaptationDecisionsCompanion(
      kind: Value(decision.kind),
      mode: Value(decision.mode),
      status: Value(status),
      reasonVi: Value(decision.reasonVi),
      payloadVersion: const Value(1),
      inputsJson: const Value('{}'),
      beforeJson: Value(decision.beforeValue),
      afterJson: Value(decision.afterValue),
      undoJson: Value(decision.undoPayload),
      createdAtEpochMillis: Value(nowEpochMillis()),
      resolvedAtEpochMillis: decision.mode == AdaptationMode.autoApply
          ? Value(nowEpochMillis())
          : const Value(null),
    );

    return database.transaction(() async {
      final id = await personalizationDao.insertDecision(companion);
      if (decision.mode == AdaptationMode.autoApply) {
        await _applyDecisionEffect(decision);
      }
      return id;
    });
  }

  @override
  Future<DecisionActionResult> acceptDecision(int decisionId) async {
    return database.transaction(() async {
      final entity = await personalizationDao.decisionByIdNow(decisionId);
      if (entity == null) {
        return DecisionActionResultNotFound(decisionId);
      }

      if (entity.status != AdaptationStatus.proposed) {
        return DecisionActionResultInvalidState(
          currentStatus: entity.status,
          expectedStatus: AdaptationStatus.proposed,
        );
      }

      final staleCheck = await _validateBeforeState(entity);
      if (staleCheck != null) return staleCheck;

      if (entity.kind == AdaptationKind.deloadWeek) {
        final error = await _applyConfirmedDeload(entity);
        if (error != null) return error;
      } else {
        await _applyDecisionEffect(_entityToDecision(entity));
      }

      await personalizationDao.updateDecisionStatus(
        decisionId,
        AdaptationStatus.applied,
        nowEpochMillis(),
      );

      return DecisionActionResultSuccess();
    });
  }

  @override
  Future<DecisionActionResult> rejectDecision(int decisionId) async {
    return database.transaction(() async {
      final entity = await personalizationDao.decisionByIdNow(decisionId);
      if (entity == null) {
        return DecisionActionResultNotFound(decisionId);
      }

      if (entity.status != AdaptationStatus.proposed) {
        return DecisionActionResultInvalidState(
          currentStatus: entity.status,
          expectedStatus: AdaptationStatus.proposed,
        );
      }

      await personalizationDao.updateDecisionStatus(
        decisionId,
        AdaptationStatus.rejected,
        nowEpochMillis(),
      );

      return DecisionActionResultSuccess();
    });
  }

  @override
  Future<DecisionActionResult> undoLatestDecision(AdaptationKind kind) async {
    return database.transaction(() async {
      final entity = await personalizationDao.latestDecisionByKindAndStatus(
        kind,
        AdaptationStatus.applied,
      );
      if (entity == null) {
        return DecisionActionResultNotFound(-1);
      }

      final allDecisions = await personalizationDao.decisionHistoryNow();
      final newerConflict = allDecisions.any((d) =>
          d.kind == kind &&
          d.id != entity.id &&
          d.createdAtEpochMillis > entity.createdAtEpochMillis &&
          d.status == AdaptationStatus.applied);

      if (newerConflict) {
        return DecisionActionResultStale(
          'Có quyết định mới hơn cùng loại đã được áp dụng. Không thể hoàn tác.',
        );
      }

      if (entity.kind == AdaptationKind.deloadWeek) {
        final error = await _undoDeload(entity);
        if (error != null) return error;
      } else {
        await _applyUndoEffect(entity);
      }

      await personalizationDao.updateDecisionStatus(
        entity.id,
        AdaptationStatus.undone,
        nowEpochMillis(),
      );

      return DecisionActionResultSuccess();
    });
  }

  Future<void> _applyDecisionEffect(AdaptationDecision decision) async {
    switch (decision.kind) {
      case AdaptationKind.calorieTarget:
        final newCalories = _extractCalories(decision.afterValue);
        if (newCalories == null) return;
        final today = todayEpochDay();

        final currentDayList = await personalizationDao.nutritionRangeNow(today, today);
        final currentDay = currentDayList.firstOrNull;

        final currentTarget = currentDay?.targetCalories != null
            ? NutritionTarget(
                basalCalories: currentDay!.targetBasalCalories ?? 0,
                maintenanceCalories: currentDay.targetMaintenanceCalories ?? 0,
                calories: currentDay.targetCalories!,
                proteinGrams: currentDay.targetProteinGrams ?? 0,
                carbsGrams: currentDay.targetCarbsGrams ?? 0,
                fatGrams: currentDay.targetFatGrams ?? 0,
                audit: NutritionTargetAudit(
                  rawBasalCalories: (currentDay.targetBasalCalories ?? 0).toDouble(),
                  rawMaintenanceCalories: (currentDay.targetMaintenanceCalories ?? 0).toDouble(),
                  rawTargetCalories: currentDay.targetCalories!.toDouble(),
                  rawProteinGrams: (currentDay.targetProteinGrams ?? 0).toDouble(),
                  rawCarbsGrams: (currentDay.targetCarbsGrams ?? 0).toDouble(),
                  rawFatGrams: (currentDay.targetFatGrams ?? 0).toDouble(),
                ),
              )
            : null;

        if (currentTarget != null) {
          final proteinCalories = currentTarget.proteinGrams * 4.0;
          final currentNonProtein = currentTarget.calories - proteinCalories;
          final newNonProtein = newCalories - proteinCalories;
          final double ratio;
          if (currentNonProtein > 0 && newNonProtein > 0) {
            ratio = newNonProtein / currentNonProtein;
          } else {
            ratio = newCalories / currentTarget.calories.clamp(1, double.infinity);
          }

          final newTarget = currentTarget.copyWith(
            calories: newCalories,
            carbsGrams: (currentTarget.carbsGrams * ratio).toInt(),
            fatGrams: (currentTarget.fatGrams * ratio).toInt(),
            audit: currentTarget.audit.copyWith(
              rawTargetCalories: newCalories.toDouble(),
              rawCarbsGrams: currentTarget.carbsGrams * ratio,
              rawFatGrams: currentTarget.fatGrams * ratio,
            ),
          );
          await nutritionRepository.setTarget(today, newTarget);
        } else {
          final profile = await personalizationDao.profileNow();
          final protein = profile != null
              ? (profile.currentWeightKg * 1.6).toInt()
              : (newCalories * 0.30 / 4).toInt();
          final fat = (newCalories * 0.25 / 9).toInt();
          final carbs = ((newCalories - protein * 4 - fat * 9).clamp(0, double.infinity) / 4).toInt();

          final target = NutritionTarget(
            basalCalories: 0,
            maintenanceCalories: 0,
            calories: newCalories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatGrams: fat,
            audit: NutritionTargetAudit(
              rawBasalCalories: 0.0,
              rawMaintenanceCalories: 0.0,
              rawTargetCalories: newCalories.toDouble(),
              rawProteinGrams: protein.toDouble(),
              rawCarbsGrams: carbs.toDouble(),
              rawFatGrams: fat.toDouble(),
            ),
          );
          await nutritionRepository.setTarget(today, target);
        }
        break;
      case AdaptationKind.recoveryDay:
        break;
      case AdaptationKind.workoutVolume:
      case AdaptationKind.programChange:
      case AdaptationKind.deloadWeek:
      case AdaptationKind.macroTarget:
        break;
    }
  }

  Future<DecisionActionResult?> _applyConfirmedDeload(AdaptationDecisionData entity) async {
    final payload = jsonDecode(entity.afterJson);
    final pendingSessions = payload['pendingSessions'] as int?;
    final scalePercent = payload['volumeScalePercent'] as int?;

    if (pendingSessions == null || scalePercent == null || pendingSessions <= 0 || scalePercent < 1 || scalePercent > 100) {
      return DecisionActionResultStale('Đề xuất giảm tải chứa dữ liệu không hợp lệ.');
    }

    final sessionIds = await workoutDao.getUpcomingIncompleteSessionIds(pendingSessions);
    if (sessionIds.isEmpty) {
      return DecisionActionResultStale('Không còn buổi tập sắp tới để áp dụng giảm tải.');
    }

    final sessions = await workoutDao.getSessions(sessionIds);
    if (sessions.length != sessionIds.length || sessions.any((s) => s.volumeScalePercent != 100)) {
      return DecisionActionResultStale('Lịch tập đã thay đổi kể từ khi tạo đề xuất giảm tải.');
    }

    final updated = await workoutDao.updateIncompleteSessionVolumeScale(sessionIds, scalePercent);
    if (updated != sessionIds.length) {
      return DecisionActionResultStale('Không thể áp dụng giảm tải vì lịch tập vừa thay đổi.');
    }

    payload['sessionIds'] = sessionIds;
    final afterJsonWithIds = jsonEncode(payload);

    final undoPayload = jsonDecode(entity.undoJson);
    undoPayload['sessionIds'] = sessionIds;
    final undoJsonWithIds = jsonEncode(undoPayload);

    await personalizationDao.updateDecisionPayloads(
      entity.id,
      afterJsonWithIds,
      undoJsonWithIds,
    );

    return null;
  }

  Future<DecisionActionResult?> _undoDeload(AdaptationDecisionData entity) async {
    final sessionIds = _extractSessionIds(entity.undoJson);
    if (sessionIds.isEmpty) {
      return DecisionActionResultStale('Không tìm thấy các buổi tập đã áp dụng giảm tải.');
    }
    await workoutDao.updateIncompleteSessionVolumeScale(sessionIds, 100);
    return null;
  }

  Future<void> _applyUndoEffect(AdaptationDecisionData entity) async {
    switch (entity.kind) {
      case AdaptationKind.calorieTarget:
        final originalCalories = _extractCalories(entity.undoJson);
        if (originalCalories == null) return;
        final today = todayEpochDay();

        final currentDayList = await personalizationDao.nutritionRangeNow(today, today);
        final currentDay = currentDayList.firstOrNull;
        if (currentDay == null) return;

        final currentCalories = currentDay.targetCalories;
        if (currentCalories == null) return;

        final currentProt = currentDay.targetProteinGrams ?? 0;
        final proteinCalories = currentProt * 4.0;
        final currentNonProtein = currentCalories - proteinCalories;
        final originalNonProtein = originalCalories - proteinCalories;

        final double ratio;
        if (currentNonProtein > 0 && originalNonProtein > 0) {
          ratio = originalNonProtein / currentNonProtein;
        } else {
          ratio = originalCalories / currentCalories.clamp(1, double.infinity);
        }

        final currentCarbs = currentDay.targetCarbsGrams ?? 0;
        final currentFat = currentDay.targetFatGrams ?? 0;

        final target = NutritionTarget(
          basalCalories: currentDay.targetBasalCalories ?? 0,
          maintenanceCalories: currentDay.targetMaintenanceCalories ?? 0,
          calories: originalCalories,
          proteinGrams: currentProt,
          carbsGrams: (currentCarbs * ratio).toInt(),
          fatGrams: (currentFat * ratio).toInt(),
          audit: NutritionTargetAudit(
            rawBasalCalories: (currentDay.targetBasalCalories ?? 0).toDouble(),
            rawMaintenanceCalories: (currentDay.targetMaintenanceCalories ?? 0).toDouble(),
            rawTargetCalories: originalCalories.toDouble(),
            rawProteinGrams: currentProt.toDouble(),
            rawCarbsGrams: currentCarbs * ratio,
            rawFatGrams: currentFat * ratio,
          ),
        );
        await nutritionRepository.setTarget(today, target);
        break;
      case AdaptationKind.recoveryDay:
      case AdaptationKind.workoutVolume:
      case AdaptationKind.programChange:
      case AdaptationKind.deloadWeek:
      case AdaptationKind.macroTarget:
        break;
    }
  }

  Future<DecisionActionResult?> _validateBeforeState(AdaptationDecisionData entity) async {
    switch (entity.kind) {
      case AdaptationKind.calorieTarget:
        final expectedCalories = _extractCalories(entity.beforeJson);
        if (expectedCalories == null) return null;
        final today = todayEpochDay();

        final currentDayList = await personalizationDao.nutritionRangeNow(today, today);
        final currentDay = currentDayList.firstOrNull;
        final actualCalories = currentDay?.targetCalories;

        if (actualCalories != null && actualCalories != expectedCalories) {
          return DecisionActionResultStale(
            'Mục tiêu calorie hiện tại ($actualCalories) khác với giá trị dự kiến ($expectedCalories). '
            'Quyết định này đã bị lỗi thời.',
          );
        }
        break;
      default:
        break;
    }
    return null;
  }

  int? _extractCalories(String json) {
    try {
      final payload = jsonDecode(json);
      return payload['calories'] as int?;
    } catch (_) {
      return null;
    }
  }

  List<int> _extractSessionIds(String json) {
    try {
      final payload = jsonDecode(json);
      final list = payload['sessionIds'] as List<dynamic>?;
      if (list == null) return const [];
      return list.map((e) => e as int).toList();
    } catch (_) {
      return const [];
    }
  }

  AdaptationDecision _entityToDecision(AdaptationDecisionData entity) {
    return AdaptationDecision(
      kind: entity.kind,
      mode: entity.mode,
      reasonVi: entity.reasonVi,
      beforeValue: entity.beforeJson,
      afterValue: entity.afterJson,
      undoPayload: entity.undoJson,
    );
  }
}
