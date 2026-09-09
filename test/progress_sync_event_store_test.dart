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
      eventNonce: () => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
    addTearDown(store.dispose);

    final event = store.createEvent(
      kind: ProgressSyncEventKind.brainSessionCompleted,
      entityId: 'n_back',
      payload: const <String, Object?>{'score': 420},
    );
    await store.append(event);

    final restored = ProgressSyncEventStore(preferences);
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

  test('Uploaded event ids can be removed without touching pending events',
      () async {
    final preferences = await _preferences(<String, Object>{});
    var nonce = 0;
    final store = ProgressSyncEventStore(
      preferences,
      eventNonce: () {
        nonce += 1;
        return nonce.toRadixString(16).padLeft(32, '0');
      },
    );
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

  test('Event ids remain unique for multiple events at the same instant',
      () async {
    final preferences = await _preferences(<String, Object>{});
    final now = DateTime.utc(2026, 9, 8, 20, 45);
    var sequence = 0;
    final store = ProgressSyncEventStore(
      preferences,
      now: () => now,
      eventNonce: () {
        sequence += 1;
        return sequence.toRadixString(16).padLeft(32, '0');
      },
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

    expect(first.occurredAt, second.occurredAt);
    expect(first.id, 'v1:00000000000000000000000000000001');
    expect(second.id, 'v1:00000000000000000000000000000002');
    expect(first.id, isNot(second.id));
  });

  test('Independent clients cannot collide at the same instant', () async {
    final firstPreferences = await _preferences(<String, Object>{});
    final secondPreferences = await _preferences(<String, Object>{});
    final now = DateTime.utc(2026, 9, 9, 7, 30);

    final firstStore = ProgressSyncEventStore(
      firstPreferences,
      now: () => now,
      eventNonce: () => '11111111111111111111111111111111',
    );
    final secondStore = ProgressSyncEventStore(
      secondPreferences,
      now: () => now,
      eventNonce: () => '22222222222222222222222222222222',
    );
    addTearDown(firstStore.dispose);
    addTearDown(secondStore.dispose);

    final first = firstStore.createEvent(
      kind: ProgressSyncEventKind.brainSessionCompleted,
      entityId: 'n_back',
    );
    final second = secondStore.createEvent(
      kind: ProgressSyncEventKind.brainSessionCompleted,
      entityId: 'n_back',
    );

    expect(first.id, 'v1:11111111111111111111111111111111');
    expect(second.id, 'v1:22222222222222222222222222222222');
    expect(first.id, isNot(second.id));
  });

  test('Generated event ids are opaque and persist no device identifier',
      () async {
    final preferences = await _preferences(<String, Object>{});
    final store = ProgressSyncEventStore(preferences);
    addTearDown(store.dispose);

    final first = store.createEvent(
      kind: ProgressSyncEventKind.meditationOpened,
      entityId: 'open-awareness-6',
    );
    final second = store.createEvent(
      kind: ProgressSyncEventKind.meditationOpened,
      entityId: 'open-awareness-6',
    );

    expect(first.id, matches(RegExp(r'^v1:[a-f0-9]{32}$')));
    expect(second.id, matches(RegExp(r'^v1:[a-f0-9]{32}$')));
    expect(first.id, isNot(second.id));
    expect(
      preferences.getString('progress.sync.client_instance.v1'),
      isNull,
    );
  });
}
