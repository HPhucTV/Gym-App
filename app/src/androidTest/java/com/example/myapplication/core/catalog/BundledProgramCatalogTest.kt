package com.example.myapplication.core.catalog

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.example.myapplication.core.model.FitnessGoal
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class BundledProgramCatalogTest {
    @Test
    fun bundledProgramsParseValidateAndLoadThroughRepository() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        fun asset(path: String) = context.assets.open(path).bufferedReader().use { it.readText() }
        val exercises = CatalogParser.parseExercises(asset("catalog/exercises_vi.json"))
        val programs = CatalogParser.parsePrograms(asset("catalog/programs.json"))

        assertEquals(6, programs.size)
        assertEquals(116, programs.sumOf { it.workouts.size })
        assertEquals(FitnessGoal.entries.toSet(), programs.map { it.goal }.toSet())
        assertTrue(CatalogValidator.validatePrograms(programs, exercises.associateBy { it.id }).isEmpty())
        assertEquals(6, AssetCatalogRepository(context).programs.size)
    }
}
