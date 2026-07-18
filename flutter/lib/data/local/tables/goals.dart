import 'package:drift/drift.dart';
import '../converters.dart';

@DataClassName('Goal')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get programId => text()();
  TextColumn get goal => text().map(const FitnessGoalConverter())();
  TextColumn get goalsCsv => text().withDefault(const Constant(''))();
  TextColumn get gender =>
      text().map(const GenderConverter()).withDefault(const Constant('MALE'))();
  TextColumn get bodyType => text()
      .map(const BodyTypeConverter())
      .withDefault(const Constant('MESOMORPH'))();
  TextColumn get level => text().map(const ExperienceLevelConverter())();
  TextColumn get equipmentProfile =>
      text().map(const EquipmentProfileConverter())();
  IntColumn get sessionsPerWeek => integer()();
  IntColumn get durationWeeks => integer()();
  TextColumn get restDayMode => text().map(const RestDayModeConverter())();
  IntColumn get trainingDaysMask => integer().withDefault(const Constant(1))();
  IntColumn get sessionDurationMinutes =>
      integer().withDefault(const Constant(45))();
  IntColumn get createdEpochDay => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}
