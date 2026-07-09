package com.example.myapplication.feature.checkin

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.core.nutrition.NutritionTargetCalculator
import com.example.myapplication.data.NutritionRepository
import com.example.myapplication.data.WeeklyAdaptationCoordinator
import com.example.myapplication.data.local.PersonalizationDao
import com.example.myapplication.data.local.WeeklyCheckInEntity
import com.example.myapplication.data.local.WeightMeasurementEntity
import java.time.LocalDate
import java.time.Period
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class WeeklyCheckInViewModel(
    private val personalizationDao: PersonalizationDao,
    private val nutritionRepository: NutritionRepository,
    private val adaptationCoordinator: WeeklyAdaptationCoordinator? = null,
    private val currentEpochDay: () -> Long = { LocalDate.now().toEpochDay() },
    private val nowEpochMillis: () -> Long = { System.currentTimeMillis() },
) : ViewModel() {

    private val isSubmittingState = MutableStateFlow(false)
    private val errorState = MutableStateFlow<String?>(null)
    private val successState = MutableStateFlow(false)
    private val validationErrorsState = MutableStateFlow<List<String>>(emptyList())

    // Form fields
    private val weightState = MutableStateFlow("")
    private val energyState = MutableStateFlow(3)
    private val hungerState = MutableStateFlow(3)
    private val recoveryState = MutableStateFlow(3)
    private val sleepQualityState = MutableStateFlow(3)
    private val noteState = MutableStateFlow("")

    private val profileLoaded = MutableStateFlow<Boolean?>(null) // null = loading, false = no profile, true = loaded

    init {
        viewModelScope.launch {
            val profile = personalizationDao.profileNow()
            if (profile == null) {
                profileLoaded.value = false
            } else {
                profileLoaded.value = true
                val latestWeight = personalizationDao.latestWeightNow()?.weightKg ?: profile.currentWeightKg
                weightState.value = latestWeight.toString()
            }
        }
    }

    private val formState = combine(
        weightState,
        energyState,
        hungerState,
        recoveryState,
        sleepQualityState,
        ::CheckInFormState,
    )
    private val submissionState = combine(
        noteState,
        isSubmittingState,
        errorState,
        successState,
        validationErrorsState,
        ::CheckInSubmissionState,
    )

    val uiState: StateFlow<WeeklyCheckInUiState> = combine(
        profileLoaded,
        formState,
        submissionState,
        personalizationDao.observeAllCheckIns(),
        personalizationDao.observeAllNutrition(),
    ) { loaded, form, submission, checkIns, allNutrition ->
        val today = currentEpochDay()
        val pastWeekNutrition = allNutrition.filter { it.epochDay in (today - 7)..<today && it.consumedCalories > 0 }

        val nutritionStats = if (pastWeekNutrition.isNotEmpty()) {
            val totalCal = pastWeekNutrition.sumOf { it.consumedCalories }
            val totalProt = pastWeekNutrition.sumOf { it.consumedProteinGrams }
            val totalCarbs = pastWeekNutrition.sumOf { it.consumedCarbsGrams }
            val totalFat = pastWeekNutrition.sumOf { it.consumedFatGrams }
            val scores = pastWeekNutrition.map { day ->
                val targetForScore = if (day.targetCalories != null && day.targetCalories > 0) {
                    com.example.myapplication.core.nutrition.NutritionTarget(
                        basalCalories = day.targetBasalCalories ?: 0,
                        maintenanceCalories = day.targetMaintenanceCalories ?: 0,
                        calories = day.targetCalories,
                        proteinGrams = day.targetProteinGrams ?: 0,
                        carbsGrams = day.targetCarbsGrams ?: 0,
                        fatGrams = day.targetFatGrams ?: 0,
                        audit = com.example.myapplication.core.nutrition.NutritionTargetAudit(
                            (day.targetBasalCalories ?: 0).toDouble(),
                            (day.targetMaintenanceCalories ?: 0).toDouble(),
                            (day.targetCalories).toDouble(),
                            (day.targetProteinGrams ?: 0).toDouble(),
                            (day.targetCarbsGrams ?: 0).toDouble(),
                            (day.targetFatGrams ?: 0).toDouble()
                        )
                    )
                } else {
                    com.example.myapplication.core.nutrition.NutritionTarget(
                        basalCalories = 2000,
                        maintenanceCalories = 2000,
                        calories = 2000,
                        proteinGrams = 125,
                        carbsGrams = 250,
                        fatGrams = 55,
                        audit = com.example.myapplication.core.nutrition.NutritionTargetAudit(2000.0, 2000.0, 2000.0, 125.0, 250.0, 55.0)
                    )
                }
                val consumed = com.example.myapplication.core.nutrition.Nutrients(
                    calories = day.consumedCalories,
                    proteinGrams = day.consumedProteinGrams,
                    carbsGrams = day.consumedCarbsGrams,
                    fatGrams = day.consumedFatGrams,
                    fiberGrams = day.consumedFiberGrams
                )
                com.example.myapplication.core.nutrition.NutritionScoreCalculator.calculateScore(
                    consumed = consumed,
                    target = targetForScore,
                    waterIntakeMl = day.waterIntakeMl
                ).score
            }
            CheckInHistorySummary(
                averageWeeklyCalories = totalCal.toDouble() / pastWeekNutrition.size,
                averageWeeklyScore = scores.average(),
                averageWeeklyProtein = totalProt.toDouble() / pastWeekNutrition.size,
                averageWeeklyCarbs = totalCarbs.toDouble() / pastWeekNutrition.size,
                averageWeeklyFat = totalFat.toDouble() / pastWeekNutrition.size
            )
        } else {
            CheckInHistorySummary()
        }

        val historySummary = if (checkIns.isEmpty()) {
            nutritionStats
        } else {
            val weightChange = if (checkIns.size >= 2) {
                checkIns[0].weightKg - checkIns[1].weightKg
            } else null
            val avgRecovery = checkIns.map { it.recovery }.average()
            val avgSleep = checkIns.map { it.sleepQuality }.average()
            nutritionStats.copy(
                weightChangeKg = weightChange,
                averageRecovery = if (avgRecovery.isNaN()) 0.0 else avgRecovery,
                averageSleep = if (avgSleep.isNaN()) 0.0 else avgSleep,
                totalCheckIns = checkIns.size
            )
        }

        when (loaded) {
            null -> WeeklyCheckInUiState.Loading
            false -> WeeklyCheckInUiState.NoProfile
            true -> WeeklyCheckInUiState.Input(
                weightKgStr = form.weight,
                energy = form.energy,
                hunger = form.hunger,
                recovery = form.recovery,
                sleepQuality = form.sleepQuality,
                note = submission.note,
                isSubmitting = submission.isSubmitting,
                error = submission.error,
                success = submission.success,
                validationErrors = submission.validationErrors,
                historySummary = historySummary
            )
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = WeeklyCheckInUiState.Loading
    )

    fun updateWeight(weight: String) {
        weightState.value = weight
    }

    fun updateEnergy(value: Int) {
        energyState.value = value.coerceIn(1, 5)
    }

    fun updateHunger(value: Int) {
        hungerState.value = value.coerceIn(1, 5)
    }

    fun updateRecovery(value: Int) {
        recoveryState.value = value.coerceIn(1, 5)
    }

    fun updateSleepQuality(value: Int) {
        sleepQualityState.value = value.coerceIn(1, 5)
    }

    fun updateNote(value: String) {
        noteState.value = value
    }

    fun clearSuccess() {
        successState.value = false
    }

    fun submitCheckIn() {
        val parsedWeight = parseDoubleLocaleSafe(weightState.value)
        val localErrors = mutableListOf<String>()

        if (parsedWeight == null || parsedWeight !in 30.0..350.0) {
            localErrors.add("Cân nặng hiện tại không hợp lệ (phải từ 30 đến 350 kg).")
        }

        if (localErrors.isNotEmpty()) {
            validationErrorsState.value = localErrors
            return
        }

        validationErrorsState.value = emptyList()
        isSubmittingState.value = true
        errorState.value = null

        viewModelScope.launch {
            try {
                val epochDayVal = currentEpochDay()
                val profile = personalizationDao.profileNow()

                if (profile == null) {
                    errorState.value = "Chưa thiết lập hồ sơ cá nhân."
                    isSubmittingState.value = false
                    return@launch
                }

                // 1. Save check-in
                val checkIn = WeeklyCheckInEntity(
                    weekStartEpochDay = epochDayVal,
                    weightKg = parsedWeight!!,
                    energy = energyState.value,
                    hunger = hungerState.value,
                    recovery = recoveryState.value,
                    sleepQuality = sleepQualityState.value,
                    note = noteState.value.trim().takeIf { it.isNotEmpty() },
                    createdAtEpochMillis = nowEpochMillis()
                )
                personalizationDao.upsertWeeklyCheckIn(checkIn)

                // 2. Log weight measurement
                personalizationDao.upsertWeight(
                    WeightMeasurementEntity(
                        epochDay = epochDayVal,
                        weightKg = parsedWeight,
                        recordedAtEpochMillis = nowEpochMillis()
                    )
                )

                // 3. Update currentWeightKg in profile
                val updatedProfile = profile.copy(
                    currentWeightKg = parsedWeight,
                    updatedAtEpochMillis = nowEpochMillis()
                )
                personalizationDao.upsertProfile(updatedProfile)

                // 4. Recalculate nutrition targets if consent is active
                if (updatedProfile.personalizationConsent) {
                    val domainProfile = com.example.myapplication.core.profile.PersonalProfile(
                        birthDateEpochDay = updatedProfile.birthDateEpochDay,
                        metabolicSex = updatedProfile.metabolicSex,
                        heightCm = updatedProfile.heightCm,
                        currentWeightKg = updatedProfile.currentWeightKg,
                        targetWeightKg = updatedProfile.targetWeightKg,
                        activityLevel = updatedProfile.activityLevel,
                        goalPace = updatedProfile.goalPace,
                        personalizationConsent = updatedProfile.personalizationConsent,
                        cloudAiConsent = updatedProfile.cloudAiConsent
                    )
                    val today = LocalDate.ofEpochDay(epochDayVal)
                    val age = Period.between(LocalDate.ofEpochDay(updatedProfile.birthDateEpochDay), today).years
                    val calculator = NutritionTargetCalculator()
                    val calcResult = calculator.calculate(domainProfile, age)
                    if (calcResult is com.example.myapplication.core.nutrition.CalculationResult.Target) {
                        nutritionRepository.setTarget(epochDayVal, calcResult.value)
                    }
                }

                val adaptationError = runCatching {
                    adaptationCoordinator?.evaluateAfterCheckIn(epochDayVal)
                }.exceptionOrNull()
                if (adaptationError != null) {
                    errorState.value = "Đã lưu check-in nhưng chưa thể làm mới đề xuất thích nghi."
                }
                successState.value = true
            } catch (e: Exception) {
                errorState.value = "Lỗi khi lưu check-in: ${e.message}"
            } finally {
                isSubmittingState.value = false
            }
        }
    }

    private fun parseDoubleLocaleSafe(value: String): Double? {
        val cleaned = value.trim().replace(',', '.')
        return cleaned.toDoubleOrNull()
    }
}

private data class CheckInFormState(
    val weight: String,
    val energy: Int,
    val hunger: Int,
    val recovery: Int,
    val sleepQuality: Int,
)

private data class CheckInSubmissionState(
    val note: String,
    val isSubmitting: Boolean,
    val error: String?,
    val success: Boolean,
    val validationErrors: List<String>,
)
