import '../../../core/model/food_photo_analysis_models.dart';

sealed class FoodPhotoState {
  const FoodPhotoState();
}

/// Opaque capture identity used to reject late camera results.
final class FoodPhotoCaptureToken {
  FoodPhotoCaptureToken._();

  static FoodPhotoCaptureToken create() => FoodPhotoCaptureToken._();
}

final class FoodPhotoIdle extends FoodPhotoState {
  const FoodPhotoIdle();
}

final class FoodPhotoCapturing extends FoodPhotoState {
  final bool isSecondary;

  const FoodPhotoCapturing({required this.isSecondary});
}

final class FoodPhotoUploading extends FoodPhotoState {
  final bool isSecondary;

  const FoodPhotoUploading({required this.isSecondary});
}

/// Public review metadata deliberately excludes the server analysis ID.
final class FoodPhotoReviewSummary {
  final FoodImageType imageType;
  final double confidence;
  final List<FoodUncertaintyReason> uncertaintyReasons;
  final DateTime expiresAt;

  FoodPhotoReviewSummary({
    required this.imageType,
    required this.confidence,
    required List<FoodUncertaintyReason> uncertaintyReasons,
    required this.expiresAt,
  }) : uncertaintyReasons = List.unmodifiable(uncertaintyReasons);

  factory FoodPhotoReviewSummary.fromReview(FoodAnalysisReview review) {
    return FoodPhotoReviewSummary(
      imageType: review.imageType,
      confidence: review.confidence,
      uncertaintyReasons: review.uncertaintyReasons,
      expiresAt: review.expiresAt,
    );
  }
}

final class FoodPhotoNeedsSecondPhoto extends FoodPhotoState {
  final FoodPhotoReviewSummary review;

  const FoodPhotoNeedsSecondPhoto(this.review);
}

final class FoodPhotoMealComponentDraft {
  static const Object _unset = Object();
  final String observationId;
  final String? foodId;
  final String nameVi;
  final FoodPortion? portion;
  final bool requiresManualPortion;
  final bool manualPortionCompleted;

  const FoodPhotoMealComponentDraft({
    required this.observationId,
    required this.foodId,
    required this.nameVi,
    required this.portion,
    required this.requiresManualPortion,
    required this.manualPortionCompleted,
  });

  FoodPhotoMealComponentDraft copyWith({
    String? nameVi,
    Object? foodId = _unset,
    Object? portion = _unset,
    bool? requiresManualPortion,
    bool? manualPortionCompleted,
  }) {
    return FoodPhotoMealComponentDraft(
      observationId: observationId,
      foodId: identical(foodId, _unset) ? this.foodId : foodId as String?,
      nameVi: nameVi ?? this.nameVi,
      portion:
          identical(portion, _unset) ? this.portion : portion as FoodPortion?,
      requiresManualPortion:
          requiresManualPortion ?? this.requiresManualPortion,
      manualPortionCompleted:
          manualPortionCompleted ?? this.manualPortionCompleted,
    );
  }

  ConfirmedFoodComponent toConfirmation() {
    final selectedPortion = portion;
    if (selectedPortion == null ||
        (requiresManualPortion && !manualPortionCompleted)) {
      throw const FoodAnalysisFormatException(
        'A required meal portion is incomplete.',
      );
    }
    return ConfirmedFoodComponent(
      observationId: observationId,
      foodId: foodId,
      nameVi: nameVi,
      portion: selectedPortion,
    );
  }
}

final class FoodPhotoMealDraft {
  final String nameVi;
  final List<FoodPhotoMealComponentDraft> components;

  FoodPhotoMealDraft({
    required this.nameVi,
    required List<FoodPhotoMealComponentDraft> components,
  }) : components = List.unmodifiable(components);

  MealConfirmation toConfirmation() {
    return MealConfirmation(
      nameVi: nameVi,
      components: components
          .map((component) => component.toConfirmation())
          .toList(growable: false),
    );
  }

  bool get canConfirm {
    try {
      toConfirmation();
      return true;
    } on FoodAnalysisFormatException {
      return false;
    }
  }
}

final class FoodPhotoLabelDraft {
  static const Object _unset = Object();
  final String nameVi;
  final LabelBasis basis;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final double? servingSizeGrams;
  final double? servingsPerContainer;
  final double? netWeightGrams;
  final LabelConsumedAmount? consumed;

