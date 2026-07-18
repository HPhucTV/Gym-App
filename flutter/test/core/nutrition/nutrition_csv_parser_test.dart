import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/nutrition/nutrition_csv_parser.dart';

void main() {
  test('parse_validEnglishCsv_returnsParsedEntities', () {
    const csv = '''
Food,Grams,Calories,fat,Carbs,Protein,Chất xơ,Potassium (mg),Sodium (mg),Cholesterol (mg)
whole milk,100,61,3.3,4.8,3.2,0.1,143,44,10
vegetable oil,14,120,14,0,0,0,0,0,0
''';

    final result = NutritionCsvParser.parse(csv, batchId: 'batch-1');

    expect(result.items.length, 2);
    expect(result.warnings.isEmpty, isTrue);
    
    expect(result.items[0].name, 'whole milk');
    expect(result.items[0].gramsPerServing, 100.0);
    expect(result.items[0].caloriesPerServing, 61.0);
    expect(result.items[0].fatPerServing, 3.3);
    expect(result.items[0].carbsPerServing, 4.8);
    expect(result.items[0].proteinPerServing, 3.2);
    expect(result.items[0].fiberPerServing, 0.1);
    expect(result.items[0].potassiumMg, 143.0);
    expect(result.items[0].sodiumMg, 44.0);
    expect(result.items[0].cholesterolMg, 10.0);
    expect(result.items[0].importBatchId, 'batch-1');

    expect(result.items[1].name, 'vegetable oil');
    expect(result.items[1].gramsPerServing, 14.0);
    expect(result.items[1].caloriesPerServing, 120.0);
    expect(result.items[1].fatPerServing, 14.0);
    expect(result.items[1].carbsPerServing, 0.0);
    expect(result.items[1].proteinPerServing, 0.0);
  });

  test('parse_validVietnameseCsvWithSemicolon_returnsParsedEntities', () {
    const csv = '''
Thực phẩm;Khẩu phần;Calo;Béo;Carbs;Đạm;xơ
Sữa nguyên kem;100;61;3,3;4,8;3,2;0,2
Dầu thực vật;14;120;14;0;0;0
''';

    final result = NutritionCsvParser.parse(csv, batchId: 'batch-2');

    expect(result.items.length, 2);
    expect(result.warnings.isEmpty, isTrue);
    expect(result.items[0].name, 'Sữa nguyên kem');
    expect(result.items[0].gramsPerServing, 100.0);
    expect(result.items[0].caloriesPerServing, 61.0);
    expect(result.items[0].fatPerServing, closeTo(3.3, 0.1));
    expect(result.items[0].carbsPerServing, closeTo(4.8, 0.1));
    expect(result.items[0].proteinPerServing, closeTo(3.2, 0.1));
    expect(result.items[0].fiberPerServing, closeTo(0.2, 0.1));
  });

  test('parse_invalidCsv_returnsEmptyList', () {
    const csv = '''
InvalidHeader1,InvalidHeader2,InvalidHeader3
Val1,Val2,Val3
''';

    final result = NutritionCsvParser.parse(csv);
    expect(result.items.isEmpty, isTrue);
    expect(result.warnings.length, 1);
    expect(result.warnings[0].contains('Không tìm thấy cột tên'), isTrue);
  });

  test('parse_csvWithWarnings_returnsWarnings', () {
    const csv = '''
Food,Grams,Calories,fat,Carbs,Protein,fiber
bad bacon,28,1176,11,0.4,3.5,0.0
negative fat,100,100,-5,10,10,0.0
macro mismatch,100,500,2,2,2,0.0
excessive fiber,50,150,2,10,5,60.0
''';

    final result = NutritionCsvParser.parse(csv);

    // items should only contain "bad bacon", "macro mismatch", "excessive fiber"
    // "negative fat" must be skipped
    expect(result.items.length, 3);

    // check warnings:
    expect(result.warnings.any((w) => w.contains("Calo của 'bad bacon' quá cao")), isTrue);
    expect(result.warnings.any((w) => w.contains("Phát hiện giá trị âm ở món 'negative fat'")), isTrue);
    expect(result.warnings.any((w) => w.contains("Tổng calo của Protein/Carb/Fat") && w.contains("macro mismatch")), isTrue);
    expect(result.warnings.any((w) => w.contains("Chất xơ (60.0 g) lớn hơn tổng trọng lượng")), isTrue);
  });
}
