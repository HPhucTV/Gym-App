package com.example.myapplication.core.nutrition

import com.example.myapplication.core.profile.GoalPace
import com.example.myapplication.core.profile.MetabolicSex
import com.example.myapplication.core.profile.PersonalProfile
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.roundToInt

class NutritionTargetCalculator {
    fun calculate(
        profile: PersonalProfile,
        ageYears: Int,
        timeline: TargetTimeline? = null,
    ): CalculationResult {
        validate(profile, ageYears)?.let { reason ->
            return CalculationResult.NeedsProfessionalReview(reason)
        }
        validateTimeline(profile, timeline)?.let { reason ->
            return CalculationResult.NeedsProfessionalReview(reason)
        }

        val rawBasalCalories =
            10 * profile.currentWeightKg +
                6.25 * profile.heightCm -
                5 * ageYears +
                if (profile.metabolicSex == MetabolicSex.MALE) MALE_CONSTANT else FEMALE_CONSTANT
        val rawMaintenanceCalories = rawBasalCalories * profile.activityLevel.multiplier
        val rawTargetCalories = when {
            profile.targetWeightKg < profile.currentWeightKg -> {
                val rate = when (profile.goalPace) {
                    GoalPace.MILD -> 0.10
                    GoalPace.STANDARD -> 0.15
                    GoalPace.AGGRESSIVE -> 0.20
                }
                rawMaintenanceCalories * (1.0 - rate)
            }
            profile.targetWeightKg > profile.currentWeightKg -> {
                val rate = when (profile.goalPace) {
                    GoalPace.MILD -> 0.05
                    GoalPace.STANDARD -> 0.10
                    GoalPace.AGGRESSIVE -> 0.15
                }
                rawMaintenanceCalories * (1.0 + rate)
            }
            else -> rawMaintenanceCalories
        }

        val rawProteinGrams = profile.currentWeightKg * PROTEIN_GRAMS_PER_KG
        val rawFatGrams = profile.currentWeightKg * FAT_GRAMS_PER_KG
        val rawCarbsGrams =
            (rawTargetCalories -
                rawProteinGrams * CALORIES_PER_PROTEIN_GRAM -
                rawFatGrams * CALORIES_PER_FAT_GRAM) / CALORIES_PER_CARB_GRAM

        if (
            rawBasalCalories <= 0 ||
            rawMaintenanceCalories <= 0 ||
            rawTargetCalories <= 0 ||
            rawCarbsGrams < 0
        ) {
            return CalculationResult.NeedsProfessionalReview(
                "Không thể tạo mục tiêu dinh dưỡng an toàn từ dữ liệu hiện tại.",
            )
        }

        return CalculationResult.Target(
            NutritionTarget(
                basalCalories = rawBasalCalories.roundToInt(),
                maintenanceCalories = rawMaintenanceCalories.roundToInt(),
                calories = rawTargetCalories.roundToInt(),
                proteinGrams = rawProteinGrams.roundToInt(),
                carbsGrams = rawCarbsGrams.roundToInt(),
                fatGrams = rawFatGrams.roundToInt(),
                audit = NutritionTargetAudit(
                    rawBasalCalories = rawBasalCalories,
                    rawMaintenanceCalories = rawMaintenanceCalories,
                    rawTargetCalories = rawTargetCalories,
                    rawProteinGrams = rawProteinGrams,
                    rawCarbsGrams = rawCarbsGrams,
                    rawFatGrams = rawFatGrams,
                ),
            ),
        )
    }

    fun capAutomaticCalorieDelta(currentCalories: Int, requestedDelta: Int): Int {
        if (currentCalories <= 0) return 0

        val fivePercentCap = (currentCalories * AUTOMATIC_CHANGE_RATE).roundToInt()
        val cap = min(fivePercentCap, MAXIMUM_AUTOMATIC_CALORIES)
        return requestedDelta.coerceIn(-cap, cap)
    }

    private fun validate(profile: PersonalProfile, ageYears: Int): String? = when {
        ageYears !in MINIMUM_AGE..MAXIMUM_AGE -> "Độ tuổi cần nằm trong khoảng 18 đến 100."
        !profile.heightCm.isFinite() || profile.heightCm !in MINIMUM_HEIGHT_CM..MAXIMUM_HEIGHT_CM ->
            "Chiều cao nằm ngoài phạm vi hỗ trợ."
        !profile.currentWeightKg.isFinite() || profile.currentWeightKg !in MINIMUM_WEIGHT_KG..MAXIMUM_WEIGHT_KG ->
            "Cân nặng hiện tại nằm ngoài phạm vi hỗ trợ."
        !profile.targetWeightKg.isFinite() || profile.targetWeightKg !in MINIMUM_WEIGHT_KG..MAXIMUM_WEIGHT_KG ->
            "Cân nặng mục tiêu nằm ngoài phạm vi hỗ trợ."
        !profile.personalizationConsent -> "Cần đồng ý sử dụng dữ liệu hồ sơ trước khi tính mục tiêu."
        else -> null
    }

    private fun validateTimeline(profile: PersonalProfile, timeline: TargetTimeline?): String? {
        if (timeline == null) return null

        val durationDays = timeline.targetDateEpochDay - timeline.todayEpochDay
        if (durationDays <= 0) return "Ngày mục tiêu cần nằm sau ngày hiện tại."

        val durationWeeks = durationDays / DAYS_PER_WEEK
        val kilogramsPerWeek = abs(profile.targetWeightKg - profile.currentWeightKg) / durationWeeks
        return if (kilogramsPerWeek > MAXIMUM_KILOGRAMS_PER_WEEK) {
            "Tốc độ thay đổi cân nặng vượt 0,9 kg mỗi tuần; hãy chọn thời hạn dài hơn hoặc trao đổi với chuyên gia."
        } else {
            null
        }
    }

    private companion object {
        const val MALE_CONSTANT = 5.0
        const val FEMALE_CONSTANT = -161.0
        const val PROTEIN_GRAMS_PER_KG = 2.0
        const val FAT_GRAMS_PER_KG = 0.8
        const val CALORIES_PER_PROTEIN_GRAM = 4.0
        const val CALORIES_PER_CARB_GRAM = 4.0
        const val CALORIES_PER_FAT_GRAM = 9.0
        const val AUTOMATIC_CHANGE_RATE = 0.05
        const val MAXIMUM_AUTOMATIC_CALORIES = 150
        const val MAXIMUM_KILOGRAMS_PER_WEEK = 0.9
        const val DAYS_PER_WEEK = 7.0
        const val MINIMUM_AGE = 18
        const val MAXIMUM_AGE = 100
        const val MINIMUM_HEIGHT_CM = 100.0
        const val MAXIMUM_HEIGHT_CM = 250.0
        const val MINIMUM_WEIGHT_KG = 30.0
        const val MAXIMUM_WEIGHT_KG = 350.0
    }
}
