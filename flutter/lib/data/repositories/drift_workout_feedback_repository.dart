import '../../core/model/feedback_models.dart';
import '../local/database.dart';
import '../local/daos/workout_dao.dart';
import '../local/daos/workout_feedback_dao.dart';
import 'workout_feedback_repository.dart';

class DriftWorkoutFeedbackRepository implements WorkoutFeedbackRepository {
  final GymDatabase database;
  final int Function() nowEpochMillis;

  DriftWorkoutFeedbackRepository({
    required this.database,
    required this.nowEpochMillis,
  });

  WorkoutFeedbackDao get feedbackDao => database.workoutFeedbackDao;
  WorkoutDao get workoutDao => database.workoutDao;

  @override
  Stream<List<WorkoutFeedback>> observeForGoal(int goalId) {
    return feedbackDao.observeForGoal(goalId).map((rows) {
      return rows
          .map((r) => WorkoutFeedback(
                sessionId: r.sessionId,
                goalId: r.goalId,
                completedEpochDay: r.completedEpochDay,
                difficulty: r.difficulty,
                recordedAtEpochMillis: r.recordedAtEpochMillis,
              ))
          .toList();
    });
  }

  @override
  Future<void> save({
    required int sessionId,
    required int goalId,
    required int completedEpochDay,
    required WorkoutDifficulty difficulty,
  }) async {
    await database.transaction(() async {
      final session = await workoutDao.getSession(sessionId);
      if (session == null) {
        throw StateError('Workout session $sessionId does not exist.');
      }
      if (session.completedEpochDay == null) {
        throw StateError('Workout feedback requires a completed session.');
      }
      if (session.goalId != goalId) {
        throw ArgumentError(
            'Workout session $sessionId does not belong to goal $goalId.');
      }
      if (session.completedEpochDay != completedEpochDay) {
        throw ArgumentError(
            'Completion day does not match the stored workout session.');
      }

      await feedbackDao.upsert(
        WorkoutFeedbackData(
          sessionId: sessionId,
          goalId: goalId,
          completedEpochDay: completedEpochDay,
          difficulty: difficulty,
          recordedAtEpochMillis: nowEpochMillis(),
        ),
      );
    });
  }
}
