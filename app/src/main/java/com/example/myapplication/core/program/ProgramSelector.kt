package com.example.myapplication.core.program

import com.example.myapplication.core.model.GoalConfig
import com.example.myapplication.core.model.ProgramTemplate

sealed interface ProgramSelectionResult {
    data class Found(val program: ProgramTemplate) : ProgramSelectionResult

    data object Unsupported : ProgramSelectionResult
}

object ProgramSelector {
    fun select(
        config: GoalConfig,
        programs: List<ProgramTemplate>,
    ): ProgramSelectionResult {
        for (g in config.goals) {
            val matches = programs.filter {
                it.goal == g &&
                    it.level == config.level &&
                    it.equipmentProfile == config.equipmentProfile
            }
            if (matches.isNotEmpty()) {
                require(matches.size <= 1) { "Duplicate programs for goal=$g, level=${config.level}, equip=${config.equipmentProfile}" }
                return ProgramSelectionResult.Found(matches.first())
            }
        }
        
        val fallbackMatches = programs.filter {
            it.goal == config.goal &&
                it.level == config.level &&
                it.equipmentProfile == config.equipmentProfile
        }
        return fallbackMatches.singleOrNull()?.let(ProgramSelectionResult::Found)
            ?: ProgramSelectionResult.Unsupported
    }
}
