package com.example.myapplication.core.nutrition

data class MealTemplate(
    val id: Long,
    val nameVi: String,
    val nutrients: Nutrients,
    val updatedAtEpochMillis: Long,
)
