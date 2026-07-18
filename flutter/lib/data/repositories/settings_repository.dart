import '../../core/model/goal_models.dart';

class Settings {
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final RestDayMode? restDayMode;
  final String? customServerUrl;
  final bool? darkModeEnabled;
  final Set<String> soreMuscles;

  const Settings({
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.restDayMode,
    this.customServerUrl,
    this.darkModeEnabled,
    this.soreMuscles = const {},
  });

  Settings copyWith({
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    RestDayMode? restDayMode,
    String? customServerUrl,
    bool? darkModeEnabled,
    Set<String>? soreMuscles,
  }) {
    return Settings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      restDayMode: restDayMode ?? this.restDayMode,
      customServerUrl: customServerUrl ?? this.customServerUrl,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      soreMuscles: soreMuscles ?? this.soreMuscles,
    );
  }
}

abstract class SettingsRepository {
  Stream<Settings> get settings;
  Future<void> setReminderEnabled(bool enabled);
  Future<void> setReminderTime(int hour, int minute);
  Future<void> setRestDayMode(RestDayMode? mode);
  Future<void> setCustomServerUrl(String? url);
  Future<void> setDarkModeEnabled(bool? enabled);
  Future<void> setSoreMuscles(Set<String> muscles);
}
