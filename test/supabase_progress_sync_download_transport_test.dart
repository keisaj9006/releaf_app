import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';
import 'package:releaf_app/core/sync/supabase_progress_sync_download_transport.dart';

Map<String, dynamic> _row({
  required String id,
  required String kind,
  required String entityId,
  required String occurredAt,
  required String createdAt,
  Object payload = const <String, Object?>{},
  int schemaVersion = 1,
}) {
  return <String, dynamic>{
    'event_id': id,
    'schema_version': schemaVersion,
    'kind': kind,
    'entity_id': entityId,
    'occurred_at': occurredAt,
    'payload': payload,
    'created_at': createdAt,
  };
}

void main() {
  test('download cursor round-trips in UTC', () {
    final cursor = ProgressSyncDownloadCursor(
      createdAt: DateTime.parse('2026-09-09T12:34:56+02:00'),
      eventId: ' event-2 ',
    );

    final decoded = ProgressSyncDownloadCursor.decode(cursor.encode());
    expect(decoded, isNotNull);
    expect(decoded!.createdAt, DateTime.parse('2026-09-09T10:34:56Z'));
    expect(decoded.eventId, 'event-2');
  });

  test('download cursor rejects malformed state', () {
    expect(ProgressSyncDownloadCursor.decode('not-json'), isNull);
    expect(
      ProgressSyncDownloadCursor.decode(
        '{"createdAt":"bad","eventId":"x"}',
      ),
      isNull,
    );
    expect(
      ProgressSyncDownloadCursor.decode(
        '{"createdAt":"2026-09-09T10:00:00Z","eventId":"   "}',
      ),
      isNull,
    );
  });

  test('download stays inert while signed out', () async {
    var reads = 0;
    final transport = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => null,
      readRows: (userId, after, limit) async {
        reads++;
        return <Map<String, dynamic>>[];
      },
    );

    final cursor = ProgressSyncDownloadCursor(
      createdAt: DateTime.parse('2026-09-09T10:00:00Z'),
      eventId: 'event-1',
    );
    final page = await transport.downloadNext(after: cursor);

    expect(reads, 0);
    expect(page.events, isEmpty);
    expect(page.nextCursor, same(cursor));
    expect(page.hasMore, isFalse);
  });

  test('download decodes events and advances by server cursor order', () async {
    ProgressSyncDownloadCursor? receivedCursor;
    var receivedLimit = 0;

    final transport = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => ' user-1 ',
      pageSize: 3,
      readRows: (userId, after, limit) async {
        expect(userId, 'user-1');
        receivedCursor = after;
        receivedLimit = limit;
        return <Map<String, dynamic>>[
          _row(
            id: 'event-c',
            kind: 'meditationFavoriteChanged',
            entityId: 'med-1',
            occurredAt: '2026-09-09T09:00:00Z',
            createdAt: '2026-09-09T10:00:02Z',
            payload: <String, Object?>{'favorite': true},
          ),
          _row(
            id: 'event-a',
            kind: 'brainSessionCompleted',
            entityId: 'memory',
            occurredAt: '2026-09-09T08:00:00Z',
            createdAt: '2026-09-09T10:00:01Z',
            payload: <String, Object?>{'score': 420},
          ),
          _row(
            id: 'event-b',
            kind: 'meditationCompleted',
            entityId: 'med-2',
            occurredAt: '2026-09-09T08:30:00Z',
            createdAt: '2026-09-09T10:00:01Z',
          ),
        ];
      },
    );

    final page = await transport.downloadNext();

    expect(receivedCursor, isNull);
    expect(receivedLimit, 3);
    expect(
      page.events.map((event) => event.id),
      <String>['event-a', 'event-b', 'event-c'],
    );
    expect(page.events.first.occurredAt.isUtc, isTrue);
    expect(
      page.events.last.kind,
      ProgressSyncEventKind.meditationFavoriteChanged,
    );
    expect(page.nextCursor!.eventId, 'event-c');
    expect(
      page.nextCursor!.createdAt,
      DateTime.parse('2026-09-09T10:00:02Z'),
    );
    expect(page.hasMore, isTrue);
  });

  test('invalid or forbidden rows cannot stall cursor advancement', () async {
    final transport = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => 'user-1',
      pageSize: 2,
      readRows: (userId, after, limit) async {
        return <Map<String, dynamic>>[
          _row(
            id: 'event-valid',
            kind: 'brainSessionCompleted',
            entityId: 'memory',
            occurredAt: '2026-09-09T08:00:00Z',
            createdAt: '2026-09-09T10:00:01Z',
          ),
          _row(
            id: 'event-forbidden',
            kind: 'resetSessionCompleted',
            entityId: 'Emergency-Grounding',
            occurredAt: '2026-09-09T08:01:00Z',
            createdAt: '2026-09-09T10:00:02Z',
          ),
        ];
      },
    );

    final page = await transport.downloadNext();

    expect(page.events, hasLength(1));
    expect(page.events.single.id, 'event-valid');
    expect(page.nextCursor!.eventId, 'event-forbidden');
    expect(page.hasMore, isTrue);
  });

  test('unknown schema/kind rows are skipped but do not poison valid rows', () async {
    final transport = SupabaseProgressSyncDownloadTransport(
      currentUserId: () => 'user-1',
      pageSize: 10,
      readRows: (userId, after, limit) async {
        return <Map<String, dynamic>>[
          _row(
            id: 'unknown-schema',
            kind: 'brainSessionCompleted',
            entityId: 'memory',
            occurredAt: '2026-09-09T08:00:00Z',
            createdAt: '2026-09-09T10:00:01Z',
            schemaVersion: 2,
          ),
          _row(
            id: 'unknown-kind',
            kind: 'futureEventKind',
            entityId: 'x',
            occurredAt: '2026-09-09T08:01:00Z',
            createdAt: '2026-09-09T10:00:02Z',
          ),
          _row(
            id: 'valid',
            kind: 'meditationOpened',
            entityId: 'med-3',
            occurredAt: '2026-09-09T08:02:00Z',
            createdAt: '2026-09-09T10:00:03Z',
          ),
        ];
      },
    );

    final page = await transport.downloadNext();

    expect(page.events.map((event) => event.id), <String>['valid']);
    expect(page.nextCursor!.eventId, 'valid');
    expect(page.hasMore, isFalse);
  });

  test('download transport rejects non-positive page size', () {
    expect(
      () => SupabaseProgressSyncDownloadTransport(
        currentUserId: () => 'user-1',
        readRows: (userId, after, limit) async =>
            <Map<String, dynamic>>[],
        pageSize: 0,
      ),
      throwsArgumentError,
    );
  });
}
