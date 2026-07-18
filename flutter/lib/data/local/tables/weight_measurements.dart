import 'package:drift/drift.dart';

@DataClassName('WeightMeasurement')
class WeightMeasurements extends Table {
  IntColumn get epochDay => integer()();
  RealColumn get weightKg => real()();
  IntColumn get recordedAtEpochMillis => integer()();

  @override
  Set<Column> get primaryKey => {epochDay};
}
