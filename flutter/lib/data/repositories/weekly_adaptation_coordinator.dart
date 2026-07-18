import 'dart:async';
import '../../core/adaptation/adaptation_engine.dart';
import '../../core/adaptation/weekly_snapshot.dart';
import '../../core/model/adaptation_models.dart';
import '../../core/model/workout_models.dart';
import '../../core/model/nutrition_models.dart';
import '../../core/model/feedback_models.dart';
import '../../core/model/profile_models.dart';
import '../../core/program/program_phase_planner.dart';
import '../local/database.dart' hide WorkoutSession;
import '../local/daos/personalization_dao.dart';
import 'adaptation_repository.dart';
import 'workout_repository.dart';
import 'workout_feedback_repository.dart';
import 'nutrition_repository.dart';

abstract class WeeklySnapshotProvider {
  Future<WeeklySnapshot?> snapshotFor(int currentEpochDay);
}

class WeeklyAdaptationCoordinator {
  final WeeklySnapshotProvider snapshotProvider;
  final AdaptationRepository adaptationRepository;
  final AdaptationEngine engine;

  WeeklyAdaptationCoordinator({
    required this.snapshotProvider,
    required this.adaptationRepository,
    AdaptationEngine? engine,
  }) : engine = engine ?? AdaptationEngine();

  Future<List<int>> evaluateAfterCheckIn(int currentEpochDay) async {
    final snapshot = await snapshotProvider.snapshotFor(currentEpochDay);
    if (snapshot == null) return const [];

    final decisions = engine.evaluate(snapshot);
    final ids = <int>[];
    for (final d in decisions) {
      final id = await adaptationRepository.recordDecision(d);
      ids.add(id);
    }
    return ids;
  }
}

class WeeklySnapshotInputs {
  final int currentEpochDay;
  final ActiveGoal goal;
  final WorkoutSession? currentSession;
  final List<CompletedWorkout> completedWorkouts;
  final List<WorkoutFeedback> feedback;
  final List<NutritionDay> nutritionDays;
  final List<double> recentWeights;
  final List<CheckInData> checkInsNewestFirst;
  final NutritionTarget currentTarget;
  final PersonalProfile profile;
  final int daysSinceLastCalorieDecision;
  final int daysSinceLastWorkoutDecision;
  final int missedSessions;

  const WeeklySnapshotInputs({
    required this.currentEpochDay,
    required this.goal,
    this.currentSession,
    required this.completedWorkouts,
    required this.feedback,
    required this.nutritionDays,
    required this.recentWeights,
    required this.checkInsNewestFirst,
    required this.currentTarget,
    required this.profile,
    required this.daysSinceLastCalorieDecision,
    required this.daysSinceLastWorkoutDecision,
    this.missedSessions = 0,
  });
}

class WeeklySnapshotAssembler {
  static WeeklySnapshot build(WeeklySnapshotInputs inputs) {
    // Chuyển đổi epoch day sang DateTime
    final currentDate = DateTime.fromMillisecondsSinceEpoch(
        inputs.currentEpochDay * 24 * 60 * 60 * 1000,
        isUtc: true);
    final monday =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final weekStart = monday.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    final weekEnd = weekStart + 6;

    final completedThisWeek = inputs.completedWorkouts.where((workout) {
      return workout.goalId == inputs.goal.id &&
          workout.completedEpochDay >= weekStart &&
          workout.completedEpochDay <= weekEnd;
    }).length;

    final trackedDays =
        inputs.nutritionDays.where((it) => it.consumed.calories > 0).toList();
    final double averageConsumed;
    if (trackedDays.isEmpty) {
      averageConsumed = 0.0;
    } else {
      averageConsumed = trackedDays
              .map((it) => it.consumed.calories)
              .reduce((a, b) => a + b) /
          trackedDays.length;
    }

    final double adherencePercent;
    if (trackedDays.isEmpty) {
      adherencePercent = 0.0;
    } else {
      final metTargetCount = trackedDays
          .where((it) =>
              it.consumed.calories >= inputs.currentTarget.calories * 0.7)
          .length;
      adherencePercent = metTargetCount / trackedDays.length;
    }

    final durationWeeks =
        inputs.goal.config.durationWeeks.clamp(1, double.infinity).toInt();
    final sessionsPerWeek =
        inputs.goal.config.sessionsPerWeek.clamp(1, double.infinity).toInt();
    final currentWeek = inputs.currentSession != null
        ? (inputs.currentSession!.sequenceIndex ~/ sessionsPerWeek + 1)
            .clamp(1, durationWeeks)
        : durationWeeks;

    final phase = ProgramPhasePlanner.phaseFor(currentWeek, durationWeeks);

    final birthDate = DateTime.fromMillisecondsSinceEpoch(
        inputs.profile.birthDateEpochDay * 24 * 60 * 60 * 1000,
        isUtc: true);
    int years = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      years--;
    }

    final sortedFeedback = List<WorkoutFeedback>.from(inputs.feedback)
      ..sort((a, b) => a.completedEpochDay.compareTo(b.completedEpochDay));
    final lastDifficulties = sortedFeedback.reversed
        .take(4)
        .toList()
        .reversed
        .map((it) => WorkoutDifficultySample(
              completedEpochDay: it.completedEpochDay,
              difficulty: it.difficulty,
            ))
        .toList();

    int consecutiveLowRecoveryCheckIns = 0;
    for (final checkIn in inputs.checkInsNewestFirst) {
      if (checkIn.recovery <= 2) {
        consecutiveLowRecoveryCheckIns++;
      } else {
        break;
      }
    }

