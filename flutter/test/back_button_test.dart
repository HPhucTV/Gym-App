import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/core/catalog/asset_catalog_repository.dart';
import 'package:gym_app/core/motivation/motivation_repository.dart';
import 'package:gym_app/ui/theme/theme.dart';

void main() {
  late GymDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = GymDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Double back press to exit and sub-page back navigation test',
      (WidgetTester tester) async {
    // 1. Setup mock repositories & providers
    final catalogRepo = AssetCatalogRepository(
      assetReader: (path) async => '[]', // dummy catalog
    );
    await catalogRepo.init();

    final motivationRepo = MotivationRepository(
      assetReader: (path) async => '[]', // dummy motivation
    );
    await motivationRepo.init();

    // 2. Build the app shell
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymDatabaseProvider.overrideWithValue(database),
          assetCatalogRepositoryProvider.overrideWithValue(catalogRepo),
          motivationRepositoryProvider.overrideWithValue(motivationRepo),
        ],
        child: MaterialApp(
          theme: getGymLightTheme(),
          darkTheme: getGymDarkTheme(),
          home: const Scaffold(
            body: AppRouterRoot(),
          ),
        ),
      ),
    );

    await tester.pump();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Reset back press timer by pumping time forward
    await tester.pump(const Duration(seconds: 3));

    // Tap back button 1st time
    print('Testing 1st back press...');
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    // SnackBar should be shown
    expect(
        find.text('Nhấn trở lại một lần nữa để thoát ứng dụng'), findsOneWidget);

    // Press back again after 3 seconds (timer expired)
    print('Sleeping 3 seconds...');
    sleep(const Duration(seconds: 3));

    print('Testing back press after timeout...');
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    // SnackBar should be shown again
    expect(
        find.text('Nhấn trở lại một lần nữa để thoát ứng dụng'), findsOneWidget);

    // Press back again immediately (within 2 seconds)
    print('Testing double back press to exit...');
    bool popCalled = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'SystemNavigator.pop') {
          popCalled = true;
        }
        return null;
      },
    );

    // Press back twice quickly
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    expect(popCalled, isTrue);
  });
}
