import 'dart:math';
import '../model/adaptation_models.dart';
import '../model/feedback_models.dart';
import '../program/program_phase_planner.dart';
import '../nutrition/nutrition_target_calculator.dart';
import 'weekly_snapshot.dart';

class AdaptationEngine {
  final NutritionTargetCalculator calculator;

  AdaptationEngine({NutritionTargetCalculator? calculator})
      : calculator = calculator ?? NutritionTargetCalculator();

  List<AdaptationDecision> evaluate(WeeklySnapshot snapshot) {
    final decisions = <AdaptationDecision>[];

    // Rule group 1: calorie target adjustment
    if (hasNutritionMinimumData(snapshot)) {
      final calorieDecision = evaluateCalorieAdjustment(snapshot);
      if (calorieDecision != null) {
        decisions.add(calorieDecision);
      }
    }

    // Rule group 2: recovery suggestion
    if (snapshot.latestCheckIn != null) {
      final recoveryDecision = evaluateRecoverySuggestion(snapshot);
      if (recoveryDecision != null) {
        decisions.add(recoveryDecision);
      }
    }

    // Rule group 3: workout volume / missed sessions
    final volumeDecision = evaluateWorkoutVolume(snapshot);
    if (volumeDecision != null) {
      decisions.add(volumeDecision);
    }

    // Rule group 4: confirmed deload from session feedback and recovery
    final deloadDecision = evaluateDeload(snapshot);
    if (deloadDecision != null) {
      decisions.add(deloadDecision);
    }

    return decisions;
  }

  // ── Data quality gates ──────────────────────────────────────────────

  bool hasNutritionMinimumData(WeeklySnapshot snapshot) {
    if (snapshot.trackedDays < MINIMUM_TRACKED_DAYS) return false;
    if (snapshot.latestCheckIn == null) return false;
    if (snapshot.recentWeights.length < MINIMUM_WEIGHT_MEASUREMENTS)
      return false;
    return true;
  }

  // ── Calorie adjustment ──────────────────────────────────────────────

  AdaptationDecision? evaluateCalorieAdjustment(WeeklySnapshot snapshot) {
    if (snapshot.daysSinceLastCalorieDecision < CALORIE_COOLDOWN_DAYS)
      return null;

    final adherenceOk = snapshot.adherencePercent >= MINIMUM_ADHERENCE;

    final weights = snapshot.recentWeights;
    if (weights.length < MINIMUM_WEIGHT_MEASUREMENTS) return null;
    final recentWeight = weights.last;
    final previousWeight = weights[weights.length - 2];
    final weightDelta = recentWeight - previousWeight;

    final wantToLose = snapshot.targetWeightKg < recentWeight;
    final wantToGain = snapshot.targetWeightKg > recentWeight;
    final onTarget = !wantToLose && !wantToGain;

    if (onTarget) return null;

    final int requestedDelta;
    if (wantToLose && weightDelta >= 0) {
      requestedDelta = -calculateSuggestedDelta(snapshot);
    } else if (wantToLose && weightDelta < -MAXIMUM_WEEKLY_WEIGHT_LOSS_KG) {
      requestedDelta = calculateSuggestedDelta(snapshot) ~/ 2;
    } else if (wantToGain && weightDelta <= 0) {
      requestedDelta = calculateSuggestedDelta(snapshot);
    } else if (wantToGain && weightDelta > MAXIMUM_WEEKLY_WEIGHT_GAIN_KG) {
      requestedDelta = -calculateSuggestedDelta(snapshot) ~/ 2;
    } else {
      return null;
    }

    if (requestedDelta == 0) return null;

    final cappedDelta = calculator.capAutomaticCalorieDelta(
      snapshot.currentCalories,
      requestedDelta,
    );

    if (cappedDelta == 0) return null;

    final newCalories = snapshot.currentCalories + cappedDelta;
    final fitsInCap = cappedDelta == requestedDelta;
    final mode = (fitsInCap && adherenceOk)
        ? AdaptationMode.autoApply
        : AdaptationMode.requiresConfirmation;

    final reason =
        buildCalorieReason(cappedDelta, weightDelta, wantToLose, adherenceOk);

    return AdaptationDecision(
      kind: AdaptationKind.calorieTarget,
      mode: mode,
      reasonVi: reason,
      beforeValue: '{"calories":${snapshot.currentCalories}}',
      afterValue: '{"calories":$newCalories}',
      undoPayload: '{"calories":${snapshot.currentCalories}}',
    );
  }

  int calculateSuggestedDelta(WeeklySnapshot snapshot) {
    final fivePercent =
        (snapshot.currentCalories * AUTOMATIC_CHANGE_RATE).round();
    return min(fivePercent, MAXIMUM_AUTOMATIC_CALORIES);
  }

  String buildCalorieReason(
    int delta,
    double weightDelta,
    bool wantToLose,
    bool adherenceOk,
  ) {
    final direction = delta > 0 ? "tăng" : "giảm";
    final absDelta = delta.abs();
    final String weightTrend;
    if (weightDelta > 0.01) {
      weightTrend = "tăng ${weightDelta.toStringAsFixed(1)} kg";
    } else if (weightDelta < -0.01) {
      weightTrend = "giảm ${weightDelta.abs().toStringAsFixed(1)} kg";
    } else {
      weightTrend = "không thay đổi";
    }
    final adherenceNote = !adherenceOk ? " (lưu ý: mức tuân thủ dưới 70%)" : "";
    return "Cân nặng tuần qua $weightTrend. Đề xuất $direction $absDelta kcal/ngày$adherenceNote.";
  }

