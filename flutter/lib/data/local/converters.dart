import 'package:drift/drift.dart';
import '../../core/model/goal_models.dart';
import '../../core/model/profile_models.dart';
import '../../core/model/adaptation_models.dart';
import '../../core/model/feedback_models.dart';

class FitnessGoalConverter extends TypeConverter<FitnessGoal, String> {
  const FitnessGoalConverter();

  @override
  FitnessGoal fromSql(String dbValue) {
    switch (dbValue) {
      case 'MUSCLE_GAIN':
        return FitnessGoal.muscleGain;
      case 'FAT_LOSS_CONDITIONING':
        return FitnessGoal.fatLossConditioning;
      case 'ENDURANCE':
        return FitnessGoal.endurance;
      case 'GENERAL_FITNESS':
        return FitnessGoal.generalFitness;
      default:
        return FitnessGoal.generalFitness;
    }
  }

  @override
  String toSql(FitnessGoal value) {
    switch (value) {
      case FitnessGoal.muscleGain:
        return 'MUSCLE_GAIN';
      case FitnessGoal.fatLossConditioning:
        return 'FAT_LOSS_CONDITIONING';
      case FitnessGoal.endurance:
        return 'ENDURANCE';
      case FitnessGoal.generalFitness:
        return 'GENERAL_FITNESS';
    }
  }
}

class ExperienceLevelConverter extends TypeConverter<ExperienceLevel, String> {
  const ExperienceLevelConverter();

  @override
  ExperienceLevel fromSql(String dbValue) {
    switch (dbValue) {
      case 'BEGINNER':
        return ExperienceLevel.beginner;
      case 'INTERMEDIATE':
        return ExperienceLevel.intermediate;
      default:
        return ExperienceLevel.beginner;
    }
  }

  @override
  String toSql(ExperienceLevel value) {
    switch (value) {
      case ExperienceLevel.beginner:
        return 'BEGINNER';
      case ExperienceLevel.intermediate:
        return 'INTERMEDIATE';
    }
  }
}

class EquipmentProfileConverter extends TypeConverter<EquipmentProfile, String> {
  const EquipmentProfileConverter();

  @override
  EquipmentProfile fromSql(String dbValue) {
    switch (dbValue) {
      case 'BODYWEIGHT_ONLY':
        return EquipmentProfile.bodyweightOnly;
      case 'DUMBBELLS':
        return EquipmentProfile.dumbbells;
      case 'RESISTANCE_BANDS':
        return EquipmentProfile.resistanceBands;
      case 'FULL_GYM':
        return EquipmentProfile.fullGym;
      default:
        return EquipmentProfile.bodyweightOnly;
    }
  }

  @override
  String toSql(EquipmentProfile value) {
    switch (value) {
      case EquipmentProfile.bodyweightOnly:
        return 'BODYWEIGHT_ONLY';
      case EquipmentProfile.dumbbells:
        return 'DUMBBELLS';
      case EquipmentProfile.resistanceBands:
        return 'RESISTANCE_BANDS';
      case EquipmentProfile.fullGym:
        return 'FULL_GYM';
    }
  }
}

class RestDayModeConverter extends TypeConverter<RestDayMode, String> {
  const RestDayModeConverter();

  @override
  RestDayMode fromSql(String dbValue) {
    switch (dbValue) {
      case 'FULL_REST':
        return RestDayMode.fullRest;
      case 'LIGHT_RECOVERY':
        return RestDayMode.lightRecovery;
      default:
        return RestDayMode.fullRest;
    }
  }

  @override
  String toSql(RestDayMode value) {
    switch (value) {
      case RestDayMode.fullRest:
        return 'FULL_REST';
      case RestDayMode.lightRecovery:
        return 'LIGHT_RECOVERY';
    }
  }
}

class GenderConverter extends TypeConverter<Gender, String> {
  const GenderConverter();

  @override
  Gender fromSql(String dbValue) {
    switch (dbValue) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  @override
  String toSql(Gender value) {
    switch (value) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
    }
  }
}

class BodyTypeConverter extends TypeConverter<BodyType, String> {
  const BodyTypeConverter();

  @override
  BodyType fromSql(String dbValue) {
    switch (dbValue) {
      case 'ECTOMORPH':
        return BodyType.ectomorph;
      case 'MESOMORPH':
        return BodyType.mesomorph;
      case 'ENDOMORPH':
        return BodyType.endomorph;
      default:
        return BodyType.mesomorph;
    }
  }

  @override
  String toSql(BodyType value) {
    switch (value) {
      case BodyType.ectomorph:
        return 'ECTOMORPH';
      case BodyType.mesomorph:
        return 'MESOMORPH';
      case BodyType.endomorph:
        return 'ENDOMORPH';
    }
  }
}

class MetabolicSexConverter extends TypeConverter<MetabolicSex, String> {
  const MetabolicSexConverter();

  @override
  MetabolicSex fromSql(String dbValue) {
    switch (dbValue) {
      case 'MALE':
        return MetabolicSex.male;
      case 'FEMALE':
        return MetabolicSex.female;
      default:
        return MetabolicSex.male;
    }
  }

  @override
  String toSql(MetabolicSex value) {
    switch (value) {
      case MetabolicSex.male:
        return 'MALE';
      case MetabolicSex.female:
        return 'FEMALE';
    }
  }
}

