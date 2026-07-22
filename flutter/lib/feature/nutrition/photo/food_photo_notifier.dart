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
  final Set<String> _completedAnalysisIds = {};
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
      _completedAnalysisIds.clear();
    });
    return const FoodPhotoIdle();
  }

  void beginPrimaryCapture() {
    if (_isBusy) return;
    _operationGeneration++;
    _client.cancelPending();
    _clearTransientData();
    state = const FoodPhotoCapturing(isSecondary: false);
  }

  void beginSecondaryCapture() {
    if (state is! FoodPhotoNeedsSecondPhoto || _isExpired) {
      if (_isExpired) _setExpired();
      return;
    }
    state = const FoodPhotoCapturing(isSecondary: true);
  }

  Future<void> submitPrimary(PreparedUpload upload) async {
    final current = state;
    if (_isBusy ||
        (current is FoodPhotoCapturing && current.isSecondary) ||
        current is FoodPhotoNeedsSecondPhoto) {
      return;
    }
    _clearTransientData();
    await _submitUpload(upload, _UploadKind.primary);
  }

  Future<void> submitSecondary(PreparedUpload upload) async {
    final current = state;
    final validState = current is FoodPhotoNeedsSecondPhoto ||
        (current is FoodPhotoCapturing && current.isSecondary);
    if (!validState || _isBusy || _activeAnalysisId == null) return;
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
      _applyReview(review);
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

  void _applyReview(FoodAnalysisReview review) {
    _clearPendingUpload();
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
            state = FoodPhotoReviewingMeal(
              summary,
              _mealDraftFromReview(review),
            );
          case FoodImageType.nutritionLabel:
            state = FoodPhotoReviewingLabel(
              summary,
              _labelDraftFromReview(review),
            );
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
    final current = state;
    if (current is! FoodPhotoReviewingMeal) return;
    _setMealDraft(
      current,
      FoodPhotoMealDraft(nameVi: nameVi, components: current.draft.components),
    );
  }

  void renameMealComponent(String observationId, String nameVi) {
    final current = state;
    if (current is! FoodPhotoReviewingMeal) return;
    final components = current.draft.components
        .map(
          (component) => component.observationId == observationId
              ? component.copyWith(nameVi: nameVi)
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
    final current = state;
    if (current is! FoodPhotoReviewingMeal) return;
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
    final current = state;
    if (current is! FoodPhotoReviewingMeal) return;
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
    final current = state;
    if (current is! FoodPhotoReviewingMeal) return;
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
    state = FoodPhotoReviewingMeal(current.review, draft);
  }

  void updateLabelName(String nameVi) {
    final current = state;
    if (current is! FoodPhotoReviewingLabel) return;
    _setLabelDraft(
      current,
      _copyLabelDraft(current.draft, nameVi: nameVi),
    );
  }

  void updateLabelBasis(LabelBasis basis) {
    final current = state;
    if (current is! FoodPhotoReviewingLabel) return;
    _setLabelDraft(
      current,
      _copyLabelDraft(current.draft, basis: basis),
    );
  }

  void updateLabelFacts({
    required double? calories,
    required double? proteinGrams,
    required double? carbsGrams,
    required double? fatGrams,
  }) {
    final current = state;
    if (current is! FoodPhotoReviewingLabel) return;
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
    final current = state;
    if (current is! FoodPhotoReviewingLabel) return;
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
    required LabelConsumedKind kind,
    required double amount,
  }) {
    final current = state;
    if (current is! FoodPhotoReviewingLabel) return;
    try {
      _setLabelDraft(
        current,
        _copyLabelDraft(
          current.draft,
          consumed: LabelConsumedAmount(kind: kind, amount: amount),
        ),
      );
    } on FoodAnalysisFormatException catch (error) {
      state = FoodPhotoReviewingLabel(
        current.review,
        current.draft,
        validationMessage: error.message,
      );
    }
  }

  FoodPhotoLabelDraft _copyLabelDraft(
    FoodPhotoLabelDraft draft, {
    String? nameVi,
    LabelBasis? basis,
    LabelConsumedAmount? consumed,
  }) {
    return FoodPhotoLabelDraft(
      nameVi: nameVi ?? draft.nameVi,
      basis: basis ?? draft.basis,
      calories: draft.calories,
      proteinGrams: draft.proteinGrams,
      carbsGrams: draft.carbsGrams,
      fatGrams: draft.fatGrams,
      servingSizeGrams: draft.servingSizeGrams,
      consumed: consumed ?? draft.consumed,
    );
  }

  void _setLabelDraft(
    FoodPhotoReviewingLabel current,
    FoodPhotoLabelDraft draft,
  ) {
    state = FoodPhotoReviewingLabel(current.review, draft);
  }

  Future<void> confirm() async {
    final reviewState = state;
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
        _clearTransientData();
        state = const FoodPhotoError(
          code: 'INVALID_PROVIDER_RESPONSE',
          message: 'Phản hồi xác nhận không khớp phiên phân tích.',
          canRetry: false,
          requiresRecapture: false,
        );
        return;
      }
      _readyResult = ready;
      _activeExpiresAt = null;
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
        _handleApiError(error);
      }
    } on FoodAnalysisCancelledException {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoCancelled();
    } on FoodAnalysisFormatException {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoError(
        code: 'INVALID_PROVIDER_RESPONSE',
        message: 'Phản hồi xác nhận không hợp lệ.',
        canRetry: false,
        requiresRecapture: false,
      );
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoError(
        code: 'ANALYSIS_UNAVAILABLE',
        message: 'Không thể xác nhận kết quả lúc này.',
        canRetry: false,
        requiresRecapture: false,
      );
    }
  }

  Future<void> save() async {
    final current = state;
    final ready = _readyResult;
    if (current is! FoodPhotoReady ||
        ready == null ||
        _completedAnalysisIds.contains(ready.analysisId)) {
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
      _completedAnalysisIds.add(ready.analysisId);
      if (!_isCurrent(generation)) return;
      _clearTransientData();
      state = const FoodPhotoSaved();
    } catch (_) {
      if (!_isCurrent(generation)) return;
      state = const FoodPhotoError(
        code: 'SAVE_FAILED',
        message: 'Không thể lưu kết quả dinh dưỡng.',
        canRetry: false,
        requiresRecapture: false,
      );
    }
  }

  void useManualEntry() {
    _operationGeneration++;
    _client.cancelPending();
    _clearTransientData();
    state = const FoodPhotoManualEntryRequested();
  }

  void cancel() {
    _operationGeneration++;
    _client.cancelPending();
    _clearTransientData();
    state = const FoodPhotoCancelled();
  }

  void reset() {
    if (_isBusy) return;
    _operationGeneration++;
    _clearTransientData();
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
  }

  void _clearTransientData() {
    _clearPendingUpload();
    _clearSessionData();
  }

  String _mealTimeFor(DateTime now) {
    if (now.hour < 10) return 'BREAKFAST';
    if (now.hour < 14) return 'LUNCH';
    if (now.hour < 17) return 'SNACK';
    return 'DINNER';
  }
}
