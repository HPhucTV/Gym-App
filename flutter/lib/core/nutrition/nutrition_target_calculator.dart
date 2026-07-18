import 'dart:math';
import '../model/nutrition_models.dart';
import '../model/profile_models.dart';

class NutritionTargetCalculator {
  static const double _maleConstant = 5.0;
  static const double _femaleConstant = -161.0;
  static const double _proteinGramsPerKg = 2.0;
  static const double _fatGramsPerKg = 0.8;
  static const double _caloriesPerProteinGram = 4.0;
  static const double _caloriesPerCarbGram = 4.0;
  static const double _caloriesPerFatGram = 9.0;
  static const double _automaticChangeRate = 0.05;
  static const int _maximumAutomaticCalories = 150;
  static const double _maximumKilogramsPerWeek = 0.9;
  static const double _daysPerWeek = 7.0;
  static const int _minimumAge = 18;
  static const int _maximumAge = 100;
  static const double _minimumHeightCm = 100.0;
  static const double _maximumHeightCm = 250.0;
  static const double _minimumWeightKg = 30.0;
  static const double _maximumWeightKg = 350.0;

  CalculationResult calculate({
    required PersonalProfile profile,
    required int ageYears,
    TargetTimeline? timeline,
  }) {
    final profileIssues = _validate(profile, ageYears);
    if (profileIssues != null) {
      return CalculationResult.needsProfessionalReview(profileIssues);
    }
    final timelineIssues = _validateTimeline(profile, timeline);
    if (timelineIssues != null) {
      return CalculationResult.needsProfessionalReview(timelineIssues);
    }

    final double rawBasalCalories = 10 * profile.currentWeightKg +
        6.25 * profile.heightCm -
        5 * ageYears +
        (profile.metabolicSex == MetabolicSex.male
            ? _maleConstant
            : _femaleConstant);

    final rawMaintenanceCalories =
        rawBasalCalories * profile.activityLevel.multiplier;

    final double rawTargetCalories;
    if (profile.targetWeightKg < profile.currentWeightKg) {
      final double rate;
      switch (profile.goalPace) {
        case GoalPace.mild:
          rate = 0.10;
          break;
        case GoalPace.standard:
          rate = 0.15;
          break;
        case GoalPace.aggressive:
          rate = 0.20;
          break;
      }
      rawTargetCalories = rawMaintenanceCalories * (1.0 - rate);
    } else if (profile.targetWeightKg > profile.currentWeightKg) {
      final double rate;
      switch (profile.goalPace) {
        case GoalPace.mild:
          rate = 0.05;
          break;
        case GoalPace.standard:
          rate = 0.10;
          break;
        case GoalPace.aggressive:
          rate = 0.15;
          break;
      }
      rawTargetCalories = rawMaintenanceCalories * (1.0 + rate);
    } else {
      rawTargetCalories = rawMaintenanceCalories;
    }

    final rawProteinGrams = profile.currentWeightKg * _proteinGramsPerKg;
    final rawFatGrams = profile.currentWeightKg * _fatGramsPerKg;
    final rawCarbsGrams = (rawTargetCalories -
            rawProteinGrams * _caloriesPerProteinGram -
            rawFatGrams * _caloriesPerFatGram) /
        _caloriesPerCarbGram;

    if (rawBasalCalories <= 0 ||
        rawMaintenanceCalories <= 0 ||
        rawTargetCalories <= 0 ||
        rawCarbsGrams < 0) {
      return const CalculationResult.needsProfessionalReview(
        "Không thể tạo mục tiêu dinh dưỡng an toàn từ dữ liệu hiện tại.",
      );
    }

    return CalculationResult.target(
      NutritionTarget(
        basalCalories: rawBasalCalories.round(),
        maintenanceCalories: rawMaintenanceCalories.round(),
        calories: rawTargetCalories.round(),
        proteinGrams: rawProteinGrams.round(),
        carbsGrams: rawCarbsGrams.round(),
        fatGrams: rawFatGrams.round(),
        audit: NutritionTargetAudit(
          rawBasalCalories: rawBasalCalories,
          rawMaintenanceCalories: rawMaintenanceCalories,
          rawTargetCalories: rawTargetCalories,
          rawProteinGrams: rawProteinGrams,
          rawCarbsGrams: rawCarbsGrams,
          rawFatGrams: rawFatGrams,
        ),
      ),
    );
  }

  int capAutomaticCalorieDelta(int currentCalories, int requestedDelta) {
    if (currentCalories <= 0) return 0;

    final fivePercentCap = (currentCalories * _automaticChangeRate).round();
    final cap = min(fivePercentCap, _maximumAutomaticCalories);
    return requestedDelta.clamp(-cap, cap);
  }

  String? _validate(PersonalProfile profile, int ageYears) {
    if (ageYears < _minimumAge || ageYears > _maximumAge) {
      return "Độ tuổi cần nằm trong khoảng 18 đến 100.";
    }
    if (!profile.heightCm.isFinite ||
        profile.heightCm < _minimumHeightCm ||
        profile.heightCm > _maximumHeightCm) {
      return "Chiều cao nằm ngoài phạm vi hỗ trợ.";
    }
    if (!profile.currentWeightKg.isFinite ||
        profile.currentWeightKg < _minimumWeightKg ||
        profile.currentWeightKg > _maximumWeightKg) {
      return "Cân nặng hiện tại nằm ngoài phạm vi hỗ trợ.";
    }
    if (!profile.targetWeightKg.isFinite ||
        profile.targetWeightKg < _minimumWeightKg ||
        profile.targetWeightKg > _maximumWeightKg) {
      return "Cân nặng mục tiêu nằm ngoài phạm vi hỗ trợ.";
    }
    if (!profile.personalizationConsent) {
      return "Cần đồng ý sử dụng dữ liệu hồ sơ trước khi tính mục tiêu.";
    }
    return null;
  }

  String? _validateTimeline(PersonalProfile profile, TargetTimeline? timeline) {
    if (timeline == null) return null;

    final durationDays = timeline.targetDateEpochDay - timeline.todayEpochDay;
    if (durationDays <= 0) {
      return "Ngày mục tiêu cần nằm sau ngày hiện tại.";
    }

    final durationWeeks = durationDays / _daysPerWeek;
    final kilogramsPerWeek =
        (profile.targetWeightKg - profile.currentWeightKg).abs() / durationWeeks;

    if (kilogramsPerWeek > _maximumKilogramsPerWeek) {
      return "Tốc độ thay đổi cân nặng vượt 0,9 kg mỗi tuần; hãy chọn thời hạn dài hơn hoặc trao đổi với chuyên gia.";
    }
    return null;
  }
}
