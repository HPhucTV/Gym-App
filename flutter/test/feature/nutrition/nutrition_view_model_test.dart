import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/core/catalog/asset_catalog_repository.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/providers/remote_providers.dart';
import 'package:gym_app/data/remote/food_analysis_client.dart';
import 'package:gym_app/data/repositories/drift_workout_repository.dart';
import 'package:gym_app/data/repositories/shared_prefs_settings_repository.dart';
import 'package:gym_app/data/repositories/drift_nutrition_repository.dart';

import 'package:gym_app/feature/nutrition/nutrition_ui_state.dart';
import 'package:gym_app/feature/nutrition/nutrition_view_model.dart';

class MockAssetCatalogRepository extends Mock
    implements AssetCatalogRepository {}

class MockFoodAnalysisClient extends Mock implements FoodAnalysisClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GymDatabase database;
  late SharedPreferences prefs;
  late MockAssetCatalogRepository mockAssetCatalogRepo;
  late MockFoodAnalysisClient mockFoodAnalysisClient;

  late DriftWorkoutRepository workoutRepo;
  late DriftNutritionRepository nutritionRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    database = GymDatabase(NativeDatabase.memory());
    mockAssetCatalogRepo = MockAssetCatalogRepository();
    mockFoodAnalysisClient = MockFoodAnalysisClient();

    when(() => mockAssetCatalogRepo.exercises).thenReturn([]);

    workoutRepo = DriftWorkoutRepository(
      database: database,
      exercisesProvider: () => mockAssetCatalogRepo.exercises,
      settingsRepository: SharedPrefsSettingsRepository(prefs),
      currentEpochDay: () => 18000,
    );

    nutritionRepo = DriftNutritionRepository(
      database: database,
      prefs: prefs,
      todayEpochDay: () => 18000,
      nowEpochMillis: () => 18000 * 24 * 60 * 60 * 1000,
    );
  });

  tearDown(() async {
    await database.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        gymDatabaseProvider.overrideWithValue(database),
        assetCatalogRepositoryProvider.overrideWithValue(mockAssetCatalogRepo),
        workoutRepositoryProvider.overrideWithValue(workoutRepo),
        nutritionRepositoryProvider.overrideWithValue(nutritionRepo),
        foodAnalysisClientProvider.overrideWithValue(mockFoodAnalysisClient),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('Initial state transitions from Loading to Content when subscribed',
      () async {
    final container = createContainer();

    // Verify initial state is loading
    expect(container.read(nutritionNotifierProvider), isA<NutritionLoading>());

    // Add profile data so target calculation can proceed
    await database.personalizationDao.upsertProfile(
      PersonalProfileData(
        id: 1,
        birthDateEpochDay: 18000 - (365 * 25),
        metabolicSex: MetabolicSex.male,
        heightCm: 175.0,
        currentWeightKg: 75.0,
        targetWeightKg: 75.0,
        activityLevel: ActivityLevel.moderate,
        goalPace: GoalPace.standard,
        personalizationConsent: true,
        cloudAiConsent: true,
        updatedAtEpochMillis: 0,
      ),
    );

    // Let the streams emit
    await Future.delayed(const Duration(milliseconds: 100));

    final state = container.read(nutritionNotifierProvider);
    expect(state, isA<NutritionContent>());
    final content = state as NutritionContent;
    expect(content.waterIntakeMl, equals(0));
    expect(content.caloriesEaten, equals(0));
  });

  test('addWater adds water correctly', () async {
    final container = createContainer();

    // Setup initial profile
    await database.personalizationDao.upsertProfile(
      PersonalProfileData(
        id: 1,
        birthDateEpochDay: 18000 - (365 * 25),
        metabolicSex: MetabolicSex.male,
        heightCm: 175.0,
        currentWeightKg: 75.0,
        targetWeightKg: 75.0,
        activityLevel: ActivityLevel.moderate,
        goalPace: GoalPace.standard,
        personalizationConsent: true,
        cloudAiConsent: true,
        updatedAtEpochMillis: 0,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // Update water intake
    await container.read(nutritionNotifierProvider.notifier).addWater(250);

    // Give database time to flush and stream to emit
    await Future.delayed(const Duration(milliseconds: 100));

    final state = container.read(nutritionNotifierProvider) as NutritionContent;
    expect(state.waterIntakeMl, equals(250));
  });

  test('startManualEntry opens a draft entry', () async {
    final container = createContainer();

    // Setup initial profile
    await database.personalizationDao.upsertProfile(
      PersonalProfileData(
        id: 1,
        birthDateEpochDay: 18000 - (365 * 25),
        metabolicSex: MetabolicSex.male,
        heightCm: 175.0,
        currentWeightKg: 75.0,
        targetWeightKg: 75.0,
        activityLevel: ActivityLevel.moderate,
        goalPace: GoalPace.standard,
        personalizationConsent: true,
        cloudAiConsent: true,
        updatedAtEpochMillis: 0,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    container.read(nutritionNotifierProvider.notifier).startManualEntry();

    final state = container.read(nutritionNotifierProvider) as NutritionContent;
    expect(state.draft, isNotNull);
    expect(state.draft!.nameVi, isEmpty);
  });
}
