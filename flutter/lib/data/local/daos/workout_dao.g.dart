// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkoutDaoMixin on DatabaseAccessor<GymDatabase> {
  $GoalsTable get goals => attachedDatabase.goals;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  WorkoutDaoManager get managers => WorkoutDaoManager(this);
}

class WorkoutDaoManager {
  final _$WorkoutDaoMixin _db;
  WorkoutDaoManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
          _db.attachedDatabase, _db.workoutSessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(
          _db.attachedDatabase, _db.sessionExercises);
}
