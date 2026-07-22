import 'package:flutter/material.dart';

import '../../../core/model/food_photo_analysis_models.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';
import 'food_photo_state.dart';

class LabelConfirmationView extends StatefulWidget {
  final FoodPhotoLabelDraft draft;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<LabelBasis>? onBasisChanged;
  final void Function(
      {double? calories,
      double? proteinGrams,
      double? carbsGrams,
      double? fatGrams})? onFactsChanged;
  final ValueChanged<double?>? onServingSizeChanged;
  final ValueChanged<double?>? onServingsPerContainerChanged;
  final ValueChanged<double?>? onNetWeightChanged;
  final void Function({LabelConsumedKind? kind, double? amount})?
      onConsumedChanged;
  final VoidCallback onConfirm;
  final String? validationMessage;
  final FoodPhotoFieldErrorPath? fieldErrorPath;

  const LabelConfirmationView({
    super.key,
    required this.draft,
    this.onNameChanged,
    this.onBasisChanged,
    this.onFactsChanged,
    this.onServingSizeChanged,
    this.onServingsPerContainerChanged,
    this.onNetWeightChanged,
    this.onConsumedChanged,
    required this.onConfirm,
    this.validationMessage,
    this.fieldErrorPath,
  });

  @override
  State<LabelConfirmationView> createState() => _LabelConfirmationViewState();
}

