package com.example.myapplication.feature.today

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.model.*
import com.example.myapplication.data.*
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class TodayViewModel(
    private val repository: WorkoutRepository,
    exercises: List<ExerciseDefinition>,
    private val restDayOverride: Flow<RestDayMode?> = flowOf(null),
    private val currentEpochDay: () -> Long,
) : ViewModel() {
    private data class Operations(
        val completingSessionId: Long? = null,
        val pending: Set<Pair<Long, Int>> = emptySet(),
        val interactionError: Pair<Long, String>? = null,
        val completionError: Pair<Long, String>? = null,
    )

    private val catalog = exercises.associateBy { it.id }
    private val today = MutableStateFlow(currentEpochDay())
    private val operations = MutableStateFlow(Operations())
    private val commandMutex = Mutex()
    private val _uiState = MutableStateFlow<TodayUiState>(TodayUiState.Loading)
    val uiState: StateFlow<TodayUiState> = _uiState.asStateFlow()
    private var retrySession: Long? = null

    init {
        viewModelScope.launch {
            combine(repository.observeActiveGoal(), repository.observeCurrentWorkout(), today, operations, restDayOverride) { goal, session, day, ops, rest ->
                resolve(goal, session, day, ops, rest)
            }.collect { _uiState.value = it }
        }
    }

    fun refreshToday() { today.value = currentEpochDay() }

    fun setChecked(orderIndex: Int, checked: Boolean) {
        val state = _uiState.value as? TodayUiState.Workout ?: return
        val key = state.sessionId to orderIndex
        if (state.isCompleting || key in operations.value.pending || state.rows.none { it.orderIndex == orderIndex }) return
        operations.value = operations.value.copy(
            pending = operations.value.pending + key,
            interactionError = null,
        )
        viewModelScope.launch {
            try {
                commandMutex.withLock { repository.setExerciseChecked(state.sessionId, orderIndex, checked) }
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                operations.value = operations.value.copy(
                    interactionError = state.sessionId to "Không thể cập nhật bài tập. Vui lòng thử lại.")
            } finally {
                operations.value = operations.value.copy(pending = operations.value.pending - key)
            }
        }
    }

    fun completeWorkout() {
        val state = _uiState.value as? TodayUiState.Workout ?: return
        if (!state.canComplete || operations.value.completingSessionId != null ||
            operations.value.pending.any { it.first == state.sessionId }) return
        complete(state.sessionId)
    }

    fun retry() {
        val sessionId = retrySession ?: return
        if (operations.value.completingSessionId != null) return
        complete(sessionId)
    }

    private fun complete(sessionId: Long) {
        retrySession = sessionId
        operations.value = operations.value.copy(completingSessionId = sessionId, completionError = null)
        viewModelScope.launch {
            try {
                when (commandMutex.withLock { repository.completeWorkout(sessionId, currentEpochDay()) }) {
                    CompleteWorkoutResult.Completed, CompleteWorkoutResult.AlreadyCompleted -> Unit
                    CompleteWorkoutResult.BlockedByUncheckedExercises -> operations.value = operations.value.copy(
                        interactionError = sessionId to "Vẫn còn bài tập chưa được đánh dấu hoàn thành.")
                }
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                operations.value = operations.value.copy(completionError = sessionId to "Không thể hoàn thành buổi tập. Vui lòng thử lại.")
            } finally {
                if (operations.value.completingSessionId == sessionId) {
                    operations.value = operations.value.copy(completingSessionId = null)
                }
            }
        }
    }

    private fun resolve(goal: ActiveGoal?, session: WorkoutSession?, day: Long, ops: Operations, restOverride: RestDayMode?): TodayUiState {
        ops.completionError?.takeIf { it.first == session?.id }?.let { return TodayUiState.Error(it.second, canRetry = true) }
        if (goal == null) return TodayUiState.Error("Không tìm thấy mục tiêu đang hoạt động.")
        if (session == null) return TodayUiState.GoalComplete
        if (session.dueEpochDay > day) return TodayUiState.Recovery(
            if ((restOverride ?: goal.config.restDayMode) == RestDayMode.FULL_REST) RecoveryKind.FULL_REST else RecoveryKind.LIGHT_RECOVERY,
            session.dueEpochDay)
        val rows = session.exercises.sortedBy { it.orderIndex }.map { exercise ->
            val definition = catalog[exercise.exerciseId] ?: return TodayUiState.Error(
                "Không tìm thấy bài tập '${exercise.exerciseId}' trong dữ liệu ứng dụng.")
            WorkoutRowUi(exercise.orderIndex, definition.nameVi, exercise.prescription.displayText(),
                exercise.prescription.restSeconds, definition.instructionsVi, exercise.checked, exercise.exerciseId)
        }
        val pending = ops.pending.filter { it.first == session.id }.map { it.second }.toSet()
        val checked = rows.count { it.checked }
        return TodayUiState.Workout(session.id, session.titleVi, session.focusVi, session.estimatedMinutes,
            rows, checked, rows.size, rows.isNotEmpty() && checked == rows.size && pending.isEmpty(),
            ops.completingSessionId == session.id, pending, ops.interactionError?.takeIf { it.first == session.id }?.second)
    }
}

private fun ExercisePrescription.displayText(): String = when {
    durationSeconds != null -> "$durationSeconds giây"
    repsMin != null && repsMax != null -> if (repsMin == repsMax) "$sets × $repsMin" else "$sets × ${repsMin}–${repsMax}"
    else -> "$sets hiệp"
}
