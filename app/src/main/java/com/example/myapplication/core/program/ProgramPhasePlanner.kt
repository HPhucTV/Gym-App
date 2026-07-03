package com.example.myapplication.core.program

enum class ProgramPhase {
    FOUNDATION,
    BUILD,
    CONSOLIDATE,
    DELOAD,
}

object ProgramPhasePlanner {
    fun phaseFor(week: Int, durationWeeks: Int): ProgramPhase {
        require(durationWeeks > 0) { "Program duration must be positive." }
        require(week in 1..durationWeeks) { "Week must be within the program duration." }
        if (durationWeeks >= 4 && week == durationWeeks) return ProgramPhase.DELOAD
        val progress = week.toDouble() / durationWeeks
        return when {
            progress <= 0.25 -> ProgramPhase.FOUNDATION
            progress <= 0.70 -> ProgramPhase.BUILD
            else -> ProgramPhase.CONSOLIDATE
        }
    }
}
