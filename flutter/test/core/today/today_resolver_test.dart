import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/today/today_resolver.dart';

void main() {
  test('inactiveGoalReturnsNoGoal', () {
    expect(
      TodayResolver.resolve(hasActiveGoal: false, workouts: [], todayEpochDay: 100),
      TodayResultNoGoal(),
    );
  });

  test('activeGoalWithEveryWorkoutCompletedReturnsGoalComplete', () {
    final sessions = [ScheduledWorkout(id: 'done', sequence: 0, dueEpochDay: 90, completed: true)];

    expect(
      TodayResolver.resolve(hasActiveGoal: true, workouts: sessions, todayEpochDay: 100),
      TodayResultGoalComplete(),
    );
  });

  test('earliestIncompleteWorkoutBySequenceWinsEvenWhenInputIsUnorderedAndOverdue', () {
    final earliest = ScheduledWorkout(id: 'first', sequence: 1, dueEpochDay: 90, completed: false);
    final sessions = [
      ScheduledWorkout(id: 'later', sequence: 2, dueEpochDay: 95, completed: false),
      ScheduledWorkout(id: 'completed', sequence: 0, dueEpochDay: 80, completed: true),
      earliest,
    ];

    expect(
      TodayResolver.resolve(hasActiveGoal: true, workouts: sessions, todayEpochDay: 100),
      TodayResultWorkout(earliest),
    );
  });

  test('futureEarliestWorkoutReturnsRecoveryWithNextDueDate', () {
    final next = ScheduledWorkout(id: 'next', sequence: 0, dueEpochDay: 105, completed: false);

    expect(
      TodayResolver.resolve(hasActiveGoal: true, workouts: [next], todayEpochDay: 100),
      TodayResultRecovery(105),
    );
  });
}
