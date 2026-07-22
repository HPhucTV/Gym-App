import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';
import 'package:gym_app/feature/nutrition/photo/meal_confirmation_view.dart';

void main() {
  testWidgets('meal review renders only catalog-advertised portions',
      (tester) async {
    final draft = FoodPhotoMealDraft(nameVi: 'Cơm', components: const [
      FoodPhotoMealComponentDraft(
        observationId: 'rice',
        foodId: 'rice',
        nameVi: 'Cơm trắng',
        portion: null,
        requiresManualPortion: true,
        manualPortionCompleted: false,
      )
    ]);
    final catalog = KnownFoodOption.listFromJson({
      'foods': [
        {
          'foodId': 'rice',
          'nameVi': 'Cơm trắng',
          'supportsGrams': true,
          'portionOptions': [
            {
              'unit': 'BOWL',
              'sizes': ['MEDIUM']
            }
          ]
        }
      ]
    });
    await tester.pumpWidget(MaterialApp(
      home: MealConfirmationView(
          draft: draft, catalog: catalog, onConfirm: () {}),
    ));

    expect(find.byKey(const Key('meal-component-rice')), findsOneWidget);
    expect(find.byKey(const Key('portion-household-rice')), findsOneWidget);
    expect(find.textContaining('1 bát'), findsOneWidget);
    expect(find.byKey(const Key('portion-grams-rice')), findsOneWidget);
  });

  testWidgets('catalog unavailable does not invent grams for direct-unit food',
      (tester) async {
    final draft = FoodPhotoMealDraft(nameVi: 'Trứng', components: const [
      FoodPhotoMealComponentDraft(
        observationId: 'egg',
        foodId: 'egg',
        nameVi: 'Trứng',
        portion: null,
        requiresManualPortion: true,
        manualPortionCompleted: false,
      )
    ]);
    await tester.pumpWidget(MaterialApp(
      home: MealConfirmationView(draft: draft, onConfirm: () {}),
    ));

    expect(find.byKey(const Key('portion-grams-egg')), findsNothing);
    expect(find.byKey(const Key('portion-household-egg')), findsNothing);
    expect(find.byKey(const Key('known-food-catalog-retry')), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('food-analysis-confirm')))
            .onPressed,
        isNull);
  });
}
