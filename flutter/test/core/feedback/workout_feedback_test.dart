import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/feedback_models.dart';

void main() {
  test('rating score preserves easy right hard ordering', () {
    expect(WorkoutDifficulty.easy.score, -1);
    expect(WorkoutDifficulty.right.score, 0);
    expect(WorkoutDifficulty.hard.score, 1);
  });
}
