import 'package:timezone/timezone.dart' as tz;
import '../../data/repositories/settings_repository.dart';

class CancellationException implements Exception {
  final String message;
  CancellationException(this.message);

  @override
  String toString() => 'CancellationException: $message';
}

List<tz.TZDateTime> getValidCandidates(
  tz.Location location,
  int year,
  int month,
  int day,
  int hour,
  int minute,
) {
  final uniqueOffsets = location.zones.map((z) => z.offset).toSet();
  final localUtc = DateTime.utc(year, month, day, hour, minute);
  final localMillis = localUtc.millisecondsSinceEpoch;
  
  final candidates = <tz.TZDateTime>[];
  for (final offset in uniqueOffsets) {
    final utcMillis = localMillis - offset.inMilliseconds;
    final tzAtUtc = location.timeZone(utcMillis);
    if (tzAtUtc.offset == offset) {
      final tzDateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(location, utcMillis);
      if (tzDateTime.year == year &&
          tzDateTime.month == month &&
          tzDateTime.day == day &&
          tzDateTime.hour == hour &&
          tzDateTime.minute == minute) {
        candidates.add(tzDateTime);
      }
    }
  }
  
  if (candidates.isEmpty) {
    candidates.add(tz.TZDateTime(location, year, month, day, hour, minute));
  }
  
  candidates.sort((a, b) => a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch));
  return candidates;
}

tz.TZDateTime nextReminderOccurrence(tz.TZDateTime now, int hour, int minute) {
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw ArgumentError('Invalid hour or minute');
  }
  
  var date = tz.TZDateTime(now.location, now.year, now.month, now.day);
  while (true) {
    final candidates = getValidCandidates(
      now.location,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    
    for (final candidate in candidates) {
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }
    
    date = date.add(const Duration(days: 1));
  }
}

bool shouldPostNotification(int apiLevel, bool permissionGranted) {
  return apiLevel < 33 || permissionGranted;
}

Future<void> runWorkoutReminder({
  required Future<Settings> Function() loadSettings,
  required Future<void> Function(int hour, int minute) schedule,
  required Future<void> Function() notify,
  required void Function(Object error) log,
}) async {
  Settings? settings;
  try {
    settings = await loadSettings();
  } on CancellationException {
    rethrow;
  } catch (error) {
    log(error);
  }

  if (settings?.reminderEnabled == true) {
    try {
      await schedule(settings!.reminderHour, settings.reminderMinute);
    } on CancellationException {
      rethrow;
    } catch (error) {
      log(error);
    }
  }

  if (settings == null || settings.reminderEnabled) {
    try {
      await notify();
    } on CancellationException {
      rethrow;
    } catch (error) {
      log(error);
    }
  }
}

Future<void> runBootReschedule({
  required Future<Settings> Function() loadSettings,
  required Future<void> Function(int hour, int minute) schedule,
  required void Function(Object error) log,
}) async {
  try {
    final settings = await loadSettings();
    if (settings.reminderEnabled) {
      await schedule(settings.reminderHour, settings.reminderMinute);
    }
  } on CancellationException {
    rethrow;
  } catch (error) {
    log(error);
  }
}
