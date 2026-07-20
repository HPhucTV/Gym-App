import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'nutrition_ui_state.dart';

class LoggedMealsSection extends StatelessWidget {
  final NutritionContent state;
  final VoidCallback onCopyYesterdayMeals;
  final ValueChanged<int>
      onDeleteLoggedFood; // In Dart ID is int, Kotlin was Long

  const LoggedMealsSection({
    super.key,
    required this.state,
    required this.onCopyYesterdayMeals,
    required this.onDeleteLoggedFood,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Bữa ăn hôm nay 🍽️",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: customColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (state.loggedFoods.isNotEmpty) ...[
          _buildTotalSummaryCard(context),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          onPressed: onCopyYesterdayMeals,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            side: const BorderSide(color: Color(0xFFF97316)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "🕒 Sao chép tất cả bữa ăn từ hôm qua",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (state.loggedFoods.isEmpty)
          Card(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Chưa ghi nhận món ăn nào hôm nay.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          _buildGroupedMealsList(context),
      ],
    );
  }

  Widget _buildTotalSummaryCard(BuildContext context) {
    final totalCal =
        state.loggedFoods.fold(0, (sum, item) => sum + item.calories);
    final totalP =
        state.loggedFoods.fold(0, (sum, item) => sum + item.proteinGrams);
    final totalC =
        state.loggedFoods.fold(0, (sum, item) => sum + item.carbsGrams);
    final totalF =
        state.loggedFoods.fold(0, (sum, item) => sum + item.fatGrams);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Card(
      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : AppColors.surfaceGray.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tổng dinh dưỡng đã nạp:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: customColors.primaryText,
                  ),
                ),
                Text(
                  "$totalCal kcal",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "P: ${totalP}g   •   C: ${totalC}g   •   F: ${totalF}g",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedMealsList(BuildContext context) {
    const mealNames = {
      "BREAKFAST": "Bữa sáng 🍳",
      "LUNCH": "Bữa trưa ☀️",
      "DINNER": "Bữa tối 🌙",
      "SNACK": "Bữa phụ 🍎",
    };
    const mealTimes = ["BREAKFAST", "LUNCH", "DINNER", "SNACK"];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    return Column(
      children: mealTimes.map((time) {
        final foodsInMeal = state.loggedFoods
            .where((e) => e.mealTime.toUpperCase() == time)
            .toList();
        if (foodsInMeal.isEmpty) return const SizedBox.shrink();

        final totalCal =
            foodsInMeal.fold(0, (sum, item) => sum + item.calories);
        final totalP =
            foodsInMeal.fold(0, (sum, item) => sum + item.proteinGrams);
        final totalC =
            foodsInMeal.fold(0, (sum, item) => sum + item.carbsGrams);
        final totalF = foodsInMeal.fold(0, (sum, item) => sum + item.fatGrams);

        return Card(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceGray,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mealNames[time] ?? time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: customColors.primaryText,
                      ),
                    ),
                    Text(
                      "$totalCal kcal  |  P: ${totalP}g  C: ${totalC}g  F: ${totalF}g",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...foodsInMeal.map((logged) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                logged.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: customColors.primaryText,
                                ),
                              ),
                              Text(
                                "${logged.grams.toInt()}g  •  ${logged.calories} kcal  |  P: ${logged.proteinGrams}g  C: ${logged.carbsGrams}g  F: ${logged.fatGrams}g",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => onDeleteLoggedFood(logged.id),
                          icon: const Text("❌", style: TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
