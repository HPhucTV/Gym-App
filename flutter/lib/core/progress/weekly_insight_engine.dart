import '../model/feedback_models.dart';
import '../model/workout_models.dart';
import '../model/goal_models.dart';

sealed class WeeklyInsight {
  final String messageVi;
  WeeklyInsight(this.messageVi);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyInsight &&
          runtimeType == other.runtimeType &&
          messageVi == other.messageVi;

  @override
  int get hashCode => messageVi.hashCode;
}

class WeeklyInsightAdherenceTrend extends WeeklyInsight {
  WeeklyInsightAdherenceTrend(super.messageVi);
}

class WeeklyInsightReliableWeekday extends WeeklyInsight {
  WeeklyInsightReliableWeekday(super.messageVi);
}

class WeeklyInsightDifficultyTrend extends WeeklyInsight {
  WeeklyInsightDifficultyTrend(super.messageVi);
}

class WeeklyInsightTimeBudgetPattern extends WeeklyInsight {
  WeeklyInsightTimeBudgetPattern(super.messageVi);
}

class WeeklyInsightScheduleDrift extends WeeklyInsight {
  WeeklyInsightScheduleDrift(super.messageVi);
}

class WeeklyInsightEngine {
  static List<WeeklyInsight> generate({
    required List<WorkoutHistoryEntry> history,
    required List<WorkoutFeedback> feedback,
    required int todayEpochDay,
  }) {
    final currentMonday = _mondayOfWeek(todayEpochDay);
    final windowStart = currentMonday - 28;

    final evidence = history
        .where((it) =>
            it.dueEpochDay >= windowStart && it.dueEpochDay < currentMonday)
        .toList();

    // Group by week start
    final byWeek = <int, List<WorkoutHistoryEntry>>{};
    for (var h in evidence) {
      final start = _mondayOfWeek(h.dueEpochDay);
      byWeek.putIfAbsent(start, () => []).add(h);
    }

    if (byWeek.keys.length < 2) return [];

    final sortedWeekStarts = byWeek.keys.toList()..sort();

    final insights = <WeeklyInsight>[];

    final adherence = _adherenceInsight(byWeek, sortedWeekStarts);
    if (adherence != null) insights.add(adherence);

    final reliable = _reliableWeekdayInsight(evidence);
    if (reliable != null) insights.add(reliable);

    final diff = _difficultyInsight(evidence, feedback);
    if (diff != null) insights.add(diff);

    final budget = _timeBudgetInsight(evidence);
    if (budget != null) insights.add(budget);

    final drift = _scheduleDriftInsight(evidence);
    if (drift != null) insights.add(drift);

    return insights.take(3).toList();
  }

  static WeeklyInsightAdherenceTrend? _adherenceInsight(
    Map<int, List<WorkoutHistoryEntry>> byWeek,
    List<int> sortedWeekStarts,
  ) {
    final rates = sortedWeekStarts.map((weekStart) {
      final week = byWeek[weekStart]!;
      final completedCount =
          week.where((it) => it.completedEpochDay != null).length;
      return completedCount * 100.0 / week.length;
    }).toList();

    final split = rates.length ~/ 2;
    if (split == 0) return null;

    final older =
        rates.take(split).fold<double>(0, (sum, val) => sum + val) / split;
    final newer = rates.skip(split).fold<double>(0, (sum, val) => sum + val) /
        (rates.length - split);

    final difference = (newer - older).round();
    if (difference.abs() < 15) return null;

    final direction = difference > 0 ? "tăng" : "giảm";
    return WeeklyInsightAdherenceTrend(
      "Tỷ lệ bám lịch $direction ${difference.abs()} điểm phần trăm qua ${rates.length} tuần đầy đủ.",
    );
  }

