import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/progress/progress_calculator.dart';

void main() {
  group('ProgressCalculatorTest', () {
    int getEpochDay(int year, int month, int day) {
      final date = DateTime.utc(year, month, day);
      return date.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    }

    test('percentageHandlesEmptyNegativeOverCompleteAndLargeValues', () {
      expect(ProgressCalculator.percentage(4, 0), equals(0));
      expect(ProgressCalculator.percentage(-1, 10), equals(0));
      expect(ProgressCalculator.percentage(11, 10), equals(100));
      // Với số cực kỳ lớn trong Dart:
      expect(ProgressCalculator.percentage(1500000000, 2000000000), equals(75));
    });

    test('completedSessionsAreGroupedByMonthAndDuplicateDaysRemainSeparateSessions', () {
      final may31 = getEpochDay(2026, 5, 31);
      final june1 = getEpochDay(2026, 6, 1);

      final expectedMap = {
        YearMonth(2026, 5): 1,
        YearMonth(2026, 6): 2,
      };

      expect(
        ProgressCalculator.completedSessionsByMonth([june1, may31, june1]),
        equals(expectedMap),
      );
    });

    test('weeklyStreakCountsTwoConsecutiveQualifiedIsoWeeks', () {
      final monday = getEpochDay(2026, 6, 8);
      final completed = [0, 2, 4, 7, 9, 11].map((d) => monday + d).toList();

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completed,
          targetPerWeek: 3,
          currentEpochDay: monday + 13,
        ),
        equals(2),
      );
    });

    test('incompleteCurrentWeekPreservesStreakThroughPreviousWeek', () {
      final monday = getEpochDay(2026, 6, 8);
      final completed = [0, 2, 4].map((d) => monday + d).toList();

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completed,
          targetPerWeek: 3,
          currentEpochDay: monday + 8,
        ),
        equals(1),
      );
    });

    test('weeklyStreakUsesIsoWeeksAcrossYearBoundaryAndRetainsMultipleSessions', () {
      final dec29 = getEpochDay(2025, 12, 29);
      final completions = [dec29, dec29, dec29 + 2, dec29 + 7, dec29 + 9];

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completions,
          targetPerWeek: 2,
          currentEpochDay: dec29 + 13,
        ),
        equals(2),
      );
    });

    test('weeklyStreakCountsMultipleSessionsOnSameDay', () {
      final monday = getEpochDay(2026, 6, 8);
      final completions = [monday, monday, monday + 2];

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completions,
          targetPerWeek: 3,
          currentEpochDay: monday + 6,
        ),
        equals(1),
      );
    });

    test('gapBreaksWeeklyStreakAndNonPositiveTargetHasNoStreak', () {
      final monday = getEpochDay(2026, 6, 1);
      final completions = [monday, monday + 14];

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completions,
          targetPerWeek: 1,
          currentEpochDay: monday + 20,
        ),
        equals(1),
      );

      expect(
        ProgressCalculator.weeklyStreak(
          completedEpochDays: completions,
          targetPerWeek: 0,
          currentEpochDay: monday + 20,
        ),
        equals(0),
      );
    });
  });
}
