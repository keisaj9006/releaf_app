import 'breath_pattern.dart';

enum ResetProgramType { guidedSteps, pacedBreathing }

class ResetSessionStep {
  const ResetSessionStep({
    required this.label,
    required this.guidance,
    required this.durationSeconds,
  }) : assert(label != ''),
       assert(guidance != ''),
       assert(durationSeconds > 0);

  final String label;
  final String guidance;
  final int durationSeconds;
}

class ResetSessionProgram {
  const ResetSessionProgram.guided({
    required this.steps,
  }) : type = ResetProgramType.guidedSteps,
       breathPattern = null;

  const ResetSessionProgram.breathing({
    required this.breathPattern,
    required this.steps,
  }) : type = ResetProgramType.pacedBreathing;

  final ResetProgramType type;
  final List<ResetSessionStep> steps;
  final BreathPattern? breathPattern;

  int get scriptedDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  ResetSessionStep stepAtElapsedSeconds(int elapsedSeconds) {
    final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    var cursor = 0;

    for (final step in steps) {
      final end = cursor + step.durationSeconds;
      if (safeElapsed < end) return step;
      cursor = end;
    }

    return steps.last;
  }

  int stepIndexAtElapsedSeconds(int elapsedSeconds) {
    final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    var cursor = 0;

    for (var index = 0; index < steps.length; index++) {
      final end = cursor + steps[index].durationSeconds;
      if (safeElapsed < end) return index;
      cursor = end;
    }

    return steps.length - 1;
  }
}
