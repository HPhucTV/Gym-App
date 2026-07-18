// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalConfig _$GoalConfigFromJson(Map<String, dynamic> json) => _GoalConfig(
      goal: $enumDecode(_$FitnessGoalEnumMap, json['goal']),
      level: $enumDecode(_$ExperienceLevelEnumMap, json['level']),
      equipmentProfile:
          $enumDecode(_$EquipmentProfileEnumMap, json['equipmentProfile']),
      sessionsPerWeek: (json['sessionsPerWeek'] as num).toInt(),
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      restDayMode: $enumDecode(_$RestDayModeEnumMap, json['restDayMode']),
      trainingDays: (json['trainingDays'] as List<dynamic>)
          .map((e) => $enumDecode(_$WeekDayEnumMap, e))
          .toSet(),
      sessionDurationMinutes:
          (json['sessionDurationMinutes'] as num?)?.toInt() ?? 45,
      goals: (json['goals'] as List<dynamic>)
          .map((e) => $enumDecode(_$FitnessGoalEnumMap, e))
          .toList(),
      gender:
          $enumDecodeNullable(_$GenderEnumMap, json['gender']) ?? Gender.male,
      bodyType: $enumDecodeNullable(_$BodyTypeEnumMap, json['bodyType']) ??
          BodyType.mesomorph,
    );

Map<String, dynamic> _$GoalConfigToJson(_GoalConfig instance) =>
    <String, dynamic>{
      'goal': _$FitnessGoalEnumMap[instance.goal]!,
      'level': _$ExperienceLevelEnumMap[instance.level]!,
      'equipmentProfile': _$EquipmentProfileEnumMap[instance.equipmentProfile]!,
      'sessionsPerWeek': instance.sessionsPerWeek,
      'durationWeeks': instance.durationWeeks,
      'restDayMode': _$RestDayModeEnumMap[instance.restDayMode]!,
      'trainingDays':
          instance.trainingDays.map((e) => _$WeekDayEnumMap[e]!).toList(),
      'sessionDurationMinutes': instance.sessionDurationMinutes,
      'goals': instance.goals.map((e) => _$FitnessGoalEnumMap[e]!).toList(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'bodyType': _$BodyTypeEnumMap[instance.bodyType]!,
    };

const _$FitnessGoalEnumMap = {
  FitnessGoal.muscleGain: 'MUSCLE_GAIN',
  FitnessGoal.fatLossConditioning: 'FAT_LOSS_CONDITIONING',
  FitnessGoal.endurance: 'ENDURANCE',
  FitnessGoal.generalFitness: 'GENERAL_FITNESS',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'BEGINNER',
  ExperienceLevel.intermediate: 'INTERMEDIATE',
};

const _$EquipmentProfileEnumMap = {
  EquipmentProfile.bodyweightOnly: 'BODYWEIGHT_ONLY',
  EquipmentProfile.dumbbells: 'DUMBBELLS',
  EquipmentProfile.resistanceBands: 'RESISTANCE_BANDS',
  EquipmentProfile.fullGym: 'FULL_GYM',
};

const _$RestDayModeEnumMap = {
  RestDayMode.fullRest: 'FULL_REST',
  RestDayMode.lightRecovery: 'LIGHT_RECOVERY',
};

const _$WeekDayEnumMap = {
  WeekDay.monday: 'monday',
  WeekDay.tuesday: 'tuesday',
  WeekDay.wednesday: 'wednesday',
  WeekDay.thursday: 'thursday',
  WeekDay.friday: 'friday',
  WeekDay.saturday: 'saturday',
  WeekDay.sunday: 'sunday',
};

const _$GenderEnumMap = {
  Gender.male: 'MALE',
  Gender.female: 'FEMALE',
};

const _$BodyTypeEnumMap = {
  BodyType.ectomorph: 'ECTOMORPH',
  BodyType.mesomorph: 'MESOMORPH',
  BodyType.endomorph: 'ENDOMORPH',
};
