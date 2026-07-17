package com.example.myapplication.data

import com.example.myapplication.core.adaptation.AdaptationEngine
import com.example.myapplication.core.adaptation.CheckInData
import com.example.myapplication.core.adaptation.WorkoutDifficultySample
import com.example.myapplication.core.adaptation.WeeklySnapshot
import com.example.myapplication.core.feedback.WorkoutFeedback
import com.example.myapplication.core.model.ActiveGoal
import com.example.myapplication.core.model.CompletedWorkout
import com.example.myapplication.core.model.WorkoutSession
import com.example.myapplication.core.nutrition.NutritionDay
import com.example.myapplication.core.nutrition.NutritionTarget
import com.example.myapplication.core.profile.PersonalProfile
import com.example.myapplication.core.program.ProgramPhase
import com.example.myapplication.core.program.ProgramPhasePlanner
import com.example.myapplication.data.local.PersonalizationDao
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.Period
import java.time.temporal.TemporalAdjusters
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope

fun interface WeeklySnapshotProvider {
    suspend fun snapshotFor(currentEpochDay: Long): WeeklySnapshot?
}

class WeeklyAdaptationCoordinator(
    private val snapshotProvider: WeeklySnapshotProvider,
    private val adaptationRepository: AdaptationRepository,
    private val engine: AdaptationEngine = AdaptationEngine(),
) {
    suspend fun evaluateAfterCheckIn(currentEpochDay: Long): List<Long> {
        val snapshot = snapshotProvider.snapshotFor(currentEpochDay) ?: return emptyList()
        return engine.evaluate(snapshot).map { decision ->
            adaptationRepository.recordDecision(decision)
        }
    }
}

data class WeeklySnapshotInputs(
    val currentEpochDay: Long,
    val goal: ActiveGoal,
    val currentSession: WorkoutSession?,
    val completedWorkouts: List<CompletedWorkout>,
    val feedback: List<WorkoutFeedback>,
    val nutritionDays: List<NutritionDay>,
    val recentWeights: List<Double>,
    val checkInsNewestFirst: List<CheckInData>,
    val currentTarget: NutritionTarget,
    val profile: PersonalProfile,
    val daysSinceLastCalorieDecision: Int,
    val daysSinceLastWorkoutDecision: Int,
    val missedSessions: Int = 0,
)

object WeeklySnapshotAssembler {
    fun build(inputs: WeeklySnapshotInputs): WeeklySnapshot {
        val currentDate = LocalDate.ofEpochDay(inputs.currentEpochDay)
        val weekStart = currentDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).toEpochDay()
        val weekEnd = Math.addExact(weekStart, 6L)
        val completedThisWeek = inputs.completedWorkouts.count { workout ->
            workout.goalId == inputs.goal.id && workout.completedEpochDay in weekStart..weekEnd
        }
        val trackedDays = inputs.nutritionDays.filter { it.consumed.calories > 0 }
        val averageConsumed = trackedDays.map { it.consumed.calories }
            .average()
            .takeUnless(Double::isNaN)
            ?.toInt()
            ?: 0
        val adherencePercent = if (trackedDays.isEmpty()) {
            0.0
        } else {
            trackedDays.count { it.consumed.calories >= inputs.currentTarget.calories * 0.7 }
                .toDouble() / trackedDays.size
        }
        val durationWeeks = inputs.goal.config.durationWeeks.coerceAtLeast(1)
        val currentWeek = inputs.currentSession
            ?.let { it.sequenceIndex / inputs.goal.config.sessionsPerWeek.coerceAtLeast(1) + 1 }
            ?.coerceIn(1, durationWeeks)
            ?: durationWeeks
        val phase = ProgramPhasePlanner.phaseFor(currentWeek, durationWeeks)

        return WeeklySnapshot(
            currentCalories = inputs.currentTarget.calories,
            currentTarget = inputs.currentTarget,
            averageConsumedCalories = averageConsumed,
            adherencePercent = adherencePercent,
            recentWeights = inputs.recentWeights,
            targetWeightKg = inputs.profile.targetWeightKg,
            latestCheckIn = inputs.checkInsNewestFirst.firstOrNull(),
            consecutiveLowRecoveryCheckIns = inputs.checkInsNewestFirst.takeWhile { it.recovery <= 2 }.size,
            daysSinceLastCalorieDecision = inputs.daysSinceLastCalorieDecision,
            daysSinceLastWorkoutDecision = inputs.daysSinceLastWorkoutDecision,
            trackedDays = trackedDays.size,
            completedSessionsThisWeek = completedThisWeek,
            scheduledSessionsThisWeek = inputs.goal.config.sessionsPerWeek,
            missedSessions = inputs.missedSessions,
            profileAgeYears = Period.between(
                LocalDate.ofEpochDay(inputs.profile.birthDateEpochDay),
                currentDate,
            ).years,
            profile = inputs.profile,
            lastDifficulties = inputs.feedback.sortedBy(WorkoutFeedback::completedEpochDay)
                .takeLast(4)
                .map { WorkoutDifficultySample(it.completedEpochDay, it.difficulty) },
            currentProgramPhase = phase,
        )
    }
}

