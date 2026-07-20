import 'package:flutter/material.dart';
import '../../core/model/nutrition_models.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'nutrition_ui_state.dart';

class NutritionDraftDialog extends StatelessWidget {
  final EditableNutritionDraft draft;
  final bool saving;
  final ValueChanged<String> onName;
  final ValueChanged<String> onCalories;
  final ValueChanged<String> onProtein;
  final ValueChanged<String> onCarbs;
  final ValueChanged<String> onFat;
  final ValueChanged<String> onFiber;
  final ValueChanged<bool?> onSaveAsTemplate;
  final VoidCallback onAccept;
  final VoidCallback onDiscard;

  const NutritionDraftDialog({
    super.key,
    required this.draft,
    required this.saving,
    required this.onName,
    required this.onCalories,
    required this.onProtein,
    required this.onCarbs,
    required this.onFat,
    required this.onFiber,
    required this.onSaveAsTemplate,
    required this.onAccept,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = context.customColors;
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedCornerShape(20.0),
      title: Text(
        "Kiểm tra món ăn",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: customColors.primaryText,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DraftField(
              label: "Tên món",
              value: draft.nameVi,
              onValueChange: onName,
              error: draft.errors["nameVi"],
              numeric: false,
              saving: saving,
            ),
            const SizedBox(height: 12),
            _DraftField(
              label: "Calo",
              value: draft.caloriesText,
              onValueChange: onCalories,
              error: draft.errors["calories"],
              numeric: true,
              saving: saving,
            ),
            const SizedBox(height: 12),
            _DraftField(
              label: "Đạm (g)",
              value: draft.proteinText,
              onValueChange: onProtein,
              error: draft.errors["protein"],
              numeric: true,
              saving: saving,
            ),
            const SizedBox(height: 12),
            _DraftField(
              label: "Tinh bột (g)",
              value: draft.carbsText,
              onValueChange: onCarbs,
              error: draft.errors["carbs"],
              numeric: true,
              saving: saving,
            ),
            const SizedBox(height: 12),
            _DraftField(
              label: "Chất béo (g)",
              value: draft.fatText,
              onValueChange: onFat,
              error: draft.errors["fat"],
              numeric: true,
              saving: saving,
            ),
            const SizedBox(height: 12),
            _DraftField(
              label: "Chất xơ (g)",
              value: draft.fiberText,
              onValueChange: onFiber,
              error: draft.errors["fiber"],
              numeric: true,
              saving: saving,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: draft.saveAsTemplate,
                  onChanged: saving ? null : onSaveAsTemplate,
                  activeColor: const Color(0xFFF97316),
                ),
                Text(
                  "Lưu làm bữa ăn mẫu",
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (draft.errors["submit"] != null) ...[
              const SizedBox(height: 8),
              Text(
                draft.errors["submit"]!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
              ),
            ],
            if (saving) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : onDiscard,
          child: Text("Hủy", style: TextStyle(color: customColors.primaryText)),
        ),
        TextButton(
          onPressed: saving ? null : onAccept,
          child: const Text("Thêm", style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _DraftField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;
  final bool numeric;
  final bool saving;

  const _DraftField({
    required this.label,
    required this.value,
    required this.onValueChange,
    this.error,
    required this.numeric,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return TextFormField(
      initialValue: value,
      onChanged: onValueChange,
      enabled: !saving,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: customColors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: customColors.primaryText.withValues(alpha: 0.7)),
        errorText: error,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF97316)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? AppColors.darkSurface : AppColors.surfaceGray),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class MealTemplateCard extends StatelessWidget {
  final MealTemplate template;
  final bool enabled;
  final VoidCallback onApply;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const MealTemplateCard({
    super.key,
    required this.template,
    required this.enabled,
    required this.onApply,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceGray,
      elevation: 0,
      shape: RoundedCornerShape(14.0),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.nameVi,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: customColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${template.nutrients.calories} kcal · ${template.nutrients.proteinGrams}g đạm · "
              "${template.nutrients.carbsGrams}g carb · ${template.nutrients.fatGrams}g béo",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  key: Key("meal-template-apply-${template.id}"),
                  onPressed: enabled ? onApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedCornerShape(8.0),
                    elevation: 0,
                  ),
                  child: const Text("Thêm"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: enabled ? onRename : null,
                  child: Text("Sửa tên", style: TextStyle(color: customColors.primaryText)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: enabled ? onDelete : null,
                  child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius)
      : super(borderRadius: BorderRadius.circular(radius));
}
