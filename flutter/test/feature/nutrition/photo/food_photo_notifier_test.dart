import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/core/model/nutrition_models.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/providers/remote_providers.dart';
import 'package:gym_app/data/remote/food_analysis_client.dart';
import 'package:gym_app/data/repositories/nutrition_repository.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_notifier.dart';
import 'package:gym_app/feature/nutrition/photo/food_photo_state.dart';

void main() {
  group('FoodPhotoNotifier', () {
    late _FakeFoodAnalysisClient client;
    late _FakeNutritionRepository repository;
    late bool consent;
    late DateTime now;
    late _NotifierHarness harness;

    setUp(() {
      client = _FakeFoodAnalysisClient();
      repository = _FakeNutritionRepository();
      consent = true;
      now = DateTime(2026, 7, 22, 12, 30);
      harness = _NotifierHarness(
        client: client,
        repository: repository,
        consent: () async => consent,
        now: () => now,
        epochDay: () => 20656,
      );
    });

    tearDown(() {
      harness.dispose();
    });

    test('primary capture moves through uploading to needs-second-photo',
        () async {
      final response = Completer<FoodAnalysisReview>();
      client.onStart = (_) => response.future;

      harness.notifier.beginPrimaryCapture();
      expect(harness.state, isA<FoodPhotoCapturing>());
      expect((harness.state as FoodPhotoCapturing).isSecondary, isFalse);

      final submit = harness.notifier.submitPrimary(_upload(1));
      expect(harness.state, isA<FoodPhotoUploading>());
      response.complete(_mealReview(status: 'NEEDS_SECOND_IMAGE'));
      await submit;

      expect(harness.state, isA<FoodPhotoNeedsSecondPhoto>());
      expect(client.startUploads.single.bytes, [1, 2, 3]);
      await harness.notifier.retry();
      expect(client.startUploads, hasLength(1),
          reason: 'a successful first request must release primary bytes');
    });

    test('recognized primary images enter the matching review variant',
        () async {
      client.onStart = (_) async => _mealReview();
      await harness.notifier.submitPrimary(_upload(1));
      expect(harness.state, isA<FoodPhotoReviewingMeal>());

      harness.notifier.beginPrimaryCapture();
      client.onStart = (_) async => _labelReview();
      await harness.notifier.submitPrimary(_upload(2));
      expect(harness.state, isA<FoodPhotoReviewingLabel>());
    });

    test('secondary upload uses the private active session and enters review',
        () async {
      client.onStart = (_) async =>
          _mealReview(status: 'NEEDS_SECOND_IMAGE', analysisId: 'meal-session');
      await harness.notifier.submitPrimary(_upload(1));

      harness.notifier.beginSecondaryCapture();
      expect((harness.state as FoodPhotoCapturing).isSecondary, isTrue);
      client.onSecondary =
          (_, __) async => _mealReview(analysisId: 'meal-session');
      await harness.notifier.submitSecondary(_upload(2));

      expect(harness.state, isA<FoodPhotoReviewingMeal>());
      expect(client.secondaryAnalysisIds, ['meal-session']);
    });

    test('no persisted consent makes zero analysis calls', () async {
      consent = false;

      await harness.notifier.submitPrimary(_upload(1));

      expect(harness.state, isA<FoodPhotoConsentRequired>());
      expect(client.photoCallCount, 0);
    });

    test('retry after timeout reuses only the latest secondary upload',
        () async {
      client.onStart = (_) async =>
          _mealReview(status: 'NEEDS_SECOND_IMAGE', analysisId: 'session');
      await harness.notifier.submitPrimary(_upload(1));

      var secondaryAttempt = 0;
      client.onSecondary = (_, __) async {
        secondaryAttempt++;
        if (secondaryAttempt == 1) {
          throw FoodAnalysisApiException(
            code: 'ANALYSIS_UNAVAILABLE',
            message: 'timeout',
          );
        }
        return _mealReview(analysisId: 'session');
      };
      await harness.notifier.submitSecondary(_upload(9));

      final error = harness.state as FoodPhotoError;
      expect(error.canRetry, isTrue);
      await harness.notifier.retry();

      expect(harness.state, isA<FoodPhotoReviewingMeal>());
      expect(client.secondaryUploads, hasLength(2));
      expect(client.secondaryUploads[0].bytes, [9, 10, 11]);
      expect(client.secondaryUploads[1].bytes, [9, 10, 11]);
      expect(client.startUploads, hasLength(1));
    });

    test('meal edits replace immutable drafts', () async {
      client.onStart = (_) async => _mealReview();
      await harness.notifier.submitPrimary(_upload(1));
      final original = (harness.state as FoodPhotoReviewingMeal).draft;

      harness.notifier.renameMealComponent('component-1', 'Cơm gạo lứt');
      final renamed = (harness.state as FoodPhotoReviewingMeal).draft;
      expect(original.components.single.nameVi, 'Cơm trắng');
      expect(renamed.components.single.nameVi, 'Cơm gạo lứt');
      expect(renamed.components, isNot(same(original.components)));

      harness.notifier.updateMealComponentPortion(
        'component-1',
        HouseholdPortion(
          unit: HouseholdPortionUnit.bowl,
          quantity: 1.5,
          size: HouseholdPortionSize.large,
        ),
      );
      final portioned = (harness.state as FoodPhotoReviewingMeal).draft;
      expect(
        (portioned.components.single.portion as HouseholdPortion).quantity,
        1.5,
      );

      harness.notifier.addMealComponent(
        nameVi: 'Rau luộc',
        foodId: 'boiled-vegetables',
        portion: HouseholdPortion(
          unit: HouseholdPortionUnit.serving,
          quantity: 1,
          size: HouseholdPortionSize.medium,
        ),
      );
      final added = (harness.state as FoodPhotoReviewingMeal).draft;
      expect(added.components, hasLength(2));
      final addedId = added.components.last.observationId;

      harness.notifier.removeMealComponent(addedId);
      final removed = (harness.state as FoodPhotoReviewingMeal).draft;
      expect(removed.components, hasLength(1));
      expect(added.components, hasLength(2));
    });

    test('label basis, facts, serving size, and consumed edits are immutable',
        () async {
      client.onStart = (_) async => _labelReview(incomplete: true);
      await harness.notifier.submitPrimary(_upload(1));
      final original = (harness.state as FoodPhotoReviewingLabel).draft;

      harness.notifier.updateLabelBasis(LabelBasis.perServing);
      harness.notifier.updateLabelFacts(
        calories: 250,
        proteinGrams: 8,
        carbsGrams: 30,
        fatGrams: 10,
      );
      harness.notifier.updateLabelServingSize(50);
      harness.notifier.updateLabelConsumed(
        kind: LabelConsumedKind.servings,
        amount: 1.5,
      );

      final edited = (harness.state as FoodPhotoReviewingLabel).draft;
      expect(original.basis, LabelBasis.unknown);
      expect(original.calories, isNull);
      expect(original.consumed, isNull);
      expect(edited.basis, LabelBasis.perServing);
      expect(edited.calories, 250);
      expect(edited.servingSizeGrams, 50);
      expect(edited.consumed!.amount, 1.5);
    });

    test('manual-required meal component blocks confirmation until completed',
        () async {
      client.onStart = (_) async => _mealReview(manualPortion: true);
      client.onConfirm = (_, confirmation) async => _ready();
      await harness.notifier.submitPrimary(_upload(1));

      await harness.notifier.confirm();
      expect(harness.state, isA<FoodPhotoReviewingMeal>());
      expect(client.confirmations, isEmpty);

      harness.notifier.updateMealComponentPortion(
        'component-1',
        GramPortion(grams: 180),
      );
      await harness.notifier.confirm();

      expect(harness.state, isA<FoodPhotoReady>());
      expect(client.confirmations, hasLength(1));
    });

    test('confirmation sends the edited strict payload', () async {
      client.onStart = (_) async => _mealReview();
      client.onConfirm = (_, __) async => _ready();
      await harness.notifier.submitPrimary(_upload(1));
      harness.notifier.updateMealName('Bữa trưa mới');
      harness.notifier.renameMealComponent('component-1', 'Cơm mới');
      harness.notifier.updateMealComponentPortion(
        'component-1',
        GramPortion(grams: 220),
      );

      await harness.notifier.confirm();

      final confirmation = client.confirmations.single as MealConfirmation;
      expect(confirmation.nameVi, 'Bữa trưa mới');
      expect(confirmation.components.single.nameVi, 'Cơm mới');
      expect(
        (confirmation.components.single.portion as GramPortion).grams,
        220,
      );
    });

    test('persisted consent is checked again before confirmation', () async {
      client.onStart = (_) async => _mealReview();
      await harness.notifier.submitPrimary(_upload(1));
      consent = false;

      await harness.notifier.confirm();

      expect(harness.state, isA<FoodPhotoConsentRequired>());
      expect(client.confirmations, isEmpty);
    });

    test('nothing persists before save and double save writes exactly once',
        () async {
      client.onStart = (_) async => _mealReview();
      client.onConfirm = (_, __) async => _ready();
      await harness.notifier.submitPrimary(_upload(1));
      await harness.notifier.confirm();
      expect(repository.logs, isEmpty);

      repository.saveCompleter = Completer<void>();
      final first = harness.notifier.save();
      final second = harness.notifier.save();
      expect(harness.state, isA<FoodPhotoSaving>());
      expect(repository.logs, hasLength(1));
      repository.saveCompleter!.complete();
      await Future.wait([first, second]);

      expect(harness.state, isA<FoodPhotoSaved>());
      expect(repository.logs, hasLength(1));
      final saved = repository.logs.single;
      expect(saved.epochDay, 20656);
      expect(saved.log.mealTime, 'LUNCH');
      expect(saved.log.estimate.calories.mid, 505);
      expect(saved.log.estimate.calories.min, 430);
      expect(saved.log.estimate.calories.max, 580);
    });

    test('cancel cancels pending client work and ignores its late response',
        () async {
      final response = Completer<FoodAnalysisReview>();
      client.onStart = (_) => response.future;
      final submit = harness.notifier.submitPrimary(_upload(1));

      harness.notifier.cancel();
      expect(harness.state, isA<FoodPhotoCancelled>());
      expect(client.cancelCount, 1);
      response.complete(_mealReview());
      await submit;

      expect(harness.state, isA<FoodPhotoCancelled>());
      await harness.notifier.retry();
      expect(client.startUploads, isEmpty,
          reason: 'cancel must release retry bytes');
    });

    test('expired analysis requires recapture and is never confirmed',
        () async {
      client.onStart = (_) async => _mealReview(
            expiresAt: now.subtract(const Duration(seconds: 1)),
          );
      await harness.notifier.submitPrimary(_upload(1));

      final error = harness.state as FoodPhotoError;
      expect(error.code, 'ANALYSIS_EXPIRED');
      expect(error.requiresRecapture, isTrue);
      await harness.notifier.confirm();
      expect(client.confirmations, isEmpty);
    });

    test('analysis errors expose an explicit manual-entry route signal',
        () async {
      client.onStart = (_) async => throw FoodAnalysisApiException(
            code: 'INVALID_PROVIDER_RESPONSE',
            message: 'invalid provider response',
          );
      await harness.notifier.submitPrimary(_upload(1));
      expect(harness.state, isA<FoodPhotoError>());

      harness.notifier.useManualEntry();

      expect(harness.state, isA<FoodPhotoManualEntryRequested>());
      expect(client.cancelCount, 1);
    });

    test('double submit and double confirm make one client call each',
        () async {
      final review = Completer<FoodAnalysisReview>();
      client.onStart = (_) => review.future;
      final firstSubmit = harness.notifier.submitPrimary(_upload(1));
      final secondSubmit = harness.notifier.submitPrimary(_upload(2));
      review.complete(_mealReview());
      await Future.wait([firstSubmit, secondSubmit]);
      expect(client.startUploads, hasLength(1));

      final ready = Completer<FoodAnalysisReady>();
      client.onConfirm = (_, __) => ready.future;
      final firstConfirm = harness.notifier.confirm();
      final secondConfirm = harness.notifier.confirm();
      ready.complete(_ready());
      await Future.wait([firstConfirm, secondConfirm]);
      expect(client.confirmations, hasLength(1));
    });

    test('mismatched confirmation session cannot become ready', () async {
      client.onStart = (_) async => _mealReview(analysisId: 'expected');
      client.onConfirm = (_, __) async => _ready(analysisId: 'stale');
      await harness.notifier.submitPrimary(_upload(1));

      await harness.notifier.confirm();

      final error = harness.state as FoodPhotoError;
      expect(error.code, 'INVALID_PROVIDER_RESPONSE');
      expect(repository.logs, isEmpty);
    });

    test('dispose cancels work and late completion has no side effects',
        () async {
      final response = Completer<FoodAnalysisReview>();
      client.onStart = (_) => response.future;
      final submit = harness.notifier.submitPrimary(_upload(1));

      harness.dispose();
      response.complete(_mealReview());
      await submit;

      expect(client.cancelCount, 1);
      expect(repository.logs, isEmpty);
    });
  });
}

