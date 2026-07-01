package com.example.myapplication.feature.today

import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.myapplication.ui.theme.GymAppTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class TodayScreenTest {
    @get:Rule val rule = createComposeRule()

    @Test fun workout_content_expand_check_and_complete_state() {
        var checks = 0
        set(WorkoutRowUi(0, "Chống đẩy", "3 × 8–12", 60, listOf("Bước một", "Bước hai"), false), false) { checks++ }
        rule.onNodeWithText("Chống đẩy").assertIsDisplayed()
        rule.onNodeWithText("3 × 8–12 · nghỉ 60 giây").assertIsDisplayed()
        rule.onNodeWithText("Hoàn thành buổi tập").assertIsNotEnabled()
        rule.onNodeWithContentDescription("Đánh dấu Chống đẩy hoàn thành").performClick()
        rule.runOnIdle { assertEquals(1, checks) }
        rule.onNodeWithContentDescription("Mở hướng dẫn Chống đẩy").performClick()
        rule.onNodeWithText("1. Bước một").assertIsDisplayed()
    }

    @Test fun checked_row_has_semantics_and_completion_enabled() {
        set(WorkoutRowUi(0, "Chống đẩy", "30 giây", 30, listOf("Một", "Hai"), true), true)
        rule.onNodeWithContentDescription("Đánh dấu Chống đẩy hoàn thành").assertIsOn()
        rule.onNodeWithContentDescription("Đã hoàn thành Chống đẩy").assertExists()
        rule.onNodeWithText("Hoàn thành buổi tập").assertIsEnabled()
    }

    @Test fun recovery_goal_and_error_have_distinct_copy_and_retry() {
        setState(TodayUiState.Recovery(RecoveryKind.FULL_REST, 101))
        rule.onNodeWithText("Nghỉ ngơi hoàn toàn").assertIsDisplayed()
        rule.onNodeWithText("12/04/1970", substring = true).assertIsDisplayed()
        setState(TodayUiState.Recovery(RecoveryKind.LIGHT_RECOVERY, 101))
        rule.onNodeWithText("Phục hồi nhẹ").assertIsDisplayed()
        setState(TodayUiState.GoalComplete)
        rule.onNodeWithText("Hoàn thành mục tiêu").assertIsDisplayed()
        setState(TodayUiState.Error("Có lỗi", canRetry = true))
        rule.onNodeWithText("Thử lại").assertIsEnabled()
    }

    @Test fun loading_non_retry_error_and_completing_are_explicit() {
        setState(TodayUiState.Loading)
        rule.onNodeWithContentDescription("Đang tải bài tập").assertExists()
        setState(TodayUiState.Error("Có lỗi", canRetry = false))
        rule.onAllNodesWithText("Thử lại").assertCountEquals(0)
        setState(TodayUiState.Workout(7, "Toàn thân", "Ngực", 25,
            listOf(WorkoutRowUi(0, "Chống đẩy", "3 × 8", 60, listOf("Một", "Hai"), true)),
            1, 1, canComplete = true, isCompleting = true))
        rule.onNodeWithText("Đang hoàn thành…").assertIsNotEnabled()
    }

    @Test fun enabled_completion_invokes_callback_once() {
        var calls = 0
        rule.setContent {
            GymAppTheme {
                TodayScreen(TodayUiState.Workout(7, "Toàn thân", "Ngực", 25,
                    listOf(WorkoutRowUi(0, "Chống đẩy", "3 × 8", 60, listOf("Một", "Hai"), true)),
                    1, 1, true, false), { _, _ -> }, { calls++ }, {})
            }
        }
        rule.onNodeWithText("Hoàn thành buổi tập").performClick()
        rule.runOnIdle { assertEquals(1, calls) }
    }
    @Test fun pending_and_inline_error_are_visible_and_not_actionable() {
        setState(TodayUiState.Workout(7, "Toàn thân", "Ngực", 25,
            listOf(WorkoutRowUi(0, "Chống đẩy", "3 × 8", 60, listOf("Một", "Hai"), true, "push_up")),
            1, 1, canComplete = false, isCompleting = false,
            pendingOrderIndices = setOf(0), interactionError = "Không thể cập nhật bài tập. Vui lòng thử lại."))
        rule.onNodeWithContentDescription("Đánh dấu Chống đẩy hoàn thành").assertIsNotEnabled()
        rule.onNodeWithText("Hoàn thành buổi tập").assertIsNotEnabled()
        rule.onNodeWithText("Không thể cập nhật bài tập. Vui lòng thử lại.").assertIsDisplayed()
    }

    @Test fun expansion_does_not_carry_to_new_session() {
        val state = mutableStateOf(workoutState(7, "Bước cũ"))
        rule.setContent { GymAppTheme { TodayScreen(state.value, { _, _ -> }, {}, {}) } }
        rule.onNodeWithContentDescription("Mở hướng dẫn Chống đẩy").performClick()
        rule.onNodeWithText("1. Bước cũ").assertIsDisplayed()
        rule.runOnIdle { state.value = workoutState(8, "Bước mới") }
        rule.onAllNodesWithText("1. Bước cũ").assertCountEquals(0)
        rule.onAllNodesWithText("1. Bước mới").assertCountEquals(0)
    }

    private fun workoutState(sessionId: Long, instruction: String) = TodayUiState.Workout(
        sessionId, "Toàn thân", "Ngực", 25,
        listOf(WorkoutRowUi(0, "Chống đẩy", "3 × 8", 60, listOf(instruction, "Bước hai"), false, "push_up")),
        0, 1, false, false)
    private fun set(row: WorkoutRowUi, complete: Boolean, onCheck: () -> Unit = {}) = setState(
        TodayUiState.Workout(7, "Toàn thân", "Ngực", 25, listOf(row), if (row.checked) 1 else 0, 1, complete, false),
        onCheckedChange = { _, _ -> onCheck() })
    private fun setState(state: TodayUiState, onCheckedChange: (Int, Boolean) -> Unit = { _, _ -> }) = rule.setContent {
        GymAppTheme { TodayScreen(state, onCheckedChange, {}, {}) }
    }
}
