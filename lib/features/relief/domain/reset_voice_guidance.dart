import 'models/breath_pattern.dart';
import 'models/reset_session_program.dart';

const int resetBreathRhythmLeadInSeconds = 8;

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

    // Breathing sessions use three semantic stages in the catalog:
    // settle -> active rhythm -> release. Speak the full scripted guidance
    // during settle/release. At the start of the active stage, give the user a
    // short lead-in window to hear the method-specific instruction before
    // switching to reusable phase cues.
    if (index == 0 || index == steps.length - 1) {
      return ResetVoiceGuidanceCue(
        key: 'step:$track:$index',
        spokenText: step.guidance,
        narrationAssetPath: step.narrationAssetPath,
      );
    }

    var stepStartSeconds = 0;
    for (var stepIndex = 0; stepIndex < index; stepIndex++) {
      stepStartSeconds += steps[stepIndex].durationSeconds;
    }
    final elapsedInStep = elapsedSeconds - stepStartSeconds;
    if (elapsedInStep < resetBreathRhythmLeadInSeconds) {
      return ResetVoiceGuidanceCue(
        key: 'step:$track:$index',
        spokenText: step.guidance,
        narrationAssetPath: step.narrationAssetPath,
      );
    }

    final phase = pattern.frameAtElapsedSeconds(elapsedSeconds).phase;
    return ResetVoiceGuidanceCue(
      key: 'breath:${phase.name}',
      spokenText: resetBreathPhaseSpokenText(phase),
      narrationAssetPath: resetBreathPhaseTargetAssetPath(phase),
    );
  }

  return ResetVoiceGuidanceCue(
    key: 'step:$track:$index',
    spokenText: step.guidance,
    narrationAssetPath: step.narrationAssetPath,
  );
}
