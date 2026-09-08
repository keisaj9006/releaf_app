import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/session/session_manager.dart';

void main() {
  test('Paused session restores after a new manager instance', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    final first = SessionManager(preferences);
    first.setPausedSession(
      title: 'Breath & Body',
      subtitle: 'Meditation · 3 min remaining',
      resumeRoute: '/meditate/breath-and-body-4',
      extra: <String, dynamic>{
        'type': 'meditation',
        'remainingSeconds': 180,
      },
    );

    await first.flushPersistenceForTesting();

    final restored = SessionManager(preferences);
    addTearDown(first.dispose);
    addTearDown(restored.dispose);

    expect(restored.state.hasActive, isTrue);
    expect(restored.state.title, 'Breath & Body');
    expect(restored.state.resumeRoute, '/meditate/breath-and-body-4');
    expect(restored.state.extra, isA<Map>());
    expect(
      (restored.state.extra as Map)['remainingSeconds'],
      180,
    );
  });

  test('Clearing a session removes persisted Continue state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'session.active.v1': true,
      'session.title.v1': 'Paused meditation',
      'session.subtitle.v1': '2 min remaining',
      'session.resume_route.v1': '/meditate/example',
      'session.extra_json.v1':
          '{"type":"meditation","remainingSeconds":120}',
    });
    final preferences = await SharedPreferences.getInstance();

    final manager = SessionManager(preferences);
    expect(manager.state.hasActive, isTrue);

    manager.clear();
    await manager.flushPersistenceForTesting();

    final restored = SessionManager(preferences);
    addTearDown(manager.dispose);
    addTearDown(restored.dispose);

    expect(restored.state.hasActive, isFalse);
    expect(preferences.getBool('session.active.v1'), isNull);
  });

  test('Corrupt persisted session data fails closed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'session.active.v1': true,
      'session.title.v1': 'Broken',
      'session.subtitle.v1': 'Broken',
      'session.resume_route.v1': '',
      'session.extra_json.v1': '{not json',
    });
    final preferences = await SharedPreferences.getInstance();

    final manager = SessionManager(preferences);
    addTearDown(manager.dispose);

    expect(manager.state.hasActive, isFalse);
  });
}
