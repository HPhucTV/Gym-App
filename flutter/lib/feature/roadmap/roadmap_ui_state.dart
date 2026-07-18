enum RoadmapSessionStatus {
  completed,
  active,
  locked,
}

class RoadmapSessionUi {
  final int sequenceIndex;
  final int week;
  final int sessionInWeek;
  final String titleVi;
  final String focusVi;
  final int estimatedMinutes;
  final RoadmapSessionStatus status;

  RoadmapSessionUi({
    required this.sequenceIndex,
    required this.week,
    required this.sessionInWeek,
    required this.titleVi,
    required this.focusVi,
    required this.estimatedMinutes,
    required this.status,
  });
}

sealed class RoadmapUiState {}

class RoadmapLoading extends RoadmapUiState {}

class RoadmapError extends RoadmapUiState {
  final String message;
  RoadmapError(this.message);
}

class RoadmapSuccess extends RoadmapUiState {
  final String programName;
  final List<RoadmapSessionUi> sessions;
  final int currentSequenceIndex;

  RoadmapSuccess({
    required this.programName,
    required this.sessions,
    required this.currentSequenceIndex,
  });
}
