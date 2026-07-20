import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/feature/nutrition/food_catalog_section.dart';
import 'package:gym_app/feature/nutrition/nutrition_ui_state.dart';
import 'package:gym_app/ui/theme/theme.dart';

void main() {
  testWidgets('Excel Template Download Success and SnackBar Verification',
      (WidgetTester tester) async {
    // Mock path_provider method channel
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );

    // Create a mock/simple NutritionContent UI state
    final dummyState = NutritionContent(
      calorieLimit: 2000,
      caloriesEaten: 0,
      proteinEaten: 0,
      proteinLimit: 150,
      carbsEaten: 0,
      carbsLimit: 250,
      fatEaten: 0,
      fatLimit: 70,
      sweatActive: false,
      sweatExtraSets: 0,
      waterIntakeMl: 0,
      scanning: false,
    );

    // Dummy custom colors to satisfy the BuildContext extension lookups without loading Google Fonts
    final dummyCustomColors = GymCustomColors(
      orangeLight: Colors.orange,
      greenLight: Colors.green,
      checkedCardBorder: Colors.blue,
      recoveryBlue: Colors.blue,
      recoveryBlueBg: Colors.blue,
      primaryText: Colors.black,
      mutedText: Colors.grey,
      orangeAccent: Colors.orange,
      greenDark: Colors.green,
      navyLight: Colors.blue,
      errorRed: Colors.red,
      warningAmber: Colors.amber,
      navy10: Colors.blue,
      navy20: Colors.blue,
      orange10: Colors.orange,
      green10: Colors.green,
      cardShadow: Colors.black,
      divider: Colors.grey,
      shimmerBase: Colors.grey,
      shimmerHighlight: Colors.white,
    );

    // Clean up template file if it exists from a previous test run
    final templateFile = File('./thuc_pham_mau.xlsx');
    if (templateFile.existsSync()) {
      templateFile.deleteSync();
    }

    // Build the widget with ProviderScope and Custom Theme Extension
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            extensions: [dummyCustomColors],
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodCatalogSection(state: dummyState),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify template download button is visible
    final downloadButtonFinder = find.text('Tải file mẫu Excel');
    expect(downloadButtonFinder, findsOneWidget);

    // Tap template download button
    await tester.tap(downloadButtonFinder);

    // Run pending microtasks / async operations in the UI
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify success SnackBar is displayed
    expect(find.textContaining('Đã tải tệp mẫu thành công'), findsOneWidget);

    // Verify that the file was written to disk and has content
    expect(templateFile.existsSync(), isTrue);
    expect(templateFile.lengthSync(), greaterThan(0));

    // Cleanup
    if (templateFile.existsSync()) {
      templateFile.deleteSync();
    }
  });
}
