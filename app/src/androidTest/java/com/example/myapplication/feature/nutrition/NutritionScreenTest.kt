package com.example.myapplication.feature.nutrition

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import com.example.myapplication.core.nutrition.MealTemplate
import com.example.myapplication.core.nutrition.Nutrients
import com.example.myapplication.ui.theme.GymAppTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class NutritionScreenTest {
    @get:Rule val rule = createComposeRule()

    @Test
    fun manualDraftAndSavedMealsUseCurrentScreenWithoutNewNavigation() {
        var manualCalls = 0
        var appliedId: Long? = null
        rule.setContent {
            GymAppTheme {
                NutritionScreen(
                    state = content().copy(
                        draft = EditableNutritionDraft("Cơm gà", "500", "30", "60", "15"),
                        mealTemplates = listOf(MealTemplate(7, "Bữa quen", Nutrients(400, 25, 45, 10), 1)),
                    ),
                    onBack = {}, onScan = {}, onAccept = {}, onDiscard = {},
                    onUpdateResult = { _, _, _, _, _ -> },
                    onClearSweat = {}, onReset = {},
                    onStartManual = { manualCalls++ },
                    onApplyTemplate = { appliedId = it },
                )
            }
        }

        rule.onNodeWithText("Kiểm tra món ăn").assertIsDisplayed()
        rule.onNodeWithText("Cơm gà").assertIsDisplayed()
        rule.onNodeWithText("Bữa quen").assertIsDisplayed()
        rule.onNodeWithTag("meal-template-apply-7").performClick()
        rule.runOnIdle { assertEquals(7L, appliedId) }
    }

    private fun content() = NutritionUiState.Content(
        calorieLimit = 2000,
        caloriesEaten = 0,
        proteinEaten = 0,
        carbsEaten = 0,
        fatEaten = 0,
        sweatActive = false,
        sweatExerciseName = null,
        sweatExtraSets = 0,
        scanResult = null,
        scanning = false,
        scanError = null,
    )
}
