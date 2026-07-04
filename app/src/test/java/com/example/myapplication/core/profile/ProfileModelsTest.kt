package com.example.myapplication.core.profile

import com.example.myapplication.core.adaptation.AdaptationKind
import com.example.myapplication.core.adaptation.AdaptationMode
import com.example.myapplication.core.adaptation.AdaptationStatus
import com.example.myapplication.core.model.FitnessGoal
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate

class ProfileModelsTest {
    @Test
    fun `valid profile accepts all personalization inputs`() {
        val profile = validProfile()

        assertEquals(emptyList<String>(), profile.validationIssues(today))
    }

    @Test
    fun `invalid anthropometrics are rejected`() {
        val profile = validProfile().copy(
            heightCm = 0.0,
            currentWeightKg = -1.0,
            targetWeightKg = Double.NaN,
        )

        val issues = profile.validationIssues(today)

        assertTrue(issues.any { "chiều cao" in it.lowercase() })
        assertTrue(issues.any { "cân nặng hiện tại" in it.lowercase() })
        assertTrue(issues.any { "cân nặng mục tiêu" in it.lowercase() })
    }

    @Test
    fun `profile requires adult age and personalization consent`() {
        val underage = validProfile().copy(
            birthDateEpochDay = today.minusYears(17).toEpochDay(),
            personalizationConsent = false,
        )

        val issues = underage.validationIssues(today)

        assertTrue(issues.any { "18" in it })
        assertTrue(issues.any { "đồng ý" in it.lowercase() })
    }

    @Test
    fun `age boundaries are inclusive`() {
        val exactly18 = validProfile().copy(birthDateEpochDay = today.minusYears(18).toEpochDay())
        val exactly100 = validProfile().copy(birthDateEpochDay = today.minusYears(100).toEpochDay())

        assertTrue(exactly18.validationIssues(today).none { "tuổi" in it.lowercase() })
        assertTrue(exactly100.validationIssues(today).none { "tuổi" in it.lowercase() })
    }

    @Test
    fun `fat loss requires a lower target weight`() {
        val issues = ProfileGoalValidator.validate(
            validProfile().copy(targetWeightKg = 82.0),
            FitnessGoal.FAT_LOSS_CONDITIONING,
        )

        assertTrue(issues.any { "giảm mỡ" in it.lowercase() })
    }

    @Test
    fun `muscle gain requires a higher target weight`() {
        val issues = ProfileGoalValidator.validate(
            validProfile().copy(targetWeightKg = 72.0),
            FitnessGoal.MUSCLE_GAIN,
        )

        assertTrue(issues.any { "tăng cơ" in it.lowercase() })
    }

    @Test
    fun `general and endurance goals allow either weight direction`() {
        val lowerTarget = validProfile().copy(targetWeightKg = 70.0)
        val higherTarget = validProfile().copy(targetWeightKg = 85.0)

        assertTrue(ProfileGoalValidator.validate(lowerTarget, FitnessGoal.GENERAL_FITNESS).isEmpty())
        assertTrue(ProfileGoalValidator.validate(higherTarget, FitnessGoal.ENDURANCE).isEmpty())
    }

    @Test
    fun `activity levels expose fixed calculation multipliers`() {
        assertEquals(1.20, ActivityLevel.SEDENTARY.multiplier, 0.0001)
        assertEquals(1.375, ActivityLevel.LIGHT.multiplier, 0.0001)
        assertEquals(1.55, ActivityLevel.MODERATE.multiplier, 0.0001)
        assertEquals(1.725, ActivityLevel.HIGH.multiplier, 0.0001)
    }

    @Test
    fun `adaptation enums expose the approved decision vocabulary`() {
        assertEquals(setOf(AdaptationMode.AUTO_APPLY, AdaptationMode.REQUIRES_CONFIRMATION), AdaptationMode.entries.toSet())
        assertEquals(
            setOf(AdaptationStatus.PROPOSED, AdaptationStatus.APPLIED, AdaptationStatus.REJECTED, AdaptationStatus.UNDONE),
            AdaptationStatus.entries.toSet(),
        )
        assertEquals(
            setOf(
                AdaptationKind.CALORIE_TARGET,
                AdaptationKind.MACRO_TARGET,
                AdaptationKind.RECOVERY_DAY,
                AdaptationKind.WORKOUT_VOLUME,
                AdaptationKind.PROGRAM_CHANGE,
                AdaptationKind.DELOAD_WEEK,
            ),
            AdaptationKind.entries.toSet(),
        )
    }

    private fun validProfile() = PersonalProfile(
        birthDateEpochDay = LocalDate.of(1995, 6, 15).toEpochDay(),
        metabolicSex = MetabolicSex.MALE,
        heightCm = 175.0,
        currentWeightKg = 78.0,
        targetWeightKg = 72.0,
        activityLevel = ActivityLevel.MODERATE,
        goalPace = GoalPace.GRADUAL,
        personalizationConsent = true,
        cloudAiConsent = false,
    )

    private companion object {
        val today: LocalDate = LocalDate.of(2026, 7, 2)
    }
}
