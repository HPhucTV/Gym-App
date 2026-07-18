import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/data/local/database.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/model/profile_models.dart';

void main() {
  late GymDatabase db;

  setUp(() {
    db = GymDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Goal tests', () {
    test('Can insert and retrieve active goal', () async {
      final goalId = await db.workoutDao.insertGoal(GoalsCompanion(
        programId: const Value('test-program'),
        goal: const Value(FitnessGoal.muscleGain),
        goalsCsv: const Value('muscleGain,strength'),
        gender: const Value(Gender.male),
        bodyType: const Value(BodyType.mesomorph),
        level: const Value(ExperienceLevel.beginner),
        equipmentProfile: const Value(EquipmentProfile.dumbbells),
        sessionsPerWeek: const Value(3),
        durationWeeks: const Value(4),
        restDayMode: const Value(RestDayMode.fullRest),
        trainingDaysMask: const Value(42), // Mock mask
        sessionDurationMinutes: const Value(45),
        createdEpochDay: const Value(18000),
        archived: const Value(false),
      ));

      expect(goalId, greaterThan(0));

      final activeGoal = await db.workoutDao.observeActiveGoal().first;
      expect(activeGoal, isNotNull);
      expect(activeGoal!.goal.id, goalId);
      expect(activeGoal.goal.goal, FitnessGoal.muscleGain);
      expect(activeGoal.goal.goalsCsv, 'muscleGain,strength');
    });

    test('Archive active goal works', () async {
      await db.workoutDao.insertGoal(GoalsCompanion(
        programId: const Value('test-program-1'),
        goal: const Value(FitnessGoal.muscleGain),
        goalsCsv: const Value('muscleGain'),
        gender: const Value(Gender.male),
        bodyType: const Value(BodyType.mesomorph),
        level: const Value(ExperienceLevel.beginner),
        equipmentProfile: const Value(EquipmentProfile.dumbbells),
        sessionsPerWeek: const Value(3),
        durationWeeks: const Value(4),
        restDayMode: const Value(RestDayMode.fullRest),
        trainingDaysMask: const Value(42),
        sessionDurationMinutes: const Value(45),
        createdEpochDay: const Value(18000),
        archived: const Value(false),
      ));

      final activeBefore = await db.workoutDao.observeActiveGoal().first;
      expect(activeBefore, isNotNull);

      await db.workoutDao.archiveActiveGoals();

      final activeAfter = await db.workoutDao.observeActiveGoal().first;
      expect(activeAfter, isNull);
    });
  });

  group('Workout Session tests', () {
    test('Complete session sets completion date and updates remaining schedule',
        () async {
      final goalId = await db.workoutDao.insertGoal(GoalsCompanion(
        programId: const Value('test-program'),
        goal: const Value(FitnessGoal.muscleGain),
        goalsCsv: const Value('muscleGain'),
        gender: const Value(Gender.male),
        bodyType: const Value(BodyType.mesomorph),
        level: const Value(ExperienceLevel.beginner),
        equipmentProfile: const Value(EquipmentProfile.dumbbells),
        sessionsPerWeek: const Value(3),
        durationWeeks: const Value(4),
        restDayMode: const Value(RestDayMode.fullRest),
        trainingDaysMask: const Value(42),
        sessionDurationMinutes: const Value(45),
        createdEpochDay: const Value(18000),
        archived: const Value(false),
      ));

      final sessionId = (await db.workoutDao.insertSessions([
        WorkoutSessionsCompanion(
          goalId: Value(goalId),
          sequenceIndex: const Value(0),
          titleVi: const Value('Session 1'),
          focusVi: const Value('Chest'),
          estimatedMinutes: const Value(45),
          dueEpochDay: const Value(18001),
        )
      ]))
          .first;

      await db.workoutDao.insertExercises([
        SessionExercisesCompanion(
          sessionId: Value(sessionId),
          orderIndex: const Value(0),
          exerciseId: const Value('ex-1'),
          sets: const Value(3),
          minReps: const Value(8),
          maxReps: const Value(12),
          durationSeconds: const Value(0),
          restSeconds: const Value(60),
        )
      ]);

      // Initially unchecked
      final unchecked = await db.workoutDao.countUnchecked(sessionId);
      expect(unchecked, equals(1));

      // Check exercise
      await db.workoutDao.setCurrentExerciseChecked(sessionId, 0, true);
      final uncheckedAfter = await db.workoutDao.countUnchecked(sessionId);
      expect(uncheckedAfter, equals(0));

      // Complete workout
      final completed =
          await db.workoutDao.completeSessionIfIncomplete(sessionId, 18001);
      expect(completed, equals(1));

      final session = await db.workoutDao.getSession(sessionId);
      expect(session!.completedEpochDay, equals(18001));
    });
  });

  group('Personalization tests', () {
    test('Can insert and observe profile and weight', () async {
      await db.personalizationDao.upsertProfile(PersonalProfileData(
        id: 1,
        birthDateEpochDay: 10000,
        metabolicSex: MetabolicSex.male,
        heightCm: 175.0,
        currentWeightKg: 70.0,
        targetWeightKg: 75.0,
        activityLevel: ActivityLevel.moderate,
        goalPace: GoalPace.standard,
        personalizationConsent: true,
        cloudAiConsent: true,
        updatedAtEpochMillis: 12345678,
      ));

      final profile = await db.personalizationDao.profileNow();
      expect(profile, isNotNull);
      expect(profile!.currentWeightKg, equals(70.0));

      await db.personalizationDao.upsertWeight(WeightMeasurement(
        weightKg: 70.5,
        epochDay: 18000,
        recordedAtEpochMillis: 12345679,
      ));

      final history = await db.personalizationDao.weightHistoryNow();
      expect(history.length, equals(1));
      expect(history.first.weightKg, equals(70.5));
    });
  });
}
