package com.example.myapplication.feature.progress

import com.example.myapplication.core.model.*
import com.example.myapplication.data.*
import com.example.myapplication.feature.onboarding.MainDispatcherRule
import java.time.LocalDate
import java.time.YearMonth
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.test.*
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.feedback.WorkoutFeedback
import com.example.myapplication.core.progress.GoalForecast
import com.example.myapplication.data.local.WeightMeasurementEntity
import com.example.myapplication.feature.progress.WeightFilter
import com.example.myapplication.core.adaptation.AdaptationKind
import com.example.myapplication.core.adaptation.AdaptationStatus
import com.example.myapplication.data.local.PersonalProfileEntity
import com.example.myapplication.data.local.DailyNutritionEntity
import com.example.myapplication.data.local.MealTemplateEntity
import com.example.myapplication.data.local.WeeklyCheckInEntity
import com.example.myapplication.data.local.AdaptationDecisionEntity
import com.example.myapplication.data.local.UserFoodOverrideEntity
import com.example.myapplication.data.local.PersonalizationDao

@OptIn(ExperimentalCoroutinesApi::class)
class ProgressViewModelTest {
    private val dispatcher = StandardTestDispatcher()
    @get:Rule val mainRule = MainDispatcherRule(dispatcher)

    @Test fun `active summary and two qualifying weeks are calculated`() = runTest(dispatcher) {
        val current = day("2026-06-14")
        val dates = listOf("2026-06-01", "2026-06-02", "2026-06-03", "2026-06-08", "2026-06-09", "2026-06-10", "2026-06-11")
        val repo = FakeProgressRepository(goal(), dates.map { CompletedWorkout(1, day(it)) })
        val vm = ProgressViewModel(repo) { current }; runCurrent()
        val state = vm.uiState.value as ProgressUiState.Content
        assertEquals(58, state.percentage); assertEquals(7, state.completedActive)
        assertEquals(12, state.totalActive); assertEquals(2, state.weeklyStreak)
        assertEquals(dates.map(::day).toSet(), state.markedEpochDays)
    }

    @Test fun `empty history is meaningful zero state`() = runTest(dispatcher) {
        val vm = ProgressViewModel(FakeProgressRepository(goal(), emptyList())) { day("2026-06-14") }; runCurrent()
        val state = vm.uiState.value as ProgressUiState.Content
        assertEquals(0, state.percentage); assertEquals(0, state.completedActive)
        assertEquals(0, state.weeklyStreak); assertTrue(state.markedEpochDays.isEmpty())
    }

    @Test fun `archived rows appear in calendar but not active summary or streak`() = runTest(dispatcher) {
        val rows = listOf(CompletedWorkout(1, day("2026-06-08")), CompletedWorkout(2, day("2026-06-09")), CompletedWorkout(2, day("2026-06-10")))
        val vm = ProgressViewModel(FakeProgressRepository(goal(sessions = 1), rows)) { day("2026-06-14") }; runCurrent()
        val state = vm.uiState.value as ProgressUiState.Content
        assertEquals(1, state.completedActive); assertEquals(1, state.weeklyStreak)
        assertEquals(3, state.markedEpochDays.size)
    }

    @Test fun `month navigation filters marks and repository emission preserves selection`() = runTest(dispatcher) {
        val repo = FakeProgressRepository(goal(), listOf(CompletedWorkout(1, day("2026-05-20")), CompletedWorkout(1, day("2026-06-01"))))
        val vm = ProgressViewModel(repo) { day("2026-06-14") }; runCurrent()
        vm.previousMonth(); runCurrent()
        var state = vm.uiState.value as ProgressUiState.Content
        assertEquals(YearMonth.of(2026, 5), state.selectedMonth); assertEquals(setOf(day("2026-05-20")), state.markedEpochDays)
        repo.history.value = repo.history.value + CompletedWorkout(1, day("2026-05-21")); runCurrent()
        state = vm.uiState.value as ProgressUiState.Content
        assertEquals(YearMonth.of(2026, 5), state.selectedMonth); assertEquals(2, state.markedEpochDays.size)
        vm.nextMonth(); runCurrent(); assertEquals(YearMonth.of(2026, 6), (vm.uiState.value as ProgressUiState.Content).selectedMonth)
    }

