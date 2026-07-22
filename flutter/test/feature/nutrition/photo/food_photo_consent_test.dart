import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/providers/remote_providers.dart';
import 'package:gym_app/data/remote/food_analysis_client.dart';
import 'package:gym_app/data/repositories/nutrition_repository.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_notifier.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generic cloud consent cannot authorize photos; dedicated consent can',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = GymDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.personalizationDao.upsertProfile(PersonalProfileData(
      id: 1,
      birthDateEpochDay: 0,
      metabolicSex: MetabolicSex.male,
      heightCm: 170,
      currentWeightKg: 70,
      targetWeightKg: 65,
      activityLevel: ActivityLevel.moderate,
      goalPace: GoalPace.standard,
      personalizationConsent: true,
      cloudAiConsent: true,
      updatedAtEpochMillis: 1,
    ));
    final client = _NoopClient();
    final container = ProviderContainer(overrides: [
      gymDatabaseProvider.overrideWithValue(database),
      sharedPreferencesProvider.overrideWithValue(preferences),
      foodAnalysisClientProvider.overrideWithValue(client),
      nutritionRepositoryProvider.overrideWithValue(_NoopRepository()),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(
      foodPhotoNotifierProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final notifier = container.read(foodPhotoNotifierProvider.notifier);
    expect(await notifier.requestPrimaryCapture(), isNull);
    expect(container.read(foodPhotoNotifierProvider),
        isA<FoodPhotoConsentRequired>());
    expect(client.startCalls, 0);

    await container.read(foodPhotoConsentRepositoryProvider).setConsent(true);
    notifier.reset();
    expect(await notifier.requestPrimaryCapture(), isNotNull);
    expect(
        container.read(foodPhotoNotifierProvider), isA<FoodPhotoCapturing>());
    expect(client.startCalls, 0,
        reason: 'consent opens capture but does not upload before a photo');

    await container.read(foodPhotoConsentRepositoryProvider).setConsent(false);
    notifier.reset();
    expect(await notifier.requestPrimaryCapture(), isNull);
    expect(container.read(foodPhotoNotifierProvider),
        isA<FoodPhotoConsentRequired>());
  });
}

final class _NoopClient implements FoodAnalysisClient {
  int startCalls = 0;

  @override
  Future<FoodAnalysisReview> startPhotoAnalysis(PreparedUpload upload) {
    startCalls++;
    throw UnsupportedError('not reached');
  }

  @override
  void cancelPending() {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused client member');
}

final class _NoopRepository implements NutritionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused repository member');
}
