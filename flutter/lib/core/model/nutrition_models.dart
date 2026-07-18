import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_models.freezed.dart';
part 'nutrition_models.g.dart';

@freezed
abstract class NutritionTargetAudit with _$NutritionTargetAudit {
  const factory NutritionTargetAudit({
    required double rawBasalCalories,
    required double rawMaintenanceCalories,
    required double rawTargetCalories,
    required double rawProteinGrams,
    required double rawCarbsGrams,
    required double rawFatGrams,
  }) = _NutritionTargetAudit;

  factory NutritionTargetAudit.fromJson(Map<String, dynamic> json) =>
      _$NutritionTargetAuditFromJson(json);
}

@freezed
abstract class NutritionTarget with _$NutritionTarget {
  const factory NutritionTarget({
    required int basalCalories,
    required int maintenanceCalories,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int fatGrams,
    required NutritionTargetAudit audit,
  }) = _NutritionTarget;

  factory NutritionTarget.fromJson(Map<String, dynamic> json) =>
      _$NutritionTargetFromJson(json);
}

@freezed
abstract class TargetTimeline with _$TargetTimeline {
  const factory TargetTimeline({
    required int todayEpochDay,
    required int targetDateEpochDay,
  }) = _TargetTimeline;

  factory TargetTimeline.fromJson(Map<String, dynamic> json) =>
      _$TargetTimelineFromJson(json);
}

@freezed
sealed class CalculationResult with _$CalculationResult {
  const factory CalculationResult.target(NutritionTarget value) = _CalculationResultTarget;
  const factory CalculationResult.needsProfessionalReview(String reason) =
      _CalculationResultNeedsProfessionalReview;

  factory CalculationResult.fromJson(Map<String, dynamic> json) =>
      _$CalculationResultFromJson(json);
}

@freezed
abstract class Nutrients with _$Nutrients {
  const factory Nutrients({
    @Default(0) int calories,
    @Default(0) int proteinGrams,
    @Default(0) int carbsGrams,
    @Default(0) int fatGrams,
    @Default(0) int fiberGrams,
  }) = _Nutrients;

  factory Nutrients.fromJson(Map<String, dynamic> json) =>
      _$NutrientsFromJson(json);
}

enum EntrySource {
  @JsonValue('MANUAL')
  manual,
  @JsonValue('CAMERA_ANALYSIS')
  cameraAnalysis,
  @JsonValue('TEMPLATE')
  template,
}

@freezed
abstract class NutritionDay with _$NutritionDay {
  const factory NutritionDay({
    required int epochDay,
    required Nutrients consumed,
    NutritionTarget? target,
    @Default(0) int waterIntakeMl,
  }) = _NutritionDay;

  factory NutritionDay.fromJson(Map<String, dynamic> json) =>
      _$NutritionDayFromJson(json);
}

@freezed
abstract class MealTemplate with _$MealTemplate {
  const factory MealTemplate({
    required int id,
    required String nameVi,
    required Nutrients nutrients,
    required int updatedAtEpochMillis,
  }) = _MealTemplate;

  factory MealTemplate.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateFromJson(json);
}

@freezed
abstract class FoodCatalogItem with _$FoodCatalogItem {
  const factory FoodCatalogItem({
    @Default(0) int id,
    required String name,
    @Default(100.0) double gramsPerServing,
    @Default(0.0) double caloriesPerServing,
    @Default(0.0) double fatPerServing,
    @Default(0.0) double carbsPerServing,
    @Default(0.0) double proteinPerServing,
    @Default(0.0) double potassiumMg,
    @Default(0.0) double sodiumMg,
    @Default(0.0) double cholesterolMg,
    @Default(0.0) double fiberPerServing,
    @Default('') String importBatchId,
    @Default(false) bool isFavorite,
  }) = _FoodCatalogItem;

  factory FoodCatalogItem.fromJson(Map<String, dynamic> json) =>
      _$FoodCatalogItemFromJson(json);
}

@freezed
abstract class SweatPaymentProposal with _$SweatPaymentProposal {
  const factory SweatPaymentProposal({
    required String exerciseId,
    required String exerciseName,
    required int extraSets,
  }) = _SweatPaymentProposal;

  factory SweatPaymentProposal.fromJson(Map<String, dynamic> json) =>
      _$SweatPaymentProposalFromJson(json);
}

@freezed
abstract class Constituent with _$Constituent {
  const factory Constituent({
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) = _Constituent;

  factory Constituent.fromJson(Map<String, dynamic> json) =>
      _$ConstituentFromJson(json);
}

@freezed
abstract class ScanRecommendation with _$ScanRecommendation {
  const factory ScanRecommendation({
    required String dishName,
    required double confidence,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int fatGrams,
  }) = _ScanRecommendation;

  factory ScanRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ScanRecommendationFromJson(json);
}

@freezed
abstract class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String dishName,
    required int totalCalories,
    required int proteinGrams,
    required int carbsGrams,
    required int fatGrams,
    required int fitnessScore,
    required String advice,
    required List<Constituent> constituents,
    SweatPaymentProposal? sweatPayment,
    String? calculationProcess,
    @Default(1.0) double confidence,
    @Default(false) bool needsUserConfirmation,
    @Default([]) List<ScanRecommendation> recommendations,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
}