    @Test fun `refresh today recomputes streak without repository emission`() = runTest(dispatcher) {
        var current = day("2026-06-14")
        val rows = listOf("2026-06-08", "2026-06-09", "2026-06-10").map { CompletedWorkout(1, day(it)) }
        val vm = ProgressViewModel(FakeProgressRepository(goal(), rows)) { current }; runCurrent()
        assertEquals(1, (vm.uiState.value as ProgressUiState.Content).weeklyStreak)
        current = day("2026-06-22"); vm.refreshToday(); runCurrent()
        assertEquals(0, (vm.uiState.value as ProgressUiState.Content).weeklyStreak)
    }

    @Test fun `duplicate day counts sessions but draws one calendar mark`() = runTest(dispatcher) {
        val same = day("2026-06-08")
        val vm = ProgressViewModel(FakeProgressRepository(goal(sessions = 1), listOf(CompletedWorkout(1, same), CompletedWorkout(1, same)))) { day("2026-06-14") }; runCurrent()
        val state = vm.uiState.value as ProgressUiState.Content
        assertEquals(2, state.completedActive); assertEquals(1, state.markedEpochDays.size); assertEquals(1, state.weeklyStreak)
    }

    @Test fun `no active goal retains calendar history`() = runTest(dispatcher) {
        val vm = ProgressViewModel(FakeProgressRepository(null, listOf(CompletedWorkout(9, day("2026-06-08"))))) { day("2026-06-14") }; runCurrent()
        val state = vm.uiState.value as ProgressUiState.NoActiveGoal
        assertEquals(setOf(day("2026-06-08")), state.markedEpochDays)
    }

    @Test fun `active progress exposes deterministic weekly insights`() = runTest(dispatcher) {
        val entries = buildList {
            var id = 1L
            listOf("2026-06-08", "2026-06-10", "2026-06-12").forEach {
                add(historyEntry(id++, it, null))
            }
            listOf("2026-06-15", "2026-06-17", "2026-06-19", "2026-06-21").forEach {
                add(historyEntry(id++, it, it))
            }
        }
        val repo = FakeProgressRepository(goal(), emptyList(), entries)
        val feedback = object : WorkoutFeedbackRepository {
            override fun observeForGoal(goalId: Long): Flow<List<WorkoutFeedback>> = flowOf(
                entries.takeLast(4).map {
                    WorkoutFeedback(it.sessionId, 1, it.completedEpochDay!!, WorkoutDifficulty.HARD, 0)
                },
            )
            override suspend fun save(
                sessionId: Long,
                goalId: Long,
                completedEpochDay: Long,
                difficulty: WorkoutDifficulty,
            ) = Unit
        }
        val vm = ProgressViewModel(repo, feedbackRepository = feedback) { day("2026-06-22") }
        runCurrent()

        val state = vm.uiState.value as ProgressUiState.Content
        assertTrue(state.weeklyInsights.isNotEmpty())
        assertTrue(state.weeklyInsights.size <= 3)
    }

    @Test fun `forecast exposes status and evidence inputs`() = runTest(dispatcher) {
        val first = day("2026-05-25")
        val entries = List(12) { index ->
            WorkoutHistoryEntry(
                sessionId = index.toLong(),
                goalId = 1,
                sequenceIndex = index,
                dueEpochDay = first + index * 5L,
                completedEpochDay = if (index < 6) first + index * 5L else null,
                estimatedMinutes = 30,
            )
        }
        val completed = entries.mapNotNull { row ->
            row.completedEpochDay?.let { CompletedWorkout(1, it) }
        }
        val vm = ProgressViewModel(FakeProgressRepository(goal(), completed, entries)) {
            day("2026-06-22")
        }
        runCurrent()

        val state = vm.uiState.value as ProgressUiState.Content
        assertTrue(state.goalForecast is GoalForecast.OnTrack)
        assertEquals(6, state.forecastCompletedSessions)
        assertEquals(4, state.forecastElapsedWeeks)
    }

