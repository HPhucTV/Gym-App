package com.example.myapplication.feature.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.model.*
import com.example.myapplication.core.program.ProgramSelectionResult
import com.example.myapplication.core.program.ProgramSelector
import com.example.myapplication.data.WorkoutRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class OnboardingViewModel(
    private val programs: List<ProgramTemplate>,
    private val workoutRepository: WorkoutRepository,
    private val currentEpochDay: () -> Long,
) : ViewModel() {
    private val _uiState = MutableStateFlow<OnboardingUiState>(editing(OnboardingStep.GOAL, OnboardingDraft()))
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    fun selectGoal(value: FitnessGoal) = updateDraft {
        OnboardingDraft(goal = value)
    }

    fun selectLevel(value: ExperienceLevel) = updateDraft {
        it.copy(level = value, equipment = null, sessionsPerWeek = null, durationWeeks = null, restDayMode = null)
    }

    fun selectEquipment(value: EquipmentProfile) = updateDraft {
        it.copy(equipment = value, sessionsPerWeek = null, durationWeeks = null, restDayMode = null)
    }

    fun selectCommitment(sessionsPerWeek: Int, durationWeeks: Int) = updateDraft {
        it.copy(sessionsPerWeek = sessionsPerWeek, durationWeeks = durationWeeks, restDayMode = null)
    }

    fun selectRestDayMode(value: RestDayMode) = updateDraft { it.copy(restDayMode = value) }

    fun next() {
        val state = _uiState.value as? OnboardingUiState.Editing ?: return
        if (state.isSaving) return
        val valid = when (state.step) {
            OnboardingStep.GOAL -> state.draft.goal != null
            OnboardingStep.LEVEL -> state.draft.level != null
            OnboardingStep.EQUIPMENT -> state.draft.equipment != null
            OnboardingStep.COMMITMENT -> state.draft.sessionsPerWeek != null && state.draft.durationWeeks != null
            OnboardingStep.REST_BEHAVIOR -> state.draft.restDayMode != null
            OnboardingStep.REVIEW -> false
        }
        if (valid) _uiState.value = editing(OnboardingStep.entries[state.step.ordinal + 1], state.draft)
    }

    fun back() {
        when (val state = _uiState.value) {
            is OnboardingUiState.Editing -> if (!state.isSaving && state.step != OnboardingStep.GOAL) {
                _uiState.value = editing(OnboardingStep.entries[state.step.ordinal - 1], state.draft)
            }
            is OnboardingUiState.Unsupported -> _uiState.value = editing(OnboardingStep.REVIEW, state.draft)
            OnboardingUiState.Created -> Unit
        }
    }

    fun createGoal() {
        val state = _uiState.value as? OnboardingUiState.Editing ?: return
        if (state.isSaving) return
        val draft = state.draft
        val config = GoalConfig(
            goal = draft.goal ?: return,
            level = draft.level ?: return,
            equipmentProfile = draft.equipment ?: return,
            sessionsPerWeek = draft.sessionsPerWeek ?: return,
            durationWeeks = draft.durationWeeks ?: return,
            restDayMode = draft.restDayMode ?: return,
        )
        when (val selection = ProgramSelector.select(config, programs)) {
            ProgramSelectionResult.Unsupported -> _uiState.value = OnboardingUiState.Unsupported(
                draft,
                "Chưa có chương trình phù hợp với lựa chọn này. Hãy chọn một cấu hình được hỗ trợ.",
                programs.map(::programLabel).distinct(),
            )
            is ProgramSelectionResult.Found -> {
                _uiState.value = state.copy(isSaving = true, saveError = null)
                viewModelScope.launch {
                    try {
                        workoutRepository.createGoal(config, selection.program, currentEpochDay())
                        _uiState.value = OnboardingUiState.Created
                    } catch (cancelled: CancellationException) {
                        throw cancelled
                    } catch (_: Exception) {
                        _uiState.value = editing(state.step, draft).copy(saveError = "Không thể lưu mục tiêu. Vui lòng thử lại.")
                    }
                }
            }
        }
    }

    private fun updateDraft(transform: (OnboardingDraft) -> OnboardingDraft) {
        val state = _uiState.value as? OnboardingUiState.Editing ?: return
        if (state.isSaving) return
        _uiState.value = editing(state.step, transform(state.draft))
    }

    private fun editing(step: OnboardingStep, draft: OnboardingDraft) = OnboardingUiState.Editing(
        step, draft, OnboardingOptions(
            goals = programs.map { it.goal }.toSet(),
            levels = programs.filter { draft.goal == null || it.goal == draft.goal }.map { it.level }.toSet(),
            equipment = programs.filter { (draft.goal == null || it.goal == draft.goal) && (draft.level == null || it.level == draft.level) }.map { it.equipmentProfile }.toSet(),
            commitments = programs.filter {
                (draft.goal == null || it.goal == draft.goal) &&
                    (draft.level == null || it.level == draft.level) &&
                    (draft.equipment == null || it.equipmentProfile == draft.equipment)
            }.map { WorkoutCommitment(it.sessionsPerWeek, it.durationWeeks) }.toSet(),
            restDayModes = RestDayMode.entries.toSet(),
        )
    )
}

internal fun programLabel(program: ProgramTemplate): String = listOf(
    program.goal.labelVi(), program.level.labelVi(), program.equipmentProfile.labelVi(),
    "${program.sessionsPerWeek} buổi/tuần", "${program.durationWeeks} tuần",
).joinToString(" · ")

internal fun FitnessGoal.labelVi() = when (this) {
    FitnessGoal.MUSCLE_GAIN -> "Tăng cơ"
    FitnessGoal.FAT_LOSS_CONDITIONING -> "Giảm mỡ & thể lực"
    FitnessGoal.ENDURANCE -> "Sức bền"
    FitnessGoal.GENERAL_FITNESS -> "Thể lực tổng quát"
}
internal fun ExperienceLevel.labelVi() = if (this == ExperienceLevel.BEGINNER) "Người mới" else "Trung cấp"
internal fun EquipmentProfile.labelVi() = when (this) {
    EquipmentProfile.BODYWEIGHT_ONLY -> "Không dụng cụ"
    EquipmentProfile.DUMBBELLS -> "Tạ đơn"
    EquipmentProfile.RESISTANCE_BANDS -> "Dây kháng lực"
    EquipmentProfile.FULL_GYM -> "Phòng gym đầy đủ"
}
internal fun RestDayMode.labelVi() = if (this == RestDayMode.FULL_REST) "Nghỉ hoàn toàn" else "Phục hồi nhẹ"
