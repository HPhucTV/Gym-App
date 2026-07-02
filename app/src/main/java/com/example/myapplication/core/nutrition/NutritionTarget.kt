package com.example.myapplication.core.nutrition

data class NutritionTarget(
    val basalCalories: Int,
    val maintenanceCalories: Int,
    val calories: Int,
    val proteinGrams: Int,
    val carbsGrams: Int,
    val fatGrams: Int,
    val audit: NutritionTargetAudit,
)

data class NutritionTargetAudit(
    val rawBasalCalories: Double,
    val rawMaintenanceCalories: Double,
    val rawTargetCalories: Double,
    val rawProteinGrams: Double,
    val rawCarbsGrams: Double,
    val rawFatGrams: Double,
)

data class TargetTimeline(
    val todayEpochDay: Long,
    val targetDateEpochDay: Long,
)

sealed interface CalculationResult {
    data class Target(val value: NutritionTarget) : CalculationResult
    data class NeedsProfessionalReview(val reason: String) : CalculationResult
}
