package com.example.myapplication.data

import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.feedback.WorkoutFeedback
import kotlinx.coroutines.flow.Flow

interface WorkoutFeedbackRepository {
    fun observeForGoal(goalId: Long): Flow<List<WorkoutFeedback>>

    suspend fun save(
        sessionId: Long,
        goalId: Long,
        completedEpochDay: Long,
        difficulty: WorkoutDifficulty,
    )
}
