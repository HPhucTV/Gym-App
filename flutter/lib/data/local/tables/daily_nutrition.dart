import 'package:drift/drift.dart';

@DataClassName('DailyNutritionData')
class DailyNutritions extends Table {
  IntColumn get epochDay => integer()();
  IntColumn get consumedCalories => integer().withDefault(const Constant(0))();
  IntColumn get consumedProteinGrams => integer().withDefault(const Constant(0))();
  IntColumn get consumedCarbsGrams => integer().withDefault(const Constant(0))();
  IntColumn get consumedFatGrams => integer().withDefault(const Constant(0))();
  IntColumn get consumedFiberGrams => integer().withDefault(const Constant(0))();
  IntColumn get targetBasalCalories => integer().nullable()();
  IntColumn get targetMaintenanceCalories => integer().nullable()();
  IntColumn get targetCalories => integer().nullable()();
  IntColumn get targetProteinGrams => integer().nullable()();
  IntColumn get targetCarbsGrams => integer().nullable()();
  IntColumn get targetFatGrams => integer().nullable()();
  TextColumn get lastEntrySource => text().nullable()();
  IntColumn get waterIntakeMl => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtEpochMillis => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {epochDay};
}
