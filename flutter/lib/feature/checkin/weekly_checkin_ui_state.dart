class CheckInHistorySummary {
  final double? weightChangeKg;
  final double averageRecovery;
  final double averageSleep;
  final int totalCheckIns;
  final double averageWeeklyCalories;
  final double averageWeeklyScore;
  final double averageWeeklyProtein;
  final double averageWeeklyCarbs;
  final double averageWeeklyFat;

  const CheckInHistorySummary({
    this.weightChangeKg,
    this.averageRecovery = 0.0,
    this.averageSleep = 0.0,
    this.totalCheckIns = 0,
    this.averageWeeklyCalories = 0.0,
    this.averageWeeklyScore = 0.0,
    this.averageWeeklyProtein = 0.0,
    this.averageWeeklyCarbs = 0.0,
    this.averageWeeklyFat = 0.0,
  });

  CheckInHistorySummary copyWith({
    double? weightChangeKg,
    double? averageRecovery,
    double? averageSleep,
    int? totalCheckIns,
    double? averageWeeklyCalories,
    double? averageWeeklyScore,
    double? averageWeeklyProtein,
    double? averageWeeklyCarbs,
    double? averageWeeklyFat,
  }) {
    return CheckInHistorySummary(
      weightChangeKg: weightChangeKg ?? this.weightChangeKg,
      averageRecovery: averageRecovery ?? this.averageRecovery,
      averageSleep: averageSleep ?? this.averageSleep,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      averageWeeklyCalories: averageWeeklyCalories ?? this.averageWeeklyCalories,
      averageWeeklyScore: averageWeeklyScore ?? this.averageWeeklyScore,
      averageWeeklyProtein: averageWeeklyProtein ?? this.averageWeeklyProtein,
      averageWeeklyCarbs: averageWeeklyCarbs ?? this.averageWeeklyCarbs,
      averageWeeklyFat: averageWeeklyFat ?? this.averageWeeklyFat,
    );
  }
}

sealed class WeeklyCheckInUiState {}

class WeeklyCheckInLoading extends WeeklyCheckInUiState {}

class WeeklyCheckInNoProfile extends WeeklyCheckInUiState {}

class WeeklyCheckInInput extends WeeklyCheckInUiState {
  final String weightKgStr;
  final int energy;
  final int hunger;
  final int recovery;
  final int sleepQuality;
  final String note;
  final bool isSubmitting;
  final String? error;
  final bool success;
  final List<String> validationErrors;
  final CheckInHistorySummary historySummary;

  WeeklyCheckInInput({
    required this.weightKgStr,
    required this.energy,
    required this.hunger,
    required this.recovery,
    required this.sleepQuality,
    required this.note,
    this.isSubmitting = false,
    this.error,
    this.success = false,
    this.validationErrors = const [],
    this.historySummary = const CheckInHistorySummary(),
  });
}
