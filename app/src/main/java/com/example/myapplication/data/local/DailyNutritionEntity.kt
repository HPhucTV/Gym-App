package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "daily_nutrition")
data class DailyNutritionEntity(
    @PrimaryKey val epochDay: Long,
    val consumedCalories: Int = 0,
    val consumedProteinGrams: Int = 0,
    val consumedCarbsGrams: Int = 0,
    val consumedFatGrams: Int = 0,
    val targetBasalCalories: Int? = null,
    val targetMaintenanceCalories: Int? = null,
    val targetCalories: Int? = null,
    val targetProteinGrams: Int? = null,
    val targetCarbsGrams: Int? = null,
    val targetFatGrams: Int? = null,
    val lastEntrySource: String? = null,
    val updatedAtEpochMillis: Long = 0,
)
