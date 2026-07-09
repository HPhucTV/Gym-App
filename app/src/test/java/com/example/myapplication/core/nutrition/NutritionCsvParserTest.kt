package com.example.myapplication.core.nutrition

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class NutritionCsvParserTest {

    @Test
    fun parse_validEnglishCsv_returnsParsedEntities() {
        val csv = """
            Food,Grams,Calories,fat,Carbs,Protein,Chất xơ,Potassium (mg),Sodium (mg),Cholesterol (mg)
            whole milk,100,61,3.3,4.8,3.2,0.1,143,44,10
            vegetable oil,14,120,14,0,0,0,0,0,0
        """.trimIndent()

        val result = NutritionCsvParser.parse(csv, "batch-1")

        assertEquals(2, result.items.size)
        assertTrue(result.warnings.isEmpty())
        assertEquals("whole milk", result.items[0].name)
        assertEquals(100.0, result.items[0].gramsPerServing, 0.0)
        assertEquals(61.0, result.items[0].caloriesPerServing, 0.0)
        assertEquals(3.3, result.items[0].fatPerServing, 0.0)
        assertEquals(4.8, result.items[0].carbsPerServing, 0.0)
        assertEquals(3.2, result.items[0].proteinPerServing, 0.0)
        assertEquals(0.1, result.items[0].fiberPerServing, 0.0)
        assertEquals(143.0, result.items[0].potassiumMg, 0.0)
        assertEquals(44.0, result.items[0].sodiumMg, 0.0)
        assertEquals(10.0, result.items[0].cholesterolMg, 0.0)
        assertEquals("batch-1", result.items[0].importBatchId)

        assertEquals("vegetable oil", result.items[1].name)
        assertEquals(14.0, result.items[1].gramsPerServing, 0.0)
        assertEquals(120.0, result.items[1].caloriesPerServing, 0.0)
        assertEquals(14.0, result.items[1].fatPerServing, 0.0)
        assertEquals(0.0, result.items[1].carbsPerServing, 0.0)
        assertEquals(0.0, result.items[1].proteinPerServing, 0.0)
    }

    @Test
    fun parse_validVietnameseCsvWithSemicolon_returnsParsedEntities() {
        val csv = """
            Thực phẩm;Khẩu phần;Calo;Béo;Carbs;Đạm;xơ
            Sữa nguyên kem;100;61;3,3;4,8;3,2;0,2
            Dầu thực vật;14;120;14;0;0;0
        """.trimIndent()

        val result = NutritionCsvParser.parse(csv, "batch-2")

        assertEquals(2, result.items.size)
        assertTrue(result.warnings.isEmpty())
        assertEquals("Sữa nguyên kem", result.items[0].name)
        assertEquals(100.0, result.items[0].gramsPerServing, 0.0)
        assertEquals(61.0, result.items[0].caloriesPerServing, 0.0)
        assertEquals(3.3, result.items[0].fatPerServing, 0.1) // Using 0.1 delta for safety with comma decimals
        assertEquals(4.8, result.items[0].carbsPerServing, 0.1)
        assertEquals(3.2, result.items[0].proteinPerServing, 0.1)
        assertEquals(0.2, result.items[0].fiberPerServing, 0.1)
    }

    @Test
    fun parse_invalidCsv_returnsEmptyList() {
        val csv = """
            InvalidHeader1,InvalidHeader2,InvalidHeader3
            Val1,Val2,Val3
        """.trimIndent()

        val result = NutritionCsvParser.parse(csv)
        assertTrue(result.items.isEmpty())
        assertEquals(1, result.warnings.size)
        assertTrue(result.warnings[0].contains("Không tìm thấy cột tên"))
    }

    @Test
    fun parse_csvWithWarnings_returnsWarnings() {
        val csv = """
            Food,Grams,Calories,fat,Carbs,Protein,fiber
            bad bacon,28,1176,11,0.4,3.5,0.0
            negative fat,100,100,-5,10,10,0.0
            macro mismatch,100,500,2,2,2,0.0
            excessive fiber,50,150,2,10,5,60.0
        """.trimIndent()

        val result = NutritionCsvParser.parse(csv)
        
        // items should only contain "bad bacon", "macro mismatch", "excessive fiber"
        // "negative fat" must be skipped
        assertEquals(3, result.items.size)
        
        // check warnings:
        assertTrue(result.warnings.any { it.contains("Calo của 'bad bacon' quá cao") })
        assertTrue(result.warnings.any { it.contains("Phát hiện giá trị âm ở món 'negative fat'") })
        assertTrue(result.warnings.any { it.contains("Tổng calo của Protein/Carb/Fat") && it.contains("macro mismatch") })
        assertTrue(result.warnings.any { it.contains("Chất xơ (60.0 g) lớn hơn tổng trọng lượng") })
    }
}
