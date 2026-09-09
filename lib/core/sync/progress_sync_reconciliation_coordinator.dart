import 'dart:async';

import 'progress_sync_event_store.dart';
import 'progress_sync_cursor_store.dart';
import 'supabase_progress_sync_download_transport.dart';

typedef ProgressSyncPageMaterializer = Future<void> Function(
  List<ProgressSyncEvent> events,
);

class ProgressSyncReconciliationResult {
  const ProgressSyncReconciliationResult({
    required this.downloadedEvents,
    required this.cursorBefore,
    required this.cursorAfter,
    required this.hasMore,
  });

  final int downloadedEvents;
  final ProgressSyncDownloadCursor? cursorBefore;
  final ProgressSyncDownloadCursor? cursorAfter;
  final bool hasMore;

  bool get advanced => !_sameCursor(cursorBefore, cursorAfter);
}

/// Inactive reconciliation primitive for bidirectional progress sync.
///
/// This coordinator is deliberately not wired into app providers or lifecycle.
/// It provides the failure boundary needed before runtime sync can be enabled:
///
/// 1. download a server page after the durable cursor;
/// 2. materialize all valid events locally;
/// 3. only after materialization succeeds, persist the page cursor.
///
/// [materialize] MUST be idempotent because product writes may succeed while a
/// subsequent cursor write fails. In that case the same server page is retried.
///
/// Calls are serialized so two lifecycle triggers can never race the same
/// cursor.
class ProgressSyncReconciliationCoordinator {
  ProgressSyncReconciliationCoordinator({
    required SupabaseProgressSyncDownloadTransport download,
    required ProgressSyncDownloadCursorStore cursorStore,
    required ProgressSyncPageMaterializer materialize,
  })  : _download = download,
        _cursorStore = cursorStore,
        _materialize = materialize;

  final SupabaseProgressSyncDownloadTransport _download;
  final ProgressSyncDownloadCursorStore _cursorStore;
  final ProgressSyncPageMaterializer _materialize;

  Future<void> _queue = Future<void>.value();

  Future<ProgressSyncReconciliationResult> reconcileNextPage() {
    return _runExclusive(() async {
      final before = _cursorStore.current;
      final page = await _download.downloadNext(after: before);
      final next = page.nextCursor;

      // Signed-out/no-row pages are intentionally inert.
      if (next == null || _sameCursor(before, next)) {
        return ProgressSyncReconciliationResult(
          downloadedEvents: page.events.length,
          cursorBefore: before,
          cursorAfter: before,
          hasMore: page.hasMore,
        );
      }

      // Even a page containing only unknown/forbidden rows must pass through
      // the materialization boundary before its server cursor is acknowledged.
      await _materialize(page.events);
      await _cursorStore.save(next);

      return ProgressSyncReconciliationResult(
        downloadedEvents: page.events.length,
        cursorBefore: before,
        cursorAfter: next,
        hasMore: page.hasMore,
      );
    });
  }

  Future<T> _runExclusive<T>(Future<T> Function() operation) {
    final result = _queue.then<T>((_) => operation());
    _queue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }
}

bool _sameCursor(
  ProgressSyncDownloadCursor? a,
  ProgressSyncDownloadCursor? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a.createdAt.toUtc() == b.createdAt.toUtc() &&
      a.eventId == b.eventId;
}
