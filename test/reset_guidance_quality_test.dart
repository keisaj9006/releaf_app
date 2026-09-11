import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';
import 'package:releaf_app/theme/widgets/releaf_body_release_visual.dart';
import 'package:releaf_app/theme/widgets/releaf_grounding_body_visual.dart';

void main() {
  test('breathing phase cues are bundled and contain audio', () {
    for (final path in const [
      'assets/sounds/reset/breath-cues/inhale.mp3',
      'assets/sounds/reset/breath-cues/exhale.mp3',
    ]) {
      final asset = File(path);
      expect(asset.existsSync(), isTrue, reason: '$path must exist');
      expect(
        asset.lengthSync(),
        greaterThan(10000),
        reason: '$path must contain a production cue',
      );
    }
  });

  test('the active app has no device text-to-speech dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final voiceController = File(
      'lib/features/meditation/application/meditation_voice_controller.dart',
    ).readAsStringSync();

    expect(pubspec, isNot(contains('flutter_tts')));
    expect(voiceController, isNot(contains('FlutterTts')));
  });

  test('60s Grounding uses the illustrated body-contact treatment', () {
    const catalog = ResetCatalog();
    final grounding = catalog.getById('60s-grounding');

    expect(grounding, isNotNull);
    expect(grounding!.quickCategory, QuickResetCategory.noBreath);
    expect(grounding.visualType, ResetVisualType.bodyGrounding);
  });

  testWidgets('grounding guide renders an accessible feet-and-support visual', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ReleafGroundingBodyVisual(
              progress: 0.2,
              phaseLabel: 'Arrive',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('reset-grounding-body-visual')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Illustrated grounding guide. Place both feet on the floor.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('jaw and shoulder guide exposes its highlighted body area', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ReleafBodyReleaseVisual(
              progress: 0.4,
              phaseLabel: 'Jaw',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('reset-body-release-visual')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Illustrated upper-body guide. Jaw. The active jaw or shoulder area is highlighted.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