  // ── Recovery suggestion ─────────────────────────────────────────────

  AdaptationDecision? evaluateRecoverySuggestion(WeeklySnapshot snapshot) {
    if (snapshot.consecutiveLowRecoveryCheckIns < MINIMUM_LOW_RECOVERY_CHECKINS)
      return null;

    return AdaptationDecision(
      kind: AdaptationKind.recoveryDay,
      mode: AdaptationMode.autoApply,
      reasonVi:
          "Khả năng phục hồi thấp trong ${snapshot.consecutiveLowRecoveryCheckIns} "
          "check-in liên tiếp. Đề xuất ưu tiên nghỉ ngơi và giảm cường độ tập luyện.",
      beforeValue: '{"recoveryStatus":"normal"}',
      afterValue: '{"recoveryStatus":"suggested_rest"}',
      undoPayload: '{"recoveryStatus":"normal"}',
    );
  }

  // ── Workout volume / missed sessions ────────────────────────────────

  AdaptationDecision? evaluateWorkoutVolume(WeeklySnapshot snapshot) {
    if (snapshot.daysSinceLastWorkoutDecision < WORKOUT_COOLDOWN_DAYS)
      return null;
    if (snapshot.missedSessions < MINIMUM_MISSED_SESSIONS_FOR_SUGGESTION)
      return null;

    return AdaptationDecision(
      kind: AdaptationKind.workoutVolume,
      mode: AdaptationMode.requiresConfirmation,
      reasonVi: "Đã bỏ lỡ ${snapshot.missedSessions} buổi tập liên tiếp. "
          "Đề xuất điều chỉnh khối lượng tập luyện để phù hợp hơn với lịch trình hiện tại.",
      beforeValue:
          '{"scheduledSessions":${snapshot.scheduledSessionsThisWeek}}',
      afterValue:
          '{"scheduledSessions":${max(1, snapshot.scheduledSessionsThisWeek - 1)}}',
      undoPayload:
          '{"scheduledSessions":${snapshot.scheduledSessionsThisWeek}}',
    );
  }

  // ── Confirmed deload from session feedback and recovery ──────────────

  AdaptationDecision? evaluateDeload(WeeklySnapshot snapshot) {
    if (snapshot.currentProgramPhase == ProgramPhase.deload) return null;
    if (snapshot.daysSinceLastWorkoutDecision < WORKOUT_COOLDOWN_DAYS)
      return null;

    final recent = snapshot.lastDifficulties.length > 4
        ? snapshot.lastDifficulties
            .sublist(snapshot.lastDifficulties.length - 4)
        : snapshot.lastDifficulties;

    if (recent.length < MINIMUM_DIFFICULTY_SAMPLES) return null;
    final hardCount =
        recent.where((d) => d.difficulty == WorkoutDifficulty.hard).length;
    final hardEvidence = hardCount >= MINIMUM_HARD_RATINGS;
    final combinedEvidence = hardCount >= MINIMUM_HARD_WITH_LOW_RECOVERY &&
        snapshot.consecutiveLowRecoveryCheckIns >=
            MINIMUM_LOW_RECOVERY_CHECKINS;

    if (!hardEvidence && !combinedEvidence) return null;

    final pendingSessions = max(1, snapshot.scheduledSessionsThisWeek);
    final String reason;
    if (hardEvidence) {
      reason =
          "$hardCount trong ${recent.length} buổi gần nhất được đánh giá quá nặng. "
          "Đề xuất một tuần giảm tải và chỉ áp dụng sau khi bạn xác nhận.";
    } else {
      reason = "Phản hồi buổi tập nặng đi kèm khả năng phục hồi thấp trong "
          "${snapshot.consecutiveLowRecoveryCheckIns} lần check-in liên tiếp. "
          "Đề xuất một tuần giảm tải và chỉ áp dụng sau khi bạn xác nhận.";
    }

    return AdaptationDecision(
      kind: AdaptationKind.deloadWeek,
      mode: AdaptationMode.requiresConfirmation,
      reasonVi: reason,
      beforeValue:
          '{"pendingSessions":$pendingSessions,"volumeScalePercent":100}',
      afterValue:
          '{"pendingSessions":$pendingSessions,"volumeScalePercent":70}',
      undoPayload:
          '{"pendingSessions":$pendingSessions,"volumeScalePercent":100}',
    );
  }

  // Constants
  static const int MINIMUM_TRACKED_DAYS = 7;
  static const int MINIMUM_WEIGHT_MEASUREMENTS = 2;
  static const int CALORIE_COOLDOWN_DAYS = 7;
  static const int WORKOUT_COOLDOWN_DAYS = 7;
  static const double MINIMUM_ADHERENCE = 0.70;
  static const double AUTOMATIC_CHANGE_RATE = 0.05;
  static const int MAXIMUM_AUTOMATIC_CALORIES = 150;
  static const int MINIMUM_LOW_RECOVERY_CHECKINS = 2;
  static const int MINIMUM_MISSED_SESSIONS_FOR_SUGGESTION = 2;
  static const int MINIMUM_DIFFICULTY_SAMPLES = 3;
  static const int MINIMUM_HARD_RATINGS = 3;
  static const int MINIMUM_HARD_WITH_LOW_RECOVERY = 2;
  static const double MAXIMUM_WEEKLY_WEIGHT_LOSS_KG = 0.9;
  static const double MAXIMUM_WEEKLY_WEIGHT_GAIN_KG = 0.5;
}
