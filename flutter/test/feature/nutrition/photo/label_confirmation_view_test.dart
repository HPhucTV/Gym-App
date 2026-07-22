import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';
import 'package:gym_app/feature/nutrition/photo/label_confirmation_view.dart';

void main() {
  testWidgets('label review requires basis and consumed amount',
      (tester) async {
    const draft = FoodPhotoLabelDraft(
      nameVi: 'Sữa',
      basis: LabelBasis.unknown,
      calories: 100,
      proteinGrams: 3,
      carbsGrams: 10,
      fatGrams: 2,
      servingSizeGrams: null,
      consumed: null,
    );
    await tester.pumpWidget(MaterialApp(
      home: LabelConfirmationView(draft: draft, onConfirm: () {}),
    ));
    expect(find.byKey(const Key('label-basis-per-100g')), findsOneWidget);
    expect(find.byKey(const Key('label-calories')), findsOneWidget);
    expect(find.byKey(const Key('label-consumed-amount')), findsOneWidget);
    final button = tester
        .widget<FilledButton>(find.byKey(const Key('food-analysis-confirm')));
    expect(button.onPressed, isNull);
  });
}
