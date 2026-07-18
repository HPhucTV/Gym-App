import 'package:flutter/material.dart';
import 'nutrition_ui_state.dart';

class NutritionCartSection extends StatelessWidget {
  final NutritionContent state;
  final VoidCallback onClearCart;
  final void Function(int, String) onRemoveFromCart; // foodCatalogId, mealTime
  final VoidCallback onConfirmEatCart;

  const NutritionCartSection({
    super.key,
    required this.state,
    required this.onClearCart,
    required this.onRemoveFromCart,
    required this.onConfirmEatCart,
  });

  @override
  Widget build(BuildContext context) {
    if (state.cart.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Giỏ món ăn (${state.cart.size} món) 🛒",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                TextButton(
                  onPressed: onClearCart,
                  child: const Text(
                    "Xóa giỏ",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...state.cart.map((cartItem) {
              final mealNameVi = () {
                switch (cartItem.mealTime.toUpperCase()) {
                  case "BREAKFAST":
                    return "Sáng";
                  case "LUNCH":
                    return "Trưa";
                  case "DINNER":
                    return "Tối";
                  default:
                    return "Phụ";
                }
              }();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.food.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            "Bữa: $mealNameVi  •  ${cartItem.grams.toInt()}g",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          onRemoveFromCart(cartItem.food.id, cartItem.mealTime),
                      icon: const Icon(Icons.delete_outline, size: 20),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onConfirmEatCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              child: const Text(
                "Xác nhận đã ăn ✔️",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension SizeExtension on List {
  int get size => length;
}
