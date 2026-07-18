import 'package:freezed_annotation/freezed_annotation.dart';
import 'catalog_models.dart';

part 'movement_block_models.freezed.dart';
part 'movement_block_models.g.dart';

enum MovementBlockKind {
  @JsonValue('WARM_UP')
  warmUp,
  @JsonValue('COOL_DOWN')
  coolDown,
}

@freezed
abstract class MovementBlock with _$MovementBlock {
  const factory MovementBlock({
    required String id,
    required MovementBlockKind kind,
    required Set<MovementPattern> movementPatterns,
    required String titleVi,
    required List<String> stepsVi,
    required int estimatedMinutes,
  }) = _MovementBlock;

  factory MovementBlock.fromJson(Map<String, dynamic> json) =>
      _$MovementBlockFromJson(json);
}
