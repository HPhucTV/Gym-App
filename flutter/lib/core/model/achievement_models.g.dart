// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      unlockedAtEpochMillis: (json['unlockedAtEpochMillis'] as num).toInt(),
    );

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'unlockedAtEpochMillis': instance.unlockedAtEpochMillis,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.firstWorkout: 'FIRST_WORKOUT',
  AchievementType.streak7: 'STREAK_7',
  AchievementType.streak14: 'STREAK_14',
  AchievementType.streak30: 'STREAK_30',
  AchievementType.perfectWeek: 'PERFECT_WEEK',
  AchievementType.halfProgram: 'HALF_PROGRAM',
  AchievementType.fullProgram: 'FULL_PROGRAM',
  AchievementType.scan10: 'SCAN_10',
  AchievementType.checkin4: 'CHECKIN_4',
  AchievementType.allMuscles: 'ALL_MUSCLES',
  AchievementType.earlyBird: 'EARLY_BIRD',
  AchievementType.nightOwl: 'NIGHT_OWL',
  AchievementType.workouts10: 'WORKOUTS_10',
  AchievementType.workouts50: 'WORKOUTS_50',
  AchievementType.workouts100: 'WORKOUTS_100',
};
