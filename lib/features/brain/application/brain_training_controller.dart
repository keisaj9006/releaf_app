import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../../core/sync/progress_sync_event_store.dart';

const progressiveBrainGameIds = <String>{
  'memory',
  'rule_shift',
  'sequence_echo',
  'color_conflict',
  'pattern_logic',
  'signal_scan',
  'broken_mirror',
  'labyrinth',
  'math_race',
  'n_back',
  'spatial_span',
  'mental_rotation',
  'trail_switch',
  'tower_plan',
  'symbol_code',
};

const maxBrainTrainingLevel = 12;
const brainSessionsPerTrainingLevel = 2;

bool usesProgressiveBrainLevel(String gameId) =>
    progressiveBrainGameIds.contains(gameId);

class BrainSessionRecord {
  const BrainSessionRecord({
    required this.gameId,
    required this.completedAt,
    this.score,
  });

  final String gameId;
  final DateTime completedAt;
  final int? score;

  String encode() =>
      '$gameId|${completedAt.millisecondsSinceEpoch}|${score ?? ''}';

  static BrainSessionRecord? decode(String raw) {
    final parts = raw.split('|');
    if (parts.length != 3) return null;

    final epoch = int.tryParse(parts[1]);
    if (epoch == null) return null;

    return BrainSessionRecord(
      gameId: parts[0],
      completedAt: DateTime.fromMillisecondsSinceEpoch(epoch),
      score: parts[2].isEmpty ? null : int.tryParse(parts[2]),
    );
  }
}

class BrainTrainingState {
  const BrainTrainingState({
    this.records = const <BrainSessionRecord>[],
    this.completionCounts = const <String, int>{},
  });

  final List<BrainSessionRecord> records;
  final Map<String, int> completionCounts;

  int get totalSessions {
    final gameIds = <String>{
      ...completionCounts.keys,
      ...records.map((record) => record.gameId),
    };
    return gameIds.fold<int>(
      0,
      (total, gameId) => total + completionCountFor(gameId),
    );
  }

  int get sessionsLast7Days =>
      activityLast7Days.fold<int>(0, (total, value) => total + value);

  int get activeDaysLast7Days =>
      activityLast7Days.where((value) => value > 0).length;

  int get distinctGamesLast7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));

    return records
        .where((record) {
          final local = record.completedAt.toLocal();
          final day = DateTime(local.year, local.month, local.day);
          return !day.isBefore(start) && !day.isAfter(today);
        })
        .map((record) => record.gameId)
        .toSet()
        .length;
  }

  List<int> get activityLast7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List<int>.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return records.where((record) => _sameLocalDay(record.completedAt, day)).length;
    });
  }

  List<DateTime> get activityDaysLast7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
  }

  int completionCountFor(String gameId) {
    final recentCount =
        records.where((record) => record.gameId == gameId).length;
    final cumulativeCount = completionCounts[gameId] ?? 0;
    return cumulativeCount > recentCount ? cumulativeCount : recentCount;
  }

  int trainingLevelFor(String gameId) {
    if (!usesProgressiveBrainLevel(gameId)) return 1;
    final completed = completionCountFor(gameId);
    return (1 + (completed ~/ brainSessionsPerTrainingLevel))
        .clamp(1, maxBrainTrainingLevel)
        .toInt();
  }

  int sessionsUntilNextTrainingLevelFor(String gameId) {
    if (!usesProgressiveBrainLevel(gameId)) return 0;
    final level = trainingLevelFor(gameId);
    if (level >= maxBrainTrainingLevel) return 0;

    final completed = completionCountFor(gameId);
    final withinLevel = completed % brainSessionsPerTrainingLevel;
    return brainSessionsPerTrainingLevel - withinLevel;
  }

  bool playedToday(String gameId) {
    final now = DateTime.now();
    return records.any(
      (record) =>
          record.gameId == gameId && _sameLocalDay(record.completedAt, now),
    );
  }

  int? bestScoreFor(String gameId) {
    int? best;
    for (final record in records) {
      if (record.gameId != gameId || record.score == null) continue;
      if (best == null || record.score! > best) best = record.score;
    }
    return best;
  }

  bool hasCompleted(String gameId) => completionCountFor(gameId) > 0;

  DateTime? lastPlayedFor(String gameId) {
    DateTime? latest;
    for (final record in records) {
      if (record.gameId != gameId) continue;
      if (latest == null || record.completedAt.isAfter(latest)) {
        latest = record.completedAt;
      }
    }
    return latest;
  }

  List<String> get recentGameIds {
    final seen = <String>{};
    final result = <String>[];

    for (final record in records) {
      if (seen.add(record.gameId)) {
        result.add(record.gameId);
      }
      if (result.length == 4) break;
    }
    return result;
  }
}

