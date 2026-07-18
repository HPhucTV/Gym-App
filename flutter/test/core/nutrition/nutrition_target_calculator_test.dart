import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/core/nutrition/nutrition_target_calculator.dart';

void main() {
  final calculator = NutritionTargetCalculator();

  int day(int year, int month, int day) {
    final date = DateTime.utc(year, month, day);
    return date.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  PersonalProfile maleProfile() {
    return PersonalProfile(
      birthDateEpochDay: day(1995, 6, 15),
      metabolicSex: MetabolicSex.male,
      heightCm: 175.0,
      currentWeightKg: 78.0,
      targetWeightKg: 72.0,
      activityLevel: ActivityLevel.moderate,
      goalPace: GoalPace.mild,
      personalizationConsent: true,
      cloudAiConsent: false,
    );
  }

  NutritionTarget requireTarget(CalculationResult result) {
    return result.when(
      target: (value) => value,
      needsProfessionalReview: (reason) =>
          fail("Expected target result, but got needsProfessionalReview: $reason"),
    );
  }

  bool isNeedsProfessionalReview(CalculationResult result) {
    return result.when(
      target: (_) => false,
      needsProfessionalReview: (_) => true,
    );
  }

  bool isTarget(CalculationResult result) {
    return result.when(
      target: (_) => true,
      needsProfessionalReview: (_) => false,
    );
  }

  test('male profile calculates deterministic gradual loss target', () {
    final target = requireTarget(calculator.calculate(profile: maleProfile(), ageYears: 31));

    expect(target.basalCalories, 1724);
    expect(target.maintenanceCalories, 2672);
    expect(target.calories, 2405);
    // Weight-based macros: 78kg * 2.0g = 156g protein, 78kg * 0.8g = 62.4g (62g) fat
    expect(target.proteinGrams, 156);
    expect(target.fatGrams, 62);
    // Carbs remaining: (2404.63 - 156*4 - 62.4*9)/4 = (2404.63 - 624 - 561.6)/4 = 304.76 (305g carbs)
    expect(target.carbsGrams, 305);
    final macroCalories = target.proteinGrams * 4 + target.carbsGrams * 4 + target.fatGrams * 9;
    expect((target.calories - macroCalories).abs() <= 10, isTrue);
    expect(target.audit.rawBasalCalories, closeTo(1723.75, 0.001));
    expect(target.audit.rawMaintenanceCalories, closeTo(2671.8125, 0.001));
  });

  test('female profile uses the female Mifflin St Jeor constant', () {
    final profile = maleProfile().copyWith(
      metabolicSex: MetabolicSex.female,
      heightCm: 165.0,
      currentWeightKg: 65.0,
      targetWeightKg: 55.0,
      activityLevel: ActivityLevel.moderate,
    );

    final target = requireTarget(calculator.calculate(profile: profile, ageYears: 30));

    expect(target.basalCalories, 1370);
    expect(target.maintenanceCalories, 2124);
  });

  test('weight gain and maintenance use the expected target direction', () {
    final gain = requireTarget(
      calculator.calculate(
        profile: maleProfile().copyWith(targetWeightKg: 82.0),
        ageYears: 31,
      ),
    );
    final maintenance = requireTarget(
      calculator.calculate(
        profile: maleProfile().copyWith(targetWeightKg: 78.0),
        ageYears: 31,
      ),
    );

    // Weight gain uses +5% for MILD: 2672 * 1.05 = 2805 kcal
    expect(gain.calories, 2805);
    expect(maintenance.calories, 2672);
  });

  test('standard pace uses a larger initial adjustment than gradual pace', () {
    final gradual = requireTarget(calculator.calculate(profile: maleProfile(), ageYears: 31));
    final standard = requireTarget(
      calculator.calculate(
        profile: maleProfile().copyWith(goalPace: GoalPace.standard),
        ageYears: 31,
      ),
    );

    expect(gradual.calories, 2405);
    expect(standard.calories, 2271);
  });

  test('automatic weekly adjustment is capped by five percent or 150 calories', () {
    expect(calculator.capAutomaticCalorieDelta(2400, 400), 120);
    expect(calculator.capAutomaticCalorieDelta(2000, -400), -100);
    expect(calculator.capAutomaticCalorieDelta(4000, 400), 150);
    expect(calculator.capAutomaticCalorieDelta(2000, 40), 40);
  });

  test('invalid profile or age requires professional review', () {
    final invalidProfile = maleProfile().copyWith(personalizationConsent: false);

    expect(isNeedsProfessionalReview(calculator.calculate(profile: invalidProfile, ageYears: 31)), isTrue);
    expect(isNeedsProfessionalReview(calculator.calculate(profile: maleProfile(), ageYears: 17)), isTrue);
  });

  test('timeline faster than point nine kilograms per week requires review', () {
    final todayEpoch = day(2026, 7, 2);
    final targetDateEpoch = todayEpoch + 4 * 7; // plus 4 weeks
    final result = calculator.calculate(
      profile: maleProfile().copyWith(targetWeightKg: 68.0),
      ageYears: 31,
      timeline: TargetTimeline(
        todayEpochDay: todayEpoch,
        targetDateEpochDay: targetDateEpoch,
      ),
    );

    expect(isNeedsProfessionalReview(result), isTrue);
  });

  test('reasonable timeline remains calculable', () {
    final todayEpoch = day(2026, 7, 2);
    final targetDateEpoch = todayEpoch + 16 * 7; // plus 16 weeks
    final result = calculator.calculate(
      profile: maleProfile(),
      ageYears: 31,
      timeline: TargetTimeline(
        todayEpochDay: todayEpoch,
        targetDateEpochDay: targetDateEpoch,
      ),
    );

    expect(isTarget(result), isTrue);
  });
}
