import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_progress_sync_download_transport.dart';

/// Durable server-side download cursor.
///
/// The cursor is intentionally persisted separately from product state. A
/// reconciliation coordinator must only save it after every local
/// materialization write for the downloaded page has completed successfully.
class ProgressSyncDownloadCursorStore {
  ProgressSyncDownloadCursorStore(this._preferences);

  static const storageKey = 'progress.sync.download_cursor.v1';

  final SharedPreferences _preferences;

  ProgressSyncDownloadCursor? get current {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    return ProgressSyncDownloadCursor.decode(raw);
  }

  Future<void> save(ProgressSyncDownloadCursor cursor) async {
    final ok = await _preferences.setString(storageKey, cursor.encode());
    if (!ok) {
      throw StateError('Failed to persist progress sync download cursor.');
    }
  }

  Future<void> clear() async {
    final ok = await _preferences.remove(storageKey);
    if (!ok && _preferences.containsKey(storageKey)) {
      throw StateError('Failed to clear progress sync download cursor.');
    }
  }
}
