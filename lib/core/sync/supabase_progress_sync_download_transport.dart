import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'progress_sync_event_store.dart';

typedef ProgressSyncDownloadUserIdReader = String? Function();
typedef ProgressSyncRowsReader = Future<List<Map<String, dynamic>>> Function(
  String userId,
  ProgressSyncDownloadCursor? after,
  int limit,
);

class ProgressSyncDownloadCursor {
  const ProgressSyncDownloadCursor({
    required this.createdAt,
    required this.eventId,
  });

  final DateTime createdAt;
  final String eventId;

  Map<String, Object?> toJson() => <String, Object?>{
        'createdAt': createdAt.toUtc().toIso8601String(),
        'eventId': eventId,
      };

  String encode() => jsonEncode(toJson());

  static ProgressSyncDownloadCursor? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final createdAtRaw = decoded['createdAt'];
      final eventIdRaw = decoded['eventId'];
      if (createdAtRaw is! String || eventIdRaw is! String) return null;

      final createdAt = DateTime.tryParse(createdAtRaw);
      final eventId = eventIdRaw.trim();
      if (createdAt == null || eventId.isEmpty) return null;

      return ProgressSyncDownloadCursor(
        createdAt: createdAt.toUtc(),
        eventId: eventId,
      );
    } catch (_) {
      return null;
    }
  }
}

class ProgressSyncDownloadPage {
  const ProgressSyncDownloadPage({
    required this.events,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<ProgressSyncEvent> events;
  final ProgressSyncDownloadCursor? nextCursor;
  final bool hasMore;
}

/// Inactive read-side transport for the append-only progress event table.
///
/// This class deliberately performs no local writes and is not registered in
/// providers/app lifecycle. A future reconciliation coordinator may combine
/// downloaded events with local events, persist materialized state, and only
/// then store [nextCursor].
class SupabaseProgressSyncDownloadTransport {
  SupabaseProgressSyncDownloadTransport({
    required ProgressSyncDownloadUserIdReader currentUserId,
    required ProgressSyncRowsReader readRows,
    int pageSize = 100,
  })  : _currentUserId = currentUserId,
        _readRows = readRows,
        pageSize = _validatePageSize(pageSize);

  factory SupabaseProgressSyncDownloadTransport.forClient(
    SupabaseClient client, {
    int pageSize = 100,
  }) {
    return SupabaseProgressSyncDownloadTransport(
      currentUserId: () => client.auth.currentUser?.id,
      readRows: (userId, after, limit) async {
        var query = client
            .from('progress_events')
            .select(
              'event_id,schema_version,kind,entity_id,occurred_at,payload,created_at',
            )
            .eq('user_id', userId);

        if (after != null) {
          final createdAt = after.createdAt.toUtc().toIso8601String();
          final eventId = after.eventId.replaceAll(',', r'\,');
          query = query.or(
            'created_at.gt.$createdAt,'
            'and(created_at.eq.$createdAt,event_id.gt.$eventId)',
          );
        }

        final rows = await query
            .order('created_at', ascending: true)
            .order('event_id', ascending: true)
            .limit(limit);

        return rows
            .map<Map<String, dynamic>>(
              (row) => Map<String, dynamic>.from(row),
            )
            .toList(growable: false);
      },
      pageSize: pageSize,
    );
  }

  final ProgressSyncDownloadUserIdReader _currentUserId;
  final ProgressSyncRowsReader _readRows;
  final int pageSize;

  Future<ProgressSyncDownloadPage> downloadNext({
    ProgressSyncDownloadCursor? after,
  }) async {
    final userId = _currentUserId()?.trim();
    if (userId == null || userId.isEmpty) {
      return ProgressSyncDownloadPage(
        events: const <ProgressSyncEvent>[],
        nextCursor: after,
        hasMore: false,
      );
    }

    final rows = await _readRows(userId, after, pageSize);
    if (rows.isEmpty) {
      return ProgressSyncDownloadPage(
        events: const <ProgressSyncEvent>[],
        nextCursor: after,
        hasMore: false,
      );
    }

    final sortable = <_CursorRow>[];
    for (final row in rows) {
      final cursor = _cursorFromRow(row);
      if (cursor == null) continue;
      sortable.add(_CursorRow(cursor: cursor, row: row));
    }
    sortable.sort((a, b) => _compareCursor(a.cursor, b.cursor));

    final events = <ProgressSyncEvent>[];
    for (final item in sortable) {
      final event = _eventFromRow(item.row);
      if (event != null) events.add(event);
    }

    final nextCursor =
        sortable.isEmpty ? after : sortable.last.cursor;

    return ProgressSyncDownloadPage(
      events: List<ProgressSyncEvent>.unmodifiable(events),
      nextCursor: nextCursor,
      hasMore: rows.length >= pageSize,
    );
  }

  static ProgressSyncDownloadCursor? _cursorFromRow(
    Map<String, dynamic> row,
  ) {
    final eventIdRaw = row['event_id'];
    final createdAtRaw = row['created_at'];
    if (eventIdRaw is! String || createdAtRaw is! String) return null;

    final eventId = eventIdRaw.trim();
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (eventId.isEmpty || createdAt == null) return null;

    return ProgressSyncDownloadCursor(
      createdAt: createdAt.toUtc(),
      eventId: eventId,
    );
  }

  static ProgressSyncEvent? _eventFromRow(Map<String, dynamic> row) {
    final schemaVersion = row['schema_version'];
    final eventIdRaw = row['event_id'];
    final kindRaw = row['kind'];
    final entityIdRaw = row['entity_id'];
    final occurredAtRaw = row['occurred_at'];
    final payloadRaw = row['payload'];

    if (schemaVersion != 1 ||
        eventIdRaw is! String ||
        kindRaw is! String ||
        entityIdRaw is! String ||
        occurredAtRaw is! String ||
        payloadRaw is! Map) {
      return null;
    }

    final eventId = eventIdRaw.trim();
    final entityId = entityIdRaw.trim();
    final occurredAt = DateTime.tryParse(occurredAtRaw);
    if (eventId.isEmpty || entityId.isEmpty || occurredAt == null) {
      return null;
    }

    ProgressSyncEventKind? kind;
    for (final candidate in ProgressSyncEventKind.values) {
      if (candidate.name == kindRaw) {
        kind = candidate;
        break;
      }
    }
    if (kind == null ||
        !isProgressSyncEventAllowed(kind: kind, entityId: entityId)) {
      return null;
    }

    final payload = <String, Object?>{};
    for (final entry in payloadRaw.entries) {
      payload[entry.key.toString()] = entry.value;
    }

    return ProgressSyncEvent(
      id: eventId,
      kind: kind,
      entityId: entityId,
      occurredAt: occurredAt.toUtc(),
      payload: Map<String, Object?>.unmodifiable(payload),
    );
  }

  static int _compareCursor(
    ProgressSyncDownloadCursor a,
    ProgressSyncDownloadCursor b,
  ) {
    final time = a.createdAt.compareTo(b.createdAt);
    if (time != 0) return time;
    return a.eventId.compareTo(b.eventId);
  }

  static int _validatePageSize(int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'pageSize', 'must be positive');
    }
    return value;
  }
}

class _CursorRow {
  const _CursorRow({
    required this.cursor,
    required this.row,
  });

  final ProgressSyncDownloadCursor cursor;
  final Map<String, dynamic> row;
}
