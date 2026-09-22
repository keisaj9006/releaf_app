import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';

class ReliefAudioEvents {
  const ReliefAudioEvents(this.interruptions, this.becomingNoisy);
  final Stream<AudioInterruptionEvent> interruptions;
  final Stream<void> becomingNoisy;
}

/// TDD boundary, not installed by main until event routing is verified.
class ReliefAudioRuntime with WidgetsBindingObserver {
  ReliefAudioRuntime({
    required Future<ReliefAudioEvents> Function() eventsFactory,
    required Future<void> Function(AudioInterruptionEvent) onInterruption,
    required Future<void> Function() onNoisy,
    required Future<void> Function() onResume,
    required Future<void> Function() onCheckpoint,
  });

  Future<void> start() async {}
  Future<void> close() async {}
}
