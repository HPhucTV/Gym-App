import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/model/goal_models.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'settings_ui_state.dart';
import 'settings_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToCheckIn;
  final VoidCallback onNavigateToRecommendations;
  final VoidCallback onGoToOnboardingReplacment;
  final VoidCallback onGoToOnboardingNew;
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    required this.onNavigateToProfile,
    required this.onNavigateToCheckIn,
    required this.onNavigateToRecommendations,
    required this.onGoToOnboardingReplacment,
    required this.onGoToOnboardingNew,
    this.onBack,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(settingsNotifierProvider);

    // Listen to events from SettingsEventProvider
    ref.listen(settingsEventProvider, (previous, next) {
      final event = next.value;
      if (event == null) return;

      if (event is SettingsEventRequestNotificationPermission) {
        debugPrint("Yêu cầu quyền thông báo");
      } else if (event is SettingsEventGoToOnboarding) {
        if (event.replacing) {
          widget.onGoToOnboardingReplacment();
        } else {
          widget.onGoToOnboardingNew();
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBg
          : AppColors.white,
      body: SafeArea(
        child: uiState is SettingsUiStateLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
                ),
              )
            : uiState is SettingsUiStateError
                ? _buildError(uiState.message)
                : _buildContent(uiState as SettingsUiStateContent),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onGoToOnboardingNew();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energyOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Tạo mục tiêu mới"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SettingsUiStateContent state) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button if applicable
                if (widget.onBack != null) ...[
                  GestureDetector(
                    onTap: widget.onBack,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "← Quay lại",
                        style: TextStyle(
                          color: AppColors.energyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Screen title
                Text(
                  "Cài đặt",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: customColors.primaryText,
                      ),
                ),
                const SizedBox(height: 16),

                // Goal overview Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _goalLabelVi(state.goal.goal),
                        style: TextStyle(
                          color: customColors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${_levelLabelVi(state.goal.level)} • ${_equipmentLabelVi(state.goal.equipment)}",
                        style: TextStyle(
                            color: customColors.mutedText, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${state.goal.sessionsPerWeek} buổi/tuần • ${state.goal.durationWeeks} tuần",
                        style: TextStyle(
                            color: customColors.mutedText, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reschedule button (if currentDueEpochDay exists)
                if (state.currentDueEpochDay != null &&
                    state.currentSessionId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: state.saving
                          ? null
                          : () => _showRescheduleDatePicker(
                              state.currentSessionId!,
                              state.currentDueEpochDay!),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.energyOrange),
                        foregroundColor: AppColors.energyOrange,
                      ),
                      child: const Text("Điều chỉnh lịch sắp tới",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Rest Day configuration
                Text(
                  "Ngày nghỉ",
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: RestDayMode.values.map((mode) {
                    final label = mode == RestDayMode.fullRest
                        ? "Nghỉ hoàn toàn"
                        : "Phục hồi nhẹ";
                    return Material(
                      type: MaterialType.transparency,
                      child: RadioListTile<RestDayMode>(
                        value: mode,
                        groupValue: state.effectiveRestDayMode,
                        title: Text(label,
                            style: TextStyle(color: customColors.primaryText)),
                        activeColor: AppColors.energyOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: state.saving
                            ? null
                            : (val) {
                                if (val != null)
                                  ref
                                      .read(settingsNotifierProvider.notifier)
                                      .setRestDayMode(val);
                              },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Notifications reminder switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nhắc tập luyện",
                          style: TextStyle(
                            color: customColors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: state.saving
                              ? null
                              : () => _showReminderTimePicker(
                                  state.reminderHour, state.reminderMinute),
                          child: Text(
                            "${state.reminderHour.toString().padLeft(2, '0')}:${state.reminderMinute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: AppColors.energyOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                    Switch(
                      value: state.reminderEnabled,
                      activeThumbColor: AppColors.energyOrange,
                      onChanged: state.saving
                          ? null
                          : (val) {
                              ref
                                  .read(settingsNotifierProvider.notifier)
                                  .setReminderEnabled(val);
                            },
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Onboarding Replacement
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: state.saving
                        ? null
                        : () => ref
                            .read(settingsNotifierProvider.notifier)
                            .requestReplaceGoal(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.energyOrange),
                      foregroundColor: AppColors.energyOrange,
                    ),
                    child: const Text("Đổi mục tiêu",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // Personalization hub
                Text(
                  "Cá nhân hóa",
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outline, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: widget.onNavigateToProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.energyOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("HỒ SƠ CÁ NHÂN",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: widget.onNavigateToCheckIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.energyOrange,
                            side:
                                const BorderSide(color: AppColors.energyOrange),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("CHECK-IN TUẦN",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: widget.onNavigateToRecommendations,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.energyOrange,
                            side:
                                const BorderSide(color: AppColors.energyOrange),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("ĐỀ XUẤT THÍCH NGHI",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Theme mode settings
                Text(
                  "Giao diện",
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outline, width: 1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      _buildThemeOption(context, "Theo hệ thống", null,
                          state.darkModeEnabled, state.saving),
                      _buildThemeOption(context, "Chế độ sáng", false,
                          state.darkModeEnabled, state.saving),
                      _buildThemeOption(context, "Chế độ tối", true,
                          state.darkModeEnabled, state.saving),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Delete active goal button
                Center(
                  child: TextButton(
                    onPressed: state.saving
                        ? null
                        : () => ref
                            .read(settingsNotifierProvider.notifier)
                            .requestDeleteGoal(),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                    ),
                    child: const Text("Xóa mục tiêu hiện tại",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

                // Messaging or Error notifications
                if (state.message != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      state.message!,
                      style: TextStyle(
                          color: colors.error, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Confirm goal replace/delete popup dialog
        if (state.confirmation != PendingConfirmation.none)
          _buildGoalActionConfirmationDialog(state),

        // Schedule change preview dialog
        if (state.schedulePreview != null)
          _buildScheduleChangePreviewDialog(state),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    bool? value,
    bool? currentValue,
    bool saving,
  ) {
    final customColors = context.customColors;
    return Material(
      type: MaterialType.transparency,
      child: RadioListTile<bool?>(
        value: value,
        groupValue: currentValue,
        title: Text(label,
            style: TextStyle(color: customColors.primaryText, fontSize: 14)),
        activeColor: AppColors.energyOrange,
        contentPadding: EdgeInsets.zero,
        onChanged: saving
            ? null
            : (val) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setDarkModeEnabled(val);
              },
      ),
    );
  }

  void _showReminderTimePicker(int currentHour, int currentMinute) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.energyOrange,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      ref
          .read(settingsNotifierProvider.notifier)
          .setReminderTime(pickedTime.hour, pickedTime.minute);
    }
  }

  void _showRescheduleDatePicker(int sessionId, int dueEpochDay) async {
    final initialDate = DateTime.fromMillisecondsSinceEpoch(
        dueEpochDay * 24 * 60 * 60 * 1000,
        isUtc: true);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.energyOrange,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final selectedEpochDay =
          pickedDate.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
      ref
          .read(settingsNotifierProvider.notifier)
          .previewScheduleChange(sessionId, selectedEpochDay);
    }
  }

  Widget _buildGoalActionConfirmationDialog(SettingsUiStateContent state) {
    final deleting = state.confirmation == PendingConfirmation.delete;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: AlertDialog(
        title: Text(deleting ? "Xóa mục tiêu" : "Đổi mục tiêu",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Lịch sử buổi tập đã hoàn thành vẫn được giữ lại."),
        actions: [
          TextButton(
            onPressed: state.saving
                ? null
                : () => ref
                    .read(settingsNotifierProvider.notifier)
                    .cancelConfirmation(),
            child: Text("Hủy", style: TextStyle(color: isDark ? AppColors.darkText : AppColors.navy)),
          ),
          TextButton(
            onPressed: state.saving
                ? null
                : () => ref
                    .read(settingsNotifierProvider.notifier)
                    .confirmGoalAction(),
            child: Text(
              "Xác nhận",
              style: TextStyle(
                color: deleting ? Colors.red : AppColors.energyOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleChangePreviewDialog(SettingsUiStateContent state) {
    final preview = state.schedulePreview!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String formatEpoch(int day) {
      final d = DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000,
          isUtc: true);
      return DateFormat("dd/MM/yyyy").format(d);
    }

    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: AlertDialog(
        title: const Text("Xác nhận lịch tập mới",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...preview.changes.map((change) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "${formatEpoch(change.oldEpochDay)} → ${formatEpoch(change.newEpochDay)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              if (preview.warningsVi.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...preview.warningsVi.map((warning) {
                  return Text(
                    warning,
                    style: TextStyle(
                        color: colors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  );
                })
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.saving
                ? null
                : () => ref
                    .read(settingsNotifierProvider.notifier)
                    .cancelSchedulePreview(),
            child: Text("Hủy", style: TextStyle(color: isDark ? AppColors.darkText : AppColors.navy)),
          ),
          TextButton(
            onPressed: state.saving
                ? null
                : () => ref
                    .read(settingsNotifierProvider.notifier)
                    .confirmScheduleChange(),
            child: const Text(
              "Xác nhận",
              style: TextStyle(
                  color: AppColors.energyOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabelVi(FitnessGoal value) {
    switch (value) {
      case FitnessGoal.generalFitness:
        return "Thể lực tổng quát";
      case FitnessGoal.muscleGain:
        return "Tăng cơ";
      case FitnessGoal.fatLossConditioning:
        return "Giảm mỡ & thể lực";
      case FitnessGoal.endurance:
        return "Sức bền";
    }
  }

  String _levelLabelVi(ExperienceLevel value) {
    return value == ExperienceLevel.beginner ? "Mới bắt đầu" : "Trung cấp";
  }

  String _equipmentLabelVi(EquipmentProfile value) {
    switch (value) {
      case EquipmentProfile.bodyweightOnly:
        return "Không dụng cụ";
      case EquipmentProfile.dumbbells:
        return "Tạ đơn";
      case EquipmentProfile.resistanceBands:
        return "Dây kháng lực";
      case EquipmentProfile.fullGym:
        return "Phòng gym đầy đủ";
    }
  }
}
