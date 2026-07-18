import '../../core/model/feedback_models.dart';

abstract class WorkoutFeedbackRepository {
  Stream<List<WorkoutFeedback>> observeForGoal(int goalId);

  Future<void> save({
    required int sessionId,
    required int goalId,
    required int completedEpochDay,
    required WorkoutDifficulty difficulty,
  });
}
