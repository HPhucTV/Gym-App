import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_models.freezed.dart';
part 'feedback_models.g.dart';

enum WorkoutDifficulty {
  @JsonValue('EASY')
  easy(-1),
  @JsonValue('RIGHT')
  right(0),
  @JsonValue('HARD')
  hard(1);

  final int score;
  const WorkoutDifficulty(this.score);
}

@freezed
abstract class WorkoutFeedback with _$WorkoutFeedback {
  const factory WorkoutFeedback({
    required int sessionId,
    required int goalId,
    required int completedEpochDay,
    required WorkoutDifficulty difficulty,
    required int recordedAtEpochMillis,
  }) = _WorkoutFeedback;

  factory WorkoutFeedback.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFeedbackFromJson(json);
}
