package com.example.myapplication.core.catalog

import com.example.myapplication.core.model.*
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class ProgramCatalogValidatorTest {
    @Test
    fun `valid program has no validation issues`() {
        val exercises = CatalogParser.parseExercises(File("src/main/assets/catalog/exercises_vi.json").readText()).associateBy { it.id }
        val program = ProgramTemplate(
            id = "general_beginner_bodyweight_2x_1w",
            goal = FitnessGoal.GENERAL_FITNESS,
            level = ExperienceLevel.BEGINNER,
            equipmentProfile = EquipmentProfile.BODYWEIGHT_ONLY,
            sessionsPerWeek = 2,
            durationWeeks = 1,
            workouts = listOf(
                WorkoutTemplate(0, 1, "Toàn thân", "Nền tảng", 20, 2,
                    listOf(ExercisePrescription("bodyweight_squat", 2, 8, 12, null, 60))),
                WorkoutTemplate(1, 1, "Toàn thân 2", "Nền tảng", 20, 3,
                    listOf(ExercisePrescription("push_up", 2, 6, 10, null, 60))),
            ),
        )
        assertTrue(CatalogValidator.validatePrograms(listOf(program), exercises).isEmpty())
    }

    @Test
    fun `validator reports malformed program fields and references`() {
        val workout = WorkoutTemplate(2, 2, "Sai", "Sai", 9, 4,
            listOf(ExercisePrescription("missing", 0, 0, 101, 9, 14)))
        val program = ProgramTemplate("duplicate", FitnessGoal.GENERAL_FITNESS, ExperienceLevel.BEGINNER,
            EquipmentProfile.BODYWEIGHT_ONLY, 1, 1, listOf(workout))
        val issues = CatalogValidator.validatePrograms(listOf(program, program), emptyMap())
        listOf(
            "Duplicate program id", "Duplicate program match key", "contiguous", "week",
            "estimatedMinutes", "restDaysAfter", "Unknown exercise", "sets", "restSeconds",
            "prescription", "weekly schedule",
        ).forEach { expected -> assertTrue("Missing issue: $expected in $issues", issues.any { expected in it }) }
    }
}
