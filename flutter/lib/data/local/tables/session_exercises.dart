import 'package:drift/drift.dart';
import 'workout_sessions.dart';

@DataClassName('SessionExercise')
class SessionExercises extends Table {
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer()();
  TextColumn get exerciseId => text()();
  TextColumn get originalExerciseId => text().nullable()();
  IntColumn get sets => integer()();
  IntColumn get minReps => integer().nullable()();
  IntColumn get maxReps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get restSeconds => integer()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  BoolColumn get omittedByTimeBudget => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sessionId, orderIndex};
}
