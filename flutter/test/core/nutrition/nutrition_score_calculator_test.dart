import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/core/nutrition/nutrition_score_calculator.dart';

void main() {
  final sampleTarget = NutritionTarget(
    basalCalories: 1500,
    maintenanceCalories: 2000,
    calories: 2000,
    proteinGrams: 150,
    carbsGrams: 200,
    fatGrams: 60,
    audit: const NutritionTargetAudit(
      rawBasalCalories: 1500.0,
      rawMaintenanceCalories: 2000.0,
      rawTargetCalories: 2000.0,
      rawProteinGrams: 150.0,
      rawCarbsGrams: 200.0,
      rawFatGrams: 60.0,
    ),
  );

  test('calculateScore_perfectMatch_returns100', () {
    const consumed = Nutrients(
      calories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 60,
      fiberGrams: 30,
    );
    final result = NutritionScoreCalculator.calculateScore(
      consumed: consumed,
      target: sampleTarget,
      waterIntakeMl: 2000,
    );

    expect(result.score, 100);
    expect(result.label, 'Xuất sắc');
    expect(result.emoji, '🌟');
  });

  test('calculateScore_noTarget_returnsZero', () {
    const consumed = Nutrients(
      calories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 60,
    );
    final result = NutritionScoreCalculator.calculateScore(
      consumed: consumed,
      target: null,
      waterIntakeMl: 2000,
    );

    expect(result.score, 0);
    expect(result.label, 'Chưa thiết lập mục tiêu');
  });

  test('calculateScore_underEating_returnsProportionalScore', () {
    const consumed = Nutrients(
      calories: 1000,
      proteinGrams: 75,
      carbsGrams: 100,
      fatGrams: 30,
    );
    final result = NutritionScoreCalculator.calculateScore(
      consumed: consumed,
      target: sampleTarget,
      waterIntakeMl: 1000,
    );

    // Calorie: 15 points (deviation 0.5)
    // Protein: 13 points (ratio 0.5)
    // Carbs: 8 points (deviation 0.5)
    // Fat: 8 points (deviation 0.5)
    // Water: 8 points (ratio 0.5)
    // Total expected = 15 + 13 + 8 + 8 + 8 = 52
    expect(result.score >= 50 && result.score <= 55, isTrue);
    expect(result.label, 'Cần cải thiện');
  });
}
