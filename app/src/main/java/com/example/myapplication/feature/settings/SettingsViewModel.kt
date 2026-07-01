package com.example.myapplication.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.model.*
import com.example.myapplication.data.*
import com.example.myapplication.notification.ReminderScheduler
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val workoutRepository: WorkoutRepository,
    private val settingsRepository: SettingsRepository,
    private val scheduler: ReminderScheduler,
) : ViewModel() {
    private val saving = MutableStateFlow(false)
    private val confirmation = MutableStateFlow(PendingConfirmation.NONE)
    private val message = MutableStateFlow<String?>(null)
    private val _events = Channel<SettingsEvent>(Channel.BUFFERED)
    val events: Flow<SettingsEvent> = _events.receiveAsFlow()
    private val _uiState = MutableStateFlow<SettingsUiState>(SettingsUiState.Loading)
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            combine(workoutRepository.observeActiveGoal(), settingsRepository.settings, saving, confirmation, message) { goal, prefs, busy, pending, note ->
                if (goal == null) SettingsUiState.Error("Không tìm thấy mục tiêu đang hoạt động.") else SettingsUiState.Content(
                    GoalSummary(goal.config.goal, goal.config.level, goal.config.equipmentProfile, goal.config.sessionsPerWeek, goal.config.durationWeeks),
                    prefs.restDayMode ?: goal.config.restDayMode, prefs.reminderEnabled, prefs.reminderHour, prefs.reminderMinute,
                    busy, pending, note)
            }.collect { _uiState.value = it }
        }
    }

    fun setRestDayMode(mode: RestDayMode) = perform { settingsRepository.setRestDayMode(mode) }
    fun setReminderTime(hour: Int, minute: Int) = perform {
        settingsRepository.setReminderTime(hour, minute)
        val current = settingsRepository.settings.first()
        if (current.reminderEnabled) scheduler.schedule(hour, minute)
    }
    fun setReminderEnabled(enabled: Boolean) {
        if (saving.value) return
        saving.value = true; message.value = null
        viewModelScope.launch {
            try {
                val current = settingsRepository.settings.first()
                settingsRepository.setReminderEnabled(enabled)
                if (enabled) {
                    scheduler.schedule(current.reminderHour, current.reminderMinute)
                    _events.send(SettingsEvent.RequestNotificationPermission)
                } else scheduler.cancel()
            } catch (cancelled: CancellationException) { throw cancelled }
            catch (_: Exception) { message.value = "Không thể lưu cài đặt. Vui lòng thử lại." }
            finally { saving.value = false }
        }
    }
    fun requestReplaceGoal() { if (!saving.value) confirmation.value = PendingConfirmation.REPLACE }
    fun requestDeleteGoal() { if (!saving.value) confirmation.value = PendingConfirmation.DELETE }
    fun cancelConfirmation() { if (!saving.value) confirmation.value = PendingConfirmation.NONE }
    fun confirmGoalAction() {
        val action = confirmation.value
        if (action == PendingConfirmation.NONE || saving.value) return
        saving.value = true; confirmation.value = PendingConfirmation.NONE
        viewModelScope.launch {
            val replacing = action == PendingConfirmation.REPLACE
            var modeHoisted = false
            try {
                navigateAndAwait(replacing)
                modeHoisted = replacing
                workoutRepository.archiveActiveGoal()
            } catch (cancelled: CancellationException) {
                if (modeHoisted) navigateAndAwait(false)
                throw cancelled
            } catch (_: Exception) {
                if (modeHoisted) navigateAndAwait(false)
                message.value = "Không thể cập nhật mục tiêu. Vui lòng thử lại."
            } finally { saving.value = false }
        }
    }
    private suspend fun navigateAndAwait(replacing: Boolean) {
        val event = SettingsEvent.GoToOnboarding(replacing)
        _events.send(event)
        event.awaitAcknowledgement()
    }
    private fun perform(block: suspend () -> Unit) {
        if (saving.value) return
        saving.value = true; message.value = null
        viewModelScope.launch {
            try { block() }
            catch (cancelled: CancellationException) { throw cancelled }
            catch (_: Exception) { message.value = "Không thể lưu cài đặt. Vui lòng thử lại." }
            finally { saving.value = false }
        }
    }
}
