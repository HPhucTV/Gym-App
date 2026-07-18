import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/program/program_selector.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/catalog_models.dart';

void main() {
  group('ProgramSelectorTest', () {
    final config = GoalConfig(
      goal: FitnessGoal.generalFitness,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.bodyweightOnly,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      restDayMode: RestDayMode.fullRest,
      trainingDays: const {},
      goals: const [FitnessGoal.generalFitness],
    );

    test('exactMatchReturnsFoundProgram', () {
      final expected = ProgramTemplate(
        id: "general-beginner-bodyweight",
        goal: config.goal,
        level: config.level,
        equipmentProfile: config.equipmentProfile,
        sessionsPerWeek: config.sessionsPerWeek,
        durationWeeks: config.durationWeeks,
        workouts: const [],
      );

      final result = ProgramSelector.select(config, [expected]);

      expect(result, equals(ProgramSelectionFound(expected)));
    });

    test('emptyCatalogReturnsUnsupported', () {
      final result = ProgramSelector.select(config, const []);

      expect(result, equals(ProgramSelectionUnsupported()));
    });

    test('reviewedBaseProgramCanAdaptToDifferentWeeklyFrequency', () {
      final differentProgram = ProgramTemplate(
        id: "different",
        goal: config.goal,
        level: config.level,
        equipmentProfile: config.equipmentProfile,
        sessionsPerWeek: 4,
        durationWeeks: config.durationWeeks,
        workouts: const [],
      );

      final result = ProgramSelector.select(config, [differentProgram]);

      expect(result, equals(ProgramSelectionFound(differentProgram)));
    });

    test('duplicateExactConfigurationsThrowArgumentError', () {
      final program1 = ProgramTemplate(
        id: "first",
        goal: config.goal,
        level: config.level,
        equipmentProfile: config.equipmentProfile,
        sessionsPerWeek: config.sessionsPerWeek,
        durationWeeks: config.durationWeeks,
        workouts: const [],
      );
      final program2 = ProgramTemplate(
        id: "second",
        goal: config.goal,
        level: config.level,
        equipmentProfile: config.equipmentProfile,
        sessionsPerWeek: config.sessionsPerWeek,
        durationWeeks: config.durationWeeks,
        workouts: const [],
      );

      expect(
        () => ProgramSelector.select(config, [program1, program2]),
        throwsArgumentError,
      );
    });
  });
}
