import 'dart:convert';
import '../model/catalog_models.dart';
import '../model/movement_block_models.dart';

class CatalogParser {
  static List<ExerciseDefinition> parseExercises(String raw) {
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((item) => ExerciseDefinition.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<ProgramTemplate> parsePrograms(String raw) {
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((item) => ProgramTemplate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<MovementBlock> parseMovementBlocks(String raw) {
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((item) => MovementBlock.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
