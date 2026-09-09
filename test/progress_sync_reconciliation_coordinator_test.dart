import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/sync/progress_sync_cursor_store.dart';
import 'package:releaf_app/core/sync/progress_sync_reconciliation_coordinator.dart';
import 'package:releaf_app/core/sync/supabase_progress_sync_download_transport.dart';

Map<String, dynamic> _row({
  required String id,
  required String kind,
  required String entityId,
  required String occurredAt,
  required String createdAt,
  Object payload = const <String, Object?>{},
}) {
  return <String, dynamic>{
    'event_id': id,
    'schema_version': 1,
    'kind': kind,
    'entity_id': entityId,
    'occurred_at': occurredAt,
    'payload': payload,
    'created_at': createdAt,
  };
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}

void main() {
  test('cursor store round-trips and fails closed on malformed state', () async {
    final preferences = await _preferences();
    final store = ProgressSyncDownloadCursorStore(preferences);
    final cursor = ProgressSyncDownloadCursor(
      createdAt: DateTime.parse('2026-09-09T20:00:00+01:00'),
      eventId: 'event-2',
    );

    expect(store.current, isNull);
    await store.save(cursor);

    expect(store.current, isNotNull);
    expect(store.current!.createdAt, DateTime.parse('2026-09-09T19:00:00Z'));
    expect(store.current!.eventId, 'event-2');

    await preferences.setString(
      ProgressSyncDownloadCursorStore.storageKey,
      '{broken',
    );
    expect(store.current, isNull);
  });

  test('successful materialization advances durable cursor afterwards', () async {
    final preferences = await _preferences();
    final cursorStore = ProgressSyncDownloadCursorStore(preferences);
    final materialized = <String>[];

    final download = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => 'user-1',
      readRows: (userId, after, limit) async => <Map<String, dynamic>>[
        _row(
          id: 'event-1',
          kind: 'brainSessionCompleted',
          entityId: 'memory',
          occurredAt: '2026-09-09T18:00:00Z',
          createdAt: '2026-09-09T19:00:00Z',
          payload: <String, Object?>{'score': 420},
        ),
        _row(
          id: 'event-2',
          kind: 'meditationCompleted',
          entityId: 'body-scan-5',
          occurredAt: '2026-09-09T18:01:00Z',
          createdAt: '2026-09-09T19:00:01Z',
        ),
      ],
    );

    final coordinator = ProgressSyncReconciliationCoordinator(
      download: download,
      cursorStore: cursorStore,
      materialize: (events) async {
        expect(cursorStore.current, isNull);
        materialized.addAll(events.map((event) => event.id));
      },
    );

    final result = await coordinator.reconcileNextPage();

    expect(materialized, <String>['event-1', 'event-2']);
    expect(result.downloadedEvents, 2);
    expect(result.advanced, isTrue);
    expect(cursorStore.current!.eventId, 'event-2');
  });

  test('partial local write failure never advances the server cursor', () async {
    final preferences = await _preferences();
    final cursorStore = ProgressSyncDownloadCursorStore(preferences);
    var attempts = 0;
    final applied = <String>{};

    final download = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => 'user-1',
      readRows: (userId, after, limit) async {
        expect(after, isNull);
        return <Map<String, dynamic>>[
          _row(
            id: 'event-a',
            kind: 'brainSessionCompleted',
            entityId: 'memory',
            occurredAt: '2026-09-09T17:00:00Z',
            createdAt: '2026-09-09T19:00:00Z',
          ),
          _row(
            id: 'event-b',
            kind: 'resetSessionCompleted',
            entityId: 'equal-rhythm',
            occurredAt: '2026-09-09T17:01:00Z',
            createdAt: '2026-09-09T19:00:01Z',
            payload: <String, Object?>{'durationSeconds': 120},
          ),
        ];
      },
    );

    final coordinator = ProgressSyncReconciliationCoordinator(
      download: download,
      cursorStore: cursorStore,
      materialize: (events) async {
        attempts++;
        applied.add(events.first.id);
        if (attempts == 1) {
          throw StateError('simulated second product-store write failure');
        }
        applied.addAll(events.map((event) => event.id));
      },
    );

    await expectLater(
      coordinator.reconcileNextPage(),
      throwsA(isA<StateError>()),
    );
    expect(cursorStore.current, isNull);
    expect(applied, <String>{'event-a'});

    final retry = await coordinator.reconcileNextPage();

    expect(attempts, 2);
    expect(applied, <String>{'event-a', 'event-b'});
    expect(retry.advanced, isTrue);
    expect(cursorStore.current!.eventId, 'event-b');
  });

  test('invalid-only page can advance cursor without materializing data', () async {
    final preferences = await _preferences();
    final cursorStore = ProgressSyncDownloadCursorStore(preferences);
    var materializeCalls = 0;

    final download = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => 'user-1',
      pageSize: 1,
      readRows: (userId, after, limit) async => <Map<String, dynamic>>[
        _row(
          id: 'forbidden',
          kind: 'resetSessionCompleted',
          entityId: 'Emergency-Grounding',
          occurredAt: '2026-09-09T17:00:00Z',
          createdAt: '2026-09-09T19:00:00Z',
        ),
      ],
    );

    final coordinator = ProgressSyncReconciliationCoordinator(
      download: download,
      cursorStore: cursorStore,
      materialize: (events) async {
        materializeCalls++;
        expect(events, isEmpty);
      },
    );

    final result = await coordinator.reconcileNextPage();

    expect(materializeCalls, 1);
    expect(result.downloadedEvents, 0);
    expect(result.advanced, isTrue);
    expect(cursorStore.current!.eventId, 'forbidden');
  });

  test('signed-out reconciliation is inert', () async {
    final preferences = await _preferences();
    final cursorStore = ProgressSyncDownloadCursorStore(preferences);
    var materializeCalls = 0;

    final download = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => null,
      readRows: (userId, after, limit) async {
        fail('signed-out transport must not read rows');
      },
    );

    final coordinator = ProgressSyncReconciliationCoordinator(
      download: download,
      cursorStore: cursorStore,
      materialize: (events) async {
        materializeCalls++;
      },
    );

    final result = await coordinator.reconcileNextPage();

    expect(materializeCalls, 0);
    expect(result.advanced, isFalse);
    expect(cursorStore.current, isNull);
  });
}
