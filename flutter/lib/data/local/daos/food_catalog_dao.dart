import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/food_catalog.dart';

part 'food_catalog_dao.g.dart';

@DriftAccessor(tables: [FoodCatalog])
class FoodCatalogDao extends DatabaseAccessor<GymDatabase>
    with _$FoodCatalogDaoMixin {
  FoodCatalogDao(super.db);

  Future<void> insertAll(List<FoodCatalogData> foods) async {
    await batch((b) {
      b.insertAll(foodCatalog, foods, mode: InsertMode.insertOrReplace);
    });
  }

  Stream<List<FoodCatalogData>> observeAll() {
    final query = select(foodCatalog)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Stream<List<FoodCatalogData>> searchByName(String query) {
    final queryLower = query.toLowerCase();
    final querySelect = select(foodCatalog)
      ..where((tbl) => tbl.name.lower().like('%$queryLower%'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return querySelect.watch();
  }

  Future<List<FoodCatalogData>> getAllNow() {
    final query = select(foodCatalog)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.get();
  }

  Future<int> deleteByBatch(String batchId) {
    final query = delete(foodCatalog)
      ..where((tbl) => tbl.importBatchId.equals(batchId));
    return query.go();
  }

  Future<int> deleteAll() {
    return delete(foodCatalog).go();
  }

  Future<int> countAll() async {
    final countExpr = foodCatalog.id.count();
    final query = selectOnly(foodCatalog)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Stream<int> observeCount() {
    final countExpr = foodCatalog.id.count();
    final query = selectOnly(foodCatalog)..addColumns([countExpr]);
    return query.watchSingle().map((row) => row.read(countExpr) ?? 0);
  }

  Future<int> toggleFavorite(int id, bool isFavorite) {
    final query = update(foodCatalog)..where((tbl) => tbl.id.equals(id));
    return query.write(FoodCatalogCompanion(isFavorite: Value(isFavorite)));
  }

  Stream<List<FoodCatalogData>> observeFavorites() {
    final query = select(foodCatalog)
      ..where((tbl) => tbl.isFavorite.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Stream<List<FoodCatalogData>> searchFavorites(String query) {
    final queryLower = query.toLowerCase();
    final querySelect = select(foodCatalog)
      ..where((tbl) =>
          tbl.isFavorite.equals(true) & tbl.name.lower().like('%$queryLower%'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return querySelect.watch();
  }
}
