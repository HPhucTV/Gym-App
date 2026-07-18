import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/profile_models.dart';
import '../../core/model/nutrition_models.dart';
import '../../core/nutrition/nutrition_target_calculator.dart';
import '../../core/nutrition/nutrition_score_calculator.dart';
import '../../data/providers/data_providers.dart';
import '../../data/local/database.dart';
import 'weekly_checkin_ui_state.dart';

final weeklyCheckInProfileProvider =
    StreamProvider<PersonalProfileData?>((ref) {
  final db = ref.watch(gymDatabaseProvider);
  return db.personalizationDao.observeProfile();
});

final weeklyCheckInAllCheckInsProvider =
    StreamProvider<List<WeeklyCheckInData>>((ref) {
  final db = ref.watch(gymDatabaseProvider);
  return db.personalizationDao.observeAllCheckIns();
});

final weeklyCheckInAllNutritionProvider =
    StreamProvider<List<DailyNutritionData>>((ref) {
  final db = ref.watch(gymDatabaseProvider);
  return db.personalizationDao.observeAllNutrition();
});

class WeeklyCheckInState {
  final String weightKgStr;
  final int energy;
  final int hunger;
  final int recovery;
  final int sleepQuality;
  final String note;
  final bool isSubmitting;
  final String? error;
  final bool success;
  final List<String> validationErrors;

  const WeeklyCheckInState({
    this.weightKgStr = "",
    this.energy = 3,
    this.hunger = 3,
    this.recovery = 3,
    this.sleepQuality = 3,
    this.note = "",
    this.isSubmitting = false,
    this.error,
    this.success = false,
    this.validationErrors = const [],
  });