class ActivityLevelConverter extends TypeConverter<ActivityLevel, String> {
  const ActivityLevelConverter();

  @override
  ActivityLevel fromSql(String dbValue) {
    switch (dbValue) {
      case 'SEDENTARY':
        return ActivityLevel.sedentary;
      case 'LIGHT':
        return ActivityLevel.light;
      case 'MODERATE':
        return ActivityLevel.moderate;
      case 'HIGH':
        return ActivityLevel.high;
      default:
        return ActivityLevel.sedentary;
    }
  }

  @override
  String toSql(ActivityLevel value) {
    switch (value) {
      case ActivityLevel.sedentary:
        return 'SEDENTARY';
      case ActivityLevel.light:
        return 'LIGHT';
      case ActivityLevel.moderate:
        return 'MODERATE';
      case ActivityLevel.high:
        return 'HIGH';
    }
  }
}

class GoalPaceConverter extends TypeConverter<GoalPace, String> {
  const GoalPaceConverter();

  @override
  GoalPace fromSql(String dbValue) {
    switch (dbValue) {
      case 'MILD':
        return GoalPace.mild;
      case 'STANDARD':
        return GoalPace.standard;
      case 'AGGRESSIVE':
        return GoalPace.aggressive;
      default:
        return GoalPace.standard;
    }
  }

  @override
  String toSql(GoalPace value) {
    switch (value) {
      case GoalPace.mild:
        return 'MILD';
      case GoalPace.standard:
        return 'STANDARD';
      case GoalPace.aggressive:
        return 'AGGRESSIVE';
    }
  }
}

class AdaptationKindConverter extends TypeConverter<AdaptationKind, String> {
  const AdaptationKindConverter();

  @override
  AdaptationKind fromSql(String dbValue) {
    switch (dbValue) {
      case 'CALORIE_TARGET':
        return AdaptationKind.calorieTarget;
      case 'MACRO_TARGET':
        return AdaptationKind.macroTarget;
      case 'RECOVERY_DAY':
        return AdaptationKind.recoveryDay;
      case 'WORKOUT_VOLUME':
        return AdaptationKind.workoutVolume;
      case 'PROGRAM_CHANGE':
        return AdaptationKind.programChange;
      case 'DELOAD_WEEK':
        return AdaptationKind.deloadWeek;
      default:
        return AdaptationKind.workoutVolume;
    }
  }

  @override
  String toSql(AdaptationKind value) {
    switch (value) {
      case AdaptationKind.calorieTarget:
        return 'CALORIE_TARGET';
      case AdaptationKind.macroTarget:
        return 'MACRO_TARGET';
      case AdaptationKind.recoveryDay:
        return 'RECOVERY_DAY';
      case AdaptationKind.workoutVolume:
        return 'WORKOUT_VOLUME';
      case AdaptationKind.programChange:
        return 'PROGRAM_CHANGE';
      case AdaptationKind.deloadWeek:
        return 'DELOAD_WEEK';
    }
  }
}

class AdaptationModeConverter extends TypeConverter<AdaptationMode, String> {
  const AdaptationModeConverter();

  @override
  AdaptationMode fromSql(String dbValue) {
    switch (dbValue) {
      case 'AUTO_APPLY':
        return AdaptationMode.autoApply;
      case 'REQUIRES_CONFIRMATION':
        return AdaptationMode.requiresConfirmation;
      default:
        return AdaptationMode.requiresConfirmation;
    }
  }

  @override
  String toSql(AdaptationMode value) {
    switch (value) {
      case AdaptationMode.autoApply:
        return 'AUTO_APPLY';
      case AdaptationMode.requiresConfirmation:
        return 'REQUIRES_CONFIRMATION';
    }
  }
}

class AdaptationStatusConverter extends TypeConverter<AdaptationStatus, String> {
  const AdaptationStatusConverter();

  @override
  AdaptationStatus fromSql(String dbValue) {
    switch (dbValue) {
      case 'PROPOSED':
        return AdaptationStatus.proposed;
      case 'APPLIED':
        return AdaptationStatus.applied;
      case 'REJECTED':
        return AdaptationStatus.rejected;
      case 'UNDONE':
        return AdaptationStatus.undone;
      default:
        return AdaptationStatus.proposed;
    }
  }

  @override
  String toSql(AdaptationStatus value) {
    switch (value) {
      case AdaptationStatus.proposed:
        return 'PROPOSED';
      case AdaptationStatus.applied:
        return 'APPLIED';
      case AdaptationStatus.rejected:
        return 'REJECTED';
      case AdaptationStatus.undone:
        return 'UNDONE';
    }
  }
}

class WorkoutDifficultyConverter extends TypeConverter<WorkoutDifficulty, String> {
  const WorkoutDifficultyConverter();

  @override
  WorkoutDifficulty fromSql(String dbValue) {
    switch (dbValue) {
      case 'EASY':
        return WorkoutDifficulty.easy;
      case 'RIGHT':
        return WorkoutDifficulty.right;
      case 'HARD':
        return WorkoutDifficulty.hard;
      default:
        return WorkoutDifficulty.right;
    }
  }

  @override
  String toSql(WorkoutDifficulty value) {
    switch (value) {
      case WorkoutDifficulty.easy:
        return 'EASY';
      case WorkoutDifficulty.right:
        return 'RIGHT';
      case WorkoutDifficulty.hard:
        return 'HARD';
    }
  }
}
