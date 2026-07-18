import '../model/goal_models.dart';

class ReschedulableSession {
  final int sessionId;
  final int sequenceIndex;
  final int dueEpochDay;
  final int? completedEpochDay;
  final bool demanding;

  ReschedulableSession({
    required this.sessionId,
    required this.sequenceIndex,
    required this.dueEpochDay,
    this.completedEpochDay,
    required this.demanding,
  });
}

class SessionDateChange {
  final int sessionId;
  final int oldEpochDay;
  final int newEpochDay;

  SessionDateChange({
    required this.sessionId,
    required this.oldEpochDay,
    required this.newEpochDay,
  });
}

class ScheduleChangePreview {
  final List<SessionDateChange> changes;
  final List<String> warningsVi;

  ScheduleChangePreview({
    required this.changes,
    required this.warningsVi,
  });
}

class ScheduleRescheduler {
  static int _safeAdd(int a, int b) {
    final res = a + b;
    if ((a > 0 && b > 0 && res < 0) || (a < 0 && b < 0 && res > 0)) {
      throw UnsupportedError("Integer overflow");
    }
    return res;
  }

  static ScheduleChangePreview preview({
    required List<ReschedulableSession> sessions,
    required int selectedSessionId,
    required int newEpochDay,
    required int todayEpochDay,
    required Set<WeekDay> trainingDays,
  }) {
    if (newEpochDay < todayEpochDay) {
      throw ArgumentError("New workout date cannot be in the past");
    }
    if (trainingDays.isEmpty) {
      throw ArgumentError("At least one training weekday is required");
    }

    ReschedulableSession? selected;
    for (var s in sessions) {
      if (s.sessionId == selectedSessionId) {
        selected = s;
        break;
      }
    }
    if (selected == null) {
      throw ArgumentError("Unknown session $selectedSessionId");
    }
    if (selected.completedEpochDay != null) {
      throw ArgumentError("Completed sessions cannot be rescheduled");
    }

    final pending = sessions
        .where((it) =>
            it.completedEpochDay == null &&
            it.sequenceIndex >= selected!.sequenceIndex)
        .toList();
    pending.sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex));

    if (pending.length > 1) {
      _safeAdd(newEpochDay, 1);
    }

    final newDates = <int>[];
    newDates.add(newEpochDay);
    var cursor = newEpochDay;

    for (var i = 0; i < pending.length - 1; i++) {
      cursor = _nextTrainingEpochDay(cursor, trainingDays);
      newDates.add(cursor);
    }

    final warnings = <String>[];
    
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      newEpochDay * 24 * 60 * 60 * 1000,
      isUtc: true,
    );
    final selectedWeekday = WeekDay.fromValue(dateTime.weekday);
    if (!trainingDays.contains(selectedWeekday)) {
      warnings.add("Ngày đã chọn không phải ngày tập thường lệ.");
    }

    for (var i = 0; i < pending.length - 1; i++) {
      final leftSession = pending[i];
      final leftDate = newDates[i];
      final rightSession = pending[i + 1];
      final rightDate = newDates[i + 1];

      if (leftSession.demanding &&
          rightSession.demanding &&
          (rightDate - leftDate) == 1) {
        warnings.add(
            "Hai buổi tập nặng được xếp liên tiếp; hãy cân nhắc thời gian hồi phục.");
      }
    }

    return ScheduleChangePreview(
      changes: List.generate(
        pending.length,
        (index) => SessionDateChange(
          sessionId: pending[index].sessionId,
          oldEpochDay: pending[index].dueEpochDay,
          newEpochDay: newDates[index],
        ),
      ),
      warningsVi: warnings.toSet().toList(),
    );
  }

  static int _nextTrainingEpochDay(
    int afterEpochDay,
    Set<WeekDay> trainingDays,
  ) {
    var candidate = _safeAdd(afterEpochDay, 1);
    for (var i = 0; i < 7; i++) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        candidate * 24 * 60 * 60 * 1000,
        isUtc: true,
      );
      final weekday = WeekDay.fromValue(dateTime.weekday);
      if (trainingDays.contains(weekday)) {
        return candidate;
      }
      candidate = _safeAdd(candidate, 1);
    }
    throw StateError("No selected training day found");
  }
}
