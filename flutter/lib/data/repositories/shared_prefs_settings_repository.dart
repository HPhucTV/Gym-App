import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/model/goal_models.dart';
import 'settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  final SharedPreferences prefs;
  final _controller = StreamController<Settings>.broadcast();

  SharedPrefsSettingsRepository(this.prefs) {
    _emitCurrent();
  }

  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _keyRest = 'rest_day_mode';
  static const _keyCustomServer = 'custom_server_url';
  static const _keyDarkMode = 'dark_mode_enabled';
  static const _keySoreMuscles = 'sore_muscles';

  Settings _getCurrent() {
    final enabled = prefs.getBool(_keyEnabled) ?? false;
    final hour = prefs.getInt(_keyHour) ?? 20;
    final minute = prefs.getInt(_keyMinute) ?? 0;
    final restStr = prefs.getString(_keyRest);
    final restMode = restStr != null
        ? RestDayMode.values.firstWhere(
            (e) => e.name == restStr || e.toString().split('.').last == restStr,
            orElse: () => RestDayMode.fullRest,
          )
        : null;
    final customUrl = prefs.getString(_keyCustomServer);
    final darkMode = prefs.getBool(_keyDarkMode);
    final soreStr = prefs.getString(_keySoreMuscles) ?? '';
    final soreSet = soreStr.split(',').where((s) => s.isNotEmpty).toSet();

    return Settings(
      reminderEnabled: enabled,
      reminderHour: hour.clamp(0, 23),
      reminderMinute: minute.clamp(0, 59),
      restDayMode: restMode,
      customServerUrl: customUrl,
      darkModeEnabled: darkMode,
      soreMuscles: soreSet,
    );
  }

  void _emitCurrent() {
    _controller.add(_getCurrent());
  }

  @override
  Stream<Settings> get settings {
    final controller = StreamController<Settings>();
    controller.add(_getCurrent());
    final subscription = _controller.stream.listen(controller.add);
    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  @override
  Future<void> setReminderEnabled(bool enabled) async {
    await prefs.setBool(_keyEnabled, enabled);
    _emitCurrent();
  }

  @override
  Future<void> setReminderTime(int hour, int minute) async {
    require(hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59);
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);
    _emitCurrent();
  }

  @override
  Future<void> setRestDayMode(RestDayMode? mode) async {
    if (mode == null) {
      await prefs.remove(_keyRest);
    } else {
      await prefs.setString(_keyRest, mode.name);
    }
    _emitCurrent();
  }

  @override
  Future<void> setCustomServerUrl(String? url) async {
    if (url == null) {
      await prefs.remove(_keyCustomServer);
    } else {
      await prefs.setString(_keyCustomServer, url);
    }
    _emitCurrent();
  }

  @override
  Future<void> setDarkModeEnabled(bool? enabled) async {
    if (enabled == null) {
      await prefs.remove(_keyDarkMode);
    } else {
      await prefs.setBool(_keyDarkMode, enabled);
    }
    _emitCurrent();
  }

  @override
  Future<void> setSoreMuscles(Set<String> muscles) async {
    await prefs.setString(_keySoreMuscles, muscles.join(','));
    _emitCurrent();
  }

  void require(bool condition) {
    if (!condition) throw ArgumentError();
  }
}
