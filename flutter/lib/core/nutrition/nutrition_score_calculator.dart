import 'dart:math';
import '../model/nutrition_models.dart';

class NutritionScoreResult {
  final int score;
  final String label;
  final String emoji;

  NutritionScoreResult({
    required this.score,
    required this.label,
    required this.emoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionScoreResult &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          label == other.label &&
          emoji == other.emoji;

  @override
  int get hashCode => score.hashCode ^ label.hashCode ^ emoji.hashCode;
}

class NutritionScoreCalculator {
  static NutritionScoreResult calculateScore({
    required Nutrients consumed,
    NutritionTarget? target,
    required int waterIntakeMl,
    int waterTargetMl = 2000,
  }) {
    if (target == null || target.calories <= 0) {
      return NutritionScoreResult(
        score: 0,
        label: "Chưa thiết lập mục tiêu",
        emoji: "🔴",
      );
    }

    // Calories: tối đa 30 điểm
    final calorieScore = target.calories > 0
        ? (30.0 *
                (1.0 -
                        (consumed.calories - target.calories).abs() /
                            target.calories)
                    .clamp(0.0, 1.0))
            .round()
        : 0;

    // Protein: tối đa 25 điểm
    final proteinScore = target.proteinGrams > 0
        ? (25.0 * min(1.0, consumed.proteinGrams / target.proteinGrams)).round()
        : 0;

    // Carbs: tối đa 15 điểm
    final carbsScore = target.carbsGrams > 0
        ? (15.0 *
                (1.0 -
                        (consumed.carbsGrams - target.carbsGrams).abs() /
                            target.carbsGrams)
                    .clamp(0.0, 1.0))
            .round()
        : 0;

    // Fat: tối đa 15 điểm
    final fatScore = target.fatGrams > 0
        ? (15.0 *
                (1.0 -
                        (consumed.fatGrams - target.fatGrams).abs() /
                            target.fatGrams)
                    .clamp(0.0, 1.0))
            .round()
        : 0;

    // Water: tối đa 15 điểm
    final waterScore = waterTargetMl > 0
        ? (15.0 * min(1.0, waterIntakeMl / waterTargetMl)).round()
        : 0;

    final totalScore = calorieScore + proteinScore + carbsScore + fatScore + waterScore;

    final String label;
    final String emoji;
    if (totalScore >= 90) {
      label = "Xuất sắc";
      emoji = "🌟";
    } else if (totalScore >= 70) {
      label = "Tốt";
      emoji = "✅";
    } else if (totalScore >= 50) {
      label = "Cần cải thiện";
      emoji = "⚠️";
    } else {
      label = "Chưa đạt";
      emoji = "🔴";
    }

    return NutritionScoreResult(
      score: totalScore,
      label: label,
      emoji: emoji,
    );
  }
}
