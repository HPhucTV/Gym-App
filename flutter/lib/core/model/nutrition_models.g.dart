// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NutritionTargetAudit _$NutritionTargetAuditFromJson(
        Map<String, dynamic> json) =>
    _NutritionTargetAudit(
      rawBasalCalories: (json['rawBasalCalories'] as num).toDouble(),
      rawMaintenanceCalories:
          (json['rawMaintenanceCalories'] as num).toDouble(),
      rawTargetCalories: (json['rawTargetCalories'] as num).toDouble(),
      rawProteinGrams: (json['rawProteinGrams'] as num).toDouble(),
      rawCarbsGrams: (json['rawCarbsGrams'] as num).toDouble(),
      rawFatGrams: (json['rawFatGrams'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionTargetAuditToJson(
        _NutritionTargetAudit instance) =>
    <String, dynamic>{
      'rawBasalCalories': instance.rawBasalCalories,
      'rawMaintenanceCalories': instance.rawMaintenanceCalories,
      'rawTargetCalories': instance.rawTargetCalories,
      'rawProteinGrams': instance.rawProteinGrams,
      'rawCarbsGrams': instance.rawCarbsGrams,
      'rawFatGrams': instance.rawFatGrams,
    };

_NutritionTarget _$NutritionTargetFromJson(Map<String, dynamic> json) =>
    _NutritionTarget(
      basalCalories: (json['basalCalories'] as num).toInt(),
      maintenanceCalories: (json['maintenanceCalories'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      carbsGrams: (json['carbsGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
      audit:
          NutritionTargetAudit.fromJson(json['audit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NutritionTargetToJson(_NutritionTarget instance) =>
    <String, dynamic>{
      'basalCalories': instance.basalCalories,
      'maintenanceCalories': instance.maintenanceCalories,
      'calories': instance.calories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'audit': instance.audit,
    };

_TargetTimeline _$TargetTimelineFromJson(Map<String, dynamic> json) =>
    _TargetTimeline(
      todayEpochDay: (json['todayEpochDay'] as num).toInt(),
      targetDateEpochDay: (json['targetDateEpochDay'] as num).toInt(),
    );

Map<String, dynamic> _$TargetTimelineToJson(_TargetTimeline instance) =>
    <String, dynamic>{
      'todayEpochDay': instance.todayEpochDay,
      'targetDateEpochDay': instance.targetDateEpochDay,
    };

_CalculationResultTarget _$CalculationResultTargetFromJson(
        Map<String, dynamic> json) =>
    _CalculationResultTarget(
      NutritionTarget.fromJson(json['value'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CalculationResultTargetToJson(
        _CalculationResultTarget instance) =>
    <String, dynamic>{
      'value': instance.value,
      'runtimeType': instance.$type,
    };

_CalculationResultNeedsProfessionalReview
    _$CalculationResultNeedsProfessionalReviewFromJson(
            Map<String, dynamic> json) =>
        _CalculationResultNeedsProfessionalReview(
          json['reason'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$CalculationResultNeedsProfessionalReviewToJson(
        _CalculationResultNeedsProfessionalReview instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'runtimeType': instance.$type,
    };

_Nutrients _$NutrientsFromJson(Map<String, dynamic> json) => _Nutrients(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toInt() ?? 0,
      carbsGrams: (json['carbsGrams'] as num?)?.toInt() ?? 0,
      fatGrams: (json['fatGrams'] as num?)?.toInt() ?? 0,
      fiberGrams: (json['fiberGrams'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NutrientsToJson(_Nutrients instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'fiberGrams': instance.fiberGrams,
    };

_NutritionDay _$NutritionDayFromJson(Map<String, dynamic> json) =>
    _NutritionDay(
      epochDay: (json['epochDay'] as num).toInt(),
      consumed: Nutrients.fromJson(json['consumed'] as Map<String, dynamic>),
      target: json['target'] == null
          ? null
          : NutritionTarget.fromJson(json['target'] as Map<String, dynamic>),
      waterIntakeMl: (json['waterIntakeMl'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NutritionDayToJson(_NutritionDay instance) =>
    <String, dynamic>{
      'epochDay': instance.epochDay,
      'consumed': instance.consumed,
      'target': instance.target,
      'waterIntakeMl': instance.waterIntakeMl,
    };

_MealTemplate _$MealTemplateFromJson(Map<String, dynamic> json) =>
    _MealTemplate(
      id: (json['id'] as num).toInt(),
      nameVi: json['nameVi'] as String,
      nutrients: Nutrients.fromJson(json['nutrients'] as Map<String, dynamic>),
      updatedAtEpochMillis: (json['updatedAtEpochMillis'] as num).toInt(),
    );

Map<String, dynamic> _$MealTemplateToJson(_MealTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameVi': instance.nameVi,
      'nutrients': instance.nutrients,
      'updatedAtEpochMillis': instance.updatedAtEpochMillis,
    };

_FoodCatalogItem _$FoodCatalogItemFromJson(Map<String, dynamic> json) =>
    _FoodCatalogItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      gramsPerServing: (json['gramsPerServing'] as num?)?.toDouble() ?? 100.0,
      caloriesPerServing:
          (json['caloriesPerServing'] as num?)?.toDouble() ?? 0.0,
      fatPerServing: (json['fatPerServing'] as num?)?.toDouble() ?? 0.0,
      carbsPerServing: (json['carbsPerServing'] as num?)?.toDouble() ?? 0.0,
      proteinPerServing: (json['proteinPerServing'] as num?)?.toDouble() ?? 0.0,
      potassiumMg: (json['potassiumMg'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble() ?? 0.0,
      cholesterolMg: (json['cholesterolMg'] as num?)?.toDouble() ?? 0.0,
      fiberPerServing: (json['fiberPerServing'] as num?)?.toDouble() ?? 0.0,
      importBatchId: json['importBatchId'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$FoodCatalogItemToJson(_FoodCatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gramsPerServing': instance.gramsPerServing,
      'caloriesPerServing': instance.caloriesPerServing,
      'fatPerServing': instance.fatPerServing,
      'carbsPerServing': instance.carbsPerServing,
      'proteinPerServing': instance.proteinPerServing,
      'potassiumMg': instance.potassiumMg,
      'sodiumMg': instance.sodiumMg,
      'cholesterolMg': instance.cholesterolMg,
      'fiberPerServing': instance.fiberPerServing,
      'importBatchId': instance.importBatchId,
      'isFavorite': instance.isFavorite,
    };

_SweatPaymentProposal _$SweatPaymentProposalFromJson(
        Map<String, dynamic> json) =>
    _SweatPaymentProposal(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      extraSets: (json['extraSets'] as num).toInt(),
    );

Map<String, dynamic> _$SweatPaymentProposalToJson(
        _SweatPaymentProposal instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'extraSets': instance.extraSets,
    };

_Constituent _$ConstituentFromJson(Map<String, dynamic> json) => _Constituent(
      name: json['name'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toInt(),
      carbs: (json['carbs'] as num).toInt(),
      fat: (json['fat'] as num).toInt(),
    );

Map<String, dynamic> _$ConstituentToJson(_Constituent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
    };

_ScanRecommendation _$ScanRecommendationFromJson(Map<String, dynamic> json) =>
    _ScanRecommendation(
      dishName: json['dishName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      calories: (json['calories'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      carbsGrams: (json['carbsGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
    );

Map<String, dynamic> _$ScanRecommendationToJson(_ScanRecommendation instance) =>
    <String, dynamic>{
      'dishName': instance.dishName,
      'confidence': instance.confidence,
      'calories': instance.calories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
    };

_ScanResult _$ScanResultFromJson(Map<String, dynamic> json) => _ScanResult(
      dishName: json['dishName'] as String,
      totalCalories: (json['totalCalories'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      carbsGrams: (json['carbsGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
      fitnessScore: (json['fitnessScore'] as num).toInt(),
      advice: json['advice'] as String,
      constituents: (json['constituents'] as List<dynamic>)
          .map((e) => Constituent.fromJson(e as Map<String, dynamic>))
          .toList(),
      sweatPayment: json['sweatPayment'] == null
          ? null
          : SweatPaymentProposal.fromJson(
              json['sweatPayment'] as Map<String, dynamic>),
      calculationProcess: json['calculationProcess'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      needsUserConfirmation: json['needsUserConfirmation'] as bool? ?? false,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map(
                  (e) => ScanRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ScanResultToJson(_ScanResult instance) =>
    <String, dynamic>{
      'dishName': instance.dishName,
      'totalCalories': instance.totalCalories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'fitnessScore': instance.fitnessScore,
      'advice': instance.advice,
      'constituents': instance.constituents,
      'sweatPayment': instance.sweatPayment,
      'calculationProcess': instance.calculationProcess,
      'confidence': instance.confidence,
      'needsUserConfirmation': instance.needsUserConfirmation,
      'recommendations': instance.recommendations,
    };
