import '../model/nutrition_models.dart';

class CsvParseResult {
  final List<FoodCatalogItem> items;
  final List<String> warnings;

  CsvParseResult({required this.items, required this.warnings});
}

class NutritionCsvParser {
  static final _nonNumericRegex = RegExp(r'[^0-9.,-]');

  static CsvParseResult parse(String csvText, {String batchId = ""}) {
    final lines = csvText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return CsvParseResult(items: [], warnings: []);

    // Xác định dấu phân cách: đếm số lượng dấu ',' và ';' trong dòng đầu tiên
    final firstLine = lines.first;
    final commaCount = firstLine.split(',').length - 1;
    final semicolonCount = firstLine.split(';').length - 1;
    final separator = semicolonCount > commaCount ? ';' : ',';

    final rows = lines.map((line) => _parseCsvLine(line, separator)).toList();
    return parseTable(rows, batchId: batchId);
  }

  static CsvParseResult parseTable(List<List<String>> rows, {String batchId = ""}) {
    if (rows.isEmpty) return CsvParseResult(items: [], warnings: []);

    final headers = rows.first.map((h) => h.toLowerCase().trim()).toList();

    // Tìm index của các cột
    final nameIdx = headers.indexWhere((h) =>
        h == "food" ||
        h == "name" ||
        h == "tên" ||
        h == "thực phẩm" ||
        h == "món ăn" ||
        h == "tên thực phẩm");
    final gramsIdx = headers.indexWhere((h) =>
        h == "grams" ||
        h == "gram" ||
        h == "khối lượng" ||
        h == "trọng lượng" ||
        h == "serving" ||
        h == "khẩu phần");
    final caloriesIdx = headers.indexWhere((h) =>
        h == "calories" ||
        h == "calo" ||
        h == "năng lượng" ||
        h == "kcal" ||
        h == "energy");
    final fatIdx = headers.indexWhere((h) =>
        h == "fat" || h == "lipid" || h == "béo" || h == "chất béo");
    final carbsIdx = headers.indexWhere((h) =>
        h.startsWith("carb") || h == "tinh bột" || h == "đường");
    final proteinIdx = headers.indexWhere((h) =>
        h == "protein" || h == "đạm" || h == "chất đạm");
    final fiberIdx = headers.indexWhere((h) =>
        h.contains("fiber") || h.contains("xơ") || h.contains("chất xơ"));
    final potassiumIdx = headers.indexWhere((h) =>
        h.startsWith("potassium") || h.contains("kali"));
    final sodiumIdx = headers.indexWhere((h) =>
        h.startsWith("sodium") || h.contains("natri"));
    final cholesterolIdx = headers.indexWhere((h) =>
        h.startsWith("cholesterol"));

    if (nameIdx == -1) {
      return CsvParseResult(
        items: [],
        warnings: ["Không tìm thấy cột tên món ăn / thực phẩm."],
      );
    }

    final foodList = <FoodCatalogItem>[];
    final warnings = <String>[];

    for (var i = 1; i < rows.length; i++) {
      final rowCells = rows[i];
      if (rowCells.isEmpty) continue;

      final rowNum = i + 1;
      final name = nameIdx < rowCells.length ? rowCells[nameIdx] : "";
      if (name.isEmpty) continue;

      final grams = gramsIdx >= 0 && gramsIdx < rowCells.length
          ? _parseDouble(rowCells[gramsIdx], 100.0)
          : 100.0;
      final calories = caloriesIdx >= 0 && caloriesIdx < rowCells.length
          ? _parseDouble(rowCells[caloriesIdx], 0.0)
          : 0.0;
      final fat = fatIdx >= 0 && fatIdx < rowCells.length
          ? _parseDouble(rowCells[fatIdx], 0.0)
          : 0.0;
      final carbs = carbsIdx >= 0 && carbsIdx < rowCells.length
          ? _parseDouble(rowCells[carbsIdx], 0.0)
          : 0.0;
      final protein = proteinIdx >= 0 && proteinIdx < rowCells.length
          ? _parseDouble(rowCells[proteinIdx], 0.0)
          : 0.0;
      final fiber = fiberIdx >= 0 && fiberIdx < rowCells.length
          ? _parseDouble(rowCells[fiberIdx], 0.0)
          : 0.0;
      final potassium = potassiumIdx >= 0 && potassiumIdx < rowCells.length
          ? _parseDouble(rowCells[potassiumIdx], 0.0)
          : 0.0;
      final sodium = sodiumIdx >= 0 && sodiumIdx < rowCells.length
          ? _parseDouble(rowCells[sodiumIdx], 0.0)
          : 0.0;
      final cholesterol = cholesterolIdx >= 0 && cholesterolIdx < rowCells.length
          ? _parseDouble(rowCells[cholesterolIdx], 0.0)
          : 0.0;

      // Validation
      if (grams < 0.0 ||
          calories < 0.0 ||
          fat < 0.0 ||
          carbs < 0.0 ||
          protein < 0.0 ||
          fiber < 0.0 ||
          potassium < 0.0 ||
          sodium < 0.0 ||
          cholesterol < 0.0) {
        warnings.add(
            "Dòng $rowNum: Phát hiện giá trị âm ở món '$name'. Dòng này đã bị bỏ qua.");
        continue;
      }

      if (grams > 0.0) {
        final calorieDensity = calories / grams;
        if (calorieDensity > 9.2) {
          warnings.add(
              "Dòng $rowNum: Calo của '$name' quá cao so với trọng lượng (${calorieDensity.toStringAsFixed(1)} kcal/g).");
        }
      }

      final macroCalories = (protein * 4.0) + (carbs * 4.0) + (fat * 9.0);
      if (calories > 20.0 && ((macroCalories - calories).abs() / calories) > 0.3) {
        warnings.add(
            "Dòng $rowNum: Tổng calo của Protein/Carb/Fat (${macroCalories.toInt()} kcal) lệch hơn 30% so với Calo khai báo (${calories.toInt()} kcal) ở món '$name'.");
      }

      if (fiber > grams) {
        warnings.add(
            "Dòng $rowNum: Chất xơ ($fiber g) lớn hơn tổng trọng lượng ($grams g) ở món '$name'.");
      }

      foodList.add(
        FoodCatalogItem(
          name: name,
          gramsPerServing: grams,
          caloriesPerServing: calories,
          fatPerServing: fat,
          carbsPerServing: carbs,
          proteinPerServing: protein,
          potassiumMg: potassium,
          sodiumMg: sodium,
          cholesterolMg: cholesterol,
          fiberPerServing: fiber,
          importBatchId: batchId,
        ),
      );
    }

    return CsvParseResult(items: foodList, warnings: warnings);
  }

  static List<String> _parseCsvLine(String line, String separator) {
    final result = <String>[];
    final currentCell = StringBuffer();
    var inQuotes = false;
    var i = 0;
    while (i < line.length) {
      final c = line[i];
      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          currentCell.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == separator && !inQuotes) {
        result.add(currentCell.toString().trim());
        currentCell.clear();
      } else {
        currentCell.write(c);
      }
      i++;
    }
    result.add(currentCell.toString().trim());
    return result;
  }

  static double _parseDouble(String value, double defaultValue) {
    if (value.isEmpty) return defaultValue;
    final cleaned = value.replaceAll(_nonNumericRegex, '').trim();
    if (cleaned.isEmpty) return defaultValue;

    try {
      final String standardDot;
      final commaCount = ','.allMatches(cleaned).length;
      final dotCount = '.'.allMatches(cleaned).length;

      if (commaCount == 1 && dotCount == 0) {
        standardDot = cleaned.replaceAll(',', '.');
      } else if (cleaned.contains(',') && cleaned.contains('.')) {
        standardDot = cleaned.replaceAll(',', '');
      } else {
        standardDot = cleaned;
      }
      return double.parse(standardDot);
    } catch (_) {
      return defaultValue;
    }
  }
}
