import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tooling/reset/export_narration_manifest.dart';

void main() {
  test(
    'Reset Releaf Guide manifest covers every active Reset session',
    () async {
      final manifest = buildResetNarrationManifest();

      expect(manifest['resetSessionCount'], 50);
      expect(manifest['breathingSessionCount'], 10);
      expect(manifest['breathCueCount'], 4);
      expect(manifest['breathCuesStillToRender'], 2);
      expect(manifest['breathCuesAwaitingApproval'], 2);
      expect(manifest['voiceGuidanceDefaultEnabled'], isTrue);
      expect(manifest['defaultVoiceVolume'], 0.72);
      expect(manifest['totalStepCount'], greaterThan(50));

      final guide = manifest['guideProfile']! as Map<String, Object?>;
      expect(guide['name'], 'Releaf Guide');
      expect(guide['speedReference'], 0.82);
      expect(
        guide['referenceGenerationId'],
        'd730719be8654c93bddd639a96da7417',
      );
      expect(guide['exactProviderVoiceId'], isNull);
      expect(guide['renderBlockedUntilVoiceIdIsRecovered'], isTrue);

      final breathCues = (manifest['breathCues']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(breathCues, hasLength(4));
      expect(
        breathCues.singleWhere((cue) => cue['phase'] == 'inhale'),
        containsPair('targetAssetPath', 'sounds/reset/breath-cues/inhale.mp3'),
      );
      expect(
        breathCues.singleWhere((cue) => cue['phase'] == 'exhale'),
        containsPair('cueType', 'naturalHumanBreath'),
      );
      expect(
        breathCues.singleWhere((cue) => cue['phase'] == 'holdAfterInhale'),
        containsPair('cueType', 'silence'),
      );
      for (final cue in breathCues) {
        final audible = cue['targetAssetPath'] != null;
        expect(cue['approvalStatus'], audible ? 'rejected' : 'notRequired');
        expect(cue['renderRequired'], audible);
        expect(cue['productionApproved'], isFalse);
        expect(cue['existingAssetPresent'], audible);
        expect(cue, containsPair('runtimeAssetPath', null));
        expect(cue['runtimeEligible'], isFalse);
      }

      final sessions = (manifest['sessions']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(sessions, hasLength(50));
      expect(
        sessions.where((session) => session['isEmergency'] == true),
        hasLength(1),
      );

      final equalRhythm = sessions.singleWhere(
        (session) => session['id'] == 'equal-rhythm',
      );
      expect(equalRhythm['programType'], 'pacedBreathing');
      final pattern = equalRhythm['breathPattern']! as Map<String, Object?>;
      expect(pattern['inhaleSeconds'], 5);
      expect(pattern['exhaleSeconds'], 5);

      final steps = (equalRhythm['steps']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(steps.first['targetAssetPath'], isNull);
      expect(steps.first['spokenGuidance'], isNull);
      expect(steps.first['screenGuidance'], isNotEmpty);

      final file = await writeResetNarrationManifest(
        'build/qa-manifests/reset-releaf-guide-manifest.json',
      );
      expect(file.existsSync(), isTrue);
      final decoded = jsonDecode(await file.readAsString());
      expect(decoded, isA<Map>());
      expect((decoded as Map)['resetSessionCount'], 50);
    },
  );
}
