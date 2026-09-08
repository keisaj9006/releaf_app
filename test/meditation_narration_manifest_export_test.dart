import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tooling/meditation/export_narration_manifest.dart';

void main() {
  test('Releaf Guide production manifest exports the current guided catalog', () async {
    final manifest = buildNarrationManifest();

    expect(manifest['guidedSessionCount'], 20);
    expect(manifest['totalStepCount'], isA<int>());
    expect(manifest['recordedStepCount'], greaterThanOrEqualTo(4));
    expect(manifest['stepsStillToRender'], isA<int>());

    final guide = manifest['guideProfile']! as Map<String, Object?>;
    expect(guide['name'], 'Releaf Guide');
    expect(guide['speedReference'], 0.75);
    expect(guide['exactProviderVoiceId'], isNull);
    expect(guide['renderBlockedUntilVoiceIdIsRecovered'], isTrue);

    final sessions = manifest['sessions']! as List<Object?>;
    expect(sessions, hasLength(20));

    final mindfulness = sessions
        .cast<Map<String, Object?>>()
        .singleWhere((session) => session['id'] == 'mindfulness-basics-2');
    final steps = mindfulness['steps']! as List<Object?>;
    expect(steps, hasLength(4));

    final first = steps.first as Map<String, Object?>;
    expect(
      first['targetAssetPath'],
      'narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3',
    );
    expect(first['recordedAssetPath'], first['targetAssetPath']);
    expect(first['renderRequired'], isFalse);

    final file = await writeNarrationManifest(
      'build/qa-manifests/releaf-guide-manifest.json',
    );
    addTearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    expect(file.existsSync(), isTrue);
    final decoded = jsonDecode(await file.readAsString());
    expect(decoded, isA<Map>());
    expect((decoded as Map)['guidedSessionCount'], 20);
  });
}
