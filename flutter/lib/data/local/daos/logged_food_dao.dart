import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/logged_foods.dart';

part 'logged_food_dao.g.dart';

@DriftAccessor(tables: [LoggedFoods])
class LoggedFoodDao extends DatabaseAccessor<GymDatabase>
    with _$LoggedFoodDaoMixin {
  LoggedFoodDao(super.db);

  Future<int> insert(LoggedFoodsCompanion loggedFood) {
    return into(loggedFoods)
        .insert(loggedFood, mode: InsertMode.insertOrReplace);
  }

  Future<void> insertAll(List<LoggedFoodsCompanion> loggedFoodsList) async {
    await batch((b) {
      for (final f in loggedFoodsList) {
        b.insert(loggedFoods, f, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<LoggedFoodData?> getById(int id) {
    final query = select(loggedFoods)
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> deleteLoggedFood(int id) {
    final query = delete(loggedFoods)..where((tbl) => tbl.id.equals(id));
    return query.go();
  }

  Stream<List<LoggedFoodData>> observeDay(int epochDay) {
    final query = select(loggedFoods)
      ..where((tbl) => tbl.epochDay.equals(epochDay))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]);
    return query.watch();
  }

  Future<List<LoggedFoodData>> dayNow(int epochDay) {
    final query = select(loggedFoods)
      ..where((tbl) => tbl.epochDay.equals(epochDay))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]);
    return query.get();
  }

  Stream<List<LoggedFoodData>> observeRecentFoods(int limit) {
    final query = select(loggedFoods)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)])
      ..limit(limit);
    return query.watch();
  }

  Future<List<LoggedFoodData>> recentFoodsNow(int limit) {
    final query = select(loggedFoods)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)])
      ..limit(limit);
    return query.get();
  }

  Future<int> deleteAll() {
    return delete(loggedFoods).go();
  }
}
