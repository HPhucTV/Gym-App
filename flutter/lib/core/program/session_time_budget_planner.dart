import '../model/catalog_models.dart';

class TimeBudgetSelection {
  final List<int> activeOrderIndices;
  final int estimatedMinutes;

  TimeBudgetSelection({
    required this.activeOrderIndices,
    required this.estimatedMinutes,
  });
}

class SessionTimeBudgetPlanner {
  static TimeBudgetSelection select(
    List<ExercisePrescription> exercises,
    int budgetMinutes,
  ) {
    if (exercises.isEmpty) {
      throw ArgumentError("A workout must contain at least one exercise");
    }
    if (budgetMinutes <= 0) {
      throw ArgumentError("Time budget must be positive");
    }

    final costs = exercises.map(estimatedMinutes).toList();
    var usedMinutes = 0;
    final active = <int>[];

    for (var index = 0; index < costs.length; index++) {
      final cost = costs[index];
      if (active.isEmpty || usedMinutes + cost <= budgetMinutes) {
        active.add(index);
        usedMinutes += cost;
      }
    }

    return TimeBudgetSelection(
      activeOrderIndices: active,
      estimatedMinutes: usedMinutes,
    );
  }

  static int estimatedMinutes(ExercisePrescription prescription) {
    final int activeSecondsPerSet;
    if (prescription.durationSeconds != null) {
      activeSecondsPerSet = prescription.durationSeconds!;
    } else {
      final minReps = prescription.minReps ?? 1;
      final maxReps = prescription.maxReps ?? prescription.minReps ?? 1;
      activeSecondsPerSet = ((minReps + maxReps) ~/ 2) * 4;
    }

    final totalSeconds =
        prescription.sets * (activeSecondsPerSet + prescription.restSeconds);
    return (totalSeconds / 60.0).ceil().clamp(1, double.infinity).toInt();
  }
}
