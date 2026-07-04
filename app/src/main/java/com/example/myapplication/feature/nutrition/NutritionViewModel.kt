package com.example.myapplication.feature.nutrition

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.model.FitnessGoal
import com.example.myapplication.core.nutrition.EntrySource
import com.example.myapplication.core.nutrition.Nutrients
import com.example.myapplication.core.nutrition.NutritionDay
import com.example.myapplication.core.nutrition.MealTemplate
import com.example.myapplication.data.NutritionData
import com.example.myapplication.data.NutritionRepository
import com.example.myapplication.data.WorkoutRepository
import java.time.LocalDate
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

sealed interface NutritionUiState {
    data object Loading : NutritionUiState
    data class Content(
        val calorieLimit: Int,
        val caloriesEaten: Int,
        val proteinEaten: Int,
        val carbsEaten: Int,
        val fatEaten: Int,
        val sweatActive: Boolean,
        val sweatExerciseName: String?,
        val sweatExtraSets: Int,
        val scanResult: ScanResult?,
        val scanning: Boolean,
        val scanError: String?,
        val history: List<NutritionDay> = emptyList(),
        val draft: EditableNutritionDraft? = null,
        val mealTemplates: List<MealTemplate> = emptyList(),
        val savingDraft: Boolean = false,
        val pendingDeleteTemplateId: Long? = null,
        val templateNameEdit: TemplateNameEdit? = null,
    ) : NutritionUiState
}

data class EditableNutritionDraft(
    val nameVi: String,
    val caloriesText: String,
    val proteinText: String,
    val carbsText: String,
    val fatText: String,
    val saveAsTemplate: Boolean = false,
    val errors: Map<String, String> = emptyMap(),
)

data class TemplateNameEdit(
    val id: Long,
    val nameVi: String,
    val error: String? = null,
)

data class ScanResult(
    val dishName: String,
    val totalCalories: Int,
    val proteinGrams: Int,
    val carbsGrams: Int,
    val fatGrams: Int,
    val fitnessScore: Int,
    val advice: String,
    val constituents: List<Constituent>,
    val sweatPayment: SweatPaymentProposal?,
    val calculationProcess: String? = null,
    val confidence: Double = 1.0,
    val needsUserConfirmation: Boolean = false,
)

data class Constituent(
    val name: String,
    val calories: Int,
    val protein: Int,
    val carbs: Int,
    val fat: Int,
)

data class SweatPaymentProposal(
    val exerciseId: String,
    val exerciseName: String,
    val extraSets: Int,
)

