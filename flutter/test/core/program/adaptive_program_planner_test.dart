import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/program/adaptive_program_planner.dart';

void main() {
  group('AdaptiveProgramPlannerTest', () {
    GoalConfig config(int sessions, int minutes, {int durationWeeks = 2}) {
      final days = {
        WeekDay.monday,
        WeekDay.tuesday,
        WeekDay.wednesday,
        WeekDay.thursday,
        WeekDay.friday,
        WeekDay.saturday,
        WeekDay.sunday
      }.take(sessions).toSet();
      return GoalConfig(
        goal: FitnessGoal.generalFitness,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.bodyweightOnly,
        sessionsPerWeek: sessions,
        durationWeeks: durationWeeks,
        restDayMode: RestDayMode.fullRest,
        trainingDays: days,
        sessionDurationMinutes: minutes,
        goals: [FitnessGoal.generalFitness],
      );
    }

    ProgramTemplate program() {
      return ProgramTemplate(
        id: "base",
        goal: FitnessGoal.generalFitness,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.bodyweightOnly,
        sessionsPerWeek: 2,
        durationWeeks: 2,
        workouts: [
          workout(0, 1, "A", ["one", "two"]),
          workout(1, 1, "B", ["three", "four"]),
          workout(2, 2, "A", ["one", "two"]),
          workout(3, 2, "B", ["three", "four"]),
        ],
      );
    }

    test('cycles reviewed workouts for requested weekly frequency', () {
      final plan = AdaptiveProgramPlanner.adapt(program(), config(6, 45));

      expect(plan.length, equals(12));
      expect(plan.map((w) => w.sequence).toList(), equals(List.generate(12, (i) => i)));
      expect(plan.take(6).map((w) => w.titleVi).toList(), equals(["A", "B", "A", "B", "A", "B"]));
    });

    test('longer duration monotonically adds reviewed exercises', () {
      final shortPlan = AdaptiveProgramPlanner.adapt(program(), config(3, 30));
      final longPlan = AdaptiveProgramPlanner.adapt(program(), config(3, 90));

      final shortExercises = shortPlan.first.exercises.map((e) => e.exerciseId).toList();
      final longExercises = longPlan.first.exercises.map((e) => e.exerciseId).toList();

      expect(shortExercises, isNotEmpty);
      expect(longExercises.length >= shortExercises.length, isTrue);
      expect(longExercises.take(shortExercises.length).toList(), equals(shortExercises));
      expect(longExercises.every((id) => const {"one", "two", "three", "four"}.contains(id)), isTrue);
    });

    test('same inputs always produce identical snapshots', () {
      final first = AdaptiveProgramPlanner.adapt(program(), config(5, 75));
      final second = AdaptiveProgramPlanner.adapt(program(), config(5, 75));

      expect(first, equals(second));
    });

    test('phase policy changes only prescribed sets within safe bounds', () {
      final plan = AdaptiveProgramPlanner.adapt(program(), config(1, 90, durationWeeks: 8));

      expect(plan.firstWhere((w) => w.week == 1).exercises.first.sets, equals(3));
      expect(plan.firstWhere((w) => w.week == 3).exercises.first.sets, equals(4));
      expect(plan.firstWhere((w) => w.week == 6).exercises.first.sets, equals(3));
      expect(plan.firstWhere((w) => w.week == 8).exercises.first.sets, equals(2));

      final original = program().workouts.first.exercises.first;
      final build = plan.firstWhere((w) => w.week == 3).exercises.first;
      expect(build.exerciseId, equals(original.exerciseId));
      expect(build.minReps, equals(original.minReps));
      expect(build.maxReps, equals(original.maxReps));
      expect(build.durationSeconds, equals(original.durationSeconds));
      expect(build.restSeconds, equals(original.restSeconds));
    });
  });
}

WorkoutTemplate workout(int sequence, int week, String title, List<String> ids) {
  return WorkoutTemplate(
    sequence: sequence,
    week: week,
    titleVi: title,
    focusVi: title,
    estimatedMinutes: 45,
    restDaysAfter: 0,
    exercises: ids.map((id) => ExercisePrescription(
      exerciseId: id,
      sets: 3,
      minReps: 10,
      maxReps: 12,
      durationSeconds: null,
      restSeconds: 60,
    )).toList(),
  );
}
