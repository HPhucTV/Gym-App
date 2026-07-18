import '../model/goal_models.dart';

class TrainingSchedule {
  static const Set<int> durationBuckets = {30, 45, 60, 75, 90};

  static void validate(Set<WeekDay> trainingDays, int sessionDurationMinutes) {
    if (trainingDays.isEmpty || trainingDays.length > 6) {
      throw ArgumentError("Training days must contain 1..6 unique weekdays");
    }
    if (!durationBuckets.contains(sessionDurationMinutes)) {
      final sortedBuckets = durationBuckets.toList()..sort();
      throw ArgumentError("Session duration must be one of $sortedBuckets");
    }
  }

  static Set<WeekDay> defaultDays(int sessionsPerWeek) =>
      defaultTrainingDays(sessionsPerWeek);
}