class RoomWeeklySnapshotProvider(
    private val personalizationDao: PersonalizationDao,
    private val workoutRepository: WorkoutRepository,
    private val feedbackRepository: WorkoutFeedbackRepository,
    private val nutritionRepository: NutritionRepository,
    private val nowEpochMillis: () -> Long = { System.currentTimeMillis() },
) : WeeklySnapshotProvider {
    override suspend fun snapshotFor(currentEpochDay: Long): WeeklySnapshot? = coroutineScope {
        val goal = workoutRepository.observeActiveGoal().first() ?: return@coroutineScope null

        val profileDeferred = async { personalizationDao.profileNow() }
        val currentTargetDeferred = async { nutritionRepository.observeDay(currentEpochDay).first().target }
        val decisionsDeferred = async { personalizationDao.decisionHistoryNow() }
        val allSessionsDeferred = async { workoutRepository.observeWorkoutHistory().first() }
        val currentSessionDeferred = async { workoutRepository.observeCurrentWorkout().first() }
        val completedWorkoutsDeferred = async { workoutRepository.observeCompletedWorkouts().first() }
        val feedbackDeferred = async { feedbackRepository.observeForGoal(goal.id).first() }
        
        val rangeStart = Math.subtractExact(currentEpochDay, 6L)
        val nutritionDaysDeferred = async { nutritionRepository.observeRange(rangeStart, currentEpochDay).first() }
        val recentWeightsDeferred = async { personalizationDao.weightHistoryNow().takeLast(4).map { it.weightKg } }
        val checkInsDeferred = async { personalizationDao.observeAllCheckIns().first() }

        val profileEntity = profileDeferred.await() ?: return@coroutineScope null
        val currentTarget = currentTargetDeferred.await() ?: return@coroutineScope null
        val decisions = decisionsDeferred.await()
        val allSessions = allSessionsDeferred.await().filter { it.goalId == goal.id }
        val missedCount = allSessions.count { it.completedEpochDay == null && it.dueEpochDay < currentEpochDay }

        val currentSession = currentSessionDeferred.await()
        val completedWorkouts = completedWorkoutsDeferred.await()
        val feedback = feedbackDeferred.await()
        val nutritionDays = nutritionDaysDeferred.await()
        val recentWeights = recentWeightsDeferred.await()
        val checkInsNewestFirst = checkInsDeferred.await().map { row ->
            CheckInData(row.energy, row.hunger, row.recovery, row.sleepQuality)
        }

        WeeklySnapshotAssembler.build(
            WeeklySnapshotInputs(
                currentEpochDay = currentEpochDay,
                goal = goal,
                currentSession = currentSession,
                completedWorkouts = completedWorkouts,
                feedback = feedback,
                nutritionDays = nutritionDays,
                recentWeights = recentWeights,
                checkInsNewestFirst = checkInsNewestFirst,
                currentTarget = currentTarget,
                profile = PersonalProfile(
                    birthDateEpochDay = profileEntity.birthDateEpochDay,
                    metabolicSex = profileEntity.metabolicSex,
                    heightCm = profileEntity.heightCm,
                    currentWeightKg = profileEntity.currentWeightKg,
                    targetWeightKg = profileEntity.targetWeightKg,
                    activityLevel = profileEntity.activityLevel,
                    goalPace = profileEntity.goalPace,
                    personalizationConsent = profileEntity.personalizationConsent,
                    cloudAiConsent = profileEntity.cloudAiConsent,
                ),
                daysSinceLastCalorieDecision = daysSinceLastDecision(
                    decisions.filter { it.kind == com.example.myapplication.core.adaptation.AdaptationKind.CALORIE_TARGET }
                        .maxOfOrNull { it.createdAtEpochMillis },
                ),
                daysSinceLastWorkoutDecision = daysSinceLastDecision(
                    decisions.filter {
                        it.kind == com.example.myapplication.core.adaptation.AdaptationKind.WORKOUT_VOLUME ||
                            it.kind == com.example.myapplication.core.adaptation.AdaptationKind.DELOAD_WEEK
                    }.maxOfOrNull { it.createdAtEpochMillis },
                ),
                missedSessions = missedCount,
            ),
        )
    }

    private fun daysSinceLastDecision(createdAtEpochMillis: Long?): Int {
        if (createdAtEpochMillis == null) return Int.MAX_VALUE
        val elapsed = (nowEpochMillis() - createdAtEpochMillis).coerceAtLeast(0L)
        return (elapsed / MILLIS_PER_DAY).coerceAtMost(Int.MAX_VALUE.toLong()).toInt()
    }

    private companion object {
        const val MILLIS_PER_DAY = 86_400_000L
    }
}
