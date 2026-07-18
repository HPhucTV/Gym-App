import 'package:drift/drift.dart';

@DataClassName('FoodCatalogData')
class FoodCatalog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get gramsPerServing => real().withDefault(const Constant(100.0))();
  RealColumn get caloriesPerServing => real().withDefault(const Constant(0.0))();
  RealColumn get fatPerServing => real().withDefault(const Constant(0.0))();
  RealColumn get carbsPerServing => real().withDefault(const Constant(0.0))();
  RealColumn get proteinPerServing => real().withDefault(const Constant(0.0))();
  RealColumn get potassiumMg => real().withDefault(const Constant(0.0))();
  RealColumn get sodiumMg => real().withDefault(const Constant(0.0))();
  RealColumn get cholesterolMg => real().withDefault(const Constant(0.0))();
  RealColumn get fiberPerServing => real().withDefault(const Constant(0.0))();
  TextColumn get importBatchId => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}
