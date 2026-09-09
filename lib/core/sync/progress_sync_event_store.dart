import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';

enum ProgressSyncEventKind {
  brainSessionCompleted,
  meditationCompleted,
  meditationFavoriteChanged,
  meditationOpened,
  resetSessionCompleted,
}

class ProgressSyncEvent {
  const ProgressSyncEvent({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.occurredAt,
    this.payload = const <String, Object?>{},
  });

  final String id;
  final ProgressSyncEventKind kind;
  final String entityId;
  final DateTime occurredAt;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'entityId': entityId,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'payload': payload,
      };

  String encode() => jsonEncode(toJson());

  static ProgressSyncEvent? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final id = decoded['id'];
      final kindName = decoded['kind'];
      final entityId = decoded['entityId'];
      final occurredAtRaw = decoded['occurredAt'];

      if (id is! String ||
          id.isEmpty ||
          kindName is! String ||
          entityId is! String ||
          entityId.isEmpty ||
          occurredAtRaw is! String) {
        return null;
      }

      final occurredAt = DateTime.tryParse(occurredAtRaw);
      final kind = ProgressSyncEventKind.values
          .where((value) => value.name == kindName)
          .firstOrNull;
      if (occurredAt == null || kind == null) return null;

      final payloadRaw = decoded['payload'];
      final payload = <String, Object?>{};
      if (payloadRaw is Map) {
        for (final entry in payloadRaw.entries) {
          payload[entry.key.toString()] = entry.value;
        }
      }

      return ProgressSyncEvent(
        id: id,
        kind: kind,
        entityId: entityId,
        occurredAt: occurredAt.toUtc(),
        payload: payload,
      );
    } catch (_) {
      return null;
    }
  }
}

final progressSyncEventStoreProvider = StateNotifierProvider<
    ProgressSyncEventStore, List<ProgressSyncEvent>>((ref) {
  return ProgressSyncEventStore(
    ref.watch(sharedPreferencesProvider),
  );
});

class ProgressSyncEventStore
    extends StateNotifier<List<ProgressSyncEvent>> {
  ProgressSyncEventStore(
    this._preferences, {
    DateTime Function()? now,
    String? clientInstanceId,
  })  : _now = now ?? DateTime.now,
        _clientInstanceId =
            clientInstanceId ?? _readOrCreateClientInstanceId(_preferences),
        super(_read(_preferences));

  static const _storageKey = 'progress.sync.events.v1';
  static const _clientInstanceKey = 'progress.sync.client_instance.v1';
  static const _maxEvents = 1000;

  final SharedPreferences _preferences;
  final DateTime Function() _now;
  final String _clientInstanceId;
  Future<void> _queue = Future<void>.value();
  int _sequence = 0;

  String get clientInstanceId => _clientInstanceId;

  ProgressSyncEvent createEvent({
    required ProgressSyncEventKind kind,
    required String entityId,
    DateTime? occurredAt,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    final when = (occurredAt ?? _now()).toUtc();
    final id = [
      'v1',
      _clientInstanceId,
      when.microsecondsSinceEpoch,
      kind.name,
      Uri.encodeComponent(entityId),
      _sequence++,
    ].join(':');

    return ProgressSyncEvent(
      id: id,
      kind: kind,
      entityId: entityId,
      occurredAt: when,
      payload: payload,
    );
  }

  Future<void> append(ProgressSyncEvent event) {
    return _runExclusive(() async {
      if (state.any((existing) => existing.id == event.id)) return;

      final next = <ProgressSyncEvent>[
        event,
        ...state,
      ].take(_maxEvents).toList(growable: false);

      state = next;
      await _preferences.setStringList(
        _storageKey,
        next.map((item) => item.encode()).toList(growable: false),
      );
    });
  }

  Future<void> appendNew({
    required ProgressSyncEventKind kind,
    required String entityId,
    DateTime? occurredAt,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return append(
      createEvent(
        kind: kind,
        entityId: entityId,
        occurredAt: occurredAt,
        payload: payload,
      ),
    );
  }

  Future<void> clearUploadedIds(Set<String> uploadedIds) {
    if (uploadedIds.isEmpty) return Future<void>.value();

    return _runExclusive(() async {
      final next = state
          .where((event) => !uploadedIds.contains(event.id))
          .toList(growable: false);
      state = next;
      await _preferences.setStringList(
        _storageKey,
        next.map((item) => item.encode()).toList(growable: false),
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

  static String _readOrCreateClientInstanceId(
    SharedPreferences preferences,
  ) {
    final existing = preferences.getString(_clientInstanceKey)?.trim();
    if (existing != null &&
        RegExp(r'^[a-f0-9]{32}
    final raw = preferences.getStringList(_storageKey) ?? const <String>[];
    final seen = <String>{};
    final events = <ProgressSyncEvent>[];

    for (final item in raw) {
      final decoded = ProgressSyncEvent.decode(item);
      if (decoded == null || !seen.add(decoded.id)) continue;
      events.add(decoded);
      if (events.length >= _maxEvents) break;
    }

    return List<ProgressSyncEvent>.unmodifiable(events);
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
).hasMatch(existing)) {
      return existing;
    }

    final random = Random.secure();
    final id = List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    unawaited(preferences.setString(_clientInstanceKey, id));
    return id;
  }

  static List<ProgressSyncEvent> _read(SharedPreferences preferences) {
    final raw = preferences.getStringList(_storageKey) ?? const <String>[];
    final seen = <String>{};
    final events = <ProgressSyncEvent>[];

    for (final item in raw) {
      final decoded = ProgressSyncEvent.decode(item);
      if (decoded == null || !seen.add(decoded.id)) continue;
      events.add(decoded);
      if (events.length >= _maxEvents) break;
    }

    return List<ProgressSyncEvent>.unmodifiable(events);
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
