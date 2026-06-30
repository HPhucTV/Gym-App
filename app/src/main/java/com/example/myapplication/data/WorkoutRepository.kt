package com.example.myapplication.data

import com.example.myapplication.core.model.ActiveGoal
import com.example.myapplication.core.model.CompletedWorkout
import com.example.myapplication.core.model.GoalConfig
import com.example.myapplication.core.model.ProgramTemplate
import com.example.myapplication.core.model.WorkoutSession
import kotlinx.coroutines.flow.Flow

interface WorkoutRepository {
    fun observeActiveGoal(): Flow<ActiveGoal?>
    fun observeCurrentWorkout(): Flow<WorkoutSession?>
    fun observeCompletedWorkouts(): Flow<List<CompletedWorkout>>
    suspend fun createGoal(config: GoalConfig, program: ProgramTemplate, startEpochDay: Long)
    suspend fun setExerciseChecked(sessionId: Long, orderIndex: Int, checked: Boolean)
    suspend fun completeWorkout(sessionId: Long, completedEpochDay: Long): CompleteWorkoutResult
    suspend fun archiveActiveGoal()
}

sealed interface CompleteWorkoutResult {
    data object Completed : CompleteWorkoutResult
    data object BlockedByUncheckedExercises : CompleteWorkoutResult
    data object AlreadyCompleted : CompleteWorkoutResult
}
