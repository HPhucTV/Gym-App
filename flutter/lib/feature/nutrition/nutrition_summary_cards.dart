import 'dart:math';
import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'nutrition_ui_state.dart';

class CalorieCard extends StatelessWidget {
  final NutritionContent state;

  const CalorieCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress =
        state.calorieLimit > 0 ? state.caloriesEaten / state.calorieLimit : 0.0;
    final isOverLimit = state.caloriesEaten > state.calorieLimit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Ngân sách calo hôm nay",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: customColors.primaryText,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: customColors.primaryText.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: customColors.primaryText.withValues(alpha: 0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.nutritionScoreEmoji,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        "Score: ${state.nutritionScore}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: customColors.primaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${state.nutritionScoreLabel})",
                        style: TextStyle(
                          color: customColors.primaryText.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Đã nạp",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${state.caloriesEaten} / ${state.calorieLimit} kcal",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isOverLimit
                              ? Colors.red
                              : const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 6.0,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: min(progress, 1.0),
                        strokeWidth: 6.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverLimit ? Colors.red : const Color(0xFF22C55E),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                     Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: customColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            MacroRow(
              label: "Đạm (Protein)",
              eaten: state.proteinEaten,
              limit: state.proteinLimit,
              unit: "g",
              color: const Color(0xFF22C55E),
            ),
            MacroRow(
              label: "Tinh bột (Carbs)",
              eaten: state.carbsEaten,
              limit: state.carbsLimit,
              unit: "g",
              color: const Color(0xFFF97316),
            ),
            MacroRow(
              label: "Chất béo (Fat)",
              eaten: state.fatEaten,
              limit: state.fatLimit,
              unit: "g",
              color: const Color(0xFF3B82F6),
            ),
            MacroRow(
              label: "Chất xơ (Fiber)",
              eaten: state.fiberEaten,
              limit: state.fiberLimit,
              unit: "g",
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class WaterCard extends StatelessWidget {
  final NutritionContent state;
  final ValueChanged<int> onAddWater;

  const WaterCard({super.key, required this.state, required this.onAddWater});

  @override
  Widget build(BuildContext context) {
    const targetWater = 2000;
    final progress = (state.waterIntakeMl / targetWater).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Theo dõi Nước uống 💧",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: customColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Đã nạp",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${state.waterIntakeMl} / $targetWater ml",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkRecoveryBlue : const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.water_drop,
                  size: 32,
                  color: isDark ? AppColors.darkRecoveryBlue : const Color(0xFF3B82F6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: state.waterIntakeMl >= 250
                          ? () => onAddWater(-250)
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFFF97316)),
                      ),
                      child: const Text("-250",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF97316))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => onAddWater(100),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("+100",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => onAddWater(250),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("+250",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => onAddWater(500),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("+500",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: isDark ? AppColors.darkRecoveryBlue : const Color(0xFF3B82F6),
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MacroRow extends StatelessWidget {
  final String label;
  final int eaten;
  final int limit;
  final String unit;
  final Color color;

  const MacroRow({
    super.key,
    required this.label,
    required this.eaten,
    required this.limit,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = limit > 0 ? eaten / limit : 0.0;
    final customColors = context.customColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: customColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$eaten / $limit $unit",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: min(fraction, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class SweatPaymentStatusCard extends StatelessWidget {
  final NutritionContent state;
  final VoidCallback onClear;

  const SweatPaymentStatusCard(
      {super.key, required this.state, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkOrangeLight : const Color(0xFFF97316).withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFF97316)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nhiệm vụ bù đắp (Sweat Payment)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: customColors.primaryText,
                    ),
                  ),
                  Text(
                    "Cộng thêm ${state.sweatExtraSets} hiệp ${state.sweatExerciseName} vào buổi tập.",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text("Xóa",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanningCard extends StatelessWidget {
  const ScanningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316))),
            const SizedBox(height: 14),
            Text(
              "Đang phân tích món ăn bằng Gemini AI...",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: customColors.primaryText),
            ),
            const Text(
              "Dịch vụ chạy offline kết nối server",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
