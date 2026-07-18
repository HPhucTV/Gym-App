import '../../data/remote/coach_review_client.dart';

class TodayCoachCoordinator {
  final CoachReviewClient client;

  TodayCoachCoordinator({required this.client});

  Future<String> review({
    required CoachReviewRequest request,
    required bool cloudAiConsent,
    required String localFallback,
  }) async {
    if (!cloudAiConsent) return localFallback;
    try {
      final result = await client.reviewToday(request);
      if (result != null && result.trim().isNotEmpty) {
        return result;
      }
      return localFallback;
    } catch (_) {
      return localFallback;
    }
  }
}
