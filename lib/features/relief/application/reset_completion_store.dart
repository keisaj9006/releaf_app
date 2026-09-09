import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../../core/sync/progress_sync_event_store.dart';

class ResetCompletionRecord {
  const ResetCompletionRecord({
    required this.id,
    required this.sessionId,
    required this.completedAt,
    required this.durationSeconds,
  });

  final String id;
  final String sessionId;
  final DateTime completedAt;
  final int durationSeconds;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionId': sessionId,
        'completedAt': completedAt.toUtc().toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  String encode() => jsonEncode(toJson());

  static ResetCompletionRecord? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final id = decoded['id'];
      final sessionId = decoded['sessionId'];
      final completedAtRaw = decoded['completedAt'];
      final durationSeconds = decoded['durationSeconds'];

      if (id is! String ||
          id.isEmpty ||
          sessionId is! String ||
          sessionId.isEmpty ||
          completedAtRaw is! String ||
          durationSeconds is! num) {
        return null;
      }

      final completedAt = DateTime.tryParse(completedAtRaw);
      if (completedAt == null || durationSeconds <= 0) return null;

      return ResetCompletionRecord(
        id: id,
        sessionId: sessionId,
        completedAt: completedAt.toUtc(),
        durationSeconds: durationSeconds.toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}

bool shouldJournalResetCompletion({required bool isEmergency}) => !isEmergency;

final resetCompletionStoreProvider = StateNotifierProvider<
    ResetCompletionStore, List<ResetCompletionRecord>>((ref) {
  return ResetCompletionStore(
    ref.watch(sharedPreferencesProvider),
    syncEvents: ref.watch(progressSyncEventStoreProvider.notifier),
  );
});

class ResetCompletionStore
    extends StateNotifier<List<ResetCompletionRecord>> {
  ResetCompletionStore(
    this._preferences, {
    ProgressSyncEventStore? syncEvents,
    DateTime Function()? now,
  })  : _syncEvents = syncEvents,
        _now = now ?? DateTime.now,
        super(_read(_preferences));

  static const _storageKey = 'reset.completions.v1';
  static const _maxRecords = 500;

  final SharedPreferences _preferences;
  final ProgressSyncEventStore? _syncEvents;
  final DateTime Function() _now;
  Future<void> _queue = Future<void>.value();
  int _sequence = 0;

  int get totalCompletions => state.length;

  int completionCountFor(String sessionId) {
    return state.where((record) => record.sessionId == sessionId).length;
  }

  ResetCompletionRecord? latestFor(String sessionId) {
    for (final record in state) {
      if (record.sessionId == sessionId) return record;
    }
    return null;
  }

  int completionCountSince(DateTime instant) {
    final threshold = instant.toUtc();
    return state
        .where((record) => !record.completedAt.isBefore(threshold))
        .length;
  }

  Future<ResetCompletionRecord> recordCompletion({
    required String sessionId,
    required int durationSeconds,
    DateTime? completedAt,
  }) {
    final safeSessionId = sessionId.trim();
    if (safeSessionId.isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'must not be empty');
    }
    if (durationSeconds <= 0) {
      throw ArgumentError.value(
        durationSeconds,
        'durationSeconds',
        'must be positive',
      );
    }

    final when = (completedAt ?? _now()).toUtc();
    final syncEvent = _syncEvents?.createEvent(
      kind: ProgressSyncEventKind.resetSessionCompleted,
      entityId: safeSessionId,
      occurredAt: when,
      payload: <String, Object?>{
        'durationSeconds': durationSeconds,
      },
    );

    final record = ResetCompletionRecord(
      id: syncEvent?.id ??
          [
            'reset-local-v1',
            when.microsecondsSinceEpoch,
            Uri.encodeComponent(safeSessionId),
            _sequence++,
          ].join(':'),
      sessionId: safeSessionId,
      completedAt: when,
      durationSeconds: durationSeconds,
    );

    return _runExclusive(() async {
      final next = <ResetCompletionRecord>[
        record,
        ...state.where((existing) => existing.id != record.id),
      ].take(_maxRecords).toList(growable: false);

      await _preferences.setStringList(
        _storageKey,
        next.map((item) => item.encode()).toList(growable: false),
      );
      state = List<ResetCompletionRecord>.unmodifiable(next);

      final syncEvents = _syncEvents;
      if (syncEvents != null && syncEvent != null) {
        try {
          await syncEvents.append(syncEvent);
        } catch (_) {
          // Local completion is the source of truth. Sync journaling must never
          // turn a completed Reset into a failed user action.
        }
      }

      return record;
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

  static List<ResetCompletionRecord> _read(
    SharedPreferences preferences,
  ) {
    final raw = preferences.getStringList(_storageKey) ?? const <String>[];
    final seen = <String>{};
    final records = <ResetCompletionRecord>[];

    for (final item in raw) {
      final record = ResetCompletionRecord.decode(item);
      if (record == null || !seen.add(record.id)) continue;
      records.add(record);
      if (records.length >= _maxRecords) break;
    }

    return List<ResetCompletionRecord>.unmodifiable(records);
  }
}
