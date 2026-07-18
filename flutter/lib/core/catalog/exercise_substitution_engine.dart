import '../model/catalog_models.dart';
import '../model/goal_models.dart';

extension ExerciseDefinitionSupport on ExerciseDefinition {
  bool supports(EquipmentProfile profile) {
    final Set<Equipment> allowed;
    switch (profile) {
      case EquipmentProfile.bodyweightOnly:
        allowed = {Equipment.bodyweight};
        break;
      case EquipmentProfile.dumbbells:
        allowed = {Equipment.bodyweight, Equipment.dumbbell};
        break;
      case EquipmentProfile.resistanceBands:
        allowed = {Equipment.bodyweight, Equipment.band};
        break;
      case EquipmentProfile.fullGym:
        allowed = Equipment.values.toSet();
        break;
    }
    return equipment.every((e) => allowed.contains(e));
  }
}

class ExerciseSubstitutionEngine {
  final Map<String, ExerciseDefinition> exercisesById;

  ExerciseSubstitutionEngine(List<ExerciseDefinition> exercises)
      : exercisesById = {for (var e in exercises) e.id: e};

  List<ExerciseDefinition> findSubstitutionCandidates(
    String exerciseId,
    EquipmentProfile profile,
  ) {
    final source = exercisesById[exerciseId];
    if (source == null) return [];

    final list = source.substituteIds
        .map((id) => exercisesById[id])
        .whereType<ExerciseDefinition>()
        .where((it) => it.primaryMuscleGroup == source.primaryMuscleGroup)
        .where((it) => it.movementPattern == source.movementPattern)
        .where((it) => it.supports(profile))
        .toList();

    // Distinct by ID
    final seen = <String>{};
    final distinctList = list.where((it) => seen.add(it.id)).toList();

    // Sort by level difference first (same level priority), then nameVi
    distinctList.sort((a, b) {
      final aDiffLevel = a.level != source.level;
      final bDiffLevel = b.level != source.level;
      if (aDiffLevel != bDiffLevel) {
        return aDiffLevel ? 1 : -1;
      }
      return a.nameVi.compareTo(b.nameVi);
    });

    return distinctList;
  }
}
