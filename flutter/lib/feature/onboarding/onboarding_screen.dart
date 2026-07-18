import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/goal_models.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'onboarding_ui_state.dart';
import 'onboarding_view_model.dart';

class OnboardingScreen extends ConsumerWidget {
  final bool replacementMode;
  final VoidCallback onCancel;
  final VoidCallback onGoalCreated;

  const OnboardingScreen({
    super.key,
    this.replacementMode = false,
    required this.onCancel,
    required this.onGoalCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);

    ref.listen<OnboardingUiState>(onboardingNotifierProvider, (previous, next) {
      next.maybeWhen(
        created: onGoalCreated,
        orElse: () {},
      );
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: state.when(
          editing: (step, draft, options, isSaving, saveError) =>
              _buildEditingContent(
            context,
            ref,
            step,
            draft,
            options,
            isSaving,
            saveError,
          ),
          unsupported: (draft, explanation, alternatives) =>
              _buildUnsupportedContent(
            context,
            ref,
            explanation,
            alternatives,
          ),
          created: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingContent(
    BuildContext context,
    WidgetRef ref,
    OnboardingStep step,
    OnboardingDraft draft,
    OnboardingOptions options,
    bool isSaving,
    String? saveError,
  ) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final customColors = context.customColors;
    final stepNumber = step.index + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Info
        Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 24.0, bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    replacementMode ? "Đổi mục tiêu" : "Tạo mục tiêu",
                    style: const TextStyle(
                      color: AppColors.energyOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Bước $stepNumber/8",
                    style: TextStyle(
                      color: customColors.mutedText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: stepNumber / 8.0,
                  minHeight: 6,
                  backgroundColor: customColors.orangeLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.energyOrange),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _stepTitle(step),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customColors.primaryText,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _stepExplanation(step, replacementMode),
                style: TextStyle(
                  color: customColors.mutedText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildSelectionSummary(context, draft),
            ],
          ),
        ),

        // Scrollable Choice List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            children: [
              ..._buildStepOptions(step, draft, options, notifier),
              if (saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    saveError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom Navigation Bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Row(
            children: [
              if (step != OnboardingStep.personalInfo || replacementMode) ...[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isSaving
                          ? null
                          : () => notifier.back(() {
                                onCancel();
                              }),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                            color: AppColors.energyOrange, width: 1),
                        foregroundColor: AppColors.energyOrange,
                      ),
                      child: Text(
                        step == OnboardingStep.personalInfo
                            ? "Hủy"
                            : "Quay lại",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isSaving || !_canAdvance(step, draft))
                        ? null
                        : () {
                            if (step == OnboardingStep.review) {
                              notifier.createGoal();
                            } else {
                              notifier.next();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.energyOrange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.energyOrange.withValues(alpha: 0.4),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isSaving
                          ? "Đang tạo…"
                          : (step == OnboardingStep.review
                              ? "Tạo mục tiêu"
                              : "Tiếp tục"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnsupportedContent(
    BuildContext context,
    WidgetRef ref,
    String explanation,
    List<String> alternatives,
  ) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final customColors = context.customColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chưa thể tạo mục tiêu",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customColors.primaryText,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            explanation,
            style: TextStyle(color: customColors.primaryText, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Text(
            "Các cấu hình đang được hỗ trợ",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: customColors.primaryText,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: alternatives.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alternatives[index],
                    style: TextStyle(color: customColors.primaryText),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => notifier.back(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energyOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Thay đổi lựa chọn",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSummary(BuildContext context, OnboardingDraft draft) {
    final customColors = context.customColors;
    final items = <String>[];

    if (draft.gender != null) items.add(draft.gender!.labelVi());
    if (draft.bodyType != null) items.add(draft.bodyType!.labelVi());
    if (draft.goals.isNotEmpty) {
      items.add(draft.goals.map((g) => g.labelVi()).join("+"));
    }
    if (draft.level != null) items.add(draft.level!.labelVi());
    if (draft.equipment != null) items.add(draft.equipment!.labelVi());
    if (draft.trainingDays.isNotEmpty) {
      items.add("${draft.trainingDays.length} buổi/tuần");
    }
    if (draft.sessionDurationMinutes != null) {
      items.add("${draft.sessionDurationMinutes} phút");
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
      child: Text(
        items.join("  •  "),
        style: TextStyle(
          color: customColors.mutedText,
          fontSize: 12,
        ),
      ),
    );
  }

  List<Widget> _buildStepOptions(
    OnboardingStep step,
    OnboardingDraft draft,
    OnboardingOptions options,
    OnboardingNotifier notifier,
  ) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Giới tính",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...Gender.values.map(
            (gender) => _buildChoiceItem(
              title: gender.labelVi(),
              subtitle: gender == Gender.male
                  ? "Phù hợp cho cơ thể nam giới"
                  : "Phù hợp cho cơ thể nữ giới",
              selected: draft.gender == gender,
              onTap: () => notifier.selectGender(gender),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Tạng người",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...BodyType.values.map(
            (bodyType) => _buildChoiceItem(
              title: bodyType.labelVi(),
              subtitle: _bodyTypeExplanation(bodyType),
              selected: draft.bodyType == bodyType,
              onTap: () => notifier.selectBodyType(bodyType),
            ),
          ),
        ];

      case OnboardingStep.goal:
        return options.goals
            .map(
              (goal) => _buildChoiceItem(
                title: goal.labelVi(),
                subtitle: _goalExplanation(goal),
                selected: draft.goals.contains(goal),
                isMultiSelect: true,
                onTap: () => notifier.toggleGoal(goal),
              ),
            )
            .toList();

      case OnboardingStep.level:
        return options.levels
            .map(
              (level) => _buildChoiceItem(
                title: level.labelVi(),
                subtitle: _levelExplanation(level),
                selected: draft.level == level,
                onTap: () => notifier.selectLevel(level),
              ),
            )
            .toList();

      case OnboardingStep.equipment:
        return options.equipment
            .map(
              (equipment) => _buildChoiceItem(
                title: equipment.labelVi(),
                subtitle: _equipmentExplanation(equipment),
                selected: draft.equipment == equipment,
                onTap: () => notifier.selectEquipment(equipment),
              ),
            )
            .toList();

      case OnboardingStep.trainingDays:
        return WeekDay.values
            .map(
              (day) => _buildChoiceItem(
                title: day.labelVi(),
                subtitle: _dayHint(day),
                selected: draft.trainingDays.contains(day),
                isMultiSelect: true,
                onTap: () => notifier.toggleTrainingDay(day),
              ),
            )
            .toList();

      case OnboardingStep.sessionDuration:
        return [30, 45, 60, 75, 90]
            .map(
              (minutes) => _buildChoiceItem(
                title: "Tối đa $minutes phút",
                subtitle: _durationExplanation(minutes),
                selected: draft.sessionDurationMinutes == minutes,
                onTap: () => notifier.selectSessionDuration(minutes),
              ),
            )
            .toList();

      case OnboardingStep.restBehavior:
        return options.restDayModes
            .map(
              (mode) => _buildChoiceItem(
                title: mode.labelVi(),
                subtitle: _restExplanation(mode),
                selected: draft.restDayMode == mode,
                onTap: () => notifier.selectRestDayMode(mode),
              ),
            )
            .toList();

      case OnboardingStep.review:
        return [
          _buildReviewCard(draft),
        ];
    }
  }

  Widget _buildChoiceItem({
    required String title,
    required String subtitle,
    required bool selected,
    bool isMultiSelect = false,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final customColors = context.customColors;
        final outlineColor = Theme.of(context).colorScheme.outline;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.energyOrange : outlineColor,
              width: 1,
            ),
            color: selected
                ? customColors.orangeLight
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w600,
                            color: customColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: customColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isMultiSelect)
                    Checkbox(
                      value: selected,
                      onChanged: (_) => onTap(),
                      activeColor: AppColors.energyOrange,
                      checkColor: Colors.white,
                      side: BorderSide(color: outlineColor),
                    )
                  else
                    Radio<bool>(
                      value: true,
                      groupValue: selected ? true : null,
                      onChanged: (_) => onTap(),
                      activeColor: AppColors.energyOrange,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(OnboardingDraft draft) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final customColors = context.customColors;

        return Card(
          color: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.outline, width: 1),
          ),
          elevation: 0,
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kế hoạch của bạn",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: customColors.primaryText,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Chương trình được chọn từ preset đã kiểm duyệt, không tạo bài ngẫu nhiên.",
                  style: TextStyle(color: customColors.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Divider(color: colors.outline),
                const SizedBox(height: 12),
                _buildReviewItem(
                    context, "Giới tính", draft.gender?.labelVi() ?? ""),
                _buildReviewItem(
                    context, "Tạng người", draft.bodyType?.labelVi() ?? ""),
                _buildReviewItem(
                    context, "Mục tiêu chính", draft.goal?.labelVi() ?? ""),
                _buildReviewItem(
                  context,
                  "Tất cả mục tiêu",
                  draft.goals.map((g) => g.labelVi()).join(", "),
                ),
                _buildReviewItem(
                    context, "Trình độ", draft.level?.labelVi() ?? ""),
                _buildReviewItem(
                    context, "Dụng cụ", draft.equipment?.labelVi() ?? ""),
                _buildReviewItem(
                  context,
                  "Ngày tập",
                  draft.trainingDays
                      .toList()
                      .map((d) => d.shortLabelVi())
                      .join(", "),
                ),
                _buildReviewItem(context, "Tần suất",
                    "${draft.trainingDays.length} buổi/tuần"),
                _buildReviewItem(
                  context,
                  "Mỗi buổi",
                  "Tối đa ${draft.sessionDurationMinutes ?? 0} phút",
                ),
                _buildReviewItem(context, "Thời gian chương trình",
                    "${draft.durationWeeks ?? 0} tuần"),
                _buildReviewItem(
                    context, "Ngày nghỉ", draft.restDayMode?.labelVi() ?? ""),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, String label, String value) {
    final customColors = context.customColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Text(
              label,
              style: TextStyle(
                color: customColors.mutedText,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: Text(
              value,
              style: TextStyle(
                color: customColors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canAdvance(OnboardingStep step, OnboardingDraft draft) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return draft.gender != null && draft.bodyType != null;
      case OnboardingStep.goal:
        return draft.goals.isNotEmpty;
      case OnboardingStep.level:
        return draft.level != null;
      case OnboardingStep.equipment:
        return draft.equipment != null;
      case OnboardingStep.trainingDays:
        return draft.trainingDays.isNotEmpty && draft.trainingDays.length <= 6;
      case OnboardingStep.sessionDuration:
        return draft.sessionDurationMinutes != null;
      case OnboardingStep.restBehavior:
        return draft.restDayMode != null;
      case OnboardingStep.review:
        return true;
    }
  }

  String _stepTitle(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return "Thông tin cá nhân";
      case OnboardingStep.goal:
        return "Bạn muốn đạt điều gì?";
      case OnboardingStep.level:
        return "Kinh nghiệm tập luyện";
      case OnboardingStep.equipment:
        return "Bạn có dụng cụ gì?";
      case OnboardingStep.trainingDays:
        return "Chọn ngày tập";
      case OnboardingStep.sessionDuration:
        return "Thời gian mỗi buổi";
      case OnboardingStep.restBehavior:
        return "Bạn muốn nghỉ thế nào?";
      case OnboardingStep.review:
        return "Xem lại kế hoạch";
    }
  }

  String _stepExplanation(OnboardingStep step, bool replacementMode) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return "Giới tính và tạng người giúp hệ thống cá nhân hóa lịch trình tập luyện.";
      case OnboardingStep.goal:
        return replacementMode
            ? "Lịch sử hoàn thành vẫn được giữ lại."
            : "Mục tiêu quyết định trọng tâm của chương trình (chọn tối đa 3).";
      case OnboardingStep.level:
        return "Chọn đúng mức để khối lượng tập không quá nhẹ hoặc quá sức.";
      case OnboardingStep.equipment:
        return "App chỉ phát những bài bạn có thể thực hiện với dụng cụ này.";
      case OnboardingStep.trainingDays:
        return "Chọn ngày bạn thực sự có thể duy trì.";
      case OnboardingStep.sessionDuration:
        return "Hệ thống điều chỉnh số bài theo thời gian bạn có.";
      case OnboardingStep.restBehavior:
        return "Ngày không tập chính có thể nghỉ hoàn toàn hoặc vận động nhẹ.";
      case OnboardingStep.review:
        return "Kiểm tra lịch trước khi app tạo các buổi tập offline.";
    }
  }

  String _bodyTypeExplanation(BodyType value) {
    switch (value) {
      case BodyType.ectomorph:
        return "Gầy, khó tăng cơ/tăng mỡ, trao đổi chất nhanh.";
      case BodyType.mesomorph:
        return "Cân đối, dễ phát triển cơ bắp và duy trì cân nặng.";
      case BodyType.endomorph:
        return "Dễ tích mỡ, khung xương to, trao đổi chất chậm.";
    }
  }

  String _goalExplanation(FitnessGoal value) {
    switch (value) {
      case FitnessGoal.muscleGain:
        return "Ưu tiên sức mạnh và phát triển nhóm cơ.";
      case FitnessGoal.fatLossConditioning:
        return "Kết hợp vận động toàn thân và sức bền.";
      case FitnessGoal.endurance:
        return "Tăng khả năng duy trì vận động lâu hơn.";
      case FitnessGoal.generalFitness:
        return "Cân bằng sức mạnh, vận động và thể lực nền.";
    }
  }

  String _levelExplanation(ExperienceLevel value) {
    return value == ExperienceLevel.beginner
        ? "Kỹ thuật cơ bản, khối lượng vừa phải."
        : "Khối lượng cao hơn và bài phối hợp đa dạng hơn.";
  }

  String _equipmentExplanation(EquipmentProfile value) {
    switch (value) {
      case EquipmentProfile.bodyweightOnly:
        return "Tập ở bất kỳ đâu, không cần thiết bị.";
      case EquipmentProfile.dumbbells:
        return "Chương trình xoay quanh tạ đơn và trọng lượng cơ thể.";
      case EquipmentProfile.resistanceBands:
        return "Phù hợp khi có dây kháng lực.";
      case EquipmentProfile.fullGym:
        return "Sử dụng máy, cáp, thanh đòn và ghế tập.";
    }
  }

  String _dayHint(WeekDay day) {
    return (day == WeekDay.saturday || day == WeekDay.sunday)
        ? "Cuối tuần"
        : "Ngày trong tuần";
  }

  String _durationExplanation(int minutes) {
    switch (minutes) {
      case 30:
        return "Khoảng 3–5 bài, tập trung vào phần cốt lõi.";
      case 45:
        return "Khoảng 5–7 bài, cân bằng bài chính và bổ trợ.";
      case 60:
        return "Khoảng 6–8 bài với thời gian nghỉ đầy đủ.";
      case 75:
        return "Buổi tập dài, thêm nhóm bài bổ trợ.";
      default:
        return "Khối lượng đầy đủ nhất từ preset đã kiểm duyệt.";
    }
  }

  String _restExplanation(RestDayMode value) {
    return value == RestDayMode.fullRest
        ? "Không xếp hoạt động tập luyện vào ngày nghỉ."
        : "Gợi ý vận động nhẹ và mobility vào ngày nghỉ.";
  }
}
