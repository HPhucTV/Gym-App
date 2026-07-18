import 'package:drift/drift.dart';
import '../converters.dart';

@DataClassName('AdaptationDecisionData')
class AdaptationDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text().map(const AdaptationKindConverter())();
  TextColumn get mode => text().map(const AdaptationModeConverter())();
  TextColumn get status => text().map(const AdaptationStatusConverter())();
  TextColumn get reasonVi => text()();
  IntColumn get payloadVersion => integer()();
  TextColumn get inputsJson => text()();
  TextColumn get beforeJson => text()();
  TextColumn get afterJson => text()();
  TextColumn get undoJson => text()();
  IntColumn get createdAtEpochMillis => integer()();
  IntColumn get resolvedAtEpochMillis => integer().nullable()();
}
