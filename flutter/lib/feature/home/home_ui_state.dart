class HomeUiState {
  final int epochDay;
  final String? workoutTitle;
  final String? workoutFocus;
  final int? durationMinutes;
  final int completedExercises;
  final int totalExercises;
  final int completedThisWeek;
  final int streakDays;
  final int caloriesConsumed;
  final int? caloriesTarget;
  final String dailyQuote;

  const HomeUiState({
    this.epochDay = 0,
    this.workoutTitle,
    this.workoutFocus,
    this.durationMinutes,
    this.completedExercises = 0,
    this.totalExercises = 0,
    this.completedThisWeek = 0,
    this.streakDays = 0,
    this.caloriesConsumed = 0,
    this.caloriesTarget,
    this.dailyQuote = "",
  });

  HomeUiState copyWith({
    int? epochDay,
    String? workoutTitle,
    String? workoutFocus,
    int? durationMinutes,
    int? completedExercises,
    int? totalExercises,
    int? completedThisWeek,
    int? streakDays,
    int? caloriesConsumed,
    int? caloriesTarget,
    String? dailyQuote,
  }) {
    return HomeUiState(
      epochDay: epochDay ?? this.epochDay,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      workoutFocus: workoutFocus ?? this.workoutFocus,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completedExercises: completedExercises ?? this.completedExercises,
      totalExercises: totalExercises ?? this.totalExercises,
      completedThisWeek: completedThisWeek ?? this.completedThisWeek,
      streakDays: streakDays ?? this.streakDays,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      dailyQuote: dailyQuote ?? this.dailyQuote,
    );
  }
}