bool _sameLocalDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();
  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}

final brainTrainingControllerProvider =
    StateNotifierProvider<BrainTrainingController, BrainTrainingState>((ref) {
  return BrainTrainingController(
    ref.watch(sharedPreferencesProvider),
    syncEvents: ref.read(progressSyncEventStoreProvider.notifier),
  );
});

class BrainTrainingController extends StateNotifier<BrainTrainingState> {
  BrainTrainingController(
    this._prefs, {
    ProgressSyncEventStore? syncEvents,
  })  : _syncEvents = syncEvents,
        super(
          BrainTrainingState(
            records: _readRecords(_prefs),
            completionCounts: _readCompletionCounts(_prefs),
          ),
        );

  static const _historyKey = 'brain.training.history.v1';
  static const _completionCountsKey = 'brain.training.completion_counts.v1';
  static const _maxHistoryItems = 120;

  final SharedPreferences _prefs;
  final ProgressSyncEventStore? _syncEvents;

  Future<void> recordCompletion({
    required String gameId,
    int? score,
  }) async {
    final completedAt = DateTime.now();
    final next = <BrainSessionRecord>[
      BrainSessionRecord(
        gameId: gameId,
        score: score,
        completedAt: completedAt,
      ),
      ...state.records,
    ].take(_maxHistoryItems).toList(growable: false);
    final nextCounts = <String, int>{
      ...state.completionCounts,
      gameId: state.completionCountFor(gameId) + 1,
    };

    state = BrainTrainingState(
      records: next,
      completionCounts: nextCounts,
    );
    await _prefs.setStringList(
      _historyKey,
      next.map((record) => record.encode()).toList(growable: false),
    );
    await _prefs.setStringList(
      _completionCountsKey,
      _encodeCompletionCounts(nextCounts),
    );

    await _recordSyncEvent(
      kind: ProgressSyncEventKind.brainSessionCompleted,
      entityId: gameId,
      occurredAt: completedAt,
      payload: <String, Object?>{
        if (score != null) 'score': score,
      },
    );
  }

  Future<void> _recordSyncEvent({
    required ProgressSyncEventKind kind,
    required String entityId,
    DateTime? occurredAt,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    final store = _syncEvents;
    if (store == null) return;

    try {
      await store.appendNew(
        kind: kind,
        entityId: entityId,
        occurredAt: occurredAt,
        payload: payload,
      );
    } catch (_) {
      // Sync preparation must never block local gameplay progress.
    }
  }

  static List<BrainSessionRecord> _readRecords(SharedPreferences prefs) {
    final raw = prefs.getStringList(_historyKey) ?? const <String>[];
    return raw
        .map(BrainSessionRecord.decode)
        .whereType<BrainSessionRecord>()
        .toList(growable: false);
  }

  static Map<String, int> _readCompletionCounts(SharedPreferences prefs) {
    final result = <String, int>{};
    final raw =
        prefs.getStringList(_completionCountsKey) ?? const <String>[];

    for (final item in raw) {
      final separator = item.lastIndexOf('|');
      if (separator <= 0 || separator >= item.length - 1) continue;

      final gameId = item.substring(0, separator).trim();
      final count = int.tryParse(item.substring(separator + 1));
      if (gameId.isEmpty || count == null || count < 0) continue;

      final current = result[gameId] ?? 0;
      if (count > current) result[gameId] = count;
    }

    // Migration path for installs created before cumulative counters existed.
    // Never let a persisted counter be lower than the recent history we can
    // still observe.
    final recentCounts = <String, int>{};
    for (final record in _readRecords(prefs)) {
      recentCounts[record.gameId] = (recentCounts[record.gameId] ?? 0) + 1;
    }
    for (final entry in recentCounts.entries) {
      final persisted = result[entry.key] ?? 0;
      if (entry.value > persisted) result[entry.key] = entry.value;
    }

    return result;
  }

  static List<String> _encodeCompletionCounts(Map<String, int> counts) {
    final entries = counts.entries
        .where((entry) => entry.key.trim().isNotEmpty && entry.value >= 0)
        .toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map((entry) => '${entry.key}|${entry.value}')
        .toList(growable: false);
  }
}
