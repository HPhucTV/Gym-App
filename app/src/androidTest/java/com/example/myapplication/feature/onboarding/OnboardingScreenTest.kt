package com.example.myapplication.feature.onboarding

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.myapplication.core.model.*
import com.example.myapplication.ui.theme.GymAppTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class OnboardingScreenTest {
    @get:Rule val composeRule = createComposeRule()

    @Test fun goalStep_selectsOneDecisionAndAdvances() {
        var selected: FitnessGoal? = null
        var nextCalls = 0
        setContent(editing(OnboardingStep.GOAL, OnboardingDraft(goal = FitnessGoal.MUSCLE_GAIN)), onGoal = { goal -> selected = goal }, onNext = { nextCalls++ })
        composeRule.onNodeWithText("Tăng cơ").performClick()
        composeRule.runOnIdle { assert(selected == FitnessGoal.MUSCLE_GAIN) }
        composeRule.onNodeWithText("Tiếp tục").performClick()
        composeRule.runOnIdle { assert(nextCalls == 1) }
        composeRule.onAllNodesWithText("Trình độ").assertCountEquals(0)
    }

    @Test fun reviewShowsExactSelectionsAndSavingDisablesCreate() {
        val draft = OnboardingDraft(FitnessGoal.GENERAL_FITNESS, ExperienceLevel.BEGINNER,
            EquipmentProfile.BODYWEIGHT_ONLY, 3, 4, RestDayMode.LIGHT_RECOVERY)
        setContent(editing(OnboardingStep.REVIEW, draft, isSaving = true))
        composeRule.onNodeWithText("Thể lực tổng quát").assertIsDisplayed()
        composeRule.onNodeWithText("3 buổi/tuần · 4 tuần").assertIsDisplayed()
        composeRule.onNodeWithText("Phục hồi nhẹ").assertIsDisplayed()
        composeRule.onNodeWithText("Đang tạo…").assertIsNotEnabled()
    }

    @Test fun unsupportedShowsExplanationAndAlternative() {
        setContent(OnboardingUiState.Unsupported(
            draft = OnboardingDraft(goal = FitnessGoal.MUSCLE_GAIN),
            explanation = "Chưa có chương trình phù hợp với lựa chọn này.",
            alternatives = listOf("Tăng cơ · Người mới · Tạ đơn · 3 buổi/tuần · 4 tuần"),
        ))
        composeRule.onNodeWithText("Chưa có chương trình phù hợp với lựa chọn này.").assertIsDisplayed()
        composeRule.onNodeWithText("Tăng cơ · Người mới · Tạ đơn · 3 buổi/tuần · 4 tuần").assertIsDisplayed()
        composeRule.onNodeWithText("Thay đổi lựa chọn").assertIsDisplayed()
    }

    @Test fun forbiddenAccountAndBodyFieldsAreAbsent() {
        setContent(editing(OnboardingStep.GOAL))
        listOf("Tài khoản", "Cân nặng", "Số đo", "Dinh dưỡng", "AI").forEach {
            composeRule.onAllNodesWithText(it, substring = true, ignoreCase = true).assertCountEquals(0)
        }
    }

    private fun setContent(
        state: OnboardingUiState,
        onGoal: (FitnessGoal) -> Unit = {},
        onNext: () -> Unit = {},
    ) = composeRule.setContent {
        GymAppTheme {
            OnboardingScreen(state, onGoalSelected = onGoal, onNext = onNext)
        }
    }

    private fun editing(
        step: OnboardingStep,
        draft: OnboardingDraft = OnboardingDraft(),
        isSaving: Boolean = false,
    ) = OnboardingUiState.Editing(step, draft, OnboardingOptions(
        goals = setOf(FitnessGoal.GENERAL_FITNESS, FitnessGoal.MUSCLE_GAIN),
        levels = setOf(ExperienceLevel.BEGINNER),
        equipment = setOf(EquipmentProfile.BODYWEIGHT_ONLY),
        commitments = setOf(WorkoutCommitment(3, 4)),
        restDayModes = RestDayMode.entries.toSet(),
    ), isSaving)
}
