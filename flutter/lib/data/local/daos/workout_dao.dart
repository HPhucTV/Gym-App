import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/goals.dart';
import '../tables/workout_sessions.dart';
import '../tables/session_exercises.dart';
import 'dart:async';

part 'workout_dao.g.dart';

class GoalWithWorkoutCount {
  final Goal goal;
  final int totalWorkouts;

  GoalWithWorkoutCount({required this.goal, required this.totalWorkouts});
}

class SessionWithExercises {
  final WorkoutSession session;
  final List<SessionExercise> exercises;

  SessionWithExercises({required this.session, required this.exercises});
}

class CompletedSessionRow {
  final int goalId;
  final int completedEpochDay;

  CompletedSessionRow({required this.goalId, required this.completedEpochDay});
}

extension StreamSwitchMap<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R> Function(T) transform) {
    StreamController<R>? controller;
    StreamSubscription<T>? subscription;
    StreamSubscription<R>? innerSubscription;

    controller = StreamController<R>(
      onListen: () {
        subscription = listen(
          (event) {
            innerSubscription?.cancel();
            final innerStream = transform(event);
            innerSubscription = innerStream.listen(
              (r) => controller?.add(r),
              onError: (Object err, StackTrace stack) =>
                  controller?.addError(err, stack),
              onDone: () {},
            );
          },
          onError: (Object err, StackTrace stack) =>
              controller?.addError(err, stack),
          onDone: () => controller?.close(),
        );
      },
      onCancel: () async {
        await subscription?.cancel();
        await innerSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}

@DriftAccessor(tables: [Goals, WorkoutSessions, SessionExercises])
class WorkoutDao extends DatabaseAccessor<GymDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  Stream<GoalWithWorkoutCount?> observeActiveGoal() {
    final query = customSelect(
      'SELECT goals.*, '
      '(SELECT COUNT(*) FROM workout_sessions WHERE workout_sessions.goal_id = goals.id) AS total_workouts '
      'FROM goals '
      'WHERE archived = 0 '
      'ORDER BY id DESC '
      'LIMIT 1',
      readsFrom: {goals, workoutSessions},
    );
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      final goal = goals.map(row.data);
      final totalWorkouts = row.read<int>('total_workouts');
      return GoalWithWorkoutCount(goal: goal, totalWorkouts: totalWorkouts);
    });
  }

  Stream<SessionWithExercises?> observeCurrentSession() {
    final currentSessionIdStream = customSelect(
      'SELECT workout_sessions.id FROM workout_sessions '
      'INNER JOIN goals ON goals.id = workout_sessions.goal_id '
      'WHERE goals.archived = 0 AND workout_sessions.completed_epoch_day IS NULL '
      'ORDER BY workout_sessions.sequence_index ASC, workout_sessions.id ASC '
      'LIMIT 1',
      readsFrom: {workoutSessions, goals},
    ).watchSingleOrNull().map((row) => row?.read<int>('id'));

    return currentSessionIdStream.switchMap((sessionId) {
      if (sessionId == null) return Stream.value(null);

      final sessionQuery = select(workoutSessions)
        ..where((tbl) => tbl.id.equals(sessionId));
      final exercisesQuery = select(sessionExercises)
        ..where((tbl) => tbl.sessionId.equals(sessionId))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]);

      return sessionQuery.watchSingle().switchMap((session) {
        return exercisesQuery.watch().map((exercises) {
          return SessionWithExercises(session: session, exercises: exercises);
        });
      });
    });
  }

  Stream<List<CompletedSessionRow>> observeCompletedSessions() {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.completedEpochDay.isNotNull())
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.completedEpochDay),
        (tbl) => OrderingTerm.asc(tbl.goalId),
        (tbl) => OrderingTerm.asc(tbl.sequenceIndex),
        (tbl) => OrderingTerm.asc(tbl.id),
      ]);
    return query.watch().map((rows) {
      return rows
          .map((r) => CompletedSessionRow(
                goalId: r.goalId,
                completedEpochDay: r.completedEpochDay!,
              ))
          .toList();
    });
  }

  Stream<List<WorkoutSession>> observeWorkoutHistory() {
    final query = select(workoutSessions)
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.goalId),
        (tbl) => OrderingTerm.asc(tbl.sequenceIndex),
        (tbl) => OrderingTerm.asc(tbl.id),
      ]);
    return query.watch();
  }

  Future<int> insertGoal(GoalsCompanion goal) {
    return into(goals).insert(goal);
  }

  Future<List<int>> insertSessions(
      List<WorkoutSessionsCompanion> sessions) async {
    return transaction(() async {
      final list = <int>[];
      for (final s in sessions) {
        final id = await into(workoutSessions).insert(s);
        list.add(id);
      }
      return list;
    });
  }

  Future<void> insertExercises(
      List<SessionExercisesCompanion> exercisesList) async {
    await batch((b) {
      b.insertAll(sessionExercises, exercisesList);
    });
  }

  Future<int> updateSessions(List<WorkoutSession> sessions) async {
    int count = 0;
    await transaction(() async {
      for (final s in sessions) {
        final updated = await update(workoutSessions).replace(s);
        if (updated) count++;
      }
    });
    return count;
  }

  Future<List<WorkoutSession>> getSessions(List<int> sessionIds) {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.id.isIn(sessionIds));
    return query.get();
  }

  Future<List<WorkoutSession>> getSessionsForGoal(int goalId) {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.goalId.equals(goalId))
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.sequenceIndex),
        (tbl) => OrderingTerm.asc(tbl.id)
      ]);
    return query.get();
  }

  Future<Goal?> getGoal(int goalId) {
    final query = select(goals)..where((tbl) => tbl.id.equals(goalId));
    return query.getSingleOrNull();
  }

  Future<int> updateSessionDueEpochDay(int sessionId, int dueEpochDay) {
    final query = update(workoutSessions)
      ..where((tbl) => tbl.id.equals(sessionId));
    return query
        .write(WorkoutSessionsCompanion(dueEpochDay: Value(dueEpochDay)));
  }

  Future<List<SessionExercise>> getExercisesForSession(int sessionId) {
    final query = select(sessionExercises)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]);
    return query.get();
  }

  Future<int> substituteCurrentExercise({
    required int sessionId,
    required int orderIndex,
    required String replacementExerciseId,
  }) async {
    return transaction(() async {
      final currentSessionId = await getCurrentSessionId();
      if (currentSessionId != sessionId) {
        return 0;
      }

      final exercise = await (select(sessionExercises)
            ..where((tbl) =>
                tbl.sessionId.equals(sessionId) &
                tbl.orderIndex.equals(orderIndex)))
          .getSingleOrNull();
      if (exercise == null ||
          exercise.isChecked ||
          exercise.omittedByTimeBudget) {
        return 0;
      }

      final originalId = exercise.originalExerciseId ?? exercise.exerciseId;

      final query = update(sessionExercises)
        ..where((tbl) =>
            tbl.sessionId.equals(sessionId) &
            tbl.orderIndex.equals(orderIndex) &
            tbl.isChecked.equals(false) &
            tbl.omittedByTimeBudget.equals(false));

      return query.write(SessionExercisesCompanion(
        originalExerciseId: Value(originalId),
        exerciseId: Value(replacementExerciseId),
      ));
    });
  }

  Future<int> setCurrentExerciseChecked(
      int sessionId, int orderIndex, bool checked) async {
    return transaction(() async {
      final currentSessionId = await getCurrentSessionId();
      if (currentSessionId != sessionId) {
        return 0;
      }
      final query = update(sessionExercises)
        ..where((tbl) =>
            tbl.sessionId.equals(sessionId) &
            tbl.orderIndex.equals(orderIndex) &
            tbl.omittedByTimeBudget.equals(false));
      return query.write(SessionExercisesCompanion(
        isChecked: Value(checked),
      ));
    });
  }

  Future<int> countUnchecked(int sessionId) async {
    final query = select(sessionExercises)
      ..where((tbl) =>
          tbl.sessionId.equals(sessionId) &
          tbl.isChecked.equals(false) &
          tbl.omittedByTimeBudget.equals(false));
    final rows = await query.get();
    return rows.length;
  }

  Future<int> countChecked(int sessionId) async {
    final query = select(sessionExercises)
      ..where((tbl) =>
          tbl.sessionId.equals(sessionId) & tbl.isChecked.equals(true));
    final rows = await query.get();
    return rows.length;
  }

  Future<int> updateSelectedTimeBudget(int sessionId, int? minutes) {
    final query = update(workoutSessions)
      ..where((tbl) => tbl.id.equals(sessionId));
    return query.write(
        WorkoutSessionsCompanion(selectedTimeBudgetMinutes: Value(minutes)));
  }

  Future<int> setAllExercisesOmittedByTimeBudget(int sessionId, bool omitted) {
    final query = update(sessionExercises)
      ..where((tbl) => tbl.sessionId.equals(sessionId));
    return query
        .write(SessionExercisesCompanion(omittedByTimeBudget: Value(omitted)));
  }

  Future<int> activateExercisesForTimeBudget(
      int sessionId, List<int> orderIndices) {
    final query = update(sessionExercises)
      ..where((tbl) =>
          tbl.sessionId.equals(sessionId) & tbl.orderIndex.isIn(orderIndices));
    return query.write(
        SessionExercisesCompanion(omittedByTimeBudget: const Value(false)));
  }

  Future<WorkoutSession?> getSession(int sessionId) {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.id.equals(sessionId));
    return query.getSingleOrNull();
  }

  Future<int?> getCurrentSessionId() async {
    final query = customSelect(
      'SELECT workout_sessions.id FROM workout_sessions '
      'INNER JOIN goals ON goals.id = workout_sessions.goal_id '
      'WHERE goals.archived = 0 AND workout_sessions.completed_epoch_day IS NULL '
      'ORDER BY workout_sessions.sequence_index ASC, workout_sessions.id ASC '
      'LIMIT 1',
      readsFrom: {workoutSessions, goals},
    );
    final row = await query.getSingleOrNull();
    return row?.read<int>('id');
  }

  Future<List<int>> getUpcomingIncompleteSessionIds(int limit) async {
    final query = customSelect(
      'SELECT workout_sessions.id FROM workout_sessions '
      'INNER JOIN goals ON goals.id = workout_sessions.goal_id '
      'WHERE goals.archived = 0 AND workout_sessions.completed_epoch_day IS NULL '
      'ORDER BY workout_sessions.sequence_index ASC, workout_sessions.id ASC '
      'LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {workoutSessions, goals},
    );
    final rows = await query.get();
    return rows.map((r) => r.read<int>('id')).toList();
  }

  Future<int> updateIncompleteSessionVolumeScale(
      List<int> sessionIds, int percent) {
    final query = update(workoutSessions)
      ..where(
          (tbl) => tbl.id.isIn(sessionIds) & tbl.completedEpochDay.isNull());
    return query
        .write(WorkoutSessionsCompanion(volumeScalePercent: Value(percent)));
  }

  Future<int> completeSessionIfIncomplete(
      int sessionId, int completedEpochDay) async {
    return transaction(() async {
      final currentSessionId = await getCurrentSessionId();
      if (currentSessionId != sessionId) {
        return 0;
      }
      final query = update(workoutSessions)
        ..where(
            (tbl) => tbl.id.equals(sessionId) & tbl.completedEpochDay.isNull());
      return query.write(WorkoutSessionsCompanion(
          completedEpochDay: Value(completedEpochDay)));
    });
  }

  Future<int> archiveActiveGoals() {
    final query = update(goals)..where((tbl) => tbl.archived.equals(false));
    return query.write(const GoalsCompanion(archived: Value(true)));
  }

  Future<int?> maxLaterIncompleteDueEpochDay(
      int goalId, int sequenceIndex) async {
    final query = selectOnly(workoutSessions)
      ..addColumns([workoutSessions.dueEpochDay.max()])
      ..where(workoutSessions.goalId.equals(goalId) &
          workoutSessions.sequenceIndex.isBiggerThanValue(sequenceIndex) &
          workoutSessions.completedEpochDay.isNull());
    final row = await query.getSingle();
    return row.read(workoutSessions.dueEpochDay.max());
  }

  Future<int> shiftLaterIncompleteSessions(
      int goalId, int sequenceIndex, int delayDays) async {
    // Để shift dueEpochDay, chúng ta lấy tất cả sessions thỏa mãn điều kiện
    // và update từng do SQLite update với arithmetic expressions trong Drift có thể hơi phức tạp.
    // Cách an toàn và trực quan nhất là lấy các sessions đó ra, tính toán và update từng session.
    return transaction(() async {
      final list = await (select(workoutSessions)
            ..where((tbl) =>
                tbl.goalId.equals(goalId) &
                tbl.sequenceIndex.isBiggerThanValue(sequenceIndex) &
                tbl.completedEpochDay.isNull()))
          .get();

      int count = 0;
      for (final s in list) {
        final updated = await (update(workoutSessions)
              ..where((tbl) => tbl.id.equals(s.id)))
            .write(WorkoutSessionsCompanion(
                dueEpochDay: Value(s.dueEpochDay + delayDays)));
        count += updated;
      }
      return count;
    });
  }
}
