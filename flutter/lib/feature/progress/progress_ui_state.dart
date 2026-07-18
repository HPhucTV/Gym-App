import '../../core/model/catalog_models.dart';
import '../../core/progress/weekly_insight_engine.dart';
import '../../core/progress/goal_forecast_calculator.dart';
import '../../data/local/database.dart';
import '../../core/progress/progress_calculator.dart';

enum WeightFilter {
  last7Days(7),
  last30Days(30),
  last90Days(90);

  final int days;
  const WeightFilter(this.days);
}

class WeeklyCompletedStats {
  final String weekLabel;
  final int count;

  const WeeklyCompletedStats({
    required this.weekLabel,
    required this.count,
  });
}

class MuscleCompletedStats {
  final MuscleGroup muscleGroup;
  final int count;

  const MuscleCompletedStats({
    required this.muscleGroup,
    required this.count,
  });
}

sealed class ProgressUiState {
  const ProgressUiState();
}

class ProgressUiStateLoading extends ProgressUiState {
  const ProgressUiStateLoading();
}

class ProgressUiStateContent extends ProgressUiState {
  final int percentage;
  final int completedActive;
  final int totalActive;
  final int weeklyStreak;
  final int targetPerWeek;
  final YearMonth selectedMonth;
  final Set<int> markedEpochDays;
  final int completedInMonth;
  final bool canNavigatePrevious;
  final bool canNavigateNext;
  final List<WeeklyCompletedStats> weeklyStats;
  final List<MuscleCompletedStats> muscleStats;
  final List<WeeklyInsight> weeklyInsights;
  final GoalForecast goalForecast;
  final int forecastCompletedSessions;
  final int forecastElapsedWeeks;
  final List<WeightMeasurement> weightHistory;
  final WeightFilter weightFilter;
  final Set<int> allCompletedDates;

  const ProgressUiStateContent({
    required this.percentage,
    required this.completedActive,
    required this.totalActive,
    required this.weeklyStreak,
    required this.targetPerWeek,
    required this.selectedMonth,
    required this.markedEpochDays,
    required this.completedInMonth,
    required this.canNavigatePrevious,
    required this.canNavigateNext,
    required this.weeklyStats,
    required this.muscleStats,
    required this.weeklyInsights,
    required this.goalForecast,
    required this.forecastCompletedSessions,
    required this.forecastElapsedWeeks,
    required this.weightHistory,
    required this.weightFilter,
    required this.allCompletedDates,
  });
}

class ProgressUiStateNoActiveGoal extends ProgressUiState {
  final YearMonth selectedMonth;
  final Set<int> markedEpochDays;
  final int completedInMonth;
  final bool canNavigatePrevious;
  final bool canNavigateNext;
  final List<WeeklyCompletedStats> weeklyStats;
  final List<MuscleCompletedStats> muscleStats;
  final List<WeightMeasurement> weightHistory;
  final WeightFilter weightFilter;
  final Set<int> allCompletedDates;

  const ProgressUiStateNoActiveGoal({
    required this.selectedMonth,
    required this.markedEpochDays,
    required this.completedInMonth,
    required this.canNavigatePrevious,
    required this.canNavigateNext,
    required this.weeklyStats,
    required this.muscleStats,
    required this.weightHistory,
    required this.weightFilter,
    required this.allCompletedDates,
  });
}
