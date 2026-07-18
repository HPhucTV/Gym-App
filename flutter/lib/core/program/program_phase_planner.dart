enum ProgramPhase {
  foundation,
  build,
  consolidate,
  deload,
}

class ProgramPhasePlanner {
  static ProgramPhase phaseFor(int week, int durationWeeks) {
    if (durationWeeks <= 0) {
      throw ArgumentError("Program duration must be positive.");
    }
    if (week < 1 || week > durationWeeks) {
      throw ArgumentError("Week must be within the program duration.");
    }
    
    if (durationWeeks >= 4 && week == durationWeeks) {
      return ProgramPhase.deload;
    }
    
    final progress = week / durationWeeks.toDouble();
    if (progress <= 0.25) {
      return ProgramPhase.foundation;
    } else if (progress <= 0.70) {
      return ProgramPhase.build;
    } else {
      return ProgramPhase.consolidate;
    }
  }
}
