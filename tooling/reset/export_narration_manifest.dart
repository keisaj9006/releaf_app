import 'dart:convert';
import 'dart:io';

import 'package:releaf_app/core/audio/releaf_guide_contract.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/breath_pattern.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';
import 'package:releaf_app/features/relief/domain/models/reset_session_program.dart';
import 'package:releaf_app/features/relief/domain/reset_voice_guidance.dart';

const double resetGuideDefaultVoiceVolume = 0.72;

String _slug(String value) {
  final lower = value.toLowerCase().trim();
  final slug = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'step' : slug;
}

String _targetPath(
  String sessionId,
  int stepIndex,
  String label, {
  required bool simplified,
}) {
  final index = (stepIndex + 1).toString().padLeft(2, '0');
  final track = simplified ? 'simplified' : 'main';
  return 'narration/releaf-guide/reset/$sessionId/$track/'
      '$index-${_slug(label)}.mp3';
}

int _wordCount(String value) =>
    value.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

Map<String, Object?> _breathPatternPayload(BreathPattern pattern) {
  return <String, Object?>{
    'label': pattern.label,
    'inhaleSeconds': pattern.inhaleSeconds,
    'holdAfterInhaleSeconds': pattern.holdAfterInhaleSeconds,
    'exhaleSeconds': pattern.exhaleSeconds,
    'holdAfterExhaleSeconds': pattern.holdAfterExhaleSeconds,
    'cycleSeconds': pattern.cycleSeconds,
  };
}

List<Map<String, Object?>> _serializeSteps(
  String sessionId,
  List<ResetSessionStep> steps, {
  required bool simplified,
  required bool spokenGuidanceEnabled,
}) {
  final payload = <Map<String, Object?>>[];

  for (var index = 0; index < steps.length; index++) {
    final step = steps[index];
    final spoken = spokenGuidanceEnabled ? step.guidance.trim() : null;
    if (spokenGuidanceEnabled && (spoken == null || spoken.isEmpty)) {
      throw StateError('$sessionId / ${step.label} has no spoken guidance.');
    }

    final target = spokenGuidanceEnabled
        ? _targetPath(sessionId, index, step.label, simplified: simplified)
        : null;
    final recorded = spokenGuidanceEnabled
        ? step.narrationAssetPath?.trim()
        : null;

    if (recorded != null && recorded.isNotEmpty && recorded != target) {
      throw StateError(
        '$sessionId / ${step.label} uses "$recorded"; '
        'expected canonical path "$target".',
      );
    }

    payload.add(<String, Object?>{
      'index': index + 1,
      'label': step.label,
      'screenGuidance': step.guidance,
      'spokenGuidance': spoken,
      'durationSeconds': step.durationSeconds,
      'wordCount': spoken == null ? 0 : _wordCount(spoken),
      'advanceActionLabel': step.advanceActionLabel,
      'targetAssetPath': target,
      'recordedAssetPath': recorded,
      'renderRequired':
          spokenGuidanceEnabled && (recorded == null || recorded.isEmpty),
    });
  }

  return payload;
}

Map<String, Object?> buildResetNarrationManifest() {
  const catalog = ResetCatalog();
  final sessions = catalog.getAll();

  if (sessions.length != 50) {
    throw StateError(
      'Expected 50 active Reset sessions, found ${sessions.length}.',
    );
  }

  var breathingSessionCount = 0;
  var totalStepCount = 0;
  var recordedStepCount = 0;
  var stepsStillToRender = 0;

  final sessionPayload = <Map<String, Object?>>[];

  for (final session in sessions) {
    final program = session.program;
    if (program == null) {
      throw StateError('${session.id} has no ResetSessionProgram.');
    }

    if (session.modality == ResetModality.breathing) {
      if (program.type != ResetProgramType.pacedBreathing ||
          program.breathPattern == null) {
        throw StateError(
          '${session.id} is breathing content but does not use the canonical '
          'paced-breathing engine.',
        );
      }
      breathingSessionCount += 1;
    }

    final mainSteps = _serializeSteps(
      session.id,
      program.steps,
      simplified: false,
      spokenGuidanceEnabled: program.type != ResetProgramType.pacedBreathing,
    );
    final simplifiedSteps = _serializeSteps(
      session.id,
      program.simplifiedSteps,
      simplified: true,
      spokenGuidanceEnabled: program.type != ResetProgramType.pacedBreathing,
    );

    final allSteps = <Map<String, Object?>>[...mainSteps, ...simplifiedSteps];
    totalStepCount += allSteps.length;
    recordedStepCount += allSteps
        .where((step) => step['recordedAssetPath'] != null)
        .length;
    stepsStillToRender += allSteps
        .where((step) => step['renderRequired'] == true)
        .length;

    sessionPayload.add(<String, Object?>{
      'id': session.id,
      'title': session.title,
      'level': session.level.name,
      'modality': session.modality.name,
      'accessTier': session.accessTier.name,
      'isEmergency': session.isEmergency,
      'sessionDurationSeconds': session.durationSeconds,
      'programType': program.type.name,
      'breathPattern': program.breathPattern == null
          ? null
          : _breathPatternPayload(program.breathPattern!),
      'steps': mainSteps,
      'simplifiedSteps': simplifiedSteps,
    });
  }

  if (breathingSessionCount != 10) {
    throw StateError(
      'Expected 10 canonical breathing sessions, found $breathingSessionCount.',
    );
  }

  final breathCues = BreathPhase.values
      .map((phase) {
        final target = resetBreathPhaseTargetAssetPath(phase);
        if (target != null && !File('assets/$target').existsSync()) {
          throw StateError('Missing non-verbal breathing cue: assets/$target');
        }
        return <String, Object?>{
          'phase': phase.name,
          'cueType': target == null ? 'silence' : 'naturalHumanBreath',
          'existingCueType': target == null ? 'silence' : 'nonVerbalTone',
          'existingAssetPresent': target != null,
          'approvalStatus': target == null ? 'notRequired' : 'rejected',
          'productionApproved': false,
          'spokenGuidance': null,
          'targetAssetPath': target,
          'recordedAssetPath': target,
          'renderRequired': target != null,
        };
      })
      .toList(growable: false);

  return <String, Object?>{
    'schemaVersion': 1,
    'guideProfile': releafGuideProductionProfile,
    'voiceGuidanceDefaultEnabled': true,
    'defaultVoiceVolume': resetGuideDefaultVoiceVolume,
    'runtimeVoicePolicy':
        'approved recorded Releaf Guide only; missing narration stays silent; '
        'device/system TTS prohibited',
    'resetSessionCount': sessions.length,
    'breathingSessionCount': breathingSessionCount,
    'breathCueCount': breathCues.length,
    'breathCuesStillToRender': breathCues
        .where((cue) => cue['renderRequired'] == true)
        .length,
    'breathCuesAwaitingApproval': breathCues
        .where((cue) => cue['approvalStatus'] == 'rejected')
        .length,
    'breathingProductionDirection':
        'natural gentle human inhale and longer calming exhale; hold/rest silent; '
        'candidate files remain outside runtime assets until owner approval',
    'breathCues': breathCues,
    'totalStepCount': totalStepCount,
    'recordedStepCount': recordedStepCount,
    'stepsStillToRender': stepsStillToRender,
    'sessions': sessionPayload,
  };
}

Future<File> writeResetNarrationManifest(String outputPath) async {
  final manifest = buildResetNarrationManifest();
  final json = const JsonEncoder.withIndent('  ').convert(manifest);
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('$json\n');
  return file;
}