  WeeklyCheckInState copyWith({
    String? weightKgStr,
    int? energy,
    int? hunger,
    int? recovery,
    int? sleepQuality,
    String? note,
    bool? isSubmitting,
    String? error,
    bool? success,
    List<String>? validationErrors,
  }) {
    return WeeklyCheckInState(
      weightKgStr: weightKgStr ?? this.weightKgStr,
      energy: energy ?? this.energy,
      hunger: hunger ?? this.hunger,
      recovery: recovery ?? this.recovery,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

class WeeklyCheckInNotifier extends Notifier<WeeklyCheckInState> {
  @override
  WeeklyCheckInState build() {
    // Proactively prepopulate weight when profile becomes available
    ref.listen(weeklyCheckInProfileProvider, (prev, next) {
      final profile = next.value;
      if (profile != null && state.weightKgStr.isEmpty) {
        state = state.copyWith(weightKgStr: profile.currentWeightKg.toString());
      }
    });

    final profile = ref.read(weeklyCheckInProfileProvider).value;
    final initialWeight =
        profile != null ? profile.currentWeightKg.toString() : "";
    return WeeklyCheckInState(weightKgStr: initialWeight);
  }

  void updateWeight(String weight) {
    state = state.copyWith(weightKgStr: weight);
  }

  void updateEnergy(int value) {
    state = state.copyWith(energy: value.clamp(1, 5));
  }

  void updateHunger(int value) {
    state = state.copyWith(hunger: value.clamp(1, 5));
  }

  void updateRecovery(int value) {
    state = state.copyWith(recovery: value.clamp(1, 5));
  }

  void updateSleepQuality(int value) {
    state = state.copyWith(sleepQuality: value.clamp(1, 5));
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  void clearSuccess() {
    state = state.copyWith(success: false);
  }

  Future<void> submitCheckIn() async {
    final parsedWeight =
        double.tryParse(state.weightKgStr.trim().replaceAll(',', '.'));
    final localErrors = <String>[];

    if (parsedWeight == null || parsedWeight < 30.0 || parsedWeight > 350.0) {
      localErrors
          .add("Cân nặng hiện tại không hợp lệ (phải từ 30 đến 350 kg).");
    }

    if (localErrors.isNotEmpty) {
      state = state.copyWith(validationErrors: localErrors);
      return;
    }

    state = state.copyWith(
      validationErrors: const [],
      isSubmitting: true,
      error: null,
    );

    try {
      final epochDayVal = currentLocalEpochDay();
      final db = ref.read(gymDatabaseProvider);
      final profile = await db.personalizationDao.profileNow();

      if (profile == null) {
        state = state.copyWith(
          error: "Chưa thiết lập hồ sơ cá nhân.",
          isSubmitting: false,
        );
        return;
      }

      final nowMillis = DateTime.now().millisecondsSinceEpoch;

      // 1. Save check-in
      final checkIn = WeeklyCheckInData(
        weekStartEpochDay: epochDayVal,
        weightKg: parsedWeight!,
        energy: state.energy,
        hunger: state.hunger,
        recovery: state.recovery,
        sleepQuality: state.sleepQuality,
        note: state.note.trim().isEmpty ? null : state.note.trim(),
        createdAtEpochMillis: nowMillis,
      );
      await db.personalizationDao.upsertWeeklyCheckIn(checkIn);

      // 2. Log weight measurement
      await db.personalizationDao.upsertWeight(
        WeightMeasurement(
          epochDay: epochDayVal,
          weightKg: parsedWeight,
          recordedAtEpochMillis: nowMillis,
        ),
      );

      // 3. Update currentWeightKg in profile
      final updatedProfile = profile.copyWith(
        currentWeightKg: parsedWeight,
        updatedAtEpochMillis: nowMillis,
      );
      await db.personalizationDao.upsertProfile(updatedProfile);

      // 4. Recalculate nutrition targets if consent is active
      if (updatedProfile.personalizationConsent) {
        final domainProfile = PersonalProfile(
          birthDateEpochDay: updatedProfile.birthDateEpochDay,
          metabolicSex: updatedProfile.metabolicSex,
          heightCm: updatedProfile.heightCm,
          currentWeightKg: updatedProfile.currentWeightKg,
          targetWeightKg: updatedProfile.targetWeightKg,
          activityLevel: updatedProfile.activityLevel,
          goalPace: updatedProfile.goalPace,
          personalizationConsent: updatedProfile.personalizationConsent,
          cloudAiConsent: updatedProfile.cloudAiConsent,
        );
        final birthDate = DateTime.fromMillisecondsSinceEpoch(
            updatedProfile.birthDateEpochDay * 24 * 60 * 60 * 1000,
            isUtc: true);
        final todayDate = DateTime.fromMillisecondsSinceEpoch(
            epochDayVal * 24 * 60 * 60 * 1000,
            isUtc: true);
        int age = todayDate.year - birthDate.year;
        if (todayDate.month < birthDate.month ||
            (todayDate.month == birthDate.month &&
                todayDate.day < birthDate.day)) {
          age--;
        }
        final calculator = NutritionTargetCalculator();
        final calcResult = calculator.calculate(
          profile: domainProfile,
          ageYears: age,
        );
        await calcResult.mapOrNull(
          target: (targetVal) async {
            await ref.read(nutritionRepositoryProvider).setTarget(
                  epochDayVal,
                  targetVal.value,
                );
          },
        );
      }

      // 5. Evaluate weekly adaptation
      try {
        final adaptationCoordinator =
            ref.read(weeklyAdaptationCoordinatorProvider);
        await adaptationCoordinator.evaluateAfterCheckIn(epochDayVal);
      } catch (e) {
        state = state.copyWith(
          error: "Đã lưu check-in nhưng chưa thể làm mới đề xuất thích nghi.",
          success: true,
          isSubmitting: false,
        );
        return;
      }

      state = state.copyWith(
        success: true,
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: "Lỗi khi lưu check-in: $e",
        isSubmitting: false,
      );
    }
  }
}

final weeklyCheckInNotifierProvider =
    NotifierProvider<WeeklyCheckInNotifier, WeeklyCheckInState>(
  WeeklyCheckInNotifier.new,
);

final weeklyCheckInUiStateProvider = Provider<WeeklyCheckInUiState>((ref) {
  final profileAsync = ref.watch(weeklyCheckInProfileProvider);
  final checkInsAsync = ref.watch(weeklyCheckInAllCheckInsProvider);
  final nutritionAsync = ref.watch(weeklyCheckInAllNutritionProvider);
  final formState = ref.watch(weeklyCheckInNotifierProvider);

  if (profileAsync.isLoading ||
      checkInsAsync.isLoading ||
      nutritionAsync.isLoading) {
    return WeeklyCheckInLoading();
  }

  final profile = profileAsync.value;
  if (profile == null) {
    return WeeklyCheckInNoProfile();
  }

  final checkIns = checkInsAsync.value ?? [];
  final allNutrition = nutritionAsync.value ?? [];

  final today = currentLocalEpochDay();
  final pastWeekNutrition = allNutrition
      .where((n) =>
          n.epochDay >= today - 7 &&
          n.epochDay < today &&
          n.consumedCalories > 0)
      .toList();

  CheckInHistorySummary nutritionStats;
  if (pastWeekNutrition.isNotEmpty) {
    final totalCal = pastWeekNutrition
        .map((n) => n.consumedCalories)
        .reduce((a, b) => a + b);
    final totalProt = pastWeekNutrition
        .map((n) => n.consumedProteinGrams)
        .reduce((a, b) => a + b);
    final totalCarbs = pastWeekNutrition
        .map((n) => n.consumedCarbsGrams)
        .reduce((a, b) => a + b);
    final totalFat = pastWeekNutrition
        .map((n) => n.consumedFatGrams)
        .reduce((a, b) => a + b);

    final scores = pastWeekNutrition.map((day) {
      final targetForScore =
          (day.targetCalories != null && day.targetCalories! > 0)
              ? NutritionTarget(
                  basalCalories: day.targetBasalCalories ?? 0,
                  maintenanceCalories: day.targetMaintenanceCalories ?? 0,
                  calories: day.targetCalories!,
                  proteinGrams: day.targetProteinGrams ?? 0,
                  carbsGrams: day.targetCarbsGrams ?? 0,
                  fatGrams: day.targetFatGrams ?? 0,
                  audit: NutritionTargetAudit(
                    rawBasalCalories: (day.targetBasalCalories ?? 0).toDouble(),
                    rawMaintenanceCalories:
                        (day.targetMaintenanceCalories ?? 0).toDouble(),
                    rawTargetCalories: (day.targetCalories!).toDouble(),
                    rawProteinGrams: (day.targetProteinGrams ?? 0).toDouble(),
                    rawCarbsGrams: (day.targetCarbsGrams ?? 0).toDouble(),
                    rawFatGrams: (day.targetFatGrams ?? 0).toDouble(),
                  ),
                )
              : const NutritionTarget(
                  basalCalories: 2000,
                  maintenanceCalories: 2000,
                  calories: 2000,
                  proteinGrams: 125,
                  carbsGrams: 250,
                  fatGrams: 55,
                  audit: NutritionTargetAudit(
                    rawBasalCalories: 2000.0,
                    rawMaintenanceCalories: 2000.0,
                    rawTargetCalories: 2000.0,
                    rawProteinGrams: 125.0,
                    rawCarbsGrams: 250.0,
                    rawFatGrams: 55.0,
                  ),
                );

      final consumed = Nutrients(
        calories: day.consumedCalories,
        proteinGrams: day.consumedProteinGrams,
        carbsGrams: day.consumedCarbsGrams,
        fatGrams: day.consumedFatGrams,
        fiberGrams: day.consumedFiberGrams,
      );

      return NutritionScoreCalculator.calculateScore(
        consumed: consumed,
        target: targetForScore,
        waterIntakeMl: day.waterIntakeMl,
      ).score;
    }).toList();

    final avgCal = totalCal.toDouble() / pastWeekNutrition.length;
    final avgProt = totalProt.toDouble() / pastWeekNutrition.length;
    final avgCarbs = totalCarbs.toDouble() / pastWeekNutrition.length;
    final avgFat = totalFat.toDouble() / pastWeekNutrition.length;
    final avgScore =
        scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

    nutritionStats = CheckInHistorySummary(
      averageWeeklyCalories: avgCal,
      averageWeeklyScore: avgScore,
      averageWeeklyProtein: avgProt,
      averageWeeklyCarbs: avgCarbs,
      averageWeeklyFat: avgFat,
    );
  } else {
    nutritionStats = const CheckInHistorySummary();
  }

  final historySummary = () {
    if (checkIns.isEmpty) {
      return nutritionStats;
    } else {
      final weightChange = checkIns.length >= 2
          ? checkIns[0].weightKg - checkIns[1].weightKg
          : null;
      final avgRecovery =
          checkIns.map((c) => c.recovery).reduce((a, b) => a + b) /
              checkIns.length;
      final avgSleep =
          checkIns.map((c) => c.sleepQuality).reduce((a, b) => a + b) /
              checkIns.length;

      return nutritionStats.copyWith(
        weightChangeKg: weightChange,
        averageRecovery: avgRecovery.isNaN ? 0.0 : avgRecovery,
        averageSleep: avgSleep.isNaN ? 0.0 : avgSleep,
        totalCheckIns: checkIns.length,
      );
    }
  }();

  return WeeklyCheckInInput(
    weightKgStr: formState.weightKgStr,
    energy: formState.energy,
    hunger: formState.hunger,
    recovery: formState.recovery,
    sleepQuality: formState.sleepQuality,
    note: formState.note,
    isSubmitting: formState.isSubmitting,
    error: formState.error,
    success: formState.success,
    validationErrors: formState.validationErrors,
    historySummary: historySummary,
  );
});
