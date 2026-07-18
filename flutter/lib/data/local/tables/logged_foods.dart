import 'package:drift/drift.dart';

@DataClassName('LoggedFoodData')
class LoggedFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get epochDay => integer()();
  TextColumn get name => text()();
  TextColumn get mealTime => text()(); // BREAKFAST, LUNCH, DINNER, SNACK
  RealColumn get grams => real()();
  IntColumn get calories => integer()();
  IntColumn get proteinGrams => integer()();
  IntColumn get carbsGrams => integer()();
  IntColumn get fatGrams => integer()();
  IntColumn get fiberGrams => integer().withDefault(const Constant(0))();
  IntColumn get foodCatalogId => integer().nullable()();
  IntColumn get timestamp => integer()();
}
