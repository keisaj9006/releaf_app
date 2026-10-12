import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/stories/presentation/stories_preview_screen.dart';

const _audioBundled = bool.fromEnvironment(
  'RELIEF_STORIES_AUDIO_BUNDLED',
  defaultValue: false,
);

Future<void> _pumpStories(
  WidgetTester tester, {
  Size size = const Size(800, 900),
  double textScale = 1.0,
  List<SleepProgressRecord> progressRecords = const <SleepProgressRecord>[],
}) async {
  SharedPreferences.setMockInitialValues({
    SleepProgressStore.storageKeyForAccount(null): progressRecords
        .map((record) => record.encode())
        .toList(growable: false),
  });
  final preferences = await SharedPreferences.getInstance();
  final progress = SleepProgressStore(preferences);

  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        sleepProgressStoreProvider.overrideWith((ref) => progress),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const StoriesPreviewScreen(),
        ),
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
  testWidgets('dedicated Stories screen exposes three user-facing titles', (
    WidgetTester tester,
  ) async {
    await _pumpStories(tester);

    expect(find.byKey(const Key('stories-preview-back')), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('3 stories'), findsOneWidget);
    expect(find.textContaining('prepared'), findsNothing);
    expect(find.textContaining('audio master'), findsNothing);
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

  testWidgets('latest unfinished Story becomes the Continue Listening action', (
    WidgetTester tester,
  ) async {
    await _pumpStories(
      tester,
      progressRecords: [
        SleepProgressRecord(
          contentId: 'TS01_BEYOND_THE_GATE',
          position: const Duration(minutes: 12),
          duration: const Duration(seconds: 1971),
          chapterId: null,
          updatedAt: DateTime.utc(2026, 10, 10, 20),
          isCompleted: false,
          isFavourite: false,
        ),
        SleepProgressRecord(
          contentId: 'ST_L05_COMPUTER',
          position: const Duration(minutes: 3),
          duration: const Duration(seconds: 1245),
          chapterId: null,
          updatedAt: DateTime.utc(2026, 10, 11, 20),
          isCompleted: false,
          isFavourite: false,
        ),
      ],
    );

    final continueCard = find.byKey(
      const Key('stories-continue-ST_L05_COMPUTER'),
    );
    expect(continueCard, findsOneWidget);
    expect(
      find.descendant(of: continueCard, matching: find.text('Computer')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: continueCard, matching: find.text('3 min listened')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('stories-continue-TS01_BEYOND_THE_GATE')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed or unknown progress never creates a resume card', (
    WidgetTester tester,
  ) async {
    await _pumpStories(
      tester,
      progressRecords: [
        SleepProgressRecord(
          contentId: 'TS02_KRYSTYNA_SKARBEK',
          position: const Duration(seconds: 2198),
          duration: const Duration(seconds: 2198),
          chapterId: null,
          updatedAt: DateTime.utc(2026, 10, 11, 20),
          isCompleted: true,
          isFavourite: false,
        ),
        SleepProgressRecord(
          contentId: 'unknown-story',
          position: const Duration(minutes: 5),
          duration: const Duration(minutes: 20),
          chapterId: null,
          updatedAt: DateTime.utc(2026, 10, 11, 21),
          isCompleted: false,
          isFavourite: false,
        ),
      ],
    );

    expect(find.byKey(const Key('stories-continue-listening')), findsNothing);
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
    expect(find.text('3 stories'), findsOneWidget);
    expect(
      find.byKey(const Key('stories-preview-back')).hitTestable(),
      findsOneWidget,
    );
    final countBounds = tester.getRect(find.text('3 stories'));
    expect(countBounds.left, greaterThanOrEqualTo(0));
    expect(countBounds.right, lessThanOrEqualTo(320));
    expect(
      MediaQuery.textScalerOf(tester.element(find.text('Stories'))).scale(12),
      24,
      reason: 'Layout must adapt without reducing the requested text scale.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('all Stories remain reachable at 320x640 with 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpStories(
      tester,
      size: const Size(320, 640),
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);

    const storyIds = <String>[
      'TS01_BEYOND_THE_GATE',
      'TS02_KRYSTYNA_SKARBEK',
      'ST_L05_COMPUTER',
    ];
    for (final id in storyIds) {
      final card = await _revealStoryCard(tester, id);
      final control = find.descendant(
        of: card,
        matching: find.byKey(
          Key(
            _audioBundled
                ? 'story-preview-play-$id'
                : 'story-preview-audio-missing-$id',
          ),
        ),
      );
      expect(control, findsOneWidget, reason: id);
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      expect(control.hitTestable(), findsOneWidget, reason: id);
      expect(tester.takeException(), isNull, reason: id);
    }
  });
}
