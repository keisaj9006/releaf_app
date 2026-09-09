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

String resetBreathPhaseSpokenText(BreathPhase phase) {
  return switch (phase) {
    BreathPhase.inhale => 'Breathe in.',
    BreathPhase.holdAfterInhale => 'Hold gently.',
    BreathPhase.exhale => 'Breathe out.',
    BreathPhase.holdAfterExhale => 'Rest.',
  };
}

String resetBreathPhaseAssetSlug(BreathPhase phase) {
  return switch (phase) {
    BreathPhase.inhale => 'breathe-in',
    BreathPhase.holdAfterInhale => 'hold-gently',
    BreathPhase.exhale => 'breathe-out',
    BreathPhase.holdAfterExhale => 'rest',
  };
}

String resetBreathPhaseTargetAssetPath(BreathPhase phase) {
  return 'narration/releaf-guide/reset/breath-cues/'
      '${resetBreathPhaseAssetSlug(phase)}.mp3';
}

/// Resolves the single spoken cue for the current Reset frame.
///
/// Guided Reset sessions speak their scripted step guidance. Paced-breathing
/// sessions deliberately use short phase cues so the narrator never talks over
/// the next inhale/exhale transition. All breathing methods therefore share
/// the same four Releaf Guide cues while their [BreathPattern] remains the
/// source of truth for timing.
ResetVoiceGuidanceCue resetVoiceGuidanceCue({
  required ResetSessionProgram program,
  required int elapsedSeconds,
  required bool simplified,
}) {
  if (program.type == ResetProgramType.pacedBreathing) {
    final pattern = program.breathPattern;
    if (pattern == null) {
      throw StateError('Paced-breathing Reset has no BreathPattern.');
    }

    final phase = pattern.frameAtElapsedSeconds(elapsedSeconds).phase;
    return ResetVoiceGuidanceCue(
      key: 'breath:${phase.name}',
      spokenText: resetBreathPhaseSpokenText(phase),
    );
  }

  final index = program.stepIndexAtElapsedSeconds(
    elapsedSeconds,
    simplified: simplified,
  );
  final step = program.stepsFor(simplified: simplified)[index];
  final track = simplified ? 'simplified' : 'main';

  return ResetVoiceGuidanceCue(
    key: 'step:$track:$index',
    spokenText: step.guidance,
    narrationAssetPath: step.narrationAssetPath,
  );
}
