import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/model/goal_models.dart';
import '../../core/program/program_phase_planner.dart';
import '../../core/model/catalog_models.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'today_ui_state.dart';
import 'today_view_model.dart';
import 'widgets/exercise_card.dart';
import 'widgets/exercise_substitution_dialog.dart';
import 'widgets/workout_feedback_dialog.dart';
import 'widgets/achievement_unlock_dialog.dart';
import 'widgets/rest_timer_section.dart';
import '../../ui/components/confetti_celebration.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToCatalog;
  final VoidCallback onNavigateToNutrition;

  const TodayScreen({
    super.key,
    required this.onNavigateToCatalog,
    required this.onNavigateToNutrition,
  });

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  int _timerInitialSeconds = 0;
  bool _timerVisible = false;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(todayNotifierProvider);
    final celebration = ref.watch(celebrationProvider);
    final pendingFeedback = ref.watch(pendingFeedbackProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBg
          : AppColors.white,
      body: Stack(
        children: [
          // Main Content
          _buildMainContent(uiState),

          // Confetti / Celebration Layer
          if (celebration.showConfetti) ...[
            ConfettiCelebration(
              isActive: true,
              onFinished: () {
                if (celebration.unlockedAchievements.isEmpty) {
                  ref.read(todayNotifierProvider.notifier).dismissCelebration();
                }
              },
            ),
            if (celebration.unlockedAchievements.isEmpty)
              _buildSimpleCelebrationBanner(celebration)
            else
              _buildAchievementCelebrationDialog(celebration),
          ],

          // Feedback Dialogue
          if (pendingFeedback != null) _buildFeedbackDialog(pendingFeedback),
        ],
      ),
    );
  }

  Widget _buildMainContent(TodayUiState state) {
    switch (state) {
      case TodayUiStateLoading():
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
          ),
        );
      case TodayUiStateGoalComplete():
        return const GoalCompleteScreen();
      case TodayUiStateRecovery():
        return RecoveryScreen(
          state: state,
          onRefreshCoachTip: () =>
              ref.read(todayNotifierProvider.notifier).refreshCoachTip(),
        );
      case TodayUiStateError():
        return ErrorScreen(
          state: state,
          onRetry: () => ref.read(todayNotifierProvider.notifier).retry(),
        );
      case TodayUiStateWorkout():
        return _buildWorkoutContent(state);
    }
  }

  Widget _buildWorkoutContent(TodayUiStateWorkout state) {
    final customColors = context.customColors;
    final colors = Theme.of(context).colorScheme;

    final musclesInWorkout =
        state.rows.map((r) => r.primaryMuscleGroup).toSet().toList();

    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 140.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _TodayHeaderCard(
                    state: state,
                    onNavigateToCatalog: widget.onNavigateToCatalog,
                    onNavigateToNutrition: widget.onNavigateToNutrition,
                  ),
                  const SizedBox(height: 18),

                  // Time Budget Choices
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thời lượng buổi tập",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: customColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: state.timeBudgetChoices.map((minutes) {
                          final isSelected =
                              state.selectedTimeBudgetMinutes == minutes;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              child: ChoiceChip(
                                label: Text(
                                  minutes != null ? "$minutes phút" : "Đầy đủ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: state.canChangeTimeBudget
                                    ? (_) => ref
                                        .read(todayNotifierProvider.notifier)
                                        .applyTimeBudget(minutes)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (state.omittedExerciseCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${state.omittedExerciseCount} bài phụ được lược bớt",
                          style: TextStyle(
                            color: customColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Sore Muscles Toggles
                  if (musclesInWorkout.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hôm nay bạn mỏi nhóm cơ nào? (Tập nhẹ giảm 50% hiệp 💡)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: customColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: musclesInWorkout.map((muscle) {
                            final isSelected =
                                state.soreMuscles.contains(muscle.name);
                            return FilterChip(
                              selected: isSelected,
                              label: Text(
                                _muscleLabelVi(muscle),
                                style: const TextStyle(fontSize: 12),
                              ),
                              onSelected: (_) => ref
                                  .read(todayNotifierProvider.notifier)
                                  .toggleSoreMuscle(muscle.name),
                              selectedColor: AppColors.energyOrange
                                  .withValues(alpha: 0.15),
                              checkmarkColor: AppColors.energyOrange,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.energyOrange
                                    : customColors.primaryText,
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Warmup Card
                  if (state.warmUp != null) ...[
                    AdvisoryMovementBlockCard(
                        sectionLabel: "Khởi động", block: state.warmUp!),
                    const SizedBox(height: 14),
                  ],

                  // AI Coach Tip
                  if (state.coachTip != null) ...[
                    AICoachTipCard(
                      tip: state.coachTip,
                      isRefreshing: state.isRefreshingCoach,
                      onRefresh: () => ref
                          .read(todayNotifierProvider.notifier)
                          .refreshCoachTip(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Exercises list
                  ...state.rows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: ExerciseCard(
                        sessionId: state.sessionId,
                        row: row,
                        enabled: !state.isCompleting &&
                            !state.pendingOrderIndices.contains(row.orderIndex),
                        onCheckedChange: (checked) {
                          ref
                              .read(todayNotifierProvider.notifier)
                              .setChecked(row.orderIndex, checked);
                          if (checked && row.restSeconds > 0) {
                            setState(() {
                              _timerInitialSeconds = row.restSeconds;
                              _timerVisible = true;
                            });
                          }
                        },
                        onSubstitute: () => ref
                            .read(todayNotifierProvider.notifier)
                            .requestSubstitution(row.orderIndex),
                      ),
                    );
                  }),

                  // Cooldown Card
                  if (state.coolDown != null) ...[
                    const SizedBox(height: 14),
                    AdvisoryMovementBlockCard(
                        sectionLabel: "Thả lỏng", block: state.coolDown!),
                  ],

                  // Interaction errors
                  if (state.interactionError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.interactionError!,
                      style: TextStyle(
                          color: colors.error, fontWeight: FontWeight.bold),
                    ),
                  ],

                  // Complete Buutton Section
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _getCompleteStatusText(state),
                          style: TextStyle(
                            color: (state.total - state.checkedCount == 0)
                                ? AppColors.successGreen
                                : customColors.mutedText,
                            fontSize: 14,
                            fontWeight: (state.total - state.checkedCount == 0)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                (state.canComplete && !state.isCompleting)
                                    ? () => ref
                                        .read(todayNotifierProvider.notifier)
                                        .completeWorkout()
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.energyOrange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  colors.outline.withValues(alpha: 0.3),
                              disabledForegroundColor: customColors.mutedText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              state.isCompleting
                                  ? "Đang hoàn thành…"
                                  : "Hoàn thành buổi tập ✓",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        // Floating Rest Timer
        if (_timerVisible && _timerInitialSeconds > 0)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: RestTimerSection(
                initialSeconds: _timerInitialSeconds,
                onFinished: () {
                  setState(() {
                    _timerVisible = false;
                  });
                },
                onClose: () {
                  setState(() {
                    _timerVisible = false;
                  });
                },
              ),
            ),
          ),

        // Substitution Dialog Overlay
        if (state.substitution != null)
          _buildSubstitutionDialog(state.substitution!),
      ],
    );
  }

  String _getCompleteStatusText(TodayUiStateWorkout state) {
    final remaining = state.total - state.checkedCount;
    if (state.isCompleting) return "Đang lưu kết quả...";
    if (remaining == 0) return "Sẵn sàng hoàn thành! ✓";
    if (remaining == 1) return "Còn 1 bài nữa";
    return "Còn $remaining bài nữa";
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

  Widget _buildSubstitutionDialog(ExerciseSubstitutionUi substitution) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: ExerciseSubstitutionDialog(
          state: substitution,
          onApply: (replacementId) {
            ref
                .read(todayNotifierProvider.notifier)
                .applySubstitution(replacementId);
          },
          onDismiss: () =>
              ref.read(todayNotifierProvider.notifier).dismissSubstitution(),
        ),
      ),
    );
  }

  Widget _buildFeedbackDialog(PendingWorkoutFeedback feedback) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: WorkoutFeedbackDialog(
          feedback: feedback,
          onDifficultySelected: (difficulty) {
            ref
                .read(todayNotifierProvider.notifier)
                .submitDifficulty(difficulty);
          },
          onDismiss: () =>
              ref.read(todayNotifierProvider.notifier).dismissFeedback(),
        ),
      ),
    );
  }

  Widget _buildSimpleCelebrationBanner(CelebrationState celebration) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: SafeArea(
        child: Material(
          color: AppColors.successGreen,
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Tuyệt vời! Bạn đã hoàn thành buổi tập hôm nay! 💪🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        shareWorkoutSummary(
                          context: context,
                          workoutTitle: celebration.workoutTitle,
                          completed: celebration.completedExercises,
                          total: celebration.totalExercises,
                          achievements: const [],
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Chia sẻ 🔗",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(todayNotifierProvider.notifier)
                          .dismissCelebration(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Đóng",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCelebrationDialog(CelebrationState celebration) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: AchievementUnlockDialog(
          badges: celebration.unlockedAchievements,
          workoutTitle: celebration.workoutTitle,
          completedExercises: celebration.completedExercises,
          totalExercises: celebration.totalExercises,
          onDismiss: () =>
              ref.read(todayNotifierProvider.notifier).dismissCelebration(),
        ),
      ),
    );
  }
}

