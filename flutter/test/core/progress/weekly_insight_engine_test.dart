import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/feedback_models.dart';
import 'package:gym_app/core/model/workout_models.dart';
import 'package:gym_app/core/progress/weekly_insight_engine.dart';

void main() {
  int day(String value) {
    final date = DateTime.parse("${value}T00:00:00Z");
    return date.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }

  WorkoutHistoryEntry entry(
    int id,
    String due,
    String? completed, {
    int? budget,
  }) {
    return WorkoutHistoryEntry(
      sessionId: id,
      goalId: 1,
      sequenceIndex: id,
      dueEpochDay: day(due),
      completedEpochDay: completed != null ? day(completed) : null,
      estimatedMinutes: 30,
      selectedTimeBudgetMinutes: budget,
    );
  }

  final today = day("2026-07-06");

  test('fewer than two complete weeks returns no conclusions', () {
    final history = [entry(1, "2026-06-29", "2026-06-29")];

    final insights = WeeklyInsightEngine.generate(
      history: history,
      feedback: [],
      todayEpochDay: today,
    );

    expect(insights.isEmpty, isTrue);
  });

  test('returns at most three conclusions in documented priority', () {
    final history = <WorkoutHistoryEntry>[];
    var id = 1;
    for (var d in ["2026-06-08", "2026-06-10", "2026-06-12"]) {
      history.add(entry(id++, d, null));
    }
    for (var d in ["2026-06-15", "2026-06-17", "2026-06-19"]) {
      history.add(entry(id++, d, d));
    }
    for (var d in ["2026-06-22", "2026-06-24", "2026-06-26"]) {
      history.add(entry(id++, d, d, budget: 15));
    }
    for (var d in ["2026-06-29", "2026-07-01", "2026-07-03"]) {
      history.add(entry(id++, d, d, budget: 15));
    }

    final completedEntries = history.where((it) => it.completedEpochDay != null).toList();
    final feedback = completedEntries.take(4).map((it) {
      return WorkoutFeedback(
        sessionId: it.sessionId,
        goalId: 1,
        completedEpochDay: it.completedEpochDay!,
        difficulty: WorkoutDifficulty.hard,
        recordedAtEpochMillis: 0,
      );
    }).toList();

    final insights = WeeklyInsightEngine.generate(
      history: history,
      feedback: feedback,
      todayEpochDay: today,
    );

    expect(insights.length, 3);
    expect(insights[0] is WeeklyInsightAdherenceTrend, isTrue);
    expect(insights[1] is WeeklyInsightReliableWeekday, isTrue);
    expect(insights[2] is WeeklyInsightDifficultyTrend, isTrue);
    
    final regex = RegExp(r'\d');
    for (var insight in insights) {
      expect(regex.hasMatch(insight.messageVi), isTrue);
    }
  });

  test('evidence thresholds suppress weak claims', () {
    final history = [
      entry(1, "2026-06-16", "2026-06-16", budget: 15),
      entry(2, "2026-06-23", "2026-06-23", budget: 15),
      entry(3, "2026-06-30", "2026-06-30", budget: 15),
    ];
    final feedback = history.map((it) {
      return WorkoutFeedback(
        sessionId: it.sessionId,
        goalId: 1,
        completedEpochDay: it.completedEpochDay!,
        difficulty: WorkoutDifficulty.hard,
        recordedAtEpochMillis: 0,
      );
    }).toList();

    final insights = WeeklyInsightEngine.generate(
      history: history,
      feedback: feedback,
      todayEpochDay: today,
    );

    expect(insights.any((it) => it is WeeklyInsightDifficultyTrend), isFalse);
    expect(insights.any((it) => it is WeeklyInsightTimeBudgetPattern), isFalse);
  });
}
