import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/providers/remote_providers.dart';
import '../../../data/remote/food_analysis_client.dart';
import '../../../data/repositories/nutrition_repository.dart';
import 'food_photo_state.dart';

typedef FoodPhotoConsentLookup = Future<bool> Function();
typedef FoodPhotoClock = DateTime Function();
typedef FoodPhotoEpochDay = int Function();

final foodPhotoConsentLookupProvider = Provider<FoodPhotoConsentLookup>((ref) {
  final database = ref.watch(gymDatabaseProvider);
  return () async {
    final profile = await database.personalizationDao.profileNow();
    return profile?.cloudAiConsent == true;
  };
});

final foodPhotoClockProvider = Provider<FoodPhotoClock>((ref) => DateTime.now);

final foodPhotoEpochDayProvider =
    Provider<FoodPhotoEpochDay>((ref) => currentLocalEpochDay);

final foodPhotoNotifierProvider =
    NotifierProvider.autoDispose<FoodPhotoNotifier, FoodPhotoState>(
  FoodPhotoNotifier.new,
);

enum _UploadKind { primary, secondary }

final class FoodPhotoNotifier extends Notifier<FoodPhotoState> {
  late FoodAnalysisClient _client;
  late NutritionRepository _repository;
  late FoodPhotoConsentLookup _lookupConsent;
  late FoodPhotoClock _clock;
  late FoodPhotoEpochDay _epochDay;

  PreparedUpload? _pendingUpload;
  _UploadKind? _pendingUploadKind;
  String? _activeAnalysisId;
  DateTime? _activeExpiresAt;
  FoodAnalysisReady? _readyResult;
  String? _savedAnalysisId;
  FoodPhotoCaptureToken? _activeCaptureToken;
  FoodPhotoReviewingMeal? _mealReviewRecovery;
  FoodPhotoReviewingLabel? _labelReviewRecovery;
  int _manualComponentSequence = 0;
  int _operationGeneration = 0;
  bool _disposed = false;

  @override
  FoodPhotoState build() {
    _client = ref.watch(foodAnalysisClientProvider);
    _repository = ref.watch(nutritionRepositoryProvider);
    _lookupConsent = ref.watch(foodPhotoConsentLookupProvider);
    _clock = ref.watch(foodPhotoClockProvider);
    _epochDay = ref.watch(foodPhotoEpochDayProvider);
    _disposed = false;

    final client = _client;
    ref.onDispose(() {
      _disposed = true;
      _operationGeneration++;
      client.cancelPending();
      _clearTransientData();
      _savedAnalysisId = null;
      _activeCaptureToken = null;
    });
    return const FoodPhotoIdle();
  }

  FoodPhotoCaptureToken beginPrimaryCapture() {
    if (_isBusy) {
      throw StateError('A food-photo operation is already in progress.');
    }
    _operationGeneration++;
    _startNewWorkflow();
    final token = FoodPhotoCaptureToken.create();
    _activeCaptureToken = token;
    state = const FoodPhotoCapturing(isSecondary: false);
    return token;
  }

  FoodPhotoCaptureToken? beginSecondaryCapture() {
    if (state is! FoodPhotoNeedsSecondPhoto || _isExpired) {
      if (_isExpired) _setExpired();
      return null;
    }
    final token = FoodPhotoCaptureToken.create();
    _activeCaptureToken = token;
    state = const FoodPhotoCapturing(isSecondary: true);
    return token;
  }

  Future<void> submitPrimary(
    PreparedUpload upload, {
    required FoodPhotoCaptureToken token,
  }) async {
    final current = state;
    if (_isBusy ||
        current is! FoodPhotoCapturing ||
        current.isSecondary ||
        !identical(token, _activeCaptureToken)) {
      return;
    }
    _startNewWorkflow(clearSavedId: false);
    await _submitUpload(upload, _UploadKind.primary);
  }

