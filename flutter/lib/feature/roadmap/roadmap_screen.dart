import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'roadmap_ui_state.dart';
import 'roadmap_view_model.dart';

class RoadmapScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const RoadmapScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roadmapUiStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      appBar: AppBar(
        title: Text(
          "Lộ trình bài tập",
          style: TextStyle(
            color: customColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          key: const ValueKey("roadmap-back-button"),
          icon: const Icon(Icons.arrow_back),
          color: customColors.primaryText,
          onPressed: onBack,
        ),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is RoadmapLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      key: ValueKey("roadmap-loading"),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
                    ),
                  ),
                )
              else if (state is RoadmapError)
                Expanded(
                  child: Center(
                    child: Padding(
                      key: const ValueKey("roadmap-error"),
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else if (state is RoadmapSuccess) ...[
                // Program name header card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chương trình tập luyện",
                        style: TextStyle(
                          color: AppColors.energyOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.programName,
                        style: TextStyle(
                          color: customColors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sessions Timeline list
                Expanded(
                  child: ListView.builder(
                    key: const ValueKey("roadmap-list"),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: state.sessions.length,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final isLast = index == state.sessions.length - 1;
                      return _buildRoadmapItem(
                          context, session, isLast, customColors, isDark);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapItem(
    BuildContext context,
    RoadmapSessionUi session,
    bool isLast,
    GymCustomColors customColors,
    bool isDark,
  ) {
    final isCompleted = session.status == RoadmapSessionStatus.completed;
    final isActive = session.status == RoadmapSessionStatus.active;
    final isLocked = session.status == RoadmapSessionStatus.locked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Node Circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.successGreen
                        : isActive
                            ? (isDark ? AppColors.darkBg : AppColors.white)
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.surfaceGray),
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: AppColors.energyOrange, width: 3)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Text(
                          "✓",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : isActive
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.energyOrange,
                                shape: BoxShape.circle,
                              ),
                            )
                          : const Text(
                              "🔒",
                              style: TextStyle(fontSize: 10),
                            ),
                ),
                // Line linking nodes
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.successGreen.withValues(alpha: 0.5)
                          : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceGray),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Details Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceGray)
                      : (isDark ? AppColors.darkSurface : AppColors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(
                          color: AppColors.energyOrange.withValues(alpha: 0.5),
                          width: 1)
                      : Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.borderGray,
                          width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tuần ${session.week} - Buổi ${session.sessionInWeek}",
                          style: TextStyle(
                            color: isLocked
                                ? customColors.mutedText
                                : AppColors.energyOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.energyOrange
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Đang tập",
                              style: TextStyle(
                                color: AppColors.energyOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.titleVi,
                      style: TextStyle(
                        color: isLocked
                            ? customColors.mutedText
                            : customColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Trọng tâm: ${session.focusVi}",
                      style: TextStyle(
                        color: customColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Thời lượng: ~${session.estimatedMinutes} phút",
                      style: TextStyle(
                        color: customColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
