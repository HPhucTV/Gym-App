import 'package:drift/drift.dart';

@DataClassName('UserFoodOverrideData')
class UserFoodOverrides extends Table {
  TextColumn get dishName => text()();
  IntColumn get totalCalories => integer()();
  IntColumn get proteinGrams => integer()();
  IntColumn get carbsGrams => integer()();
  IntColumn get fatGrams => integer()();

  @override
  Set<Column> get primaryKey => {dishName};
}