class GoalCompleteScreen extends StatelessWidget {
  const GoalCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🏆", style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              "Hoàn thành mục tiêu!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Bạn đã hoàn thành tất cả buổi tập trong chương trình. Tuyệt vời! 🎉",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: customColors.mutedText,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: customColors.greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Hãy vào Cài đặt để tạo mục tiêu mới!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: customColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final TodayUiStateError state;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("⚠️", style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              "Đã có lỗi",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: TextStyle(
                color: customColors.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.canRetry) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.energyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Thử lại"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class RecoveryScreen extends StatelessWidget {
  final TodayUiStateRecovery state;
  final VoidCallback onRefreshCoachTip;

  const RecoveryScreen({
    super.key,
    required this.state,
    required this.onRefreshCoachTip,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    final emoji = state.kind == RecoveryKind.fullRest ? "🧘" : "🚶";
    final title = state.kind == RecoveryKind.fullRest
        ? "Nghỉ ngơi hoàn toàn"
        : "Phục hồi nhẹ";
    final supporting = state.kind == RecoveryKind.fullRest
        ? "Hôm nay hãy nghỉ ngơi để cơ thể phục hồi."
        : "Bạn có thể đi bộ hoặc vận động nhẹ nhàng.";

    final date = DateTime.fromMillisecondsSinceEpoch(
        state.nextDueEpochDay * 24 * 60 * 60 * 1000);
    final dateStr = DateFormat("dd/MM/yyyy").format(date);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              supporting,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: customColors.mutedText,
                  ),
            ),
            const SizedBox(height: 24),

            // Next Workout Card
            Container(
              decoration: BoxDecoration(
                color: customColors.recoveryBlueBg,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text("📅", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buổi tập tiếp theo",
                        style: TextStyle(
                          color: customColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: customColors.recoveryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Coach Tip
            if (state.coachTip != null)
              AICoachTipCard(
                tip: state.coachTip,
                isRefreshing: state.isRefreshingCoach,
                onRefresh: onRefreshCoachTip,
              ),
          ],
        ),
      ),
    );
  }
}

