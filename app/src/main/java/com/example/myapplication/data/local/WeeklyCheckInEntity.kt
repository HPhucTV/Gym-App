package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "weekly_check_ins")
data class WeeklyCheckInEntity(
    @PrimaryKey val weekStartEpochDay: Long,
    val weightKg: Double,
    val energy: Int,
    val hunger: Int,
    val recovery: Int,
    val sleepQuality: Int,
    val note: String?,
    val createdAtEpochMillis: Long,
)
