import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/meditation/application/meditation_library_controller.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}

void main() {
  test('Brain completion also writes a merge-safe sync event', () async {
    final preferences = await _preferences();
    final events = ProgressSyncEventStore(preferences);
    final brain = BrainTrainingController(
      preferences,
      syncEvents: events,
    );
    addTearDown(brain.dispose);
    addTearDown(events.dispose);

    await brain.recordCompletion(
      gameId: 'n_back',
      score: 420,
    );

    expect(brain.state.completionCountFor('n_back'), 1);
    expect(events.state, hasLength(1));
    expect(
      events.state.single.kind,
      ProgressSyncEventKind.brainSessionCompleted,
    );
    expect(events.state.single.entityId, 'n_back');
    expect(events.state.single.payload['score'], 420);
  });

  test('Meditation changes write timestamped sync events without changing local semantics', () async {
    final preferences = await _preferences();
    final events = ProgressSyncEventStore(preferences);
    final meditation = MeditationLibraryController(
      preferences,
      syncEvents: events,
    );
    addTearDown(meditation.dispose);
    addTearDown(events.dispose);

    await meditation.toggleFavorite('body-scan-5');
    await meditation.markRecent('body-scan-5');
    await meditation.markCompleted('body-scan-5');
    await meditation.toggleFavorite('body-scan-5');

    expect(meditation.state.isFavorite('body-scan-5'), isFalse);
    expect(meditation.state.isCompleted('body-scan-5'), isTrue);
    expect(meditation.state.recentIds.first, 'body-scan-5');

    expect(events.state, hasLength(4));
    expect(
      events.state.map((event) => event.kind),
      containsAll(<ProgressSyncEventKind>[
        ProgressSyncEventKind.meditationFavoriteChanged,
        ProgressSyncEventKind.meditationOpened,
        ProgressSyncEventKind.meditationCompleted,
      ]),
    );

    final favoriteEvents = events.state
        .where(
          (event) =>
              event.kind ==
              ProgressSyncEventKind.meditationFavoriteChanged,
        )
        .toList(growable: false);

    expect(favoriteEvents, hasLength(2));
    expect(favoriteEvents.first.payload['favorite'], isFalse);
    expect(favoriteEvents.last.payload['favorite'], isTrue);
  });

  test('Leaves are intentionally absent from the sync event schema', () {
    expect(
      ProgressSyncEventKind.values.map((kind) => kind.name),
      isNot(contains('leavesChanged')),
    );
    expect(
      ProgressSyncEventKind.values.map((kind) => kind.name),
      isNot(contains('leavesBalance')),
    );
  });
}
