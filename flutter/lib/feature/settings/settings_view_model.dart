import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/goal_models.dart';
import '../../core/model/workout_models.dart';
import '../../core/program/schedule_rescheduler.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/providers/data_providers.dart';
import '../../core/notification/notification_service.dart';
import 'settings_ui_state.dart';

// Stream Providers
final settingsActiveGoalProvider = StreamProvider<ActiveGoal?>((ref) {
  return ref.watch(workoutRepositoryProvider).observeActiveGoal();
});

final settingsPrefsProvider = StreamProvider<Settings>((ref) {
  return ref.watch(settingsRepositoryProvider).settings;
});

final settingsCurrentWorkoutProvider = StreamProvider<WorkoutSession?>((ref) {
  return ref.watch(workoutRepositoryProvider).observeCurrentWorkout();
});

// Event Stream Controller Provider
final settingsEventProvider = StreamProvider<SettingsEvent>((ref) {
  final notifier = ref.watch(settingsNotifierProvider.notifier);
  return notifier.eventStream;
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsUiState>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<SettingsUiState> {
  final _eventController = StreamController<SettingsEvent>.broadcast();
  Stream<SettingsEvent> get eventStream => _eventController.stream;

  bool _saving = false;
  PendingConfirmation _confirmation = PendingConfirmation.none;
  String? _message;
  ScheduleChangePreview? _schedulePreview;

  @override
  SettingsUiState build() {
    final activeGoalAsync = ref.watch(settingsActiveGoalProvider);
    final prefsAsync = ref.watch(settingsPrefsProvider);
    final currentWorkoutAsync = ref.watch(settingsCurrentWorkoutProvider);

    final activeGoal = activeGoalAsync.value;
    final prefs = prefsAsync.value;
    final currentWorkout = currentWorkoutAsync.value;

    if (activeGoalAsync.isLoading ||
        prefsAsync.isLoading ||
        currentWorkoutAsync.isLoading) {
      return const SettingsUiStateLoading();
    }

    if (activeGoal == null || prefs == null) {
      return const SettingsUiStateError(
          "Không tìm thấy mục tiêu đang hoạt động.");
    }

    return SettingsUiStateContent(
      goal: GoalSummary(
        goal: activeGoal.config.goal,
        level: activeGoal.config.level,
        equipment: activeGoal.config.equipmentProfile,
        sessionsPerWeek: activeGoal.config.sessionsPerWeek,
        durationWeeks: activeGoal.config.durationWeeks,
      ),
      effectiveRestDayMode: prefs.restDayMode ?? activeGoal.config.restDayMode,
      reminderEnabled: prefs.reminderEnabled,
      reminderHour: prefs.reminderHour,
      reminderMinute: prefs.reminderMinute,
      customServerUrl: prefs.customServerUrl,
      darkModeEnabled: prefs.darkModeEnabled,
      saving: _saving,
      confirmation: _confirmation,
      message: _message,
      currentSessionId: currentWorkout?.id,
      currentDueEpochDay: currentWorkout?.dueEpochDay,
      schedulePreview: _schedulePreview,
    );
  }

  void _updateState() {
    final activeGoalAsync = ref.read(settingsActiveGoalProvider);
    final prefsAsync = ref.read(settingsPrefsProvider);
    final currentWorkoutAsync = ref.read(settingsCurrentWorkoutProvider);

    final activeGoal = activeGoalAsync.value;
    final prefs = prefsAsync.value;
    final currentWorkout = currentWorkoutAsync.value;

    if (activeGoalAsync.isLoading ||
        prefsAsync.isLoading ||
        currentWorkoutAsync.isLoading) {
      state = const SettingsUiStateLoading();
      return;
    }

    if (activeGoal == null || prefs == null) {
      state =
          const SettingsUiStateError("Không tìm thấy mục tiêu đang hoạt động.");
      return;
    }

    state = SettingsUiStateContent(
      goal: GoalSummary(
        goal: activeGoal.config.goal,
        level: activeGoal.config.level,
        equipment: activeGoal.config.equipmentProfile,
        sessionsPerWeek: activeGoal.config.sessionsPerWeek,
        durationWeeks: activeGoal.config.durationWeeks,
      ),
      effectiveRestDayMode: prefs.restDayMode ?? activeGoal.config.restDayMode,
      reminderEnabled: prefs.reminderEnabled,
      reminderHour: prefs.reminderHour,
      reminderMinute: prefs.reminderMinute,
      customServerUrl: prefs.customServerUrl,
      darkModeEnabled: prefs.darkModeEnabled,
      saving: _saving,
      confirmation: _confirmation,
      message: _message,
      currentSessionId: currentWorkout?.id,
      currentDueEpochDay: currentWorkout?.dueEpochDay,
      schedulePreview: _schedulePreview,
    );
  }

  void clearMessage() {
    _message = null;
    _updateState();
  }

  bool _startSaving() {
    if (_saving) return false;
    _saving = true;
    _message = null;
    _updateState();
    return true;
  }

  void _stopSaving([String? message]) {
    _saving = false;
    _message = message;
    _updateState();
  }

  Future<void> previewScheduleChange(int sessionId, int newEpochDay) async {
    if (!_startSaving()) return;
    try {
      final preview = await ref
          .read(workoutRepositoryProvider)
          .previewScheduleChange(sessionId, newEpochDay);
      _schedulePreview = preview;
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể xem trước lịch mới. Vui lòng chọn ngày khác.");
    }
  }

  void cancelSchedulePreview() {
    if (!_saving) {
      _schedulePreview = null;
      _updateState();
    }
  }

  Future<void> confirmScheduleChange() async {
    final preview = _schedulePreview;
    if (preview == null || !_startSaving()) return;
    try {
      final result = await ref
          .read(workoutRepositoryProvider)
          .applyScheduleChange(preview);
      if (result == ScheduleChangeResult.applied) {
        _schedulePreview = null;
        _stopSaving("Đã cập nhật lịch tập sắp tới.");
      } else {
        _schedulePreview = null;
        _stopSaving("Lịch tập đã thay đổi. Vui lòng xem trước lại.");
      }
    } catch (_) {
      _stopSaving("Không thể cập nhật lịch tập. Vui lòng thử lại.");
    }
  }

  Future<void> setRestDayMode(RestDayMode mode) async {
    if (!_startSaving()) return;
    try {
      await ref.read(settingsRepositoryProvider).setRestDayMode(mode);
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể lưu cài đặt. Vui lòng thử lại.");
    }
  }

  Future<void> setCustomServerUrl(String? url) async {
    if (!_startSaving()) return;
    try {
      await ref.read(settingsRepositoryProvider).setCustomServerUrl(url);
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể lưu cài đặt. Vui lòng thử lại.");
    }
  }

  Future<void> setDarkModeEnabled(bool? enabled) async {
    if (!_startSaving()) return;
    try {
      await ref.read(settingsRepositoryProvider).setDarkModeEnabled(enabled);
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể lưu cài đặt. Vui lòng thử lại.");
    }
  }

  Future<void> setReminderTime(int hour, int minute) async {
    if (!_startSaving()) return;
    try {
      await ref.read(settingsRepositoryProvider).setReminderTime(hour, minute);
      final prefs = ref.read(settingsPrefsProvider).value;
      if (prefs?.reminderEnabled == true) {
        await ref.read(reminderSchedulerProvider).schedule(hour, minute);
      }
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể lưu cài đặt. Vui lòng thử lại.");
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    if (!_startSaving()) return;
    try {
      await ref.read(settingsRepositoryProvider).setReminderEnabled(enabled);
      if (enabled) {
        final prefs = ref.read(settingsPrefsProvider).value;
        final hour = prefs?.reminderHour ?? 20;
        final minute = prefs?.reminderMinute ?? 0;
        _eventController
            .add(const SettingsEventRequestNotificationPermission());
        await ref.read(reminderSchedulerProvider).schedule(hour, minute);
      } else {
        await ref.read(reminderSchedulerProvider).cancel();
      }
      _stopSaving();
    } catch (_) {
      _stopSaving("Không thể lưu cài đặt. Vui lòng thử lại.");
    }
  }

  void requestReplaceGoal() {
    if (!_saving) {
      _confirmation = PendingConfirmation.replace;
      _updateState();
    }
  }

  void requestDeleteGoal() {
    if (!_saving) {
      _confirmation = PendingConfirmation.delete;
      _updateState();
    }
  }

  void cancelConfirmation() {
    if (!_saving) {
      _confirmation = PendingConfirmation.none;
      _updateState();
    }
  }

  Future<void> confirmGoalAction() async {
    final action = _confirmation;
    if (action == PendingConfirmation.none || _saving) return;
    _saving = true;
    _confirmation = PendingConfirmation.none;
    _updateState();

    final replacing = action == PendingConfirmation.replace;
    try {
      _eventController.add(SettingsEventGoToOnboarding(replacing: replacing));

      // Wait a short duration to ensure UI captures it, then archive active goal
      await Future.delayed(const Duration(milliseconds: 300));
      await ref.read(workoutRepositoryProvider).archiveActiveGoal();
      _saving = false;
      _updateState();
    } catch (_) {
      _saving = false;
      _message = "Không thể cập nhật mục tiêu. Vui lòng thử lại.";
      _updateState();
    }
  }
}
