import 'package:flutter/material.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../ui/theme/colors.dart';
import 'food_photo_state.dart';

class MealConfirmationView extends StatelessWidget {
  final FoodPhotoMealDraft draft;
  final List<KnownFoodOption>? catalog;
  final ValueChanged<String>? onNameChanged;
  final void Function(String, String)? onRenameComponent;
  final void Function(String)? onRemoveComponent;
  final void Function(String, FoodPortion)? onPortionChanged;
  final ValueChanged<String>? onChooseKnownFood;
  final VoidCallback? onRetryCatalog;
  final VoidCallback? onManualEntry;
  final VoidCallback? onAddComponent;
  final VoidCallback onConfirm;
  final String? validationMessage;
  final FoodPhotoFieldErrorPath? fieldErrorPath;

  const MealConfirmationView({
    super.key,
    required this.draft,
    this.catalog,
    this.onNameChanged,
    this.onRenameComponent,
    this.onRemoveComponent,
    this.onPortionChanged,
    this.onChooseKnownFood,
    this.onRetryCatalog,
    this.onManualEntry,
    this.onAddComponent,
    required this.onConfirm,
    this.validationMessage,
    this.fieldErrorPath,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Kiểm tra món ăn',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                  'Chỉ các khẩu phần được máy chủ hỗ trợ mới xuất hiện. Bạn luôn có thể chọn món khác hoặc dùng gram khi được hỗ trợ.'),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('meal-name'),
                initialValue: draft.nameVi,
                onChanged: onNameChanged,
                decoration: InputDecoration(
                  labelText: 'Tên bữa ăn',
                  errorText: fieldErrorPath?.kind == FoodPhotoFieldKind.name
                      ? 'Kiểm tra lại tên bữa ăn'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              for (final component in draft.components)
                _MealComponentCard(
                  key: Key('meal-component-${component.observationId}'),
                  component: component,
                  knownFood: catalog
                      ?.where((food) => food.foodId == component.foodId)
                      .firstOrNull,
                  onRename: onRenameComponent,
                  onRemove: onRemoveComponent,
                  onPortionChanged: onPortionChanged,
                  onChooseKnownFood: onChooseKnownFood,
                  fieldErrorPath: fieldErrorPath,
                ),
              if (catalog == null) ...[
                const Text(
                    'Chưa tải được danh sách khẩu phần. Ứng dụng sẽ không đoán đơn vị hoặc mở tùy chọn gram.'),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('known-food-catalog-retry'),
                  onPressed: onRetryCatalog,
                  child: const Text('Tải lại danh sách món'),
                ),
                TextButton(
                  key: const Key('known-food-catalog-manual'),
                  onPressed: onManualEntry,
                  child: const Text('Nhập tay'),
                ),
              ],
              OutlinedButton.icon(
                key: const Key('meal-add-component'),
                onPressed: onAddComponent,
                icon: const Icon(Icons.add),
                label: const Text('Thêm món'),
              ),
              if (draft.components.any((component) =>
                  component.requiresManualPortion &&
                  !component.manualPortionCompleted))
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Vui lòng bổ sung khẩu phần trước khi xác nhận.'),
                ),
              if (validationMessage != null) ...[
                const SizedBox(height: 8),
                Text(validationMessage!,
                    key: const Key('food-analysis-validation-error'),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('food-analysis-confirm'),
                onPressed: draft.canConfirm ? onConfirm : null,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.energyOrange,
                    minimumSize: const Size.fromHeight(52)),
                child: const Text('Xác nhận khẩu phần'),
              ),
            ],
          ),
        ),
      );
}

class _MealComponentCard extends StatefulWidget {
  final FoodPhotoMealComponentDraft component;
  final KnownFoodOption? knownFood;
  final void Function(String, String)? onRename;
  final void Function(String)? onRemove;
  final void Function(String, FoodPortion)? onPortionChanged;
  final ValueChanged<String>? onChooseKnownFood;
  final FoodPhotoFieldErrorPath? fieldErrorPath;

  const _MealComponentCard({
    super.key,
    required this.component,
    required this.knownFood,
    required this.onRename,
    required this.onRemove,
    required this.onPortionChanged,
    required this.onChooseKnownFood,
    required this.fieldErrorPath,
  });

  @override
  State<_MealComponentCard> createState() => _MealComponentCardState();
}

