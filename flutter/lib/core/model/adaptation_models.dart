import 'package:freezed_annotation/freezed_annotation.dart';

part 'adaptation_models.freezed.dart';
part 'adaptation_models.g.dart';

enum AdaptationMode {
  @JsonValue('AUTO_APPLY')
  autoApply,
  @JsonValue('REQUIRES_CONFIRMATION')
  requiresConfirmation,
}

enum AdaptationStatus {
  @JsonValue('PROPOSED')
  proposed,
  @JsonValue('APPLIED')
  applied,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('UNDONE')
  undone,
}

enum AdaptationKind {
  @JsonValue('CALORIE_TARGET')
  calorieTarget,
  @JsonValue('MACRO_TARGET')
  macroTarget,
  @JsonValue('RECOVERY_DAY')
  recoveryDay,
  @JsonValue('WORKOUT_VOLUME')
  workoutVolume,
  @JsonValue('PROGRAM_CHANGE')
  programChange,
  @JsonValue('DELOAD_WEEK')
  deloadWeek,
}

@freezed
abstract class AdaptationDecision with _$AdaptationDecision {
  const factory AdaptationDecision({
    required AdaptationKind kind,
    required AdaptationMode mode,
    required String reasonVi,
    required String beforeValue,
    required String afterValue,
    required String undoPayload,
  }) = _AdaptationDecision;

  factory AdaptationDecision.fromJson(Map<String, dynamic> json) =>
      _$AdaptationDecisionFromJson(json);
}
