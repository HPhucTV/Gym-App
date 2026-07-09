package com.example.myapplication.core.profile

import java.time.DateTimeException
import java.time.LocalDate
import java.time.Period

enum class MetabolicSex {
    FEMALE,
    MALE,
}

enum class ActivityLevel(val multiplier: Double) {
    SEDENTARY(1.20),
    LIGHT(1.375),
    MODERATE(1.55),
    HIGH(1.725),
}

enum class GoalPace {
    MILD,
    STANDARD,
    AGGRESSIVE,
}

data class PersonalProfile(
    val birthDateEpochDay: Long,
    val metabolicSex: MetabolicSex,
    val heightCm: Double,
    val currentWeightKg: Double,
    val targetWeightKg: Double,
    val activityLevel: ActivityLevel,
    val goalPace: GoalPace,
    val personalizationConsent: Boolean,
    val cloudAiConsent: Boolean,
) {
    fun validationIssues(today: LocalDate): List<String> = buildList {
        val birthDate = try {
            LocalDate.ofEpochDay(birthDateEpochDay)
        } catch (_: DateTimeException) {
            null
        }
        val age = birthDate?.let { Period.between(it, today).years }

        if (age == null || age !in MINIMUM_AGE..MAXIMUM_AGE) {
            add("Độ tuổi phải từ 18 đến 100.")
        }
        if (!heightCm.isFinite() || heightCm !in MINIMUM_HEIGHT_CM..MAXIMUM_HEIGHT_CM) {
            add("Chiều cao phải từ 100 đến 250 cm.")
        }
        if (!currentWeightKg.isFinite() || currentWeightKg !in MINIMUM_WEIGHT_KG..MAXIMUM_WEIGHT_KG) {
            add("Cân nặng hiện tại phải từ 30 đến 350 kg.")
        }
        if (!targetWeightKg.isFinite() || targetWeightKg !in MINIMUM_WEIGHT_KG..MAXIMUM_WEIGHT_KG) {
            add("Cân nặng mục tiêu phải từ 30 đến 350 kg.")
        }
        if (!personalizationConsent) {
            add("Bạn cần đồng ý sử dụng dữ liệu hồ sơ để bật cá nhân hóa.")
        }
    }

    private companion object {
        const val MINIMUM_AGE = 18
        const val MAXIMUM_AGE = 100
        const val MINIMUM_HEIGHT_CM = 100.0
        const val MAXIMUM_HEIGHT_CM = 250.0
        const val MINIMUM_WEIGHT_KG = 30.0
        const val MAXIMUM_WEIGHT_KG = 350.0
    }
}
