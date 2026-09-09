import 'dart:convert';
import 'dart:io';

import 'package:releaf_app/core/audio/releaf_guide_contract.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';


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

int _wordCount(String value) => value
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .length;

Map<String, Object?> buildNarrationManifest() {
  const catalog = MeditationCatalog();
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

  final sessionPayload = sessions.map((session) {
    final steps = <Map<String, Object?>>[];

    for (var index = 0; index < session.steps.length; index++) {
      final step = session.steps[index];
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
        recordedSteps += 1;
      }

      steps.add({
        'index': index + 1,
        'label': step.label,
        'screenGuidance': step.guidance,
        'spokenGuidance': spoken,
        'durationSeconds': step.durationSeconds,
        'wordCount': _wordCount(spoken),
        'targetAssetPath': target,
        'recordedAssetPath': recorded,
        'renderRequired': recorded == null || recorded.isEmpty,
      });
    }

    return <String, Object?>{
      'id': session.id,
      'title': session.title,
      'category': session.category.name,
      'accessTier': session.accessTier.name,
      'sessionDurationSeconds': session.durationSeconds,
      'backgroundSoundId': session.backgroundSoundId,
      'backgroundSoundVolume': session.backgroundSoundVolume,
      'steps': steps,
    };
  }).toList(growable: false);

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
