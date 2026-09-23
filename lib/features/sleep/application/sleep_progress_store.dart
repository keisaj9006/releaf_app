import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../account/application/account_auth_service.dart';

class SleepProgressRecord {
  const SleepProgressRecord({
    required this.contentId,
    required this.position,
    required this.duration,
    required this.chapterId,
    required this.updatedAt,
    required this.isCompleted,
    required this.isFavourite,
  });

  final String contentId;
  final Duration position;
  final Duration? duration;
  final String? chapterId;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isFavourite;

  Map<String, Object?> toJson() => <String, Object?>{
    'contentId': contentId,
    'positionMs': position.inMilliseconds,
    'durationMs': duration?.inMilliseconds,
    'chapterId': chapterId,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'isCompleted': isCompleted,
    'isFavourite': isFavourite,
  };

  String encode() => jsonEncode(toJson());

  static SleepProgressRecord? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final contentId = decoded['contentId'];
      final positionMs = decoded['positionMs'];
      final durationMs = decoded['durationMs'];
      final chapterId = decoded['chapterId'];
      final updatedAtRaw = decoded['updatedAt'];
      final isCompleted = decoded['isCompleted'];
      final isFavourite = decoded['isFavourite'];

      if (contentId is! String ||
          contentId.trim().isEmpty ||
          positionMs is! num ||
          positionMs < 0 ||
          (durationMs != null && (durationMs is! num || durationMs < 0)) ||
          (chapterId != null && chapterId is! String) ||
          updatedAtRaw is! String ||
          isCompleted is! bool ||
          isFavourite is! bool) {
        return null;
      }

      final updatedAt = DateTime.tryParse(updatedAtRaw);
      if (updatedAt == null) return null;

      final duration = durationMs == null
          ? null
          : Duration(milliseconds: (durationMs as num).toInt());
      final position = _clampPosition(
        Duration(milliseconds: positionMs.toInt()),
        duration,
      );
      final cleanChapterId = chapterId?.trim();

      return SleepProgressRecord(
        contentId: contentId.trim(),
        position: position,
        duration: duration,
        chapterId: cleanChapterId == null || cleanChapterId.isEmpty
            ? null
            : cleanChapterId,
        updatedAt: updatedAt.toUtc(),
        isCompleted: isCompleted,
        isFavourite: isFavourite,
      );
    } catch (_) {
      return null;
    }
  }
}

final sleepProgressStoreProvider =
    StateNotifierProvider.autoDispose<
      SleepProgressStore,
      List<SleepProgressRecord>
    >((ref) {
      final watchedUser = ref.watch(accountUserProvider).valueOrNull;
      final currentUser = ref.watch(accountAuthServiceProvider).currentUser;
      return SleepProgressStore(
        ref.watch(sharedPreferencesProvider),
        accountId: watchedUser?.id ?? currentUser?.id,
      );
    });

class SleepProgressStore extends StateNotifier<List<SleepProgressRecord>> {
  SleepProgressStore(
    this._preferences, {
    String? accountId,
    DateTime Function()? now,
  }) : _storageKey = storageKeyForAccount(accountId),
       _now = now ?? DateTime.now,
       super(_read(_preferences, storageKeyForAccount(accountId)));

  static const _anonymousScope = 'anonymous';
  static const _storagePrefix = 'sleep.progress.v1';
  static const _maxRecords = 250;

  final SharedPreferences _preferences;
  final String _storageKey;
  final DateTime Function() _now;
  Future<void> _queue = Future<void>.value();

  static String storageKeyForAccount(String? accountId) {
    final cleanAccountId = accountId?.trim();
    final scope = cleanAccountId == null || cleanAccountId.isEmpty
        ? _anonymousScope
        : Uri.encodeComponent(cleanAccountId);
    return '$_storagePrefix.$scope';
  }

  SleepProgressRecord? recordFor(String contentId) {
    final cleanContentId = contentId.trim();
    for (final record in state) {
      if (record.contentId == cleanContentId) return record;
    }
    return null;
  }

  List<SleepProgressRecord> get continueListening {
    final records =
        state
            .where(
              (record) =>
                  !record.isCompleted && record.position > Duration.zero,
            )
            .toList(growable: false)
          ..sort((a, b) {
            final byTime = b.updatedAt.compareTo(a.updatedAt);
            return byTime != 0 ? byTime : a.contentId.compareTo(b.contentId);
          });
    return List<SleepProgressRecord>.unmodifiable(records);
  }

