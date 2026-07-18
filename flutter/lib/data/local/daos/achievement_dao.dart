import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/achievements.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<GymDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  Stream<List<Achievement>> observeAll() {
    final query = select(achievements)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.unlockedAtEpochMillis)]);
    return query.watch();
  }

  Future<List<Achievement>> getAll() {
    final query = select(achievements)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.unlockedAtEpochMillis)]);
    return query.get();
  }

  Future<Achievement?> getByType(String type) {
    final query = select(achievements)
      ..where((tbl) => tbl.type.equals(type))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> insert(AchievementsCompanion achievement) {
    return into(achievements)
        .insert(achievement, mode: InsertMode.insertOrIgnore);
  }
}
