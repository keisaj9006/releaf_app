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

Future<Finder> _revealStoryCard(WidgetTester tester, String id) async {
  final card = find.byKey(Key('story-preview-$id'));
  final scroll = find.byKey(const Key('stories-screen-scroll'));

  for (var attempt = 0; card.evaluate().isEmpty && attempt < 20; attempt++) {
    await tester.drag(scroll, const Offset(0, -360));
    await tester.pumpAndSettle();
  }

  expect(card, findsOneWidget, reason: 'Story card $id was not reachable.');
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  return card;
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

    const stories = <String, String>{
      'TS01_BEYOND_THE_GATE': 'Beyond the Gate',
      'TS02_KRYSTYNA_SKARBEK': 'The Woman Who Crossed Every Border',
      'ST_L05_COMPUTER': 'Computer',
    };

    for (final entry in stories.entries) {
      final card = await _revealStoryCard(tester, entry.key);
      expect(
        find.descendant(of: card, matching: find.text(entry.value)),
        findsOneWidget,
      );

      if (_audioBundled) {
        expect(
          find.byKey(Key('story-preview-play-${entry.key}')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('story-preview-audio-missing-${entry.key}')),
          findsNothing,
        );
      } else {
        expect(
          find.byKey(Key('story-preview-play-${entry.key}')),
          findsNothing,
        );
        expect(
          find.byKey(Key('story-preview-audio-missing-${entry.key}')),
          findsOneWidget,
        );
      }
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
