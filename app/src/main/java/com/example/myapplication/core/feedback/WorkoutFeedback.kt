package com.example.myapplication.core.feedback

enum class WorkoutDifficulty(val score: Int) {
    EASY(-1),
    RIGHT(0),
    HARD(1),
}

data class WorkoutFeedback(
    val sessionId: Long,
    val goalId: Long,
    val completedEpochDay: Long,
    val difficulty: WorkoutDifficulty,
    val recordedAtEpochMillis: Long,
)
