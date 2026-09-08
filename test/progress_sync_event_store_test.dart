import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';

Future<SharedPreferences> _preferences(
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  test('Progress sync events round-trip through local storage', () async {
    final preferences = await _preferences(<String, Object>{});
    final now = DateTime.utc(2026, 9, 8, 20, 45);
    final store = ProgressSyncEventStore(
      preferences,
      now: () => now,
    );

    final event = store.createEvent(
      kind: ProgressSyncEventKind.brainSessionCompleted,
      entityId: 'n_back',
      payload: const <String, Object?>{'score': 420},
    );
    await store.append(event);

    final restored = ProgressSyncEventStore(preferences);
    addTearDown(store.dispose);
    addTearDown(restored.dispose);

    expect(restored.state, hasLength(1));
    expect(restored.state.single.id, event.id);
    expect(
      restored.state.single.kind,
      ProgressSyncEventKind.brainSessionCompleted,
    );
    expect(restored.state.single.entityId, 'n_back');
    expect(restored.state.single.occurredAt, now);
    expect(restored.state.single.payload['score'], 420);
  });

  test('Corrupt and duplicate persisted events fail closed', () async {
    final valid = ProgressSyncEvent(
      id: 'event-1',
      kind: ProgressSyncEventKind.meditationCompleted,
      entityId: 'mindfulness-basics-2',
      occurredAt: DateTime.utc(2026, 9, 8, 20),
    ).encode();

    final preferences = await _preferences(<String, Object>{
      'progress.sync.events.v1': <String>[
        valid,
        '{broken json',
        valid,
      ],
    });

    final store = ProgressSyncEventStore(preferences);
    addTearDown(store.dispose);

    expect(store.state, hasLength(1));
    expect(store.state.single.id, 'event-1');
  });

  test('Uploaded event ids can be removed without touching pending events', () async {
    final preferences = await _preferences(<String, Object>{});
    final store = ProgressSyncEventStore(preferences);
    addTearDown(store.dispose);

    final first = store.createEvent(
      kind: ProgressSyncEventKind.meditationOpened,
      entityId: 'body-scan-5',
    );
    final second = store.createEvent(
      kind: ProgressSyncEventKind.meditationFavoriteChanged,
      entityId: 'body-scan-5',
      payload: const <String, Object?>{'favorite': true},
    );

    await store.append(first);
    await store.append(second);
    await store.clearUploadedIds(<String>{first.id});

    expect(store.state, hasLength(1));
    expect(store.state.single.id, second.id);
  });

  test('Event ids remain unique for multiple events at the same instant', () async {
    final preferences = await _preferences(<String, Object>{});
    final now = DateTime.utc(2026, 9, 8, 20, 45);
    final store = ProgressSyncEventStore(
      preferences,
      now: () => now,
    );
    addTearDown(store.dispose);

    final first = store.createEvent(
      kind: ProgressSyncEventKind.meditationOpened,
      entityId: 'open-awareness-6',
    );
    final second = store.createEvent(
      kind: ProgressSyncEventKind.meditationOpened,
      entityId: 'open-awareness-6',
    );

    expect(first.id, isNot(second.id));
  });
}
