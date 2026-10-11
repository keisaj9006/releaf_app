import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/stories/presentation/stories_preview_screen.dart';

const _audioBundled = bool.fromEnvironment(
  'RELIEF_STORIES_AUDIO_BUNDLED',
  defaultValue: false,
);

Future<void> _pumpStories(
  WidgetTester tester, {
  Size size = const Size(800, 900),
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const StoriesPreviewScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dedicated Stories screen exposes the three prepared titles', (
    WidgetTester tester,
  ) async {
    await _pumpStories(tester);

    expect(find.byKey(const Key('stories-preview-back')), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('3 prepared titles'), findsOneWidget);
    expect(find.text('OWNER PREVIEW'), findsNothing);

    for (final id in const [
      'TS01_BEYOND_THE_GATE',
      'TS02_KRYSTYNA_SKARBEK',
      'ST_L05_COMPUTER',
    ]) {
      final card = find.byKey(Key('story-preview-$id'));
      await tester.scrollUntilVisible(card, 300);
      expect(card, findsOneWidget);
      if (_audioBundled) {
        expect(find.byKey(Key('story-preview-play-$id')), findsOneWidget);
        expect(
          find.byKey(Key('story-preview-audio-missing-$id')),
          findsNothing,
        );
      } else {
        expect(find.byKey(Key('story-preview-play-$id')), findsNothing);
        expect(
          find.byKey(Key('story-preview-audio-missing-$id')),
          findsOneWidget,
        );
      }
    }

    for (final title in const [
      'Beyond the Gate',
      'The Woman Who Crossed Every Border',
      'Computer',
    ]) {
      final titleFinder = find.text(title);
      await tester.scrollUntilVisible(titleFinder, 300);
      expect(titleFinder, findsOneWidget);
    }

    expect(find.text('Night Mysteries'), findsNothing);
    expect(find.text('Fiction Escapes'), findsNothing);
    expect(find.text('Wonder Journeys'), findsNothing);
    expect(find.text('Drift Through History'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dedicated Stories screen stays usable at 320x640', (
    WidgetTester tester,
  ) async {
    await _pumpStories(tester, size: const Size(320, 640));

    expect(find.text('Stories'), findsOneWidget);
    expect(
      find.byKey(const Key('story-preview-TS01_BEYOND_THE_GATE')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dedicated Stories screen stays usable at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpStories(
      tester,
      size: const Size(320, 640),
      textScale: 2.0,
    );

    expect(find.text('Stories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
