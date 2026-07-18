import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/program/session_time_budget_planner.dart';

void main() {
  group('SessionTimeBudgetPlannerTest', () {
    final exercises = [
      prescription("compound", sets: 6, reps: 12, rest: 90),
      prescription("second", sets: 6, reps: 12, rest: 90),
      prescription("third", sets: 6, reps: 12, rest: 90),
      prescription("fourth", sets: 6, reps: 12, rest: 90),
    ];

    test('short budget always keeps first compound exercise', () {
      final result = SessionTimeBudgetPlanner.select(exercises, 15);

      expect(result.activeOrderIndices, isNotEmpty);
      expect(result.activeOrderIndices.first, equals(0));
    });

    test('larger budgets monotonically add an ordered prefix', () {
      final short = SessionTimeBudgetPlanner.select(exercises, 15).activeOrderIndices;
      final medium = SessionTimeBudgetPlanner.select(exercises, 30).activeOrderIndices;
      final long = SessionTimeBudgetPlanner.select(exercises, 45).activeOrderIndices;

      expect(short.every((it) => medium.contains(it)), isTrue);
      expect(medium.every((it) => long.contains(it)), isTrue);
      expect(short, equals(List.generate(short.length, (i) => i)));
      expect(medium, equals(List.generate(medium.length, (i) => i)));
      expect(long, equals(List.generate(long.length, (i) => i)));
    });

    test('estimate uses active work plus rest for every set', () {
      final result = SessionTimeBudgetPlanner.select(
        [
          const ExercisePrescription(
            exerciseId: "hold",
            sets: 3,
            minReps: null,
            maxReps: null,
            durationSeconds: 30,
            restSeconds: 60,
          )
        ],
        15,
      );

      expect(result.estimatedMinutes, equals(5));
    });
  });
}

ExercisePrescription prescription(String id, {required int sets, required int reps, required int rest}) {
  return ExercisePrescription(
    exerciseId: id,
    sets: sets,
    minReps: reps,
    maxReps: reps,
    durationSeconds: null,
    restSeconds: rest,
  );
}
