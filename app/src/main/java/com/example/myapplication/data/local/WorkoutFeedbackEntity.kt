package com.example.myapplication.data.local

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import com.example.myapplication.core.feedback.WorkoutDifficulty

@Entity(
    tableName = "workout_feedback",
    foreignKeys = [
        ForeignKey(
            entity = WorkoutSessionEntity::class,
            parentColumns = ["id"],
            childColumns = ["sessionId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index(value = ["goalId", "completedEpochDay"])],
)
data class WorkoutFeedbackEntity(
    @PrimaryKey val sessionId: Long,
    val goalId: Long,
    val completedEpochDay: Long,
    val difficulty: WorkoutDifficulty,
    val recordedAtEpochMillis: Long,
)
