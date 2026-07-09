package com.example.myapplication.core.model

data class ActiveGoal(
    val id: Long,
    val config: GoalConfig,
    val totalWorkouts: Int,
)

data class WorkoutSession(
    val id: Long,
    val goalId: Long,
    val sequenceIndex: Int,
    val titleVi: String,
    val focusVi: String,
    val estimatedMinutes: Int,
    val dueEpochDay: Long,
    val exercises: List<WorkoutExercise>,
    val selectedTimeBudgetMinutes: Int? = null,
    val omittedExerciseCount: Int = 0,
)

data class WorkoutExercise(
    val orderIndex: Int,
    val exerciseId: String,
    val prescription: ExercisePrescription,
    val checked: Boolean,
    val originalExerciseId: String? = null,
    val isLightWorkout: Boolean = false,
)

data class CompletedWorkout(
    val goalId: Long,
    val completedEpochDay: Long,
)

data class WorkoutHistoryEntry(
    val sessionId: Long,
    val goalId: Long,
    val sequenceIndex: Int,
    val dueEpochDay: Long,
    val completedEpochDay: Long?,
    val estimatedMinutes: Int,
    val selectedTimeBudgetMinutes: Int? = null,
)
