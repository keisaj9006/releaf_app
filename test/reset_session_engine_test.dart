import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/relief/domain/models/breath_pattern.dart';
import 'package:releaf_app/features/relief/domain/models/reset_session_program.dart';

void main() {
  group('BreathPattern', () {
    test('4–4 pattern resolves inhale and exhale phases', () {
      const pattern = BreathPattern(
        inhaleSeconds: 4,
        exhaleSeconds: 4,
      );

      expect(pattern.cycleSeconds, 8);
      expect(pattern.hasHolds, isFalse);
      expect(
        pattern.frameAtElapsedSeconds(0).phase,
        BreathPhase.inhale,
      );
      expect(
        pattern.frameAtElapsedSeconds(3).phase,
        BreathPhase.inhale,
      );
      expect(
        pattern.frameAtElapsedSeconds(4).phase,
        BreathPhase.exhale,
      );
      expect(
        pattern.frameAtElapsedSeconds(7).phase,
        BreathPhase.exhale,
      );
      expect(
        pattern.frameAtElapsedSeconds(8).phase,
        BreathPhase.inhale,
      );
    });

    test('box pattern resolves all four phases', () {
      const pattern = BreathPattern(
        inhaleSeconds: 4,
        holdAfterInhaleSeconds: 4,
        exhaleSeconds: 4,
        holdAfterExhaleSeconds: 4,
      );

      expect(pattern.cycleSeconds, 16);
      expect(pattern.hasHolds, isTrue);
      expect(pattern.frameAtElapsedSeconds(0).phase, BreathPhase.inhale);
      expect(
        pattern.frameAtElapsedSeconds(4).phase,
        BreathPhase.holdAfterInhale,
      );
      expect(pattern.frameAtElapsedSeconds(8).phase, BreathPhase.exhale);
      expect(
        pattern.frameAtElapsedSeconds(12).phase,
        BreathPhase.holdAfterExhale,
      );
      expect(pattern.frameAtElapsedSeconds(16).phase, BreathPhase.inhale);
    });

    test('asymmetric 3–4 pattern preserves unequal timing', () {
      const pattern = BreathPattern(
        inhaleSeconds: 3,
        exhaleSeconds: 4,
      );

      expect(pattern.cycleSeconds, 7);
      expect(pattern.frameAtElapsedSeconds(2).phase, BreathPhase.inhale);
      expect(pattern.frameAtElapsedSeconds(3).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(6).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(7).phase, BreathPhase.inhale);
    });
  });

  group('ResetSessionProgram', () {
    test('guided program resolves uneven step durations', () {
      const program = ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Arrive here.',
            durationSeconds: 10,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice this.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance: 'Return here.',
            durationSeconds: 5,
          ),
        ],
      );

      expect(program.scriptedDurationSeconds, 35);
      expect(program.stepAtElapsedSeconds(0).label, 'Arrive');
      expect(program.stepAtElapsedSeconds(9).label, 'Arrive');
      expect(program.stepAtElapsedSeconds(10).label, 'Notice');
      expect(program.stepAtElapsedSeconds(29).label, 'Notice');
      expect(program.stepAtElapsedSeconds(30).label, 'Return');
      expect(program.stepAtElapsedSeconds(99).label, 'Return');
    });

    test('breathing program carries one canonical timing source', () {
      const pattern = BreathPattern(
        inhaleSeconds: 3,
        exhaleSeconds: 4,
        label: 'Longer exhale',
      );
      const program = ResetSessionProgram.breathing(
        breathPattern: pattern,
        steps: [
          ResetSessionStep(
            label: 'Rhythm',
            guidance: 'Follow the rhythm.',
            durationSeconds: 120,
          ),
        ],
      );

      expect(program.type, ResetProgramType.pacedBreathing);
      expect(program.breathPattern, same(pattern));
      expect(program.scriptedDurationSeconds, 120);
    });
  });
}
