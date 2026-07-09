package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "food_catalog")
data class FoodCatalogEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val gramsPerServing: Double = 100.0,
    val caloriesPerServing: Double = 0.0,
    val fatPerServing: Double = 0.0,
    val carbsPerServing: Double = 0.0,
    val proteinPerServing: Double = 0.0,
    val potassiumMg: Double = 0.0,
    val sodiumMg: Double = 0.0,
    val cholesterolMg: Double = 0.0,
    val fiberPerServing: Double = 0.0,
    val importBatchId: String = "",
    val isFavorite: Boolean = false,
)