final class _NotifierHarness {
  final ProviderContainer container;
  late final ProviderSubscription<FoodPhotoState> _subscription;
  bool _disposed = false;

  _NotifierHarness({
    required FoodAnalysisClient client,
    required NutritionRepository repository,
    required Future<bool> Function() consent,
    required DateTime Function() now,
    required int Function() epochDay,
  }) : container = ProviderContainer(
          overrides: [
            foodAnalysisClientProvider.overrideWithValue(client),
            nutritionRepositoryProvider.overrideWithValue(repository),
            foodPhotoConsentLookupProvider.overrideWithValue(consent),
            foodPhotoClockProvider.overrideWithValue(now),
            foodPhotoEpochDayProvider.overrideWithValue(epochDay),
          ],
        ) {
    _subscription = container.listen(
      foodPhotoNotifierProvider,
      (_, __) {},
      fireImmediately: true,
    );
  }

  FoodPhotoNotifier get notifier =>
      container.read(foodPhotoNotifierProvider.notifier);

  FoodPhotoState get state => container.read(foodPhotoNotifierProvider);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription.close();
    container.dispose();
  }
}

final class _FakeFoodAnalysisClient implements FoodAnalysisClient {
  Future<FoodAnalysisReview> Function(PreparedUpload)? onStart;
  Future<FoodAnalysisReview> Function(String, PreparedUpload)? onSecondary;
  Future<FoodAnalysisReady> Function(String, FoodAnalysisConfirmation)?
      onConfirm;

