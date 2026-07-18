import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gym_app/core/notification/reminder_orchestrator.dart';
import 'package:gym_app/data/repositories/settings_repository.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  test('next alarm handles future passed gap overlap and rejects invalid time', () {
    final zone = tz.getLocation('America/New_York');
    final now = tz.TZDateTime(zone, 2026, 1, 2, 10, 0, 0);
    
    expect(nextReminderOccurrence(now, 11, 0).day, 2);
    expect(nextReminderOccurrence(now, 11, 0).hour, 11);
    expect(nextReminderOccurrence(now, 9, 0).day, 3);
    expect(nextReminderOccurrence(now, 9, 0).hour, 9);
    
    final gapNow = tz.TZDateTime(zone, 2026, 3, 8, 1, 0, 0);
    expect(nextReminderOccurrence(gapNow, 2, 30).isAfter(gapNow), true);
    
    final overlapNow = tz.TZDateTime(zone, 2026, 11, 1, 0, 30, 0);
    expect(nextReminderOccurrence(overlapNow, 1, 30).isAfter(overlapNow), true);
    
    expect(() => nextReminderOccurrence(now, 24, 0), throwsArgumentError);
  });

  test('workout orchestration isolates schedule and notification failures', () async {
    final calls = <String>[];
    await runWorkoutReminder(
      loadSettings: () async => const Settings(reminderEnabled: true, reminderHour: 7),
      schedule: (h, m) async {
        calls.add('schedule');
        throw Exception('alarm');
      },
      notify: () async {
        calls.add('notify');
        throw Exception('notification');
      },
      log: (err) {
        calls.add('log');
      },
    );
    expect(calls, const ['schedule', 'log', 'notify', 'log']);
  });

  test('workout still notifies when settings load fails and boot catches failures', () async {
    final calls = <String>[];
    await runWorkoutReminder(
      loadSettings: () async => throw Exception('data'),
      schedule: (h, m) async => calls.add('schedule'),
      notify: () async => calls.add('notify'),
      log: (err) => calls.add('log'),
    );
    expect(calls, const ['log', 'notify']);

    calls.clear();
    await runBootReschedule(
      loadSettings: () async => const Settings(reminderEnabled: true),
      schedule: (h, m) async => throw Exception('alarm'),
      log: (err) => calls.add('log'),
    );
    expect(calls, const ['log']);
  });

  test('workout does not notify when settings load succeeds and reminder is disabled', () async {
    final calls = <String>[];
    await runWorkoutReminder(
      loadSettings: () async => const Settings(reminderEnabled: false),
      schedule: (h, m) async => calls.add('schedule'),
      notify: () async => calls.add('notify'),
      log: (err) => calls.add('log'),
    );
    expect(calls, isEmpty);
  });

  test('cancellation from settings load is rethrown and never logged', () async {
    final calls = <String>[];
    try {
      await runWorkoutReminder(
        loadSettings: () async => throw CancellationException('settings'),
        schedule: (h, m) async {},
        notify: () async {},
        log: (err) => calls.add('log'),
      );
      fail('expected cancellation from settings load');
    } on CancellationException catch (e) {
      expect(e.message, 'settings');
      expect(calls.contains('log'), false);
    }
  });

  test('cancellation from schedule is rethrown and never logged', () async {
    final calls = <String>[];
    try {
      await runWorkoutReminder(
        loadSettings: () async => const Settings(reminderEnabled: true),
        schedule: (h, m) async => throw CancellationException('schedule'),
        notify: () async {},
        log: (err) => calls.add('log'),
      );
      fail('expected cancellation from schedule');
    } on CancellationException catch (e) {
      expect(e.message, 'schedule');
      expect(calls.contains('log'), false);
    }
  });

  test('cancellation from notify is rethrown and never logged', () async {
    final calls = <String>[];
    try {
      await runWorkoutReminder(
        loadSettings: () async => const Settings(reminderEnabled: true),
        schedule: (h, m) async {},
        notify: () async => throw CancellationException('notify'),
        log: (err) => calls.add('log'),
      );
      fail('expected cancellation from notify');
    } on CancellationException catch (e) {
      expect(e.message, 'notify');
      expect(calls.contains('log'), false);
    }
  });

  test('cancellation from boot reschedule is rethrown and never logged', () async {
    final calls = <String>[];
    try {
      await runBootReschedule(
        loadSettings: () async => throw CancellationException('boot'),
        schedule: (h, m) async {},
        log: (err) => calls.add('log'),
      );
      fail('expected cancellation from boot reschedule');
    } on CancellationException catch (e) {
      expect(e.message, 'boot');
      expect(calls.contains('log'), false);
    }
  });

  test('DST gap resolves exactly and overlap chooses next valid instant', () {
    final zone = tz.getLocation('America/New_York');
    
    final gapNow = tz.TZDateTime(zone, 2026, 3, 8, 1, 0, 0);
    final gap = nextReminderOccurrence(gapNow, 2, 30);
    expect(gap.year, 2026);
    expect(gap.month, 3);
    expect(gap.day, 8);
    expect(gap.hour, 3);
    expect(gap.minute, 30);
    expect(gap.timeZoneOffset, const Duration(hours: -4));

    // Construct beforeOverlap (00:30 at -04:00 offset)
    final beforeOverlap = tz.TZDateTime.fromMillisecondsSinceEpoch(
      zone,
      DateTime.utc(2026, 11, 1, 0, 30).millisecondsSinceEpoch - const Duration(hours: -4).inMilliseconds,
    );
    final first = nextReminderOccurrence(beforeOverlap, 1, 30);
    expect(first.timeZoneOffset, const Duration(hours: -4));

    // betweenOccurrences is 01:45 at -04:00 offset
    final betweenOccurrences = tz.TZDateTime.fromMillisecondsSinceEpoch(
      zone,
      DateTime.utc(2026, 11, 1, 1, 45).millisecondsSinceEpoch - const Duration(hours: -4).inMilliseconds,
    );
    
    final second = nextReminderOccurrence(betweenOccurrences, 1, 30);
    expect(second.year, 2026);
    expect(second.month, 11);
    expect(second.day, 1);
    expect(second.hour, 1);
    expect(second.minute, 30);
    expect(second.timeZoneOffset, const Duration(hours: -5));
    expect(second.isAfter(betweenOccurrences), true);
  });

  test('notification permission matrix is explicit', () {
    expect(shouldPostNotification(32, false), true);
    expect(shouldPostNotification(33, true), true);
    expect(shouldPostNotification(33, false), false);
  });

  test('permission denial skips post but orchestration still schedules', () async {
    final calls = <String>[];
    await runWorkoutReminder(
      loadSettings: () async => const Settings(reminderEnabled: true),
      schedule: (h, m) async => calls.add('schedule'),
      notify: () async {
        if (shouldPostNotification(33, false)) {
          calls.add('notify');
        }
      },
      log: (err) => calls.add('log'),
    );
    expect(calls, const ['schedule']);
  });
}
