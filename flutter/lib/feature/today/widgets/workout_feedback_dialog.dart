import 'package:flutter/material.dart';
import '../../../core/model/feedback_models.dart';
import '../today_ui_state.dart';
import '../../../ui/theme/theme.dart';

class WorkoutFeedbackDialog extends StatelessWidget {
  final PendingWorkoutFeedback feedback;
  final ValueChanged<WorkoutDifficulty> onDifficultySelected;
  final VoidCallback onDismiss;

  const WorkoutFeedbackDialog({
    super.key,
    required this.feedback,
    required this.onDifficultySelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    final choices = [
      MapEntry(WorkoutDifficulty.easy, "Quá nhẹ"),
      MapEntry(WorkoutDifficulty.right, "Vừa sức"),
      MapEntry(WorkoutDifficulty.hard, "Quá nặng"),
    ];

    return PopScope(
      canPop: !feedback.saving,
      child: AlertDialog(
        title: Text(
          "Buổi tập vừa rồi thế nào?",
          style: TextStyle(
            color: customColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phản hồi này giúp điều chỉnh các buổi sau mà không cần ghi tạ hay số lần tập.",
              style: TextStyle(
                color: customColors.mutedText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...choices.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: feedback.saving
                        ? null
                        : () => onDifficultySelected(entry.key),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
            if (feedback.saving) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (feedback.error != null) ...[
              const SizedBox(height: 8),
              Text(
                feedback.error!,
                style: TextStyle(color: colors.error, fontSize: 13),
              )
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: feedback.saving ? null : onDismiss,
            child: const Text("Để sau"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colors.surface,
      ),
    );
  }
}
