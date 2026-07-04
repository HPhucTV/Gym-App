package com.example.myapplication.data

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.model.EquipmentProfile
import com.example.myapplication.core.model.ExperienceLevel
import com.example.myapplication.core.model.FitnessGoal
import com.example.myapplication.core.model.RestDayMode
import com.example.myapplication.data.local.GoalEntity
import com.example.myapplication.data.local.GymDatabase
import com.example.myapplication.data.local.WorkoutSessionEntity
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class RoomWorkoutFeedbackRepositoryTest {
    private lateinit var database: GymDatabase
    private lateinit var repository: WorkoutFeedbackRepository

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, GymDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        repository = RoomWorkoutFeedbackRepository(database, nowEpochMillis = { 9000L })
    }

    @After
    fun tearDown() {
        database.close()
    }

    @Test
    fun saveCompletedSessionPersistsAndReplacesRating() = runTest {
        val goalId = insertGoal()
        val sessionId = insertSession(goalId, completedEpochDay = 20640L)

        repository.save(sessionId, goalId, 20640L, WorkoutDifficulty.RIGHT)
        repository.save(sessionId, goalId, 20640L, WorkoutDifficulty.HARD)

        val feedback = repository.observeForGoal(goalId).first().single()
        assertEquals(WorkoutDifficulty.HARD, feedback.difficulty)
        assertEquals(9000L, feedback.recordedAtEpochMillis)
    }

    @Test
    fun saveRejectsIncompleteSession() = runTest {
        val goalId = insertGoal()
        val sessionId = insertSession(goalId, completedEpochDay = null)

        val error = runCatching {
            repository.save(sessionId, goalId, 20640L, WorkoutDifficulty.RIGHT)
        }.exceptionOrNull()

        assertTrue(error is IllegalStateException)
    }

    private suspend fun insertGoal(): Long = database.workoutDao().insertGoal(
        GoalEntity(
            programId = "general",
            goal = FitnessGoal.GENERAL_FITNESS,
            level = ExperienceLevel.BEGINNER,
            equipmentProfile = EquipmentProfile.BODYWEIGHT_ONLY,
            sessionsPerWeek = 3,
            durationWeeks = 4,
            restDayMode = RestDayMode.FULL_REST,
            createdEpochDay = 20600L,
        ),
    )

    private suspend fun insertSession(goalId: Long, completedEpochDay: Long?): Long =
        database.workoutDao().insertSessions(
            listOf(
                WorkoutSessionEntity(
                    goalId = goalId,
                    sequenceIndex = 0,
                    titleVi = "Buổi 1",
                    focusVi = "Toàn thân",
                    estimatedMinutes = 45,
                    dueEpochDay = 20640L,
                    completedEpochDay = completedEpochDay,
                ),
            ),
        ).single()
}
