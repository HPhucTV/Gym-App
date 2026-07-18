import 'package:flutter/material.dart';
import '../today_ui_state.dart';

class ExerciseSubstitutionDialog extends StatelessWidget {
  final ExerciseSubstitutionUi state;
  final ValueChanged<String> onApply;
  final VoidCallback onDismiss;

  const ExerciseSubstitutionDialog({
    super.key,
    required this.state,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        "Thay ${state.currentNameVi}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.candidates.map((candidate) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: OutlinedButton(
                onPressed: () => onApply(candidate.exerciseId),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colors.outline),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.restoresOriginal
                            ? "${candidate.nameVi} · Bài gốc"
                            : candidate.nameVi,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.equipment
                            .map((e) =>
                                e.name.toLowerCase().replaceAll('_', ' '))
                            .join(', '),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      if (candidate.instructionsVi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          candidate.instructionsVi.first,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text("Đóng"),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: colors.surface,
    );
  }
}
