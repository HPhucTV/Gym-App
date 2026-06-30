package com.example.myapplication.core.catalog

import com.example.myapplication.core.model.FitnessGoal
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class BundledProgramCatalogJvmTest {
    @Test
    fun `bundled programs cover the approved matrix and validate cleanly`() {
        val exercises = CatalogParser.parseExercises(File("src/main/assets/catalog/exercises_vi.json").readText())
        val programs = CatalogParser.parsePrograms(File("src/main/assets/catalog/programs.json").readText())

        assertEquals(6, programs.size)
        assertEquals(116, programs.sumOf { it.workouts.size })
        assertEquals(FitnessGoal.entries.toSet(), programs.map { it.goal }.toSet())
        assertEquals(
            setOf(
                "general-beginner-bodyweight-3x-4w",
                "conditioning-beginner-bodyweight-4x-4w",
                "endurance-beginner-bodyweight-3x-4w",
                "muscle-beginner-dumbbells-3x-4w",
                "general-intermediate-gym-4x-8w",
                "muscle-intermediate-gym-4x-8w",
            ),
            programs.map { it.id }.toSet(),
        )
        assertTrue(CatalogValidator.validatePrograms(programs, exercises.associateBy { it.id }).isEmpty())
    }

    @Test
    fun `beginner progression and low impact substitutions follow review rules`() {
        val programs = CatalogParser.parsePrograms(File("src/main/assets/catalog/programs.json").readText())
        val general = programs.single { it.id == "general-beginner-bodyweight-3x-4w" }
        assertTrue(general.workouts.filter { it.week <= 2 }.flatMap { it.exercises }.all { it.sets == 2 })
        assertTrue(general.workouts.filter { it.week >= 3 }.flatMap { it.exercises }.all { it.sets == 3 })

        val conditioning = programs.single { it.id == "conditioning-beginner-bodyweight-4x-4w" }
        val earlyIds = conditioning.workouts.filter { it.week <= 2 }.flatMap { it.exercises }.map { it.exerciseId }
        assertTrue("low_impact_jumping_jack" in earlyIds)
        assertTrue("jumping_jack" !in earlyIds)
    }

    @Test
    fun `endurance timed intervals rise no more than ten percent week to week`() {
        val endurance = CatalogParser.parsePrograms(File("src/main/assets/catalog/programs.json").readText())
            .single { it.id == "endurance-beginner-bodyweight-3x-4w" }
        val grouped = endurance.workouts.groupBy { it.sequence % endurance.sessionsPerWeek }
        grouped.values.forEach { sameSession ->
            val durationsByExercise = sameSession.flatMap { workout ->
                workout.exercises.mapNotNull { prescription ->
                    prescription.durationSeconds?.let { prescription.exerciseId to (workout.week to it) }
                }
            }.groupBy({ it.first }, { it.second })
            durationsByExercise.values.forEach { values ->
                values.sortedBy { it.first }.zipWithNext().forEach { (previous, current) ->
                    assertTrue(current.second <= previous.second * 1.10 + 1)
                }
            }
        }
    }
}