  const FoodPhotoLabelDraft({
    required this.nameVi,
    required this.basis,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.servingSizeGrams,
    this.servingsPerContainer,
    this.netWeightGrams,
    required this.consumed,
  });

  FoodPhotoLabelDraft copyWith({
    String? nameVi,
    LabelBasis? basis,
    Object? calories = _unset,
    Object? proteinGrams = _unset,
    Object? carbsGrams = _unset,
    Object? fatGrams = _unset,
    Object? servingSizeGrams = _unset,
    Object? servingsPerContainer = _unset,
    Object? netWeightGrams = _unset,
    Object? consumed = _unset,
  }) {
    return FoodPhotoLabelDraft(
      nameVi: nameVi ?? this.nameVi,
      basis: basis ?? this.basis,
      calories:
          identical(calories, _unset) ? this.calories : calories as double?,
      proteinGrams: identical(proteinGrams, _unset)
          ? this.proteinGrams
          : proteinGrams as double?,
      carbsGrams: identical(carbsGrams, _unset)
          ? this.carbsGrams
          : carbsGrams as double?,
      fatGrams:
          identical(fatGrams, _unset) ? this.fatGrams : fatGrams as double?,
      servingSizeGrams: identical(servingSizeGrams, _unset)
          ? this.servingSizeGrams
          : servingSizeGrams as double?,
      servingsPerContainer: identical(servingsPerContainer, _unset)
          ? this.servingsPerContainer
          : servingsPerContainer as double?,
      netWeightGrams: identical(netWeightGrams, _unset)
          ? this.netWeightGrams
          : netWeightGrams as double?,
      consumed: identical(consumed, _unset)
          ? this.consumed
          : consumed as LabelConsumedAmount?,
    );
  }

  LabelConfirmation toConfirmation() {
    final selectedCalories = calories;
    final selectedProtein = proteinGrams;
    final selectedCarbs = carbsGrams;
    final selectedFat = fatGrams;
    final selectedConsumed = consumed;
    if (selectedCalories == null ||
        selectedProtein == null ||
        selectedCarbs == null ||
        selectedFat == null ||
        selectedConsumed == null) {
      throw const FoodAnalysisFormatException(
        'Required nutrition-label corrections are incomplete.',
      );
    }
    return LabelConfirmation(
      nameVi: nameVi,
      basis: basis,
      facts: NutrientFacts(
        calories: selectedCalories,
        proteinGrams: selectedProtein,
        carbsGrams: selectedCarbs,
        fatGrams: selectedFat,
      ),
      servingSizeGrams: servingSizeGrams,
      consumed: selectedConsumed,
    );
  }

  bool get canConfirm {
    try {
      toConfirmation();
      return true;
    } on FoodAnalysisFormatException {
      return false;
    }
  }
}

enum FoodPhotoFieldKind {
  name,
  basis,
  calories,
  protein,
  carbs,
  fat,
  servingSize,
  consumed,
  componentPortion,
}

final class FoodPhotoFieldErrorPath {
  final FoodPhotoFieldKind kind;
  final String? componentId;

  const FoodPhotoFieldErrorPath(this.kind, {this.componentId});

  static FoodPhotoFieldErrorPath? fromApiDetails(
    Map<String, Object?> details, {
    List<String> componentObservationIds = const [],
  }) {
    final field = details['field'];
    if (field is! String || field.length > 120) return null;
    final observationId = details['observationId'];
    if (observationId is String) {
      return _componentPath(
        observationId,
        field,
        componentObservationIds,
      );
    }
    return switch (field) {
      'nameVi' => const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.name),
      'basis' => const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.basis),
      'facts.calories' =>
        const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.calories),
      'facts.proteinGrams' =>
        const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.protein),
      'facts.carbsGrams' =>
        const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.carbs),
      'facts.fatGrams' => const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.fat),
      'servingSizeGrams' =>
        const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.servingSize),
      'consumed' ||
      'consumed.amount' =>
        const FoodPhotoFieldErrorPath(FoodPhotoFieldKind.consumed),
      _ => null,
    };
  }

  static FoodPhotoFieldErrorPath? _componentPath(
    String observationId,
    String field,
    List<String> componentObservationIds,
  ) {
    if (observationId.isEmpty || observationId.length > 100) return null;
    if (!componentObservationIds.contains(observationId)) return null;
    if (!RegExp(
      r'^(?:portion(?:\.(?:kind|unit|quantity|size|grams))?|foodId|nameVi|observationId)$',
    ).hasMatch(field)) {
      return null;
    }
    return FoodPhotoFieldErrorPath(
      FoodPhotoFieldKind.componentPortion,
      componentId: observationId,
    );
  }
}

