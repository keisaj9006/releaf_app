import 'dart:convert';

import 'progress_sync_event_store.dart';

class ProgressSyncProjection {
  const ProgressSyncProjection({
    required this.eventIds,
    required this.brainSessions,
    required this.completedMeditationIds,
    required this.meditationFavorites,
    required this.meditationRecentIds,
    required this.resetCompletions,
  });

  final Set<String> eventIds;
  final List<ProgressSyncEvent> brainSessions;
  final Set<String> completedMeditationIds;
  final Map<String, bool> meditationFavorites;
  final List<String> meditationRecentIds;
  final List<ProgressSyncEvent> resetCompletions;
}

/// Deterministically reduces an immutable event set into product progress.
///
/// This is a pure reconciliation primitive. It performs no network access and
/// writes no local state, so it can be tested independently before runtime
/// cloud sync is enabled.
ProgressSyncProjection projectProgressEvents(
  Iterable<ProgressSyncEvent> events, {
  int meditationRecentLimit = 8,
}) {
  if (meditationRecentLimit < 0) {
    throw ArgumentError.value(
      meditationRecentLimit,
      'meditationRecentLimit',
      'must not be negative',
    );
  }

  final uniqueById = <String, ProgressSyncEvent>{};

  for (final event in events) {
    final normalized = _normalize(event);
    if (normalized == null) continue;

    final existing = uniqueById[normalized.id];
    if (existing == null) {
      uniqueById[normalized.id] = normalized;
      continue;
    }

    if (!_sameImmutableEvent(existing, normalized)) {
      throw StateError(
        'Conflicting immutable progress events share id ${normalized.id}.',
      );
    }
  }

  final ordered = uniqueById.values.toList(growable: false)
    ..sort(_newestFirst);

  final brainSessions = ordered
      .where(
        (event) =>
            event.kind == ProgressSyncEventKind.brainSessionCompleted,
      )
      .toList(growable: false);

  final completedMeditationIds = <String>{
    for (final event in ordered)
      if (event.kind == ProgressSyncEventKind.meditationCompleted)
        event.entityId,
  };

  final meditationFavorites = <String, bool>{};
  for (final event in ordered) {
    if (event.kind != ProgressSyncEventKind.meditationFavoriteChanged ||
        meditationFavorites.containsKey(event.entityId)) {
      continue;
    }

    final favorite = event.payload['favorite'];
    if (favorite is bool) {
      meditationFavorites[event.entityId] = favorite;
    }
  }

  final meditationRecentIds = <String>[];
  final seenRecentIds = <String>{};
  if (meditationRecentLimit > 0) {
    for (final event in ordered) {
      if (event.kind != ProgressSyncEventKind.meditationOpened ||
          !seenRecentIds.add(event.entityId)) {
        continue;
      }

      meditationRecentIds.add(event.entityId);
      if (meditationRecentIds.length >= meditationRecentLimit) break;
    }
  }

  final resetCompletions = ordered
      .where(
        (event) => event.kind == ProgressSyncEventKind.resetSessionCompleted,
      )
      .toList(growable: false);

  return ProgressSyncProjection(
    eventIds: Set<String>.unmodifiable(uniqueById.keys),
    brainSessions: List<ProgressSyncEvent>.unmodifiable(brainSessions),
    completedMeditationIds:
        Set<String>.unmodifiable(completedMeditationIds),
    meditationFavorites:
        Map<String, bool>.unmodifiable(meditationFavorites),
    meditationRecentIds: List<String>.unmodifiable(meditationRecentIds),
    resetCompletions:
        List<ProgressSyncEvent>.unmodifiable(resetCompletions),
  );
}

ProgressSyncEvent? _normalize(ProgressSyncEvent event) {
  final safeId = event.id.trim();
  final safeEntityId = event.entityId.trim();

  if (safeId.isEmpty ||
      !isProgressSyncEventAllowed(
        kind: event.kind,
        entityId: safeEntityId,
      )) {
    return null;
  }

  return ProgressSyncEvent(
    id: safeId,
    kind: event.kind,
    entityId: safeEntityId,
    occurredAt: event.occurredAt.toUtc(),
    payload: Map<String, Object?>.unmodifiable(
      Map<String, Object?>.from(event.payload),
    ),
  );
}

int _newestFirst(ProgressSyncEvent a, ProgressSyncEvent b) {
  final time = b.occurredAt.compareTo(a.occurredAt);
  if (time != 0) return time;
  return b.id.compareTo(a.id);
}

bool _sameImmutableEvent(
  ProgressSyncEvent a,
  ProgressSyncEvent b,
) {
  return a.kind == b.kind &&
      a.entityId == b.entityId &&
      a.occurredAt == b.occurredAt &&
      _canonicalJson(a.payload) == _canonicalJson(b.payload);
}

String _canonicalJson(Object? value) => jsonEncode(_canonicalize(value));

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is List) {
    return value.map(_canonicalize).toList(growable: false);
  }
  return value;
}