    @Test fun `weight history is filtered and sorted by epoch day`() = runTest(dispatcher) {
        val todayVal = day("2026-06-14")
        val dao = FakePersonalizationDao()
        // measurements: 5 days ago, 15 days ago, 45 days ago
        val m1 = WeightMeasurementEntity(todayVal - 5, 80.0, (todayVal - 5) * 86400000L)
        val m2 = WeightMeasurementEntity(todayVal - 15, 81.0, (todayVal - 15) * 86400000L)
        val m3 = WeightMeasurementEntity(todayVal - 45, 82.0, (todayVal - 45) * 86400000L)
        dao.upsertWeight(m1)
        dao.upsertWeight(m2)
        dao.upsertWeight(m3)

        val vm = ProgressViewModel(
            repository = FakeProgressRepository(goal(), emptyList()),
            personalizationDao = dao,
            currentEpochDay = { todayVal }
        )
        runCurrent()

        // By default, filter should be LAST_30_DAYS
        var state = vm.uiState.value as ProgressUiState.Content
        assertEquals(WeightFilter.LAST_30_DAYS, state.weightFilter)
        // Should contain m1 and m2, but not m3 (which is 45 days ago)
        assertEquals(2, state.weightHistory.size)
        assertEquals(81.0, state.weightHistory[0].weightKg, 0.01) // chronological sort: 15 days ago, then 5 days ago
        assertEquals(80.0, state.weightHistory[1].weightKg, 0.01)

        // Select LAST_7_DAYS
        vm.changeWeightFilter(WeightFilter.LAST_7_DAYS)
        runCurrent()
        state = vm.uiState.value as ProgressUiState.Content
        assertEquals(WeightFilter.LAST_7_DAYS, state.weightFilter)
        assertEquals(1, state.weightHistory.size)
        assertEquals(80.0, state.weightHistory[0].weightKg, 0.01)

        // Select LAST_90_DAYS
        vm.changeWeightFilter(WeightFilter.LAST_90_DAYS)
        runCurrent()
        state = vm.uiState.value as ProgressUiState.Content
        assertEquals(WeightFilter.LAST_90_DAYS, state.weightFilter)
        assertEquals(3, state.weightHistory.size)
    }

    private fun goal(sessions: Int = 3) = ActiveGoal(1, GoalConfig(FitnessGoal.GENERAL_FITNESS, ExperienceLevel.BEGINNER,
        EquipmentProfile.BODYWEIGHT_ONLY, sessions, 4, RestDayMode.FULL_REST), 12)
    private fun day(value: String) = LocalDate.parse(value).toEpochDay()
    private fun historyEntry(id: Long, due: String, completed: String?) = WorkoutHistoryEntry(
        id, 1, id.toInt(), day(due), completed?.let(::day), 30,
    )
}

private class FakeProgressRepository(
    goal: ActiveGoal?,
    completed: List<CompletedWorkout>,
    entries: List<WorkoutHistoryEntry> = completed.mapIndexed { index, row ->
        WorkoutHistoryEntry(index.toLong(), row.goalId, index, row.completedEpochDay, row.completedEpochDay, 30)
    },
) : WorkoutRepository {
    val active = MutableStateFlow(goal); val history = MutableStateFlow(completed)
    val workoutHistory = MutableStateFlow(entries)
    override fun observeActiveGoal(): Flow<ActiveGoal?> = active
    override fun observeCompletedWorkouts(): Flow<List<CompletedWorkout>> = history
    override fun observeCurrentWorkout(): Flow<WorkoutSession?> = flowOf(null)
    override fun observeWorkoutHistory(): Flow<List<WorkoutHistoryEntry>> = workoutHistory
    override suspend fun createGoal(config: GoalConfig, program: ProgramTemplate, startEpochDay: Long) = Unit
    override suspend fun setExerciseChecked(sessionId: Long, orderIndex: Int, checked: Boolean) = Unit
    override suspend fun completeWorkout(sessionId: Long, completedEpochDay: Long) = CompleteWorkoutResult.Completed
    override suspend fun archiveActiveGoal() = Unit
}

