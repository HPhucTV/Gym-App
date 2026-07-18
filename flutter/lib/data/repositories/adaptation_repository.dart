import '../../core/model/adaptation_models.dart';

abstract class DecisionActionResult {}

class DecisionActionResultSuccess extends DecisionActionResult {}

class DecisionActionResultNotFound extends DecisionActionResult {
  final int id;
  DecisionActionResultNotFound(this.id);
}

class DecisionActionResultInvalidState extends DecisionActionResult {
  final AdaptationStatus currentStatus;
  final AdaptationStatus expectedStatus;
  DecisionActionResultInvalidState(
      {required this.currentStatus, required this.expectedStatus});
}

class DecisionActionResultStale extends DecisionActionResult {
  final String reason;
  DecisionActionResultStale(this.reason);
}

abstract class AdaptationRepository {
  Stream<List<AdaptationDecisionData>> observeDecisions();
  Future<int> recordDecision(AdaptationDecision decision);
  Future<DecisionActionResult> acceptDecision(int decisionId);
  Future<DecisionActionResult> rejectDecision(int decisionId);
  Future<DecisionActionResult> undoLatestDecision(AdaptationKind kind);
}
