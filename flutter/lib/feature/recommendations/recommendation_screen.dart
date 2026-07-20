import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/adaptation_models.dart';
import '../../data/local/database.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'recommendation_ui_state.dart';
import 'recommendation_view_model.dart';

class RecommendationScreen extends ConsumerWidget {
  final VoidCallback onBack;

  const RecommendationScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationNotifierProvider);
    final customColors = context.customColors;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBg
          : AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Đề xuất thích nghi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: customColors.primaryText,
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, RecommendationUiState state) {
    if (state is RecommendationUiStateLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
        ),
      );
    }

    final successState = state as RecommendationUiStateSuccess;
    if (successState.decisions.isEmpty) {
      return const EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: successState.decisions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final uiDecision = successState.decisions[index];
        return DecisionCard(uiDecision: uiDecision);
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("✅", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            "Chưa có đề xuất thích nghi nào",
            style: TextStyle(
              color: customColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy hoàn thành tập luyện và check-in tuần để hệ thống phân tích và đưa ra đề xuất tối ưu.",
            style: TextStyle(
                color: customColors.mutedText, fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DecisionCard extends ConsumerWidget {
  final UiDecision uiDecision;

  const DecisionCard({
    super.key,
    required this.uiDecision,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = uiDecision.entity;
    final customColors = context.customColors;

    final statusColor = switch (entity.status) {
      AdaptationStatus.applied => AppColors.successGreen,
      AdaptationStatus.rejected => Colors.grey,
      AdaptationStatus.undone => customColors.mutedText,
      AdaptationStatus.proposed => AppColors.energyOrange,
    };

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.surfaceGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Kind & Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _translateKind(entity.kind),
                          style: TextStyle(
                            color: customColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: AppColors.energyOrange, size: 20),
                        onPressed: () =>
                            _showExplanationDialog(context, uiDecision),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    _buildBadge(
                      context: context,
                      label: entity.mode == AdaptationMode.autoApply
                          ? "Tự động"
                          : "Cần xác nhận",
                      bgColor: entity.mode == AdaptationMode.autoApply
                          ? AppColors.successGreen.withValues(alpha: 0.15)
                          : AppColors.energyOrange.withValues(alpha: 0.15),
                      textColor: entity.mode == AdaptationMode.autoApply
                          ? AppColors.successGreen
                          : AppColors.energyOrange,
                    ),
                    const SizedBox(width: 6),
                    _buildBadge(
                      context: context,
                      label: _translateStatus(entity.status),
                      bgColor: statusColor.withValues(alpha: 0.15),
                      textColor: statusColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Explanation / Reason
            if (uiDecision.isExplaining)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Đang tải giải thích từ Coach AI...",
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                ],
              )
            else
              Text(
                uiDecision.explanationText,
                style: TextStyle(
                    color: customColors.primaryText, fontSize: 14, height: 1.4),
              ),
            const SizedBox(height: 12),

            // Details/Before-After values
            _buildStateDetailsWidget(context, entity),

            // Action Buttons
            if (entity.status == AdaptationStatus.proposed) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(recommendationNotifierProvider.notifier)
                          .rejectDecision(entity.id),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: customColors.primaryText),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Từ chối",
                        style: TextStyle(
                            color: customColors.primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(recommendationNotifierProvider.notifier)
                          .acceptDecision(entity.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.energyOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Đồng ý",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else if (uiDecision.isUndoEligible) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref
                    .read(recommendationNotifierProvider.notifier)
                    .undoDecision(entity.kind),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.energyOrange),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  "HOÀN TÁC",
                  style: TextStyle(
                      color: AppColors.energyOrange,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStateDetailsWidget(
      BuildContext context, AdaptationDecisionData entity) {
    final customColors = context.customColors;
    final beforeText = _parseStateDetails(entity.beforeJson, entity.kind);
    final afterText = _parseStateDetails(entity.afterJson, entity.kind);

    if (beforeText.isEmpty || afterText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBg
            : AppColors.borderGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Trạng thái cũ",
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                beforeText,
                style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
          Icon(Icons.arrow_forward, color: customColors.primaryText, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Trạng thái mới",
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                afterText,
                style: const TextStyle(
                    color: AppColors.energyOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _translateKind(AdaptationKind kind) {
    switch (kind) {
      case AdaptationKind.calorieTarget:
        return "Mục tiêu Calorie";
      case AdaptationKind.macroTarget:
        return "Mục tiêu dinh dưỡng (Macros)";
      case AdaptationKind.recoveryDay:
        return "Đề xuất phục hồi";
      case AdaptationKind.workoutVolume:
        return "Khối lượng tập luyện";
      case AdaptationKind.programChange:
        return "Đổi chương trình tập";
      case AdaptationKind.deloadWeek:
        return "Tuần giảm tải";
    }
  }

  String _translateStatus(AdaptationStatus status) {
    switch (status) {
      case AdaptationStatus.proposed:
        return "Đề xuất mới";
      case AdaptationStatus.applied:
        return "Đã áp dụng";
      case AdaptationStatus.rejected:
        return "Đã từ chối";
      case AdaptationStatus.undone:
        return "Đã hoàn tác";
    }
  }

  String _parseStateDetails(String json, AdaptationKind kind) {
    switch (kind) {
      case AdaptationKind.calorieTarget:
        final match = RegExp(r'"calories":(\d+)').firstMatch(json);
        return match != null ? "${match.group(1)} kcal" : "";
      case AdaptationKind.workoutVolume:
        final match = RegExp(r'"scheduledSessions":(\d+)').firstMatch(json);
        return match != null ? "${match.group(1)} buổi/tuần" : "";
      case AdaptationKind.deloadWeek:
        final match = RegExp(r'"volumeScalePercent":(\d+)').firstMatch(json);
        return match != null ? "${match.group(1)}% khối lượng" : "";
      default:
        return "";
    }
  }

  void _showExplanationDialog(BuildContext context, UiDecision uiDecision) {
    final entity = uiDecision.entity;
    final customColors = context.customColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Chi tiết Đề xuất Thích nghi",
          style: TextStyle(
              color: customColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info badges
              Row(
                children: [
                  _buildBadge(
                    context: context,
                    label: _translateKind(entity.kind),
                    bgColor: AppColors.energyOrange.withValues(alpha: 0.15),
                    textColor: AppColors.energyOrange,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    context: context,
                    label: entity.mode == AdaptationMode.autoApply
                        ? "Tự động"
                        : "Cần đồng ý",
                    bgColor: customColors.primaryText.withValues(alpha: 0.1),
                    textColor: customColors.primaryText,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Reasoning
              Text(
                "Lý do thích nghi (Hệ thống):",
                style: TextStyle(
                    color: customColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                entity.reasonVi,
                style: TextStyle(
                    color: customColors.primaryText, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),

              if (uiDecision.explanationText != entity.reasonVi) ...[
                Text(
                  "Giải thích chi tiết (Coach AI):",
                  style: const TextStyle(
                      color: AppColors.energyOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  uiDecision.explanationText,
                  style: TextStyle(
                      color: customColors.primaryText,
                      fontSize: 13,
                      height: 1.4),
                ),
              ] else if (uiDecision.isExplaining) ...[
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.energyOrange),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đang phân tích từ Coach AI...",
                      style:
                          TextStyle(color: AppColors.mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Đóng",
              style: TextStyle(
                  color: AppColors.energyOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
