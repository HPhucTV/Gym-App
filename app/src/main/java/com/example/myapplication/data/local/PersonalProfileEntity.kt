package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.example.myapplication.core.profile.ActivityLevel
import com.example.myapplication.core.profile.GoalPace
import com.example.myapplication.core.profile.MetabolicSex

@Entity(tableName = "personal_profiles")
data class PersonalProfileEntity(
    @PrimaryKey val id: Int = SINGLETON_ID,
    val birthDateEpochDay: Long,
    val metabolicSex: MetabolicSex,
    val heightCm: Double,
    val currentWeightKg: Double,
    val targetWeightKg: Double,
    val activityLevel: ActivityLevel,
    val goalPace: GoalPace,
    val personalizationConsent: Boolean,
    val cloudAiConsent: Boolean,
    val updatedAtEpochMillis: Long,
) {
    companion object {
        const val SINGLETON_ID = 1
    }
}