class _MealComponentCardState extends State<_MealComponentCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _gramsController;
  late final FocusNode _nameFocus;
  late final FocusNode _gramsFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.component.nameVi);
    final portion = widget.component.portion;
    _gramsController = TextEditingController(
        text: portion is GramPortion ? _format(portion.grams) : '');
    _nameFocus = FocusNode();
    _gramsFocus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _MealComponentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_nameFocus.hasFocus &&
        _nameController.text != widget.component.nameVi) {
      _nameController.text = widget.component.nameVi;
    }
    final portion = widget.component.portion;
    final grams = portion is GramPortion ? _format(portion.grams) : '';
    if (!_gramsFocus.hasFocus && _gramsController.text != grams) {
      _gramsController.text = grams;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _nameFocus.dispose();
    _gramsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final selected = component.portion is HouseholdPortion
        ? component.portion as HouseholdPortion
        : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                focusNode: _nameFocus,
                onChanged: (value) =>
                    widget.onRename?.call(component.observationId, value),
                decoration: const InputDecoration(labelText: 'Tên món'),
              ),
            ),
            IconButton(
              key: Key('meal-component-remove-${component.observationId}'),
              onPressed: widget.onRemove == null
                  ? null
                  : () => widget.onRemove!(component.observationId),
              icon: const Icon(Icons.delete_outline),
            ),
          ]),
          TextButton.icon(
            key: Key('meal-component-choose-${component.observationId}'),
            onPressed: widget.onChooseKnownFood == null
                ? null
                : () => widget.onChooseKnownFood!(component.observationId),
            icon: const Icon(Icons.restaurant_menu),
            label: Text(widget.knownFood == null
                ? 'Chọn món quen thuộc'
                : 'Đổi món: ${widget.knownFood!.nameVi}'),
          ),
          if (component.requiresManualPortion &&
              !component.manualPortionCompleted)
            const Text('Cần bổ sung khẩu phần'),
          if (widget.knownFood?.portionOptions.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            const Text('Khẩu phần quen thuộc',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              key: Key('portion-household-${component.observationId}'),
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in widget.knownFood!.portionOptions)
                  for (final choice in _portionChoices(option))
                    ChoiceChip(
                      key: Key(
                          'portion-choice-${component.observationId}-${choice.key}'),
                      label: Text(choice.label),
                      selected: selected?.unit == choice.portion.unit &&
                          selected?.quantity == choice.portion.quantity &&
                          selected?.size == choice.portion.size,
                      onSelected: (_) => widget.onPortionChanged
                          ?.call(component.observationId, choice.portion),
                    ),
              ],
            ),
          ],
          if (widget.knownFood?.supportsGrams == true) ...[
            const SizedBox(height: 10),
            TextField(
              key: Key('portion-grams-${component.observationId}'),
              controller: _gramsController,
              focusNode: _gramsFocus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final grams = double.tryParse(value.replaceAll(',', '.'));
                if (grams != null && grams > 0) {
                  widget.onPortionChanged?.call(
                      component.observationId, GramPortion(grams: grams));
                }
              },
              decoration: InputDecoration(
                labelText: 'Gram (tùy chọn)',
                suffixText: 'g',
                errorText: widget.fieldErrorPath?.kind ==
                            FoodPhotoFieldKind.componentPortion &&
                        (widget.fieldErrorPath!.componentId == null ||
                            widget.fieldErrorPath!.componentId ==
                                component.observationId)
                    ? 'Kiểm tra lại khẩu phần này'
                    : null,
              ),
            ),
          ],
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

List<_PortionChoice> _portionChoices(KnownFoodPortionOption option) {
  final quantities = switch (option.unit) {
    HouseholdPortionUnit.bowl => [.5, 1.0, 1.5],
    HouseholdPortionUnit.piece => [1.0, 2.0, 3.0],
    _ => [1.0],
  };
  return [
    for (final quantity in quantities)
      for (final size in option.sizes)
        _PortionChoice(
          '${option.unit.name}-${_format(quantity)}-${size.name}',
          _portionLabel(option.unit, quantity, size),
          HouseholdPortion(unit: option.unit, quantity: quantity, size: size),
        ),
  ];
}

String _portionLabel(HouseholdPortionUnit unit, double quantity,
        HouseholdPortionSize size) =>
    switch (unit) {
      HouseholdPortionUnit.bowl =>
        '${_format(quantity)} bát ${_sizeLabel(size)}',
      HouseholdPortionUnit.piece =>
        '${_format(quantity)} miếng ${_sizeLabel(size)}',
      HouseholdPortionUnit.spoon =>
        '${_format(quantity)} thìa ${_sizeLabel(size)}',
      HouseholdPortionUnit.serving => optionServingLabel(size),
    };

String optionServingLabel(HouseholdPortionSize size) => switch (size) {
      HouseholdPortionSize.small => 'Ít',
      HouseholdPortionSize.medium => 'Vừa',
      HouseholdPortionSize.large => 'Nhiều',
    };

String _sizeLabel(HouseholdPortionSize size) => switch (size) {
      HouseholdPortionSize.small => 'nhỏ',
      HouseholdPortionSize.medium => 'vừa',
      HouseholdPortionSize.large => 'lớn',
    };

String _format(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
