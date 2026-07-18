import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/adaptation/adaptation_engine.dart';
import 'package:gym_app/core/adaptation/weekly_snapshot.dart';
import 'package:gym_app/core/model/adaptation_models.dart';
import 'package:gym_app/core/model/feedback_models.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/core/program/program_phase_planner.dart';

void main() {
  final engine = AdaptationEngine();

  int day(int year, int month, int day) {
    final date = DateTime.utc(year, month, day);
    return date.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  PersonalProfile defaultProfile() {
    return PersonalProfile(
      birthDateEpochDay: day(1995, 6, 15),
      metabolicSex: MetabolicSex.male,
      heightCm: 175.0,
      currentWeightKg: 78.0,
      targetWeightKg: 72.0,
      activityLevel: ActivityLevel.moderate,
      goalPace: GoalPace.standard,
      personalizationConsent: true,
      cloudAiConsent: false,
    );
  }

  NutritionTarget defaultTarget() {
    return NutritionTarget(
      basalCalories: 1724,
      maintenanceCalories: 2672,
      calories: 2400,
      proteinGrams: 125,
      carbsGrams: 280,
      fatGrams: 67,
      audit: const NutritionTargetAudit(
        rawBasalCalories: 1724.0,
        rawMaintenanceCalories: 2672.0,
        rawTargetCalories: 2400.0,
        rawProteinGrams: 125.0,
        rawCarbsGrams: 280.0,
        rawFatGrams: 67.0,
      ),
    );
  }

  const defaultCheckIn = CheckInData(
    energy: 3,
    hunger: 3,
    recovery: 3,
    sleepQuality: 3,
  );

  WeeklySnapshot baseSnapshot({
    int currentCalories = 2400,
    int averageConsumedCalories = 2300,
    double adherencePercent = 0.85,
    List<double> recentWeights = const [78.0, 78.2],
    double targetWeightKg = 72.0,
    CheckInData? latestCheckIn = defaultCheckIn,
    int consecutiveLowRecoveryCheckIns = 0,
    int daysSinceLastCalorieDecision = 10,
    int daysSinceLastWorkoutDecision = 10,
    int trackedDays = 7,
    int completedSessionsThisWeek = 3,
    int scheduledSessionsThisWeek = 3,
    int missedSessions = 0,
    int profileAgeYears = 31,
    PersonalProfile? profile,
    List<WorkoutDifficultySample> lastDifficulties = const [],
    ProgramPhase currentProgramPhase = ProgramPhase.build,
  }) {
    return WeeklySnapshot(
      currentCalories: currentCalories,
      currentTarget: defaultTarget().copyWith(calories: currentCalories),
      averageConsumedCalories: averageConsumedCalories,
      adherencePercent: adherencePercent,
      recentWeights: recentWeights,
      targetWeightKg: targetWeightKg,
      latestCheckIn: latestCheckIn,
      consecutiveLowRecoveryCheckIns: consecutiveLowRecoveryCheckIns,
      daysSinceLastCalorieDecision: daysSinceLastCalorieDecision,
      daysSinceLastWorkoutDecision: daysSinceLastWorkoutDecision,
      trackedDays: trackedDays,
      completedSessionsThisWeek: completedSessionsThisWeek,
      scheduledSessionsThisWeek: scheduledSessionsThisWeek,
      missedSessions: missedSessions,
      profileAgeYears: profileAgeYears,
      profile: profile ?? defaultProfile(),
      lastDifficulties: lastDifficulties,
      currentProgramPhase: currentProgramPhase,
    );
  }

  AdaptationDecision? getSingleDecision(List<AdaptationDecision> decisions, AdaptationKind kind) {
    final filtered = decisions.where((it) => it.kind == kind).toList();
    if (filtered.length > 1) {
      fail("Expected at most one decision of kind $kind, but found ${filtered.length}");
    }
    return filtered.isNotEmpty ? filtered.first : null;
  }

  List<WorkoutDifficultySample> difficulties(List<WorkoutDifficulty> values) {
    return List.generate(values.length, (index) {
      return WorkoutDifficultySample(
        completedEpochDay: 20600 + index,
        difficulty: values[index],
      );
    });
  }

  group('Minimum data requirements', () {
    test('returns empty when tracked days below minimum', () {
      final snapshot = baseSnapshot(trackedDays: 5);
      expect(engine.evaluate(snapshot).isEmpty, isTrue);
    });

    test('returns empty when no check-in exists', () {
      final snapshot = baseSnapshot(latestCheckIn: null);
      expect(engine.evaluate(snapshot).isEmpty, isTrue);
    });

    test('returns empty when fewer than two weight measurements', () {
      final snapshot = baseSnapshot(recentWeights: [78.0]);
      expect(engine.evaluate(snapshot).isEmpty, isTrue);
    });

    test('returns empty when zero weight measurements', () {
      final snapshot = baseSnapshot(recentWeights: []);
      expect(engine.evaluate(snapshot).isEmpty, isTrue);
    });
  });

  group('Calorie correction: auto-apply', () {
    test('small calorie decrease auto-applies when losing weight is stalled', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 78.2],
        targetWeightKg: 72.0,
        adherencePercent: 0.85,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNotNull);
      expect(calorie!.mode, AdaptationMode.autoApply);
      expect(calorie.afterValue.contains(RegExp(r'"calories":\d+')), isTrue);

      final match = RegExp(r'"calories":(\d+)').firstMatch(calorie.afterValue);
      expect(match, isNotNull);
      final afterCalories = int.parse(match!.group(1)!);
      expect(afterCalories < 2400, isTrue);
    });

    test('small calorie increase auto-applies when gaining too slowly', () {
      final profile = defaultProfile().copyWith(targetWeightKg: 85.0);
      final snapshot = baseSnapshot(
        targetWeightKg: 85.0,
        recentWeights: [78.0, 78.0],
        adherencePercent: 0.80,
        profile: profile,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNotNull);
      expect(calorie!.mode, AdaptationMode.autoApply);

      final match = RegExp(r'"calories":(\d+)').firstMatch(calorie.afterValue);
      expect(match, isNotNull);
      final afterCalories = int.parse(match!.group(1)!);
      expect(afterCalories > 2400, isTrue);
    });
  });

  group('Calorie correction: requires confirmation', () {
    test('calorie correction requires confirmation when adherence below threshold', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
        adherencePercent: 0.50,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNotNull);
      expect(calorie!.mode, AdaptationMode.requiresConfirmation);
    });
  });

  group('Calorie correction: no action needed', () {
    test('no calorie decision when weight is trending correctly at acceptable rate', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 77.5],
        targetWeightKg: 72.0,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNull);
    });

    test('no calorie decision when weight already at target', () {
      final snapshot = baseSnapshot(
        recentWeights: [72.0, 72.0],
        targetWeightKg: 72.0,
        profile: defaultProfile().copyWith(currentWeightKg: 72.0, targetWeightKg: 72.0),
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNull);
    });
  });

  group('Calorie cooldown', () {
    test('no calorie decision during cooldown period', () {
      final snapshot = baseSnapshot(
        daysSinceLastCalorieDecision: 3,
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNull);
    });
  });

  group('Calorie cap enforcement', () {
    test('calorie change is capped at 5 percent or 150 kcal', () {
      final snapshot = baseSnapshot(
        currentCalories: 2400,
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNotNull);

      final beforeMatch = RegExp(r'"calories":(\d+)').firstMatch(calorie!.beforeValue);
      final afterMatch = RegExp(r'"calories":(\d+)').firstMatch(calorie.afterValue);
      expect(beforeMatch, isNotNull);
      expect(afterMatch, isNotNull);

      final beforeCalories = int.parse(beforeMatch!.group(1)!);
      final afterCalories = int.parse(afterMatch!.group(1)!);
      final actualDelta = (afterCalories - beforeCalories).abs();

      expect(actualDelta <= 150, isTrue);
      expect(actualDelta <= (beforeCalories * 0.05 + 1).toInt(), isTrue);
    });
  });

  group('Losing too fast -> small increase', () {
    test('suggests calorie increase when losing weight too fast', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 76.5],
        targetWeightKg: 72.0,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      expect(calorie, isNotNull);

      final match = RegExp(r'"calories":(\d+)').firstMatch(calorie!.afterValue);
      expect(match, isNotNull);
      final afterCalories = int.parse(match!.group(1)!);
      expect(afterCalories > 2400, isTrue);
    });
  });

  group('Recovery suggestion', () {
    test('suggests recovery when consecutive low recovery check-ins reach threshold', () {
      final snapshot = baseSnapshot(
        consecutiveLowRecoveryCheckIns: 2,
      );
      final decisions = engine.evaluate(snapshot);
      final recovery = getSingleDecision(decisions, AdaptationKind.recoveryDay);
      expect(recovery, isNotNull);
      expect(recovery!.mode, AdaptationMode.autoApply);
    });

    test('no recovery suggestion when low recovery count is below threshold', () {
      final snapshot = baseSnapshot(
        consecutiveLowRecoveryCheckIns: 1,
      );
      final decisions = engine.evaluate(snapshot);
      final recovery = getSingleDecision(decisions, AdaptationKind.recoveryDay);
      expect(recovery, isNull);
    });

    test('no recovery suggestion with zero low recovery check-ins', () {
      final snapshot = baseSnapshot(consecutiveLowRecoveryCheckIns: 0);
      final decisions = engine.evaluate(snapshot);
      final recovery = getSingleDecision(decisions, AdaptationKind.recoveryDay);
      expect(recovery, isNull);
    });
  });

  group('Workout volume', () {
    test('missed sessions produce volume decision requiring confirmation', () {
      final snapshot = baseSnapshot(
        missedSessions: 2,
        scheduledSessionsThisWeek: 4,
      );
      final decisions = engine.evaluate(snapshot);
      final volume = getSingleDecision(decisions, AdaptationKind.workoutVolume);
      expect(volume, isNotNull);
      expect(volume!.mode, AdaptationMode.requiresConfirmation);
    });

    test('one missed session does not trigger volume suggestion', () {
      final snapshot = baseSnapshot(missedSessions: 1);
      final decisions = engine.evaluate(snapshot);
      final volume = getSingleDecision(decisions, AdaptationKind.workoutVolume);
      expect(volume, isNull);
    });

    test('workout volume decision respects cooldown', () {
      final snapshot = baseSnapshot(
        missedSessions: 3,
        daysSinceLastWorkoutDecision: 3,
      );
      final decisions = engine.evaluate(snapshot);
      final volume = getSingleDecision(decisions, AdaptationKind.workoutVolume);
      expect(volume, isNull);
    });

    test('volume suggestion does not reduce below 1 session', () {
      final snapshot = baseSnapshot(
        missedSessions: 3,
        scheduledSessionsThisWeek: 1,
      );
      final decisions = engine.evaluate(snapshot);
      final volume = getSingleDecision(decisions, AdaptationKind.workoutVolume);
      expect(volume, isNotNull);

      final match = RegExp(r'"scheduledSessions":(\d+)').firstMatch(volume!.afterValue);
      expect(match, isNotNull);
      final afterSessions = int.parse(match!.group(1)!);
      expect(afterSessions >= 1, isTrue);
    });
  });

  group('Deload recommendation', () {
    test('three hard ratings in latest four sessions require confirmed deload', () {
      final snapshot = baseSnapshot(
        trackedDays: 0,
        recentWeights: [],
        lastDifficulties: difficulties([
          WorkoutDifficulty.hard,
          WorkoutDifficulty.hard,
          WorkoutDifficulty.right,
          WorkoutDifficulty.hard
        ]),
      );

      final deload = engine.evaluate(snapshot).singleWhere((it) => it.kind == AdaptationKind.deloadWeek);

      expect(deload.mode, AdaptationMode.requiresConfirmation);
      expect(deload.afterValue, '{"pendingSessions":3,"volumeScalePercent":70}');
      expect(deload.undoPayload, '{"pendingSessions":3,"volumeScalePercent":100}');
    });

    test('two hard ratings plus repeated low recovery require deload', () {
      final snapshot = baseSnapshot(
        consecutiveLowRecoveryCheckIns: 2,
        lastDifficulties: difficulties([WorkoutDifficulty.hard, WorkoutDifficulty.right, WorkoutDifficulty.hard]),
      );

      expect(engine.evaluate(snapshot).any((it) => it.kind == AdaptationKind.deloadWeek), isTrue);
    });

    test('deload is not proposed with weak evidence current deload phase or cooldown', () {
      expect(
        engine.evaluate(baseSnapshot(lastDifficulties: difficulties([WorkoutDifficulty.hard, WorkoutDifficulty.right]))).any((it) => it.kind == AdaptationKind.deloadWeek),
        isFalse,
      );
      expect(
        engine.evaluate(
          baseSnapshot(
            lastDifficulties: difficulties([WorkoutDifficulty.hard, WorkoutDifficulty.hard, WorkoutDifficulty.hard]),
            currentProgramPhase: ProgramPhase.deload,
          ),
        ).any((it) => it.kind == AdaptationKind.deloadWeek),
        isFalse,
      );
      expect(
        engine.evaluate(
          baseSnapshot(
            lastDifficulties: difficulties([WorkoutDifficulty.hard, WorkoutDifficulty.hard, WorkoutDifficulty.hard]),
            daysSinceLastWorkoutDecision: 3,
          ),
        ).any((it) => it.kind == AdaptationKind.deloadWeek),
        isFalse,
      );
    });
  });

  group('Multiple decisions can coexist', () {
    test('calorie and recovery decisions can be produced simultaneously', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
        consecutiveLowRecoveryCheckIns: 3,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = getSingleDecision(decisions, AdaptationKind.calorieTarget);
      final recovery = getSingleDecision(decisions, AdaptationKind.recoveryDay);
      expect(calorie, isNotNull);
      expect(recovery, isNotNull);
    });

    test('all three decision types can coexist in one evaluation', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
        consecutiveLowRecoveryCheckIns: 2,
        missedSessions: 2,
        scheduledSessionsThisWeek: 3,
      );
      final decisions = engine.evaluate(snapshot);
      expect(decisions.any((it) => it.kind == AdaptationKind.calorieTarget), isTrue);
      expect(decisions.any((it) => it.kind == AdaptationKind.recoveryDay), isTrue);
      expect(decisions.any((it) => it.kind == AdaptationKind.workoutVolume), isTrue);
    });
  });

  group('Undo payload correctness', () {
    test('calorie decision undo payload contains the original calories', () {
      final snapshot = baseSnapshot(
        currentCalories: 2400,
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
      );
      final decisions = engine.evaluate(snapshot);
      final calorie = decisions.singleWhere((it) => it.kind == AdaptationKind.calorieTarget);
      expect(calorie.undoPayload, '{"calories":2400}');
      expect(calorie.beforeValue, '{"calories":2400}');
    });
  });

  group('Reason text is non-empty Vietnamese', () {
    test('all decisions have non-empty Vietnamese reason text', () {
      final snapshot = baseSnapshot(
        recentWeights: [78.0, 78.5],
        targetWeightKg: 72.0,
        consecutiveLowRecoveryCheckIns: 2,
        missedSessions: 2,
      );
      final decisions = engine.evaluate(snapshot);
      expect(decisions.isNotEmpty, isTrue);
      for (var decision in decisions) {
        expect(decision.reasonVi.trim().isNotEmpty, isTrue);
      }
    });
  });
}
