package com.example.myapplication.data

import androidx.room.withTransaction
import com.example.myapplication.core.model.ActiveGoal
import com.example.myapplication.core.model.CompletedWorkout
import com.example.myapplication.core.model.ExercisePrescription
import com.example.myapplication.core.model.GoalConfig
import com.example.myapplication.core.model.FitnessGoal
import com.example.myapplication.core.model.ProgramTemplate
import com.example.myapplication.core.model.WorkoutExercise
import com.example.myapplication.core.model.WorkoutSession
import com.example.myapplication.core.model.WorkoutHistoryEntry
import com.example.myapplication.core.model.ExerciseDefinition
import com.example.myapplication.core.catalog.ExerciseSubstitutionEngine
import com.example.myapplication.core.model.trainingDaysFromMask
import com.example.myapplication.core.model.trainingDaysMask
import com.example.myapplication.core.program.AdaptiveProgramPlanner
import com.example.myapplication.core.program.SchedulePlanner
import com.example.myapplication.core.program.TrainingSchedule
import com.example.myapplication.core.program.SessionTimeBudgetPlanner
import com.example.myapplication.core.program.ReschedulableSession
import com.example.myapplication.core.program.ScheduleChangePreview
import com.example.myapplication.core.program.ScheduleRescheduler
import com.example.myapplication.data.local.GoalEntity
import com.example.myapplication.data.local.GymDatabase
import com.example.myapplication.data.local.SessionExerciseEntity
import com.example.myapplication.data.local.SessionWithExercises
import com.example.myapplication.data.local.WorkoutSessionEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlin.math.floor
import kotlin.math.roundToInt

