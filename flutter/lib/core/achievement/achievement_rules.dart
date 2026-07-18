import '../model/achievement_models.dart';
import '../model/workout_models.dart';

class AchievementSnapshot {
  final List<int> completedEpochDays;
  final int totalProgramSessions;
  final int targetPerWeek;
  final int todayEpochDay;
  final int currentHour;
  final int scanCount;
  final int checkInCount;
  final int allMuscleGroupsCount;
  final int muscleGroupsThisWeek;

  AchievementSnapshot({
    required this.completedEpochDays,
    required this.totalProgramSessions,
    required this.targetPerWeek,
    required this.todayEpochDay,
    required this.currentHour,
    this.scanCount = 0,
    this.checkInCount = 0,
    this.allMuscleGroupsCount = 0,
    this.muscleGroupsThisWeek = 0,
  });
}

List<int> completedEpochDaysForGoal(
  List<CompletedWorkout> history,
  int activeGoalId,
) {
  return history
      .where((w) => w.goalId == activeGoalId)
      .map((w) => w.completedEpochDay)
      .toList();
}

class AchievementRules {
  static Set<AchievementType> evaluate(AchievementSnapshot snapshot) {
    final completedDays = Set<int>.from(snapshot.completedEpochDays).toList()..sort();
    final totalCompleted = snapshot.completedEpochDays.length;
    final result = <AchievementType>{};
    final streak = _currentStreak(completedDays.toSet(), snapshot.todayEpochDay);

    // Tính thứ Hai của tuần hiện tại
    final weekStart = _getWeekStartEpochDay(snapshot.todayEpochDay);
    final completedThisWeek = snapshot.completedEpochDays
        .where((day) => day >= weekStart && day <= (weekStart + 6))
        .length;

    final completedToday = completedDays.contains(snapshot.todayEpochDay);

    _addIf(result, AchievementType.firstWorkout, totalCompleted >= 1);
    _addIf(result, AchievementType.streak7, streak >= 7);
    _addIf(result, AchievementType.streak14, streak >= 14);
    _addIf(result, AchievementType.streak30, streak >= 30);
    _addIf(
      result,
      AchievementType.perfectWeek,
      snapshot.targetPerWeek > 0 && completedThisWeek >= snapshot.targetPerWeek,
    );
    _addIf(
      result,
      AchievementType.halfProgram,
      snapshot.totalProgramSessions > 0 &&
          totalCompleted >= (snapshot.totalProgramSessions + 1) ~/ 2,
    );
    _addIf(
      result,
      AchievementType.fullProgram,
      snapshot.totalProgramSessions > 0 &&
          totalCompleted >= snapshot.totalProgramSessions,
    );
    _addIf(result, AchievementType.scan10, snapshot.scanCount >= 10);
    _addIf(result, AchievementType.checkin4, snapshot.checkInCount >= 4);
    _addIf(
      result,
      AchievementType.allMuscles,
      snapshot.allMuscleGroupsCount > 0 &&
          snapshot.muscleGroupsThisWeek >= snapshot.allMuscleGroupsCount,
    );
    _addIf(result, AchievementType.earlyBird, completedToday && snapshot.currentHour < 7);
    _addIf(result, AchievementType.nightOwl, completedToday && snapshot.currentHour >= 21);
    _addIf(result, AchievementType.workouts10, totalCompleted >= 10);
    _addIf(result, AchievementType.workouts50, totalCompleted >= 50);
    _addIf(result, AchievementType.workouts100, totalCompleted >= 100);

    return result;
  }

  static int _currentStreak(Set<int> completedDays, int todayEpochDay) {
    var cursor = completedDays.contains(todayEpochDay) ? todayEpochDay : todayEpochDay - 1;
    var streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor--;
    }
    return streak;
  }

  static void _addIf(Set<AchievementType> set, AchievementType type, bool condition) {
    if (condition) {
      set.add(type);
    }
  }

  static int _getWeekStartEpochDay(int epochDay) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochDay * 24 * 60 * 60 * 1000, isUtc: true);
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return (monday.millisecondsSinceEpoch / (24 * 60 * 60 * 1000)).floor();
  }
}
