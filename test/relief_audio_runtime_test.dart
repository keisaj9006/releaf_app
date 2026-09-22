import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/audio/relief_audio_runtime.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // This contract has no widget frames. Run stream setup/cleanup on the real
  // async event loop rather than awaiting cleanup inside a widget fake clock.
  test('one root subscription forwards interruption and headphone events once', () async {
    final interruptions = StreamController<AudioInterruptionEvent>.broadcast();
    final noisy = StreamController<void>.broadcast();
    final seen = <AudioInterruptionEvent>[];
    var pauses = 0;
    final runtime = ReliefAudioRuntime(
      eventsFactory: () async => ReliefAudioEvents(interruptions.stream, noisy.stream),
      onInterruption: (event) async { seen.add(event); },
      onNoisy: () async { pauses++; },
      onResume: () async {}, onCheckpoint: () async {},
    );
    await runtime.start();
    await runtime.start();
    final beginning = AudioInterruptionEvent(true, AudioInterruptionType.pause);
    final ending = AudioInterruptionEvent(false, AudioInterruptionType.pause);
    interruptions.add(beginning); interruptions.add(ending); noisy.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(seen, [beginning, ending]);
    expect(pauses, 1);
    await runtime.close();
    await runtime.close();
    expect(interruptions.hasListener, isFalse);
    expect(noisy.hasListener, isFalse);
    noisy.add(null); interruptions.add(beginning);
    await Future<void>.delayed(Duration.zero);
    expect(pauses, 1);
    expect(seen, hasLength(2));
    await interruptions.close(); await noisy.close();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('root checkpoints background and resynchronises resume with no player widget', (tester) async {
    var checkpoints = 0;
    var resumes = 0;
    final runtime = ReliefAudioRuntime(
      eventsFactory: () async => const ReliefAudioEvents(Stream.empty(), Stream.empty()),
      onInterruption: (_) async {}, onNoisy: () async {},
      onResume: () async { resumes++; },
      onCheckpoint: () async { checkpoints++; },
    );
    await runtime.start();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(checkpoints, greaterThanOrEqualTo(1));
    expect(resumes, 1);
    await runtime.close();
    final previous = checkpoints;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(checkpoints, previous);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('late native event setup cannot subscribe after runtime is closed', (tester) async {
    final ready = Completer<ReliefAudioEvents>();
    final noisy = StreamController<void>.broadcast();
    var pauses = 0;
    final runtime = ReliefAudioRuntime(
      eventsFactory: () => ready.future,
      onInterruption: (_) async {}, onNoisy: () async { pauses++; },
      onResume: () async {}, onCheckpoint: () async {},
    );
    final starting = runtime.start();
    await runtime.close();
    ready.complete(ReliefAudioEvents(const Stream.empty(), noisy.stream));
    await starting;
    expect(noisy.hasListener, isFalse);
    noisy.add(null); await tester.pump();
    expect(pauses, 0);
    await noisy.close();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('native event stream failure requests a safe pause without an unhandled error', (tester) async {
    final events = StreamController<AudioInterruptionEvent>.broadcast();
    var pauses = 0;
    final runtime = ReliefAudioRuntime(
      eventsFactory: () async => ReliefAudioEvents(events.stream, const Stream.empty()),
      onInterruption: (_) async {}, onNoisy: () async { pauses++; },
      onResume: () async {}, onCheckpoint: () async {},
    );
    await runtime.start();
    events.addError(StateError('Native audio events failed'));
    await tester.pump();
    expect(pauses, 1);
    expect(tester.takeException(), isNull);
    await runtime.close(); await events.close();
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('native setup and async callback failures do not escape the root boundary', (tester) async {
    final runtime = ReliefAudioRuntime(
      eventsFactory: () async => throw StateError('Native setup failed'),
      onInterruption: (_) async => throw StateError('Interruption failed'),
      onNoisy: () async => throw StateError('Pause failed'),
      onResume: () async => throw StateError('Resume failed'),
      onCheckpoint: () async => throw StateError('Save failed'),
    );
    await runtime.start();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await runtime.close();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('shared startup is preview-only and its root uses the same controllers', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('StoryPreviewConfig.enabled'));
    expect(main, contains('AudioService.init<ReliefSharedAudioHandler>'));
    expect(main, contains('soundPlayerControllerProvider.overrideWith'));
    expect(main, contains('reliefSharedAudioHandlerProvider.overrideWithValue'));
    expect(main, contains('ReliefAudioRuntime('));
    expect(main, contains('onInterruption: audio.handleAudioInterruption'));
    expect(main, contains('onNoisy: audio.handleBecomingNoisy'));
    expect(main, contains('onResume: audio.onAppResumed'));
    expect(main, contains('onCheckpoint: audio.checkpoint'));
    final screen = File('lib/features/sound/presentation/sound_player_screen.dart').readAsStringSync();
    expect(screen, contains('ReliefManagedSoundController'));
    final configure = screen.substring(screen.indexOf('Future<void> _configureAudioSession()'));
    expect(configure.indexOf('ReliefManagedSoundController'), lessThan(configure.indexOf('configureReleafAudioSession')));
  });
}
