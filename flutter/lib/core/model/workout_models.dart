import 'package:freezed_annotation/freezed_annotation.dart';
import 'goal_models.dart';
import 'catalog_models.dart';

part 'workout_models.freezed.dart';
part 'workout_models.g.dart';

@freezed
abstract class ActiveGoal with _$ActiveGoal {
  const factory ActiveGoal({
    required int id,
    required GoalConfig config,
    required int totalWorkouts,
  }) = _ActiveGoal;

  factory ActiveGoal.fromJson(Map<String, dynamic> json) =>
      _$ActiveGoalFromJson(json);
}

@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required int id,
    required int goalId,
    required int sequenceIndex,
    required String titleVi,
    required String focusVi,
    required int estimatedMinutes,
    required int dueEpochDay,
    required List<WorkoutExercise> exercises,
    int? selectedTimeBudgetMinutes,
    @Default(0) int omittedExerciseCount,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required int orderIndex,
    required String exerciseId,
    required ExercisePrescription prescription,
    required bool isChecked,
    String? originalExerciseId,
    @Default(false) bool isLightWorkout,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}

@freezed
abstract class CompletedWorkout with _$CompletedWorkout {
  const factory CompletedWorkout({
    required int goalId,
    required int completedEpochDay,
  }) = _CompletedWorkout;

  factory CompletedWorkout.fromJson(Map<String, dynamic> json) =>
      _$CompletedWorkoutFromJson(json);
}

@freezed
abstract class WorkoutHistoryEntry with _$WorkoutHistoryEntry {
  const factory WorkoutHistoryEntry({
    required int sessionId,
    required int goalId,
    required int sequenceIndex,
    required int dueEpochDay,
    int? completedEpochDay,
    required int estimatedMinutes,
    int? selectedTimeBudgetMinutes,
  }) = _WorkoutHistoryEntry;

  factory WorkoutHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryEntryFromJson(json);
}
