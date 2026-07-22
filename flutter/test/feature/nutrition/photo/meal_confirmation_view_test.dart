import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';
import 'package:gym_app/feature/nutrition/photo/meal_confirmation_view.dart';

void main() {
  testWidgets('meal review exposes familiar portions and editing keys',
      (tester) async {
    final draft = FoodPhotoMealDraft(
      nameVi: 'Cơm',
      components: [
        const FoodPhotoMealComponentDraft(
          observationId: 'rice',
          foodId: 'rice',
          nameVi: 'Cơm trắng',
          portion: null,
          requiresManualPortion: true,
          manualPortionCompleted: false,
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: MealConfirmationView(draft: draft, onConfirm: () {}),
    ));
    expect(find.byKey(const Key('meal-component-rice')), findsOneWidget);
    expect(find.byKey(const Key('portion-household-rice')), findsOneWidget);
    expect(find.text('1 bát'), findsOneWidget);
    expect(find.byKey(const Key('portion-grams-rice')), findsOneWidget);
    expect(find.byKey(const Key('food-analysis-confirm')), findsOneWidget);
  });
}
