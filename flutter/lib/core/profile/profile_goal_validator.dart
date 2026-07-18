import '../model/goal_models.dart';
import '../model/profile_models.dart';

class ProfileGoalValidator {
  static List<String> validate({
    required PersonalProfile profile,
    required FitnessGoal fitnessGoal,
  }) {
    if (!profile.currentWeightKg.isFinite || !profile.targetWeightKg.isFinite) {
      return const [];
    }

    switch (fitnessGoal) {
      case FitnessGoal.muscleGain:
        if (profile.targetWeightKg <= profile.currentWeightKg) {
          return const ["Mục tiêu tăng cơ cần cân nặng mục tiêu cao hơn cân nặng hiện tại."];
        }
        return const [];
      case FitnessGoal.fatLossConditioning:
        if (profile.targetWeightKg >= profile.currentWeightKg) {
          return const ["Mục tiêu giảm mỡ cần cân nặng mục tiêu thấp hơn cân nặng hiện tại."];
        }
        return const [];
      case FitnessGoal.endurance:
      case FitnessGoal.generalFitness:
        return const [];
    }
  }
}
