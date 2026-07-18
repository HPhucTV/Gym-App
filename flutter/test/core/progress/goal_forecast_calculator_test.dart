import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/progress/goal_forecast_calculator.dart';

void main() {
  const maxInt = 9223372036854775807; // 2^63 - 1

  GoalForecast calculate({
    required int total,
    required int completed,
    int sessionsPerWeek = 3,
    int firstDue = 100,
    int finalDue = 160,
    int today = 121,
  }) {
    return GoalForecastCalculator.calculate(
      totalSessions: total,
      completedSessions: completed,
      sessionsPerWeek: sessionsPerWeek,
      firstDueEpochDay: firstDue,
      plannedFinalDueEpochDay: finalDue,
      todayEpochDay: today,
    );
  }

  test('no completions and invalid totals are insufficient', () {
    expect(calculate(total: 12, completed: 0), GoalForecastInsufficientData());
    expect(calculate(total: 0, completed: 0), GoalForecastInsufficientData());
    expect(calculate(total: -1, completed: 2), GoalForecastInsufficientData());
  });

  test('less than two elapsed weeks is insufficient', () {
    expect(
      calculate(total: 12, completed: 3, firstDue: 100, today: 113),
      GoalForecastInsufficientData(),
    );
  });

  test('projects on track from capped weekly rate', () {
    final forecast = calculate(
      total: 12,
      completed: 6,
      sessionsPerWeek: 3,
      firstDue: 100,
      finalDue: 160,
      today: 121,
    );

    expect(forecast, GoalForecastOnTrack(142));
  });

  test('marks at risk past planned end and reports sessions behind', () {
    final forecast = calculate(
      total: 12,
      completed: 2,
      sessionsPerWeek: 3,
      firstDue: 100,
      finalDue: 130,
      today: 128,
    );

    expect(forecast is GoalForecastAtRisk, isTrue);
    expect((forecast as GoalForecastAtRisk).sessionsBehind, 10);
  });

  test('past planned end still forecasts and full completion is complete', () {
    expect(
      calculate(total: 12, completed: 8, sessionsPerWeek: 3, firstDue: 100, finalDue: 120, today: 135) is GoalForecastAtRisk,
      isTrue,
    );
    expect(
      calculate(total: 12, completed: 12, sessionsPerWeek: 3, firstDue: 100, finalDue: 120, today: 135),
      GoalForecastComplete(),
    );
  });

  test('date overflow is rejected', () {
    expect(
      () => calculate(
        total: 12,
        completed: 2,
        sessionsPerWeek: 3,
        firstDue: maxInt - 30,
        finalDue: maxInt - 1,
        today: maxInt - 1,
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
