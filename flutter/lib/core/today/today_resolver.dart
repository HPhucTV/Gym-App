class ScheduledWorkout {
  final String id;
  final int sequence;
  final int dueEpochDay;
  final bool completed;

  ScheduledWorkout({
    required this.id,
    required this.sequence,
    required this.dueEpochDay,
    required this.completed,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledWorkout &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sequence == other.sequence &&
          dueEpochDay == other.dueEpochDay &&
          completed == other.completed;

  @override
  int get hashCode =>
      id.hashCode ^ sequence.hashCode ^ dueEpochDay.hashCode ^ completed.hashCode;
}

sealed class TodayResult {}

class TodayResultNoGoal extends TodayResult {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayResultNoGoal && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class TodayResultGoalComplete extends TodayResult {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayResultGoalComplete && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class TodayResultWorkout extends TodayResult {
  final ScheduledWorkout workout;
  TodayResultWorkout(this.workout);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayResultWorkout &&
          runtimeType == other.runtimeType &&
          workout == other.workout;

  @override
  int get hashCode => workout.hashCode;
}

class TodayResultRecovery extends TodayResult {
  final int nextDueEpochDay;
  TodayResultRecovery(this.nextDueEpochDay);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayResultRecovery &&
          runtimeType == other.runtimeType &&
          nextDueEpochDay == other.nextDueEpochDay;

  @override
  int get hashCode => nextDueEpochDay.hashCode;
}

class TodayResolver {
  static TodayResult resolve({
    required bool hasActiveGoal,
    required List<ScheduledWorkout> workouts,
    required int todayEpochDay,
  }) {
    if (!hasActiveGoal) return TodayResultNoGoal();

    final pendingWorkouts = workouts.where((w) => !w.completed).toList();
    if (pendingWorkouts.isEmpty) return TodayResultGoalComplete();

    pendingWorkouts.sort((a, b) {
      final seqCompare = a.sequence.compareTo(b.sequence);
      if (seqCompare != 0) return seqCompare;
      final dayCompare = a.dueEpochDay.compareTo(b.dueEpochDay);
      if (dayCompare != 0) return dayCompare;
      return a.id.compareTo(b.id);
    });

    final nextWorkout = pendingWorkouts.first;

    if (nextWorkout.dueEpochDay <= todayEpochDay) {
      return TodayResultWorkout(nextWorkout);
    } else {
      return TodayResultRecovery(nextWorkout.dueEpochDay);
    }
  }
}
