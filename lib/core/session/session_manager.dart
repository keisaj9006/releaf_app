import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';

final sessionManagerProvider =
    StateNotifierProvider<SessionManager, SessionState>((ref) {
  return SessionManager(
    ref.watch(sharedPreferencesProvider),
  );
});

class SessionState {
  final bool hasActive;
  final String title;
  final String subtitle;
  final String resumeRoute;
  final Object? extra;

  const SessionState({
    required this.hasActive,
    required this.title,
    required this.subtitle,
    required this.resumeRoute,
    required this.extra,
  });

  const SessionState.none()
      : hasActive = false,
        title = '',
        subtitle = '',
        resumeRoute = '',
        extra = null;

  SessionState copyWith({
    bool? hasActive,
    String? title,
    String? subtitle,
    String? resumeRoute,
    Object? extra,
  }) {
    return SessionState(
      hasActive: hasActive ?? this.hasActive,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      resumeRoute: resumeRoute ?? this.resumeRoute,
      extra: extra ?? this.extra,
    );
  }
}

class SessionManager extends StateNotifier<SessionState> {
  SessionManager(this._preferences)
      : super(_restore(_preferences));

  static const _activeKey = 'session.active.v1';
  static const _titleKey = 'session.title.v1';
  static const _subtitleKey = 'session.subtitle.v1';
  static const _routeKey = 'session.resume_route.v1';
  static const _extraKey = 'session.extra_json.v1';

  final SharedPreferences _preferences;
  Future<void> _persistenceQueue = Future<void>.value();

  void setPausedSession({
    required String title,
    required String subtitle,
    required String resumeRoute,
    Object? extra,
  }) {
    state = SessionState(
      hasActive: true,
      title: title,
      subtitle: subtitle,
      resumeRoute: resumeRoute,
      extra: extra,
    );

    final encodedExtra = _encodeExtra(extra);
    _queuePersistence(() async {
      await _preferences.setBool(_activeKey, true);
      await _preferences.setString(_titleKey, title);
      await _preferences.setString(_subtitleKey, subtitle);
      await _preferences.setString(_routeKey, resumeRoute);
      if (encodedExtra == null) {
        await _preferences.remove(_extraKey);
      } else {
        await _preferences.setString(_extraKey, encodedExtra);
      }
    });
  }

  void clear() {
    state = const SessionState.none();
    _queuePersistence(() async {
      await _preferences.remove(_activeKey);
      await _preferences.remove(_titleKey);
      await _preferences.remove(_subtitleKey);
      await _preferences.remove(_routeKey);
      await _preferences.remove(_extraKey);
    });
  }

  void _queuePersistence(Future<void> Function() operation) {
    _persistenceQueue = _persistenceQueue.then(
      (_) => operation(),
      onError: (Object _, StackTrace _) => operation(),
    );
  }

  Future<void> flushPersistenceForTesting() => _persistenceQueue;

  static SessionState _restore(SharedPreferences preferences) {
    if (preferences.getBool(_activeKey) != true) {
      return const SessionState.none();
    }

    final title = preferences.getString(_titleKey);
    final subtitle = preferences.getString(_subtitleKey);
    final resumeRoute = preferences.getString(_routeKey);

    if (title == null ||
        subtitle == null ||
        resumeRoute == null ||
        resumeRoute.trim().isEmpty) {
      return const SessionState.none();
    }

    return SessionState(
      hasActive: true,
      title: title,
      subtitle: subtitle,
      resumeRoute: resumeRoute,
      extra: _decodeExtra(preferences.getString(_extraKey)),
    );
  }

  static String? _encodeExtra(Object? extra) {
    if (extra == null) return null;
    if (extra is! Map<String, dynamic>) return null;

    try {
      return jsonEncode(extra);
    } catch (_) {
      return null;
    }
  }

  static Object? _decodeExtra(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      // Invalid persisted session data should never block app startup.
    }
    return null;
  }
}
