import '../model/achievement_models.dart';
import '../model/workout_models.dart';
import 'achievement_rules.dart';

class AchievementChecker {
  final int Function() todayEpochDay;
  final int Function() currentHour;

  AchievementChecker({
    int Function()? todayEpochDay,
    int Function()? currentHour,
  })  : todayEpochDay = todayEpochDay ?? (() => (DateTime.now().millisecondsSinceEpoch / (24 * 60 * 60 * 1000)).floor()),
        currentHour = currentHour ?? (() => DateTime.now().hour);

  /// Đánh giá xem có thành tựu mới nào được mở khóa hay không.
  /// Trả về danh sách các [AchievementType] mới được mở khóa so với danh sách [existing].
  List<AchievementType> checkNewUnlocks({
    required List<CompletedWorkout> completed,
    required int activeGoalId,
    required int totalProgramSessions,
    required int targetPerWeek,
    required Set<AchievementType> existing,
    int scanCount = 0,
    int checkInCount = 0,
    int allMuscleGroupsCount = 0,
    int muscleGroupsThisWeek = 0,
  }) {
    final eligible = AchievementRules.evaluate(
      AchievementSnapshot(
        completedEpochDays: completedEpochDaysForGoal(completed, activeGoalId),
        totalProgramSessions: totalProgramSessions,
        targetPerWeek: targetPerWeek,
        todayEpochDay: todayEpochDay(),
        currentHour: currentHour(),
        scanCount: scanCount,
        checkInCount: checkInCount,
        allMuscleGroupsCount: allMuscleGroupsCount,
        muscleGroupsThisWeek: muscleGroupsThisWeek,
      ),
    );

    return eligible.where((type) => !existing.contains(type)).toList();
  }
}
