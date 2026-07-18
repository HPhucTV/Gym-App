// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalProfile _$PersonalProfileFromJson(Map<String, dynamic> json) =>
    _PersonalProfile(
      birthDateEpochDay: (json['birthDateEpochDay'] as num).toInt(),
      metabolicSex: $enumDecode(_$MetabolicSexEnumMap, json['metabolicSex']),
      heightCm: (json['heightCm'] as num).toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
      activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
      goalPace: $enumDecode(_$GoalPaceEnumMap, json['goalPace']),
      personalizationConsent: json['personalizationConsent'] as bool,
      cloudAiConsent: json['cloudAiConsent'] as bool,
    );

Map<String, dynamic> _$PersonalProfileToJson(_PersonalProfile instance) =>
    <String, dynamic>{
      'birthDateEpochDay': instance.birthDateEpochDay,
      'metabolicSex': _$MetabolicSexEnumMap[instance.metabolicSex]!,
      'heightCm': instance.heightCm,
      'currentWeightKg': instance.currentWeightKg,
      'targetWeightKg': instance.targetWeightKg,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'goalPace': _$GoalPaceEnumMap[instance.goalPace]!,
      'personalizationConsent': instance.personalizationConsent,
      'cloudAiConsent': instance.cloudAiConsent,
    };

const _$MetabolicSexEnumMap = {
  MetabolicSex.female: 'FEMALE',
  MetabolicSex.male: 'MALE',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'SEDENTARY',
  ActivityLevel.light: 'LIGHT',
  ActivityLevel.moderate: 'MODERATE',
  ActivityLevel.high: 'HIGH',
};

const _$GoalPaceEnumMap = {
  GoalPace.mild: 'MILD',
  GoalPace.standard: 'STANDARD',
  GoalPace.aggressive: 'AGGRESSIVE',
};
