package com.example.myapplication.feature.settings

import android.app.TimePickerDialog
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import com.example.myapplication.core.model.*

@Composable
fun SettingsScreen(
    state: SettingsUiState,
    onRest: (RestDayMode) -> Unit,
    onReminder: (Boolean) -> Unit,
    onTime: (Int, Int) -> Unit,
    onRequestReplace: () -> Unit,
    onRequestDelete: () -> Unit,
    onCancel: () -> Unit,
    onConfirm: () -> Unit,
) {
    when (state) {
        SettingsUiState.Loading -> Box(Modifier.fillMaxSize()) { CircularProgressIndicator() }
        is SettingsUiState.Error -> Text(state.message, Modifier.padding(24.dp))
        is SettingsUiState.Content -> SettingsContent(
            state, onRest, onReminder, onTime, onRequestReplace, onRequestDelete, onCancel, onConfirm,
        )
    }
}

@Composable
private fun SettingsContent(
    state: SettingsUiState.Content,
    onRest: (RestDayMode) -> Unit,
    onReminder: (Boolean) -> Unit,
    onTime: (Int, Int) -> Unit,
    onReplace: () -> Unit,
    onDelete: () -> Unit,
    onCancel: () -> Unit,
    onConfirm: () -> Unit,
) {
    val context = LocalContext.current
    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Cài đặt", style = MaterialTheme.typography.headlineMedium)
        Card {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(goalLabel(state.goal.goal), style = MaterialTheme.typography.titleLarge)
                Text("${levelLabel(state.goal.level)} • ${equipmentLabel(state.goal.equipment)}")
                Text("${state.goal.sessionsPerWeek} buổi/tuần • ${state.goal.durationWeeks} tuần")
            }
        }
        Text("Ngày nghỉ", style = MaterialTheme.typography.titleMedium)
        RestDayMode.entries.forEach { mode ->
            Row(
                Modifier.fillMaxWidth().heightIn(min = 48.dp).selectable(
                    selected = state.effectiveRestDayMode == mode,
                    enabled = !state.saving,
                    role = Role.RadioButton,
                    onClick = { onRest(mode) },
                ),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                RadioButton(state.effectiveRestDayMode == mode, null, enabled = !state.saving)
                Text(if (mode == RestDayMode.FULL_REST) "Nghỉ hoàn toàn" else "Phục hồi nhẹ")
            }
        }
        Row(
            Modifier.fillMaxWidth().heightIn(min = 56.dp).toggleable(
                value = state.reminderEnabled,
                enabled = !state.saving,
                role = Role.Switch,
                onValueChange = onReminder,
            ),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Column {
                Text("Nhắc tập luyện", style = MaterialTheme.typography.titleMedium)
                TextButton(
                    enabled = !state.saving,
                    contentPadding = PaddingValues(0.dp),
                    onClick = {
                        TimePickerDialog(
                            context,
                            { _, hour, minute -> onTime(hour, minute) },
                            state.reminderHour,
                            state.reminderMinute,
                            true,
                        ).show()
                    },
                ) { Text("%02d:%02d".format(state.reminderHour, state.reminderMinute)) }
            }
            Switch(state.reminderEnabled, onCheckedChange = null, enabled = !state.saving)
        }
        OutlinedButton(onClick = onReplace, enabled = !state.saving, modifier = Modifier.fillMaxWidth()) {
            Text("Đổi mục tiêu")
        }
        TextButton(
            onClick = onDelete,
            enabled = !state.saving,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error),
        ) { Text("Xóa mục tiêu hiện tại") }
        state.message?.let { Text(it, color = MaterialTheme.colorScheme.error) }
    }
    if (state.confirmation != PendingConfirmation.NONE) {
        val deleting = state.confirmation == PendingConfirmation.DELETE
        AlertDialog(
            onDismissRequest = onCancel,
            title = { Text(if (deleting) "Xóa mục tiêu" else "Đổi mục tiêu") },
            text = { Text("Lịch sử buổi tập đã hoàn thành vẫn được giữ lại.") },
            dismissButton = { TextButton(onClick = onCancel, enabled = !state.saving) { Text("Hủy") } },
            confirmButton = {
                TextButton(
                    onClick = onConfirm,
                    enabled = !state.saving,
                    colors = if (deleting) ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                    else ButtonDefaults.textButtonColors(),
                ) { Text("Xác nhận") }
            },
        )
    }
}

private fun goalLabel(value: FitnessGoal) = when (value) {
    FitnessGoal.GENERAL_FITNESS -> "Thể lực tổng quát"
    FitnessGoal.MUSCLE_GAIN -> "Tăng cơ"
    FitnessGoal.FAT_LOSS_CONDITIONING -> "Giảm mỡ & thể lực"
    FitnessGoal.ENDURANCE -> "Sức bền"
}

private fun levelLabel(value: ExperienceLevel) =
    if (value == ExperienceLevel.BEGINNER) "Mới bắt đầu" else "Trung cấp"

private fun equipmentLabel(value: EquipmentProfile) = when (value) {
    EquipmentProfile.BODYWEIGHT_ONLY -> "Không dụng cụ"
    EquipmentProfile.DUMBBELLS -> "Tạ đơn"
    EquipmentProfile.RESISTANCE_BANDS -> "Dây kháng lực"
    EquipmentProfile.FULL_GYM -> "Phòng gym đầy đủ"
}