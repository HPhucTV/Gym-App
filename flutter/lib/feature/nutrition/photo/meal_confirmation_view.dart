import 'package:flutter/material.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';
import 'food_photo_state.dart';

/// Review and correction form for photographed meals.
///
/// All edits are emitted as typed [FoodPortion] values so the notifier remains
/// the owner of the confirmation contract.
class MealConfirmationView extends StatelessWidget {
  final FoodPhotoMealDraft draft;
  final ValueChanged<String>? onNameChanged;
  final void Function(String observationId, String name)? onRenameComponent;
  final void Function(String observationId)? onRemoveComponent;
  final void Function(String observationId, FoodPortion portion)?
      onPortionChanged;
  final VoidCallback? onAddComponent;
  final VoidCallback onConfirm;
  final String? validationMessage;

  const MealConfirmationView({
    super.key,
    required this.draft,
    this.onNameChanged,
    this.onRenameComponent,
    this.onRemoveComponent,
    this.onPortionChanged,
    this.onAddComponent,
    required this.onConfirm,
    this.validationMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kiểm tra món ăn',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 6),
            Text(
                'Chọn khẩu phần quen thuộc. Có thể đổi sang gram nếu bạn biết chính xác.',
                style: TextStyle(color: colors.mutedText)),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('meal-name'),
              initialValue: draft.nameVi,
              onChanged: onNameChanged,
              decoration: const InputDecoration(labelText: 'Tên bữa ăn'),
            ),
            const SizedBox(height: 16),
            ...draft.components.map((component) => _MealComponentCard(
                  component: component,
                  onRename: onRenameComponent,
                  onRemove: onRemoveComponent,
                  onPortionChanged: onPortionChanged,
                )),
            OutlinedButton.icon(
              key: const Key('meal-add-component'),
              onPressed: onAddComponent,
              icon: const Icon(Icons.add),
              label: const Text('Thêm món'),
            ),
            if (draft.components.any(
                (c) => c.requiresManualPortion && !c.manualPortionCompleted))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Vui lòng bổ sung khẩu phần cho món được đánh dấu trước khi xác nhận.',
                  style: TextStyle(
                      color: colors.warningAmber, fontWeight: FontWeight.w600),
                ),
              ),
            if (validationMessage != null) ...[
              const SizedBox(height: 8),
              Text(validationMessage!,
                  key: const Key('food-analysis-validation-error'),
                  style: TextStyle(
                      color: colors.errorRed, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('food-analysis-confirm'),
              onPressed: draft.canConfirm ? onConfirm : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.energyOrange,
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Xác nhận khẩu phần'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealComponentCard extends StatefulWidget {
  final FoodPhotoMealComponentDraft component;
  final void Function(String, String)? onRename;
  final void Function(String)? onRemove;
  final void Function(String, FoodPortion)? onPortionChanged;

  const _MealComponentCard({
    required this.component,
    required this.onRename,
    required this.onRemove,
    required this.onPortionChanged,
  });

  @override
  State<_MealComponentCard> createState() => _MealComponentCardState();
}

class _MealComponentCardState extends State<_MealComponentCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.component.nameVi);
    final portion = widget.component.portion;
    _gramsController = TextEditingController(
      text: portion is GramPortion ? _format(portion.grams) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _MealComponentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component.nameVi != widget.component.nameVi &&
        _nameController.text != widget.component.nameVi) {
      _nameController.text = widget.component.nameVi;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    final unit = _defaultUnit(component.nameVi);
    final selected = component.portion is HouseholdPortion
        ? component.portion as HouseholdPortion
        : null;
    return Card(
      key: Key('meal-component-${component.observationId}'),
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.surfaceGray,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: TextField(
                key: Key('meal-component-name-${component.observationId}'),
                controller: _nameController,
                onChanged: (value) =>
                    widget.onRename?.call(component.observationId, value),
                decoration: const InputDecoration(labelText: 'Tên món'),
              ),
            ),
            IconButton(
              key: Key('meal-component-remove-${component.observationId}'),
              tooltip: 'Xóa món',
              onPressed: widget.onRemove == null
                  ? null
                  : () => widget.onRemove!(component.observationId),
              icon: Icon(Icons.delete_outline, color: colors.errorRed),
            ),
          ]),
          if (component.requiresManualPortion &&
              !component.manualPortionCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Cần bổ sung khẩu phần',
                  style: TextStyle(
                      color: colors.warningAmber, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 10),
          Text('Khẩu phần quen thuộc',
              style: TextStyle(
                  color: colors.primaryText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            key: Key('portion-household-${component.observationId}'),
            spacing: 8,
            runSpacing: 8,
            children: _portionChoices(unit, selected).map((choice) {
              return ChoiceChip(
                key: Key(
                    'portion-choice-${component.observationId}-${choice.key}'),
                label: Text(choice.label),
                selected: selected?.unit == choice.portion.unit &&
                    selected?.quantity == choice.portion.quantity &&
                    selected?.size == choice.portion.size,
                onSelected: (_) => widget.onPortionChanged
                    ?.call(component.observationId, choice.portion),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            key: Key('portion-grams-${component.observationId}'),
            controller: _gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final grams = double.tryParse(value.replaceAll(',', '.'));
              if (grams != null && grams > 0) {
                widget.onPortionChanged
                    ?.call(component.observationId, GramPortion(grams: grams));
              }
            },
            decoration: const InputDecoration(
                labelText: 'Gram (tùy chọn)', suffixText: 'g'),
          ),
        ]),
      ),
    );
  }
}

