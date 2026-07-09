package com.example.myapplication.feature.roadmap

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.model.ActiveGoal
import com.example.myapplication.core.model.ProgramTemplate
import com.example.myapplication.core.model.WorkoutSession
import com.example.myapplication.core.program.ProgramSelector
import com.example.myapplication.core.program.ProgramSelectionResult
import com.example.myapplication.data.WorkoutRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch

class RoadmapViewModel(
    private val repository: WorkoutRepository,
    private val programs: List<ProgramTemplate>,
) : ViewModel() {
    private val _uiState = MutableStateFlow<RoadmapUiState>(RoadmapUiState.Loading)
    val uiState: StateFlow<RoadmapUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            combine(
                repository.observeActiveGoal(),
                repository.observeCurrentWorkout()
            ) { goal, currentWorkout ->
                resolve(goal, currentWorkout)
            }.collect {
                _uiState.value = it
            }
        }
    }

    private fun resolve(goal: ActiveGoal?, currentWorkout: WorkoutSession?): RoadmapUiState {
        if (goal == null) {
            return RoadmapUiState.Error("Không tìm thấy mục tiêu đang hoạt động.")
        }
        val config = goal.config
        val selection = ProgramSelector.select(config, programs)
        if (selection is ProgramSelectionResult.Unsupported) {
            return RoadmapUiState.Error("Không tìm thấy chương trình tập luyện phù hợp với cấu hình của bạn.")
        }
        val program = (selection as ProgramSelectionResult.Found).program

        val currentSeq = currentWorkout?.sequenceIndex ?: Int.MAX_VALUE

        val sessions = program.workouts.map { workout ->
            val status = when {
                workout.sequence < currentSeq -> RoadmapSessionStatus.COMPLETED
                workout.sequence == currentSeq -> RoadmapSessionStatus.ACTIVE
                else -> RoadmapSessionStatus.LOCKED
            }
            val sessionInWeek = program.workouts
                .filter { it.week == workout.week && it.sequence <= workout.sequence }
                .size

            RoadmapSessionUi(
                sequenceIndex = workout.sequence,
                week = workout.week,
                sessionInWeek = sessionInWeek,
                titleVi = workout.titleVi,
                focusVi = workout.focusVi,
                estimatedMinutes = workout.estimatedMinutes,
                status = status
            )
        }

        val programName = when (config.goal) {
            com.example.myapplication.core.model.FitnessGoal.MUSCLE_GAIN -> "Tăng Cơ Bắp (Muscle Gain)"
            com.example.myapplication.core.model.FitnessGoal.FAT_LOSS_CONDITIONING -> "Giảm Mỡ & Thể Lực (Fat Loss & Conditioning)"
            com.example.myapplication.core.model.FitnessGoal.ENDURANCE -> "Sức Bền (Endurance)"
            com.example.myapplication.core.model.FitnessGoal.GENERAL_FITNESS -> "Thể Chất Chung (General Fitness)"
        } + " - Cấp độ " + when (config.level) {
            com.example.myapplication.core.model.ExperienceLevel.BEGINNER -> "Cơ bản"
            com.example.myapplication.core.model.ExperienceLevel.INTERMEDIATE -> "Trung cấp"
        }

        return RoadmapUiState.Success(
            programName = programName,
            sessions = sessions,
            currentSequenceIndex = if (currentSeq == Int.MAX_VALUE) -1 else currentSeq
        )
    }
}