class NutritionViewModel(
    private val workoutRepository: WorkoutRepository,
    private val nutritionRepository: NutritionRepository,
    private val personalizationDao: com.example.myapplication.data.local.PersonalizationDao? = null,
    private val foodAnalysisClient: FoodAnalysisClient = OkHttpFoodAnalysisClient(),
    private val cloudAiConsent: Flow<Boolean> = flowOf(false),
    private val currentEpochDay: () -> Long = { LocalDate.now().toEpochDay() },
) : ViewModel() {
    private val scanningState = MutableStateFlow(false)
    private val scanResultState = MutableStateFlow<ScanResult?>(null)
    private val scanErrorState = MutableStateFlow<String?>(null)
    private val draftState = MutableStateFlow<EditableNutritionDraft?>(null)
    private val savingDraftState = MutableStateFlow(false)
    private val pendingDeleteTemplateId = MutableStateFlow<Long?>(null)
    private val templateNameEdit = MutableStateFlow<TemplateNameEdit?>(null)
    private var draftEntrySource = EntrySource.MANUAL
    private var draftSweatPayment: SweatPaymentProposal? = null
    private var draftNutrientsRecorded = false
    private val todayEpochDay = currentEpochDay()
    private val nutritionParts = combine(
        nutritionRepository.nutritionData,
        nutritionRepository.observeDay(todayEpochDay),
        ::NutritionStateParts,
    )
    private val scanParts = combine(scanningState, scanResultState, scanErrorState, ::ScanStateParts)
    private val draftParts = combine(
        draftState,
        savingDraftState,
        pendingDeleteTemplateId,
        templateNameEdit,
        ::DraftStateParts,
    )
    private val interactionParts = combine(scanParts, draftParts, ::NutritionInteractionParts)

    val uiState: StateFlow<NutritionUiState> = combine(
        workoutRepository.observeActiveGoal(),
        nutritionParts,
        nutritionRepository.observeAllNutrition(),
        nutritionRepository.observeMealTemplates(),
        interactionParts,
    ) { goal, nutrition, allNutrition, templates, interaction ->
        val fallbackLimit = when (goal?.config?.goal) {
            com.example.myapplication.core.model.FitnessGoal.MUSCLE_GAIN -> 2700
            com.example.myapplication.core.model.FitnessGoal.FAT_LOSS_CONDITIONING -> 1800
            com.example.myapplication.core.model.FitnessGoal.ENDURANCE -> 2200
            com.example.myapplication.core.model.FitnessGoal.GENERAL_FITNESS -> 2000
            null -> 2000
        }
        val history = allNutrition.filter { it.epochDay < todayEpochDay && it.consumed.calories > 0 }
        NutritionUiState.Content(
            calorieLimit = nutrition.today.target?.calories ?: fallbackLimit,
            caloriesEaten = nutrition.data.caloriesEaten,
            proteinEaten = nutrition.data.proteinEaten,
            carbsEaten = nutrition.data.carbsEaten,
            fatEaten = nutrition.data.fatEaten,
            sweatActive = nutrition.data.sweatActive,
            sweatExerciseName = nutrition.data.sweatExerciseName,
            sweatExtraSets = nutrition.data.sweatExtraSets,
            scanResult = interaction.scan.result,
            scanning = interaction.scan.scanning,
            scanError = interaction.scan.error,
            history = history,
            draft = interaction.draft.draft,
            mealTemplates = templates,
            savingDraft = interaction.draft.saving,
            pendingDeleteTemplateId = interaction.draft.pendingDeleteTemplateId,
            templateNameEdit = interaction.draft.templateNameEdit,
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = NutritionUiState.Loading,
    )

    fun scanFood(bitmap: Bitmap?) {
        viewModelScope.launch {
            if (!cloudAiConsent.first()) {
                scanningState.value = false
                scanResultState.value = null
                scanErrorState.value = "Hãy bật đồng ý AI Cloud trong Hồ sơ trước khi quét món ăn."
                return@launch
            }
            if (com.example.myapplication.app.BackendConfig.baseUrl == null) {
                scanningState.value = false
                scanResultState.value = null
                scanErrorState.value = "Chưa cấu hình địa chỉ máy chủ trong mục Cài đặt."
                return@launch
            }
            scanningState.value = true
            scanErrorState.value = null
            scanResultState.value = null

            try {
                val result = foodAnalysisClient.analyze(bitmap)
                if (result != null) {
                    scanResultState.value = null
                    draftEntrySource = EntrySource.CAMERA_ANALYSIS
                    draftSweatPayment = result.sweatPayment
                    draftNutrientsRecorded = false
                    draftState.value = result.toEditableDraft()
                } else {
                    scanErrorState.value = "Khong the phan tich du lieu mon an tra ve."
                }
            } catch (cancelled: CancellationException) {
                scanErrorState.value = null
                throw cancelled
            } catch (error: Exception) {
                scanErrorState.value = "Loi ket noi toi server backend: ${error.message}"
            } finally {
                scanningState.value = false
            }
        }
    }

    fun acceptScanResult() {
        acceptDraft()
    }

    fun startManualEntry() {
        if (savingDraftState.value) return
        draftEntrySource = EntrySource.MANUAL
        draftSweatPayment = null
        draftNutrientsRecorded = false
        draftState.value = EditableNutritionDraft("", "", "", "", "")
    }

    fun updateDraftName(value: String) = updateDraft { copy(nameVi = value, errors = emptyMap()) }
    fun updateDraftCalories(value: String) = updateDraft { copy(caloriesText = value, errors = emptyMap()) }
    fun updateDraftProtein(value: String) = updateDraft { copy(proteinText = value, errors = emptyMap()) }
    fun updateDraftCarbs(value: String) = updateDraft { copy(carbsText = value, errors = emptyMap()) }
    fun updateDraftFat(value: String) = updateDraft { copy(fatText = value, errors = emptyMap()) }
    fun setDraftSaveAsTemplate(value: Boolean) = updateDraft { copy(saveAsTemplate = value) }

    fun acceptDraft() {
        val draft = draftState.value ?: return
        if (savingDraftState.value) return
        val parsed = draft.validateAndParse()
        if (parsed.errors.isNotEmpty()) {
            draftState.value = draft.copy(errors = parsed.errors)
            return
        }
        val nutrients = requireNotNull(parsed.nutrients)
        val normalizedName = draft.nameVi.trim()
        val source = draftEntrySource
        val sweatPayment = draftSweatPayment
        savingDraftState.value = true
        viewModelScope.launch {
            try {
                if (!draftNutrientsRecorded) {
                    nutritionRepository.addNutrients(currentEpochDay(), nutrients, source)
                    sweatPayment?.let { proposal ->
                        nutritionRepository.setSweatPayment(
                            proposal.exerciseId,
                            proposal.exerciseName,
                            proposal.extraSets,
                            true,
                        )
                    }
                    draftNutrientsRecorded = true
                }
                if (draft.saveAsTemplate) {
                    nutritionRepository.saveMealTemplate(null, normalizedName, nutrients)
                }
                draftState.value = null
                draftSweatPayment = null
                draftNutrientsRecorded = false
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                draftState.value = draft.copy(
                    errors = mapOf("submit" to "Không thể lưu món ăn. Vui lòng thử lại."),
                )
            } finally {
                savingDraftState.value = false
            }
        }
    }

    fun discardScanResult() {
        scanResultState.value = null
        draftState.value = null
        draftSweatPayment = null
        draftNutrientsRecorded = false
    }

    fun applyTemplate(id: Long) {
        if (savingDraftState.value) return
        savingDraftState.value = true
        viewModelScope.launch {
            try {
                nutritionRepository.applyMealTemplate(id, currentEpochDay())
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                scanErrorState.value = "Không thể thêm bữa ăn đã lưu. Vui lòng thử lại."
            } finally {
                savingDraftState.value = false
            }
        }
    }

    fun requestDeleteTemplate(id: Long) {
        if (!savingDraftState.value) pendingDeleteTemplateId.value = id
    }

    fun cancelDeleteTemplate() {
        if (!savingDraftState.value) pendingDeleteTemplateId.value = null
    }

    fun confirmDeleteTemplate() {
        val id = pendingDeleteTemplateId.value ?: return
        if (savingDraftState.value) return
        pendingDeleteTemplateId.value = null
        savingDraftState.value = true
        viewModelScope.launch {
            try {
                nutritionRepository.deleteMealTemplate(id)
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                scanErrorState.value = "Không thể xóa bữa ăn đã lưu. Vui lòng thử lại."
            } finally {
                savingDraftState.value = false
            }
        }
    }

    fun startRenameTemplate(id: Long) {
        if (savingDraftState.value) return
        val template = (uiState.value as? NutritionUiState.Content)
            ?.mealTemplates?.firstOrNull { it.id == id } ?: return
        templateNameEdit.value = TemplateNameEdit(id, template.nameVi)
    }

    fun updateTemplateName(value: String) {
        if (!savingDraftState.value) templateNameEdit.value = templateNameEdit.value?.copy(nameVi = value, error = null)
    }

    fun cancelRenameTemplate() {
        if (!savingDraftState.value) templateNameEdit.value = null
    }

    fun confirmRenameTemplate() {
        val edit = templateNameEdit.value ?: return
        val template = (uiState.value as? NutritionUiState.Content)
            ?.mealTemplates?.firstOrNull { it.id == edit.id } ?: return
        val normalized = edit.nameVi.trim()
        if (normalized.length !in 1..60) {
            templateNameEdit.value = edit.copy(error = "Tên món cần từ 1 đến 60 ký tự.")
            return
        }
        if (savingDraftState.value) return
        savingDraftState.value = true
        viewModelScope.launch {
            try {
                nutritionRepository.saveMealTemplate(template.id, normalized, template.nutrients)
                templateNameEdit.value = null
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (_: Exception) {
                templateNameEdit.value = edit.copy(error = "Không thể đổi tên. Vui lòng thử lại.")
            } finally {
                savingDraftState.value = false
            }
        }
    }

    fun updateScanResult(
        dishName: String,
        totalCalories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
    ) {
        val current = scanResultState.value ?: return
        scanResultState.value = current.copy(
            dishName = dishName,
            totalCalories = totalCalories,
            proteinGrams = proteinGrams,
            carbsGrams = carbsGrams,
            fatGrams = fatGrams,
        )
    }

    fun scanBarcode(barcode: String) {
        viewModelScope.launch {
            scanningState.value = true
            scanErrorState.value = null
            scanResultState.value = null
            
            try {
                val result = foodAnalysisClient.lookupBarcode(barcode)
                scanningState.value = false
                if (result != null) {
                    val override = personalizationDao?.foodOverrideNow(result.dishName)
                    val finalResult = if (override != null) {
                        result.copy(
                            totalCalories = override.totalCalories,
                            proteinGrams = override.proteinGrams,
                            carbsGrams = override.carbsGrams,
                            fatGrams = override.fatGrams,
                            needsUserConfirmation = false,
                            calculationProcess = "${result.calculationProcess}\n(Đã áp dụng khẩu phần quen thuộc của bạn)"
                        )
                    } else {
                        result
                    }
                    scanResultState.value = finalResult
                } else {
                    scanErrorState.value = "Mã vạch $barcode chưa có trong dữ liệu. Thử lại với ảnh chụp bảng dinh dưỡng!"
                }
            } catch (e: Exception) {
                scanningState.value = false
                scanErrorState.value = "Lỗi kết nối tra cứu mã vạch: ${e.message}"
            }
        }
    }

    fun clearSweat() {
        viewModelScope.launch { nutritionRepository.clearSweatPayment() }
    }

    fun resetDaily() {
        viewModelScope.launch { nutritionRepository.resetDaily() }
    }

    private fun updateDraft(transform: EditableNutritionDraft.() -> EditableNutritionDraft) {
        if (savingDraftState.value) return
        draftState.value = draftState.value?.transform()
    }
}

private data class NutritionStateParts(
    val data: NutritionData,
    val today: NutritionDay,
)

private data class ScanStateParts(val scanning: Boolean, val result: ScanResult?, val error: String?)
private data class DraftStateParts(
    val draft: EditableNutritionDraft?,
    val saving: Boolean,
    val pendingDeleteTemplateId: Long?,
    val templateNameEdit: TemplateNameEdit?,
)
private data class NutritionInteractionParts(val scan: ScanStateParts, val draft: DraftStateParts)
private data class ParsedDraft(val nutrients: Nutrients?, val errors: Map<String, String>)

private fun ScanResult.toEditableDraft() = EditableNutritionDraft(
    nameVi = dishName,
    caloriesText = totalCalories.toString(),
    proteinText = proteinGrams.toString(),
    carbsText = carbsGrams.toString(),
    fatText = fatGrams.toString(),
)

private fun EditableNutritionDraft.validateAndParse(): ParsedDraft {
    val errors = mutableMapOf<String, String>()
    val normalizedName = nameVi.trim()
    if (normalizedName.length !in 1..60) errors["nameVi"] = "Tên món cần từ 1 đến 60 ký tự."
    fun parse(field: String, raw: String): Int? {
        val value = raw.trim().toIntOrNull()
        if (value == null || value < 0) errors[field] = "Nhập số nguyên không âm."
        return value
    }
    val calories = parse("calories", caloriesText)
    val protein = parse("protein", proteinText)
    val carbs = parse("carbs", carbsText)
    val fat = parse("fat", fatText)
    if (calories != null && calories <= 0) errors["calories"] = "Calo phải lớn hơn 0."
    return ParsedDraft(
        nutrients = if (errors.isEmpty()) Nutrients(calories!!, protein!!, carbs!!, fat!!) else null,
        errors = errors,
    )
}
