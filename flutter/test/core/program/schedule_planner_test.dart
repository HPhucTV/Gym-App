import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/program/schedule_planner.dart';

void main() {
  group('SchedulePlannerTest', () {
    int getEpochDay(String dateStr) {
      final date = DateTime.parse("${dateStr}T00:00:00Z");
      return date.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    }

    test('selectedWeekdaysDriveDueDatesAcrossWeekBoundaries', () {
      final monday = getEpochDay("2026-07-06");

      final dates = SchedulePlanner.dueEpochDaysFromWeekdays(
        startEpochDay: monday,
        trainingDays: {DateTime.monday, DateTime.wednesday, DateTime.friday},
        workoutCount: 5,
      );

      final expected = [
        "2026-07-06",
        "2026-07-08",
        "2026-07-10",
        "2026-07-13",
        "2026-07-15"
      ].map((d) => getEpochDay(d)).toList();

      expect(dates, equals(expected));
    });

    test('dueDatesStartOnStartDayAndUsePreviousSessionRestDays', () {
      expect(
        SchedulePlanner.dueEpochDaysFromRestDays(
          startEpochDay: 100,
          restDays: const [1, 1, 2],
        ),
        equals([100, 102, 104]),
      );
    });

    test('emptyScheduleHasNoDueDates', () {
      expect(
        SchedulePlanner.dueEpochDaysFromRestDays(
          startEpochDay: 100,
          restDays: const [],
        ),
        isEmpty,
      );
    });

    test('negativeRestDaysAreRejected', () {
      expect(
        () => SchedulePlanner.dueEpochDaysFromRestDays(
          startEpochDay: 100,
          restDays: const [1, -1],
        ),
        throwsArgumentError,
      );
    });

    test('lateCompletionShiftsOnlyLaterWorkoutsByLateness', () {
      final shifted = SchedulePlanner.carryForwardAfterCompletion(
        dueEpochDays: const [10, 12, 14, 16],
        completedIndex: 1,
        completionEpochDay: 15,
      );

      expect(shifted, equals([10, 12, 17, 19]));
    });

    test('lateCompletionOfFirstWorkoutShiftsAllRemainingWorkouts', () {
      expect(
        SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: const [10, 12, 14],
          completedIndex: 0,
          completionEpochDay: 12,
        ),
        equals([10, 14, 16]),
      );
    });

    test('onTimeOrEarlyCompletionDoesNotMoveScheduleEarlier', () {
      const dueDates = [10, 12, 14];

      expect(
        SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: dueDates,
          completedIndex: 1,
          completionEpochDay: 12,
        ),
        equals(dueDates),
      );
      expect(
        SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: dueDates,
          completedIndex: 1,
          completionEpochDay: 11,
        ),
        equals(dueDates),
      );
    });

    test('invalidCompletedIndexIsRejected', () {
      expect(
        () => SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: const [10],
          completedIndex: 1,
          completionEpochDay: 12,
        ),
        throwsRangeError,
      );
    });
  });
}
