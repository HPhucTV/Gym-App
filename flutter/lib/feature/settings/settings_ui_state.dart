import '../../core/model/goal_models.dart';
import '../../core/program/schedule_rescheduler.dart';

class GoalSummary {
  final FitnessGoal goal;
  final ExperienceLevel level;
  final EquipmentProfile equipment;
  final int sessionsPerWeek;
  final int durationWeeks;

  const GoalSummary({
    required this.goal,
    required this.level,
    required this.equipment,
    required this.sessionsPerWeek,
    required this.durationWeeks,
  });
}

enum PendingConfirmation { none, replace, delete }

sealed class SettingsUiState {
  const SettingsUiState();
}

class SettingsUiStateLoading extends SettingsUiState {
  const SettingsUiStateLoading();
}

class SettingsUiStateContent extends SettingsUiState {
  final GoalSummary goal;
  final RestDayMode effectiveRestDayMode;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String? customServerUrl;
  final bool? darkModeEnabled;
  final bool saving;
  final PendingConfirmation confirmation;
  final String? message;
  final int? currentSessionId;
  final int? currentDueEpochDay;
  final ScheduleChangePreview? schedulePreview;

  const SettingsUiStateContent({
    required this.goal,
    required this.effectiveRestDayMode,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    this.customServerUrl,
    this.darkModeEnabled,
    this.saving = false,
    this.confirmation = PendingConfirmation.none,
    this.message,
    this.currentSessionId,
    this.currentDueEpochDay,
    this.schedulePreview,
  });

  SettingsUiStateContent copyWith({
    GoalSummary? goal,
    RestDayMode? effectiveRestDayMode,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? customServerUrl,
    bool? darkModeEnabled,
    bool? saving,
    PendingConfirmation? confirmation,
    String? message,
    int? currentSessionId,
    int? currentDueEpochDay,
    ScheduleChangePreview? schedulePreview,
  }) {
    return SettingsUiStateContent(
      goal: goal ?? this.goal,
      effectiveRestDayMode: effectiveRestDayMode ?? this.effectiveRestDayMode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      customServerUrl: customServerUrl ?? this.customServerUrl,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      saving: saving ?? this.saving,
      confirmation: confirmation ?? this.confirmation,
      message: message, // Clear if not explicitly provided
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentDueEpochDay: currentDueEpochDay ?? this.currentDueEpochDay,
      schedulePreview: schedulePreview ?? this.schedulePreview,
    );
  }
}

class SettingsUiStateError extends SettingsUiState {
  final String message;
  const SettingsUiStateError(this.message);
}

sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsEventRequestNotificationPermission extends SettingsEvent {
  const SettingsEventRequestNotificationPermission();
}

class SettingsEventGoToOnboarding extends SettingsEvent {
  final bool replacing;
  const SettingsEventGoToOnboarding({required this.replacing});
}
