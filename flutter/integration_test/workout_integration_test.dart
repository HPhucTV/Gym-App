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

  testWidgets('Workout Completion and Feedback Integration Test',
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

    // Verify we are on Today Screen
    expect(find.text('HÔM NAY'), findsOneWidget);

    // Find all Checkboxes (which represent exercise sets)
    final checkboxFinder = find.byType(Checkbox);
    final count = checkboxFinder.evaluate().length;
    expect(count, greaterThan(0));

    // Tap every checkbox to complete all exercises
    for (int i = 0; i < count; i++) {
      // Tap the i-th checkbox
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pumpAndSettle();

      // If a rest timer appears, we can skip or wait. But the timer is just UI.
      // Let's tap the rest timer's "Bỏ qua" button if it is visible to keep test execution fast
      final skipFinder = find.text('Bỏ qua ➡️');
      if (skipFinder.evaluate().isNotEmpty) {
        await tester.tap(skipFinder);
        await tester.pumpAndSettle();
      }
    }

    // Once all checkboxes are checked, the celebration/feedback dialog should appear!
    // Verify the feedback dialog is showing
    expect(find.text('Buổi tập vừa rồi thế nào?'), findsOneWidget);

    // Choose "Vừa sức"
    await tester.tap(find.text('Vừa sức'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // The dialog should dismiss, and workout should be marked complete
    expect(find.text('Buổi tập vừa rồi thế nào?'), findsNothing);
  });
}
