import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/adaptation_models.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/core/profile/profile_goal_validator.dart';

void main() {
  final today = DateTime.utc(2026, 7, 2);

  int day(int year, int month, int day) {
    return DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  int epochDayMinusYears(DateTime date, int years) {
    final targetDate = DateTime.utc(date.year - years, date.month, date.day);
    return targetDate.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  PersonalProfile validProfile() {
    return PersonalProfile(
      birthDateEpochDay: day(1995, 6, 15),
      metabolicSex: MetabolicSex.male,
      heightCm: 175.0,
      currentWeightKg: 78.0,
      targetWeightKg: 72.0,
      activityLevel: ActivityLevel.moderate,
      goalPace: GoalPace.standard,
      personalizationConsent: true,
      cloudAiConsent: false,
    );
  }

  test('valid profile accepts all personalization inputs', () {
    final profile = validProfile();
    expect(profile.validationIssues(today).isEmpty, isTrue);
  });

  test('invalid anthropometrics are rejected', () {
    final profile = validProfile().copyWith(
      heightCm: 0.0,
      currentWeightKg: -1.0,
      targetWeightKg: double.nan,
    );

    final issues = profile.validationIssues(today);

    expect(issues.any((it) => it.toLowerCase().contains("chiều cao")), isTrue);
    expect(issues.any((it) => it.toLowerCase().contains("cân nặng hiện tại")), isTrue);
    expect(issues.any((it) => it.toLowerCase().contains("cân nặng mục tiêu")), isTrue);
  });

  test('profile requires adult age and personalization consent', () {
    final underage = validProfile().copyWith(
      birthDateEpochDay: epochDayMinusYears(today, 17),
      personalizationConsent: false,
    );

    final issues = underage.validationIssues(today);

    expect(issues.any((it) => it.contains("18")), isTrue);
    expect(issues.any((it) => it.toLowerCase().contains("đồng ý")), isTrue);
  });

  test('age boundaries are inclusive', () {
    final exactly18 = validProfile().copyWith(birthDateEpochDay: epochDayMinusYears(today, 18));
    final exactly100 = validProfile().copyWith(birthDateEpochDay: epochDayMinusYears(today, 100));

    expect(exactly18.validationIssues(today).any((it) => it.toLowerCase().contains("tuổi")), isFalse);
    expect(exactly100.validationIssues(today).any((it) => it.toLowerCase().contains("tuổi")), isFalse);
  });

  test('fat loss requires a lower target weight', () {
    final issues = ProfileGoalValidator.validate(
      profile: validProfile().copyWith(targetWeightKg: 82.0),
      fitnessGoal: FitnessGoal.fatLossConditioning,
    );

    expect(issues.any((it) => it.toLowerCase().contains("giảm mỡ")), isTrue);
  });

  test('muscle gain requires a higher target weight', () {
    final issues = ProfileGoalValidator.validate(
      profile: validProfile().copyWith(targetWeightKg: 72.0),
      fitnessGoal: FitnessGoal.muscleGain,
    );

    expect(issues.any((it) => it.toLowerCase().contains("tăng cơ")), isTrue);
  });

  test('general and endurance goals allow either weight direction', () {
    final lowerTarget = validProfile().copyWith(targetWeightKg: 70.0);
    final higherTarget = validProfile().copyWith(targetWeightKg: 85.0);

    expect(ProfileGoalValidator.validate(profile: lowerTarget, fitnessGoal: FitnessGoal.generalFitness).isEmpty, isTrue);
    expect(ProfileGoalValidator.validate(profile: higherTarget, fitnessGoal: FitnessGoal.endurance).isEmpty, isTrue);
  });

  test('activity levels expose fixed calculation multipliers', () {
    expect(ActivityLevel.sedentary.multiplier, closeTo(1.20, 0.0001));
    expect(ActivityLevel.light.multiplier, closeTo(1.375, 0.0001));
    expect(ActivityLevel.moderate.multiplier, closeTo(1.55, 0.0001));
    expect(ActivityLevel.high.multiplier, closeTo(1.725, 0.0001));
  });

  test('adaptation enums expose the approved decision vocabulary', () {
    expect(AdaptationMode.values.toSet(), {AdaptationMode.autoApply, AdaptationMode.requiresConfirmation});
    expect(
      AdaptationStatus.values.toSet(),
      {AdaptationStatus.proposed, AdaptationStatus.applied, AdaptationStatus.rejected, AdaptationStatus.undone},
    );
    expect(
      AdaptationKind.values.toSet(),
      {
        AdaptationKind.calorieTarget,
        AdaptationKind.macroTarget,
        AdaptationKind.recoveryDay,
        AdaptationKind.workoutVolume,
        AdaptationKind.programChange,
        AdaptationKind.deloadWeek,
      },
    );
  });
}
