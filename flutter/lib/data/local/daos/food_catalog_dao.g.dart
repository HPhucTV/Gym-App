// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodCatalogDaoMixin on DatabaseAccessor<GymDatabase> {
  $FoodCatalogTable get foodCatalog => attachedDatabase.foodCatalog;
  FoodCatalogDaoManager get managers => FoodCatalogDaoManager(this);
}

class FoodCatalogDaoManager {
  final _$FoodCatalogDaoMixin _db;
  FoodCatalogDaoManager(this._db);
  $$FoodCatalogTableTableManager get foodCatalog =>
      $$FoodCatalogTableTableManager(_db.attachedDatabase, _db.foodCatalog);
}