final class FoodPhotoReviewingMeal extends FoodPhotoState {
  final FoodPhotoReviewSummary review;
  final FoodPhotoMealDraft draft;
  final String? validationMessage;
  final FoodPhotoFieldErrorPath? fieldErrorPath;

  const FoodPhotoReviewingMeal(
    this.review,
    this.draft, {
    this.validationMessage,
    this.fieldErrorPath,
  });
}

final class FoodPhotoReviewingLabel extends FoodPhotoState {
  final FoodPhotoReviewSummary review;
  final FoodPhotoLabelDraft draft;
  final String? validationMessage;
  final FoodPhotoFieldErrorPath? fieldErrorPath;

  const FoodPhotoReviewingLabel(
    this.review,
    this.draft, {
    this.validationMessage,
    this.fieldErrorPath,
  });
}

final class FoodPhotoConfirming extends FoodPhotoState {
  const FoodPhotoConfirming();
}

/// Public estimate data deliberately excludes the server analysis ID.
final class FoodPhotoEstimateResult {
  final FoodImageType imageType;
  final String nameVi;
  final NutritionEstimate estimate;
  final AnalysisConfidenceLevel confidenceLevel;
  final List<FoodUncertaintyReason> uncertaintyReasons;
  final String calculationSummary;

  FoodPhotoEstimateResult({
    required this.imageType,
    required this.nameVi,
    required this.estimate,
    required this.confidenceLevel,
    required List<FoodUncertaintyReason> uncertaintyReasons,
    required this.calculationSummary,
  }) : uncertaintyReasons = List.unmodifiable(uncertaintyReasons);

  factory FoodPhotoEstimateResult.fromReady(FoodAnalysisReady ready) {
    return FoodPhotoEstimateResult(
      imageType: ready.imageType,
      nameVi: ready.nameVi,
      estimate: ready.estimate,
      confidenceLevel: ready.confidenceLevel,
      uncertaintyReasons: ready.uncertaintyReasons,
      calculationSummary: ready.calculationSummary,
    );
  }
}

final class FoodPhotoReady extends FoodPhotoState {
  final FoodPhotoEstimateResult result;

  const FoodPhotoReady(this.result);
}

final class FoodPhotoSaving extends FoodPhotoState {
  final FoodPhotoEstimateResult result;

  const FoodPhotoSaving(this.result);
}

final class FoodPhotoSaved extends FoodPhotoState {
  const FoodPhotoSaved();
}

final class FoodPhotoError extends FoodPhotoState {
  final String code;
  final String message;
  final bool canRetry;
  final bool requiresRecapture;
  final bool canRetryConfirm;
  final bool canUseManualEntry;
  final FoodPhotoReviewSummary? reviewSummary;
  final FoodPhotoMealDraft? mealDraft;
  final FoodPhotoLabelDraft? labelDraft;
  final String? affectedComponentId;

  const FoodPhotoError({
    required this.code,
    required this.message,
    required this.canRetry,
    required this.requiresRecapture,
    this.canRetryConfirm = false,
    this.canUseManualEntry = false,
    this.reviewSummary,
    this.mealDraft,
    this.labelDraft,
    this.affectedComponentId,
  });
}

final class FoodPhotoSaveFailed extends FoodPhotoState {
  final FoodPhotoEstimateResult result;
  final String message;

  const FoodPhotoSaveFailed(
    this.result, {
    this.message = 'Không thể lưu kết quả dinh dưỡng.',
  });
}

final class FoodPhotoConsentRequired extends FoodPhotoState {
  final String message;

  const FoodPhotoConsentRequired({
    this.message = 'Bạn chưa đồng ý tải ảnh món ăn để phân tích bằng AI.',
  });
}

final class FoodPhotoManualEntryRequested extends FoodPhotoState {
  const FoodPhotoManualEntryRequested();
}

final class FoodPhotoCancelled extends FoodPhotoState {
  const FoodPhotoCancelled();
}
