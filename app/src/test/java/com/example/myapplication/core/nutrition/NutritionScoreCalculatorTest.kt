package com.example.myapplication.core.nutrition

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class NutritionScoreCalculatorTest {

    private val sampleTarget = NutritionTarget(
        basalCalories = 1500,
        maintenanceCalories = 2000,
        calories = 2000,
        proteinGrams = 150,
        carbsGrams = 200,
        fatGrams = 60,
        audit = NutritionTargetAudit(1500.0, 2000.0, 2000.0, 150.0, 200.0, 60.0)
    )

    @Test
    fun calculateScore_perfectMatch_returns100() {
        val consumed = Nutrients(
            calories = 2000,
            proteinGrams = 150,
            carbsGrams = 200,
            fatGrams = 60,
            fiberGrams = 30
        )
        val result = NutritionScoreCalculator.calculateScore(
            consumed = consumed,
            target = sampleTarget,
            waterIntakeMl = 2000
        )

        assertEquals(100, result.score)
        assertEquals("Xuất sắc", result.label)
        assertEquals("🌟", result.emoji)
    }

    @Test
    fun calculateScore_noTarget_returnsZero() {
        val consumed = Nutrients(calories = 2000, proteinGrams = 150, carbsGrams = 200, fatGrams = 60)
        val result = NutritionScoreCalculator.calculateScore(
            consumed = consumed,
            target = null,
            waterIntakeMl = 2000
        )

        assertEquals(0, result.score)
        assertEquals("Chưa thiết lập mục tiêu", result.label)
    }

    @Test
    fun calculateScore_underEating_returnsProportionalScore() {
        val consumed = Nutrients(
            calories = 1000,
            proteinGrams = 75,
            carbsGrams = 100,
            fatGrams = 30
        )
        val result = NutritionScoreCalculator.calculateScore(
            consumed = consumed,
            target = sampleTarget,
            waterIntakeMl = 1000
        )

        // Calorie: 15 points (deviation 0.5)
        // Protein: 13 points (ratio 0.5)
        // Carbs: 8 points (deviation 0.5)
        // Fat: 8 points (deviation 0.5)
        // Water: 8 points (ratio 0.5)
        // Total expected = 15 + 13 + 8 + 8 + 8 = 52
        assertTrue(result.score in 50..55)
        assertEquals("Cần cải thiện", result.label)
    }
}