  Future<void> submitSecondary(
    PreparedUpload upload, {
    required FoodPhotoCaptureToken token,
  }) async {
    final current = state;
    final validState = current is FoodPhotoNeedsSecondPhoto ||
        (current is FoodPhotoCapturing && current.isSecondary);
    if (!validState || _isBusy || _activeAnalysisId == null) return;
    if (!identical(token, _activeCaptureToken) ||
        current is! FoodPhotoCapturing) {
      return;
    }
    if (_isExpired) {
      _setExpired();
      return;
    }
    await _submitUpload(upload, _UploadKind.secondary);
  }

  Future<void> retry() async {
    final current = state;
    final upload = _pendingUpload;
    final kind = _pendingUploadKind;
    if (current is! FoodPhotoError ||
        current.code != 'ANALYSIS_UNAVAILABLE' ||
        !current.canRetry ||
        upload == null ||
        kind == null) {
      return;
    }
    if (kind == _UploadKind.secondary && _isExpired) {
      _setExpired();
      return;
    }
    await _submitUpload(upload, kind, isRetry: true);
  }

  Future<void> _submitUpload(
    PreparedUpload upload,
    _UploadKind kind, {
    bool isRetry = false,
  }) async {
    if (!isRetry) {
      _pendingUpload = upload;
      _pendingUploadKind = kind;
    }
    final analysisId = _activeAnalysisId;
    if (kind == _UploadKind.secondary && analysisId == null) {
      _clearPendingUpload();
      _setExpired();
      return;
    }

    final generation = ++_operationGeneration;
    state = FoodPhotoUploading(isSecondary: kind == _UploadKind.secondary);

    final hasConsent = await _readConsent(generation);
    if (!_isCurrent(generation)) return;
    if (!hasConsent) {
      _clearTransientData();
      state = const FoodPhotoConsentRequired();
      return;
    }

    try {
      final review = switch (kind) {
        _UploadKind.primary => await _client.startPhotoAnalysis(upload),
        _UploadKind.secondary =>
          await _client.addSecondaryPhoto(analysisId!, upload),
      };
      if (!_isCurrent(generation)) return;
      _applyReview(
        review,
        kind: kind,
        expectedAnalysisId: analysisId,
      );
    } on FoodAnalysisCancelledException {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoCancelled();
    } on FoodAnalysisApiException catch (error) {
      if (!_isCurrent(generation)) return;
      _handleApiError(error);
    } on FoodAnalysisFormatException {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoError(
        code: 'INVALID_PROVIDER_RESPONSE',
        message: 'Phản hồi phân tích ảnh không hợp lệ.',
        canRetry: false,
        requiresRecapture: false,
      );
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoError(
        code: 'ANALYSIS_UNAVAILABLE',
        message: 'Không thể phân tích ảnh lúc này.',
        canRetry: false,
        requiresRecapture: false,
      );
    }
  }

