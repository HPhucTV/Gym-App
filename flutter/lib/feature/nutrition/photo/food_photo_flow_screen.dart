import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';
import 'food_capture_screen.dart';
import 'food_camera_gateway.dart';
import 'food_photo_notifier.dart';
import 'food_photo_preprocessor.dart';
import 'food_photo_state.dart';
import 'label_confirmation_view.dart';
import 'meal_confirmation_view.dart';
import 'nutrition_estimate_view.dart';

enum FoodPhotoFlowAction { saved, cancelled, manualEntry }

final class FoodPhotoFlowResult {
  final FoodPhotoFlowAction action;

  const FoodPhotoFlowResult._(this.action);

  const FoodPhotoFlowResult.saved() : this._(FoodPhotoFlowAction.saved);
  const FoodPhotoFlowResult.cancelled() : this._(FoodPhotoFlowAction.cancelled);
  const FoodPhotoFlowResult.manualEntry()
      : this._(FoodPhotoFlowAction.manualEntry);

  bool get isManualEntry => action == FoodPhotoFlowAction.manualEntry;
}

/// State-driven coordinator for capture, review, deterministic result and save.
class FoodPhotoFlowScreen extends ConsumerStatefulWidget {
  final FoodCameraGateway? gateway;
  final FoodPhotoPreprocessor? preprocessor;

  const FoodPhotoFlowScreen({super.key, this.gateway, this.preprocessor});

  @override
  ConsumerState<FoodPhotoFlowScreen> createState() =>
      _FoodPhotoFlowScreenState();
}

class _FoodPhotoFlowScreenState extends ConsumerState<FoodPhotoFlowScreen> {
  late final FoodCameraGateway _gateway;
  late final FoodPhotoPreprocessor _preprocessor;
  bool _captureOpen = false;
  bool _exitScheduled = false;

