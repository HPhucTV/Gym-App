package com.example.myapplication.feature.onboarding

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.myapplication.core.model.*
import com.example.myapplication.data.WorkoutRepository
import java.time.LocalDate

private val Navy = Color(0xFF14213D)
private val Orange = Color(0xFFF97316)
private val LightGray = Color(0xFFF3F4F6)

@Composable
fun OnboardingRoute(programs: List<ProgramTemplate>, workoutRepository: WorkoutRepository, replacementMode: Boolean = false) {
    val factory = object : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            OnboardingViewModel(programs, workoutRepository) { LocalDate.now().toEpochDay() } as T
    }
    val vm: OnboardingViewModel = viewModel(factory = factory)
    val state by vm.uiState.collectAsStateWithLifecycle()
    OnboardingScreen(
        state = state,
        replacementMode = replacementMode,
        onGoalSelected = vm::selectGoal,
        onLevelSelected = vm::selectLevel,
        onEquipmentSelected = vm::selectEquipment,
        onCommitmentSelected = { vm.selectCommitment(it.sessionsPerWeek, it.durationWeeks) },
        onRestDayModeSelected = vm::selectRestDayMode,
        onNext = vm::next,
        onBack = vm::back,
        onCreateGoal = vm::createGoal,
    )
}

@Composable
fun OnboardingScreen(
    state: OnboardingUiState,
    replacementMode: Boolean = false,
    onGoalSelected: (FitnessGoal) -> Unit = {},
    onLevelSelected: (ExperienceLevel) -> Unit = {},
    onEquipmentSelected: (EquipmentProfile) -> Unit = {},
    onCommitmentSelected: (WorkoutCommitment) -> Unit = {},
    onRestDayModeSelected: (RestDayMode) -> Unit = {},
    onNext: () -> Unit = {},
    onBack: () -> Unit = {},
    onCreateGoal: () -> Unit = {},
) {
    Surface(color = Color.White, modifier = Modifier.fillMaxSize()) {
        when (state) {
            is OnboardingUiState.Editing -> EditingContent(state, replacementMode, onGoalSelected, onLevelSelected,
                onEquipmentSelected, onCommitmentSelected, onRestDayModeSelected, onNext, onBack, onCreateGoal)
            is OnboardingUiState.Unsupported -> UnsupportedContent(state, onBack)
            OnboardingUiState.Created -> Box(Modifier.fillMaxSize())
        }
    }
}

@Composable
private fun EditingContent(
    state: OnboardingUiState.Editing,
    replacementMode: Boolean,
    onGoal: (FitnessGoal) -> Unit,
    onLevel: (ExperienceLevel) -> Unit,
    onEquipment: (EquipmentProfile) -> Unit,
    onCommitment: (WorkoutCommitment) -> Unit,
    onRest: (RestDayMode) -> Unit,
    onNext: () -> Unit,
    onBack: () -> Unit,
    onCreate: () -> Unit,
) {
    val title = when (state.step) {
        OnboardingStep.GOAL -> "Mục tiêu của bạn"
        OnboardingStep.LEVEL -> "Trình độ hiện tại"
        OnboardingStep.EQUIPMENT -> "Dụng cụ sẵn có"
        OnboardingStep.COMMITMENT -> "Lịch tập phù hợp"
        OnboardingStep.REST_BEHAVIOR -> "Ngày nghỉ"
        OnboardingStep.REVIEW -> "Xem lại mục tiêu"
    }
    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp),
        contentPadding = PaddingValues(vertical = 28.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item { Text(if (replacementMode) "Đổi mục tiêu" else "Tạo mục tiêu", color = Orange, style = MaterialTheme.typography.labelLarge) }
        item { Text(title, color = Navy, style = MaterialTheme.typography.headlineMedium) }
        item { Text(if (replacementMode) "Lịch sử tập luyện đã hoàn thành vẫn được giữ lại." else "Chọn chương trình có sẵn để nhận bài tập mỗi ngày.", color = Navy.copy(alpha = .72f)) }
        when (state.step) {
            OnboardingStep.GOAL -> items(state.options.goals.toList()) { value -> Choice(value.labelVi(), state.draft.goal == value) { onGoal(value) } }
            OnboardingStep.LEVEL -> items(state.options.levels.toList()) { value -> Choice(value.labelVi(), state.draft.level == value) { onLevel(value) } }
            OnboardingStep.EQUIPMENT -> items(state.options.equipment.toList()) { value -> Choice(value.labelVi(), state.draft.equipment == value) { onEquipment(value) } }
            OnboardingStep.COMMITMENT -> items(state.options.commitments.toList()) { value -> Choice("${value.sessionsPerWeek} buổi/tuần · ${value.durationWeeks} tuần", state.draft.sessionsPerWeek == value.sessionsPerWeek && state.draft.durationWeeks == value.durationWeeks) { onCommitment(value) } }
            OnboardingStep.REST_BEHAVIOR -> items(state.options.restDayModes.toList()) { value -> Choice(value.labelVi(), state.draft.restDayMode == value) { onRest(value) } }
            OnboardingStep.REVIEW -> item { ReviewCard(state.draft) }
        }
        state.saveError?.let { error -> item { Text(error, color = MaterialTheme.colorScheme.error) } }
        item {
            Row(Modifier.fillMaxWidth().padding(top = 12.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                if (state.step != OnboardingStep.GOAL) OutlinedButton(onClick = onBack, enabled = !state.isSaving, modifier = Modifier.weight(1f)) { Text("Quay lại") }
                Button(
                    onClick = if (state.step == OnboardingStep.REVIEW) onCreate else onNext,
                    enabled = !state.isSaving && canAdvance(state),
                    colors = ButtonDefaults.buttonColors(containerColor = Orange),
                    modifier = Modifier.weight(1f),
                ) { Text(if (state.isSaving) "Đang tạo…" else if (state.step == OnboardingStep.REVIEW) "Tạo mục tiêu" else "Tiếp tục") }
            }
        }
    }
}

