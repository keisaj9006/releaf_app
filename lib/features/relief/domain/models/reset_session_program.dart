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
    this.simplifiedSteps = const [],
    this.simplifyActionLabel,
  }) : type = ResetProgramType.guidedSteps,
       breathPattern = null;

  const ResetSessionProgram.breathing({
    required this.breathPattern,
    required this.steps,
  }) : simplifiedSteps = const [],
       simplifyActionLabel = null,
       type = ResetProgramType.pacedBreathing;

  final ResetProgramType type;
  final List<ResetSessionStep> steps;
  final List<ResetSessionStep> simplifiedSteps;
  final String? simplifyActionLabel;
  final BreathPattern? breathPattern;

  bool get hasSimplifiedPath => simplifiedSteps.isNotEmpty;

  int get scriptedDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  int get simplifiedDurationSeconds =>
      simplifiedSteps.fold(0, (sum, step) => sum + step.durationSeconds);

  List<ResetSessionStep> stepsFor({required bool simplified}) {
    if (simplified && hasSimplifiedPath) return simplifiedSteps;
    return steps;
  }

  ResetSessionStep stepAtElapsedSeconds(
    int elapsedSeconds, {
    bool simplified = false,
  }) {
    final activeSteps = stepsFor(simplified: simplified);
    final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    var cursor = 0;

    for (final step in activeSteps) {
      final end = cursor + step.durationSeconds;
      if (safeElapsed < end) return step;
      cursor = end;
    }

    return activeSteps.last;
  }

  int stepIndexAtElapsedSeconds(
    int elapsedSeconds, {
    bool simplified = false,
  }) {
    final activeSteps = stepsFor(simplified: simplified);
    final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    var cursor = 0;

    for (var index = 0; index < activeSteps.length; index++) {
      final end = cursor + activeSteps[index].durationSeconds;
      if (safeElapsed < end) return index;
      cursor = end;
    }

    return activeSteps.length - 1;
  }
}
