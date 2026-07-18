import 'package:drift/drift.dart';

@DataClassName('MealTemplateData')
class MealTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameVi => text().customConstraint('NOT NULL UNIQUE COLLATE NOCASE')();
  IntColumn get calories => integer()();
  IntColumn get proteinGrams => integer()();
  IntColumn get carbsGrams => integer()();
  IntColumn get fatGrams => integer()();
  IntColumn get fiberGrams => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtEpochMillis => integer()();
}
