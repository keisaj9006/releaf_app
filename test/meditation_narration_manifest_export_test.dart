import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/meditation/domain/meditation_content.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';

import '../tooling/meditation/export_narration_manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'every exported recording and ambience is in the actual Flutter bundle',
    () async {
      final bundle = await AssetManifest.loadFromAssetBundle(rootBundle);
      final bundled = bundle.listAssets().toSet();
      final manifest = buildNarrationManifest();
      for (final session
          in (manifest['sessions']! as List).cast<Map<String, Object?>>()) {
        for (final step
            in (session['steps']! as List).cast<Map<String, Object?>>()) {
          final recorded = step['recordedAssetPath'];
          if (recorded != null) expect(bundled, contains('assets/$recorded'));
        }
        final ambienceId = session['backgroundSoundId'] as String?;
        if (ambienceId != null) {
          final track = const SoundCatalog().getById(ambienceId)!;
          expect(bundled, contains('assets/${track.assetPath}'));
        }
      }
    },
  );
  test(
    'recording availability distinguishes complete, partial and captions-only',
    () {
      final complete = (buildNarrationManifest()['sessions']! as List)
          .cast<Map<String, Object?>>();
      expect(complete.first['recordingAvailability'], 'recorded');
      expect(
        complete
            .skip(1)
            .every(
              (session) => session['recordingAvailability'] == 'captionsOnly',
            ),
        isTrue,
      );
      final partial = buildNarrationManifest(
        catalog: _ModifiedCatalog(
          _fixture(
            recording:
                'narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3',
          ),
        ),
      );
      expect(
        ((partial['sessions']! as List).first as Map)['recordingAvailability'],
        'partial',
      );
    },
  );
  test('export rejects a declared recording whose source file is missing', () {
    expect(
      () => buildNarrationManifest(
        catalog: _ModifiedCatalog(
          _fixture(
            id: 'missing-recording',
            recording: 'narration/releaf-guide/missing-recording/01-arrive.mp3',
          ),
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Missing recorded asset'),
        ),
      ),
    );
  });
  test(
    'export rejects unknown ambience instead of publishing an unusable mix',
    () {
      expect(
        () => buildNarrationManifest(
          catalog: _ModifiedCatalog(
            _fixture(backgroundSoundId: 'missing-ambience'),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Unknown ambience'),
          ),
        ),
      );
    },
  );
  test('export rejects duplicate session IDs', () {
    expect(
      () => buildNarrationManifest(
        catalog: _ModifiedCatalog(
          _fixture(id: const MeditationCatalog().getAll()[1].id),
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Duplicate session ID'),
        ),
      ),
    );
  });
  for (final duration in [0, -1, 31]) {
    test('export rejects invalid or mismatched step duration $duration', () {
      final original = const MeditationCatalog().getAll().first;
      final changed = MeditationContent(
        id: original.id,
        title: original.title,
        subtitle: original.subtitle,
        durationSeconds: original.durationSeconds,
        category: original.category,
        accessTier: original.accessTier,
        steps: [
          for (var i = 0; i < original.steps.length; i++)
            MeditationStep(
              label: original.steps[i].label,
              guidance: original.steps[i].guidance,
              spokenGuidance: original.steps[i].spokenGuidance,
              durationSeconds: i == 0
                  ? duration
                  : original.steps[i].durationSeconds,
            ),
        ],
      );
      expect(
        () => buildNarrationManifest(catalog: _ModifiedCatalog(changed)),
        throwsStateError,
      );
    });
  }

  test('exported caption timelines cover each session without gaps', () {
    final manifest = buildNarrationManifest();
    for (final session
        in (manifest['sessions']! as List).cast<Map<String, Object?>>()) {
      var elapsed = 0;
      for (final step
          in (session['steps']! as List).cast<Map<String, Object?>>()) {
        expect(step['startSeconds'], elapsed, reason: '${session['id']} start');
        elapsed += step['durationSeconds']! as int;
        expect(step['endSeconds'], elapsed, reason: '${session['id']} end');
      }
      expect(elapsed, session['sessionDurationSeconds']);
    }
  });

  test(
    'Releaf Guide production manifest exports the current guided catalog',
    () async {
      final manifest = buildNarrationManifest();

      expect(manifest['guidedSessionCount'], 20);
      expect(manifest['totalStepCount'], isA<int>());
      expect(manifest['recordedStepCount'], greaterThanOrEqualTo(4));
      expect(manifest['stepsStillToRender'], isA<int>());

      final guide = manifest['guideProfile']! as Map<String, Object?>;
      expect(guide['name'], 'Releaf Guide');
      expect(guide['provider'], 'ElevenCreative');
      expect(guide['speedReference'], 0.82);
      expect(
        guide['referenceGenerationId'],
        'd730719be8654c93bddd639a96da7417',
      );
      expect(guide['exactProviderVoiceId'], isNull);
      expect(guide['renderBlockedUntilVoiceIdIsRecovered'], isTrue);

      final sessions = manifest['sessions']! as List<Object?>;
      expect(sessions, hasLength(20));

      final mindfulness = sessions.cast<Map<String, Object?>>().singleWhere(
        (session) => session['id'] == 'mindfulness-basics-2',
      );
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
      expect(file.existsSync(), isTrue);
      final decoded = jsonDecode(await file.readAsString());
      expect(decoded, isA<Map>());
      expect((decoded as Map)['guidedSessionCount'], 20);
    },
  );
}

class _ModifiedCatalog extends MeditationCatalog {
  const _ModifiedCatalog(this.first);
  final MeditationContent first;
  @override
  List<MeditationContent> getAll() => [first, ...super.getAll().skip(1)];
}

MeditationContent _fixture({
  String? id,
  String? recording,
  String? backgroundSoundId,
}) {
  final original = const MeditationCatalog().getAll().first;
  return MeditationContent(
    id: id ?? original.id,
    title: original.title,
    subtitle: original.subtitle,
    durationSeconds: original.durationSeconds,
    category: original.category,
    accessTier: original.accessTier,
    backgroundSoundId: backgroundSoundId,
    steps: [
      for (var i = 0; i < original.steps.length; i++)
        MeditationStep(
          label: original.steps[i].label,
          guidance: original.steps[i].guidance,
          spokenGuidance: original.steps[i].spokenGuidance,
          durationSeconds: original.steps[i].durationSeconds,
          narrationAssetPath: i == 0 ? recording : null,
        ),
    ],
  );
}
