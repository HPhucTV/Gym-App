package com.example.myapplication.core.nutrition

import com.example.myapplication.data.local.FoodCatalogEntity

data class CsvParseResult(
    val items: List<FoodCatalogEntity>,
    val warnings: List<String>
)

object NutritionCsvParser {
    fun parse(csvText: String, batchId: String = ""): CsvParseResult {
        val lines = csvText.lines().map { it.trim() }.filter { it.isNotEmpty() }
        if (lines.isEmpty()) return CsvParseResult(emptyList(), emptyList())

        // Determine separator: count occurrences in first line
        val firstLine = lines.first()
        val separator = if (firstLine.count { it == ';' } > firstLine.count { it == ',' }) ';' else ','

        val headers = parseCsvLine(firstLine, separator).map { it.lowercase().trim() }

        // Find column indices
        val nameIdx = headers.indexOfFirst { 
            it == "food" || it == "name" || it == "tên" || it == "thực phẩm" || it == "món ăn" || it == "tên thực phẩm"
        }
        val gramsIdx = headers.indexOfFirst { 
            it == "grams" || it == "gram" || it == "khối lượng" || it == "trọng lượng" || it == "serving" || it == "khẩu phần"
        }
        val caloriesIdx = headers.indexOfFirst { 
            it == "calories" || it == "calo" || it == "năng lượng" || it == "kcal" || it == "energy"
        }
        val fatIdx = headers.indexOfFirst { 
            it == "fat" || it == "lipid" || it == "béo" || it == "chất béo"
        }
        val carbsIdx = headers.indexOfFirst { 
            it.startsWith("carb") || it == "tinh bột" || it == "đường"
        }
        val proteinIdx = headers.indexOfFirst { 
            it == "protein" || it == "đạm" || it == "chất đạm"
        }
        val fiberIdx = headers.indexOfFirst {
            it.contains("fiber") || it.contains("xơ") || it.contains("chất xơ")
        }
        val potassiumIdx = headers.indexOfFirst { 
            it.startsWith("potassium") || it.contains("kali")
        }
        val sodiumIdx = headers.indexOfFirst { 
            it.startsWith("sodium") || it.contains("natri")
        }
        val cholesterolIdx = headers.indexOfFirst { 
            it.startsWith("cholesterol")
        }

        // If we can't find name or calories column, it's not a valid calorie tracker sheet
        if (nameIdx == -1) {
            return CsvParseResult(emptyList(), listOf("Không tìm thấy cột tên món ăn / thực phẩm."))
        }

        val foodList = mutableListOf<FoodCatalogEntity>()
        val warnings = mutableListOf<String>()

        for (i in 1 until lines.size) {
            val line = lines[i]
            val tokens = parseCsvLine(line, separator)
            if (tokens.isEmpty()) continue

            val rowNum = i + 1
            val name = if (nameIdx < tokens.size) tokens[nameIdx] else ""
            if (name.isEmpty()) continue

            val grams = if (gramsIdx >= 0 && gramsIdx < tokens.size) parseDouble(tokens[gramsIdx], 100.0) else 100.0
            val calories = if (caloriesIdx >= 0 && caloriesIdx < tokens.size) parseDouble(tokens[caloriesIdx], 0.0) else 0.0
            val fat = if (fatIdx >= 0 && fatIdx < tokens.size) parseDouble(tokens[fatIdx], 0.0) else 0.0
            val carbs = if (carbsIdx >= 0 && carbsIdx < tokens.size) parseDouble(tokens[carbsIdx], 0.0) else 0.0
            val protein = if (proteinIdx >= 0 && proteinIdx < tokens.size) parseDouble(tokens[proteinIdx], 0.0) else 0.0
            val fiber = if (fiberIdx >= 0 && fiberIdx < tokens.size) parseDouble(tokens[fiberIdx], 0.0) else 0.0
            val potassium = if (potassiumIdx >= 0 && potassiumIdx < tokens.size) parseDouble(tokens[potassiumIdx], 0.0) else 0.0
            val sodium = if (sodiumIdx >= 0 && sodiumIdx < tokens.size) parseDouble(tokens[sodiumIdx], 0.0) else 0.0
            val cholesterol = if (cholesterolIdx >= 0 && cholesterolIdx < tokens.size) parseDouble(tokens[cholesterolIdx], 0.0) else 0.0

            // Validation rules
            if (grams < 0.0 || calories < 0.0 || fat < 0.0 || carbs < 0.0 || protein < 0.0 || fiber < 0.0 || potassium < 0.0 || sodium < 0.0 || cholesterol < 0.0) {
                warnings.add("Dòng $rowNum: Phát hiện giá trị âm ở món '$name'. Dòng này đã bị bỏ qua.")
                continue
            }

            if (grams > 0.0) {
                val calorieDensity = calories / grams
                if (calorieDensity > 9.2) {
                    warnings.add("Dòng $rowNum: Calo của '$name' quá cao so với trọng lượng (${String.format(java.util.Locale.US, "%.1f", calorieDensity)} kcal/g).")
                }
            }

            val macroCal = (protein * 4.0) + (carbs * 4.0) + (fat * 9.0)
            if (calories > 20.0 && kotlin.math.abs(macroCal - calories) / calories > 0.3) {
                warnings.add("Dòng $rowNum: Tổng calo của Protein/Carb/Fat (${macroCal.toInt()} kcal) lệch hơn 30% so với Calo khai báo ($calories kcal) ở món '$name'.")
            }

            if (fiber > grams) {
                warnings.add("Dòng $rowNum: Chất xơ ($fiber g) lớn hơn tổng trọng lượng ($grams g) ở món '$name'.")
            }

            foodList.add(
                FoodCatalogEntity(
                    name = name,
                    gramsPerServing = grams,
                    caloriesPerServing = calories,
                    fatPerServing = fat,
                    carbsPerServing = carbs,
                    proteinPerServing = protein,
                    potassiumMg = potassium,
                    sodiumMg = sodium,
                    cholesterolMg = cholesterol,
                    fiberPerServing = fiber,
                    importBatchId = batchId
                )
            )
        }

        return CsvParseResult(foodList, warnings)
    }

    private fun parseCsvLine(line: String, sep: Char): List<String> {
        val result = mutableListOf<String>()
        var cur = StringBuilder()
        var inQuotes = false
        var i = 0
        while (i < line.length) {
            val c = line[i]
            if (c == '"') {
                if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
                    cur.append('"')
                    i++
                } else {
                    inQuotes = !inQuotes
                }
            } else if (c == sep && !inQuotes) {
                result.add(cur.toString().trim())
                cur = StringBuilder()
            } else {
                cur.append(c)
            }
            i++
        }
        result.add(cur.toString().trim())
        return result
    }

    private fun parseDouble(value: String, default: Double): Double {
        if (value.isEmpty()) return default
        // Clean value of non-numeric characters except dots, commas, minus, and digits
        val cleaned = value.replace(Regex("[^0-9.,-]"), "").trim()
        if (cleaned.isEmpty()) return default
        return try {
            // Replace comma with dot if comma is used as decimal separator
            val standardDot = if (cleaned.count { it == ',' } == 1 && cleaned.count { it == '.' } == 0) {
                cleaned.replace(',', '.')
            } else if (cleaned.contains(',') && cleaned.contains('.')) {
                // E.g., 1,234.56 -> remove comma
                cleaned.replace(",", "")
            } else {
                cleaned
            }
            standardDot.toDouble()
        } catch (e: NumberFormatException) {
            default
        }
    }
}
