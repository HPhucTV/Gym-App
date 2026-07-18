import 'package:drift/drift.dart';

@DataClassName('WeeklyCheckInData')
class WeeklyCheckIns extends Table {
  IntColumn get weekStartEpochDay => integer()();
  RealColumn get weightKg => real()();
  IntColumn get energy => integer()();
  IntColumn get hunger => integer()();
  IntColumn get recovery => integer()();
  IntColumn get sleepQuality => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtEpochMillis => integer()();

  @override
  Set<Column> get primaryKey => {weekStartEpochDay};
}
