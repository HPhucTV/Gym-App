import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';
import 'package:gym_app/feature/nutrition/photo/nutrition_estimate_view.dart';

void main() {
  testWidgets('estimate shows ranges confidence reasons and disclaimer',
      (tester) async {
    final result = FoodPhotoEstimateResult(
      imageType: FoodImageType.meal,
      nameVi: 'Cơm gà',
      estimate: NutritionEstimate(
        calories: NutritionRange(min: 400, mid: 500, max: 650),
        proteinGrams: NutritionRange(min: 20, mid: 25, max: 35),
        carbsGrams: NutritionRange(min: 45, mid: 55, max: 70),
        fatGrams: NutritionRange(min: 8, mid: 12, max: 20),
      ),
      confidenceLevel: AnalysisConfidenceLevel.medium,
      uncertaintyReasons: const [FoodUncertaintyReason.hiddenOil],
      calculationSummary: 'Theo khẩu phần đã xác nhận.',
    );
    await tester.pumpWidget(MaterialApp(
      home: NutritionEstimateView(
          result: result, stable: false, onSave: () {}, onEdit: () {}),
    ));
    expect(find.textContaining('400'), findsOneWidget);
    expect(find.textContaining('650'), findsOneWidget);
    expect(find.text('Độ tin cậy: Trung bình'), findsOneWidget);
    expect(find.textContaining('dầu ẩn'), findsOneWidget);
    expect(find.text('Ước tính, không phải phép đo y khoa'), findsOneWidget);
    expect(find.byKey(const Key('food-analysis-save')), findsOneWidget);
    expect(find.byKey(const Key('food-analysis-edit')), findsOneWidget);
  });
}