  Future<void> updatePosition({
    required String contentId,
    required Duration position,
    Duration? duration,
    String? chapterId,
  }) {
    final cleanContentId = _requireContentId(contentId);
    final cleanChapterId = _cleanOptional(chapterId);
    final safeDuration = duration == null || duration.isNegative
        ? null
        : duration;

    return _runExclusive(() async {
      final existing = recordFor(cleanContentId);
      final effectiveDuration = safeDuration ?? existing?.duration;
      final record = SleepProgressRecord(
        contentId: cleanContentId,
        position: _clampPosition(position, effectiveDuration),
        duration: effectiveDuration,
        chapterId: cleanChapterId ?? existing?.chapterId,
        updatedAt: _now().toUtc(),
        isCompleted: false,
        isFavourite: existing?.isFavourite ?? false,
      );
      await _replace(record);
    });
  }

  Future<void> markCompleted({
    required String contentId,
    Duration? duration,
    String? chapterId,
  }) {
    final cleanContentId = _requireContentId(contentId);
    final cleanChapterId = _cleanOptional(chapterId);
    final safeDuration = duration == null || duration.isNegative
        ? null
        : duration;

    return _runExclusive(() async {
      final existing = recordFor(cleanContentId);
      final effectiveDuration = safeDuration ?? existing?.duration;
      final record = SleepProgressRecord(
        contentId: cleanContentId,
        position: effectiveDuration ?? existing?.position ?? Duration.zero,
        duration: effectiveDuration,
        chapterId: cleanChapterId ?? existing?.chapterId,
        updatedAt: _now().toUtc(),
        isCompleted: true,
        isFavourite: existing?.isFavourite ?? false,
      );
      await _replace(record);
    });
  }

  Future<void> toggleFavourite(String contentId) {
    final cleanContentId = _requireContentId(contentId);
    return _runExclusive(() async {
      final existing = recordFor(cleanContentId);
      final record = SleepProgressRecord(
        contentId: cleanContentId,
        position: existing?.position ?? Duration.zero,
        duration: existing?.duration,
        chapterId: existing?.chapterId,
        updatedAt: _now().toUtc(),
        isCompleted: existing?.isCompleted ?? false,
        isFavourite: !(existing?.isFavourite ?? false),
      );
      await _replace(record);
    });
  }

  Future<void> clear(String contentId) {
    final cleanContentId = _requireContentId(contentId);
    return _runExclusive(() async {
      final next = state
          .where((record) => record.contentId != cleanContentId)
          .toList(growable: false);
      await _persist(next);
      state = List<SleepProgressRecord>.unmodifiable(next);
    });
  }

  Future<void> _replace(SleepProgressRecord record) async {
    final next = <SleepProgressRecord>[
      record,
      ...state.where((existing) => existing.contentId != record.contentId),
    ].take(_maxRecords).toList(growable: false);
    await _persist(next);
    state = List<SleepProgressRecord>.unmodifiable(next);
  }

  Future<void> _persist(List<SleepProgressRecord> records) {
    return _preferences.setStringList(
      _storageKey,
      records.map((record) => record.encode()).toList(growable: false),
    );
  }

  Future<T> _runExclusive<T>(Future<T> Function() operation) {
    final result = _queue.then<T>((_) => operation());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  static List<SleepProgressRecord> _read(
    SharedPreferences preferences,
    String storageKey,
  ) {
    final raw = preferences.getStringList(storageKey) ?? const <String>[];
    final seenIds = <String>{};
    final records = <SleepProgressRecord>[];
    for (final item in raw) {
      final record = SleepProgressRecord.decode(item);
      if (record == null || !seenIds.add(record.contentId)) continue;
      records.add(record);
      if (records.length >= _maxRecords) break;
    }
    return List<SleepProgressRecord>.unmodifiable(records);
  }

  static String _requireContentId(String contentId) {
    final cleanContentId = contentId.trim();
    if (cleanContentId.isEmpty) {
      throw ArgumentError.value(contentId, 'contentId', 'must not be empty');
    }
    return cleanContentId;
  }

  static String? _cleanOptional(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}

Duration _clampPosition(Duration position, Duration? duration) {
  if (position.isNegative) return Duration.zero;
  if (duration != null && position > duration) return duration;
  return position;
}
