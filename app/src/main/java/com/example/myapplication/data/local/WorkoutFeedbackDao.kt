package com.example.myapplication.data.local

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Dao
interface WorkoutFeedbackDao {
    @Query(
        """
        SELECT * FROM workout_feedback
        WHERE goalId = :goalId
        ORDER BY completedEpochDay DESC, recordedAtEpochMillis DESC
        """,
    )
    fun observeForGoal(goalId: Long): Flow<List<WorkoutFeedbackEntity>>

    @Query("SELECT * FROM workout_feedback WHERE sessionId = :sessionId LIMIT 1")
    suspend fun feedbackForSessionNow(sessionId: Long): WorkoutFeedbackEntity?

    @Upsert
    suspend fun upsert(feedback: WorkoutFeedbackEntity)
}
