import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';

class ReliefAudioEvents {
  const ReliefAudioEvents(this.interruptions, this.becomingNoisy);
  final Stream<AudioInterruptionEvent> interruptions;
  final Stream<void> becomingNoisy;
}

/// Application-scoped event binding. Content drivers configure speech/music;
/// this boundary only forwards events, even when no player screen is mounted.
class ReliefAudioRuntime with WidgetsBindingObserver {
  ReliefAudioRuntime({
    Future<ReliefAudioEvents> Function()? eventsFactory,
    required Future<void> Function(AudioInterruptionEvent) onInterruption,
    required Future<void> Function() onNoisy,
    required Future<void> Function() onResume,
    required Future<void> Function() onCheckpoint,
  }) : _eventsFactory = eventsFactory ?? _nativeEvents,
       _onInterruption = onInterruption,
       _onNoisy = onNoisy,
       _onResume = onResume,
       _onCheckpoint = onCheckpoint;

  final Future<ReliefAudioEvents> Function() _eventsFactory;
  final Future<void> Function(AudioInterruptionEvent) _onInterruption;
  final Future<void> Function() _onNoisy;
  final Future<void> Function() _onResume;
  final Future<void> Function() _onCheckpoint;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;
  StreamSubscription<void>? _noisy;
  Future<void>? _starting;
  Future<void>? _closing;
  bool _closed = false;
  bool _observing = false;

  static Future<ReliefAudioEvents> _nativeEvents() async {
    final session = await AudioSession.instance;
    return ReliefAudioEvents(
      session.interruptionEventStream,
      session.becomingNoisyEventStream,
    );
  }

  Future<void> start() {
    if (_closed) return Future<void>.value();
    return _starting ??= _start();
  }

  Future<void> _start() async {
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
    try {
      final events = await _eventsFactory();
      if (_closed) return;
      _interruptions = events.interruptions.listen(
        (event) => unawaited(_safe(() => _onInterruption(event))),
        onError: (Object error, StackTrace stack) {
          unawaited(_safe(_onNoisy));
        },
      );
      _noisy = events.becomingNoisy.listen(
        (_) => unawaited(_safe(_onNoisy)),
        onError: (Object error, StackTrace stack) {
          unawaited(_safe(_onNoisy));
        },
      );
    } catch (_) {
      // Failure to establish interruption hooks must not cause an unhandled
      // async error or silently continue existing playback during the failure.
      await _safe(_onNoisy);
    }
  }

  Future<void> _safe(Future<void> Function() action) async {
    if (_closed) return;
    try {
      await action();
    } catch (_) {
      debugPrint('Relief audio event could not be handled.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_closed) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_safe(_onResume));
    } else {
      unawaited(_safe(_onCheckpoint));
    }
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    _closed = true;
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
    // Do not await a pending native factory: its continuation checks _closed
    // and cannot attach listeners after this runtime has been disposed.
    await _interruptions?.cancel();
    await _noisy?.cancel();
    _interruptions = null;
    _noisy = null;
  }
}
