import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/model/goal_models.dart';

part 'onboarding_ui_state.freezed.dart';

enum OnboardingStep {
  personalInfo,
  goal,
  level,
  equipment,
  trainingDays,
  sessionDuration,
  restBehavior,
  review,
}

class WorkoutCommitment {
  final int sessionsPerWeek;
  final int durationWeeks;

  const WorkoutCommitment({
    required this.sessionsPerWeek,
    required this.durationWeeks,
  });
}

@freezed
abstract class OnboardingDraft with _$OnboardingDraft {
  const factory OnboardingDraft({
    FitnessGoal? goal,
    @Default([]) List<FitnessGoal> goals,
    Gender? gender,
    BodyType? bodyType,
    ExperienceLevel? level,
    EquipmentProfile? equipment,
    int? sessionsPerWeek,
    int? durationWeeks,
    RestDayMode? restDayMode,
    @Default({}) Set<WeekDay> trainingDays,
    int? sessionDurationMinutes,
  }) = _OnboardingDraft;
}

@freezed
abstract class OnboardingOptions with _$OnboardingOptions {
  const factory OnboardingOptions({
    required Set<FitnessGoal> goals,
    required Set<ExperienceLevel> levels,
    required Set<EquipmentProfile> equipment,
    required Set<WorkoutCommitment> commitments,
    required Set<RestDayMode> restDayModes,
  }) = _OnboardingOptions;
}

@freezed
sealed class OnboardingUiState with _$OnboardingUiState {
  const factory OnboardingUiState.editing({
    required OnboardingStep step,
    required OnboardingDraft draft,
    required OnboardingOptions options,
    @Default(false) bool isSaving,
    String? saveError,
  }) = _Editing;

  const factory OnboardingUiState.unsupported({
    required OnboardingDraft draft,
    required String explanation,
    required List<String> alternatives,
  }) = _Unsupported;

  const factory OnboardingUiState.created() = _Created;
}