  @override
  void initState() {
    super.initState();
    _gateway = widget.gateway ?? CameraPluginFoodGateway();
    _preprocessor = widget.preprocessor ?? DeterministicFoodPhotoPreprocessor();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FoodPhotoState>(foodPhotoNotifierProvider, (previous, next) {
      if (next is FoodPhotoManualEntryRequested) {
        _complete(const FoodPhotoFlowResult.manualEntry());
      } else if (next is FoodPhotoCancelled) {
        _complete(const FoodPhotoFlowResult.cancelled());
      }
    });
    final state = ref.watch(foodPhotoNotifierProvider);
    final notifier = ref.read(foodPhotoNotifierProvider.notifier);
    final saving = state is FoodPhotoSaving;
    return PopScope(
      canPop: !saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !saving) {
          notifier.cancel();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBg
            : Colors.white,
        appBar: AppBar(
          title: Text(_titleFor(state)),
          leading: IconButton(
            key: const Key('food-analysis-cancel'),
            tooltip: 'Hủy',
            onPressed: saving ? null : () => _cancel(notifier),
            icon: const Icon(Icons.close),
          ),
        ),
        body: SafeArea(child: _body(context, state, notifier)),
      ),
    );
  }

  String _titleFor(FoodPhotoState state) => switch (state) {
        FoodPhotoReviewingMeal() => 'Xác nhận món ăn',
        FoodPhotoError(mealDraft: final draft) when draft != null =>
          'Xác nhận món ăn',
        FoodPhotoReviewingLabel() => 'Xác nhận nhãn',
        FoodPhotoError(labelDraft: final draft) when draft != null =>
          'Xác nhận nhãn',
        FoodPhotoReady() || FoodPhotoSaving() => 'Kết quả dinh dưỡng',
        FoodPhotoNeedsSecondPhoto() => 'Cần ảnh bổ sung',
        _ => 'Chụp món ăn',
      };

  Widget _body(
      BuildContext context, FoodPhotoState state, FoodPhotoNotifier notifier) {
    return switch (state) {
      FoodPhotoIdle() => _entry(context, notifier),
      FoodPhotoCapturing() ||
      FoodPhotoUploading() ||
      FoodPhotoConfirming() =>
        _progress(state),
      FoodPhotoNeedsSecondPhoto(:final review) =>
        _secondPhoto(context, review, notifier),
      FoodPhotoReviewingMeal(:final draft, :final validationMessage) =>
        MealConfirmationView(
          draft: draft,
          validationMessage: validationMessage,
          onNameChanged: notifier.updateMealName,
          onRenameComponent: notifier.renameMealComponent,
          onRemoveComponent: notifier.removeMealComponent,
          onPortionChanged: notifier.updateMealComponentPortion,
          onAddComponent: () => _addComponent(context, notifier),
          onConfirm: notifier.confirm,
        ),
      FoodPhotoReviewingLabel(:final draft, :final validationMessage) =>
        LabelConfirmationView(
          draft: draft,
          validationMessage: validationMessage,
          onNameChanged: notifier.updateLabelName,
          onBasisChanged: notifier.updateLabelBasis,
          onFactsChanged: ({calories, proteinGrams, carbsGrams, fatGrams}) =>
              notifier.updateLabelFacts(
            calories: calories,
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatGrams: fatGrams,
          ),
          onServingSizeChanged: notifier.updateLabelServingSize,
          onConsumedChanged: ({kind, amount}) =>
              notifier.updateLabelConsumed(kind: kind, amount: amount),
          onConfirm: notifier.confirm,
        ),
      FoodPhotoReady(:final result) => NutritionEstimateView(
          result: result,
          foodPhotoAnalysisStable: false,
          onSave: notifier.save,
          onEdit: notifier.editFromReady,
        ),
      FoodPhotoSaving(:final result) => NutritionEstimateView(
          result: result,
          foodPhotoAnalysisStable: false,
          onSave: null,
          onEdit: null,
        ),
      FoodPhotoSaved() => _saved(context),
      FoodPhotoSaveFailed(:final result, :final message) =>
        _saveFailed(context, result, message, notifier),
      FoodPhotoConsentRequired(:final message) =>
        _consent(context, message, notifier),
      FoodPhotoManualEntryRequested() => _manualRequested(),
      FoodPhotoCancelled() => _cancelled(),
      FoodPhotoError() => _error(context, state, notifier),
    };
  }

  Widget _entry(BuildContext context, FoodPhotoNotifier notifier) {
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.photo_camera_outlined,
            size: 64, color: AppColors.energyOrange),
        const SizedBox(height: 16),
        Text('Chụp món ăn hoặc nhãn dinh dưỡng',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.primaryText, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
            'Ảnh chỉ tạo ra ước tính. Bạn sẽ kiểm tra khẩu phần trước khi lưu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText)),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('food-photo-primary-action'),
          onPressed: () => _openCapture(notifier, isSecondary: false),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Chụp món ăn'),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.energyOrange,
              minimumSize: const Size.fromHeight(54)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('food-photo-manual-fallback'),
          onPressed: notifier.useManualEntry,
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Nhập tay'),
        ),
      ]),
    );
  }

  Widget _secondPhoto(BuildContext context, FoodPhotoReviewSummary review,
      FoodPhotoNotifier notifier) {
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    final label = review.imageType == FoodImageType.meal
        ? 'Chụp góc bên để thấy chiều cao và tách rõ từng món.'
        : 'Chụp cận cảnh, thẳng và đủ sáng phần chữ còn thiếu.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.add_a_photo_outlined,
            size: 56, color: AppColors.energyOrange),
        const SizedBox(height: 16),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        FilledButton.icon(
          key: const Key('food-photo-secondary-action'),
          onPressed: () => _openCapture(notifier, isSecondary: true),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Chụp ảnh bổ sung'),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.energyOrange,
              minimumSize: const Size.fromHeight(54)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
            onPressed: notifier.useManualEntry, child: const Text('Nhập tay')),
      ]),
    );
  }

  Widget _progress(FoodPhotoState state) {
    final text = state is FoodPhotoCapturing
        ? 'Đang mở camera…'
        : state is FoodPhotoUploading
            ? 'Đang phân tích ảnh…'
            : 'Đang tính toán khẩu phần…';
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppColors.energyOrange),
      const SizedBox(height: 16),
      Text(text),
    ]));
  }

  Widget _error(
      BuildContext context, FoodPhotoError error, FoodPhotoNotifier notifier) {
    final mapped = _errorMessage(error.code, error.message);
    final needsRecapture = error.requiresRecapture ||
        error.code == 'IMAGE_TOO_BLURRY' ||
        error.code == 'IMAGE_TOO_LARGE' ||
        error.code == 'UNSUPPORTED_IMAGE_TYPE' ||
        error.code == 'INVALID_IMAGE';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Icon(needsRecapture ? Icons.camera_alt_outlined : Icons.error_outline,
            size: 56, color: Colors.red.shade700),
        const SizedBox(height: 16),
        Text(mapped,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        if (error.affectedComponentId != null) ...[
          const SizedBox(height: 10),
          const Text(
              'Không tìm thấy món tương ứng. Hãy chọn món quen thuộc hoặc nhập dinh dưỡng thủ công.',
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton(
            key: const Key('food-analysis-choose-known-food'),
            onPressed: () {
              notifier.updateMealComponentFoodId(
                  error.affectedComponentId!, null);
              notifier.retryConfirm();
            },
            child: const Text('Chọn lại món theo tên đã sửa'),
          ),
        ],
        const SizedBox(height: 24),
        if (error.canRetry)
          FilledButton(
              key: const Key('food-analysis-retry'),
              onPressed: notifier.retry,
              child: const Text('Thử lại')),
        if (error.canRetryConfirm)
          FilledButton(
              key: const Key('food-analysis-retry-confirm'),
              onPressed: notifier.retryConfirm,
              child: const Text('Xác nhận lại')),
        if (needsRecapture)
          FilledButton(
              key: const Key('food-analysis-recapture'),
              onPressed: () {
                notifier.reset();
                _openCapture(notifier, isSecondary: false);
              },
              child: const Text('Chụp lại')),
        if (error.canUseManualEntry)
          OutlinedButton(
              key: const Key('food-analysis-manual'),
              onPressed: notifier.useManualEntry,
              child: const Text('Nhập tay')),
      ]),
    );
  }

  Widget _saved(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 64),
        const SizedBox(height: 12),
        const Text('Đã lưu vào nhật ký',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 18),
        FilledButton(
            key: const Key('food-analysis-done'),
            onPressed: () =>
                Navigator.of(context).pop(const FoodPhotoFlowResult.saved()),
            child: const Text('Xong')),
      ]));

  Widget _saveFailed(BuildContext context, FoodPhotoEstimateResult result,
          String message, FoodPhotoNotifier notifier) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(message,
                key: const Key('food-analysis-save-error'),
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: NutritionEstimateView(
                result: result,
                foodPhotoAnalysisStable: false,
                onSave: notifier.retrySave,
                onEdit: notifier.editFromReady),
          ),
        ],
      );

  Widget _consent(
          BuildContext context, String message, FoodPhotoNotifier notifier) =>
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_outline,
              size: 54, color: AppColors.energyOrange),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
              'Bạn có thể bật đồng ý AI đám mây trong Hồ sơ, hoặc tiếp tục nhập tay.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          OutlinedButton(
              key: const Key('food-analysis-manual'),
              onPressed: notifier.useManualEntry,
              child: const Text('Nhập tay')),
        ]),
      );

  Widget _manualRequested() => const SizedBox.shrink();

  Widget _cancelled() => const SizedBox.shrink();

  Future<void> _openCapture(FoodPhotoNotifier notifier,
      {required bool isSecondary}) async {
    if (_captureOpen) return;
    final token = isSecondary
        ? notifier.beginSecondaryCapture()
        : notifier.beginPrimaryCapture();
    if (token == null) return;
    _captureOpen = true;
    final upload =
        await Navigator.of(context).push<PreparedUpload>(MaterialPageRoute(
      builder: (_) => FoodCaptureScreen(
        gateway: _gateway,
        preprocessor: _preprocessor,
        capturePurpose: isSecondary
            ? FoodCapturePurpose.requestedSideOrCloseUp
            : FoodCapturePurpose.primaryMealOrLabel,
      ),
    ));
    _captureOpen = false;
    if (!mounted) return;
    if (upload == null) {
      notifier.cancel();
      return;
    }
    if (isSecondary) {
      await notifier.submitSecondary(upload, token: token);
    } else {
      await notifier.submitPrimary(upload, token: token);
    }
  }

  void _cancel(FoodPhotoNotifier notifier) {
    notifier.cancel();
  }

  void _complete(FoodPhotoFlowResult result) {
    if (_exitScheduled) return;
    _exitScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  Future<void> _addComponent(
      BuildContext context, FoodPhotoNotifier notifier) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Thêm món'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Tên món')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy')),
                FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Thêm'))
              ],
            ));
    controller.dispose();
    if (name != null && name.isNotEmpty) {
      notifier.addMealComponent(nameVi: name);
    }
  }

  String _errorMessage(String code, String fallback) => switch (code) {
        'IMAGE_TOO_BLURRY' ||
        'INVALID_IMAGE' ||
        'IMAGE_TOO_LARGE' ||
        'UNSUPPORTED_IMAGE_TYPE' =>
          'Ảnh chưa đủ rõ. Hãy chụp lại với đủ sáng và giữ máy ổn định.',
        'ANALYSIS_EXPIRED' =>
          'Phiên phân tích đã hết hạn. Hãy bắt đầu lại bằng một ảnh mới.',
        'ANALYSIS_UNAVAILABLE' =>
          'Dịch vụ phân tích đang bận. Bạn có thể thử lại hoặc nhập tay.',
        'INVALID_PROVIDER_RESPONSE' =>
          'Phản hồi phân tích không hợp lệ. Hãy thử lại hoặc nhập tay.',
        'DATABASE_NO_MATCH' => 'Chưa tìm thấy món phù hợp trong dữ liệu.',
        'INVALID_CONFIRMATION' => fallback,
        _ => fallback,
      };
}