class _PortionChoice {
  final String key;
  final String label;
  final HouseholdPortion portion;

  const _PortionChoice(this.key, this.label, this.portion);
}

HouseholdPortionUnit _defaultUnit(String name) {
  final value = name.toLowerCase();
  if (value.contains('cơm') ||
      value.contains('rice') ||
      value.contains('bún') ||
      value.contains('mì')) {
    return HouseholdPortionUnit.bowl;
  }
  if (value.contains('thịt') ||
      value.contains('cá') ||
      value.contains('gà') ||
      value.contains('fish') ||
      value.contains('meat')) {
    return HouseholdPortionUnit.piece;
  }
  if (value.contains('rau') ||
      value.contains('canh') ||
      value.contains('súp') ||
      value.contains('sốt') ||
      value.contains('sauce')) {
    return HouseholdPortionUnit.spoon;
  }
  return HouseholdPortionUnit.serving;
}

List<_PortionChoice> _portionChoices(
    HouseholdPortionUnit unit, HouseholdPortion? selected) {
  final size = selected?.size ?? HouseholdPortionSize.medium;
  switch (unit) {
    case HouseholdPortionUnit.bowl:
      return [
        _PortionChoice('half-bowl', '½ bát',
            HouseholdPortion(unit: unit, quantity: .5, size: size)),
        _PortionChoice('one-bowl', '1 bát',
            HouseholdPortion(unit: unit, quantity: 1, size: size)),
        _PortionChoice('one-half-bowl', '1½ bát',
            HouseholdPortion(unit: unit, quantity: 1.5, size: size)),
      ];
    case HouseholdPortionUnit.piece:
      return [
        for (final quantity in [1.0, 2.0, 3.0])
          for (final choice in [
            (HouseholdPortionSize.small, 'nhỏ'),
            (HouseholdPortionSize.medium, 'vừa'),
            (HouseholdPortionSize.large, 'lớn'),
          ])
            _PortionChoice(
                '${quantity.toInt()}-${choice.$1.name}',
                '${quantity.toInt()} miếng ${choice.$2}',
                HouseholdPortion(
                    unit: unit, quantity: quantity, size: choice.$1)),
      ];
    case HouseholdPortionUnit.spoon:
      return [
        _PortionChoice(
            'little',
            'Ít',
            HouseholdPortion(
                unit: unit, quantity: 1, size: HouseholdPortionSize.small)),
        _PortionChoice(
            'medium',
            'Vừa',
            HouseholdPortion(
                unit: unit, quantity: 2, size: HouseholdPortionSize.medium)),
        _PortionChoice(
            'much',
            'Nhiều',
            HouseholdPortion(
                unit: unit, quantity: 3, size: HouseholdPortionSize.large)),
      ];
    case HouseholdPortionUnit.serving:
      return [
        _PortionChoice(
            'small-serving',
            'Nhỏ',
            HouseholdPortion(
                unit: unit, quantity: 1, size: HouseholdPortionSize.small)),
        _PortionChoice(
            'medium-serving',
            'Vừa',
            HouseholdPortion(
                unit: unit, quantity: 1, size: HouseholdPortionSize.medium)),
        _PortionChoice(
            'large-serving',
            'Lớn',
            HouseholdPortion(
                unit: unit, quantity: 1, size: HouseholdPortionSize.large)),
      ];
  }
}

String _format(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
