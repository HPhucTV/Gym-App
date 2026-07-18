import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/achievement/achievement_rules.dart';
import 'package:gym_app/core/model/achievement_models.dart';
import 'package:gym_app/core/model/workout_models.dart';

void main() {
  const today = 20638; // epoch day of 2026-07-03

  AchievementSnapshot snapshot({
    required List<int> completedEpochDays,
    int totalProgramSessions = 20,
    int targetPerWeek = 3,
    int currentHour = 12,
  }) {
    return AchievementSnapshot(
      completedEpochDays: completedEpochDays,
      totalProgramSessions: totalProgramSessions,
      targetPerWeek: targetPerWeek,
      todayEpochDay: today,
      currentHour: currentHour,
    );
  }

  test('half program rounds up for an odd number of sessions', () {
    final oneOfThree = snapshot(completedEpochDays: [today], totalProgramSessions: 3);
    final twoOfThree = snapshot(completedEpochDays: [today - 1, today], totalProgramSessions: 3);

    expect(AchievementRules.evaluate(oneOfThree).contains(AchievementType.halfProgram), isFalse);
    expect(AchievementRules.evaluate(twoOfThree).contains(AchievementType.halfProgram), isTrue);
  });

  test('streak is calculated from the supplied day instead of the device clock', () {
    final completedDays = List.generate(7, (index) => today - index);
    final result = AchievementRules.evaluate(
      snapshot(completedEpochDays: completedDays),
    );

    expect(result.contains(AchievementType.streak7), isTrue);
    expect(result.contains(AchievementType.streak14), isFalse);
  });

  test('time badges require a completion on the supplied day', () {
    final previousWorkout = AchievementRules.evaluate(
      snapshot(completedEpochDays: [today - 1], currentHour: 6),
    );
    final completedThisMorning = AchievementRules.evaluate(
      snapshot(completedEpochDays: [today], currentHour: 6),
    );

    expect(previousWorkout.contains(AchievementType.earlyBird), isFalse);
    expect(completedThisMorning.contains(AchievementType.earlyBird), isTrue);
  });

  test('program progress excludes completed workouts from replaced goals', () {
    final history = [
      CompletedWorkout(goalId: 1, completedEpochDay: today - 1),
      CompletedWorkout(goalId: 2, completedEpochDay: today),
    ];

    expect(completedEpochDaysForGoal(history, 2), [today]);
  });
}
