import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_app/data/local/database.dart' as db;
import 'package:gym_app/data/repositories/settings_repository.dart';
import 'package:gym_app/data/repositories/drift_workout_repository.dart';
import 'package:gym_app/data/repositories/workout_repository.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/catalog_models.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late db.GymDatabase database;
  late MockSettingsRepository mockSettingsRepository;
  late DriftWorkoutRepository repository;

  setUp(() {
    database = db.GymDatabase(NativeDatabase.memory());
    mockSettingsRepository = MockSettingsRepository();

    // Default settings stream
    when(() => mockSettingsRepository.settings)
        .thenAnswer((_) => Stream.value(const Settings()));

    repository = DriftWorkoutRepository(
      database: database,
      exercisesProvider: () => [
        const ExerciseDefinition(
          id: 'ex-1',
          sourceId: 'ex-1',
          nameVi: 'Hít đất',
          equipment: [Equipment.bodyweight],
          level: ExperienceLevel.beginner,
          movementPattern: MovementPattern.horizontalPush,
          primaryMuscleGroup: MuscleGroup.chest,
          instructionsVi: [],
        )
      ],
      settingsRepository: mockSettingsRepository,
      currentEpochDay: () => 18000,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('WorkoutRepository tests', () {
    test('createGoal inserts goal, sessions, and exercises in a transaction',
        () async {
      final config = GoalConfig(
        goal: FitnessGoal.muscleGain,
        goals: [FitnessGoal.muscleGain],
        gender: Gender.male,
        bodyType: BodyType.mesomorph,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        sessionsPerWeek: 3,
        durationWeeks: 4,
        restDayMode: RestDayMode.fullRest,
        trainingDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
        sessionDurationMinutes: 45,
      );

      final program = ProgramTemplate(
        id: 'prog-1',
        goal: FitnessGoal.muscleGain,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        durationWeeks: 4,
        sessionsPerWeek: 3,
        workouts: [
          WorkoutTemplate(
            sequence: 0,
            week: 0,
            titleVi: 'Session 1',
            focusVi: 'Chest',
            estimatedMinutes: 45,
            restDaysAfter: 2,
            exercises: [
              const ExercisePrescription(
                exerciseId: 'ex-1',
                sets: 3,
                minReps: 8,
                maxReps: 12,
                durationSeconds: 0,
                restSeconds: 60,
              )
            ],
          )
        ],
      );

      await repository.createGoal(config, program, 18000);

      final activeGoal = await repository.observeActiveGoal().first;
      expect(activeGoal, isNotNull);
      expect(activeGoal!.config.goal, equals(FitnessGoal.muscleGain));

      final currentWorkout = await repository.observeCurrentWorkout().first;
      expect(currentWorkout, isNotNull);
      expect(currentWorkout!.titleVi, equals('Session 1'));
      expect(currentWorkout.exercises.length, equals(1));
      expect(currentWorkout.exercises.first.exerciseId, equals('ex-1'));
    });

    test(
        'completeWorkout validates unchecked exercises and advances remaining schedule',
        () async {
      final config = GoalConfig(
        goal: FitnessGoal.muscleGain,
        goals: [FitnessGoal.muscleGain],
        gender: Gender.male,
        bodyType: BodyType.mesomorph,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        sessionsPerWeek: 3,
        durationWeeks: 4,
        restDayMode: RestDayMode.fullRest,
        trainingDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
        sessionDurationMinutes: 45,
      );

      final program = ProgramTemplate(
        id: 'prog-1',
        goal: FitnessGoal.muscleGain,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        durationWeeks: 4,
        sessionsPerWeek: 3,
        workouts: [
          WorkoutTemplate(
            sequence: 0,
            week: 0,
            titleVi: 'Session 1',
            focusVi: 'Chest',
            estimatedMinutes: 45,
            restDaysAfter: 2,
            exercises: [
              const ExercisePrescription(
                exerciseId: 'ex-1',
                sets: 3,
                minReps: 8,
                maxReps: 12,
                durationSeconds: 0,
                restSeconds: 60,
              )
            ],
          ),
          WorkoutTemplate(
            sequence: 1,
            week: 0,
            titleVi: 'Session 2',
            focusVi: 'Back',
            estimatedMinutes: 45,
            restDaysAfter: 2,
            exercises: [
              const ExercisePrescription(
                exerciseId: 'ex-1',
                sets: 3,
                minReps: 8,
                maxReps: 12,
                durationSeconds: 0,
                restSeconds: 60,
              )
            ],
          )
        ],
      );

      // Start goal on monday 18000
      await repository.createGoal(config, program, 18000);

      final currentWorkout1 = await repository.observeCurrentWorkout().first;
      expect(currentWorkout1, isNotNull);

      // Attempt to complete without checking exercise -> should be blocked
      final blockedResult =
          await repository.completeWorkout(currentWorkout1!.id, 18000);
      expect(blockedResult,
          equals(CompleteWorkoutResult.blockedByUncheckedExercises));

      // Check exercise
      await repository.setExerciseChecked(currentWorkout1.id, 0, true);

      // Complete workout (on wednesday 18002 - delayed by 2 days)
      final successResult =
          await repository.completeWorkout(currentWorkout1.id, 18002);
      expect(successResult, equals(CompleteWorkoutResult.completed));

      // Check that remaining workout (Session 2) has rescheduled due to the delay
      final nextWorkout = await repository.observeCurrentWorkout().first;
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.titleVi, equals('Session 2'));
      // Monday(18000) -> completed on Wednesday(18002).
      // Next scheduled should shift relative to wednesday + 1 training day
      expect(nextWorkout.dueEpochDay, greaterThan(18002));
    });

    test('completeWorkout reschedules remaining workouts on early completion',
        () async {
      final config = GoalConfig(
        goal: FitnessGoal.muscleGain,
        goals: [FitnessGoal.muscleGain],
        gender: Gender.male,
        bodyType: BodyType.mesomorph,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        sessionsPerWeek: 3,
        durationWeeks: 4,
        restDayMode: RestDayMode.fullRest,
        trainingDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
        sessionDurationMinutes: 45,
      );

      final program = ProgramTemplate(
        id: 'prog-1',
        goal: FitnessGoal.muscleGain,
        level: ExperienceLevel.beginner,
        equipmentProfile: EquipmentProfile.dumbbells,
        durationWeeks: 4,
        sessionsPerWeek: 3,
        workouts: [
          WorkoutTemplate(
            sequence: 0,
            week: 0,
            titleVi: 'Session 1',
            focusVi: 'Chest',
            estimatedMinutes: 45,
            restDaysAfter: 2,
            exercises: [
              const ExercisePrescription(
                exerciseId: 'ex-1',
                sets: 3,
                minReps: 8,
                maxReps: 12,
                durationSeconds: 0,
                restSeconds: 60,
              )
            ],
          ),
          WorkoutTemplate(
            sequence: 1,
            week: 0,
            titleVi: 'Session 2',
            focusVi: 'Back',
            estimatedMinutes: 45,
            restDaysAfter: 2,
            exercises: [
              const ExercisePrescription(
                exerciseId: 'ex-1',
                sets: 3,
                minReps: 8,
                maxReps: 12,
                durationSeconds: 0,
                restSeconds: 60,
              )
            ],
          )
        ],
      );

      // Start goal on Tuesday 18002 (due dates: Session 1 on Wednesday 18003, Session 2 on Friday 18005)
      await repository.createGoal(config, program, 18002);

      final currentWorkout1 = await repository.observeCurrentWorkout().first;
      expect(currentWorkout1, isNotNull);
      expect(currentWorkout1!.dueEpochDay, equals(18003));

      // Check exercise
      await repository.setExerciseChecked(currentWorkout1.id, 0, true);

      // Complete workout early (e.g. on Tuesday 18002, which is 1 day earlier than Wednesday 18003)
      final successResult =
          await repository.completeWorkout(currentWorkout1.id, 18002);
      expect(successResult, equals(CompleteWorkoutResult.completed));

      // Check that remaining workout (Session 2) has rescheduled starting from 18002 + 1 = 18003.
      // Next training day starting from 18003 (Wednesday) is 18003.
      final nextWorkout = await repository.observeCurrentWorkout().first;
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.titleVi, equals('Session 2'));
      expect(nextWorkout.dueEpochDay, equals(18003));
    });
  });
}
