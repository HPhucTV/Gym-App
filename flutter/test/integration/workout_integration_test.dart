import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
// import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/feature/today/today_screen.dart';
import 'package:gym_app/feature/today/today_view_model.dart';
import 'package:gym_app/feature/today/today_ui_state.dart';
import 'package:gym_app/ui/components/gym_checkbox.dart';
import 'package:gym_app/main.dart' as app;

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late GymDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = GymDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    debugMockEpochDay = DateTime.utc(2026, 7, 20).millisecondsSinceEpoch ~/
        (24 * 60 * 60 * 1000);
  });

  tearDown(() async {
    await database.close();
    debugMockEpochDay = null;
  });

  Future<String> testAssetReader(String path) async {
    var file = File(path);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    file = File('flutter/$path');
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    throw Exception(
        'Test asset not found: $path (current directory: ${Directory.current.path})');
  }

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
    for (int i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
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
    await app.main(
      overrides: [
        gymDatabaseProvider.overrideWithValue(database),
      ],
      assetReader: testAssetReader,
    );
    await tester.pump();
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }

    await performOnboarding(tester);

    // Verify we are on Today Screen
    expect(find.text('Hôm nay'), findsOneWidget);

    print(
        "ALL_TEXTS_ON_SCREEN: ${tester.allElements.map((e) => e.widget).whereType<Text>().map((w) => w.data ?? w.textSpan?.toPlainText()).toList()}");

    final todayScreenElement = tester.element(find.byType(TodayScreen));
    final container = ProviderScope.containerOf(todayScreenElement);
    final todayState = container.read(todayNotifierProvider);
    print("TODAY_SCREEN_STATE: $todayState");
    if (todayState is TodayUiStateWorkout) {
      print(
          "TODAY_SCREEN_WORKOUT_ROWS: ${todayState.rows.map((r) => r.nameVi).toList()}");
      print(
          "TODAY_SCREEN_WORKOUT_CHECKED: ${todayState.rows.map((r) => r.isChecked).toList()}");
    }

    // Find all Checkboxes (which represent exercise sets)
    final checkboxFinder = find.byType(GymCheckbox);
    final count = checkboxFinder.evaluate().length;
    print("CHECKBOX_COUNT: $count");
    final checkboxes = checkboxFinder.evaluate().toList();
    for (int i = 0; i < checkboxes.length; i++) {
      final element = checkboxes[i];
      final ancestorTypes = <Type>[];
      element.visitAncestorElements((parent) {
        ancestorTypes.add(parent.widget.runtimeType);
        return ancestorTypes.length < 5; // print first 5 ancestors
      });
      print("CHECKBOX_$i ancestors: $ancestorTypes");
    }
    expect(count, greaterThan(0));

    // Tap every checkbox to complete all exercises
    for (int i = 0; i < count; i++) {
      print("TAPPING_CHECKBOX_$i");
      final checkbox = find.byType(GymCheckbox).at(i);
      await tester.ensureVisible(checkbox);
      await tester.pump(const Duration(milliseconds: 200));

      // Tap the checkbox
      await tester.tap(checkbox);
      await tester.pump(const Duration(milliseconds: 500));

      final stateAfterTap = container.read(todayNotifierProvider);
      if (stateAfterTap is TodayUiStateWorkout) {
        print(
            "AFTER_TAP_$i checked states: ${stateAfterTap.rows.map((r) => r.isChecked).toList()}");
        print(
            "AFTER_TAP_$i interactionError: ${stateAfterTap.interactionError}");
        print(
            "AFTER_TAP_$i pendingOrderIndices: ${stateAfterTap.pendingOrderIndices}");
      }

      // If a rest timer appears, we can skip or wait. But the timer is just UI.
      // Let's tap the rest timer's "Bỏ qua" button if it is visible to keep test execution fast
      final skipFinder = find.text('Bỏ qua');
      if (skipFinder.evaluate().isNotEmpty) {
        print("FOUND_REST_TIMER_SKIPPING");
        await tester.tap(skipFinder);
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Scroll to and tap "Hoàn thành buổi tập ✓"
    final completeButtonFinder =
        find.widgetWithText(ElevatedButton, 'Hoàn thành buổi tập ✓');
    await tester.ensureVisible(completeButtonFinder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(completeButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    // Once the button is tapped, the celebration/feedback dialog should appear!
    // Verify the feedback dialog is showing
    expect(find.text('Buổi tập vừa rồi thế nào?'), findsOneWidget);

    // Choose "Vừa sức"
    await tester.tap(find.text('Vừa sức'));
    await tester.pump(const Duration(seconds: 2));

    // The dialog should dismiss, and workout should be marked complete
    expect(find.text('Buổi tập vừa rồi thế nào?'), findsNothing);

    // Dispose the app widget tree to trigger database/provider disposal inside the test body
    await tester.pumpWidget(const SizedBox.shrink());
    // Pump a duration to allow any pending timers/streams to finish
    await tester.pump(const Duration(seconds: 1));
  });
}
