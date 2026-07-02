package com.example.myapplication.core.nutrition

import com.example.myapplication.core.profile.ActivityLevel
import com.example.myapplication.core.profile.GoalPace
import com.example.myapplication.core.profile.MetabolicSex
import com.example.myapplication.core.profile.PersonalProfile
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate
import kotlin.math.abs

class NutritionTargetCalculatorTest {
    private val calculator = NutritionTargetCalculator()

    @Test
    fun `male profile calculates deterministic gradual loss target`() {
        val target = calculator.calculate(profile = maleProfile(), ageYears = 31).requireTarget()

        assertEquals(1724, target.basalCalories)
        assertEquals(2672, target.maintenanceCalories)
        assertEquals(2405, target.calories)
        val macroCalories = target.proteinGrams * 4 + target.carbsGrams * 4 + target.fatGrams * 9
        assertTrue(abs(target.calories - macroCalories) <= 4)
        assertEquals(1723.75, target.audit.rawBasalCalories, 0.001)
        assertEquals(2671.8125, target.audit.rawMaintenanceCalories, 0.001)
    }

    @Test
    fun `female profile uses the female Mifflin St Jeor constant`() {
        val profile = maleProfile().copy(
            metabolicSex = MetabolicSex.FEMALE,
            heightCm = 165.0,
            currentWeightKg = 65.0,
            targetWeightKg = 55.0,
            activityLevel = ActivityLevel.MODERATE,
        )

        val target = calculator.calculate(profile, ageYears = 30).requireTarget()

        assertEquals(1370, target.basalCalories)
        assertEquals(2124, target.maintenanceCalories)
    }

    @Test
    fun `weight gain and maintenance use the expected target direction`() {
        val gain = calculator.calculate(
            maleProfile().copy(targetWeightKg = 82.0),
            ageYears = 31,
        ).requireTarget()
        val maintenance = calculator.calculate(
            maleProfile().copy(targetWeightKg = 78.0),
            ageYears = 31,
        ).requireTarget()

        assertEquals(2939, gain.calories)
        assertEquals(2672, maintenance.calories)
    }

    @Test
    fun `standard pace uses a larger initial adjustment than gradual pace`() {
        val gradual = calculator.calculate(maleProfile(), ageYears = 31).requireTarget()
        val standard = calculator.calculate(
            maleProfile().copy(goalPace = GoalPace.STANDARD),
            ageYears = 31,
        ).requireTarget()

        assertEquals(2405, gradual.calories)
        assertEquals(2271, standard.calories)
    }

    @Test
    fun `automatic weekly adjustment is capped by five percent or 150 calories`() {
        assertEquals(120, calculator.capAutomaticCalorieDelta(currentCalories = 2400, requestedDelta = 400))
        assertEquals(-100, calculator.capAutomaticCalorieDelta(currentCalories = 2000, requestedDelta = -400))
        assertEquals(150, calculator.capAutomaticCalorieDelta(currentCalories = 4000, requestedDelta = 400))
        assertEquals(40, calculator.capAutomaticCalorieDelta(currentCalories = 2000, requestedDelta = 40))
    }

    @Test
    fun `invalid profile or age requires professional review`() {
        val invalidProfile = maleProfile().copy(personalizationConsent = false)

        assertTrue(calculator.calculate(invalidProfile, ageYears = 31) is CalculationResult.NeedsProfessionalReview)
        assertTrue(calculator.calculate(maleProfile(), ageYears = 17) is CalculationResult.NeedsProfessionalReview)
    }

    @Test
    fun `timeline faster than point nine kilograms per week requires review`() {
        val today = LocalDate.of(2026, 7, 2)
        val result = calculator.calculate(
            profile = maleProfile().copy(targetWeightKg = 68.0),
            ageYears = 31,
            timeline = TargetTimeline(
                todayEpochDay = today.toEpochDay(),
                targetDateEpochDay = today.plusWeeks(4).toEpochDay(),
            ),
        )

        assertTrue(result is CalculationResult.NeedsProfessionalReview)
    }

    @Test
    fun `reasonable timeline remains calculable`() {
        val today = LocalDate.of(2026, 7, 2)
        val result = calculator.calculate(
            profile = maleProfile(),
            ageYears = 31,
            timeline = TargetTimeline(
                todayEpochDay = today.toEpochDay(),
                targetDateEpochDay = today.plusWeeks(16).toEpochDay(),
            ),
        )

        assertTrue(result is CalculationResult.Target)
    }

    private fun CalculationResult.requireTarget(): NutritionTarget {
        assertTrue(this is CalculationResult.Target)
        return (this as CalculationResult.Target).value
    }

    private fun maleProfile() = PersonalProfile(
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
}
