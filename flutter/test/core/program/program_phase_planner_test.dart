import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/program/program_phase_planner.dart';

void main() {
  group('ProgramPhasePlannerTest', () {
    test('eight week plan uses foundation build consolidate and deload phases',
        () {
      final phases =
          List.generate(8, (i) => ProgramPhasePlanner.phaseFor(i + 1, 8));

      expect(
        phases,
        equals(const [
          ProgramPhase.foundation,
          ProgramPhase.foundation,
          ProgramPhase.build,
          ProgramPhase.build,
          ProgramPhase.build,
          ProgramPhase.consolidate,
          ProgramPhase.consolidate,
          ProgramPhase.deload,
        ]),
      );
    });

    test('short plan does not force a deload week', () {
      expect(
        List.generate(1, (i) => ProgramPhasePlanner.phaseFor(i + 1, 1)),
        equals(const [ProgramPhase.consolidate]),
      );
      expect(
        List.generate(3, (i) => ProgramPhasePlanner.phaseFor(i + 1, 3)),
        equals(const [
          ProgramPhase.build,
          ProgramPhase.build,
          ProgramPhase.consolidate
        ]),
      );
    });

    test('phase rejects a week outside program duration', () {
      expect(() => ProgramPhasePlanner.phaseFor(0, 8), throwsArgumentError);
      expect(() => ProgramPhasePlanner.phaseFor(9, 8), throwsArgumentError);
    });
  });
}