  void _applyReview(
    FoodAnalysisReview review, {
    required _UploadKind kind,
    required String? expectedAnalysisId,
  }) {
    _clearPendingUpload();
    _activeCaptureToken = null;
    if (kind == _UploadKind.secondary &&
        (expectedAnalysisId == null ||
            review.analysisId != expectedAnalysisId ||
            review.status == FoodAnalysisStatus.needsSecondImage ||
            review.status == FoodAnalysisStatus.ready)) {
      _clearSessionData();
      state = const FoodPhotoError(
        code: 'INVALID_PROVIDER_RESPONSE',
        message: 'Phản hồi ảnh thứ hai không khớp phiên phân tích.',
        canRetry: false,
        requiresRecapture: false,
      );
      return;
    }
    if (kind == _UploadKind.primary &&
        review.status == FoodAnalysisStatus.ready) {
      _clearSessionData();
      state = const FoodPhotoError(
        code: 'INVALID_PROVIDER_RESPONSE',
        message: 'Phản hồi phân tích ảnh không hợp lệ.',
        canRetry: false,
        requiresRecapture: false,
      );
      return;
    }
    if (!review.expiresAt.isAfter(_clock())) {
      _clearSessionData();
      _setExpired();
      return;
    }

    _activeAnalysisId = review.analysisId;
    _activeExpiresAt = review.expiresAt;
    final summary = FoodPhotoReviewSummary.fromReview(review);

    switch (review.status) {
      case FoodAnalysisStatus.needsSecondImage:
        state = FoodPhotoNeedsSecondPhoto(summary);
      case FoodAnalysisStatus.needsConfirmation:
        switch (review.imageType) {
          case FoodImageType.meal:
            final mealState = FoodPhotoReviewingMeal(
              summary,
              _mealDraftFromReview(review),
            );
            _mealReviewRecovery = mealState;
            _labelReviewRecovery = null;
            state = mealState;
          case FoodImageType.nutritionLabel:
            final labelState = FoodPhotoReviewingLabel(
              summary,
              _labelDraftFromReview(review),
            );
            _labelReviewRecovery = labelState;
            _mealReviewRecovery = null;
            state = labelState;
          case FoodImageType.unknown:
            _clearSessionData();
            state = const FoodPhotoError(
              code: 'INVALID_PROVIDER_RESPONSE',
              message: 'Phản hồi phân tích ảnh không hợp lệ.',
              canRetry: false,
              requiresRecapture: false,
            );
        }
      case FoodAnalysisStatus.unrecognized:
        _clearSessionData();
        state = const FoodPhotoError(
          code: 'UNRECOGNIZED',
          message: 'Không nhận diện được món ăn hoặc nhãn dinh dưỡng.',
          canRetry: false,
          requiresRecapture: true,
        );
      case FoodAnalysisStatus.ready:
        _clearSessionData();
        state = const FoodPhotoError(
          code: 'INVALID_PROVIDER_RESPONSE',
          message: 'Phản hồi phân tích ảnh không hợp lệ.',
          canRetry: false,
          requiresRecapture: false,
        );
    }
  }

  FoodPhotoMealDraft _mealDraftFromReview(FoodAnalysisReview review) {
    final components = review.components!;
    return FoodPhotoMealDraft(
      nameVi: components.map((component) => component.nameVi).join(' + '),
      components: components
          .map(
            (component) => FoodPhotoMealComponentDraft(
              observationId: component.id,
              foodId: component.matchedFoodId,
              nameVi: component.nameVi,
              portion: component.suggestedPortion,
              requiresManualPortion: component.requiresManualPortion ||
                  component.suggestedPortion == null,
              manualPortionCompleted: !component.requiresManualPortion &&
                  component.suggestedPortion != null,
            ),
          )
          .toList(growable: false),
    );
  }

  FoodPhotoLabelDraft _labelDraftFromReview(FoodAnalysisReview review) {
    final label = review.labelFacts!;
    final consumed = label.netWeightGrams == null
        ? null
        : LabelConsumedAmount(
            kind: LabelConsumedKind.grams,
            amount: label.netWeightGrams!,
          );
    return FoodPhotoLabelDraft(
      nameVi: label.nameVi,
      basis: label.basis,
      calories: label.facts.calories,
      proteinGrams: label.facts.proteinGrams,
      carbsGrams: label.facts.carbsGrams,
      fatGrams: label.facts.fatGrams,
      servingSizeGrams: label.servingSizeGrams,
      consumed: consumed,
    );
  }

