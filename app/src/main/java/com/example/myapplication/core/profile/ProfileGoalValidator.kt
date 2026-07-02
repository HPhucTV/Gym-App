package com.example.myapplication.core.profile

import com.example.myapplication.core.model.FitnessGoal

object ProfileGoalValidator {
    fun validate(profile: PersonalProfile, fitnessGoal: FitnessGoal): List<String> {
        if (!profile.currentWeightKg.isFinite() || !profile.targetWeightKg.isFinite()) {
            return emptyList()
        }

        return when (fitnessGoal) {
            FitnessGoal.MUSCLE_GAIN -> if (profile.targetWeightKg <= profile.currentWeightKg) {
                listOf("Mục tiêu tăng cơ cần cân nặng mục tiêu cao hơn cân nặng hiện tại.")
            } else {
                emptyList()
            }

            FitnessGoal.FAT_LOSS_CONDITIONING -> if (profile.targetWeightKg >= profile.currentWeightKg) {
                listOf("Mục tiêu giảm mỡ cần cân nặng mục tiêu thấp hơn cân nặng hiện tại.")
            } else {
                emptyList()
            }

            FitnessGoal.ENDURANCE,
            FitnessGoal.GENERAL_FITNESS,
            -> emptyList()
        }
    }
}
