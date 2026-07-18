import '../model/catalog_models.dart';
import '../model/movement_block_models.dart';

class MovementBlockPlanner {
  static MovementBlock select(
    List<MovementBlock> blocks,
    MovementBlockKind kind,
    Set<MovementPattern> activePatterns,
  ) {
    final candidates = blocks.where((b) => b.kind == kind).toList();
    if (candidates.isEmpty) {
      throw ArgumentError("No movement blocks available for $kind");
    }

    if (activePatterns.isEmpty) {
      final mobilityBlocks = candidates
          .where((b) => b.movementPatterns.contains(MovementPattern.mobility))
          .toList();
      if (mobilityBlocks.isNotEmpty) {
        mobilityBlocks.sort((a, b) => a.id.compareTo(b.id));
        return mobilityBlocks.first;
      }
      candidates.sort((a, b) => a.id.compareTo(b.id));
      return candidates.first;
    }

    candidates.sort((a, b) {
      final aIntersection =
          a.movementPatterns.intersection(activePatterns).length;
      final bIntersection =
          b.movementPatterns.intersection(activePatterns).length;
      if (aIntersection != bIntersection) {
        // Sắp xếp giảm dần theo kích thước tập giao
        return bIntersection.compareTo(aIntersection);
      }
      return a.id.compareTo(b.id);
    });

    return candidates.first;
  }
}
