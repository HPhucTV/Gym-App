import 'package:drift/drift.dart';
import '../converters.dart';

@DataClassName('PersonalProfileData')
class PersonalProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get birthDateEpochDay => integer()();
  TextColumn get metabolicSex => text().map(const MetabolicSexConverter())();
  RealColumn get heightCm => real()();
  RealColumn get currentWeightKg => real()();
  RealColumn get targetWeightKg => real()();
  TextColumn get activityLevel => text().map(const ActivityLevelConverter())();
  TextColumn get goalPace => text().map(const GoalPaceConverter())();
  BoolColumn get personalizationConsent => boolean()();
  BoolColumn get cloudAiConsent => boolean()();
  IntColumn get updatedAtEpochMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
