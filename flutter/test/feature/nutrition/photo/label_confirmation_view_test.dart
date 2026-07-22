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

  testWidgets('preserves decimal editing and exposes package metadata',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _EditingHarness()));

    expect(
        find.byKey(const Key('label-servings-per-container')), findsOneWidget);
    expect(find.byKey(const Key('label-net-weight')), findsOneWidget);
    await tester.showKeyboard(find.byKey(const Key('label-calories')));
    await tester.enterText(find.byKey(const Key('label-calories')), '1.');
    await tester.pump();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('label-calories')))
            .controller!
            .text,
        '1.');
    expect(find.text('Kiểm tra lại giá trị này'), findsOneWidget);
  });
}

class _EditingHarness extends StatefulWidget {
  const _EditingHarness();

  @override
  State<_EditingHarness> createState() => _EditingHarnessState();
}

class _EditingHarnessState extends State<_EditingHarness> {
  late FoodPhotoLabelDraft draft = FoodPhotoLabelDraft(
    nameVi: 'Sữa',
    basis: LabelBasis.per100g,
    calories: 100,
    proteinGrams: 3,
    carbsGrams: 10,
    fatGrams: 2,
    servingSizeGrams: null,
    servingsPerContainer: 2,
    netWeightGrams: 180,
    consumed: LabelConsumedAmount(kind: LabelConsumedKind.grams, amount: 180),
  );

  @override
  Widget build(BuildContext context) => LabelConfirmationView(
        draft: draft,
        fieldErrorPath:
            const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.calories),
        onFactsChanged: ({calories, proteinGrams, carbsGrams, fatGrams}) {
          setState(() {
            draft = draft.copyWith(
              calories: calories,
              proteinGrams: proteinGrams,
              carbsGrams: carbsGrams,
              fatGrams: fatGrams,
            );
          });
        },
        onConfirm: () {},
      );
}
