import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'weekly_checkin_ui_state.dart';
import 'weekly_checkin_view_model.dart';

class WeeklyCheckInScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigateToProfile;

  const WeeklyCheckInScreen({
    super.key,
    required this.onBack,
    required this.onNavigateToProfile,
  });

  @override
  ConsumerState<WeeklyCheckInScreen> createState() =>
      _WeeklyCheckInScreenState();
}

class _WeeklyCheckInScreenState extends ConsumerState<WeeklyCheckInScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _initialized = false;
  bool _dialogShown = false;

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Thành công",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Check-in tuần đã được lưu thành công!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              ref.read(weeklyCheckInNotifierProvider.notifier).clearSuccess();
              widget.onBack(); // Go back
            },
            child: const Text(
              "Đồng ý",
              style: TextStyle(
                color: AppColors.energyOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(weeklyCheckInUiStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    // Listen to success to show dialog
    ref.listen<WeeklyCheckInState>(weeklyCheckInNotifierProvider, (prev, next) {
      if (next.success) {
        _showSuccessDialog(context);
      }
    });

    // Initialize controller values once when state loaded
    if (uiState is WeeklyCheckInInput && !_initialized) {
      _weightController.text = uiState.weightKgStr;
      _noteController.text = uiState.note;
      _initialized = true;
    }

    if (uiState is WeeklyCheckInLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
          ),
        ),
      );
    }

    if (uiState is WeeklyCheckInNoProfile) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("👤", style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  "Yêu cầu Hồ sơ cá nhân",
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Bạn cần thiết lập hồ sơ cá nhân và đồng ý cá nhân hóa trước khi tiến hành Check-in tuần.",
                  style: TextStyle(
                    color: customColors.mutedText,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onNavigateToProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.energyOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "ĐI TỚI HỒ SƠ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onBack,
                  child: Text(
                    "Quay lại",
                    style:
                        TextStyle(color: customColors.mutedText, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final inputState = uiState as WeeklyCheckInInput;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    onTap: widget.onBack,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Quay lại ⬅",
                        style: TextStyle(
                          color: AppColors.energyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "CHECK-IN TUẦN",
                    style: TextStyle(
                      color: customColors.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Trend Analysis Card
              if (inputState.historySummary.totalCheckIns > 0) ...[
                _buildTrendCard(context, inputState, customColors, isDark),
                const SizedBox(height: 20),
              ],

              // Weight Input Card
              _buildFormCard(
                context,
                title: "Cân nặng tuần này",
                isDark: isDark,
                customColors: customColors,
                child: TextField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Cân nặng thực tế",
                    labelStyle: const TextStyle(color: AppColors.energyOrange),
                    suffixText: "kg ",
                    suffixStyle: TextStyle(
                        color: customColors.primaryText,
                        fontWeight: FontWeight.bold),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.energyOrange, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.borderGray),
                    ),
                  ),
                  style: TextStyle(color: customColors.primaryText),
                  onChanged: (val) {
                    ref
                        .read(weeklyCheckInNotifierProvider.notifier)
                        .updateWeight(val);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Wellness Questions Card
              _buildFormCard(
                context,
                title: "Đánh giá thể trạng (Thang điểm 1 - 5)",
                isDark: isDark,
                customColors: customColors,
                child: Column(
                  children: [
                    _buildScaleSelector(
                      label: "⚡ Mức năng lượng",
                      value: inputState.energy,
                      onChanged: (val) => ref
                          .read(weeklyCheckInNotifierProvider.notifier)
                          .updateEnergy(val),
                      isDark: isDark,
                      customColors: customColors,
                    ),
                    const SizedBox(height: 16),
                    _buildScaleSelector(
                      label: "🍕 Mức thèm ăn",
                      value: inputState.hunger,
                      onChanged: (val) => ref
                          .read(weeklyCheckInNotifierProvider.notifier)
                          .updateHunger(val),
                      isDark: isDark,
                      customColors: customColors,
                    ),
                    const SizedBox(height: 16),
                    _buildScaleSelector(
                      label: "🧘 Khả năng phục hồi",
                      value: inputState.recovery,
                      onChanged: (val) => ref
                          .read(weeklyCheckInNotifierProvider.notifier)
                          .updateRecovery(val),
                      isDark: isDark,
                      customColors: customColors,
                    ),
                    const SizedBox(height: 16),
                    _buildScaleSelector(
                      label: "😴 Chất lượng giấc ngủ",
                      value: inputState.sleepQuality,
                      onChanged: (val) => ref
                          .read(weeklyCheckInNotifierProvider.notifier)
                          .updateSleepQuality(val),
                      isDark: isDark,
                      customColors: customColors,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notes Card
              _buildFormCard(
                context,
                title: "Ghi chú bổ sung",
                isDark: isDark,
                customColors: customColors,
                child: TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Ghi chú cá nhân (tùy chọn)",
                    labelStyle: const TextStyle(color: AppColors.energyOrange),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.energyOrange, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.borderGray),
                    ),
                  ),
                  style: TextStyle(color: customColors.primaryText),
                  onChanged: (val) => ref
                      .read(weeklyCheckInNotifierProvider.notifier)
                      .updateNote(val),
                ),
              ),

              // Validation errors
              if (inputState.validationErrors.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: inputState.validationErrors.map((err) {
                      return Text(
                        "- $err",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 14,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // Submission error
              if (inputState.error != null) ...[
                const SizedBox(height: 20),
                Text(
                  inputState.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey("checkin-submit-button"),
                  onPressed: inputState.isSubmitting
                      ? null
                      : () => ref
                          .read(weeklyCheckInNotifierProvider.notifier)
                          .submitCheckIn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.energyOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: inputState.isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "LƯU CHECK-IN",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required String title,
    required Widget child,
    required bool isDark,
    required GymCustomColors customColors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: customColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    WeeklyCheckInInput state,
    GymCustomColors customColors,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkOrangeLight.withValues(alpha: 0.15)
            : AppColors.energyOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.energyOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📈 XU HƯỚNG TUẦN QUA",
            style: TextStyle(
              color: AppColors.energyOrange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tổng số Check-in",
                      style: TextStyle(
                          color: customColors.mutedText, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    "${state.historySummary.totalCheckIns} tuần",
                    style: TextStyle(
                        color: customColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              if (state.historySummary.weightChangeKg != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Thay đổi cân nặng",
                        style: TextStyle(
                            color: customColors.mutedText, fontSize: 11)),
                    const SizedBox(height: 2),
                    () {
                      final change = state.historySummary.weightChangeKg!;
                      final sign = change >= 0 ? "+" : "";
                      final color = change > 0
                          ? AppColors.energyOrange
                          : AppColors.successGreen;
                      return Text(
                        "$sign${change.toStringAsFixed(1)} kg",
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      );
                    }(),
                  ],
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
                color: (isDark ? AppColors.darkBorder : AppColors.borderGray)
                    .withValues(alpha: 0.3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Điểm Phục Hồi TB",
                      style: TextStyle(
                          color: customColors.mutedText, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    "${state.historySummary.averageRecovery.toStringAsFixed(1)} / 5",
                    style: TextStyle(
                        color: customColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Điểm Giấc Ngủ TB",
                      style: TextStyle(
                          color: customColors.mutedText, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    "${state.historySummary.averageSleep.toStringAsFixed(1)} / 5",
                    style: TextStyle(
                        color: customColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
                color: (isDark ? AppColors.darkBorder : AppColors.borderGray)
                    .withValues(alpha: 0.3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dinh dưỡng TB tuần",
                        style: TextStyle(
                            color: customColors.mutedText, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      "${state.historySummary.averageWeeklyCalories.round()} kcal  •  ${state.historySummary.averageWeeklyProtein.round()}g P  •  ${state.historySummary.averageWeeklyCarbs.round()}g C  •  ${state.historySummary.averageWeeklyFat.round()}g F",
                      style: TextStyle(
                        color: customColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Điểm Dinh dưỡng TB",
                      style: TextStyle(
                          color: customColors.mutedText, fontSize: 11)),
                  const SizedBox(height: 2),
                  () {
                    final score = state.historySummary.averageWeeklyScore;
                    final String scoreLabel;
                    final Color scoreColor;
                    if (score >= 90) {
                      scoreLabel = "🌟 Xuất sắc";
                      scoreColor = AppColors.successGreen;
                    } else if (score >= 70) {
                      scoreLabel = "✅ Tốt";
                      scoreColor = AppColors.successGreen;
                    } else if (score >= 50) {
                      scoreLabel = "⚠️ Khá";
                      scoreColor = AppColors.energyOrange;
                    } else if (score > 0) {
                      scoreLabel = "🔴 Chưa đạt";
                      scoreColor = Theme.of(context).colorScheme.error;
                    } else {
                      scoreLabel = "—";
                      scoreColor = customColors.mutedText;
                    }
                    return Text(
                      "${score.round()} đ ($scoreLabel)",
                      style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    );
                  }(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScaleSelector({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required bool isDark,
    required GymCustomColors customColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: customColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final num = index + 1;
            final selected = value == num;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(num),
                child: Container(
                  height: 48,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 4 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark
                            ? AppColors.darkOrangeLight
                            : AppColors.orangeLight)
                        : (isDark ? AppColors.darkBg : AppColors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.energyOrange
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.borderGray),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    num.toString(),
                    style: TextStyle(
                      color: selected
                          ? AppColors.energyOrange
                          : customColors.primaryText,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
