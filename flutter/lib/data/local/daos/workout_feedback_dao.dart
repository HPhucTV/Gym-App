import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/workout_feedback.dart';
import '../tables/workout_sessions.dart';

part 'workout_feedback_dao.g.dart';

@DriftAccessor(tables: [WorkoutFeedbacks, WorkoutSessions])
class WorkoutFeedbackDao extends DatabaseAccessor<GymDatabase>
    with _$WorkoutFeedbackDaoMixin {
  WorkoutFeedbackDao(super.db);

  Stream<List<WorkoutFeedbackData>> observeForGoal(int goalId) {
    final query = select(workoutFeedbacks)
      ..where((tbl) => tbl.goalId.equals(goalId))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.completedEpochDay),
        (tbl) => OrderingTerm.desc(tbl.recordedAtEpochMillis)
      ]);
    return query.watch();
  }

  Future<WorkoutFeedbackData?> feedbackForSessionNow(int sessionId) {
    final query = select(workoutFeedbacks)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> upsert(WorkoutFeedbackData feedback) {
    return into(workoutFeedbacks).insertOnConflictUpdate(feedback);
  }
}