private class FakePersonalizationDao : PersonalizationDao {
    val weights = MutableStateFlow<List<WeightMeasurementEntity>>(emptyList())
    override suspend fun upsertProfile(profile: PersonalProfileEntity) {}
    override fun observeProfile(): Flow<PersonalProfileEntity?> = flowOf(null)
    override suspend fun profileNow(): PersonalProfileEntity? = null
    override suspend fun upsertWeight(measurement: WeightMeasurementEntity) {
        weights.value = weights.value + measurement
    }
    override suspend fun latestWeightNow(): WeightMeasurementEntity? = weights.value.lastOrNull()
    override fun observeWeightHistory(): Flow<List<WeightMeasurementEntity>> = weights
    override suspend fun weightHistoryNow(): List<WeightMeasurementEntity> = weights.value
    override suspend fun upsertDailyNutrition(day: DailyNutritionEntity) {}
    override fun observeNutritionDay(epochDay: Long): Flow<DailyNutritionEntity?> = flowOf(null)
    override fun observeNutritionRange(startEpochDay: Long, endEpochDay: Long): Flow<List<DailyNutritionEntity>> = flowOf(emptyList())
    override suspend fun nutritionRangeNow(startEpochDay: Long, endEpochDay: Long): List<DailyNutritionEntity> = emptyList()
    override fun observeAllNutrition(): Flow<List<DailyNutritionEntity>> = flowOf(emptyList())
    override fun observeMealTemplates(): Flow<List<MealTemplateEntity>> = flowOf(emptyList())
    override suspend fun mealTemplateNow(id: Long): MealTemplateEntity? = null
    override suspend fun mealTemplateByNameNow(nameVi: String): MealTemplateEntity? = null
    override suspend fun insertMealTemplate(template: MealTemplateEntity): Long = 0
    override suspend fun updateMealTemplate(template: MealTemplateEntity): Int = 0
    override suspend fun deleteMealTemplate(id: Long): Int = 0
    override suspend fun upsertWeeklyCheckIn(checkIn: WeeklyCheckInEntity) {}
    override fun observeLatestCheckIn(): Flow<WeeklyCheckInEntity?> = flowOf(null)
    override fun observeAllCheckIns(): Flow<List<WeeklyCheckInEntity>> = flowOf(emptyList())
    override suspend fun latestCheckInNow(): WeeklyCheckInEntity? = null
    override suspend fun insertDecision(decision: AdaptationDecisionEntity): Long = 0
    override suspend fun updateDecisionStatus(id: Long, status: AdaptationStatus, resolvedAt: Long) {}
    override suspend fun updateDecisionPayloads(id: Long, afterJson: String, undoJson: String) {}
    override suspend fun decisionByIdNow(id: Long): AdaptationDecisionEntity? = null
    override suspend fun latestDecisionByKindAndStatus(kind: AdaptationKind, status: AdaptationStatus): AdaptationDecisionEntity? = null
    override fun observeDecisionHistory(): Flow<List<AdaptationDecisionEntity>> = flowOf(emptyList())
    override suspend fun decisionHistoryNow(): List<AdaptationDecisionEntity> = emptyList()
    override suspend fun upsertFoodOverride(override: UserFoodOverrideEntity) {}
    override suspend fun foodOverrideNow(dishName: String): UserFoodOverrideEntity? = null
}