  final List<PreparedUpload> startUploads = [];
  final List<PreparedUpload> secondaryUploads = [];
  final List<String> secondaryAnalysisIds = [];
  final List<FoodAnalysisConfirmation> confirmations = [];
  int cancelCount = 0;

  int get photoCallCount =>
      startUploads.length + secondaryUploads.length + confirmations.length;

  @override
  Future<FoodAnalysisReview> startPhotoAnalysis(PreparedUpload upload) {
    startUploads.add(upload);
    return onStart!(upload);
  }

  @override
  Future<FoodAnalysisReview> addSecondaryPhoto(
    String analysisId,
    PreparedUpload upload,
  ) {
    secondaryAnalysisIds.add(analysisId);
    secondaryUploads.add(upload);
    return onSecondary!(analysisId, upload);
  }

  @override
  Future<FoodAnalysisReady> confirmAnalysis(
    String analysisId,
    FoodAnalysisConfirmation confirmation,
  ) {
    confirmations.add(confirmation);
    return onConfirm!(analysisId, confirmation);
  }

  @override
  void cancelPending() {
    cancelCount++;
  }

  @override
  Future<ScanResult?> analyze(Uint8List imageBytes) =>
      throw UnsupportedError('legacy API is outside this fake');

  @override
  Future<bool> registerBarcode(String barcode, ScanResult result) =>
      throw UnsupportedError('legacy API is outside this fake');