  void updateMealName(String nameVi) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    _setMealDraft(
      current,
      FoodPhotoMealDraft(nameVi: nameVi, components: current.draft.components),
    );
  }

  void renameMealComponent(String observationId, String nameVi) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    final components = current.draft.components
        .map(
          (component) => component.observationId == observationId
              ? component.copyWith(nameVi: nameVi, foodId: null)
              : component,
        )
        .toList(growable: false);
    _setMealDraft(
      current,
      FoodPhotoMealDraft(nameVi: current.draft.nameVi, components: components),
    );
  }

  void updateMealComponentPortion(
    String observationId,
    FoodPortion portion,
  ) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    final components = current.draft.components
        .map(
          (component) => component.observationId == observationId
              ? component.copyWith(
                  portion: portion,
                  manualPortionCompleted: true,
                )
              : component,
        )
        .toList(growable: false);
    _setMealDraft(
      current,
      FoodPhotoMealDraft(nameVi: current.draft.nameVi, components: components),
    );
  }

  void addMealComponent({
    required String nameVi,
    String? foodId,
    FoodPortion? portion,
  }) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    final component = FoodPhotoMealComponentDraft(
      observationId: 'manual-${++_manualComponentSequence}',
      foodId: foodId,
      nameVi: nameVi,
      portion: portion,
      requiresManualPortion: portion == null,
      manualPortionCompleted: portion != null,
    );
    _setMealDraft(
      current,
      FoodPhotoMealDraft(
        nameVi: current.draft.nameVi,
        components: [...current.draft.components, component],
      ),
    );
  }

  void removeMealComponent(String observationId) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    _setMealDraft(
      current,
      FoodPhotoMealDraft(
        nameVi: current.draft.nameVi,
        components: current.draft.components
            .where((component) => component.observationId != observationId)
            .toList(growable: false),
      ),
    );
  }

  void _setMealDraft(
    FoodPhotoReviewingMeal current,
    FoodPhotoMealDraft draft,
  ) {
    final next = FoodPhotoReviewingMeal(current.review, draft);
    _mealReviewRecovery = next;
    if (state is FoodPhotoError) {
      final error = state as FoodPhotoError;
      state = FoodPhotoError(
        code: error.code,
        message: error.message,
        canRetry: error.canRetry,
        requiresRecapture: error.requiresRecapture,
        canRetryConfirm: error.canRetryConfirm,
        canUseManualEntry: error.canUseManualEntry,
        reviewSummary: error.reviewSummary,
        mealDraft: draft,
        labelDraft: null,
        affectedComponentId: error.affectedComponentId,
      );
    } else {
      state = next;
    }
  }

  FoodPhotoReviewingMeal? _mealReviewForEditing() {
    final current = state;
    if (current is FoodPhotoReviewingMeal) return current;
    if (current is FoodPhotoError &&
        current.mealDraft != null &&
        current.reviewSummary != null) {
      return FoodPhotoReviewingMeal(current.reviewSummary!, current.mealDraft!);
    }
    return null;
  }

  void updateMealComponentFoodId(String observationId, String? foodId) {
    final current = _mealReviewForEditing();
    if (current == null) return;
    final components = current.draft.components
        .map(
          (component) => component.observationId == observationId
              ? component.copyWith(foodId: foodId)
              : component,
        )
        .toList(growable: false);
    _setMealDraft(
      current,
      FoodPhotoMealDraft(nameVi: current.draft.nameVi, components: components),
    );
  }

  void updateLabelName(String nameVi) {
    final current = _labelReviewForEditing();
    if (current == null) return;
    _setLabelDraft(
      current,
      current.draft.copyWith(nameVi: nameVi),
    );
  }

  void updateLabelBasis(LabelBasis basis) {
    final current = _labelReviewForEditing();
    if (current == null) return;
    _setLabelDraft(
      current,
      current.draft.copyWith(basis: basis),
    );
  }

  void updateLabelFacts({
    required double? calories,
    required double? proteinGrams,
    required double? carbsGrams,
    required double? fatGrams,
  }) {
    final current = _labelReviewForEditing();
    if (current == null) return;
    final draft = current.draft;
    _setLabelDraft(
      current,
      FoodPhotoLabelDraft(
        nameVi: draft.nameVi,
        basis: draft.basis,
        calories: calories,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatGrams: fatGrams,
        servingSizeGrams: draft.servingSizeGrams,
        consumed: draft.consumed,
      ),
    );
  }

  void updateLabelServingSize(double? servingSizeGrams) {
    final current = _labelReviewForEditing();
    if (current == null) return;
    final draft = current.draft;
    _setLabelDraft(
      current,
      FoodPhotoLabelDraft(
        nameVi: draft.nameVi,
        basis: draft.basis,
        calories: draft.calories,
        proteinGrams: draft.proteinGrams,
        carbsGrams: draft.carbsGrams,
        fatGrams: draft.fatGrams,
        servingSizeGrams: servingSizeGrams,
        consumed: draft.consumed,
      ),
    );
  }

  void updateLabelConsumed({
    required LabelConsumedKind? kind,
    required double? amount,
  }) {
    final current = _labelReviewForEditing();
    if (current == null) return;
    try {
      final consumed = kind == null || amount == null
          ? null
          : LabelConsumedAmount(kind: kind, amount: amount);
      _setLabelDraft(
        current,
        current.draft.copyWith(consumed: consumed),
      );
    } on FoodAnalysisFormatException catch (error) {
      final cleared = current.draft.copyWith(consumed: null);
      _setLabelDraft(current, cleared);
      if (state is FoodPhotoReviewingLabel) {
        state = FoodPhotoReviewingLabel(
          current.review,
          cleared,
          validationMessage: error.message,
        );
      }
    }
  }

  void _setLabelDraft(
    FoodPhotoReviewingLabel current,
    FoodPhotoLabelDraft draft,
  ) {
    final next = FoodPhotoReviewingLabel(current.review, draft);
    _labelReviewRecovery = next;
    if (state is FoodPhotoError) {
      final error = state as FoodPhotoError;
      state = FoodPhotoError(
        code: error.code,
        message: error.message,
        canRetry: error.canRetry,
        requiresRecapture: error.requiresRecapture,
        canRetryConfirm: error.canRetryConfirm,
        canUseManualEntry: error.canUseManualEntry,
        reviewSummary: error.reviewSummary,
        mealDraft: null,
        labelDraft: draft,
        affectedComponentId: error.affectedComponentId,
      );
    } else {
      state = next;
    }
  }

  FoodPhotoReviewingLabel? _labelReviewForEditing() {
    final current = state;
    if (current is FoodPhotoReviewingLabel) return current;
    if (current is FoodPhotoError &&
        current.labelDraft != null &&
        current.reviewSummary != null) {
      return FoodPhotoReviewingLabel(
        current.reviewSummary!,
        current.labelDraft!,
      );
    }
    return null;
  }

  Future<void> confirm() async {
    final reviewState = switch (state) {
      FoodPhotoReviewingMeal() => state as FoodPhotoReviewingMeal,
      FoodPhotoReviewingLabel() => state as FoodPhotoReviewingLabel,
      FoodPhotoError(canRetryConfirm: true) =>
        _mealReviewForEditing() ?? _labelReviewForEditing(),
      _ => null,
    };
    if (reviewState == null) return;
    FoodAnalysisConfirmation confirmation;
    try {
      if (reviewState case FoodPhotoReviewingMeal(:final draft)) {
        confirmation = draft.toConfirmation();
      } else if (reviewState case FoodPhotoReviewingLabel(:final draft)) {
        confirmation = draft.toConfirmation();
      } else {
        return;
      }
    } on FoodAnalysisFormatException catch (error) {
      switch (reviewState) {
        case FoodPhotoReviewingMeal(:final review, :final draft):
          state = FoodPhotoReviewingMeal(
            review,
            draft,
            validationMessage: error.message,
          );
        case FoodPhotoReviewingLabel(:final review, :final draft):
          state = FoodPhotoReviewingLabel(
            review,
            draft,
            validationMessage: error.message,
          );
        default:
      }
      return;
    }

    final analysisId = _activeAnalysisId;
    if (analysisId == null || _isExpired) {
      _setExpired();
      return;
    }

    final generation = ++_operationGeneration;
    state = const FoodPhotoConfirming();
    final hasConsent = await _readConsent(generation);
    if (!_isCurrent(generation)) return;
    if (!hasConsent) {
      _clearTransientData();
      state = const FoodPhotoConsentRequired();
      return;
    }

    try {
      final ready = await _client.confirmAnalysis(analysisId, confirmation);
      if (!_isCurrent(generation)) return;
      if (ready.analysisId != analysisId) {
        _retainConfirmationError(
          FoodAnalysisApiException(
            code: 'INVALID_PROVIDER_RESPONSE',
            message: 'Phản hồi xác nhận không khớp phiên phân tích.',
          ),
          reviewState,
        );
        return;
      }
      _readyResult = ready;
      state = FoodPhotoReady(FoodPhotoEstimateResult.fromReady(ready));
    } on FoodAnalysisApiException catch (error) {
      if (!_isCurrent(generation)) return;
      if (error.code == 'INVALID_CONFIRMATION') {
        switch (reviewState) {
          case FoodPhotoReviewingMeal(:final review, :final draft):
            state = FoodPhotoReviewingMeal(
              review,
              draft,
              validationMessage: error.message,
            );
          case FoodPhotoReviewingLabel(:final review, :final draft):
            state = FoodPhotoReviewingLabel(
              review,
              draft,
              validationMessage: error.message,
            );
          default:
        }
      } else {
        _handleConfirmApiError(error, reviewState);
      }
    } on FoodAnalysisCancelledException {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoCancelled();
    } on FoodAnalysisFormatException {
      if (!_isCurrent(generation)) return;
      _retainConfirmationError(
        FoodAnalysisApiException(
          code: 'INVALID_PROVIDER_RESPONSE',
          message: 'Phản hồi xác nhận không hợp lệ.',
        ),
        reviewState,
      );
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _retainConfirmationError(
        FoodAnalysisApiException(
          code: 'ANALYSIS_UNAVAILABLE',
          message: 'Không thể xác nhận kết quả lúc này.',
        ),
        reviewState,
      );
    }
  }

  Future<void> retryConfirm() async {
    final current = state;
    if (current is FoodPhotoError && current.canRetryConfirm) {
      await confirm();
    }
  }

  void _handleConfirmApiError(
    FoodAnalysisApiException error,
    FoodPhotoState reviewState,
  ) {
    if (error.code == 'ANALYSIS_EXPIRED') {
      _setExpired(message: error.message);
      return;
    }
    if (error.code == 'ANALYSIS_UNAVAILABLE' ||
        error.code == 'INVALID_PROVIDER_RESPONSE' ||
        error.code == 'DATABASE_NO_MATCH') {
      _retainConfirmationError(error, reviewState);
      return;
    }
    _handleApiError(error);
  }

  void _retainConfirmationError(
    FoodAnalysisApiException error,
    FoodPhotoState reviewState,
  ) {
    final summary = reviewState is FoodPhotoReviewingMeal
        ? reviewState.review
        : (reviewState as FoodPhotoReviewingLabel).review;
    final mealDraft =
        reviewState is FoodPhotoReviewingMeal ? reviewState.draft : null;
    final labelDraft =
        reviewState is FoodPhotoReviewingLabel ? reviewState.draft : null;
    state = FoodPhotoError(
      code: error.code,
      message: error.message,
      canRetry: false,
      requiresRecapture: false,
      canRetryConfirm: true,
      canUseManualEntry: true,
      reviewSummary: summary,
      mealDraft: mealDraft,
      labelDraft: labelDraft,
      affectedComponentId: _affectedComponentId(error, mealDraft),
    );
  }

  String? _affectedComponentId(
    FoodAnalysisApiException error,
    FoodPhotoMealDraft? draft,
  ) {
    if (error.code != 'DATABASE_NO_MATCH' || draft == null) return null;
    final value = error.details['observationId'];
    if (value is! String) return null;
    return draft.components.any((item) => item.observationId == value)
        ? value
        : null;
  }

  Future<void> save() async {
    final current = state;
    final ready = _readyResult;
    if (current is! FoodPhotoReady ||
        ready == null ||
        _savedAnalysisId == ready.analysisId) {
      return;
    }

    final generation = ++_operationGeneration;
    state = FoodPhotoSaving(current.result);
    try {
      await _repository.logPhotoEstimate(
        epochDay: _epochDay(),
        log: PhotoNutritionLog(
          name: ready.nameVi,
          mealTime: _mealTimeFor(_clock()),
          imageType: ready.imageType,
          estimate: ready.estimate,
          confidenceLevel: ready.confidenceLevel,
          calculationSummary: ready.calculationSummary,
        ),
      );
      if (!_isCurrent(generation)) return;
      _savedAnalysisId = ready.analysisId;
      _clearTransientData();
      state = const FoodPhotoSaved();
    } catch (_) {
      if (!_isCurrent(generation)) return;
      state = FoodPhotoSaveFailed(current.result);
    }
  }

  Future<void> retrySave() async {
    final current = state;
    if (current is! FoodPhotoSaveFailed || _readyResult == null) return;
    state = FoodPhotoReady(current.result);
    await save();
  }

  void editFromReady() {
    final current = state;
    if (current is! FoodPhotoReady && current is! FoodPhotoSaveFailed) return;
    if (_isExpired) {
      _setExpired();
      return;
    }
    final meal = _mealReviewRecovery;
    final label = _labelReviewRecovery;
    _readyResult = null;
    if (meal != null) {
      state = meal;
    } else if (label != null) {
      state = label;
    }
  }

  void useManualEntry() {
    if (state is FoodPhotoSaving) return;
    _operationGeneration++;
    _client.cancelPending();
    _clearTransientData();
    state = const FoodPhotoManualEntryRequested();
  }

  void cancel() {
    if (state is FoodPhotoSaving) return;
    _operationGeneration++;
    _client.cancelPending();
    _clearTransientData();
    state = const FoodPhotoCancelled();
  }

  void reset() {
    if (_isBusy) return;
    _operationGeneration++;
    _startNewWorkflow();
    state = const FoodPhotoIdle();
  }

  Future<bool> _readConsent(int generation) async {
    try {
      final hasConsent = await _lookupConsent();
      return _isCurrent(generation) && hasConsent;
    } catch (_) {
      return false;
    }
  }

  void _handleApiError(FoodAnalysisApiException error) {
    if (error.code == 'ANALYSIS_EXPIRED') {
      _clearTransientData();
      _setExpired(message: error.message);
      return;
    }

    final canRetry = error.code == 'ANALYSIS_UNAVAILABLE' &&
        _pendingUpload != null &&
        _pendingUploadKind != null;
    if (!canRetry) {
      _clearTransientData();
    }
    state = FoodPhotoError(
      code: error.code,
      message: error.message,
      canRetry: canRetry,
      requiresRecapture: _requiresRecapture(error.code),
      canUseManualEntry: true,
    );
  }

  bool _requiresRecapture(String code) => switch (code) {
        'ANALYSIS_EXPIRED' ||
        'INVALID_IMAGE' ||
        'IMAGE_TOO_LARGE' ||
        'UNSUPPORTED_IMAGE_TYPE' ||
        'UNRECOGNIZED' =>
          true,
        _ => false,
      };

  void _setExpired({
    String message = 'Phiên phân tích đã hết hạn. Hãy chụp ảnh mới.',
  }) {
    _clearTransientData();
    state = FoodPhotoError(
      code: 'ANALYSIS_EXPIRED',
      message: message,
      canRetry: false,
      requiresRecapture: true,
    );
  }

  bool get _isExpired {
    final expiresAt = _activeExpiresAt;
    return expiresAt != null && !expiresAt.isAfter(_clock());
  }

  bool get _isBusy =>
      state is FoodPhotoUploading ||
      state is FoodPhotoConfirming ||
      state is FoodPhotoSaving;

  bool _isCurrent(int generation) =>
      !_disposed && generation == _operationGeneration;

  void _clearPendingUpload() {
    _pendingUpload = null;
    _pendingUploadKind = null;
  }

  void _clearSessionData() {
    _activeAnalysisId = null;
    _activeExpiresAt = null;
    _readyResult = null;
    _mealReviewRecovery = null;
    _labelReviewRecovery = null;
  }

  void _clearTransientData() {
    _clearPendingUpload();
    _clearSessionData();
    _activeCaptureToken = null;
  }

  void _startNewWorkflow({bool clearSavedId = true}) {
    _clearTransientData();
    if (clearSavedId) _savedAnalysisId = null;
  }

  String _mealTimeFor(DateTime now) {
    if (now.hour < 10) return 'BREAKFAST';
    if (now.hour < 14) return 'LUNCH';
    if (now.hour < 17) return 'SNACK';
    return 'DINNER';
  }
}