@Composable private fun Choice(label: String, selected: Boolean, onClick: () -> Unit) {
    Surface(
        border = BorderStroke(1.dp, if (selected) Orange else Color(0xFFE5E7EB)),
        color = if (selected) Color(0xFFFFF7ED) else Color.White,
        contentColor = Navy,
        shape = RoundedCornerShape(14.dp),
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .selectable(selected = selected, role = Role.RadioButton, onClick = onClick),
    ) { Text(label, modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 16.dp)) }
}

@Composable private fun ReviewCard(draft: OnboardingDraft) {
    Card(colors = CardDefaults.cardColors(containerColor = LightGray), shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
        Column(Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(draft.goal?.labelVi().orEmpty(), color = Navy, style = MaterialTheme.typography.titleLarge)
            Text(draft.level?.labelVi().orEmpty(), color = Navy)
            Text(draft.equipment?.labelVi().orEmpty(), color = Navy)
            Text("${draft.sessionsPerWeek} buổi/tuần · ${draft.durationWeeks} tuần", color = Navy)
            Text(draft.restDayMode?.labelVi().orEmpty(), color = Navy)
        }
    }
}

@Composable private fun UnsupportedContent(state: OnboardingUiState.Unsupported, onBack: () -> Unit) {
    LazyColumn(Modifier.fillMaxSize().padding(20.dp), contentPadding = PaddingValues(vertical = 28.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        item { Text("Chưa thể tạo mục tiêu", color = Navy, style = MaterialTheme.typography.headlineMedium) }
        item { Text(state.explanation, color = Navy) }
        item { Text("Các lựa chọn đang được hỗ trợ", color = Navy, style = MaterialTheme.typography.titleMedium) }
        items(state.alternatives) { Text(it, modifier = Modifier.fillMaxWidth().padding(12.dp), color = Navy) }
        item { Button(onClick = onBack, colors = ButtonDefaults.buttonColors(containerColor = Orange)) { Text("Thay đổi lựa chọn") } }
    }
}

private fun canAdvance(state: OnboardingUiState.Editing) = when (state.step) {
    OnboardingStep.GOAL -> state.draft.goal != null
    OnboardingStep.LEVEL -> state.draft.level != null
    OnboardingStep.EQUIPMENT -> state.draft.equipment != null
    OnboardingStep.COMMITMENT -> state.draft.sessionsPerWeek != null && state.draft.durationWeeks != null
    OnboardingStep.REST_BEHAVIOR -> state.draft.restDayMode != null
    OnboardingStep.REVIEW -> true
}
