import 'dart:convert';
import 'dart:io';

import 'package:releaf_app/core/audio/releaf_guide_contract.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';

String _slug(String value) {
  final lower = value.toLowerCase().trim();
  final slug = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'step' : slug;
}

String _targetPath(String sessionId, int stepIndex, String label) {
  final index = (stepIndex + 1).toString().padLeft(2, '0');
  return 'narration/releaf-guide/$sessionId/$index-${_slug(label)}.mp3';
}

int _wordCount(String value) =>
    value.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

Map<String, Object?> buildNarrationManifest({
  MeditationCatalog catalog = const MeditationCatalog(),
}) {
  final sessions = catalog
      .getAll()
      .where((session) => !session.unguided)
      .toList(growable: false);

  if (sessions.length != 20) {
    throw StateError(
      'Expected 20 guided meditations, found ${sessions.length}.',
    );
  }

  var totalSteps = 0;
  var recordedSteps = 0;
  final sessionIds = <String>{};
  const sounds = SoundCatalog();

  final sessionPayload = sessions
      .map((session) {
        if (!sessionIds.add(session.id)) {
          throw StateError('Duplicate session ID: ${session.id}.');
        }
        if (session.id.trim().isEmpty ||
            session.durationSeconds <= 0 ||
            session.steps.isEmpty) {
          throw StateError(
            'Invalid session identity or duration: ${session.id}.',
          );
        }
        final ambienceId = session.backgroundSoundId;
        if (ambienceId != null) {
          final ambience = sounds.getById(ambienceId);
          if (ambience == null) {
            throw StateError('Unknown ambience: $ambienceId (${session.id}).');
          }
          final file = File('assets/${ambience.assetPath}');
          if (!file.existsSync() || file.lengthSync() == 0) {
            throw StateError('Missing ambience asset: ${ambience.assetPath}.');
          }
        }
        final steps = <Map<String, Object?>>[];
        var elapsed = 0;

        for (var index = 0; index < session.steps.length; index++) {
          final step = session.steps[index];
          if (step.durationSeconds <= 0 ||
              step.label.trim().isEmpty ||
              step.guidance.trim().isEmpty) {
            throw StateError(
              'Invalid step timeline or caption: ${session.id} / ${step.label}.',
            );
          }
          final spoken = step.spokenGuidance?.trim() ?? '';
          if (spoken.isEmpty) {
            throw StateError(
              '${session.id} / ${step.label} has no spokenGuidance.',
            );
          }

          final target = _targetPath(session.id, index, step.label);
          final recorded = step.narrationAssetPath?.trim();

          if (recorded != null && recorded.isNotEmpty && recorded != target) {
            throw StateError(
              '${session.id} / ${step.label} uses "$recorded"; '
              'expected canonical path "$target".',
            );
          }

          totalSteps += 1;
          if (recorded != null && recorded.isNotEmpty) {
            final file = File('assets/$recorded');
            if (!file.existsSync() || file.lengthSync() == 0) {
              throw StateError('Missing recorded asset: $recorded.');
            }
            recordedSteps += 1;
          }

          steps.add({
            'index': index + 1,
            'label': step.label,
            'screenGuidance': step.guidance,
            'spokenGuidance': spoken,
            'durationSeconds': step.durationSeconds,
            'startSeconds': elapsed,
            'endSeconds': elapsed + step.durationSeconds,
            'wordCount': _wordCount(spoken),
            'targetAssetPath': target,
            'recordedAssetPath': recorded,
            'renderRequired': recorded == null || recorded.isEmpty,
          });
          elapsed += step.durationSeconds;
        }
        if (elapsed != session.durationSeconds) {
          throw StateError(
            'Step duration total $elapsed differs from session duration '
            '${session.durationSeconds}: ${session.id}.',
          );
        }

        return <String, Object?>{
          'id': session.id,
          'title': session.title,
          'subtitle': session.subtitle,
          'category': session.category.name,
          'accessTier': session.accessTier.name,
          'sessionDurationSeconds': session.durationSeconds,
          'backgroundSoundId': session.backgroundSoundId,
          'backgroundSoundVolume': session.backgroundSoundVolume,
          'seriesId': session.seriesId,
          'seriesOrder': session.seriesOrder,
          'recordingAvailability': session.hasRecordedNarration
              ? 'recorded'
              : session.hasAnyRecordedNarration
              ? 'partial'
              : 'captionsOnly',
          'steps': steps,
        };
      })
      .toList(growable: false);

  return {
    'schemaVersion': 1,
    'guideProfile': releafGuideProductionProfile,
    'guidedSessionCount': sessions.length,
    'totalStepCount': totalSteps,
    'recordedStepCount': recordedSteps,
    'stepsStillToRender': totalSteps - recordedSteps,
    'sessions': sessionPayload,
  };
}

Future<File> writeNarrationManifest(String outputPath) async {
  final manifest = buildNarrationManifest();
  final json = const JsonEncoder.withIndent('  ').convert(manifest);
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('$json\n');
  return file;
}
