package com.example.myapplication.core.catalog

import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AssetCatalogRepositoryTest {
    @Test
    fun constructingRepositoryDoesNotOpenMissingProgramsAsset() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext

        AssetCatalogRepository(context)
    }

    @Test
    fun repositoryLoadsAndValidatesBundledExercises() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val repository = AssetCatalogRepository(context)

        val exercises = repository.exercises

        assertEquals(64, exercises.size)
        assertEquals(64, exercises.map { it.id }.toSet().size)
        assertTrue(CatalogValidator.validateExercises(exercises).isEmpty())
    }
}
