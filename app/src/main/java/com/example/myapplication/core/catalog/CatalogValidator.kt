package com.example.myapplication.core.catalog

import com.example.myapplication.core.model.ExerciseDefinition

object CatalogValidator {
    private val validId = Regex("[a-z0-9_]+")

    fun validateExercises(exercises: List<ExerciseDefinition>): List<String> {
        val issues = mutableListOf<String>()

        exercises.groupingBy { it.id }
            .eachCount()
            .filterValues { it > 1 }
            .keys
            .sorted()
            .forEach { issues += "Duplicate exercise id: $it" }

        exercises.forEach { exercise ->
            if (!validId.matches(exercise.id)) {
                issues += "Exercise id '${exercise.id}' must match [a-z0-9_]+"
            }
            if (exercise.sourceId.isBlank()) {
                issues += "Exercise '${exercise.id}' has blank sourceId"
            }
            if (exercise.nameVi.isBlank()) {
                issues += "Exercise '${exercise.id}' has blank nameVi"
            }
            if (exercise.instructionsVi.size !in 2..5) {
                issues += "Exercise '${exercise.id}' instructionsVi must contain 2..5 items"
            }
            if (exercise.instructionsVi.any { it.isBlank() }) {
                issues += "Exercise '${exercise.id}' has a blank instruction"
            }
            if (exercise.equipment.isEmpty()) {
                issues += "Exercise '${exercise.id}' must declare equipment"
            }
        }

        return issues
    }
}
