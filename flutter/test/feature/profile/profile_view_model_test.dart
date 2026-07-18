import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';

import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/repositories/workout_repository.dart';
import 'package:gym_app/data/repositories/nutrition_repository.dart';
import 'package:gym_app/feature/profile/profile_ui_state.dart';
import 'package:gym_app/feature/profile/profile_view_model.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockNutritionRepository extends Mock implements NutritionRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GymDatabase database;
  late MockWorkoutRepository mockWorkoutRepo;
  late MockNutritionRepository mockNutritionRepo;

  setUpAll(() {
    registerFallbackValue(const NutritionTarget(
      basalCalories: 0,
      maintenanceCalories: 0,
      calories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      audit: NutritionTargetAudit(
        rawBasalCalories: 0,
        rawMaintenanceCalories: 0,
        rawTargetCalories: 0,
        rawProteinGrams: 0,
        rawCarbsGrams: 0,
        rawFatGrams: 0,
      ),
    ));
  });

  setUp(() {
    database = GymDatabase(NativeDatabase.memory());
    mockWorkoutRepo = MockWorkoutRepository();
    mockNutritionRepo = MockNutritionRepository();

    when(() => mockWorkoutRepo.observeActiveGoal())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockNutritionRepo.setTarget(any(), any()))
        .thenAnswer((_) => Future.value());
  });

  tearDown(() async {
    await database.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        gymDatabaseProvider.overrideWithValue(database),
        workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
        nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('default profile is set when database profile is empty', () async {
    final container = createContainer();

    // Verify initial state is loading
    expect(
        container.read(profileNotifierProvider), isA<ProfileUiStateLoading>());

    // Wait for the initialization stream to emit
    await Future.delayed(const Duration(milliseconds: 100));

    final state = container.read(profileNotifierProvider);
    expect(state, isA<ProfileUiStateContent>());
    final content = state as ProfileUiStateContent;
    expect(content.heightCmStr, equals("170"));
    expect(content.currentWeightKgStr, equals("70"));
    expect(content.targetWeightKgStr, equals("65"));
    expect(content.metabolicSex, equals(MetabolicSex.male));
    expect(content.activityLevel, equals(ActivityLevel.moderate));
    expect(content.goalPace, equals(GoalPace.standard));
    expect(content.personalizationConsent, isFalse);
    expect(content.cloudAiConsent, isFalse);
  });

  test('saving valid profile updates DB and registers weight measurement',
      () async {
    final container = createContainer();
    container.read(profileNotifierProvider);
    await Future.delayed(const Duration(milliseconds: 100));

    final notifier = container.read(profileNotifierProvider.notifier);
    notifier.updateHeight("180");
    notifier.updateCurrentWeight("80");
    notifier.updateTargetWeight("75");
    notifier.updatePersonalizationConsent(true);

    notifier.saveProfile();
    await Future.delayed(const Duration(milliseconds: 100));

    final savedProfile = await database.personalizationDao.profileNow();
    expect(savedProfile, isNotNull);
    expect(savedProfile!.heightCm, equals(180.0));
    expect(savedProfile.currentWeightKg, equals(80.0));
    expect(savedProfile.targetWeightKg, equals(75.0));
    expect(savedProfile.personalizationConsent, isTrue);

    // Verify weight logged
    final weights = await database.personalizationDao.weightHistoryNow();
    expect(weights.length, equals(1));
    expect(weights.first.weightKg, equals(80.0));

    // Verify nutrition target calculated and set
    verify(() => mockNutritionRepo.setTarget(any(), any())).called(1);
  });

  test('saving invalid values fails with validation errors', () async {
    final container = createContainer();
    container.read(profileNotifierProvider);
    await Future.delayed(const Duration(milliseconds: 100));

    final notifier = container.read(profileNotifierProvider.notifier);
    notifier.updateHeight("invalid");
    notifier.updateCurrentWeight("-10");

    notifier.saveProfile();
    await Future.delayed(const Duration(milliseconds: 100));

    final state =
        container.read(profileNotifierProvider) as ProfileUiStateContent;
    expect(state.validationErrors, isNotEmpty);
  });
}
