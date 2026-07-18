import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/catalog/catalog_validator.dart';
import 'package:gym_app/core/catalog/movement_block_planner.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/model/movement_block_models.dart';

void main() {
  group('MovementBlockPlannerTest', () {
    final blocks = [
      block("general_mobility_warmup", MovementBlockKind.warmUp, [MovementPattern.mobility]),
      block("push_warmup", MovementBlockKind.warmUp, [MovementPattern.horizontalPush]),
      block(
        "push_pull_warmup",
        MovementBlockKind.warmUp,
        [MovementPattern.horizontalPush, MovementPattern.horizontalPull],
      ),
      block("a_push_cooldown", MovementBlockKind.coolDown, [MovementPattern.horizontalPush]),
      block("z_push_cooldown", MovementBlockKind.coolDown, [MovementPattern.horizontalPush]),
    ];

    test('selects greatest distinct pattern overlap', () {
      final selected = MovementBlockPlanner.select(
        blocks,
        MovementBlockKind.warmUp,
        {MovementPattern.horizontalPush, MovementPattern.horizontalPull},
      );

      expect(selected.id, equals("push_pull_warmup"));
    });

    test('breaks overlap ties by stable block id', () {
      final selected = MovementBlockPlanner.select(
        blocks,
        MovementBlockKind.coolDown,
        {MovementPattern.horizontalPush},
      );

      expect(selected.id, equals("a_push_cooldown"));
    });

    test('empty workout returns general mobility block', () {
      final selected = MovementBlockPlanner.select(
        blocks,
        MovementBlockKind.warmUp,
        {},
      );

      expect(selected.id, equals("general_mobility_warmup"));
    });

    test('validator rejects malformed movement blocks', () {
      final malformed = block("Bad ID", MovementBlockKind.warmUp, []).copyWith(
        titleVi: "",
        stepsVi: ["", "b", "c", "d", "e", "f", "g"],
        estimatedMinutes: 1,
      );
      final duplicate = block("duplicate", MovementBlockKind.coolDown, [MovementPattern.core]);
      final issues = CatalogValidator.validateMovementBlocks([malformed, duplicate, duplicate]);

      final expectedWords = [
        "Duplicate",
        "id",
        "titleVi",
        "movementPatterns",
        "stepsVi",
        "blank",
        "estimatedMinutes"
      ];
      for (final expected in expectedWords) {
        expect(
          issues.any((issue) => issue.toLowerCase().contains(expected.toLowerCase())),
          isTrue,
          reason: "Thiếu '$expected' trong danh sách cảnh báo lỗi: $issues",
        );
      }
    });
  });
}

MovementBlock block(
  String id,
  MovementBlockKind kind,
  List<MovementPattern> patterns,
) {
  return MovementBlock(
    id: id,
    kind: kind,
    movementPatterns: patterns.toSet(),
    titleVi: "Chuẩn bị vận động",
    stepsVi: const ["Di chuyển chậm và có kiểm soát", "Hít thở đều"],
    estimatedMinutes: 4,
  );
}
