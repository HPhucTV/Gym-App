import 'package:flutter/material.dart';
import '../../../core/model/goal_models.dart';
import '../../../core/model/catalog_models.dart';
import '../../../ui/components/exercise_3d_dialog.dart';
import '../today_ui_state.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';

class ExerciseCard extends StatefulWidget {
  final int sessionId;
  final WorkoutRowUi row;
  final bool enabled;
  final ValueChanged<bool> onCheckedChange;
  final VoidCallback onSubstitute;

  const ExerciseCard({
    super.key,
    required this.sessionId,
    required this.row,
    required this.enabled,
    required this.onCheckedChange,
    required this.onSubstitute,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _expanded = false;
  bool _show3DDialog = false;

  String _muscleEmoji(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return "🫁";
      case MuscleGroup.back:
        return "🔙";
      case MuscleGroup.shoulders:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
        return "💪";
      case MuscleGroup.core:
        return "🎯";
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
        return "🦵";
      case MuscleGroup.glutes:
        return "🍑";
      case MuscleGroup.calves:
        return "🦶";
      case MuscleGroup.fullBody:
        return "🏋️";
      case MuscleGroup.cardio:
        return "❤️";
      case MuscleGroup.mobility:
        return "🧘";
    }
  }

  String _muscleLabelVi(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return "Ngực";
      case MuscleGroup.back:
        return "Lưng";
      case MuscleGroup.shoulders:
        return "Vai";
      case MuscleGroup.biceps:
        return "Tay trước";
      case MuscleGroup.triceps:
        return "Tay sau";
      case MuscleGroup.core:
        return "Cơ bụng";
      case MuscleGroup.quads:
        return "Đùi trước";
      case MuscleGroup.hamstrings:
        return "Đùi sau";
      case MuscleGroup.glutes:
        return "Mông";
      case MuscleGroup.calves:
        return "Bắp chân";
      case MuscleGroup.fullBody:
        return "Toàn thân";
      case MuscleGroup.cardio:
        return "Tim mạch";
      case MuscleGroup.mobility:
        return "Linh hoạt";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    final borderColor = widget.row.isChecked
        ? customColors.checkedCardBorder
        : colors.outline.withValues(alpha: 0.3);

    final bgColor = widget.row.isChecked
        ? customColors.greenLight
        : colors.surfaceContainerHighest.withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Exercise Number/Checkmark Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.row.isChecked
                      ? AppColors.successGreen
                      : AppColors.energyOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.row.isChecked ? "✓" : "${widget.row.orderIndex + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Focus Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.row.nameVi,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: customColors.primaryText,
                              decoration: widget.row.isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        if (widget.row.isLightWorkout) ...[
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.energyOrange
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: const Text(
                              "Tập nhẹ",
                              style: TextStyle(
                                color: AppColors.energyOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _muscleEmoji(widget.row.primaryMuscleGroup),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${widget.row.prescriptionText} · nghỉ ${widget.row.restSeconds}s",
                            style: TextStyle(
                              color: customColors.mutedText,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              // Checkbox Toggle
              Checkbox(
                value: widget.row.isChecked,
                onChanged: widget.enabled
                    ? (val) => widget.onCheckedChange(val ?? false)
                    : null,
                activeColor: AppColors.successGreen,
                side: BorderSide(color: colors.outline),
              )
            ],
          ),

          // Instructions Trigger Link
          InkWell(
            onTap: widget.enabled
                ? () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    _expanded ? "Ẩn hướng dẫn ▲" : "Xem hướng dẫn ▼",
                    style: const TextStyle(
                      color: AppColors.energyOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Instruction Sheet
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2D Image Fallback (loads locally from flutter assets if present)
                            if (widget.row.gif3dPath != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  widget.row.gif3dPath!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Sometime asset path might have android-specific references, load fallback gracefully
                                    return Container(
                                      height: 60,
                                      color: colors.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "🏋️",
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Step-by-Step Instructions
                            ...List.generate(widget.row.instructionsVi.length,
                                (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${index + 1}.",
                                      style: const TextStyle(
                                        color: AppColors.energyOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.row.instructionsVi[index],
                                        style: TextStyle(
                                          color: customColors.primaryText,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 12),
                            // Launch 3D Model Dialog
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _show3DDialog = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.energyOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "Xem 3D trực quan 🔄",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Exercise Substitution Triggers
          if (!widget.row.isChecked) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.enabled ? widget.onSubstitute : null,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Thay bài",
                  style: TextStyle(
                    color: AppColors.energyOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expand state if workout session or exercise ID changed
    if (oldWidget.row.exerciseId != widget.row.exerciseId ||
        oldWidget.sessionId != widget.sessionId) {
      setState(() {
        _expanded = false;
        _show3DDialog = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Launch 3D dialogue in post-frame callback if active
    if (_show3DDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Exercise3DDialog(
              exerciseId: widget.row.exerciseId,
              exerciseName: widget.row.nameVi,
              instructions: widget.row.instructionsVi,
              onDismiss: () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    _show3DDialog = false;
                  });
                }
              },
            );
          },
        );
      });
    }
  }
}
