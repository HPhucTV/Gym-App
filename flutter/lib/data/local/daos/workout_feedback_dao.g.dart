// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_feedback_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkoutFeedbackDaoMixin on DatabaseAccessor<GymDatabase> {
  $GoalsTable get goals => attachedDatabase.goals;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  $WorkoutFeedbacksTable get workoutFeedbacks =>
      attachedDatabase.workoutFeedbacks;
  WorkoutFeedbackDaoManager get managers => WorkoutFeedbackDaoManager(this);
}

class WorkoutFeedbackDaoManager {
  final _$WorkoutFeedbackDaoMixin _db;
  WorkoutFeedbackDaoManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
          _db.attachedDatabase, _db.workoutSessions);
  $$WorkoutFeedbacksTableTableManager get workoutFeedbacks =>
      $$WorkoutFeedbacksTableTableManager(
          _db.attachedDatabase, _db.workoutFeedbacks);
}
