import 'package:supabase_flutter/supabase_flutter.dart';

import 'progress_sync_event_store.dart';

typedef ProgressSyncUserIdReader = String? Function();
typedef ProgressSyncRowsWriter = Future<void> Function(
  List<Map<String, dynamic>> rows,
);

/// Inactive cloud transport for the local-first progress journal.
///
/// This class is intentionally not wired into providers or app lifecycle yet.
/// It only converts already-persisted local events into idempotent Supabase
/// inserts. The caller remains responsible for clearing acknowledged local ids.
class SupabaseProgressSyncTransport {
  SupabaseProgressSyncTransport({
    required ProgressSyncUserIdReader currentUserId,
    required ProgressSyncRowsWriter writeRows,
    int batchSize = 100,
  })  : _currentUserId = currentUserId,
        _writeRows = writeRows,
        batchSize = _validateBatchSize(batchSize);

  factory SupabaseProgressSyncTransport.forClient(
    SupabaseClient client, {
    int batchSize = 100,
  }) {
    return SupabaseProgressSyncTransport(
      currentUserId: () => client.auth.currentUser?.id,
      writeRows: (rows) async {
        await client.from('progress_events').upsert(
              rows,
              onConflict: 'user_id,event_id',
              ignoreDuplicates: true,
            );
      },
      batchSize: batchSize,
    );
  }

  final ProgressSyncUserIdReader _currentUserId;
  final ProgressSyncRowsWriter _writeRows;
  final int batchSize;

  /// Uploads a snapshot of pending events and returns ids safe to acknowledge.
  ///
  /// No ids are returned unless every batch succeeds. If a later batch fails,
  /// earlier successful rows may already exist remotely, but retrying the same
  /// snapshot is safe because the user/event composite key is idempotent.
  Future<Set<String>> uploadPending(
    Iterable<ProgressSyncEvent> pendingEvents,
  ) async {
    final userId = _currentUserId()?.trim();
    if (userId == null || userId.isEmpty) return <String>{};

    final uniqueEvents = <ProgressSyncEvent>[];
    final seenIds = <String>{};

    for (final event in pendingEvents) {
      if (seenIds.add(event.id)) {
        uniqueEvents.add(event);
      }
    }

    if (uniqueEvents.isEmpty) return <String>{};

    for (var start = 0; start < uniqueEvents.length; start += batchSize) {
      final candidateEnd = start + batchSize;
      final end = candidateEnd < uniqueEvents.length
          ? candidateEnd
          : uniqueEvents.length;
      final rows = uniqueEvents
          .sublist(start, end)
          .map((event) => _toRow(userId, event))
          .toList(growable: false);

      await _writeRows(rows);
    }

    return Set<String>.unmodifiable(seenIds);
  }

  static Map<String, dynamic> _toRow(
    String userId,
    ProgressSyncEvent event,
  ) {
    return <String, dynamic>{
      'user_id': userId,
      'event_id': event.id,
      'schema_version': 1,
      'kind': event.kind.name,
      'entity_id': event.entityId,
      'occurred_at': event.occurredAt.toUtc().toIso8601String(),
      'payload': Map<String, Object?>.from(event.payload),
    };
  }

  static int _validateBatchSize(int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'batchSize', 'must be positive');
    }
    return value;
  }
}
