package com.example.myapplication.core.catalog

import com.example.myapplication.core.model.MovementPattern
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class ProgramContentQualityTest {
    private val exercises by lazy {
        CatalogParser.parseExercises(File("src/main/assets/catalog/exercises_vi.json").readText())
            .associateBy { it.id }
    }
    private val programs by lazy {
        CatalogParser.parsePrograms(File("src/main/assets/catalog/programs.json").readText())
    }

    @Test
    fun `Vietnamese workout text is readable and contains exact sentinels`() {
        val textValues = programs.flatMap { program ->
            program.workouts.flatMap { listOf(it.titleVi, it.focusVi) }
        }
        val mojibakeMarkers = listOf("Ă", "Ä", "Æ", "áº", "á»")

        assertEquals(232, textValues.size)
        textValues.forEach { value ->
            assertTrue("Blank workout text", value.isNotBlank())
            assertFalse("Mojibake in '$value'", mojibakeMarkers.any(value::contains))
            assertFalse("C1 control character in '$value'", value.any { it.code in 0x80..0x9F })
        }
        val allText = textValues.toSet()
        setOf("Toàn thân A", "Điều hòa toàn thân", "Đi bộ bền ổn định", "Tăng cơ A", "Thân dưới B")
            .forEach { expected -> assertTrue("Missing exact Vietnamese text: $expected", expected in allText) }
    }

    @Test
    fun `compound exercises precede accessory and core work in every workout`() {
        val accessoryIds = setOf(
            "standing_calf_raise", "leg_curl", "leg_extension", "dumbbell_lateral_raise",
            "triceps_pushdown", "overhead_triceps_extension", "prone_y_raise",
            "reverse_snow_angel", "face_pull", "reverse_fly", "back_extension",
            "dumbbell_biceps_curl", "hammer_curl",
        )

        programs.forEach { program ->
            program.workouts.forEach { workout ->
                var lateWorkStarted = false
                workout.exercises.forEach { prescription ->
                    val exercise = exercises.getValue(prescription.exerciseId)
                    val isLateWork = exercise.id in accessoryIds || exercise.movementPattern == MovementPattern.CORE
                    if (isLateWork) lateWorkStarted = true
                    val isCompound = !isLateWork
                    assertFalse(
                        "${program.id} workout ${workout.sequence}: compound ${exercise.id} appears after accessory/core",
                        lateWorkStarted && isCompound,
                    )
                }
            }
        }
    }

    @Test
    fun `adjacent training days do not repeat primary muscles`() {
        programs.forEach { program ->
            program.workouts.zipWithNext().forEach { (current, next) ->
                if (current.restDaysAfter == 0) {
                    val currentMuscles = current.exercises.map { exercises.getValue(it.exerciseId).primaryMuscle }.toSet()
                    val nextMuscles = next.exercises.map { exercises.getValue(it.exerciseId).primaryMuscle }.toSet()
                    assertTrue(
                        "${program.id} ${current.sequence}->${next.sequence} overlap ${currentMuscles intersect nextMuscles}",
                        (currentMuscles intersect nextMuscles).isEmpty(),
                    )
                }
            }
        }
    }
}
