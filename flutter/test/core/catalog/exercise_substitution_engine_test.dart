import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/catalog/catalog_parser.dart';
import 'package:gym_app/core/catalog/catalog_validator.dart';
import 'package:gym_app/core/catalog/exercise_substitution_engine.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/model/goal_models.dart';

void main() {
  group('ExerciseSubstitutionEngineTest', () {
    test('candidates respect explicit review equipment and stable ranking', () {
      final source = exercise(
        id: "push_up",
        name: "Chống đẩy",
        equipment: [Equipment.bodyweight],
        substituteIds: ["machine_press", "knee_push_up", "barbell_press"],
      );
      final engine = ExerciseSubstitutionEngine(
        [
          source,
          exercise(id: "barbell_press", name: "Đẩy đòn", equipment: [Equipment.barbell], level: ExperienceLevel.intermediate),
          exercise(id: "knee_push_up", name: "Chống đẩy gối", equipment: [Equipment.bodyweight]),
          exercise(id: "machine_press", name: "Đẩy máy", equipment: [Equipment.machine]),
        ],
      );

      expect(
        engine.findSubstitutionCandidates("push_up", EquipmentProfile.bodyweightOnly).map((e) => e.id).toList(),
        equals(["knee_push_up"]),
      );
      expect(
        engine.findSubstitutionCandidates("push_up", EquipmentProfile.fullGym).map((e) => e.id).toList(),
        equals(["knee_push_up", "machine_press", "barbell_press"]),
      );
      expect(
        engine.findSubstitutionCandidates("missing", EquipmentProfile.fullGym),
        isEmpty,
      );
    });

    test('validator rejects unsafe substitution references', () {
      final source = exercise(
        id: "push_up",
        name: "Chống đẩy",
        equipment: [Equipment.bodyweight],
        substituteIds: ["push_up", "missing", "wrong_muscle", "wrong_pattern", "missing"],
      );
      final issues = CatalogValidator.validateExercises([
        source,
        exercise(id: "wrong_muscle", name: "Kéo lưng", equipment: [Equipment.bodyweight], muscle: MuscleGroup.back),
        exercise(
          id: "wrong_pattern",
          name: "Đẩy vai",
          equipment: [Equipment.bodyweight],
          movementPattern: MovementPattern.verticalPush,
        ),
      ]);

      expect(issues.any((issue) => issue.contains("itself")), isTrue);
      expect(issues.any((issue) => issue.contains("Unknown substitute 'missing'")), isTrue);
      expect(issues.any((issue) => issue.contains("duplicate substitute 'missing'")), isTrue);
      expect(issues.any((issue) => issue.contains("primary muscle")), isTrue);
      expect(issues.any((issue) => issue.contains("movement pattern")), isTrue);
    });

    test('bundled substitutions are reviewed reciprocal and useful', () {
      final file = File('assets/catalog/exercises_vi.json');
      expect(file.existsSync(), isTrue, reason: "Không tìm thấy file assets/catalog/exercises_vi.json");
      final raw = file.readAsStringSync();
      final exercises = CatalogParser.parseExercises(raw);
      final byId = {for (var e in exercises) e.id: e};

      expect(CatalogValidator.validateExercises(exercises).isEmpty, isTrue);
      expect(exercises.map((e) => e.substituteIds.length).reduce((a, b) => a + b) >= 30, isTrue);
      expect(byId["push_up"]?.substituteIds.contains("knee_push_up"), isTrue);
      expect(byId["split_squat"]?.substituteIds.contains("reverse_lunge"), isTrue);

      for (final exercise in exercises) {
        for (final substituteId in exercise.substituteIds) {
          final sub = byId[substituteId];
          expect(sub, isNotNull, reason: "Không tìm thấy bài tập thay thế '$substituteId' cho bài '${exercise.id}'");
          expect(sub!.substituteIds.contains(exercise.id), isTrue,
              reason: "Thiếu liên kết đảo nghịch: bài thay thế '$substituteId' phải chứa '${exercise.id}' trong substituteIds");
        }
      }
    });
  });
}

ExerciseDefinition exercise({
  required String id,
  required String name,
  required List<Equipment> equipment,
  ExperienceLevel level = ExperienceLevel.beginner,
  MuscleGroup muscle = MuscleGroup.chest,
  MovementPattern movementPattern = MovementPattern.horizontalPush,
  List<String> substituteIds = const [],
}) {
  return ExerciseDefinition(
    id: id,
    sourceId: "project:$id",
    nameVi: name,
    level: level,
    equipment: equipment,
    movementPattern: movementPattern,
    primaryMuscleGroup: muscle,
    instructionsVi: const ["Bước một.", "Bước hai."],
    substituteIds: substituteIds,
  );
}