class _LabelConfirmationViewState extends State<LabelConfirmationView> {
  late final TextEditingController _name;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _serving;
  late final TextEditingController _consumed;
  late final TextEditingController _servingsPerContainer;
  late final TextEditingController _netWeight;
  TextEditingController? _editingController;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _name = TextEditingController(text: draft.nameVi);
    _calories = _controller(draft.calories);
    _protein = _controller(draft.proteinGrams);
    _carbs = _controller(draft.carbsGrams);
    _fat = _controller(draft.fatGrams);
    _serving = _controller(draft.servingSizeGrams);
    _consumed = _controller(draft.consumed?.amount);
    _servingsPerContainer = _controller(draft.servingsPerContainer);
    _netWeight = _controller(draft.netWeightGrams);
  }

  TextEditingController _controller(double? value) =>
      TextEditingController(text: value == null ? '' : _format(value));

  @override
  void didUpdateWidget(covariant LabelConfirmationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final draft = widget.draft;
    _sync(_name, draft.nameVi);
    _sync(_calories, draft.calories == null ? null : _format(draft.calories!));
    _sync(_protein,
        draft.proteinGrams == null ? null : _format(draft.proteinGrams!));
    _sync(_carbs, draft.carbsGrams == null ? null : _format(draft.carbsGrams!));
    _sync(_fat, draft.fatGrams == null ? null : _format(draft.fatGrams!));
    _sync(
        _serving,
        draft.servingSizeGrams == null
            ? null
            : _format(draft.servingSizeGrams!));
    _sync(_consumed,
        draft.consumed == null ? null : _format(draft.consumed!.amount));
    _sync(
        _servingsPerContainer,
        draft.servingsPerContainer == null
            ? null
            : _format(draft.servingsPerContainer!));
    _sync(_netWeight,
        draft.netWeightGrams == null ? null : _format(draft.netWeightGrams!));
  }

  void _sync(TextEditingController controller, String? value) {
    if (!identical(controller, _editingController) &&
        controller.text != (value ?? '')) {
      controller.text = value ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _calories,
      _protein,
      _carbs,
      _fat,
      _serving,
      _consumed,
      _servingsPerContainer,
      _netWeight,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final colors =
        Theme.of(context).extension<GymCustomColors>() ?? GymCustomColors.light;
    final consumedKind = draft.consumed?.kind ?? LabelConsumedKind.grams;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Kiểm tra nhãn dinh dưỡng',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 6),
          Text('Sửa số đọc từ nhãn và cho biết lượng bạn đã dùng.',
              style: TextStyle(color: colors.mutedText)),
          const SizedBox(height: 16),
          TextField(
              key: const Key('label-name'),
              controller: _name,
              onChanged: widget.onNameChanged,
              decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  errorText:
                      widget.fieldErrorPath?.kind == FoodPhotoFieldKind.name
                          ? 'Kiểm tra lại tên sản phẩm'
                          : null)),
          const SizedBox(height: 16),
          Text('Cơ sở hiển thị',
              style: TextStyle(
                  color: colors.primaryText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _basisChip('label-basis-per-100g', 'Mỗi 100 g', LabelBasis.per100g,
                draft.basis),
            _basisChip('label-basis-per-serving', 'Mỗi khẩu phần',
                LabelBasis.perServing, draft.basis),
          ]),
          if (draft.basis == LabelBasis.unknown)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Chọn cơ sở trên nhãn trước khi xác nhận.',
                  style: TextStyle(
                      color: colors.warningAmber, fontWeight: FontWeight.w600)),
            ),
          if (widget.fieldErrorPath?.kind == FoodPhotoFieldKind.basis)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Kiểm tra lại cơ sở hiển thị',
                  style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          _numberField('label-calories', 'Calo (kcal)', _calories,
              (v) => _emitFacts(calories: v)),
          _numberField('label-protein', 'Đạm (g)', _protein,
              (v) => _emitFacts(proteinGrams: v)),
          _numberField('label-carbs', 'Carbohydrate (g)', _carbs,
              (v) => _emitFacts(carbsGrams: v)),
          _numberField('label-fat', 'Chất béo (g)', _fat,
              (v) => _emitFacts(fatGrams: v)),
          if (draft.basis == LabelBasis.perServing) ...[
            const SizedBox(height: 4),
            _numberField('label-serving-size', 'Khối lượng một khẩu phần (g)',
                _serving, (v) => widget.onServingSizeChanged?.call(v)),
          ],
          _numberField(
              'label-servings-per-container',
              'Số khẩu phần trong bao bì',
              _servingsPerContainer,
              widget.onServingsPerContainerChanged ?? (_) {}),
          _numberField('label-net-weight', 'Khối lượng tịnh (g)', _netWeight,
              widget.onNetWeightChanged ?? (_) {}),
          const SizedBox(height: 10),
          Text('Lượng đã dùng',
              style: TextStyle(
                  color: colors.primaryText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<LabelConsumedKind>(
            key: const Key('label-consumed-kind'),
            segments: const [
              ButtonSegment(
                  value: LabelConsumedKind.grams, label: Text('Gram')),
              ButtonSegment(
                  value: LabelConsumedKind.servings, label: Text('Khẩu phần')),
            ],
            selected: {consumedKind},
            onSelectionChanged: (values) {
              final kind = values.first;
              if (draft.basis == LabelBasis.per100g &&
                  kind == LabelConsumedKind.servings) {
                return;
              }
              final amount =
                  double.tryParse(_consumed.text.replaceAll(',', '.'));
              widget.onConsumedChanged?.call(kind: kind, amount: amount);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('label-consumed-amount'),
            controller: _consumed,
            onTap: () => _editingController = _consumed,
            onEditingComplete: () {
              _editingController = null;
              FocusScope.of(context).unfocus();
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              widget.onConsumedChanged?.call(
                kind: consumedKind,
                amount: double.tryParse(value.replaceAll(',', '.')),
              );
            },
            decoration: InputDecoration(
                labelText: consumedKind == LabelConsumedKind.grams
                    ? 'Số gram đã dùng'
                    : 'Số khẩu phần đã dùng',
                errorText:
                    widget.fieldErrorPath?.kind == FoodPhotoFieldKind.consumed
                        ? 'Kiểm tra lại lượng đã dùng'
                        : null),
          ),
          if (widget.validationMessage != null) ...[
            const SizedBox(height: 8),
            Text(widget.validationMessage!,
                key: const Key('food-analysis-validation-error'),
                style: TextStyle(
                    color: colors.errorRed, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('food-analysis-confirm'),
            onPressed: draft.canConfirm ? widget.onConfirm : null,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.energyOrange,
                minimumSize: const Size.fromHeight(52)),
            child: const Text('Xác nhận thông tin'),
          ),
        ]),
      ),
    );
  }

  Widget _basisChip(
      String key, String label, LabelBasis basis, LabelBasis selected) {
    return ChoiceChip(
      key: Key(key),
      label: Text(label),
      selected: selected == basis,
      onSelected: (_) => widget.onBasisChanged?.call(basis),
    );
  }

  Widget _numberField(String key, String label,
      TextEditingController controller, ValueChanged<double?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        key: Key(key),
        controller: controller,
        onTap: () => _editingController = controller,
        onEditingComplete: () {
          _editingController = null;
          FocusScope.of(context).unfocus();
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) =>
            onChanged(double.tryParse(value.replaceAll(',', '.'))),
        decoration: InputDecoration(
          labelText: label,
          errorText: _fieldHasError(key) ? 'Kiểm tra lại giá trị này' : null,
        ),
      ),
    );
  }

  void _emitFacts(
      {double? calories,
      double? proteinGrams,
      double? carbsGrams,
      double? fatGrams}) {
    widget.onFactsChanged?.call(
      calories:
          calories ?? double.tryParse(_calories.text.replaceAll(',', '.')),
      proteinGrams:
          proteinGrams ?? double.tryParse(_protein.text.replaceAll(',', '.')),
      carbsGrams:
          carbsGrams ?? double.tryParse(_carbs.text.replaceAll(',', '.')),
      fatGrams: fatGrams ?? double.tryParse(_fat.text.replaceAll(',', '.')),
    );
  }

  bool _fieldHasError(String key) {
    final kind = widget.fieldErrorPath?.kind;
    return switch (key) {
      'label-calories' => kind == FoodPhotoFieldKind.calories,
      'label-protein' => kind == FoodPhotoFieldKind.protein,
      'label-carbs' => kind == FoodPhotoFieldKind.carbs,
      'label-fat' => kind == FoodPhotoFieldKind.fat,
      'label-serving-size' => kind == FoodPhotoFieldKind.servingSize,
      _ => false,
    };
  }
}

String _format(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
