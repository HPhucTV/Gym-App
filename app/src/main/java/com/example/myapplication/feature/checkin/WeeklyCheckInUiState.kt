package com.example.myapplication.feature.checkin

data class CheckInHistorySummary(
    val weightChangeKg: Double? = null,
    val averageRecovery: Double = 0.0,
    val averageSleep: Double = 0.0,
    val totalCheckIns: Int = 0,
    val averageWeeklyCalories: Double = 0.0,
    val averageWeeklyScore: Double = 0.0,
    val averageWeeklyProtein: Double = 0.0,
    val averageWeeklyCarbs: Double = 0.0,
    val averageWeeklyFat: Double = 0.0,
)

sealed interface WeeklyCheckInUiState {
    data object Loading : WeeklyCheckInUiState
    data object NoProfile : WeeklyCheckInUiState
    data class Input(
        val weightKgStr: String,
        val energy: Int,
        val hunger: Int,
        val recovery: Int,
        val sleepQuality: Int,
        val note: String,
        val isSubmitting: Boolean = false,
        val error: String? = null,
        val success: Boolean = false,
        val validationErrors: List<String> = emptyList(),
        val historySummary: CheckInHistorySummary = CheckInHistorySummary(),
    ) : WeeklyCheckInUiState
}
