package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "weight_measurements")
data class WeightMeasurementEntity(
    @PrimaryKey val epochDay: Long,
    val weightKg: Double,
    val recordedAtEpochMillis: Long,
)