  @override
  Future<ScanResult?> scanBarcode(String barcode) =>
      throw UnsupportedError('legacy API is outside this fake');
}

final class _SavedPhotoLog {
  final int epochDay;
  final PhotoNutritionLog log;

  const _SavedPhotoLog(this.epochDay, this.log);
}

final class _FakeNutritionRepository implements NutritionRepository {
  final List<_SavedPhotoLog> logs = [];
  Completer<void>? saveCompleter;

  @override
  Future<void> logPhotoEstimate({
    required int epochDay,
    required PhotoNutritionLog log,
  }) async {
    logs.add(_SavedPhotoLog(epochDay, log));
    await saveCompleter?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused fake repository member');
}

PreparedUpload _upload(int seed) => PreparedUpload(
      bytes: Uint8List.fromList([seed, seed + 1, seed + 2]),
      mimeType: 'image/jpeg',
      filename: 'food-$seed.jpg',
    );

FoodAnalysisReview _mealReview({
  String status = 'NEEDS_CONFIRMATION',
  String analysisId = 'analysis-1',
  bool manualPortion = false,
  DateTime? expiresAt,
}) {
  return FoodAnalysisReview.fromJson({
    'analysisId': analysisId,
    'imageType': 'MEAL',
    'status': status,
    'components': [
      {
        'id': 'component-1',
        'nameVi': 'Cơm trắng',
        'matchedFoodId': 'white-rice',
        'confidence': manualPortion ? 0.4 : 0.91,
        'isMajor': true,
        'requiresManualPortion': manualPortion,
        'suggestedPortion': manualPortion
            ? null
            : {
                'kind': 'HOUSEHOLD',
                'unit': 'BOWL',
                'quantity': 1,
                'size': 'MEDIUM',
              },
      },
    ],
    'labelFacts': null,
    'confidence': 0.82,
    'uncertaintyReasons': ['HIDDEN_OIL'],
    'expiresAt':
        (expiresAt ?? DateTime(2026, 7, 22, 13, 0)).toUtc().toIso8601String(),
  });
}

FoodAnalysisReview _labelReview({
  String analysisId = 'analysis-label',
  bool incomplete = false,
}) {
  return FoodAnalysisReview.fromJson({
    'analysisId': analysisId,
    'imageType': 'NUTRITION_LABEL',
    'status': 'NEEDS_CONFIRMATION',
    'components': null,
    'labelFacts': {
      'nameVi': 'Sản phẩm mẫu',
      'basis': incomplete ? 'UNKNOWN' : 'PER_100G',
      'facts': {
        'calories': incomplete ? null : 498,
        'proteinGrams': incomplete ? null : 4.4,
        'carbsGrams': incomplete ? null : 49.8,
        'fatGrams': incomplete ? null : 31.1,
      },
      'servingSizeGrams': null,
      'servingsPerContainer': null,
      'netWeightGrams': incomplete ? null : 57,
      'confidence': 0.94,
      'missingFields': incomplete
          ? [
              'BASIS',
              'CALORIES',
              'PROTEIN_GRAMS',
              'CARBS_GRAMS',
              'FAT_GRAMS',
              'CONSUMED_AMOUNT',
            ]
          : [],
    },
    'confidence': 0.94,
    'uncertaintyReasons': [],
    'expiresAt': DateTime(2026, 7, 22, 13).toUtc().toIso8601String(),
  });
}

FoodAnalysisReady _ready({String analysisId = 'analysis-1'}) {
  return FoodAnalysisReady.fromJson({
    'analysisId': analysisId,
    'imageType': 'MEAL',
    'status': 'READY',
    'nameVi': 'Cơm với ức gà',
    'estimate': {
      'calories': {'min': 430, 'mid': 505, 'max': 580},
      'proteinGrams': {'min': 34, 'mid': 39, 'max': 44},
      'carbsGrams': {'min': 48, 'mid': 55, 'max': 62},
      'fatGrams': {'min': 8, 'mid': 12, 'max': 16},
    },
    'confidenceLevel': 'MEDIUM',
    'uncertaintyReasons': ['HIDDEN_OIL'],
    'calculationSummary': '1 bát cơm vừa + 1 phần ức gà vừa.',
  });
}
