// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutFeedback _$WorkoutFeedbackFromJson(Map<String, dynamic> json) =>
    _WorkoutFeedback(
      sessionId: (json['sessionId'] as num).toInt(),
      goalId: (json['goalId'] as num).toInt(),
      completedEpochDay: (json['completedEpochDay'] as num).toInt(),
      difficulty: $enumDecode(_$WorkoutDifficultyEnumMap, json['difficulty']),
      recordedAtEpochMillis: (json['recordedAtEpochMillis'] as num).toInt(),
    );

Map<String, dynamic> _$WorkoutFeedbackToJson(_WorkoutFeedback instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'goalId': instance.goalId,
      'completedEpochDay': instance.completedEpochDay,
      'difficulty': _$WorkoutDifficultyEnumMap[instance.difficulty]!,
      'recordedAtEpochMillis': instance.recordedAtEpochMillis,
    };

const _$WorkoutDifficultyEnumMap = {
  WorkoutDifficulty.easy: 'EASY',
  WorkoutDifficulty.right: 'RIGHT',
  WorkoutDifficulty.hard: 'HARD',
};
