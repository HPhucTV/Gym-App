// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_block_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovementBlock _$MovementBlockFromJson(Map<String, dynamic> json) =>
    _MovementBlock(
      id: json['id'] as String,
      kind: $enumDecode(_$MovementBlockKindEnumMap, json['kind']),
      movementPatterns: (json['movementPatterns'] as List<dynamic>)
          .map((e) => $enumDecode(_$MovementPatternEnumMap, e))
          .toSet(),
      titleVi: json['titleVi'] as String,
      stepsVi:
          (json['stepsVi'] as List<dynamic>).map((e) => e as String).toList(),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$MovementBlockToJson(_MovementBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$MovementBlockKindEnumMap[instance.kind]!,
      'movementPatterns': instance.movementPatterns
          .map((e) => _$MovementPatternEnumMap[e]!)
          .toList(),
      'titleVi': instance.titleVi,
      'stepsVi': instance.stepsVi,
      'estimatedMinutes': instance.estimatedMinutes,
    };

const _$MovementBlockKindEnumMap = {
  MovementBlockKind.warmUp: 'WARM_UP',
  MovementBlockKind.coolDown: 'COOL_DOWN',
};

const _$MovementPatternEnumMap = {
  MovementPattern.squat: 'SQUAT',
  MovementPattern.hinge: 'HINGE',
  MovementPattern.lunge: 'LUNGE',
  MovementPattern.horizontalPush: 'HORIZONTAL_PUSH',
  MovementPattern.verticalPush: 'VERTICAL_PUSH',
  MovementPattern.horizontalPull: 'HORIZONTAL_PULL',
  MovementPattern.verticalPull: 'VERTICAL_PULL',
  MovementPattern.carry: 'CARRY',
  MovementPattern.core: 'CORE',
  MovementPattern.locomotion: 'LOCOMOTION',
  MovementPattern.mobility: 'MOBILITY',
};
