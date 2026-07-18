import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/workout_models.dart';
import 'package:gym_app/core/program/schedule_rescheduler.dart';
import 'package:gym_app/data/repositories/workout_repository.dart';
import 'package:gym_app/data/repositories/settings_repository.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/feature/settings/settings_ui_state.dart';
import 'package:gym_app/feature/settings/settings_view_model.dart';
import 'package:gym_app/core/notification/notification_service.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockReminderScheduler extends Mock implements ReminderScheduler {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockWorkoutRepository mockWorkoutRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockReminderScheduler mockReminderScheduler;

  final activeGoal = ActiveGoal(
    id: 1,
    config: GoalConfig(
      goal: FitnessGoal.generalFitness,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.bodyweightOnly,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      restDayMode: RestDayMode.fullRest,
      trainingDays: const {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
      goals: const [FitnessGoal.generalFitness],
    ),
    totalWorkouts: 12,
  );

  const testSettings = Settings(
    reminderEnabled: true,
    reminderHour: 8,
    reminderMinute: 30,
    restDayMode: RestDayMode.fullRest,
    customServerUrl: "http://test-server.com",
    darkModeEnabled: false,
  );

  setUpAll(() {
    registerFallbackValue(ScheduleChangePreview(changes: const [], warningsVi: const []));
  });

  setUp(() {
    mockWorkoutRepo = MockWorkoutRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockReminderScheduler = MockReminderScheduler();

    // Default mock behaviors
    when(() => mockWorkoutRepo.observeActiveGoal()).thenAnswer((_) => Stream.value(activeGoal));
    when(() => mockWorkoutRepo.observeCurrentWorkout()).thenAnswer((_) => Stream.value(null));
    when(() => mockSettingsRepo.settings).thenAnswer((_) => Stream.value(testSettings));

    when(() => mockSettingsRepo.setRestDayMode(any())).thenAnswer((_) => Future.value());
    when(() => mockSettingsRepo.setCustomServerUrl(any())).thenAnswer((_) => Future.value());
    when(() => mockSettingsRepo.setDarkModeEnabled(any())).thenAnswer((_) => Future.value());
    when(() => mockSettingsRepo.setReminderTime(any(), any())).thenAnswer((_) => Future.value());
    when(() => mockSettingsRepo.setReminderEnabled(any())).thenAnswer((_) => Future.value());
    when(() => mockWorkoutRepo.archiveActiveGoal()).thenAnswer((_) => Future.value());
    
    when(() => mockReminderScheduler.schedule(any(), any())).thenAnswer((_) => Future.value());
    when(() => mockReminderScheduler.cancel()).thenAnswer((_) => Future.value());
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        reminderSchedulerProvider.overrideWithValue(mockReminderScheduler),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('state is Loading when streams have not resolved', () async {
    final activeGoalController = StreamController<ActiveGoal?>();
    when(() => mockWorkoutRepo.observeActiveGoal()).thenAnswer((_) => activeGoalController.stream);

    final container = createContainer();
    final sub = container.listen(settingsNotifierProvider, (prev, next) {});
    
    expect(container.read(settingsNotifierProvider), isA<SettingsUiStateLoading>());

    activeGoalController.add(activeGoal);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(container.read(settingsNotifierProvider), isA<SettingsUiStateContent>());

    sub.close();
    activeGoalController.close();
  });

  test('state is Error when active goal is not found', () async {
    when(() => mockWorkoutRepo.observeActiveGoal()).thenAnswer((_) => Stream.value(null));

    final container = createContainer();
    final sub = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    expect(container.read(settingsNotifierProvider), isA<SettingsUiStateError>());
    
    sub.close();
  });

  test('state is Content when both goal and settings resolve successfully', () async {
    final container = createContainer();
    final sub = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    final state = container.read(settingsNotifierProvider);
    expect(state, isA<SettingsUiStateContent>());
    final content = state as SettingsUiStateContent;

    expect(content.goal.goal, equals(FitnessGoal.generalFitness));
    expect(content.goal.level, equals(ExperienceLevel.beginner));
    expect(content.goal.equipment, equals(EquipmentProfile.bodyweightOnly));
    expect(content.reminderEnabled, isTrue);
    expect(content.reminderHour, equals(8));
    expect(content.reminderMinute, equals(30));
    expect(content.customServerUrl, equals("http://test-server.com"));
    expect(content.darkModeEnabled, isFalse);

    sub.close();
  });

  test('saving settings updates trigger repository calls and transitions state', () async {
    final container = createContainer();
    final sub = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    final notifier = container.read(settingsNotifierProvider.notifier);

    // Rest Day Mode
    await notifier.setRestDayMode(RestDayMode.lightRecovery);
    verify(() => mockSettingsRepo.setRestDayMode(RestDayMode.lightRecovery)).called(1);

    // Custom Server URL
    await notifier.setCustomServerUrl("http://new-server.com");
    verify(() => mockSettingsRepo.setCustomServerUrl("http://new-server.com")).called(1);

    // Dark Mode Enabled
    await notifier.setDarkModeEnabled(true);
    verify(() => mockSettingsRepo.setDarkModeEnabled(true)).called(1);

    // Reminder Time
    await notifier.setReminderTime(12, 45);
    verify(() => mockSettingsRepo.setReminderTime(12, 45)).called(1);

    sub.close();
  });

  test('enabling reminder emits notification permission request event', () async {
    final container = createContainer();
    final subState = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    final notifier = container.read(settingsNotifierProvider.notifier);
    
    // Listen directly to eventStream
    final events = <SettingsEvent>[];
    final sub = notifier.eventStream.listen((event) => events.add(event));

    await notifier.setReminderEnabled(true);

    verify(() => mockSettingsRepo.setReminderEnabled(true)).called(1);
    
    await Future.delayed(const Duration(milliseconds: 50));
    expect(events, contains(const SettingsEventRequestNotificationPermission()));

    sub.cancel();
    subState.close();
  });

  test('schedule rescheduling preview, cancel, and apply flow works', () async {
    final preview = ScheduleChangePreview(
      changes: [
        SessionDateChange(sessionId: 5, oldEpochDay: 90, newEpochDay: 100),
      ],
      warningsVi: const [],
    );

    when(() => mockWorkoutRepo.previewScheduleChange(any(), any())).thenAnswer((_) => Future.value(preview));
    when(() => mockWorkoutRepo.applyScheduleChange(any())).thenAnswer((_) => Future.value(ScheduleChangeResult.applied));

    final container = createContainer();
    final sub = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    final notifier = container.read(settingsNotifierProvider.notifier);
    
    // Preview
    await notifier.previewScheduleChange(5, 100);
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).schedulePreview,
      equals(preview),
    );

    // Cancel preview
    notifier.cancelSchedulePreview();
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).schedulePreview,
      isNull,
    );

    // Preview again and apply
    await notifier.previewScheduleChange(5, 100);
    await notifier.confirmScheduleChange();

    verify(() => mockWorkoutRepo.applyScheduleChange(preview)).called(1);
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).schedulePreview,
      isNull,
    );
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).message,
      equals("Đã cập nhật lịch tập sắp tới."),
    );

    sub.close();
  });

  test('replace and delete goal requests require confirmations', () async {
    final container = createContainer();
    final subState = container.listen(settingsNotifierProvider, (prev, next) {});
    await Future.delayed(const Duration(milliseconds: 50));

    final notifier = container.read(settingsNotifierProvider.notifier);

    // Listen directly to eventStream
    final events = <SettingsEvent>[];
    final sub = notifier.eventStream.listen((event) => events.add(event));

    // Replace goal
    notifier.requestReplaceGoal();
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).confirmation,
      equals(PendingConfirmation.replace),
    );

    // Cancel confirmation
    notifier.cancelConfirmation();
    expect(
      (container.read(settingsNotifierProvider) as SettingsUiStateContent).confirmation,
      equals(PendingConfirmation.none),
    );

    // Request replacement again and confirm
    notifier.requestReplaceGoal();
    
    // Call confirmGoalAction and await it
    await notifier.confirmGoalAction();

    verify(() => mockWorkoutRepo.archiveActiveGoal()).called(1);
    
    expect(events.length, equals(1));
    final event = events.first as SettingsEventGoToOnboarding;
    expect(event.replacing, isTrue);

    sub.cancel();
    subState.close();
  });
}
