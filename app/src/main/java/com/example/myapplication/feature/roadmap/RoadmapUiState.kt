package com.example.myapplication.feature.roadmap

sealed interface RoadmapUiState {
    data object Loading : RoadmapUiState
    data class Error(val message: String) : RoadmapUiState
    data class Success(
        val programName: String,
        val sessions: List<RoadmapSessionUi>,
        val currentSequenceIndex: Int
    ) : RoadmapUiState
}

data class RoadmapSessionUi(
    val sequenceIndex: Int,
    val week: Int,
    val sessionInWeek: Int,
    val titleVi: String,
    val focusVi: String,
    val estimatedMinutes: Int,
    val status: RoadmapSessionStatus
)

enum class RoadmapSessionStatus {
    COMPLETED,
    ACTIVE,
    LOCKED
}
