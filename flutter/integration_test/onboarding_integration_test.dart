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

  testWidgets('Onboarding and Goal Creation Integration Test',
      (WidgetTester tester) async {
    // Set viewport size so all list options are visible without scrolling
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch the app with in-memory database override
    app.main(overrides: [
      gymDatabaseProvider.overrideWithValue(database),
    ]);

    // Wait for the async initialization in app.main (SharedPreferences, Asset Catalog etc.)
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen is shown (we should see "Bước 1/8")
    expect(find.textContaining('Bước 1/8'), findsOneWidget);
    expect(find.text('Giới tính'), findsOneWidget);

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
    expect(find.textContaining('Bước 2/8'), findsOneWidget);
    // Tap "Tăng cơ"
    await tester.tap(find.text('Tăng cơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 3/8: Level
    expect(find.textContaining('Bước 3/8'), findsOneWidget);
    // Tap "Trung cấp"
    await tester.tap(find.text('Trung cấp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 4/8: Equipment
    expect(find.textContaining('Bước 4/8'), findsOneWidget);
    // Tap "Phòng gym đầy đủ"
    await tester.tap(find.text('Phòng gym đầy đủ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 5/8: Training Days
    expect(find.textContaining('Bước 5/8'), findsOneWidget);
    // Select Thứ Hai, Thứ Tư, Thứ Sáu
    await tester.tap(find.text('Thứ Hai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thứ Tư'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thứ Sáu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 6/8: Duration
    expect(find.textContaining('Bước 6/8'), findsOneWidget);
    // Tap "Tối đa 60 phút"
    await tester.tap(find.text('Tối đa 60 phút'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 7/8: Rest behavior
    expect(find.textContaining('Bước 7/8'), findsOneWidget);
    // Tap "Nghỉ hoàn toàn"
    await tester.tap(find.text('Nghỉ hoàn toàn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Step 8/8: Review
    expect(find.textContaining('Bước 8/8'), findsOneWidget);
    // Tap "Tạo mục tiêu" button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo mục tiêu'));
    // Wait for generator to run and save (3 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // After goal creation, we should land on TodayScreen/MainNavigationShell!
    expect(find.text('HÔM NAY'), findsOneWidget);
  });
}
