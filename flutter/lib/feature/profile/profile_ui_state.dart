import '../../core/model/profile_models.dart';

sealed class ProfileUiState {}

class ProfileUiStateLoading extends ProfileUiState {}

class ProfileUiStateContent extends ProfileUiState {
  final int birthDateEpochDay;
  final MetabolicSex metabolicSex;
  final String heightCmStr;
  final String currentWeightKgStr;
  final String targetWeightKgStr;
  final ActivityLevel activityLevel;
  final GoalPace goalPace;
  final bool personalizationConsent;
  final bool cloudAiConsent;
  final bool isSaving;
  final String? saveError;
  final bool success;
  final List<String> validationErrors;

  ProfileUiStateContent({
    required this.birthDateEpochDay,
    required this.metabolicSex,
    required this.heightCmStr,
    required this.currentWeightKgStr,
    required this.targetWeightKgStr,
    required this.activityLevel,
    required this.goalPace,
    required this.personalizationConsent,
    required this.cloudAiConsent,
    this.isSaving = false,
    this.saveError,
    this.success = false,
    this.validationErrors = const [],
  });

  ProfileUiStateContent copyWith({
    int? birthDateEpochDay,
    MetabolicSex? metabolicSex,
    String? heightCmStr,
    String? currentWeightKgStr,
    String? targetWeightKgStr,
    ActivityLevel? activityLevel,
    GoalPace? goalPace,
    bool? personalizationConsent,
    bool? cloudAiConsent,
    bool? isSaving,
    String? saveError,
    bool? success,
    List<String>? validationErrors,
  }) {
    return ProfileUiStateContent(
      birthDateEpochDay: birthDateEpochDay ?? this.birthDateEpochDay,
      metabolicSex: metabolicSex ?? this.metabolicSex,
      heightCmStr: heightCmStr ?? this.heightCmStr,
      currentWeightKgStr: currentWeightKgStr ?? this.currentWeightKgStr,
      targetWeightKgStr: targetWeightKgStr ?? this.targetWeightKgStr,
      activityLevel: activityLevel ?? this.activityLevel,
      goalPace: goalPace ?? this.goalPace,
      personalizationConsent: personalizationConsent ?? this.personalizationConsent,
      cloudAiConsent: cloudAiConsent ?? this.cloudAiConsent,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError,
      success: success ?? this.success,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}
