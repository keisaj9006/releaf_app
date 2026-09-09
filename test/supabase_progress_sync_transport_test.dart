import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';
import 'package:releaf_app/core/sync/supabase_progress_sync_transport.dart';

ProgressSyncEvent _event(
  String id, {
  ProgressSyncEventKind kind = ProgressSyncEventKind.brainSessionCompleted,
  String entityId = 'n_back',
  DateTime? occurredAt,
  Map<String, Object?> payload = const <String, Object?>{},
}) {
  return ProgressSyncEvent(
    id: id,
    kind: kind,
    entityId: entityId,
    occurredAt: occurredAt ?? DateTime.utc(2026, 9, 9, 8, 15),
    payload: payload,
  );
}

void main() {
  test('Unauthenticated transport never writes pending progress', () async {
    var writes = 0;
    final transport = SupabaseProgressSyncTransport(
      currentUserId: () => null,
      writeRows: (_) async {
        writes += 1;
      },
    );

    final acknowledged = await transport.uploadPending(
      <ProgressSyncEvent>[_event('v1:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')],
    );

    expect(acknowledged, isEmpty);
    expect(writes, 0);
  });

  test('Authenticated transport maps event rows without changing semantics',
      () async {
    final writes = <List<Map<String, dynamic>>>[];
    final transport = SupabaseProgressSyncTransport(
      currentUserId: () => '  user-123  ',
      writeRows: (rows) async {
        writes.add(rows);
      },
    );

    final occurredAt = DateTime.parse('2026-09-09T09:15:00+01:00');
    final event = _event(
      'v1:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      kind: ProgressSyncEventKind.meditationFavoriteChanged,
      entityId: 'body-scan-5',
      occurredAt: occurredAt,
      payload: const <String, Object?>{'favorite': false},
    );

    final acknowledged =
        await transport.uploadPending(<ProgressSyncEvent>[event]);

    expect(writes, hasLength(1));
    expect(writes.single, hasLength(1));
    expect(
      writes.single.single,
      <String, dynamic>{
        'user_id': 'user-123',
        'event_id': 'v1:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        'schema_version': 1,
        'kind': 'meditationFavoriteChanged',
        'entity_id': 'body-scan-5',
        'occurred_at': '2026-09-09T08:15:00.000Z',
        'payload': <String, Object?>{'favorite': false},
      },
    );
    expect(
      acknowledged,
      <String>{'v1:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'},
    );
  });

  test('Duplicate local ids are uploaded only once', () async {
    final writes = <List<Map<String, dynamic>>>[];
    final transport = SupabaseProgressSyncTransport(
      currentUserId: () => 'user-123',
      writeRows: (rows) async {
        writes.add(rows);
      },
    );
    final duplicate = _event('v1:cccccccccccccccccccccccccccccccc');

    final acknowledged = await transport.uploadPending(
      <ProgressSyncEvent>[duplicate, duplicate],
    );

    expect(writes, hasLength(1));
    expect(writes.single, hasLength(1));
    expect(acknowledged, hasLength(1));
  });

  test('Large snapshots are written in deterministic batches', () async {
    final writes = <List<Map<String, dynamic>>>[];
    final transport = SupabaseProgressSyncTransport(
      currentUserId: () => 'user-123',
      writeRows: (rows) async {
        writes.add(rows);
      },
      batchSize: 2,
    );

    final acknowledged = await transport.uploadPending(
      <ProgressSyncEvent>[
        _event('v1:00000000000000000000000000000001'),
        _event('v1:00000000000000000000000000000002'),
        _event('v1:00000000000000000000000000000003'),
      ],
    );

    expect(writes.map((batch) => batch.length).toList(), <int>[2, 1]);
    expect(
      writes
          .expand((batch) => batch)
          .map((row) => row['event_id'])
          .toList(),
      <String>[
        'v1:00000000000000000000000000000001',
        'v1:00000000000000000000000000000002',
        'v1:00000000000000000000000000000003',
      ],
    );
    expect(acknowledged, hasLength(3));
  });

  test('Partial upload failure returns no acknowledgement set', () async {
    var writes = 0;
    final transport = SupabaseProgressSyncTransport(
      currentUserId: () => 'user-123',
      writeRows: (_) async {
        writes += 1;
        if (writes == 2) {
          throw StateError('network failed');
        }
      },
      batchSize: 1,
    );

    final future = transport.uploadPending(
      <ProgressSyncEvent>[
        _event('v1:00000000000000000000000000000001'),
        _event('v1:00000000000000000000000000000002'),
      ],
    );

    await expectLater(future, throwsStateError);
    expect(writes, 2);
  });

  test('Batch size must be positive', () {
    expect(
      () => SupabaseProgressSyncTransport(
        currentUserId: () => 'user-123',
        writeRows: (_) async {},
        batchSize: 0,
      ),
      throwsArgumentError,
    );
  });

  test('Emergency usage has no event kind available to this transport', () {
    expect(
      ProgressSyncEventKind.values.map((kind) => kind.name),
      isNot(contains('emergencyOpened')),
    );
    expect(
      ProgressSyncEventKind.values.map((kind) => kind.name),
      isNot(contains('emergencyCompleted')),
    );
  });
}
