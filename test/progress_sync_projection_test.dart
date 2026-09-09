import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/sync/progress_sync_event_store.dart';
import 'package:releaf_app/core/sync/progress_sync_projection.dart';

ProgressSyncEvent _event({
  required String id,
  required ProgressSyncEventKind kind,
  required String entityId,
  required DateTime occurredAt,
  Map<String, Object?> payload = const <String, Object?>{},
}) {
  return ProgressSyncEvent(
    id: id,
    kind: kind,
    entityId: entityId,
    occurredAt: occurredAt,
    payload: payload,
  );
}

void main() {
  test('Projection is deterministic regardless of input order', () {
    final events = <ProgressSyncEvent>[
      _event(
        id: 'v1:01',
        kind: ProgressSyncEventKind.brainSessionCompleted,
        entityId: 'n_back',
        occurredAt: DateTime.utc(2026, 9, 9, 8),
        payload: const <String, Object?>{'score': 420},
      ),
      _event(
        id: 'v1:02',
        kind: ProgressSyncEventKind.meditationCompleted,
        entityId: 'body-scan-5',
        occurredAt: DateTime.utc(2026, 9, 9, 8, 1),
      ),
      _event(
        id: 'v1:03',
        kind: ProgressSyncEventKind.meditationFavoriteChanged,
        entityId: 'body-scan-5',
        occurredAt: DateTime.utc(2026, 9, 9, 8, 2),
        payload: const <String, Object?>{'favorite': true},
      ),
      _event(
        id: 'v1:04',
        kind: ProgressSyncEventKind.meditationOpened,
        entityId: 'body-scan-5',
        occurredAt: DateTime.utc(2026, 9, 9, 8, 3),
      ),
      _event(
        id: 'v1:05',
        kind: ProgressSyncEventKind.resetSessionCompleted,
        entityId: 'equal-rhythm',
        occurredAt: DateTime.utc(2026, 9, 9, 8, 4),
        payload: const <String, Object?>{'durationSeconds': 120},
      ),
    ];

    final forward = projectProgressEvents(events);
    final reverse = projectProgressEvents(events.reversed);

    expect(forward.eventIds, reverse.eventIds);
    expect(
      forward.brainSessions.map((event) => event.id).toList(),
      reverse.brainSessions.map((event) => event.id).toList(),
    );
    expect(
      forward.completedMeditationIds,
      reverse.completedMeditationIds,
    );
    expect(forward.meditationFavorites, reverse.meditationFavorites);
    expect(forward.meditationRecentIds, reverse.meditationRecentIds);
    expect(
      forward.resetCompletions.map((event) => event.id).toList(),
      reverse.resetCompletions.map((event) => event.id).toList(),
    );
  });

  test('Favorite conflict uses timestamp then event id tie-break', () {
    final timestamp = DateTime.utc(2026, 9, 9, 8);
    final projection = projectProgressEvents(
      <ProgressSyncEvent>[
        _event(
          id: 'v1:aaaaaaaa',
          kind: ProgressSyncEventKind.meditationFavoriteChanged,
          entityId: 'body-scan-5',
          occurredAt: timestamp,
          payload: const <String, Object?>{'favorite': true},
        ),
        _event(
          id: 'v1:bbbbbbbb',
          kind: ProgressSyncEventKind.meditationFavoriteChanged,
          entityId: 'body-scan-5',
          occurredAt: timestamp,
          payload: const <String, Object?>{'favorite': false},
        ),
      ],
    );

    expect(projection.meditationFavorites['body-scan-5'], isFalse);
  });

  test('Recent meditations are newest, unique and capped', () {
    final projection = projectProgressEvents(
      <ProgressSyncEvent>[
        _event(
          id: 'v1:01',
          kind: ProgressSyncEventKind.meditationOpened,
          entityId: 'a',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 4),
        ),
        _event(
          id: 'v1:02',
          kind: ProgressSyncEventKind.meditationOpened,
          entityId: 'b',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 3),
        ),
        _event(
          id: 'v1:03',
          kind: ProgressSyncEventKind.meditationOpened,
          entityId: 'a',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 2),
        ),
        _event(
          id: 'v1:04',
          kind: ProgressSyncEventKind.meditationOpened,
          entityId: 'c',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 1),
        ),
      ],
      meditationRecentLimit: 2,
    );

    expect(projection.meditationRecentIds, <String>['a', 'b']);
  });

  test('Exact duplicate event ids dedupe but conflicting ids fail closed', () {
    final first = _event(
      id: 'v1:same',
      kind: ProgressSyncEventKind.meditationCompleted,
      entityId: 'body-scan-5',
      occurredAt: DateTime.utc(2026, 9, 9, 8),
    );
    final exactDuplicate = _event(
      id: 'v1:same',
      kind: ProgressSyncEventKind.meditationCompleted,
      entityId: 'body-scan-5',
      occurredAt: DateTime.utc(2026, 9, 9, 8),
    );

    final deduped = projectProgressEvents(
      <ProgressSyncEvent>[first, exactDuplicate],
    );
    expect(deduped.eventIds, <String>{'v1:same'});

    final conflict = _event(
      id: 'v1:same',
      kind: ProgressSyncEventKind.meditationCompleted,
      entityId: 'different-session',
      occurredAt: DateTime.utc(2026, 9, 9, 8),
    );

    expect(
      () => projectProgressEvents(<ProgressSyncEvent>[first, conflict]),
      throwsStateError,
    );
  });

  test('Emergency Reset events never enter a projection', () {
    final projection = projectProgressEvents(
      <ProgressSyncEvent>[
        _event(
          id: 'v1:forbidden',
          kind: ProgressSyncEventKind.resetSessionCompleted,
          entityId: ' Emergency-Grounding ',
          occurredAt: DateTime.utc(2026, 9, 9, 8),
          payload: const <String, Object?>{'durationSeconds': 120},
        ),
        _event(
          id: 'v1:allowed',
          kind: ProgressSyncEventKind.resetSessionCompleted,
          entityId: 'equal-rhythm',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 1),
          payload: const <String, Object?>{'durationSeconds': 120},
        ),
      ],
    );

    expect(projection.eventIds, <String>{'v1:allowed'});
    expect(
      projection.resetCompletions.map((event) => event.entityId).toList(),
      <String>['equal-rhythm'],
    );
  });

  test('Invalid favorite payload cannot mutate projected favorite state', () {
    final projection = projectProgressEvents(
      <ProgressSyncEvent>[
        _event(
          id: 'v1:invalid',
          kind: ProgressSyncEventKind.meditationFavoriteChanged,
          entityId: 'body-scan-5',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 2),
          payload: const <String, Object?>{'favorite': 'yes'},
        ),
        _event(
          id: 'v1:valid',
          kind: ProgressSyncEventKind.meditationFavoriteChanged,
          entityId: 'body-scan-5',
          occurredAt: DateTime.utc(2026, 9, 9, 8, 1),
          payload: const <String, Object?>{'favorite': true},
        ),
      ],
    );

    expect(projection.meditationFavorites['body-scan-5'], isTrue);
  });

  test('Recent limit cannot be negative', () {
    expect(
      () => projectProgressEvents(
        const <ProgressSyncEvent>[],
        meditationRecentLimit: -1,
      ),
      throwsArgumentError,
    );
  });
}
