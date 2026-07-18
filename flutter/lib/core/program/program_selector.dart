import '../model/catalog_models.dart';
import '../model/goal_models.dart';

sealed class ProgramSelectionResult {}

class ProgramSelectionFound extends ProgramSelectionResult {
  final ProgramTemplate program;
  ProgramSelectionFound(this.program);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramSelectionFound &&
          runtimeType == other.runtimeType &&
          program == other.program;

  @override
  int get hashCode => program.hashCode;
}

class ProgramSelectionUnsupported extends ProgramSelectionResult {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramSelectionUnsupported &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class ProgramSelector {
  static ProgramSelectionResult select(
    GoalConfig config,
    List<ProgramTemplate> programs,
  ) {
    for (var g in config.goals) {
      final matches = programs.where((it) =>
          it.goal == g &&
          it.level == config.level &&
          it.equipmentProfile == config.equipmentProfile).toList();
          
      if (matches.isNotEmpty) {
        if (matches.length > 1) {
          throw ArgumentError(
              "Duplicate programs for goal=$g, level=${config.level}, equip=${config.equipmentProfile}");
        }
        return ProgramSelectionFound(matches.first);
      }
    }

    final fallbackMatches = programs.where((it) =>
        it.goal == config.goal &&
        it.level == config.level &&
        it.equipmentProfile == config.equipmentProfile).toList();

    if (fallbackMatches.length == 1) {
      return ProgramSelectionFound(fallbackMatches.first);
    }
    return ProgramSelectionUnsupported();
  }
}
