import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/model/nutrition_models.dart';
import 'nutrition_ui_state.dart';
import 'nutrition_view_model.dart';
import 'nutrition_summary_cards.dart';
import 'nutrition_logged_meals_section.dart';
import 'nutrition_cart_section.dart';
import 'food_catalog_section.dart';
import 'nutrition_draft_dialog.dart';
import 'barcode_scanner_view.dart';
import '../../core/nutrition/nutrition_score_calculator.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const NutritionScreen({super.key, required this.onBack});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _FoodScanEntryRow extends StatelessWidget {
  final bool enabled;
  final VoidCallback onScanBarcode;
  final VoidCallback onStartManual;

  const _FoodScanEntryRow({
    required this.enabled,
    required this.onScanBarcode,
    required this.onStartManual,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: enabled ? onScanBarcode : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                elevation: 0,
              ),
              child: const Text(
                "📸 Quét mã vạch",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: enabled ? onStartManual : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                side: const BorderSide(color: Color(0xFF14213D), width: 1),
              ),
              child: const Text(
                "Nhập tay",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14213D)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanRecommendationsDialog extends StatelessWidget {
  final ScanResult scanResult;
  final VoidCallback onDiscard;
  final ValueChanged<ScanRecommendation> onSelect;

  const _ScanRecommendationsDialog({
    required this.scanResult,
    required this.onDiscard,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Gợi ý từ AI 📸",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14213D))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "AI phát hiện đĩa ăn của bạn có thể là một trong các món sau. Vui lòng chọn món đúng:",
              style: TextStyle(color: Color(0xFF14213D), fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...scanResult.recommendations.take(3).map((rec) {
              final confidencePercentage = (rec.confidence * 100).toInt();
              final isLowConfidence = rec.confidence < 0.70;

              return Card(
                color: isLowConfidence
                    ? Colors.red.withValues(alpha: 0.08)
                    : const Color(0xFFF3F4F6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isLowConfidence
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                ),
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rec.dishName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF14213D)),
                            ),
                          ),
                          Text(
                            "$confidencePercentage% tin cậy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLowConfidence
                                  ? Colors.red
                                  : const Color(0xFF22C55E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${rec.calories} kcal | P: ${rec.proteinGrams}g C: ${rec.carbsGrams}g F: ${rec.fatGrams}g",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (isLowConfidence) ...[
                        const SizedBox(height: 4),
                        const Text(
                          "⚠️ Độ tin cậy thấp (< 70%). Vui lòng kiểm tra kỹ.",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                      ],
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => onSelect(rec),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLowConfidence
                              ? Colors.red
                              : const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: const Text("Chọn món này",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDiscard,
          child: const Text("Hủy", style: TextStyle(color: Color(0xFF14213D))),
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final NutritionDay day;

  const _HistoryItemCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final targetCalories = day.target?.calories ?? 2000;
    final caloriesEaten = day.consumed.calories;
    final progress = targetCalories > 0 ? caloriesEaten / targetCalories : 0.0;
    final isOverLimit = caloriesEaten > targetCalories;

    final date =
        DateTime.fromMillisecondsSinceEpoch(day.epochDay * 24 * 60 * 60 * 1000);
    final weekdays = {
      DateTime.monday: 'Thứ hai',
      DateTime.tuesday: 'Thứ ba',
      DateTime.wednesday: 'Thứ tư',
      DateTime.thursday: 'Thứ năm',
      DateTime.friday: 'Thứ sáu',
      DateTime.saturday: 'Thứ bảy',
      DateTime.sunday: 'Chủ nhật',
    };
    final weekday = weekdays[date.weekday] ?? '';
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    final dateText = "$weekday, $dayStr/$monthStr";

    final scoreResult = NutritionScoreCalculator.calculateScore(
      consumed: day.consumed,
      target: day.target ??
          NutritionTarget(
            basalCalories: 2000,
            maintenanceCalories: 2000,
            calories: 2000,
            proteinGrams: 125,
            carbsGrams: 250,
            fatGrams: 55,
            audit: const NutritionTargetAudit(
              rawBasalCalories: 2000,
              rawMaintenanceCalories: 2000,
              rawTargetCalories: 2000,
              rawProteinGrams: 125,
              rawCarbsGrams: 250,
              rawFatGrams: 55,
            ),
          ),
      waterIntakeMl: day.waterIntakeMl,
    );

    return Card(
      color: const Color(0xFFF3F4F6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dateText,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14213D)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF14213D)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: Text(
                              "${scoreResult.emoji} ${scoreResult.score}đ",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14213D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Đạm: ${day.consumed.proteinGrams}g • Carbs: ${day.consumed.carbsGrams}g • Béo: ${day.consumed.fatGrams}g • Xơ: ${day.consumed.fiberGrams}g",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$caloriesEaten / $targetCalories kcal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isOverLimit ? Colors.red : const Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(progress * 100).toInt()}% mục tiêu",
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                color: isOverLimit ? Colors.red : const Color(0xFF22C55E),
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  bool _showBarcodeScanner = false;
  final TextEditingController _renameController = TextEditingController();

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    // Listen to changes to show Toast equivalent (Snackbars) for warnings/errors
    ref.listen(nutritionNotifierProvider, (previous, next) {
      if (next is NutritionContent && previous is NutritionContent) {
        if (next.importSuccess == true && previous.importSuccess != true) {
          if (next.importWarnings.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Nhập thành công nhưng có ${next.importWarnings.length} cảnh báo:\n"
                  "${next.importWarnings.take(3).join("\n")}"
                  "${next.importWarnings.length > 3 ? "\n..." : ""}",
                ),
                backgroundColor: const Color(0xFFF97316),
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Nhập danh mục thực phẩm thành công!"),
                backgroundColor: Color(0xFF22C55E),
              ),
            );
          }
        } else if (next.importSuccess == false &&
            previous.importSuccess != false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  next.importErrorMessage ?? "Lỗi nhập danh mục thực phẩm."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Text(
            "◀",
            style: TextStyle(
                color: Color(0xFFF97316),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "Theo dõi Dinh dưỡng 🥗",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14213D)),
        ),
      ),
      body: Stack(
        children: [
          if (uiState is NutritionLoading)
            const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316))),
            )
          else if (uiState is NutritionContent)
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CalorieCard(state: uiState),
                  const SizedBox(height: 16),
                  WaterCard(
                    state: uiState,
                    onAddWater: notifier.addWater,
                  ),
                  const SizedBox(height: 16),
                  if (uiState.sweatActive) ...[
                    SweatPaymentStatusCard(
                      state: uiState,
                      onClear: notifier.clearSweat,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (uiState.scanning) ...[
                    const ScanningCard(),
                    const SizedBox(height: 16),
                  ] else ...[
                    _FoodScanEntryRow(
                      enabled: !uiState.savingDraft,
                      onScanBarcode: () {
                        setState(() {
                          _showBarcodeScanner = true;
                        });
                      },
                      onStartManual: notifier.startManualEntry,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (uiState.scanError != null) ...[
                    Text(
                      uiState.scanError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  LoggedMealsSection(
                    state: uiState,
                    onCopyYesterdayMeals: notifier.copyYesterdayMeals,
                    onDeleteLoggedFood: notifier.deleteLoggedFood,
                  ),
                  const SizedBox(height: 16),
                  NutritionCartSection(
                    state: uiState,
                    onClearCart: notifier.clearCart,
                    onRemoveFromCart: notifier.removeFromCart,
                    onConfirmEatCart: notifier.confirmEatCart,
                  ),
                  const SizedBox(height: 16),
                  FoodCatalogSection(state: uiState),
                  const SizedBox(height: 24),
                  const Text(
                    "Bữa ăn đã lưu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF14213D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (uiState.mealTemplates.isEmpty)
                    const Text(
                      "Chưa có mẫu. Nhập một món và chọn lưu làm mẫu để dùng lại.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  else
                    ...uiState.mealTemplates.map((template) {
                      return MealTemplateCard(
                        template: template,
                        enabled: !uiState.savingDraft,
                        onApply: () => notifier.applyTemplate(template.id),
                        onRename: () {
                          _renameController.text = template.nameVi;
                          notifier.startRenameTemplate(template.id);
                        },
                        onDelete: () =>
                            notifier.requestDeleteTemplate(template.id),
                      );
                    }),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: notifier.resetDaily,
                      child: const Text(
                        "Đặt lại calo hôm nay",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Lịch sử dinh dưỡng 📊",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF14213D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (uiState.history.isEmpty)
                    Card(
                      color: const Color(0xFFF3F4F6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Chưa có lịch sử dinh dưỡng những ngày trước.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...uiState.history.map((day) => _HistoryItemCard(day: day)),
                ],
              ),
            ),
          if (_showBarcodeScanner)
            BarcodeScannerView(
              onBarcodeDetected: (barcode) {
                setState(() {
                  _showBarcodeScanner = false;
                });
                notifier.scanBarcode(barcode);
              },
              onClose: () {
                setState(() {
                  _showBarcodeScanner = false;
                });
              },
            ),

          // Scan Recommendations Dialog
          if (uiState is NutritionContent &&
              uiState.scanResult != null &&
              uiState.draft == null)
            _ScanRecommendationsDialog(
              scanResult: uiState.scanResult!,
              onDiscard: notifier.discardScanResult,
              onSelect: notifier.selectScanRecommendation,
            ),

          // Draft dialog
          if (uiState is NutritionContent && uiState.draft != null)
            NutritionDraftDialog(
              draft: uiState.draft!,
              saving: uiState.savingDraft,
              onName: notifier.updateDraftName,
              onCalories: notifier.updateDraftCalories,
              onProtein: notifier.updateDraftProtein,
              onCarbs: notifier.updateDraftCarbs,
              onFat: notifier.updateDraftFat,
              onFiber: notifier.updateDraftFiber,
              onSaveAsTemplate: (val) =>
                  notifier.setDraftSaveAsTemplate(val ?? false),
              onAccept: notifier.acceptDraft,
              onDiscard: notifier.discardScanResult,
            ),

          // Delete Template Confirmation Dialog
          if (uiState is NutritionContent &&
              uiState.pendingDeleteTemplateId != null)
            AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Xóa bữa ăn đã lưu?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF14213D))),
              content:
                  const Text("Lịch sử dinh dưỡng đã ghi sẽ không bị thay đổi."),
              actions: [
                TextButton(
                  onPressed: notifier.cancelDeleteTemplate,
                  child: const Text("Hủy",
                      style: TextStyle(color: Color(0xFF14213D))),
                ),
                TextButton(
                  onPressed: notifier.confirmDeleteTemplate,
                  child: const Text("Xóa",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

          // Rename Template Dialog
          if (uiState is NutritionContent && uiState.templateNameEdit != null)
            AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Sửa tên bữa ăn",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF14213D))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _renameController,
                    onChanged: notifier.updateTemplateName,
                    enabled: !uiState.savingDraft,
                    style: const TextStyle(color: Color(0xFF14213D)),
                    decoration: InputDecoration(
                      labelText: "Tên món",
                      labelStyle: const TextStyle(color: Color(0xFF14213D)),
                      errorText: uiState.templateNameEdit!.error,
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF97316)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: notifier.cancelRenameTemplate,
                  child: const Text("Hủy",
                      style: TextStyle(color: Color(0xFF14213D))),
                ),
                TextButton(
                  onPressed: notifier.confirmRenameTemplate,
                  child: const Text("Lưu",
                      style: TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
