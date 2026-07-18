import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/program/schedule_rescheduler.dart';

void main() {
  group('ScheduleReschedulerTest', () {
    final sessions = [
      ReschedulableSession(sessionId: 1, sequenceIndex: 0, dueEpochDay: 100, completedEpochDay: 100, demanding: true),
      ReschedulableSession(sessionId: 2, sequenceIndex: 1, dueEpochDay: 102, completedEpochDay: null, demanding: true),
      ReschedulableSession(sessionId: 3, sequenceIndex: 2, dueEpochDay: 104, completedEpochDay: null, demanding: true),
      ReschedulableSession(sessionId: 4, sequenceIndex: 3, dueEpochDay: 107, completedEpochDay: null, demanding: false),
    ];

    WeekDay day(int epochDay) {
      final date = DateTime.fromMillisecondsSinceEpoch(epochDay * 24 * 60 * 60 * 1000, isUtc: true);
      return WeekDay.fromValue(date.weekday);
    }

    test('moves pending session earlier and never changes completed rows', () {
      final preview = ScheduleRescheduler.preview(
        sessions: sessions,
        selectedSessionId: 2,
        newEpochDay: 101,
        todayEpochDay: 100,
        trainingDays: {day(101), day(103), day(106)},
      );

      expect(preview.changes.map((c) => c.sessionId).toList(), equals([2, 3, 4]));
      expect(preview.changes.any((c) => c.sessionId == 1), isFalse);
      expect(preview.changes.map((c) => c.newEpochDay).toList(), equals([101, 103, 106]));
    });

    test('moves later over week boundary while preserving sequence', () {
      final preview = ScheduleRescheduler.preview(
        sessions: sessions,
        selectedSessionId: 2,
        newEpochDay: 108,
        todayEpochDay: 100,
        trainingDays: {day(108), day(110), day(113)},
      );

      expect(preview.changes.map((c) => c.newEpochDay).toList(), equals([108, 110, 113]));
      final sortedChanges = List<SessionDateChange>.from(preview.changes)
        ..sort((a, b) => a.newEpochDay.compareTo(b.newEpochDay));
      expect(preview.changes, equals(sortedChanges));
    });

    test('warns when anchor is not a selected training weekday', () {
      final preview = ScheduleRescheduler.preview(
        sessions: sessions,
        selectedSessionId: 2,
        newEpochDay: 103,
        todayEpochDay: 100,
        trainingDays: {day(102), day(104)},
      );

      expect(preview.warningsVi.any((w) => w.contains("ngày tập")), isTrue);
      expect(preview.changes.first.newEpochDay, equals(103));
    });

    test('warns for consecutive demanding sessions', () {
      final preview = ScheduleRescheduler.preview(
        sessions: sessions,
        selectedSessionId: 2,
        newEpochDay: 101,
        todayEpochDay: 100,
        trainingDays: {day(101), day(102), day(105)},
      );

      expect(preview.warningsVi.any((w) => w.contains("liên tiếp")), isTrue);
    });

    test('rejects past date and arithmetic overflow', () {
      expect(
        () => ScheduleRescheduler.preview(
          sessions: sessions,
          selectedSessionId: 2,
          newEpochDay: 99,
          todayEpochDay: 100,
          trainingDays: {day(100)},
        ),
        throwsArgumentError,
      );

      const int maxInt = 9223372036854775807;
      expect(
        () => ScheduleRescheduler.preview(
          sessions: sessions,
          selectedSessionId: 2,
          newEpochDay: maxInt,
          todayEpochDay: maxInt,
          trainingDays: {WeekDay.monday},
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
