import 'package:flutter/material.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';
import 'food_photo_state.dart';

const bool foodPhotoAnalysisStable = false;

class NutritionEstimateView extends StatelessWidget {
  final FoodPhotoEstimateResult result;
  final bool? stable;
  final bool? foodPhotoAnalysisStable;
  final VoidCallback? onSave;
  final VoidCallback? onEdit;

  const NutritionEstimateView({
    super.key,
    required this.result,
    this.stable,
    this.foodPhotoAnalysisStable,
    required this.onSave,
    required this.onEdit,
  });

  bool get _isStable => foodPhotoAnalysisStable ?? stable ?? false;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    final estimate = result.estimate;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: Text('Kết quả ước tính',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w800,
                      ))),
          if (!_isStable)
            Container(
              key: const Key('food-analysis-experimental-badge'),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                  color: colors.orange10,
                  borderRadius: BorderRadius.circular(99)),
              child: Text('Thử nghiệm',
                  style: TextStyle(
                      color: colors.orangeAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
        ]),
        const SizedBox(height: 4),
        Text(result.nameVi,
            style: TextStyle(color: colors.mutedText, fontSize: 16)),
        const SizedBox(height: 16),
        _MetricCard(
            label: 'Calo',
            unit: 'kcal',
            range: estimate.calories,
            accent: AppColors.energyOrange),
        _MetricCard(
            label: 'Đạm',
            unit: 'g',
            range: estimate.proteinGrams,
            accent: AppColors.successGreen),
        _MetricCard(
            label: 'Carbohydrate',
            unit: 'g',
            range: estimate.carbsGrams,
            accent: AppColors.navy),
        _MetricCard(
            label: 'Chất béo',
            unit: 'g',
            range: estimate.fatGrams,
            accent: colors.orangeAccent),
        const SizedBox(height: 12),
        Text('Độ tin cậy: ${_confidenceLabel(result.confidenceLevel)}',
            style: TextStyle(
                color: colors.primaryText, fontWeight: FontWeight.w800)),
        if (result.uncertaintyReasons.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Điểm chưa chắc chắn',
              style: TextStyle(
                  color: colors.primaryText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...result.uncertaintyReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• ${_reasonLabel(reason)}',
                    style: TextStyle(color: colors.mutedText)),
              )),
        ],
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.surfaceGray,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Cách tính',
                      style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(result.calculationSummary,
                      style: TextStyle(color: colors.mutedText)),
                ]),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Ước tính, không phải phép đo y khoa',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        FilledButton(
          key: const Key('food-analysis-save'),
          onPressed: onSave,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.energyOrange,
              minimumSize: const Size.fromHeight(52)),
          child: const Text('Lưu vào nhật ký'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('food-analysis-edit'),
          onPressed: onEdit,
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Chỉnh sửa bằng ảnh mới'),
        ),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String unit;
  final NutritionRange range;
  final Color accent;

  const _MetricCard(
      {required this.label,
      required this.unit,
      required this.range,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: accent.withValues(alpha: .35))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: colors.primaryText, fontWeight: FontWeight.w700))),
          Flexible(
            flex: 2,
            child: Text(
                '${_number(range.min)} – ${_number(range.mid)} – ${_number(range.max)} $unit',
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: colors.primaryText, fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
    );
  }
}

String _confidenceLabel(AnalysisConfidenceLevel confidence) =>
    switch (confidence) {
      AnalysisConfidenceLevel.high => 'Cao',
      AnalysisConfidenceLevel.medium => 'Trung bình',
      AnalysisConfidenceLevel.low => 'Thấp',
    };

String _reasonLabel(FoodUncertaintyReason reason) => switch (reason) {
      FoodUncertaintyReason.hiddenOil => 'Có thể có dầu ẩn trong món.',
      FoodUncertaintyReason.sauce => 'Nước sốt có thể làm thay đổi năng lượng.',
      FoodUncertaintyReason.overlap =>
        'Các thành phần bị chồng lên nhau trong ảnh.',
      FoodUncertaintyReason.weakDatabaseMatch =>
        'Chưa có bản ghi thực phẩm tương đương hoàn toàn.',
    };

String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
