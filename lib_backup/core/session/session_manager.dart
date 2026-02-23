import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionManagerProvider =
StateNotifierProvider<SessionManager, SessionState>(
      (ref) => SessionManager(),
);

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
  SessionManager() : super(const SessionState.none());

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
  }

  void clear() {
    state = const SessionState.none();
  }
}