  static WeeklyInsightReliableWeekday? _reliableWeekdayInsight(
    List<WorkoutHistoryEntry> evidence,
  ) {
    final byWeekday = <WeekDay, List<WorkoutHistoryEntry>>{};
    for (var entry in evidence) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        entry.dueEpochDay * 24 * 60 * 60 * 1000,
        isUtc: true,
      );
      final weekday = WeekDay.fromValue(date.weekday);
      byWeekday.putIfAbsent(weekday, () => []).add(entry);
    }

    final candidates =
        byWeekday.entries.where((e) => e.value.length >= 3).toList();
    if (candidates.isEmpty) return null;

    // Sắp xếp theo tỷ lệ hoàn thành giảm dần, sau đó theo weekday value tăng dần
    candidates.sort((a, b) {
      final aRate = a.value
              .where((it) => it.completedEpochDay != null)
              .length
              .toDouble() /
          a.value.length;
      final bRate = b.value
              .where((it) => it.completedEpochDay != null)
              .length
              .toDouble() /
          b.value.length;
      if (aRate != bRate) {
        return bRate.compareTo(aRate);
      }
      return a.key.value.compareTo(b.key.value);
    });

    final best = candidates.first;
    final completedCount =
        best.value.where((it) => it.completedEpochDay != null).length;
    return WeeklyInsightReliableWeekday(
      "${_weekdayVi(best.key)} ổn định nhất: hoàn thành $completedCount/${best.value.length} buổi đã xếp.",
    );
  }

  static WeeklyInsightDifficultyTrend? _difficultyInsight(
    List<WorkoutHistoryEntry> evidence,
    List<WorkoutFeedback> feedback,
  ) {
    final sessionIds = evidence.map((e) => e.sessionId).toSet();
    final relevant =
        feedback.where((f) => sessionIds.contains(f.sessionId)).toList();
    if (relevant.length < 4) return null;

    final hardCount =
        relevant.where((f) => f.difficulty == WorkoutDifficulty.hard).length;
    final easyCount =
        relevant.where((f) => f.difficulty == WorkoutDifficulty.easy).length;

    final String message;
    if (hardCount * 2 >= relevant.length) {
      message =
          "$hardCount/${relevant.length} buổi được đánh giá quá nặng; nên ưu tiên hồi phục.";
    } else if (easyCount * 2 >= relevant.length) {
      message =
          "$easyCount/${relevant.length} buổi được đánh giá quá nhẹ; chương trình có thể cần tăng dần.";
    } else {
      message =
          "${relevant.length} phản hồi cho thấy độ khó nhìn chung vừa sức.";
    }

    return WeeklyInsightDifficultyTrend(message);
  }

  static WeeklyInsightTimeBudgetPattern? _timeBudgetInsight(
    List<WorkoutHistoryEntry> evidence,
  ) {
    final shortened =
        evidence.where((e) => e.selectedTimeBudgetMinutes != null).toList();
    if (shortened.length < 4) return null;

    final counts = <int, int>{};
    for (var s in shortened) {
      final minutes = s.selectedTimeBudgetMinutes!;
      counts[minutes] = (counts[minutes] ?? 0) + 1;
    }

    final entries = counts.entries.toList();
    entries.sort((a, b) {
      if (a.value != b.value) {
        return b.value.compareTo(a.value); // Sắp xếp số lượng giảm dần
      }
      return a.key.compareTo(b.key); // Khớp phút tăng dần
    });

    final common = entries.first;
    return WeeklyInsightTimeBudgetPattern(
      "Bạn đã chọn bản ${common.key} phút trong ${shortened.length} buổi gần đây.",
    );
  }

  static WeeklyInsightScheduleDrift? _scheduleDriftInsight(
    List<WorkoutHistoryEntry> evidence,
  ) {
    final completed =
        evidence.where((e) => e.completedEpochDay != null).toList();
    if (completed.length < 3) return null;

    final shifted =
        completed.where((e) => e.completedEpochDay != e.dueEpochDay).toList();
    if (shifted.isEmpty) return null;

    return WeeklyInsightScheduleDrift(
      "${shifted.length}/${completed.length} buổi hoàn thành khác ngày dự kiến.",
    );
  }

  static int _mondayOfWeek(int epochDay) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochDay * 24 * 60 * 60 * 1000,
      isUtc: true,
    );
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return monday.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  static String _weekdayVi(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return "Thứ Hai";
      case WeekDay.tuesday:
        return "Thứ Ba";
      case WeekDay.wednesday:
        return "Thứ Tư";
      case WeekDay.thursday:
        return "Thứ Năm";
      case WeekDay.friday:
        return "Thứ Sáu";
      case WeekDay.saturday:
        return "Thứ Bảy";
      case WeekDay.sunday:
        return "Chủ Nhật";
    }
  }
}
