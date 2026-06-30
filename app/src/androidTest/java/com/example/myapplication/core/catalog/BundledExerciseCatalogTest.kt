package com.example.myapplication.core.catalog

import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BundledExerciseCatalogTest {
    @Test
    fun bundledExerciseCatalogIsCompleteAndValid() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val raw = context.assets.open("catalog/exercises_vi.json")
            .bufferedReader()
            .use { it.readText() }

        val exercises = CatalogParser.parseExercises(raw)
        val issues = CatalogValidator.validateExercises(exercises)

        assertEquals(64, exercises.size)
        assertTrue(exercises.size in 60..100)
        assertTrue("Validation issues: ${issues.joinToString()}", issues.isEmpty())
        assertTrue(exercises.all { it.instructionsVi.size in 2..5 })
        assertEquals(exercises.size, exercises.map { it.id }.toSet().size)
    }
}
