import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/program/schedule_planner.dart';

void main() {
  group('SchedulePlannerOverflowTest', () {
    const int maxInt = 9223372036854775807;
    const int minInt = -9223372036854775808;

    test('dueDateOverflowIsRejectedInsteadOfWrapping', () {
      expect(
        () => SchedulePlanner.dueEpochDaysFromRestDays(
          startEpochDay: maxInt,
          restDays: const [0, 0],
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('latenessOverflowIsRejectedInsteadOfWrapping', () {
      expect(
        () => SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: const [minInt, 0],
          completedIndex: 0,
          completionEpochDay: maxInt,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('shiftedDueDateOverflowIsRejectedInsteadOfWrapping', () {
      expect(
        () => SchedulePlanner.carryForwardAfterCompletion(
          dueEpochDays: const [0, maxInt],
          completedIndex: 0,
          completionEpochDay: 1,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
