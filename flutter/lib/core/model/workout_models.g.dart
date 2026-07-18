// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActiveGoal _$ActiveGoalFromJson(Map<String, dynamic> json) => _ActiveGoal(
      id: (json['id'] as num).toInt(),
      config: GoalConfig.fromJson(json['config'] as Map<String, dynamic>),
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
    );

Map<String, dynamic> _$ActiveGoalToJson(_ActiveGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'config': instance.config,
      'totalWorkouts': instance.totalWorkouts,
    };

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: (json['id'] as num).toInt(),
      goalId: (json['goalId'] as num).toInt(),
      sequenceIndex: (json['sequenceIndex'] as num).toInt(),
      titleVi: json['titleVi'] as String,
      focusVi: json['focusVi'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      dueEpochDay: (json['dueEpochDay'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedTimeBudgetMinutes:
          (json['selectedTimeBudgetMinutes'] as num?)?.toInt(),
      omittedExerciseCount:
          (json['omittedExerciseCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'sequenceIndex': instance.sequenceIndex,
      'titleVi': instance.titleVi,
      'focusVi': instance.focusVi,
      'estimatedMinutes': instance.estimatedMinutes,
      'dueEpochDay': instance.dueEpochDay,
      'exercises': instance.exercises,
      'selectedTimeBudgetMinutes': instance.selectedTimeBudgetMinutes,
      'omittedExerciseCount': instance.omittedExerciseCount,
    };

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      orderIndex: (json['orderIndex'] as num).toInt(),
      exerciseId: json['exerciseId'] as String,
      prescription: ExercisePrescription.fromJson(
          json['prescription'] as Map<String, dynamic>),
      isChecked: json['isChecked'] as bool,
      originalExerciseId: json['originalExerciseId'] as String?,
      isLightWorkout: json['isLightWorkout'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'orderIndex': instance.orderIndex,
      'exerciseId': instance.exerciseId,
      'prescription': instance.prescription,
      'isChecked': instance.isChecked,
      'originalExerciseId': instance.originalExerciseId,
      'isLightWorkout': instance.isLightWorkout,
    };

_CompletedWorkout _$CompletedWorkoutFromJson(Map<String, dynamic> json) =>
    _CompletedWorkout(
      goalId: (json['goalId'] as num).toInt(),
      completedEpochDay: (json['completedEpochDay'] as num).toInt(),
    );

Map<String, dynamic> _$CompletedWorkoutToJson(_CompletedWorkout instance) =>
    <String, dynamic>{
      'goalId': instance.goalId,
      'completedEpochDay': instance.completedEpochDay,
    };

_WorkoutHistoryEntry _$WorkoutHistoryEntryFromJson(Map<String, dynamic> json) =>
    _WorkoutHistoryEntry(
      sessionId: (json['sessionId'] as num).toInt(),
      goalId: (json['goalId'] as num).toInt(),
      sequenceIndex: (json['sequenceIndex'] as num).toInt(),
      dueEpochDay: (json['dueEpochDay'] as num).toInt(),
      completedEpochDay: (json['completedEpochDay'] as num?)?.toInt(),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      selectedTimeBudgetMinutes:
          (json['selectedTimeBudgetMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkoutHistoryEntryToJson(
        _WorkoutHistoryEntry instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'goalId': instance.goalId,
      'sequenceIndex': instance.sequenceIndex,
      'dueEpochDay': instance.dueEpochDay,
      'completedEpochDay': instance.completedEpochDay,
      'estimatedMinutes': instance.estimatedMinutes,
      'selectedTimeBudgetMinutes': instance.selectedTimeBudgetMinutes,
    };
