package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "logged_foods")
data class LoggedFoodEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val epochDay: Long,
    val name: String,
    val mealTime: String, // BREAKFAST, LUNCH, DINNER, SNACK
    val grams: Double,
    val calories: Int,
    val proteinGrams: Int,
    val carbsGrams: Int,
    val fatGrams: Int,
    val fiberGrams: Int = 0,
    val foodCatalogId: Long? = null,
    val timestamp: Long = System.currentTimeMillis()
)
