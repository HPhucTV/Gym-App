import 'package:drift/drift.dart';
import '../converters.dart';
import 'workout_sessions.dart';

@DataClassName('WorkoutFeedbackData')
class WorkoutFeedbacks extends Table {
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get goalId => integer()();
  IntColumn get completedEpochDay => integer()();
  TextColumn get difficulty => text().map(const WorkoutDifficultyConverter())();
  IntColumn get recordedAtEpochMillis => integer()();

  @override
  Set<Column> get primaryKey => {sessionId};
}
