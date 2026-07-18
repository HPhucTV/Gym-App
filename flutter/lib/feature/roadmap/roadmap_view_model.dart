import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/goal_models.dart';
import '../../core/model/workout_models.dart';
import '../../core/program/program_selector.dart';
import '../../data/providers/data_providers.dart';
import 'roadmap_ui_state.dart';

final roadmapActiveGoalProvider = StreamProvider<ActiveGoal?>((ref) {
  return ref.watch(workoutRepositoryProvider).observeActiveGoal();
});

final roadmapCurrentWorkoutProvider = StreamProvider<WorkoutSession?>((ref) {
  return ref.watch(workoutRepositoryProvider).observeCurrentWorkout();
});

final roadmapUiStateProvider = Provider<RoadmapUiState>((ref) {
  final activeGoalAsync = ref.watch(roadmapActiveGoalProvider);
  final currentWorkoutAsync = ref.watch(roadmapCurrentWorkoutProvider);
  final catalogRepo = ref.watch(assetCatalogRepositoryProvider);

  final activeGoal = activeGoalAsync.value;
  final currentWorkout = currentWorkoutAsync.value;

  if (activeGoalAsync.isLoading || currentWorkoutAsync.isLoading) {
    return RoadmapLoading();
  }

  if (activeGoal == null) {
    return RoadmapError("Không tìm thấy mục tiêu đang hoạt động.");
  }

  final config = activeGoal.config;
  final programs = catalogRepo.programs;
  final selection = ProgramSelector.select(config, programs);

  if (selection is ProgramSelectionUnsupported) {
    return RoadmapError(
        "Không tìm thấy chương trình tập luyện phù hợp với cấu hình của bạn.");
  }

  final program = (selection as ProgramSelectionFound).program;
  const maxSeq = 999999;
  final currentSeq = currentWorkout?.sequenceIndex ?? maxSeq;

  final sessions = program.workouts.map((workout) {
    final status = () {
      if (workout.sequence < currentSeq) {
        return RoadmapSessionStatus.completed;
      } else if (workout.sequence == currentSeq) {
        return RoadmapSessionStatus.active;
      } else {
        return RoadmapSessionStatus.locked;
      }
    }();

    final sessionInWeek = program.workouts
        .where((w) => w.week == workout.week && w.sequence <= workout.sequence)
        .length;

    return RoadmapSessionUi(
      sequenceIndex: workout.sequence,
      week: workout.week,
      sessionInWeek: sessionInWeek,
      titleVi: workout.titleVi,
      focusVi: workout.focusVi,
      estimatedMinutes: workout.estimatedMinutes,
      status: status,
    );
  }).toList();

  final goalText = () {
    switch (config.goal) {
      case FitnessGoal.muscleGain:
        return "Tăng Cơ Bắp (Muscle Gain)";
      case FitnessGoal.fatLossConditioning:
        return "Giảm Mỡ & Thể Lực (Fat Loss & Conditioning)";
      case FitnessGoal.endurance:
        return "Sức Bền (Endurance)";
      case FitnessGoal.generalFitness:
        return "Thể Chất Chung (General Fitness)";
    }
  }();

  final levelText = () {
    switch (config.level) {
      case ExperienceLevel.beginner:
        return "Cơ bản";
      case ExperienceLevel.intermediate:
        return "Trung cấp";
    }
  }();

  final programName = "$goalText - Cấp độ $levelText";

  return RoadmapSuccess(
    programName: programName,
    sessions: sessions,
    currentSequenceIndex: currentSeq == maxSeq ? -1 : currentSeq,
  );
});
