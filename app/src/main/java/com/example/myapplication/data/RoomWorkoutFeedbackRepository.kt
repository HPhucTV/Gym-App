package com.example.myapplication.data

import androidx.room.withTransaction
import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.feedback.WorkoutFeedback
import com.example.myapplication.data.local.GymDatabase
import com.example.myapplication.data.local.WorkoutFeedbackEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class RoomWorkoutFeedbackRepository(
    private val database: GymDatabase,
    private val nowEpochMillis: () -> Long = { System.currentTimeMillis() },
) : WorkoutFeedbackRepository {
    private val feedbackDao = database.workoutFeedbackDao()
    private val workoutDao = database.workoutDao()

    override fun observeForGoal(goalId: Long): Flow<List<WorkoutFeedback>> =
        feedbackDao.observeForGoal(goalId).map { rows -> rows.map(WorkoutFeedbackEntity::toDomain) }

    override suspend fun save(
        sessionId: Long,
        goalId: Long,
        completedEpochDay: Long,
        difficulty: WorkoutDifficulty,
    ) {
        database.withTransaction {
            val session = checkNotNull(workoutDao.getSession(sessionId)) {
                "Workout session $sessionId does not exist."
            }
            check(session.completedEpochDay != null) {
                "Workout feedback requires a completed session."
            }
            require(session.goalId == goalId) {
                "Workout session $sessionId does not belong to goal $goalId."
            }
            require(session.completedEpochDay == completedEpochDay) {
                "Completion day does not match the stored workout session."
            }
            feedbackDao.upsert(
                WorkoutFeedbackEntity(
                    sessionId = sessionId,
                    goalId = goalId,
                    completedEpochDay = completedEpochDay,
                    difficulty = difficulty,
                    recordedAtEpochMillis = nowEpochMillis(),
                ),
            )
        }
    }
}

private fun WorkoutFeedbackEntity.toDomain() = WorkoutFeedback(
    sessionId = sessionId,
    goalId = goalId,
    completedEpochDay = completedEpochDay,
    difficulty = difficulty,
    recordedAtEpochMillis = recordedAtEpochMillis,
)
