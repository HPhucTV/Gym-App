import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_app/core/model/workout_models.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/motivation/motivation_repository.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/repositories/workout_repository.dart';
import 'package:gym_app/data/repositories/nutrition_repository.dart';
import 'package:gym_app/feature/home/home_view_model.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockNutritionRepository extends Mock implements NutritionRepository {}

class MockMotivationRepository extends Mock implements MotivationRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mapHomeUiState', () {
    const dailyQuote = "Hãy tiếp tục cố gắng!";

    // helper to parse yyyy-MM-dd to epochDay
    int day(String dateStr) {
      return DateTime.parse(dateStr).millisecondsSinceEpoch ~/
          (24 * 60 * 60 * 1000);
    }

    WorkoutSession session(
        {required List<bool> checked, required int epochDay}) {
      return WorkoutSession(
        id: 10,
        goalId: 1,
        sequenceIndex: 0,
        titleVi: "Toàn thân A",
        focusVi: "Toàn thân",
        estimatedMinutes: 42,
        dueEpochDay: epochDay,
        exercises: checked
            .map((c) => WorkoutExercise(
                  orderIndex: 0,
                  exerciseId: "ex",
                  prescription: const ExercisePrescription(
                      exerciseId: "ex",
                      sets: 3,
                      minReps: 8,
                      maxReps: 12,
                      restSeconds: 60),
                  isChecked: c,
                ))
            .toList(),
      );
    }

    NutritionTarget target(int calories) {
      return NutritionTarget(
        basalCalories: 1600,
        maintenanceCalories: 2200,
        calories: calories,
        proteinGrams: 130,
        carbsGrams: 240,
        fatGrams: 65,
        audit: NutritionTargetAudit(
          rawBasalCalories: 1600.0,
          rawMaintenanceCalories: 2200.0,
          rawTargetCalories: calories.toDouble(),
          rawProteinGrams: 130.0,
          rawCarbsGrams: 240.0,
          rawFatGrams: 65.0,
        ),
      );
    }

    test('maps current workout and nutrition without fabricated values', () {
      final today = day("2026-07-02"); // Thursday

      final state = mapHomeUiState(
        today,
        session(checked: [true, false, true], epochDay: today),
        [],
        NutritionDay(
          epochDay: today,
          consumed: const Nutrients(calories: 1240),
          target: target(2100),
        ),
        dailyQuote,
      );

      expect(state.workoutTitle, equals("Toàn thân A"));
      expect(state.workoutFocus, equals("Toàn thân"));
      expect(state.durationMinutes, equals(42));
      expect(state.completedExercises, equals(2));
      expect(state.totalExercises, equals(3));
      expect(state.caloriesConsumed, equals(1240));
      expect(state.caloriesTarget, equals(2100));
      expect(state.dailyQuote, equals(dailyQuote));
    });

    test('maps missing workout and nutrition target as empty data', () {
      final today = day("2026-07-02");

      final state = mapHomeUiState(
        today,
        null,
        [],
        NutritionDay(
          epochDay: today,
          consumed: const Nutrients(),
          target: null,
        ),
        dailyQuote,
      );

      expect(state.workoutTitle, isNull);
      expect(state.workoutFocus, isNull);
      expect(state.durationMinutes, isNull);
      expect(state.caloriesTarget, isNull);
      expect(state.completedExercises, equals(0));
      expect(state.totalExercises, equals(0));
      expect(state.completedThisWeek, equals(0));
      expect(state.streakDays, equals(0));
    });

    test('counts only completions in the current monday to sunday week', () {
      final today = day("2026-07-02"); // Thursday
      // Monday of this week is 2026-06-29, Sunday is 2026-07-05
      final history = [
        "2026-06-28", // Sunday previous week
        "2026-06-29", // Monday this week
        "2026-07-01", // Wednesday this week
        "2026-07-05", // Sunday this week
        "2026-07-06", // Monday next week
      ]
          .map((d) => CompletedWorkout(goalId: 1, completedEpochDay: day(d)))
          .toList();

      final state = mapHomeUiState(
        today,
        null,
        history,
        NutritionDay(
          epochDay: today,
          consumed: const Nutrients(),
          target: null,
        ),
        dailyQuote,
      );

      expect(state.completedThisWeek, equals(3));
    });

    test('daily streak continues from yesterday and ignores duplicate sessions',
        () {
      final today = day("2026-07-02"); // Thursday
      final history = [
        "2026-06-28",
        "2026-06-29",
        "2026-06-30",
        "2026-07-01",
        "2026-07-01", // Duplicate on Wednesday
      ]
          .map((d) => CompletedWorkout(goalId: 1, completedEpochDay: day(d)))
          .toList();

      final state = mapHomeUiState(
        today,
        null,
        history,
        NutritionDay(
          epochDay: today,
          consumed: const Nutrients(),
          target: null,
        ),
        dailyQuote,
      );

      expect(state.streakDays, equals(4));
    });
  });

  group('homeUiStateProvider integration', () {
    late MockWorkoutRepository mockWorkoutRepo;
    late MockNutritionRepository mockNutritionRepo;
    late MockMotivationRepository mockMotivationRepo;

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      mockNutritionRepo = MockNutritionRepository();
      mockMotivationRepo = MockMotivationRepository();

      when(() => mockMotivationRepo.getDailyQuote(
          epochDay: any(named: 'epochDay'))).thenReturn("Quote");
    });

    ProviderContainer createContainer({
      required Stream<WorkoutSession?> workoutStream,
      required Stream<List<CompletedWorkout>> completedStream,
      required Stream<NutritionDay> nutritionStream,
    }) {
      when(() => mockWorkoutRepo.observeCurrentWorkout())
          .thenAnswer((_) => workoutStream);
      when(() => mockWorkoutRepo.observeCompletedWorkouts())
          .thenAnswer((_) => completedStream);
      when(() => mockNutritionRepo.observeDay(any()))
          .thenAnswer((_) => nutritionStream);

      return ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
          nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
          motivationRepositoryProvider.overrideWithValue(mockMotivationRepo),
        ],
      );
    }

    test('emits loading state when streams are loading', () {
      final container = createContainer(
        workoutStream: const Stream.empty(),
        completedStream: const Stream.empty(),
        nutritionStream: const Stream.empty(),
      );

      final stateAsync = container.read(homeUiStateProvider);
      expect(stateAsync.isLoading, isTrue);
    });

    test('emits data when all streams emit values', () async {
      final today = currentLocalEpochDay();
      final session = WorkoutSession(
        id: 10,
        goalId: 1,
        sequenceIndex: 0,
        titleVi: "Tập luyện",
        focusVi: "Toàn thân",
        estimatedMinutes: 45,
        dueEpochDay: today,
        exercises: const [],
      );

      final container = createContainer(
        workoutStream: Stream.value(session),
        completedStream: Stream.value([]),
        nutritionStream: Stream.value(NutritionDay(
          epochDay: today,
          consumed: const Nutrients(calories: 500),
          target: null,
        )),
      );

      // Establish active listener to keep subscriptions alive
      final subscription =
          container.listen(homeUiStateProvider, (prev, next) {});

      // Wait for async stream events to be dispatched
      await Future.delayed(const Duration(milliseconds: 50));

      final stateAsync = container.read(homeUiStateProvider);
      subscription.close();

      expect(stateAsync.hasValue, isTrue);
      final value = stateAsync.value!;
      expect(value.workoutTitle, equals("Tập luyện"));
      expect(value.caloriesConsumed, equals(500));
      expect(value.dailyQuote, equals("Quote"));
    });

    test('propagates error when any stream fails', () async {
      final container = createContainer(
        workoutStream: Stream.error(Exception("Workout Error")),
        completedStream: Stream.value([]),
        nutritionStream: Stream.value(NutritionDay(
          epochDay: currentLocalEpochDay(),
          consumed: const Nutrients(),
          target: null,
        )),
      );

      final subscription =
          container.listen(homeUiStateProvider, (prev, next) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final stateAsync = container.read(homeUiStateProvider);
      subscription.close();

      expect(stateAsync.hasError, isTrue);
      expect(stateAsync.error.toString(), contains("Workout Error"));
    });
  });
}
