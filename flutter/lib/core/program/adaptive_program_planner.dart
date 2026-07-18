import 'dart:math';
import '../model/catalog_models.dart';
import '../model/goal_models.dart';
import 'program_phase_planner.dart';
import 'training_schedule.dart';

class AdaptiveProgramPlanner {
  static List<WorkoutTemplate> adapt(
    ProgramTemplate program,
    GoalConfig config,
  ) {
    TrainingSchedule.validate(config.trainingDays, config.sessionDurationMinutes);
    if (config.sessionsPerWeek != config.trainingDays.length) {
      throw ArgumentError("Weekly frequency must equal selected training days");
    }

    // Lọc lấy các workouts của tuần đầu tiên (week nhỏ nhất)
    final minWeek = program.workouts.isNotEmpty
        ? program.workouts.map((w) => w.week).reduce(min)
        : 1;
    final firstWeekBlueprints = program.workouts.where((w) => w.week == minWeek).toList();
    firstWeekBlueprints.sort((a, b) => a.sequence.compareTo(b.sequence));

    final blueprints = firstWeekBlueprints.isNotEmpty
        ? firstWeekBlueprints
        : (List.of(program.workouts)..sort((a, b) => a.sequence.compareTo(b.sequence)));

    if (blueprints.isEmpty) {
      throw ArgumentError("Program must contain reviewed workout blueprints");
    }

    final workoutCount = config.sessionsPerWeek * config.durationWeeks;
    return List.generate(workoutCount, (sequence) {
      final week = sequence ~/ config.sessionsPerWeek + 1;
      final phase = ProgramPhasePlanner.phaseFor(week, config.durationWeeks);
      final blueprintIndex = sequence % blueprints.length;
      final blueprint = blueprints[blueprintIndex];

      // Lấy danh sách ứng viên bài tập đã xoay vòng và lọc trùng
      final candidatesList = _rotatedBlueprints(blueprints, blueprintIndex)
          .expand((w) => w.exercises)
          .toList();

      final seenIds = <String>{};
      final candidates = candidatesList.where((e) => seenIds.add(e.exerciseId)).toList();

      final selectedRaw = _fitOrdered(candidates, config.sessionDurationMinutes);
      final selected = selectedRaw
          .map((prescription) => prescription._forPhase(phase))
          .toList()
          ._trimToBudget(config.sessionDurationMinutes);

      final totalEstimated = selected
          .map(estimatedMinutes)
          .fold<int>(0, (sum, val) => sum + val);
      final estimated = min(totalEstimated, config.sessionDurationMinutes);

      return blueprint.copyWith(
        sequence: sequence,
        week: week,
        estimatedMinutes: estimated,
        restDaysAfter: 0,
        exercises: selected,
      );
    });
  }

  static List<WorkoutTemplate> _rotatedBlueprints(
    List<WorkoutTemplate> blueprints,
    int startIndex,
  ) {
    return List.generate(
      blueprints.length,
      (offset) => blueprints[(startIndex + offset) % blueprints.length],
    );
  }

  static List<ExercisePrescription> _fitOrdered(
    List<ExercisePrescription> candidates,
    int budgetMinutes,
  ) {
    if (candidates.isEmpty) {
      throw ArgumentError("Workout blueprint must contain exercises");
    }
    final selected = <ExercisePrescription>[];
    var used = 0;

    for (var prescription in candidates) {
      final cost = estimatedMinutes(prescription);
      if (selected.isEmpty || used + cost <= budgetMinutes) {
        selected.add(prescription);
        used += cost;
      }
    }
    return selected;
  }

  static int estimatedMinutes(ExercisePrescription prescription) {
    final int activeSecondsPerSet;
    if (prescription.durationSeconds != null) {
      activeSecondsPerSet = prescription.durationSeconds!;
    } else {
      final minReps = prescription.minReps ?? 1;
      final maxReps = prescription.maxReps ?? prescription.minReps ?? 1;
      activeSecondsPerSet = ((minReps + maxReps) ~/ 2) * 4;
    }

    final totalSeconds = prescription.sets * (activeSecondsPerSet + prescription.restSeconds);
    return (totalSeconds / 60.0).ceil().clamp(1, double.infinity).toInt();
  }
}

extension _ExercisePrescriptionAdapt on ExercisePrescription {
  ExercisePrescription _forPhase(ProgramPhase phase) {
    switch (phase) {
      case ProgramPhase.build:
        return sets >= 2 ? copyWith(sets: sets + 1) : this;
      case ProgramPhase.deload:
        return copyWith(sets: max(1, (sets * 0.7).floor()));
      case ProgramPhase.foundation:
      case ProgramPhase.consolidate:
        return this;
    }
  }
}

extension _ExercisePrescriptionListAdapt on List<ExercisePrescription> {
  List<ExercisePrescription> _trimToBudget(int budgetMinutes) {
    final selected = toList();
    while (selected.length > 1 &&
        selected.map(AdaptiveProgramPlanner.estimatedMinutes).fold<int>(0, (sum, val) => sum + val) > budgetMinutes) {
      selected.removeLast();
    }
    return selected;
  }
}
