import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/core/catalog/asset_catalog_repository.dart';
import 'package:gym_app/data/providers/data_providers.dart';
import 'package:gym_app/data/repositories/workout_repository.dart';
import 'package:gym_app/feature/onboarding/onboarding_ui_state.dart';
import 'package:gym_app/feature/onboarding/onboarding_view_model.dart';

class MockAssetCatalogRepository extends Mock
    implements AssetCatalogRepository {}

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssetCatalogRepository mockCatalogRepo;
  late MockWorkoutRepository mockWorkoutRepo;

  final testPrograms = [
    const ProgramTemplate(
      id: "general-body",
      goal: FitnessGoal.generalFitness,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.bodyweightOnly,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      workouts: [],
    ),
    const ProgramTemplate(
      id: "general-gym",
      goal: FitnessGoal.generalFitness,
      level: ExperienceLevel.intermediate,
      equipmentProfile: EquipmentProfile.fullGym,
      sessionsPerWeek: 4,
      durationWeeks: 8,
      workouts: [],
    ),
    const ProgramTemplate(
      id: "muscle-dumbbell",
      goal: FitnessGoal.muscleGain,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.dumbbells,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      workouts: [],
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const GoalConfig(
      goal: FitnessGoal.generalFitness,
      goals: [FitnessGoal.generalFitness],
      gender: Gender.male,
      bodyType: BodyType.mesomorph,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.bodyweightOnly,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      restDayMode: RestDayMode.fullRest,
      trainingDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
      sessionDurationMinutes: 45,
    ));
    registerFallbackValue(const ProgramTemplate(
      id: "general-body",
      goal: FitnessGoal.generalFitness,
      level: ExperienceLevel.beginner,
      equipmentProfile: EquipmentProfile.bodyweightOnly,
      sessionsPerWeek: 3,
      durationWeeks: 4,
      workouts: [],
    ));
  });

  setUp(() {
    mockCatalogRepo = MockAssetCatalogRepository();
    mockWorkoutRepo = MockWorkoutRepository();

    when(() => mockCatalogRepo.programs).thenReturn(testPrograms);
    when(() => mockWorkoutRepo.observeActiveGoal())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockWorkoutRepo.createGoal(any(), any(), any()))
        .thenAnswer((_) => Future.value());
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        assetCatalogRepositoryProvider.overrideWithValue(mockCatalogRepo),
        workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // Helper getters to avoid using private Freezed types
  OnboardingStep? getStep(OnboardingUiState state) {
    return state.maybeWhen(
      editing: (step, draft, options, isSaving, saveError) => step,
      orElse: () => null,
    );
  }

  OnboardingDraft? getDraft(OnboardingUiState state) {
    return state.maybeWhen(
      editing: (step, draft, options, isSaving, saveError) => draft,
      unsupported: (draft, explanation, alternatives) => draft,
      orElse: () => null,
    );
  }

  OnboardingOptions? getOptions(OnboardingUiState state) {
    return state.maybeWhen(
      editing: (step, draft, options, isSaving, saveError) => options,
      orElse: () => null,
    );
  }

  bool isEditing(OnboardingUiState state) {
    return state.maybeWhen(
      editing: (step, draft, options, isSaving, saveError) => true,
      orElse: () => false,
    );
  }

  bool isCreated(OnboardingUiState state) {
    return state.maybeWhen(
      created: () => true,
      orElse: () => false,
    );
  }

  bool isUnsupported(OnboardingUiState state) {
    return state.maybeWhen(
      unsupported: (draft, explanation, alternatives) => true,
      orElse: () => false,
    );
  }

  void completeGeneral(OnboardingNotifier notifier) {
    notifier.selectGender(Gender.male);
    notifier.selectBodyType(BodyType.mesomorph);
    notifier.toggleGoal(FitnessGoal.generalFitness);
    notifier.selectLevel(ExperienceLevel.beginner);
    notifier.selectEquipment(EquipmentProfile.bodyweightOnly);
    notifier.toggleTrainingDay(WeekDay.monday);
    notifier.toggleTrainingDay(WeekDay.wednesday);
    notifier.toggleTrainingDay(WeekDay.friday);
    notifier.selectSessionDuration(45);
    notifier.selectRestDayMode(RestDayMode.fullRest);
  }

  test('user selects weekdays and a duration bucket', () {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.toggleGoal(FitnessGoal.generalFitness);
    notifier.selectLevel(ExperienceLevel.beginner);
    notifier.selectEquipment(EquipmentProfile.bodyweightOnly);

    // Toggle 7 days, but since we cannot select more than 6 training days, it caps
    for (final day in WeekDay.values) {
      notifier.toggleTrainingDay(day);
    }
    notifier.selectSessionDuration(75);

    final state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    final draft = getDraft(state)!;
    expect(draft.trainingDays.length, equals(6));
    expect(draft.sessionDurationMinutes, equals(75));
  });

  test('progresses through step by step and can go back', () {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    var state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.personalInfo));

    notifier.selectGender(Gender.male);
    notifier.selectBodyType(BodyType.mesomorph);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.goal));

    notifier.toggleGoal(FitnessGoal.generalFitness);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.level));

    notifier.selectLevel(ExperienceLevel.beginner);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.equipment));

    notifier.selectEquipment(EquipmentProfile.bodyweightOnly);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.trainingDays));

    notifier.toggleTrainingDay(WeekDay.monday);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.sessionDuration));

    notifier.selectSessionDuration(45);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.restBehavior));

    notifier.selectRestDayMode(RestDayMode.fullRest);
    notifier.next();

    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.review));

    notifier.back(null);
    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getStep(state), equals(OnboardingStep.restBehavior));
  });

  test('changing earlier choice clears downstream fields', () {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.toggleGoal(FitnessGoal.generalFitness);
    var state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getOptions(state)!.levels,
        equals({ExperienceLevel.beginner, ExperienceLevel.intermediate}));

    notifier.selectLevel(ExperienceLevel.beginner);
    state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    expect(getOptions(state)!.equipment,
        equals({EquipmentProfile.bodyweightOnly}));

    notifier.selectEquipment(EquipmentProfile.bodyweightOnly);
    notifier.toggleTrainingDay(WeekDay.monday);

    notifier.toggleGoal(FitnessGoal.generalFitness); // Unselect general fitness
    notifier.toggleGoal(FitnessGoal.muscleGain); // Select muscle gain instead
    state = container.read(onboardingNotifierProvider);

    expect(isEditing(state), isTrue);
    final draft = getDraft(state)!;
    expect(draft.goal, equals(FitnessGoal.muscleGain));
    expect(draft.level, isNull);
    expect(draft.equipment, isNull);
  });

  test('supported selection creates exact goal', () async {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    completeGeneral(notifier);
    // Go all the way to review step
    for (int i = 0; i < 7; i++) {
      notifier.next();
    }

    await notifier.createGoal();
    final state = container.read(onboardingNotifierProvider);
    expect(isCreated(state), isTrue);

    verify(() => mockWorkoutRepo.createGoal(any(), any(), any())).called(1);
  });

  test('unsupported exact combination shows alternatives', () async {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.selectGender(Gender.male);
    notifier.selectBodyType(BodyType.mesomorph);
    notifier.toggleGoal(FitnessGoal.muscleGain);
    notifier.selectLevel(ExperienceLevel.beginner);
    notifier.selectEquipment(EquipmentProfile
        .bodyweightOnly); // Bodyweight + Muscle gain Beginner is unsupported in mock catalog
    notifier.toggleTrainingDay(WeekDay.monday);
    notifier.selectSessionDuration(45);
    notifier.selectRestDayMode(RestDayMode.fullRest);

    for (int i = 0; i < 7; i++) {
      notifier.next();
    }

    await notifier.createGoal();
    final state = container.read(onboardingNotifierProvider);
    expect(isUnsupported(state), isTrue);
    final explanation = state.maybeWhen(
      unsupported: (draft, explanation, alternatives) => explanation,
      orElse: () => null,
    );
    expect(explanation, contains("Chưa có chương trình"));
  });

  test('persistence failure is recoverable and retry succeeds', () async {
    final container = createContainer();
    final notifier = container.read(onboardingNotifierProvider.notifier);

    completeGeneral(notifier);
    for (int i = 0; i < 7; i++) {
      notifier.next();
    }

    // Stub first creation to fail, second to succeed
    var attempts = 0;
    when(() => mockWorkoutRepo.createGoal(any(), any(), any()))
        .thenAnswer((_) async {
      attempts++;
      if (attempts == 1) {
        throw Exception("disk full");
      }
      return;
    });

    await notifier.createGoal();
    var state = container.read(onboardingNotifierProvider);
    expect(isEditing(state), isTrue);
    final saveError = state.maybeWhen(
      editing: (step, draft, options, isSaving, saveError) => saveError,
      orElse: () => null,
    );
    expect(saveError, isNotNull);

    await notifier.createGoal();
    state = container.read(onboardingNotifierProvider);
    expect(isCreated(state), isTrue);
    expect(attempts, equals(2));
  });
}
