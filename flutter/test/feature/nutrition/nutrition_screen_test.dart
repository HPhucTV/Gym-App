import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/catalog/asset_catalog_repository.dart';
import 'package:gym_app/core/model/profile_models.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/repositories/drift_nutrition_repository.dart';
import 'package:gym_app/feature/nutrition/nutrition_screen.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_flow_screen.dart';
import 'package:gym_app/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCatalog extends Mock implements AssetCatalogRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'nutrition entry offers photos and manual entry without barcode UI',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = GymDatabase(NativeDatabase.memory());
    final catalog = _MockCatalog();
    when(() => catalog.exercises).thenReturn([]);
    final repository = DriftNutritionRepository(
      database: database,
      prefs: prefs,
      todayEpochDay: () => 20000,
      nowEpochMillis: () => 20000 * 86400000,
    );
    await database.personalizationDao.upsertProfile(PersonalProfileData(
      id: 1,
      birthDateEpochDay: 10000,
      metabolicSex: MetabolicSex.male,
      heightCm: 175,
      currentWeightKg: 70,
      targetWeightKg: 70,
      activityLevel: ActivityLevel.moderate,
      goalPace: GoalPace.standard,
      personalizationConsent: true,
      cloudAiConsent: true,
      updatedAtEpochMillis: 0,
    ));

    var profileCalls = 0;
    var flowCalls = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        gymDatabaseProvider.overrideWithValue(database),
        assetCatalogRepositoryProvider.overrideWithValue(catalog),
        nutritionRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: getGymLightTheme(),
        home: NutritionScreen(
          onOpenProfile: () => profileCalls++,
          launchFoodPhotoFlow: (_) async {
            flowCalls++;
            return const FoodPhotoFlowResult.openProfile();
          },
        ),
      ),
    ));
    for (var i = 0;
        i < 20 &&
            find
                .byKey(const Key('food-photo-primary-action'))
                .evaluate()
                .isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('food-photo-primary-action')), findsOneWidget);
    expect(find.textContaining('Chụp món ăn'), findsOneWidget);
    expect(find.text('Nhập tay'), findsOneWidget);
    expect(find.textContaining('Quét mã vạch'), findsNothing);

    await tester
        .ensureVisible(find.byKey(const Key('food-photo-primary-action')));
    await tester.tap(find.byKey(const Key('food-photo-primary-action')));
    await tester.pump();
    expect(flowCalls, 1);
    expect(profileCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await database.close();
  });
}
