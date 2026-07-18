import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/adaptation_models.dart';
import '../../data/local/database.dart';
import '../../data/providers/data_providers.dart';
import '../../data/providers/remote_providers.dart';
import 'recommendation_ui_state.dart';

final decisionsStreamProvider = StreamProvider<List<AdaptationDecisionData>>((ref) {
  return ref.watch(adaptationRepositoryProvider).observeDecisions();
});

final profileStreamProvider = StreamProvider<PersonalProfileData?>((ref) {
  return ref.watch(gymDatabaseProvider).personalizationDao.observeProfile();
});

class RecommendationNotifier extends Notifier<RecommendationUiState> {
  final Map<int, String> _aiExplanations = {};
  final Set<int> _loadingAiExplanations = {};

  @override
  RecommendationUiState build() {
    final decisionsAsync = ref.watch(decisionsStreamProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    if (decisionsAsync.isLoading || profileAsync.isLoading) {
      return RecommendationUiStateLoading();
    }

    final decisions = decisionsAsync.value ?? const [];
    final profile = profileAsync.value;

    if (profile == null) {
      return RecommendationUiStateSuccess(decisions: const [], cloudAiConsent: false);
    }

    final uiDecisions = decisions.map((entity) {
      final isUndoEligible = _checkIfUndoEligible(entity, decisions);
      final aiExp = _aiExplanations[entity.id];

      if (profile.cloudAiConsent &&
          aiExp == null &&
          !_loadingAiExplanations.contains(entity.id) &&
          entity.status == AdaptationStatus.proposed) {
        _fetchAiExplanation(entity);
      }

      return UiDecision(
        entity: entity,
        explanationText: aiExp ?? entity.reasonVi,
        isUndoEligible: isUndoEligible,
        isExplaining: _loadingAiExplanations.contains(entity.id),
      );
    }).toList();

    return RecommendationUiStateSuccess(
      decisions: uiDecisions,
      cloudAiConsent: profile.cloudAiConsent,
    );
  }

  bool _checkIfUndoEligible(
    AdaptationDecisionData entity,
    List<AdaptationDecisionData> allDecisions,
  ) {
    if (entity.status != AdaptationStatus.applied) return false;
    final newerApplied = allDecisions.any((it) =>
        it.kind == entity.kind &&
        it.id != entity.id &&
        it.createdAtEpochMillis > entity.createdAtEpochMillis &&
        it.status == AdaptationStatus.applied);
    return !newerApplied;
  }

  void _fetchAiExplanation(AdaptationDecisionData entity) async {
    _loadingAiExplanations.add(entity.id);
    ref.notifyListeners();

    try {
      final explanation = await ref.read(coachExplanationClientProvider).explainDecision(
        kind: entity.kind,
        reasonVi: entity.reasonVi,
        beforeValue: entity.beforeJson,
        afterValue: entity.afterJson,
      );
      if (explanation != null) {
        _aiExplanations[entity.id] = explanation;
      }
    } catch (_) {
      // Ignore network errors, fallback to default
    } finally {
      _loadingAiExplanations.remove(entity.id);
      ref.notifyListeners();
    }
  }

  void acceptDecision(int id) async {
    await ref.read(adaptationRepositoryProvider).acceptDecision(id);
  }

  void rejectDecision(int id) async {
    await ref.read(adaptationRepositoryProvider).rejectDecision(id);
  }

  void undoDecision(AdaptationKind kind) async {
    await ref.read(adaptationRepositoryProvider).undoLatestDecision(kind);
  }
}

final recommendationNotifierProvider = NotifierProvider<RecommendationNotifier, RecommendationUiState>(RecommendationNotifier.new);
