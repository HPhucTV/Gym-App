import '../model/feedback_models.dart';
import '../model/nutrition_models.dart';
import '../model/profile_models.dart';
import '../program/program_phase_planner.dart';

class WorkoutDifficultySample {
  final int completedEpochDay;
  final WorkoutDifficulty difficulty;

  const WorkoutDifficultySample({
    required this.completedEpochDay,
    required this.difficulty,
  });
}

class CheckInData {
  final int energy;
  final int hunger;
  final int recovery;
  final int sleepQuality;

  const CheckInData({
    required this.energy,
    required this.hunger,
    required this.recovery,
    required this.sleepQuality,
  });
}

class WeeklySnapshot {
  final int currentCalories;
  final NutritionTarget currentTarget;
  final int averageConsumedCalories;
  final double adherencePercent;
  final List<double> recentWeights;
  final double targetWeightKg;
  final CheckInData? latestCheckIn;
  final int consecutiveLowRecoveryCheckIns;
  final int daysSinceLastCalorieDecision;
  final int daysSinceLastWorkoutDecision;
  final int trackedDays;
  final int completedSessionsThisWeek;
  final int scheduledSessionsThisWeek;
  final int missedSessions;
  final int profileAgeYears;
  final PersonalProfile profile;
  final List<WorkoutDifficultySample> lastDifficulties;
  final ProgramPhase currentProgramPhase;

  WeeklySnapshot({
    required this.currentCalories,
    required this.currentTarget,
    required this.averageConsumedCalories,
    required this.adherencePercent,
    required this.recentWeights,
    required this.targetWeightKg,
    this.latestCheckIn,
    required this.consecutiveLowRecoveryCheckIns,
    required this.daysSinceLastCalorieDecision,
    required this.daysSinceLastWorkoutDecision,
    required this.trackedDays,
    required this.completedSessionsThisWeek,
    required this.scheduledSessionsThisWeek,
    required this.missedSessions,
    required this.profileAgeYears,
    required this.profile,
    this.lastDifficulties = const [],
    this.currentProgramPhase = ProgramPhase.build,
  });
}
