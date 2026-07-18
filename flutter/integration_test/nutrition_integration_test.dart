import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late GymDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = GymDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> performOnboarding(WidgetTester tester) async {
    // Select Gender: Nam
    await tester.tap(find.text('Nam'));
    await tester.pumpAndSettle();

    // Select Body Type: Ectomorph
    await tester.tap(find.text('Ectomorph'));
    await tester.pumpAndSettle();

    // Tap "Tiếp tục"
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 2/8: Goal
    await tester.tap(find.text('Tăng cơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 3/8: Level
    await tester.tap(find.text('Trung cấp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 4/8: Equipment
    await tester.tap(find.text('Phòng gym đầy đủ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 5/8: Training Days
    await tester.tap(find.text('Thứ Hai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thứ Tư'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thứ Sáu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 6/8: Duration
    await tester.tap(find.text('Tối đa 60 phút'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 7/8: Rest behavior
    await tester.tap(find.text('Nghỉ hoàn toàn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 8/8: Review
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo mục tiêu'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  testWidgets('Nutrition Logging and Water Tracking Integration Test',
      (WidgetTester tester) async {
    // Set viewport size so all list options are visible without scrolling
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch app and perform onboarding with database override
    app.main(overrides: [
      gymDatabaseProvider.overrideWithValue(database),
    ]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await performOnboarding(tester);

    // Navigate to Nutrition screen
    await tester.tap(find.text('🥗 Dinh dưỡng'));
    await tester.pumpAndSettle();

    // Verify Nutrition Screen is shown
    expect(find.text('Theo dõi Dinh dưỡng 🥗'), findsOneWidget);

    // Verify initial water intake is 0ml
    expect(find.textContaining('0 / 2000 ml'), findsOneWidget);

    // Add 250ml water
    await tester.tap(find.text('+250'));
    await tester.pumpAndSettle();

    // Verify updated water intake is 250ml
    expect(find.textContaining('250 / 2000 ml'), findsOneWidget);

    // Start manual food entry
    await tester.tap(find.text('Nhập tay'));
    await tester.pumpAndSettle();

    // Verify draft dialog is showing
    expect(find.text('Kiểm tra món ăn'), findsOneWidget);

    // Enter name
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Tên món').first, 'Cơm tấm sườn');
    await tester.pumpAndSettle();

    // Enter calories
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Calo').first, '650');
    await tester.pumpAndSettle();

    // Enter protein
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Đạm (g)').first, '24');
    await tester.pumpAndSettle();

    // Enter carbs
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Tinh bột (g)').first, '85');
    await tester.pumpAndSettle();

    // Enter fat
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Chất béo (g)').first, '18');
    await tester.pumpAndSettle();

    // Tap "Thêm"
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();

    // The draft dialog should be dismissed, and the item should be in the cart
    expect(find.text('Kiểm tra món ăn'), findsNothing);
    expect(find.textContaining('Giỏ món ăn'), findsOneWidget);
    expect(find.text('Cơm tấm sườn'), findsOneWidget);

    // Tap "Xác nhận đã ăn ✔️" to log the cart
    await tester.tap(find.text('Xác nhận đã ăn ✔️'));
    await tester.pumpAndSettle();

    // The cart should be cleared and the meal logged
    expect(find.textContaining('Giỏ món ăn'), findsNothing);
    expect(find.text('Cơm tấm sườn'),
        findsOneWidget); // should show in logged meals section
  });
}
