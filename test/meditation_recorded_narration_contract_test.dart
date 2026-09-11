import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_player_screen.dart';

void main() {
  test('Mindfulness Basics is wired for recorded Releaf Guide narration', () {
    const catalog = MeditationCatalog();
    final session = catalog.getById('mindfulness-basics-2');

    expect(session, isNotNull);
    expect(session!.steps, hasLength(4));
    expect(session.hasRecordedNarration, isTrue);
    expect(session.hasAnyRecordedNarration, isTrue);
    expect(
      meditationVoiceSourceLabel(session),
      contains('Recorded Releaf Guide'),
    );

    expect(
      session.steps.map((step) => step.narrationAssetPath).toList(),
      const [
        'narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3',
        'narration/releaf-guide/mindfulness-basics-2/02-notice.mp3',
        'narration/releaf-guide/mindfulness-basics-2/03-return.mp3',
        'narration/releaf-guide/mindfulness-basics-2/04-finish.mp3',
      ],
    );

    expect(
      session.steps.every(
        (step) => step.spokenGuidance != null && step.spokenGuidance!.isNotEmpty,
      ),
      isTrue,
    );

    for (final step in session.steps) {
      final asset = File('assets/${step.narrationAssetPath}');
      expect(asset.existsSync(), isTrue, reason: '${asset.path} must exist');
      expect(
        asset.lengthSync(),
        greaterThan(10000),
        reason: '${asset.path} must contain production narration',
      );
    }
  });

  test('Every declared Releaf Guide asset exists and contains audio', () {
    const catalog = MeditationCatalog();
    var declaredAssets = 0;

    for (final session in catalog.getAll()) {
      for (final step in session.steps) {
        final path = step.narrationAssetPath?.trim();
        if (path == null || path.isEmpty) continue;

        declaredAssets += 1;
        final asset = File('assets/$path');
        expect(asset.existsSync(), isTrue, reason: '${asset.path} must exist');
        expect(
          asset.lengthSync(),
          greaterThan(10000),
          reason: '${asset.path} must contain production narration',
        );
      }
    }

    expect(declaredAssets, greaterThan(0));
  });

  test('Sessions without recorded narration are labelled captions-only', () {
    const catalog = MeditationCatalog();
    final session = catalog.getById('breath-and-body-4');

    expect(session, isNotNull);
    expect(session!.hasRecordedNarration, isFalse);
    expect(session.hasAnyRecordedNarration, isFalse);
    expect(
      meditationVoiceSourceLabel(session),
      'Releaf Guide recording pending · captions only',
    );
    expect(
      meditationGuidanceSourceEyebrow(session),
      'GUIDED · RELEAF GUIDE PENDING',
    );
  });
}
