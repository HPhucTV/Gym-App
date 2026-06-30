package com.example.myapplication.core.catalog

import android.content.Context
import com.example.myapplication.core.model.ExerciseDefinition
import com.example.myapplication.core.model.ProgramTemplate

class AssetCatalogRepository(context: Context) {
    private val appContext = context.applicationContext

    val exercises: List<ExerciseDefinition> by lazy {
        CatalogParser.parseExercises(readAsset(EXERCISES_ASSET)).also { parsed ->
            val issues = CatalogValidator.validateExercises(parsed)
            check(issues.isEmpty()) {
                "Invalid bundled exercise catalog:\n${issues.joinToString(separator = "\n")}"
            }
        }
    }

    val programs: List<ProgramTemplate> by lazy {
        CatalogParser.parsePrograms(readAsset(PROGRAMS_ASSET))
    }

    private fun readAsset(path: String): String =
        appContext.assets.open(path).bufferedReader().use { it.readText() }

    private companion object {
        const val EXERCISES_ASSET = "catalog/exercises_vi.json"
        const val PROGRAMS_ASSET = "catalog/programs.json"
    }
}
