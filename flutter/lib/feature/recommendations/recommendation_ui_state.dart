import '../../data/local/database.dart';

sealed class RecommendationUiState {}

class RecommendationUiStateLoading extends RecommendationUiState {}

class UiDecision {
  final AdaptationDecisionData entity;
  final String explanationText;
  final bool isUndoEligible;
  final bool isExplaining;

  UiDecision({
    required this.entity,
    required this.explanationText,
    required this.isUndoEligible,
    required this.isExplaining,
  });
}

class RecommendationUiStateSuccess extends RecommendationUiState {
  final List<UiDecision> decisions;
  final bool cloudAiConsent;

  RecommendationUiStateSuccess({
    required this.decisions,
    required this.cloudAiConsent,
  });
}
