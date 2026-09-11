import 'models/breath_pattern.dart';
import 'models/reset_session_program.dart';

class ResetVoiceGuidanceCue {
  const ResetVoiceGuidanceCue({
    required this.key,
    required this.spokenText,
    this.narrationAssetPath,
  });

  final String key;
  final String spokenText;
  final String? narrationAssetPath;
}

/// The bundled artificial tones were rejected. Change this only after the
/// owner approves the replacement inhale/exhale recordings at the target paths.
/// File presence or successful decoding is never production approval.
const bool resetBreathingCuesProductionApproved = false;

String? resetBreathPhaseTargetAssetPath(BreathPhase phase) {
  return switch (phase) {
    BreathPhase.inhale => 'sounds/reset/breath-cues/inhale.mp3',
    BreathPhase.exhale => 'sounds/reset/breath-cues/exhale.mp3',
    BreathPhase.holdAfterInhale || BreathPhase.holdAfterExhale => null,
  };
}

String? resetBreathPhaseRuntimeAssetPath(BreathPhase phase) =>
    resetBreathingCuesProductionApproved
    ? resetBreathPhaseTargetAssetPath(phase)
    : null;

/// Resolves the single audio cue for the current Reset frame.
///
/// Guided Reset sessions may use approved recorded Releaf Guide narration.
/// Paced-breathing sessions never read their instructional copy aloud: inhale
/// and exhale require approved natural breath recordings. Until then they stay
/// silent, as every hold/rest phase always does. The program's BreathPattern
/// remains the source of truth for both
/// the visual and the audio phase.
ResetVoiceGuidanceCue resetVoiceGuidanceCue({
  required ResetSessionProgram program,
  required int elapsedSeconds,
  required bool simplified,
}) {
  final steps = program.stepsFor(simplified: simplified);
  final index = program.stepIndexAtElapsedSeconds(
    elapsedSeconds,
    simplified: simplified,
  );
  final step = steps[index];
  final track = simplified ? 'simplified' : 'main';

  if (program.type == ResetProgramType.pacedBreathing) {
    final pattern = program.breathPattern;
    if (pattern == null) {
      throw StateError('Paced-breathing Reset has no BreathPattern.');
    }

    final phase = pattern.frameAtElapsedSeconds(elapsedSeconds).phase;
    return ResetVoiceGuidanceCue(
      key: 'breath:${phase.name}',
      spokenText: '',
      narrationAssetPath: resetBreathPhaseRuntimeAssetPath(phase),
    );
  }

  return ResetVoiceGuidanceCue(
    key: 'step:$track:$index',
    spokenText: step.guidance,
    narrationAssetPath: step.narrationAssetPath,
  );
}
