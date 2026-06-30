package com.example.myapplication.core.catalog

import com.example.myapplication.core.model.Equipment
import com.example.myapplication.core.model.EquipmentProfile
import com.example.myapplication.core.model.ExperienceLevel
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class ProgramEquipmentCompatibilityTest {
    @Test
    fun `program exercises match equipment tier and participant level`() {
        val exercises = CatalogParser.parseExercises(File("src/main/assets/catalog/exercises_vi.json").readText()).associateBy { it.id }
        val programs = CatalogParser.parsePrograms(File("src/main/assets/catalog/programs.json").readText())
        val allowedEquipment = mapOf(
            EquipmentProfile.BODYWEIGHT_ONLY to setOf(Equipment.BODYWEIGHT),
            EquipmentProfile.DUMBBELLS to setOf(Equipment.BODYWEIGHT, Equipment.DUMBBELL),
            EquipmentProfile.RESISTANCE_BANDS to setOf(Equipment.BODYWEIGHT, Equipment.BAND),
            EquipmentProfile.FULL_GYM to Equipment.entries.toSet(),
        )

        programs.forEach { program ->
            program.workouts.flatMap { it.exercises }.forEach { prescription ->
                val exercise = requireNotNull(exercises[prescription.exerciseId])
                assertTrue(
                    "${program.id} cannot provide ${exercise.id} equipment ${exercise.equipment}",
                    exercise.equipment.all { it in allowedEquipment.getValue(program.equipmentProfile) },
                )
                if (program.level == ExperienceLevel.BEGINNER) {
                    assertTrue("${program.id} uses intermediate exercise ${exercise.id}", exercise.level == ExperienceLevel.BEGINNER)
                }
            }
        }
    }
}
