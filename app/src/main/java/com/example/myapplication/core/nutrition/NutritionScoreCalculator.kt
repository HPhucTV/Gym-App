package com.example.myapplication.core.nutrition

import kotlin.math.abs
import kotlin.math.min
import kotlin.math.roundToInt

object NutritionScoreCalculator {
    /**
     * Calculates a daily nutrition score from 0 to 100 based on calories, macros, and water intake.
     */
    fun calculateScore(
        consumed: Nutrients,
        target: NutritionTarget?,
        waterIntakeMl: Int,
        waterTargetMl: Int = 2000
    ): CalculationResult {
        if (target == null || target.calories <= 0) {
            return CalculationResult(0, "Chưa thiết lập mục tiêu", "🔴")
        }

        // Calories: 30 points max
        val calorieScore = if (target.calories > 0) {
            val deviationRatio = abs(consumed.calories - target.calories).toDouble() / target.calories
            (30.0 * (1.0 - deviationRatio).coerceIn(0.0, 1.0)).roundToInt()
        } else 0

        // Protein: 25 points max
        val proteinScore = if (target.proteinGrams > 0) {
            val ratio = consumed.proteinGrams.toDouble() / target.proteinGrams
            (25.0 * min(1.0, ratio)).roundToInt()
        } else 0

        // Carbs: 15 points max
        val carbsScore = if (target.carbsGrams > 0) {
            val deviationRatio = abs(consumed.carbsGrams - target.carbsGrams).toDouble() / target.carbsGrams
            (15.0 * (1.0 - deviationRatio).coerceIn(0.0, 1.0)).roundToInt()
        } else 0

        // Fat: 15 points max
        val fatScore = if (target.fatGrams > 0) {
            val deviationRatio = abs(consumed.fatGrams - target.fatGrams).toDouble() / target.fatGrams
            (15.0 * (1.0 - deviationRatio).coerceIn(0.0, 1.0)).roundToInt()
        } else 0

        // Water: 15 points max
        val waterScore = if (waterTargetMl > 0) {
            val ratio = waterIntakeMl.toDouble() / waterTargetMl
            (15.0 * min(1.0, ratio)).roundToInt()
        } else 0

        val totalScore = calorieScore + proteinScore + carbsScore + fatScore + waterScore

        val labelAndEmoji = when {
            totalScore >= 90 -> Pair("Xuất sắc", "🌟")
            totalScore >= 70 -> Pair("Tốt", "✅")
            totalScore >= 50 -> Pair("Cần cải thiện", "⚠️")
            else -> Pair("Chưa đạt", "🔴")
        }

        return CalculationResult(totalScore, labelAndEmoji.first, labelAndEmoji.second)
    }

    data class CalculationResult(
        val score: Int,
        val label: String,
        val emoji: String
    )
}
