package com.example.myapplication.core.catalog

import org.junit.Assert.assertEquals
import org.junit.Test
import java.io.File

class CatalogSourceIdTest {
    @Test
    fun `project authored variants use project source IDs`() {
        val exercises = CatalogParser.parseExercises(
            File("src/main/assets/catalog/exercises_vi.json").readText(),
        ).associateBy { it.id }

        val projectAuthoredIds = listOf(
            "goblet_squat",
            "reverse_lunge",
            "split_squat",
            "step_up",
            "standing_calf_raise",
        )

        projectAuthoredIds.forEach { id ->
            assertEquals("project:$id", exercises.getValue(id).sourceId)
        }
    }
}
