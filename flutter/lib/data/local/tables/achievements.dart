import 'package:drift/drift.dart';

@DataClassName('Achievement')
class Achievements extends Table {
  TextColumn get type => text()();
  IntColumn get unlockedAtEpochMillis => integer()();

  @override
  Set<Column> get primaryKey => {type};
}
