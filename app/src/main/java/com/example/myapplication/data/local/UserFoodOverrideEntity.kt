package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_food_overrides")
data class UserFoodOverrideEntity(
    @PrimaryKey val dishName: String,
    val totalCalories: Int,
    val proteinGrams: Int,
    val carbsGrams: Int,
    val fatGrams: Int
)
