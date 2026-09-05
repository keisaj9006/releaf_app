enum BreathPhase {
  inhale,
  holdAfterInhale,
  exhale,
  holdAfterExhale,
}

class BreathPatternFrame {
  const BreathPatternFrame({
    required this.phase,
    required this.phaseElapsedSeconds,
    required this.phaseDurationSeconds,
    required this.cycleElapsedSeconds,
    required this.cycleDurationSeconds,
  });

  final BreathPhase phase;
  final int phaseElapsedSeconds;
  final int phaseDurationSeconds;
  final int cycleElapsedSeconds;
  final int cycleDurationSeconds;

  double get phaseProgress {
    if (phaseDurationSeconds <= 0) return 1;
    return (phaseElapsedSeconds / phaseDurationSeconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  int get phaseRemainingSeconds =>
      (phaseDurationSeconds - phaseElapsedSeconds).clamp(0, phaseDurationSeconds);
}

/// Canonical timing model for paced breathing.
///
/// The pattern is intentionally presentation-agnostic so the same source can
/// later drive Living Form motion, Breath Path, audio cues and haptics.
class BreathPattern {
  const BreathPattern({
    required this.inhaleSeconds,
    required this.exhaleSeconds,
    this.holdAfterInhaleSeconds = 0,
    this.holdAfterExhaleSeconds = 0,
    this.label,
  }) : assert(inhaleSeconds > 0),
       assert(exhaleSeconds > 0),
       assert(holdAfterInhaleSeconds >= 0),
       assert(holdAfterExhaleSeconds >= 0);

  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final String? label;

  int get cycleSeconds =>
      inhaleSeconds +
      holdAfterInhaleSeconds +
      exhaleSeconds +
      holdAfterExhaleSeconds;

  bool get hasHolds =>
      holdAfterInhaleSeconds > 0 || holdAfterExhaleSeconds > 0;

  BreathPatternFrame frameAtElapsedSeconds(int elapsedSeconds) {
    final cycle = cycleSeconds;
    final normalized = elapsedSeconds < 0 ? 0 : elapsedSeconds % cycle;

    var cursor = 0;

    if (normalized < cursor + inhaleSeconds) {
      return _frame(
        BreathPhase.inhale,
        normalized - cursor,
        inhaleSeconds,
        normalized,
      );
    }
    cursor += inhaleSeconds;

    if (holdAfterInhaleSeconds > 0 &&
        normalized < cursor + holdAfterInhaleSeconds) {
      return _frame(
        BreathPhase.holdAfterInhale,
        normalized - cursor,
        holdAfterInhaleSeconds,
        normalized,
      );
    }
    cursor += holdAfterInhaleSeconds;

    if (normalized < cursor + exhaleSeconds) {
      return _frame(
        BreathPhase.exhale,
        normalized - cursor,
        exhaleSeconds,
        normalized,
      );
    }
    cursor += exhaleSeconds;

    return _frame(
      BreathPhase.holdAfterExhale,
      normalized - cursor,
      holdAfterExhaleSeconds,
      normalized,
    );
  }

  BreathPatternFrame _frame(
    BreathPhase phase,
    int phaseElapsed,
    int phaseDuration,
    int cycleElapsed,
  ) {
    return BreathPatternFrame(
      phase: phase,
      phaseElapsedSeconds: phaseElapsed,
      phaseDurationSeconds: phaseDuration,
      cycleElapsedSeconds: cycleElapsed,
      cycleDurationSeconds: cycleSeconds,
    );
  }
}
