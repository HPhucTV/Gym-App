import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/goal_models.dart';
import 'package:gym_app/core/program/training_schedule.dart';

void main() {
  group('TrainingScheduleTest', () {
    test('accepts one through six unique training days', () {
      for (var count = 1; count <= 6; count++) {
        final days = WeekDay.values.take(count).toSet();
        TrainingSchedule.validate(days, 60);
      }
    });

    test('rejects zero and seven training days', () {
      expect(() => TrainingSchedule.validate(const {}, 60), throwsArgumentError);
      expect(() => TrainingSchedule.validate(WeekDay.values.toSet(), 60), throwsArgumentError);
    });

    test('accepts only reviewed duration buckets', () {
      final day = {WeekDay.monday};
      for (final minutes in const [30, 45, 60, 75, 90]) {
        TrainingSchedule.validate(day, minutes);
      }
      for (final minutes in const [29, 35, 120]) {
        expect(() => TrainingSchedule.validate(day, minutes), throwsArgumentError);
      }
    });

    test('legacy defaults are deterministic and evenly distributed', () {
      expect(TrainingSchedule.defaultDays(1), equals({WeekDay.monday}));
      expect(TrainingSchedule.defaultDays(2), equals({WeekDay.monday, WeekDay.thursday}));
      expect(TrainingSchedule.defaultDays(3), equals({WeekDay.monday, WeekDay.wednesday, WeekDay.friday}));
      expect(TrainingSchedule.defaultDays(6).length, equals(6));
    });
  });
}
