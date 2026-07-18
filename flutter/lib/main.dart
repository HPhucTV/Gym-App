import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/catalog/asset_catalog_repository.dart';
import 'core/motivation/motivation_repository.dart';
import 'data/providers/data_providers.dart';
import 'ui/theme/theme.dart';
import 'ui/theme/colors.dart';
import 'feature/onboarding/onboarding_screen.dart';
import 'feature/today/today_screen.dart';
import 'feature/progress/progress_screen.dart';
import 'feature/progress/progress_view_model.dart';
import 'feature/settings/settings_screen.dart';
import 'feature/settings/settings_view_model.dart';
import 'feature/profile/profile_screen.dart';
import 'feature/recommendations/recommendation_screen.dart';
import 'feature/roadmap/roadmap_screen.dart';
import 'feature/catalog/exercise_catalog_screen.dart';
import 'feature/checkin/weekly_checkin_screen.dart';
import 'feature/nutrition/nutrition_screen.dart';

Future<void> main({
  List<dynamic> overrides = const [],
  Future<String> Function(String)? assetReader,
}) async {
  print('MAIN: Calling WidgetsFlutterBinding.ensureInitialized...');
  WidgetsFlutterBinding.ensureInitialized();
  print('MAIN: WidgetsFlutterBinding.ensureInitialized done.');

  // Load SharedPreferences
  print('MAIN: Getting SharedPreferences instance...');
  final prefs = await SharedPreferences.getInstance();
  print('MAIN: SharedPreferences instance obtained.');

  final reader = assetReader ?? (path) => rootBundle.loadString(path);

  // Load and initialize Asset Catalog
  print('MAIN: Initializing AssetCatalogRepository...');
  final catalogRepo = AssetCatalogRepository(
    assetReader: reader,
  );
  await catalogRepo.init();
  print('MAIN: AssetCatalogRepository initialized.');

  // Load and initialize Motivation quotes
  print('MAIN: Initializing MotivationRepository...');
  final motivationRepo = MotivationRepository(
    assetReader: reader,
  );
  await motivationRepo.init();
  print('MAIN: MotivationRepository initialized.');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        assetCatalogRepositoryProvider.overrideWithValue(catalogRepo),
        motivationRepositoryProvider.overrideWithValue(motivationRepo),
        ...overrides,
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings to apply Dark/Light Mode system-wide
    final settingsAsync = ref.watch(settingsPrefsProvider);
    final settings = settingsAsync.value;

    final themeMode = settings?.darkModeEnabled == null
        ? ThemeMode.system
        : (settings!.darkModeEnabled! ? ThemeMode.dark : ThemeMode.light);

    return MaterialApp(
      title: 'SmartGym Companion',
      theme: getGymLightTheme(),
      darkTheme: getGymDarkTheme(),
      themeMode: themeMode,
      home: const AppRouterRoot(),
    );
  }
}

class CurrentSubRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  set state(String? value) => super.state = value;
}

final currentSubRouteProvider = NotifierProvider<CurrentSubRouteNotifier, String?>(CurrentSubRouteNotifier.new);

class CurrentShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  set state(int value) => super.state = value;
}

final currentShellTabProvider = NotifierProvider<CurrentShellTabNotifier, int>(CurrentShellTabNotifier.new);

class AppRouterRoot extends ConsumerWidget {
  const AppRouterRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGoalAsync = ref.watch(progressActiveGoalProvider);
    final activeGoal = activeGoalAsync.value;
    final subRoute = ref.watch(currentSubRouteProvider);

    if (activeGoalAsync.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    // 1. If no active goal is set, show Onboarding
    if (activeGoal == null) {
      return OnboardingScreen(
        replacementMode: false,
        onCancel: () {},
        onGoalCreated: () {
          ref.read(currentSubRouteProvider.notifier).state = null;
          ref.read(currentShellTabProvider.notifier).state = 0;
        },
      );
    }

    // 2. Route to sub-pages if requested
    if (subRoute == 'onboarding_replace') {
      return OnboardingScreen(
        replacementMode: true,
        onCancel: () {
          ref.read(currentSubRouteProvider.notifier).state = null;
        },
        onGoalCreated: () {
          ref.read(currentSubRouteProvider.notifier).state = null;
          ref.read(currentShellTabProvider.notifier).state = 0;
        },
      );
    }

    if (subRoute == 'profile') {
      return ProfileScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
      );
    }

    if (subRoute == 'checkin') {
      return WeeklyCheckInScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
        onNavigateToProfile: () => ref.read(currentSubRouteProvider.notifier).state = 'profile',
      );
    }

    if (subRoute == 'recommendations') {
      return RecommendationScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
      );
    }

    if (subRoute == 'roadmap') {
      return RoadmapScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
      );
    }

    if (subRoute == 'catalog') {
      return ExerciseCatalogScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
      );
    }

    if (subRoute == 'nutrition') {
      return NutritionScreen(
        onBack: () => ref.read(currentSubRouteProvider.notifier).state = null,
      );
    }

    // 3. Otherwise show Main Navigation Shell
    return const MainNavigationShell();
  }
}

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(currentShellTabProvider);

    final List<Widget> screens = [
      TodayScreen(
        onNavigateToCatalog: () {
          ref.read(currentSubRouteProvider.notifier).state = 'catalog';
        },
        onNavigateToNutrition: () {
          ref.read(currentSubRouteProvider.notifier).state = 'nutrition';
        },
      ),
      ProgressScreen(
        onNavigateToCatalog: () {
          ref.read(currentSubRouteProvider.notifier).state = 'catalog';
        },
        onNavigateToRoadmap: () {
          // Route or highlight progress roadmap
          ref.read(currentSubRouteProvider.notifier).state = 'recommendations';
        },
      ),
      SettingsScreen(
        onNavigateToProfile: () {
          ref.read(currentSubRouteProvider.notifier).state = 'profile';
        },
        onNavigateToCheckIn: () {
          ref.read(currentSubRouteProvider.notifier).state = 'checkin';
        },
        onNavigateToRecommendations: () {
          ref.read(currentSubRouteProvider.notifier).state = 'recommendations';
        },
        onGoToOnboardingReplacment: () {
          ref.read(currentSubRouteProvider.notifier).state = 'onboarding_replace';
        },
        onGoToOnboardingNew: () {
          ref.read(currentSubRouteProvider.notifier).state = 'onboarding_replace';
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          ref.read(currentShellTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            selectedIcon: Icon(Icons.today, color: Colors.orange),
            label: 'Hôm nay',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.orange),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings, color: Colors.orange),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onBack;

  const _PlaceholderScreen({
    required this.title,
    required this.description,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: onBack,
        ),
        title: Text(
          title,
          style: TextStyle(color: customColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBg
          : AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🚧", style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                "Tính năng đang phát triển",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customColors.primaryText,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: customColors.mutedText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Quay lại"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
