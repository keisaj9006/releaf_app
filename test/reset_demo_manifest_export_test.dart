import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tooling/reset/export_demo_manifest.dart';

void main() {
  test('Reset demo manifest exports only approved movement demonstrations',
      () async {
    final manifest = buildResetDemoManifest();

    expect(manifest['demoCount'], 2);
    expect(manifest['renderRequiredCount'], 2);

    final sessions = (manifest['sessions']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(
      sessions.map((session) => session['id']).toSet(),
      <String>{'pushups-activation', 'shake-it-out'},
    );

    for (final session in sessions) {
      expect(session['requirement'], 'movementTechnique');
      expect(
        session['targetAssetPath'],
        startsWith('video/reset-demos/'),
      );
      expect(session['assetPath'], isNull);
      expect(session['renderRequired'], isTrue);
      expect(session['minimumDurationSeconds'], 15);
      expect(session['maximumDurationSeconds'], 40);
      expect(session['audioRequired'], isFalse);
      expect((session['productionBrief'] as String).trim(), isNotEmpty);
      expect((session['safetyNote'] as String?)?.trim(), isNotEmpty);
      expect(session['id'], isNot('emergency-grounding'));
    }

    final pushups = sessions.singleWhere(
      (session) => session['id'] == 'pushups-activation',
    );
    expect(pushups['productionBrief'], contains('wall'));
    expect(pushups['productionBrief'], contains('seated'));

    final shake = sessions.singleWhere(
      (session) => session['id'] == 'shake-it-out',
    );
    expect(shake['productionBrief'], contains('seated'));

    final file = await writeResetDemoManifest(
      'build/qa-manifests/reset-demo-manifest.json',
    );
    expect(file.existsSync(), isTrue);

    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(decoded['demoCount'], 2);
  });
}
