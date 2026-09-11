import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/relief/domain/models/breath_pattern.dart';
import 'package:releaf_app/features/relief/domain/models/reset_session_program.dart';
import 'package:releaf_app/features/relief/domain/reset_voice_guidance.dart';

void main() {
  group('BreathPattern', () {
    test('4–4 pattern resolves inhale and exhale phases', () {
      const pattern = BreathPattern(inhaleSeconds: 4, exhaleSeconds: 4);

      expect(pattern.cycleSeconds, 8);
      expect(pattern.hasHolds, isFalse);
      expect(pattern.frameAtElapsedSeconds(0).phase, BreathPhase.inhale);
      expect(pattern.frameAtElapsedSeconds(3).phase, BreathPhase.inhale);
      expect(pattern.frameAtElapsedSeconds(4).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(7).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(8).phase, BreathPhase.inhale);
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
      const pattern = BreathPattern(inhaleSeconds: 3, exhaleSeconds: 4);

      expect(pattern.cycleSeconds, 7);
      expect(pattern.frameAtElapsedSeconds(2).phase, BreathPhase.inhale);
      expect(pattern.frameAtElapsedSeconds(3).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(6).phase, BreathPhase.exhale);
      expect(pattern.frameAtElapsedSeconds(7).phase, BreathPhase.inhale);
    });
  });

  group('Reset voice guidance', () {
    test('paced breathing keeps rejected cues and hold phases silent', () {
      const program = ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          holdAfterInhaleSeconds: 2,
          exhaleSeconds: 6,
          holdAfterExhaleSeconds: 2,
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance: 'Settle and keep the breath comfortable.',
            durationSeconds: 14,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance: 'Follow the four-part rhythm without forcing it.',
            durationSeconds: 92,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Release the count and breathe naturally.',
            durationSeconds: 14,
          ),
        ],
      );

      final settle = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 0,
        simplified: false,
      );
      final inhale = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 0,
        simplified: false,
      );
      final hold = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 32,
        simplified: false,
      );
      final exhale = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 34,
        simplified: false,
      );
      final rest = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 40,
        simplified: false,
      );
      expect(settle.key, 'breath:inhale');
      expect(settle.spokenText, isEmpty);
      expect(inhale.key, 'breath:inhale');
      expect(inhale.spokenText, isEmpty);
      expect(hold.spokenText, isEmpty);
      expect(hold.narrationAssetPath, isNull);
      expect(exhale.spokenText, isEmpty);
      expect(rest.spokenText, isEmpty);
      expect(rest.narrationAssetPath, isNull);
      expect(inhale.narrationAssetPath, isNull);
      expect(exhale.narrationAssetPath, isNull);
    });

    test('guided Reset keeps scripted step narration and recorded asset', () {
      const program = ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Settle in.',
            durationSeconds: 10,
            narrationAssetPath: 'narration/reset/arrive.mp3',
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice the room.',
            durationSeconds: 10,
          ),
        ],
      );

      final first = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 0,
        simplified: false,
      );
      final second = resetVoiceGuidanceCue(
        program: program,
        elapsedSeconds: 10,
        simplified: false,
      );

      expect(first.key, 'step:main:0');
      expect(first.spokenText, 'Settle in.');
      expect(first.narrationAssetPath, 'narration/reset/arrive.mp3');
      expect(second.key, 'step:main:1');
      expect(second.spokenText, 'Notice the room.');
    });

    test('breath cue paths are shared and hold phases are silent', () {
      expect(
        resetBreathPhaseTargetAssetPath(BreathPhase.inhale),
        'sounds/reset/breath-cues/inhale.mp3',
      );
      expect(
        resetBreathPhaseTargetAssetPath(BreathPhase.holdAfterInhale),
        isNull,
      );
      expect(
        resetBreathPhaseTargetAssetPath(BreathPhase.exhale),
        'sounds/reset/breath-cues/exhale.mp3',
      );
      expect(
        resetBreathPhaseTargetAssetPath(BreathPhase.holdAfterExhale),
        isNull,
      );
    });
  });

  test('Reset session steps may point to recorded narration assets', () {
    const step = ResetSessionStep(
      label: 'Arrive',
      guidance: 'Settle in.',
      durationSeconds: 10,
      narrationAssetPath: 'narration/reset/arrive.mp3',
    );

    expect(step.narrationAssetPath, 'narration/reset/arrive.mp3');
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
