import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';

const progressiveBrainGameIds = <String>{
  'rule_shift',
  'sequence_echo',
  'color_conflict',
  'pattern_logic',
  'signal_scan',
  'broken_mirror',
  'labyrinth',
};

const maxBrainTrainingLevel = 12;

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
  });

  final List<BrainSessionRecord> records;

  int get totalSessions => records.length;

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

  int completionCountFor(String gameId) =>
      records.where((record) => record.gameId == gameId).length;

  int trainingLevelFor(String gameId) {
    if (!usesProgressiveBrainLevel(gameId)) return 1;
    return (completionCountFor(gameId) + 1)
        .clamp(1, maxBrainTrainingLevel)
        .toInt();
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

  bool hasCompleted(String gameId) =>
      records.any((record) => record.gameId == gameId);

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
  );
});

class BrainTrainingController extends StateNotifier<BrainTrainingState> {
  BrainTrainingController(this._prefs)
      : super(
          BrainTrainingState(
            records: _readRecords(_prefs),
          ),
        );

  static const _historyKey = 'brain.training.history.v1';
  static const _maxHistoryItems = 120;

  final SharedPreferences _prefs;

  Future<void> recordCompletion({
    required String gameId,
    int? score,
  }) async {
    final next = <BrainSessionRecord>[
      BrainSessionRecord(
        gameId: gameId,
        score: score,
        completedAt: DateTime.now(),
      ),
      ...state.records,
    ].take(_maxHistoryItems).toList(growable: false);

    state = BrainTrainingState(records: next);
    await _prefs.setStringList(
      _historyKey,
      next.map((record) => record.encode()).toList(growable: false),
    );
  }

  static List<BrainSessionRecord> _readRecords(SharedPreferences prefs) {
    final raw = prefs.getStringList(_historyKey) ?? const <String>[];
    return raw
        .map(BrainSessionRecord.decode)
        .whereType<BrainSessionRecord>()
        .toList(growable: false);
  }
}
