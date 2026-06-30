package com.example.myapplication.core.catalog

import kotlinx.serialization.SerializationException
import org.junit.Assert.assertEquals
import org.junit.Test

class CatalogParserTest {
    @Test
    fun `valid minimal exercise JSON decodes`() {
        val exercises = CatalogParser.parseExercises(validExerciseJson)

        assertEquals(1, exercises.size)
        assertEquals("push_up", exercises.single().id)
        assertEquals("Chống đẩy", exercises.single().nameVi)
    }

    @Test(expected = SerializationException::class)
    fun `unknown enum value throws SerializationException`() {
        CatalogParser.parseExercises(
            validExerciseJson.replace("BEGINNER", "ADVANCED"),
        )
    }

    @Test(expected = SerializationException::class)
    fun `missing required nameVi throws SerializationException`() {
        CatalogParser.parseExercises(
            validExerciseJson.replace("\"nameVi\": \"Chống đẩy\",", ""),
        )
    }

    private companion object {
        val validExerciseJson =
            """
            [
              {
                "id": "push_up",
                "sourceId": "Pushups",
                "nameVi": "Chống đẩy",
                "level": "BEGINNER",
                "equipment": ["BODYWEIGHT"],
                "movementPattern": "HORIZONTAL_PUSH",
                "primaryMuscle": "CHEST",
                "secondaryMuscles": ["TRICEPS", "SHOULDERS"],
                "instructionsVi": [
                  "Đặt hai tay dưới vai và giữ thân người thẳng.",
                  "Hạ ngực có kiểm soát rồi đẩy người lên."
                ]
              }
            ]
            """.trimIndent()
    }
}
