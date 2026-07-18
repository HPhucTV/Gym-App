import 'dart:async';
import 'catalog_parser.dart';
import 'catalog_validator.dart';
import '../model/catalog_models.dart';
import '../model/movement_block_models.dart';

class AssetCatalogRepository {
  final Future<String> Function(String) assetReader;

  AssetCatalogRepository({required this.assetReader});

  List<ExerciseDefinition>? _exercises;
  List<ProgramTemplate>? _programs;
  List<MovementBlock>? _movementBlocks;

  Future<void> init() async {
    if (_exercises != null && _programs != null && _movementBlocks != null) {
      return;
    }

    final exercisesRaw = await assetReader(_exercisesAsset);
    final parsedExercises = CatalogParser.parseExercises(exercisesRaw);
    final exerciseIssues = CatalogValidator.validateExercises(parsedExercises);
    if (exerciseIssues.isNotEmpty) {
      throw StateError(
          "Invalid bundled exercise catalog:\n${exerciseIssues.join('\n')}");
    }
    _exercises = parsedExercises;

    final programsRaw = await assetReader(_programsAsset);
    final parsedPrograms = CatalogParser.parsePrograms(programsRaw);
    final exercisesById = {for (var e in parsedExercises) e.id: e};
    final programIssues =
        CatalogValidator.validatePrograms(parsedPrograms, exercisesById);
    if (programIssues.isNotEmpty) {
      throw StateError(
          "Invalid bundled program catalog:\n${programIssues.join('\n')}");
    }
    _programs = parsedPrograms;

    final blocksRaw = await assetReader(_movementBlocksAsset);
    final parsedBlocks = CatalogParser.parseMovementBlocks(blocksRaw);
    final blockIssues = CatalogValidator.validateMovementBlocks(parsedBlocks);
    if (blockIssues.isNotEmpty) {
      throw StateError(
          "Invalid bundled movement blocks:\n${blockIssues.join('\n')}");
    }
    _movementBlocks = parsedBlocks;
  }

  List<ExerciseDefinition> get exercises =>
      _exercises ?? (throw StateError('Repository not initialized'));
  List<ProgramTemplate> get programs =>
      _programs ?? (throw StateError('Repository not initialized'));
  List<MovementBlock> get movementBlocks =>
      _movementBlocks ?? (throw StateError('Repository not initialized'));

  static const _exercisesAsset = 'assets/catalog/exercises_vi.json';
  static const _programsAsset = 'assets/catalog/programs.json';
  static const _movementBlocksAsset = 'assets/catalog/movement_blocks_vi.json';
}
