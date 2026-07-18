import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'home_ui_state.dart';
import 'home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToWorkouts;
  final VoidCallback onNavigateToNutrition;
  final VoidCallback onNavigateToCheckIn;
  final VoidCallback onNavigateToRecommendations;
  final VoidCallback onNavigateToAchievements;
  final VoidCallback onNavigateToRoadmap;

  const HomeScreen({
    super.key,
    required this.onNavigateToWorkouts,
    required this.onNavigateToNutrition,
    required this.onNavigateToCheckIn,
    required this.onNavigateToRecommendations,
    required this.onNavigateToAchievements,
    required this.onNavigateToRoadmap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiStateAsync = ref.watch(homeUiStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBg
          : AppColors.white,
      body: uiStateAsync.when(
        data: (state) => _buildContent(context, state),
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.energyOrange),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("⚠️", style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  "Đã xảy ra lỗi khi tải dữ liệu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.customColors.primaryText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: context.customColors.mutedText,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeUiState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state.epochDay),
            const SizedBox(height: 18),

            // Daily Motivation Quote
            if (state.dailyQuote.isNotEmpty) ...[
              _buildMotivationCard(context, state.dailyQuote),
              const SizedBox(height: 18),
            ],

            _buildWorkoutHero(context, state),
            const SizedBox(height: 18),

            _buildStatusRow(context, state),
            const SizedBox(height: 24),

            Text(
              "TIẾP THEO CHO BẠN",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            _buildDashboardActionCard(
              context: context,
              eyebrow: "LỘ TRÌNH CHƯƠNG TRÌNH",
              title: "Lộ trình tập luyện",
              supporting: "Xem tổng quan các buổi tập và tiến trình của bạn",
              accent: AppColors.navy,
              onTap: onNavigateToRoadmap,
            ),
            _buildDashboardActionCard(
              context: context,
              eyebrow: "DINH DƯỠNG HÔM NAY",
              title: _nutritionTitle(state),
              supporting: _nutritionSupporting(state),
              accent: AppColors.successGreen,
              onTap: onNavigateToNutrition,
            ),
            _buildDashboardActionCard(
              context: context,
              eyebrow: "PHẢN HỒI HẰNG TUẦN",
              title: "Check-in cơ thể",
              supporting: "Ghi cân nặng, năng lượng và khả năng phục hồi",
              accent: AppColors.navy,
              onTap: onNavigateToCheckIn,
            ),
            _buildDashboardActionCard(
              context: context,
              eyebrow: "CÁ NHÂN HÓA",
              title: "Đề xuất dành cho bạn",
              supporting:
                  "Xem điều chỉnh dựa trên lịch sử và check-in gần nhất",
              accent: AppColors.energyOrange,
              onTap: onNavigateToRecommendations,
            ),
            _buildDashboardActionCard(
              context: context,
              eyebrow: "THÀNH TỰU",
              title: "Huy hiệu của bạn 🏆",
              supporting: "Xem các thành tựu đã mở khóa và thử thách mới",
              accent: const Color(0xFFEAB308),
              onTap: onNavigateToAchievements,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int epochDay) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(epochDay * 24 * 60 * 60 * 1000);

    final weekdays = {
      DateTime.monday: 'thứ hai',
      DateTime.tuesday: 'thứ ba',
      DateTime.wednesday: 'thứ tư',
      DateTime.thursday: 'thứ năm',
      DateTime.friday: 'thứ sáu',
      DateTime.saturday: 'thứ bảy',
      DateTime.sunday: 'chủ nhật',
    };
    final weekday = weekdays[date.weekday] ?? '';
    String formattedDate = "$weekday, ${date.day} tháng ${date.month}";
    if (formattedDate.isNotEmpty) {
      formattedDate =
          formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            "S",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SMARTGYM",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotivationCard(BuildContext context, String quote) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("✨", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              const Text(
                "ĐỘNG LỰC HẰNG NGÀY",
                style: TextStyle(
                  color: AppColors.energyOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text("✨", style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "“$quote”",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHero(BuildContext context, HomeUiState state) {
    final hasWorkout = state.workoutTitle != null;
    final progress = state.totalExercises > 0
        ? state.completedExercises / state.totalExercises
        : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BUỔI TẬP HÔM NAY",
            style: TextStyle(
              color: AppColors.energyOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.workoutTitle ?? "Chưa có buổi tập hiện tại",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (hasWorkout) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (state.workoutFocus != null) state.workoutFocus,
                if (state.durationMinutes != null)
                  "${state.durationMinutes} phút"
              ].join("  •  "),
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tiến độ bài tập",
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                ),
                Text(
                  "${state.completedExercises}/${state.totalExercises}",
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFF243047),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              "Kế hoạch sẽ xuất hiện khi có buổi tập đang hoạt động.",
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: hasWorkout ? onNavigateToWorkouts : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energyOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF334155),
                disabledForegroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                state.completedExercises > 0
                    ? "TIẾP TỤC BUỔI TẬP"
                    : "BẮT ĐẦU BUỔI TẬP",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, HomeUiState state) {
    final nutritionPct = state.caloriesTarget != null
        ? "${((state.caloriesConsumed * 100) / state.caloriesTarget!.clamp(1, 999999)).round().clamp(0, 999)}%"
        : "—";

    return Row(
      children: [
        Expanded(
          child: _buildStatusMetric(
            context: context,
            value: state.completedThisWeek.toString(),
            label: "Buổi tuần này",
            accent: AppColors.navy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatusMetric(
            context: context,
            value: state.streakDays.toString(),
            label: "Ngày liên tiếp",
            accent: AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatusMetric(
            context: context,
            value: nutritionPct,
            label: "Dinh dưỡng",
            accent: AppColors.energyOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMetric({
    required BuildContext context,
    required String value,
    required String label,
    required Color accent,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardActionCard({
    required BuildContext context,
    required String eyebrow,
    required String title,
    required String supporting,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        eyebrow,
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supporting,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "›",
                  style: TextStyle(
                    color: accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _nutritionTitle(HomeUiState state) {
    if (state.caloriesTarget != null) {
      return "${state.caloriesConsumed} / ${state.caloriesTarget} kcal";
    }
    return "${state.caloriesConsumed} kcal đã ghi";
  }

  String _nutritionSupporting(HomeUiState state) {
    if (state.caloriesTarget == null) {
      return "Chưa có mục tiêu calories — hoàn thiện hồ sơ để cá nhân hóa";
    }
    return "Mở nhật ký để cập nhật bữa ăn hôm nay";
  }
}
