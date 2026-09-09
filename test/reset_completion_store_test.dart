import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';
import 'package:releaf_app/features/relief/application/reset_completion_store.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}

void main() {
  test('Reset completion persists locally and writes the same id to sync journal', () async {
    final preferences = await _preferences();
    final sync = ProgressSyncEventStore(preferences);
    final now = DateTime.utc(2026, 9, 9, 7, 30);
    final store = ResetCompletionStore(
      preferences,
      syncEvents: sync,
      now: () => now,
    );
    addTearDown(sync.dispose);
    addTearDown(store.dispose);

    final record = await store.recordCompletion(
      sessionId: 'equal-rhythm',
      durationSeconds: 120,
    );

    expect(store.state, hasLength(1));
    expect(store.state.single.sessionId, 'equal-rhythm');
    expect(store.state.single.durationSeconds, 120);
    expect(store.state.single.completedAt, now);

    expect(sync.state, hasLength(1));
    expect(record.id, contains(sync.clientInstanceId));
    expect(sync.state.single.id, record.id);
    expect(
      sync.state.single.kind,
      ProgressSyncEventKind.resetSessionCompleted,
    );
    expect(sync.state.single.entityId, 'equal-rhythm');
    expect(sync.state.single.payload['durationSeconds'], 120);

    final restored = ResetCompletionStore(preferences);
    addTearDown(restored.dispose);

    expect(restored.state, hasLength(1));
    expect(restored.state.single.id, record.id);
  });

  test('Two Reset completions at the same instant still get unique ids', () async {
    final preferences = await _preferences();
    final now = DateTime.utc(2026, 9, 9, 7, 30);
    final store = ResetCompletionStore(
      preferences,
      now: () => now,
    );
    addTearDown(store.dispose);

    final first = await store.recordCompletion(
      sessionId: 'equal-rhythm',
      durationSeconds: 120,
    );
    final second = await store.recordCompletion(
      sessionId: 'equal-rhythm',
      durationSeconds: 120,
    );

    expect(first.id, isNot(second.id));
    expect(store.state, hasLength(2));
    expect(store.totalCompletions, 2);
    expect(store.completionCountFor('equal-rhythm'), 2);
    expect(store.latestFor('equal-rhythm')?.id, second.id);
    expect(
      store.completionCountSince(now.subtract(const Duration(seconds: 1))),
      2,
    );
  });

  test('Corrupt and duplicate Reset completion records fail closed', () async {
    final valid = ResetCompletionRecord(
      id: 'reset-v1:1:equal-rhythm:0',
      sessionId: 'equal-rhythm',
      completedAt: DateTime.utc(2026, 9, 9, 7, 30),
      durationSeconds: 120,
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'reset.completions.v1': <String>[
        valid.encode(),
        valid.encode(),
        '{not-json',
        '{"id":"","sessionId":"bad","completedAt":"x","durationSeconds":0}',
      ],
    });
    final preferences = await SharedPreferences.getInstance();
    final store = ResetCompletionStore(preferences);
    addTearDown(store.dispose);

    expect(store.state, hasLength(1));
    expect(store.state.single.id, valid.id);
  });

  test('Emergency sessions are excluded from Reset progress journaling', () {
    expect(
      shouldJournalResetCompletion(isEmergency: true),
      isFalse,
    );
    expect(
      shouldJournalResetCompletion(isEmergency: false),
      isTrue,
    );
  });
}