class RoomWorkoutRepository(
    private val database: GymDatabase,
    private val exercisesProvider: () -> List<ExerciseDefinition>,
    private val settingsRepository: SettingsRepository? = null,
    private val currentEpochDay: () -> Long = { java.time.LocalDate.now().toEpochDay() },
) : WorkoutRepository {

    constructor(
        database: GymDatabase,
        exercises: List<ExerciseDefinition> = emptyList(),
        settingsRepository: SettingsRepository? = null,
        currentEpochDay: () -> Long = { java.time.LocalDate.now().toEpochDay() },
    ) : this(
        database = database,
        exercisesProvider = { exercises },
        settingsRepository = settingsRepository,
        currentEpochDay = currentEpochDay
    )

    private val dao = database.workoutDao()
    private val exercisesMap by lazy { exercisesProvider().associateBy { it.id } }

    override fun observeActiveGoal(): Flow<ActiveGoal?> = dao.observeActiveGoal().map { row ->
        row?.let {
            val goalsList = if (it.goal.goalsCsv.isEmpty()) {
                listOf(it.goal.goal)
            } else {
                it.goal.goalsCsv.split(",").map { FitnessGoal.valueOf(it) }
            }
            ActiveGoal(
                id = it.goal.id,
                config = GoalConfig(
                    goal = it.goal.goal,
                    goals = goalsList,
                    gender = it.goal.gender,
                    bodyType = it.goal.bodyType,
                    level = it.goal.level,
                    equipmentProfile = it.goal.equipmentProfile,
                    sessionsPerWeek = it.goal.sessionsPerWeek,
                    durationWeeks = it.goal.durationWeeks,
                    restDayMode = it.goal.restDayMode,
                    trainingDays = trainingDaysFromMask(it.goal.trainingDaysMask),
                    sessionDurationMinutes = it.goal.sessionDurationMinutes,
                ),
                totalWorkouts = it.totalWorkouts,
            )
        }
    }

    override fun observeCurrentWorkout(): Flow<WorkoutSession?> {
        val sessionFlow = dao.observeCurrentSession()
        val settingsFlow = settingsRepository?.settings ?: kotlinx.coroutines.flow.flowOf(Settings())
        return sessionFlow.combine(settingsFlow) { session, settings ->
            session?.toDomain(settings.soreMuscles)
        }
    }

    override fun observeCompletedWorkouts(): Flow<List<CompletedWorkout>> =
        dao.observeCompletedSessions().map { rows ->
            rows.map { CompletedWorkout(it.goalId, it.completedEpochDay) }
        }

    override fun observeWorkoutHistory(): Flow<List<WorkoutHistoryEntry>> =
        dao.observeWorkoutHistory().map { rows ->
            rows.map { row ->
                WorkoutHistoryEntry(
                    sessionId = row.id,
                    goalId = row.goalId,
                    sequenceIndex = row.sequenceIndex,
                    dueEpochDay = row.dueEpochDay,
                    completedEpochDay = row.completedEpochDay,
                    estimatedMinutes = row.estimatedMinutes,
                    selectedTimeBudgetMinutes = row.selectedTimeBudgetMinutes,
                )
            }
        }

    override suspend fun createGoal(
        config: GoalConfig,
        program: ProgramTemplate,
        startEpochDay: Long,
    ) {
        validateProgramMatch(config, program)
        TrainingSchedule.validate(config.trainingDays, config.sessionDurationMinutes)
        val orderedWorkouts = AdaptiveProgramPlanner.adapt(program, config)
        require(orderedWorkouts.map { it.sequence } == orderedWorkouts.indices.toList()) {
            "Program workouts must use contiguous sequence values starting at zero"
        }
        val dueEpochDays = SchedulePlanner.dueEpochDays(startEpochDay, config.trainingDays, orderedWorkouts.size)

        database.withTransaction {
            dao.archiveActiveGoals()
            val goalId = dao.insertGoal(
                GoalEntity(
                    programId = program.id,
                    goal = config.goal,
                    goalsCsv = config.goals.joinToString(",") { it.name },
                    gender = config.gender,
                    bodyType = config.bodyType,
                    level = config.level,
                    equipmentProfile = config.equipmentProfile,
                    sessionsPerWeek = config.sessionsPerWeek,
                    durationWeeks = config.durationWeeks,
                    restDayMode = config.restDayMode,
                    trainingDaysMask = trainingDaysMask(config.trainingDays),
                    sessionDurationMinutes = config.sessionDurationMinutes,
                    createdEpochDay = startEpochDay,
                ),
            )
            val sessionIds = dao.insertSessions(
                orderedWorkouts.mapIndexed { index, workout ->
                    WorkoutSessionEntity(
                        goalId = goalId,
                        sequenceIndex = workout.sequence,
                        titleVi = workout.titleVi,
                        focusVi = workout.focusVi,
                        estimatedMinutes = workout.estimatedMinutes,
                        dueEpochDay = dueEpochDays[index],
                    )
                },
            )
            val exerciseSnapshots = orderedWorkouts.flatMapIndexed { workoutIndex, workout ->
                workout.exercises.mapIndexed { exerciseIndex, prescription ->
                    SessionExerciseEntity(
                        sessionId = sessionIds[workoutIndex],
                        orderIndex = exerciseIndex,
                        exerciseId = prescription.exerciseId,
                        sets = prescription.sets,
                        minReps = prescription.minReps,
                        maxReps = prescription.maxReps,
                        durationSeconds = prescription.durationSeconds,
                        restSeconds = prescription.restSeconds,
                    )
                }
            }
            if (exerciseSnapshots.isNotEmpty()) dao.insertExercises(exerciseSnapshots)
        }
    }

    override suspend fun setExerciseChecked(sessionId: Long, orderIndex: Int, checked: Boolean) {
        dao.setCurrentExerciseChecked(sessionId, orderIndex, checked)
    }

    override suspend fun substituteExercise(
        sessionId: Long,
        orderIndex: Int,
        replacementExerciseId: String,
    ): ExerciseSubstitutionResult = database.withTransaction {
        if (dao.getCurrentSessionId() != sessionId) {
            return@withTransaction ExerciseSubstitutionResult.StaleSession
        }

        val row = dao.getExercisesForSession(sessionId).firstOrNull { it.orderIndex == orderIndex }
            ?: return@withTransaction ExerciseSubstitutionResult.InvalidCandidate
        if (row.isChecked) return@withTransaction ExerciseSubstitutionResult.AlreadyChecked

        val session = dao.getSession(sessionId)
            ?: return@withTransaction ExerciseSubstitutionResult.StaleSession
        val profile = dao.getGoal(session.goalId)?.equipmentProfile
            ?: return@withTransaction ExerciseSubstitutionResult.StaleSession
        val originalId = row.originalExerciseId ?: row.exerciseId
        val validIds = ExerciseSubstitutionEngine(exercisesProvider()).findSubstitutionCandidates(originalId, profile).mapTo(mutableSetOf()) { it.id }
        if (row.originalExerciseId != null) validIds += originalId
        if (replacementExerciseId !in validIds) {
            return@withTransaction ExerciseSubstitutionResult.InvalidCandidate
        }

        if (dao.substituteCurrentExercise(sessionId, orderIndex, replacementExerciseId) == 1) {
            ExerciseSubstitutionResult.Applied
        } else {
            ExerciseSubstitutionResult.StaleSession
        }
    }

    override suspend fun applyTimeBudget(
        sessionId: Long,
        minutes: Int?,
    ): TimeBudgetResult = database.withTransaction {
        if (dao.getCurrentSessionId() != sessionId) {
            return@withTransaction TimeBudgetResult.StaleSession
        }
        val session = dao.getSession(sessionId)
            ?: return@withTransaction TimeBudgetResult.StaleSession
        if (dao.countChecked(sessionId) > 0) {
            return@withTransaction TimeBudgetResult.HasCheckedExercises
        }
        if (minutes != null && minutes !in setOf(15, 30, 45) && minutes != session.estimatedMinutes) {
            return@withTransaction TimeBudgetResult.InvalidBudget
        }

        dao.updateSelectedTimeBudget(sessionId, minutes)
        if (minutes == null || minutes >= session.estimatedMinutes) {
            dao.setAllExercisesOmittedByTimeBudget(sessionId, false)
        } else {
            val rows = dao.getExercisesForSession(sessionId).sortedBy { it.orderIndex }
            val selection = SessionTimeBudgetPlanner.select(
                rows.map { row ->
                    ExercisePrescription(
                        exerciseId = row.exerciseId,
                        sets = scaledSets(row.sets, session.volumeScalePercent),
                        minReps = row.minReps,
                        maxReps = row.maxReps,
                        durationSeconds = row.durationSeconds,
                        restSeconds = row.restSeconds,
                    )
                },
                minutes,
            )
            dao.setAllExercisesOmittedByTimeBudget(sessionId, true)
            dao.activateExercisesForTimeBudget(
                sessionId,
                selection.activeOrderIndices.map { rows[it].orderIndex },
            )
        }
        TimeBudgetResult.Applied
    }

    override suspend fun previewScheduleChange(
        sessionId: Long,
        newEpochDay: Long,
    ): ScheduleChangePreview = database.withTransaction {
        if (dao.getCurrentSessionId() != sessionId) {
            throw IllegalArgumentException("Only the current pending session can be rescheduled")
        }
        val session = dao.getSession(sessionId)
            ?: throw IllegalArgumentException("Unknown session $sessionId")
        val goal = dao.getGoal(session.goalId)
            ?: throw IllegalArgumentException("Unknown goal ${session.goalId}")
        ScheduleRescheduler.preview(
            sessions = dao.getSessionsForGoal(session.goalId).map { row ->
                ReschedulableSession(
                    sessionId = row.id,
                    sequenceIndex = row.sequenceIndex,
                    dueEpochDay = row.dueEpochDay,
                    completedEpochDay = row.completedEpochDay,
                    demanding = row.estimatedMinutes >= 30,
                )
            },
            selectedSessionId = sessionId,
            newEpochDay = newEpochDay,
            todayEpochDay = currentEpochDay(),
            trainingDays = trainingDaysFromMask(goal.trainingDaysMask),
        )
    }

    override suspend fun applyScheduleChange(
        preview: ScheduleChangePreview,
    ): ScheduleChangeResult = database.withTransaction {
        val first = preview.changes.firstOrNull() ?: return@withTransaction ScheduleChangeResult.Stale
        if (dao.getCurrentSessionId() != first.sessionId) {
            return@withTransaction ScheduleChangeResult.Stale
        }
        val unchanged = preview.changes.all { change ->
            dao.getSession(change.sessionId)?.let { row ->
                row.completedEpochDay == null && row.dueEpochDay == change.oldEpochDay
            } == true
        }
        if (!unchanged) return@withTransaction ScheduleChangeResult.Stale

        preview.changes.forEach { change ->
            dao.updateSessionDueEpochDay(change.sessionId, change.newEpochDay)
        }
        ScheduleChangeResult.Applied
    }

    override suspend fun completeWorkout(
        sessionId: Long,
        completedEpochDay: Long,
    ): CompleteWorkoutResult = database.withTransaction {
        val session = dao.getSession(sessionId) ?: return@withTransaction CompleteWorkoutResult.AlreadyCompleted
        if (session.completedEpochDay != null) return@withTransaction CompleteWorkoutResult.AlreadyCompleted
        // The public result contract has no stale-state variant. Treat inactive or out-of-order
        // requests as idempotent no-ops, matching repeated completion behavior.
        if (dao.getCurrentSessionId() != sessionId) {
            return@withTransaction CompleteWorkoutResult.AlreadyCompleted
        }
        if (dao.countUnchecked(sessionId) > 0) {
            return@withTransaction CompleteWorkoutResult.BlockedByUncheckedExercises
        }
        if (dao.completeSessionIfIncomplete(sessionId, completedEpochDay) == 0) {
            return@withTransaction CompleteWorkoutResult.AlreadyCompleted
        }

        val delayDays = Math.subtractExact(completedEpochDay, session.dueEpochDay).coerceAtLeast(0L)
        if (delayDays > 0) {
            val laterSessions = dao.getSessionsForGoal(session.goalId)
                .filter { it.sequenceIndex > session.sequenceIndex && it.completedEpochDay == null }
                .sortedBy { it.sequenceIndex }
            val trainingDays = dao.getGoal(session.goalId)?.let { trainingDaysFromMask(it.trainingDaysMask) }.orEmpty()
            if (laterSessions.isNotEmpty() && trainingDays.isNotEmpty()) {
                val newDueDates = SchedulePlanner.dueEpochDays(
                    startEpochDay = Math.addExact(completedEpochDay, 1L),
                    trainingDays = trainingDays,
                    workoutCount = laterSessions.size,
                )
                val updatedSessions = laterSessions.zip(newDueDates).map { (later, dueEpochDay) ->
                    later.copy(dueEpochDay = dueEpochDay)
                }
                dao.updateSessions(updatedSessions)
            }
        }
        CompleteWorkoutResult.Completed
    }

    override suspend fun archiveActiveGoal() {
        database.withTransaction { dao.archiveActiveGoals() }
    }

    private fun validateProgramMatch(config: GoalConfig, program: ProgramTemplate) {
        require(program.goal == config.goal) { "Program goal does not match goal configuration" }
        require(program.level == config.level) { "Program level does not match goal configuration" }
        require(program.equipmentProfile == config.equipmentProfile) {
            "Program equipment does not match goal configuration"
        }
        require(program.durationWeeks == config.durationWeeks) {
            "Program duration does not match goal configuration"
        }
    }

    private fun SessionWithExercises.toDomain(soreMuscles: Set<String> = emptySet()): WorkoutSession {
        val exercisesMap = this@RoomWorkoutRepository.exercisesMap
        return WorkoutSession(
            id = session.id,
            goalId = session.goalId,
            sequenceIndex = session.sequenceIndex,
            titleVi = session.titleVi,
            focusVi = session.focusVi,
            estimatedMinutes = session.estimatedMinutes,
            dueEpochDay = session.dueEpochDay,
            exercises = exercises.filterNot { it.omittedByTimeBudget }.sortedBy { it.orderIndex }.map { exercise ->
                val definition = exercisesMap[exercise.exerciseId]
                val isSore = definition?.primaryMuscleGroup?.name?.let { muscleName ->
                    soreMuscles.contains(muscleName)
                } ?: false

                WorkoutExercise(
                    orderIndex = exercise.orderIndex,
                    exerciseId = exercise.exerciseId,
                    originalExerciseId = exercise.originalExerciseId,
                    prescription = ExercisePrescription(
                        exerciseId = exercise.exerciseId,
                        sets = if (session.completedEpochDay == null) {
                            val baseSets = scaledSets(exercise.sets, session.volumeScalePercent)
                            if (isSore) {
                                maxOf(1, (baseSets * 0.5f).roundToInt())
                            } else {
                                baseSets
                            }
                        } else {
                            exercise.sets
                        },
                        minReps = exercise.minReps,
                        maxReps = exercise.maxReps,
                        durationSeconds = exercise.durationSeconds,
                        restSeconds = exercise.restSeconds,
                    ),
                    isChecked = exercise.isChecked,
                    isLightWorkout = isSore && session.completedEpochDay == null,
                )
            },
            selectedTimeBudgetMinutes = session.selectedTimeBudgetMinutes,
            omittedExerciseCount = exercises.count { it.omittedByTimeBudget },
        )
    }
}

internal fun scaledSets(sets: Int, percent: Int): Int =
    maxOf(1, floor(sets * percent.coerceIn(1, 100) / 100.0).toInt())
