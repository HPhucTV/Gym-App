import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_models.freezed.dart';
part 'goal_models.g.dart';

enum FitnessGoal {
  @JsonValue('MUSCLE_GAIN')
  muscleGain,
  @JsonValue('FAT_LOSS_CONDITIONING')
  fatLossConditioning,
  @JsonValue('ENDURANCE')
  endurance,
  @JsonValue('GENERAL_FITNESS')
  generalFitness,
}

enum ExperienceLevel {
  @JsonValue('BEGINNER')
  beginner,
  @JsonValue('INTERMEDIATE')
  intermediate,
}

enum EquipmentProfile {
  @JsonValue('BODYWEIGHT_ONLY')
  bodyweightOnly,
  @JsonValue('DUMBBELLS')
  dumbbells,
  @JsonValue('RESISTANCE_BANDS')
  resistanceBands,
  @JsonValue('FULL_GYM')
  fullGym,
}

enum RestDayMode {
  @JsonValue('FULL_REST')
  fullRest,
  @JsonValue('LIGHT_RECOVERY')
  lightRecovery,
}

enum Gender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
}

enum BodyType {
  @JsonValue('ECTOMORPH')
  ectomorph,
  @JsonValue('MESOMORPH')
  mesomorph,
  @JsonValue('ENDOMORPH')
  endomorph,
}

enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  int get value => index + 1;

  static WeekDay fromValue(int val) {
    return WeekDay.values[val - 1];
  }
}

@freezed
abstract class GoalConfig with _$GoalConfig {
  const factory GoalConfig({
    required FitnessGoal goal,
    required ExperienceLevel level,
    required EquipmentProfile equipmentProfile,
    required int sessionsPerWeek,
    required int durationWeeks,
    required RestDayMode restDayMode,
    required Set<WeekDay> trainingDays,
    @Default(45) int sessionDurationMinutes,
    required List<FitnessGoal> goals,
    @Default(Gender.male) Gender gender,
    @Default(BodyType.mesomorph) BodyType bodyType,
  }) = _GoalConfig;

  factory GoalConfig.fromJson(Map<String, dynamic> json) =>
      _$GoalConfigFromJson(json);
}

Set<WeekDay> defaultTrainingDays(int sessionsPerWeek) {
  switch (sessionsPerWeek) {
    case 1:
      return {WeekDay.monday};
    case 2:
      return {WeekDay.monday, WeekDay.thursday};
    case 3:
      return {WeekDay.monday, WeekDay.wednesday, WeekDay.friday};
    case 4:
      return {WeekDay.monday, WeekDay.tuesday, WeekDay.thursday, WeekDay.friday};
    case 5:
      return {
        WeekDay.monday,
        WeekDay.tuesday,
        WeekDay.wednesday,
        WeekDay.friday,
        WeekDay.saturday
      };
    case 6:
      return {
        WeekDay.monday,
        WeekDay.tuesday,
        WeekDay.wednesday,
        WeekDay.thursday,
        WeekDay.friday,
        WeekDay.saturday
      };
    default:
      return {};
  }
}

int trainingDaysMask(Set<WeekDay> days) {
  return days.fold(0, (mask, day) => mask | (1 << (day.value - 1)));
}

Set<WeekDay> trainingDaysFromMask(int mask) {
  final result = <WeekDay>{};
  for (var day in WeekDay.values) {
    if ((mask & (1 << (day.value - 1))) != 0) {
      result.add(day);
    }
  }
  return result;
}
