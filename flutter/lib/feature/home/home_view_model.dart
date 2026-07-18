import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/workout_models.dart';
import '../../core/model/nutrition_models.dart';
import '../../data/providers/data_providers.dart';
import 'home_ui_state.dart';

final currentWorkoutStreamProvider = StreamProvider<WorkoutSession?>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.observeCurrentWorkout();
});

final completedWorkoutsStreamProvider =
    StreamProvider<List<CompletedWorkout>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.observeCompletedWorkouts();
});

final nutritionDayStreamProvider = StreamProvider<NutritionDay>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  final epochDay = currentLocalEpochDay();
  return repo.observeDay(epochDay);
});

final homeUiStateProvider = Provider<AsyncValue<HomeUiState>>((ref) {
  final currentWorkoutAsync = ref.watch(currentWorkoutStreamProvider);
  final completedWorkoutsAsync = ref.watch(completedWorkoutsStreamProvider);
  final nutritionDayAsync = ref.watch(nutritionDayStreamProvider);
  final motivationRepo = ref.watch(motivationRepositoryProvider);

  if (currentWorkoutAsync.hasError) {
    return AsyncValue.error(
        currentWorkoutAsync.error!, currentWorkoutAsync.stackTrace!);
  }
  if (completedWorkoutsAsync.hasError) {
    return AsyncValue.error(
        completedWorkoutsAsync.error!, completedWorkoutsAsync.stackTrace!);
  }
  if (nutritionDayAsync.hasError) {
    return AsyncValue.error(
        nutritionDayAsync.error!, nutritionDayAsync.stackTrace!);
  }

  if (currentWorkoutAsync.isLoading ||
      completedWorkoutsAsync.isLoading ||
      nutritionDayAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final currentWorkout = currentWorkoutAsync.value;
  final completedWorkouts = completedWorkoutsAsync.value ?? [];
  final nutritionDay = nutritionDayAsync.value!;

  final epochDay = currentLocalEpochDay();
  final quote = motivationRepo.getDailyQuote(epochDay: epochDay);

  final homeUiState = mapHomeUiState(
    epochDay,
    currentWorkout,
    completedWorkouts,
    nutritionDay,
    quote,
  );

  return AsyncValue.data(homeUiState);
});

HomeUiState mapHomeUiState(
  int epochDay,
  WorkoutSession? workout,
  List<CompletedWorkout> completed,
  NutritionDay nutrition,
  String dailyQuote,
) {
  final today =
      DateTime.fromMillisecondsSinceEpoch(epochDay * 24 * 60 * 60 * 1000);
  final daysToSubtract = today.weekday - 1; // 0 for Monday, 6 for Sunday
  final monday = today.subtract(Duration(days: daysToSubtract));
  final weekStart = monday.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);

  final daysToAdd = 7 - today.weekday;
  final sunday = today.add(Duration(days: daysToAdd));
  final weekEnd = sunday.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);

  final completedDays = completed.map((e) => e.completedEpochDay).toSet();

  int streakCursor = completedDays.contains(epochDay) ? epochDay : epochDay - 1;
  int streakDays = 0;
  while (completedDays.contains(streakCursor)) {
    streakDays++;
    streakCursor--;
  }

  final totalExercises = workout?.exercises.length ?? 0;
  final completedExercises =
      workout?.exercises.where((e) => e.isChecked).length ?? 0;

  final completedThisWeek = completed
      .where((e) =>
          e.completedEpochDay >= weekStart && e.completedEpochDay <= weekEnd)
      .length;

  return HomeUiState(
    epochDay: epochDay,
    workoutTitle: workout?.titleVi,
    workoutFocus: workout?.focusVi,
    durationMinutes: workout?.estimatedMinutes,
    completedExercises: completedExercises,
    totalExercises: totalExercises,
    completedThisWeek: completedThisWeek,
    streakDays: streakDays,
    caloriesConsumed: nutrition.consumed.calories,
    caloriesTarget: nutrition.target?.calories,
    dailyQuote: dailyQuote,
  );
}
