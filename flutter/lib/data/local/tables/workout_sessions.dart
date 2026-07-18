import 'package:drift/drift.dart';
import 'goals.dart';

@DataClassName('WorkoutSession')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequenceIndex => integer()();
  TextColumn get titleVi => text()();
  TextColumn get focusVi => text()();
  IntColumn get estimatedMinutes => integer()();
  IntColumn get dueEpochDay => integer()();
  IntColumn get completedEpochDay => integer().nullable()();
  IntColumn get volumeScalePercent => integer().withDefault(const Constant(100))();
  IntColumn get selectedTimeBudgetMinutes => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {goalId, sequenceIndex}
      ];
}