    return WeeklySnapshot(
      currentCalories: inputs.currentTarget.calories,
      currentTarget: inputs.currentTarget,
      averageConsumedCalories: averageConsumed.round(),
      adherencePercent: adherencePercent,
      recentWeights: inputs.recentWeights,
      targetWeightKg: inputs.profile.targetWeightKg,
      latestCheckIn: inputs.checkInsNewestFirst.firstOrNull,
      consecutiveLowRecoveryCheckIns: consecutiveLowRecoveryCheckIns,
      daysSinceLastCalorieDecision: inputs.daysSinceLastCalorieDecision,
      daysSinceLastWorkoutDecision: inputs.daysSinceLastWorkoutDecision,
      trackedDays: trackedDays.length,
      completedSessionsThisWeek: completedThisWeek,
      scheduledSessionsThisWeek: inputs.goal.config.sessionsPerWeek,
      missedSessions: inputs.missedSessions,
      profileAgeYears: years,
      profile: inputs.profile,
      lastDifficulties: lastDifficulties,
      currentProgramPhase: phase,
    );
  }
}

class DriftWeeklySnapshotProvider implements WeeklySnapshotProvider {
  final GymDatabase database;
  final WorkoutRepository workoutRepository;
  final WorkoutFeedbackRepository feedbackRepository;
  final NutritionRepository nutritionRepository;
  final int Function() nowEpochMillis;

  DriftWeeklySnapshotProvider({
    required this.database,
    required this.workoutRepository,
    required this.feedbackRepository,
    required this.nutritionRepository,
    required this.nowEpochMillis,
  });

  PersonalizationDao get personalizationDao => database.personalizationDao;

  @override
  Future<WeeklySnapshot?> snapshotFor(int currentEpochDay) async {
    final goal = await workoutRepository.observeActiveGoal().first;
    if (goal == null) return null;

    final profileEntity = await personalizationDao.profileNow();
    if (profileEntity == null) return null;

    final todayNutrition =
        await nutritionRepository.observeDay(currentEpochDay).first;
    final currentTarget = todayNutrition.target;
    if (currentTarget == null) return null;

    final decisions = await personalizationDao.decisionHistoryNow();
    final allHistory = await workoutRepository.observeWorkoutHistory().first;
    final allSessions = allHistory.where((s) => s.goalId == goal.id).toList();

    int missedCount = 0;
    for (final s in allSessions) {
      if (s.completedEpochDay == null && s.dueEpochDay < currentEpochDay) {
        missedCount++;
      }
    }

    final currentSession =
        await workoutRepository.observeCurrentWorkout().first;
    final completedWorkouts =
        await workoutRepository.observeCompletedWorkouts().first;
    final feedback = await feedbackRepository.observeForGoal(goal.id).first;

    final rangeStart = currentEpochDay - 6;
    final nutritionDays = await nutritionRepository
        .observeRange(rangeStart, currentEpochDay)
        .first;

    final weights = await personalizationDao.weightHistoryNow();
    final recentWeights = weights.reversed
        .take(4)
        .toList()
        .reversed
        .map((it) => it.weightKg)
        .toList();

    final checkIns = await personalizationDao.observeAllCheckIns().first;
    final checkInsNewestFirst = checkIns.map((row) {
      return CheckInData(
        energy: row.energy,
        hunger: row.hunger,
        recovery: row.recovery,
        sleepQuality: row.sleepQuality,
      );
    }).toList();

    int? lastCalorieDecisionTime;
    for (final d in decisions) {
      if (d.kind == AdaptationKind.calorieTarget) {
        if (lastCalorieDecisionTime == null ||
            d.createdAtEpochMillis > lastCalorieDecisionTime) {
          lastCalorieDecisionTime = d.createdAtEpochMillis;
        }
      }
    }

    int? lastWorkoutDecisionTime;
    for (final d in decisions) {
      if (d.kind == AdaptationKind.workoutVolume ||
          d.kind == AdaptationKind.deloadWeek) {
        if (lastWorkoutDecisionTime == null ||
            d.createdAtEpochMillis > lastWorkoutDecisionTime) {
          lastWorkoutDecisionTime = d.createdAtEpochMillis;
        }
      }
    }

    return WeeklySnapshotAssembler.build(
      WeeklySnapshotInputs(
        currentEpochDay: currentEpochDay,
        goal: goal,
        currentSession: currentSession,
        completedWorkouts: completedWorkouts,
        feedback: feedback,
        nutritionDays: nutritionDays,
        recentWeights: recentWeights,
        checkInsNewestFirst: checkInsNewestFirst,
        currentTarget: currentTarget,
        profile: PersonalProfile(
          birthDateEpochDay: profileEntity.birthDateEpochDay,
          metabolicSex: profileEntity.metabolicSex,
          heightCm: profileEntity.heightCm,
          currentWeightKg: profileEntity.currentWeightKg,
          targetWeightKg: profileEntity.targetWeightKg,
          activityLevel: profileEntity.activityLevel,
          goalPace: profileEntity.goalPace,
          personalizationConsent: profileEntity.personalizationConsent,
          cloudAiConsent: profileEntity.cloudAiConsent,
        ),
        daysSinceLastCalorieDecision:
            _daysSinceLastDecision(lastCalorieDecisionTime),
        daysSinceLastWorkoutDecision:
            _daysSinceLastDecision(lastWorkoutDecisionTime),
        missedSessions: missedCount,
      ),
    );
  }

  int _daysSinceLastDecision(int? createdAtEpochMillis) {
    if (createdAtEpochMillis == null)
      return 2147483647; // Int.MAX_VALUE trong Java
    final elapsed = nowEpochMillis() - createdAtEpochMillis;
    if (elapsed < 0) return 0;
    final days = elapsed ~/ 86400000;
    return days.clamp(0, 2147483647);
  }
}
