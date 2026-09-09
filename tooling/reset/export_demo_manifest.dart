import 'dart:convert';
import 'dart:io';

import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';

const resetDemoMinimumDurationSeconds = 15;
const resetDemoMaximumDurationSeconds = 40;

Map<String, Object?> buildResetDemoManifest() {
  const catalog = ResetCatalog();
  final sessions = catalog
      .getAll()
      .where((session) => session.requiresMovementDemo)
      .toList(growable: false);

  final payload = sessions.map((session) {
    if (session.isEmergency) {
      throw StateError(
        'Emergency must never enter the standard Reset demo-media pipeline.',
      );
    }

    return <String, Object?>{
      'id': session.id,
      'title': session.title,
      'requirement': session.demoRequirement.name,
      'targetAssetPath': 'video/reset-demos/${session.id}.mp4',
      'assetPath': null,
      'renderRequired': true,
      'minimumDurationSeconds': resetDemoMinimumDurationSeconds,
      'maximumDurationSeconds': resetDemoMaximumDurationSeconds,
      'audioRequired': false,
      'productionBrief': _productionBrief(session),
      'safetyNote': session.safetyNote,
      'instructions': session.instructions,
    };
  }).toList(growable: false);

  return <String, Object?>{
    'schemaVersion': 1,
    'policy':
        'Only Reset sessions that genuinely need movement technique shown are eligible for demo media.',
    'demoCount': payload.length,
    'renderRequiredCount':
        payload.where((item) => item['renderRequired'] == true).length,
    'sessions': payload,
  };
}

String _productionBrief(ResetContent session) {
  return switch (session.id) {
    'pushups-activation' =>
      'Show controlled repetitions without exhaustion framing. Include a floor version plus clearly demonstrated wall and seated alternatives so the user can choose a comfortable level.',
    'shake-it-out' =>
      'Show small, loose hand, arm and leg movement rather than aggressive shaking. Include a seated alternative and finish by returning to stillness.',
    _ => throw StateError(
        'Reset ${session.id} is marked as requiring a movement demo but has no approved production brief.',
      ),
  };
}

Future<File> writeResetDemoManifest(String outputPath) async {
  final manifest = buildResetDemoManifest();
  final json = const JsonEncoder.withIndent('  ').convert(manifest);
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('$json\n');
  return file;
}
