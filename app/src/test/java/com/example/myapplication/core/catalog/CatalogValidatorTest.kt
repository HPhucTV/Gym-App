package com.example.myapplication.core.catalog

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class CatalogValidatorTest {
    @Test
    fun `validator reports every required catalog issue`() {
        val valid = CatalogParser.parseExercises(validExerciseJson).single()
        val invalid = valid.copy(
            id = "Bad-ID",
            sourceId = " ",
            nameVi = "",
            equipment = emptyList(),
            instructionsVi = listOf("", "Hai", "Ba", "Bốn", "Năm", "Sáu"),
        )

        val issues = CatalogValidator.validateExercises(listOf(invalid, invalid))

        assertTrue(issues.any { "Duplicate exercise id" in it })
        assertTrue(issues.any { "[a-z0-9_]+" in it })
        assertTrue(issues.any { "sourceId" in it })
        assertTrue(issues.any { "nameVi" in it })
        assertTrue(issues.any { "instructionsVi must contain 2..5" in it })
        assertTrue(issues.any { "blank instruction" in it })
        assertTrue(issues.any { "equipment" in it })
    }

    @Test
    fun `bundled exercise asset contains 64 valid unique records`() {
        val raw = File("src/main/assets/catalog/exercises_vi.json").readText()
        val exercises = CatalogParser.parseExercises(raw)

        assertEquals(64, exercises.size)
        assertEquals(64, exercises.map { it.id }.toSet().size)
        assertTrue(CatalogValidator.validateExercises(exercises).isEmpty())
        assertTrue(exercises.all { it.instructionsVi.size in 2..5 })
    }

    private companion object {
        val validExerciseJson =
            """
            [{
              "id":"push_up",
              "sourceId":"Pushups",
              "nameVi":"Chống đẩy",
              "level":"BEGINNER",
              "equipment":["BODYWEIGHT"],
              "movementPattern":"HORIZONTAL_PUSH",
              "primaryMuscle":"CHEST",
              "secondaryMuscles":["TRICEPS"],
              "instructionsVi":["Giữ thân thẳng.","Hạ ngực rồi đẩy lên."]
            }]
            """.trimIndent()
    }
}