class AICoachTipCard extends StatelessWidget {
  final String? tip;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const AICoachTipCard({
    super.key,
    required this.tip,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (tip == null || tip!.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("🤖", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    "Trợ lý AI Coach",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: customColors.primaryText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (isRefreshing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
                  ),
                )
              else
                GestureDetector(
                  onTap: onRefresh,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "Cập nhật 🔄",
                      style: TextStyle(
                        color: AppColors.energyOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip!,
            style: TextStyle(
              color: customColors.primaryText,
              fontSize: 14,
              height: 1.4,
            ),
          )
        ],
      ),
    );
  }
}

class AdvisoryMovementBlockCard extends StatefulWidget {
  final String sectionLabel;
  final AdvisoryMovementBlockUi block;

  const AdvisoryMovementBlockCard({
    super.key,
    required this.sectionLabel,
    required this.block,
  });

  @override
  State<AdvisoryMovementBlockCard> createState() =>
      _AdvisoryMovementBlockCardState();
}

class _AdvisoryMovementBlockCardState extends State<AdvisoryMovementBlockCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sectionLabel,
                            style: const TextStyle(
                              color: AppColors.energyOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.block.titleVi,
                            style: TextStyle(
                              color: customColors.primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${widget.block.estimatedMinutes} phút · Không tính vào tiến độ",
                            style: TextStyle(
                              color: customColors.mutedText,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      _expanded ? "▲" : "▼",
                      style: const TextStyle(
                        color: AppColors.energyOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            ...List.generate(widget.block.stepsVi.length,
                                (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "${index + 1}. ${widget.block.stepsVi[index]}",
                                  style: TextStyle(
                                    color: customColors.primaryText,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            })
                          ],
                        )
                      : const SizedBox.shrink(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayHeaderCard extends StatelessWidget {
  final TodayUiStateWorkout state;
  final VoidCallback onNavigateToCatalog;
  final VoidCallback onNavigateToNutrition;

  const _TodayHeaderCard({
    required this.state,
    required this.onNavigateToCatalog,
    required this.onNavigateToNutrition,
  });

  String _greetingText(int hour) {
    if (hour < 12) return "Chào buổi sáng! 🌅";
    if (hour < 18) return "Chào buổi chiều! ☀️";
    return "Chào buổi tối! 🌙";
  }

  String _phaseLabelVi(ProgramPhase phase) {
    switch (phase) {
      case ProgramPhase.foundation:
        return "Giai đoạn làm quen";
      case ProgramPhase.build:
        return "Giai đoạn phát triển";
      case ProgramPhase.consolidate:
        return "Giai đoạn củng cố";
      case ProgramPhase.deload:
        return "Giai đoạn giảm tải";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    final progress = state.total > 0 ? state.checkedCount / state.total : 0.0;
    final greeting = _greetingText(state.greetingHour);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: AppColors.energyOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onNavigateToCatalog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "📚 Tra cứu",
                          style: TextStyle(
                            color: AppColors.energyOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onNavigateToNutrition,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "🥗 Dinh dưỡng",
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  state.titleVi,
                  style: TextStyle(
                    color: customColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _phaseLabelVi(state.phase),
                  style: const TextStyle(
                    color: AppColors.energyOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${state.focusVi} · ${state.estimatedMinutes} phút",
                  style: TextStyle(
                    color: customColors.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${state.checkedCount}/${state.total} bài đã xong",
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Circular progress ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    color: colors.outline.withValues(alpha: 0.3),
                    strokeWidth: 8,
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    color: progress >= 1.0
                        ? AppColors.successGreen
                        : AppColors.energyOrange,
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: customColors.primaryText,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
