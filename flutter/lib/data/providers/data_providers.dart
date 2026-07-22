import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/catalog/asset_catalog_repository.dart';
import '../../core/motivation/motivation_repository.dart';
import '../local/database.dart';
import '../repositories/settings_repository.dart';
import '../repositories/shared_prefs_settings_repository.dart';
import '../repositories/workout_repository.dart';
import '../repositories/drift_workout_repository.dart';
import '../repositories/nutrition_repository.dart';
import '../repositories/drift_nutrition_repository.dart';
import '../repositories/adaptation_repository.dart';
import '../repositories/drift_adaptation_repository.dart';
import '../repositories/workout_feedback_repository.dart';
import '../repositories/drift_workout_feedback_repository.dart';
import '../repositories/weekly_adaptation_coordinator.dart';
import '../repositories/food_photo_consent_repository.dart';

// Provider cho SharedPreferences, cần override ở ProviderScope lúc khởi chạy
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final foodPhotoConsentRepositoryProvider = Provider<FoodPhotoConsentRepository>((ref) {
  return SharedPrefsFoodPhotoConsentRepository(ref.watch(sharedPreferencesProvider));
});

// Provider cho AssetCatalogRepository, cần override ở ProviderScope sau khi load asset
final assetCatalogRepositoryProvider = Provider<AssetCatalogRepository>((ref) {
  throw UnimplementedError('assetCatalogRepositoryProvider must be overridden');
});

// Provider cho MotivationRepository, cần override ở ProviderScope sau khi load asset
final motivationRepositoryProvider = Provider<MotivationRepository>((ref) {
  throw UnimplementedError('motivationRepositoryProvider must be overridden');
});

// Database Provider
final gymDatabaseProvider = Provider<GymDatabase>((ref) {
  final db = GymDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Settings Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsSettingsRepository(prefs);
});

int? debugMockEpochDay;

// Helper để lấy ngày hiện tại (local timezone epoch day)
int currentLocalEpochDay() {
  if (debugMockEpochDay != null) {
    return debugMockEpochDay!;
  }
  final now = DateTime.now();
  final localDate = DateTime(now.year, now.month, now.day);
  return localDate.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
}

// Workout Repository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  final catalogRepo = ref.watch(assetCatalogRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);

  return DriftWorkoutRepository(
    database: database,
    exercisesProvider: () => catalogRepo.exercises,
    settingsRepository: settingsRepo,
    currentEpochDay: currentLocalEpochDay,
  );
});

// Nutrition Repository
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  return DriftNutritionRepository(
    database: database,
    prefs: prefs,
    todayEpochDay: currentLocalEpochDay,
    nowEpochMillis: () => DateTime.now().millisecondsSinceEpoch,
  );
});

// Adaptation Repository
final adaptationRepositoryProvider = Provider<AdaptationRepository>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);

  return DriftAdaptationRepository(
    database: database,
    nutritionRepository: nutritionRepo,
    nowEpochMillis: () => DateTime.now().millisecondsSinceEpoch,
    todayEpochDay: currentLocalEpochDay,
  );
});

// Workout Feedback Repository
final workoutFeedbackRepositoryProvider = Provider<WorkoutFeedbackRepository>((ref) {
  final database = ref.watch(gymDatabaseProvider);

  return DriftWorkoutFeedbackRepository(
    database: database,
    nowEpochMillis: () => DateTime.now().millisecondsSinceEpoch,
  );
});

// Weekly Snapshot Provider
final weeklySnapshotProvider = Provider<WeeklySnapshotProvider>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final feedbackRepo = ref.watch(workoutFeedbackRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);

  return DriftWeeklySnapshotProvider(
    database: database,
    workoutRepository: workoutRepo,
    feedbackRepository: feedbackRepo,
    nutritionRepository: nutritionRepo,
    nowEpochMillis: () => DateTime.now().millisecondsSinceEpoch,
  );
});

// Weekly Adaptation Coordinator
final weeklyAdaptationCoordinatorProvider = Provider<WeeklyAdaptationCoordinator>((ref) {
  final snapshotProv = ref.watch(weeklySnapshotProvider);
  final adaptationRepo = ref.watch(adaptationRepositoryProvider);

  return WeeklyAdaptationCoordinator(
    snapshotProvider: snapshotProv,
    adaptationRepository: adaptationRepo,
  );
});
