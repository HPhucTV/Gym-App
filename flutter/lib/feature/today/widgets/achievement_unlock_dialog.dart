import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/model/achievement_models.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';

String buildWorkoutShareText(
  String workoutTitle,
  int completed,
  int total,
  List<AchievementType> achievements,
) {
  final safeTotal = total.clamp(0, 999999);
  final safeCompleted = completed.clamp(0, safeTotal);
  final percentage =
      safeTotal == 0 ? 0 : ((safeCompleted * 100) / safeTotal).round();

  final lines = [
    "🏋️ KẾT QUẢ LUYỆN TẬP SMARTGYM 🏋️",
    "💪 Tôi vừa hoàn thành: $workoutTitle",
    "✅ Tiến độ: $safeCompleted/$safeTotal bài tập ($percentage% hoàn thành)",
  ];

  if (achievements.isNotEmpty) {
    lines.add(
        "🏆 Huy hiệu mới: ${achievements.map((a) => a.titleVi).join(', ')}");
  }

  lines.add("🔥 Tập luyện thông minh, offline-first cùng SmartGym!");
  return lines.join("\n");
}

void shareWorkoutSummary({
  required BuildContext context,
  required String workoutTitle,
  required int completed,
  required int total,
  required List<AchievementType> achievements,
}) {
  final shareText =
      buildWorkoutShareText(workoutTitle, completed, total, achievements);
  Clipboard.setData(ClipboardData(text: shareText));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Đã sao chép kết quả tập luyện vào bộ nhớ tạm! 📋"),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class AchievementUnlockDialog extends StatelessWidget {
  final List<AchievementType> badges;
  final String workoutTitle;
  final int completedExercises;
  final int totalExercises;
  final VoidCallback onDismiss;

  const AchievementUnlockDialog({
    super.key,
    required this.badges,
    required this.workoutTitle,
    required this.completedExercises,
    required this.totalExercises,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return AlertDialog(
      title: Column(
        children: [
          const Text(
            "🏆 THÀNH TỰU MỚI!",
            style: TextStyle(
              color: AppColors.energyOrange,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chúc mừng bạn đã mở khóa huy hiệu mới!",
            style: TextStyle(
              fontSize: 13,
              color: customColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: badges.map<Widget>((badge) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              color: colors.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.outline, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.titleVi,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: customColors.primaryText,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge.descriptionVi,
                            style: TextStyle(
                              color: customColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  shareWorkoutSummary(
                    context: context,
                    workoutTitle: workoutTitle,
                    completed: completedExercises,
                    total: totalExercises,
                    achievements: badges,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.energyOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Chia sẻ 🔗",
                  style: TextStyle(
                    color: AppColors.energyOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.energyOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Đóng 🌟",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: colors.surface,
    );
  }
}
