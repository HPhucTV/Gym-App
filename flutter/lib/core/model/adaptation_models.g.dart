// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdaptationDecision _$AdaptationDecisionFromJson(Map<String, dynamic> json) =>
    _AdaptationDecision(
      kind: $enumDecode(_$AdaptationKindEnumMap, json['kind']),
      mode: $enumDecode(_$AdaptationModeEnumMap, json['mode']),
      reasonVi: json['reasonVi'] as String,
      beforeValue: json['beforeValue'] as String,
      afterValue: json['afterValue'] as String,
      undoPayload: json['undoPayload'] as String,
    );

Map<String, dynamic> _$AdaptationDecisionToJson(_AdaptationDecision instance) =>
    <String, dynamic>{
      'kind': _$AdaptationKindEnumMap[instance.kind]!,
      'mode': _$AdaptationModeEnumMap[instance.mode]!,
      'reasonVi': instance.reasonVi,
      'beforeValue': instance.beforeValue,
      'afterValue': instance.afterValue,
      'undoPayload': instance.undoPayload,
    };

const _$AdaptationKindEnumMap = {
  AdaptationKind.calorieTarget: 'CALORIE_TARGET',
  AdaptationKind.macroTarget: 'MACRO_TARGET',
  AdaptationKind.recoveryDay: 'RECOVERY_DAY',
  AdaptationKind.workoutVolume: 'WORKOUT_VOLUME',
  AdaptationKind.programChange: 'PROGRAM_CHANGE',
  AdaptationKind.deloadWeek: 'DELOAD_WEEK',
};

const _$AdaptationModeEnumMap = {
  AdaptationMode.autoApply: 'AUTO_APPLY',
  AdaptationMode.requiresConfirmation: 'REQUIRES_CONFIRMATION',
};
