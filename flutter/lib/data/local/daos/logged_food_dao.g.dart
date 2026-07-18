// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_food_dao.dart';

// ignore_for_file: type=lint
mixin _$LoggedFoodDaoMixin on DatabaseAccessor<GymDatabase> {
  $LoggedFoodsTable get loggedFoods => attachedDatabase.loggedFoods;
  LoggedFoodDaoManager get managers => LoggedFoodDaoManager(this);
}

class LoggedFoodDaoManager {
  final _$LoggedFoodDaoMixin _db;
  LoggedFoodDaoManager(this._db);
  $$LoggedFoodsTableTableManager get loggedFoods =>
      $$LoggedFoodsTableTableManager(_db.attachedDatabase, _db.loggedFoods);
}
