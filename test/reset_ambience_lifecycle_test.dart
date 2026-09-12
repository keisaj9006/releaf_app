import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';

class _DelayedPlayer implements AudioPlayer {
  _DelayedPlayer({this.delaySource = false});
  final bool delaySource;
  final sourceLoading = Completer<void>();
  final sourceReady = Completer<void>();
  String? sourcePath;
  final preparing = Completer<void>();
  final prepared = Completer<void>();
  final List<String> played = [];
  bool disposed = false;

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    if (!preparing.isCompleted) preparing.complete();
    await prepared.future;
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    await setSource(source);
    await resume();
  }

  @override
  Future<void> setSource(Source source) async {
    sourcePath = (source as AssetSource).path;
    if (!sourceLoading.isCompleted) sourceLoading.complete();
    if (delaySource) await sourceReady.future;
  }

  @override
  Future<void> resume() async {
    played.add(sourcePath!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final action in [
    'background',
    'exit',
    'mute',
    'background and resume',
  ]) {
    testWidgets('$action cancels pending Reset ambience', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final player = _DelayedPlayer(delaySource: true);
      player.prepared.complete();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            resetAmbientPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: BreathingWidget(sessionId: 'equal-rhythm'),
          ),
        ),
      );
      await tester.pump();
      expect(player.sourceLoading.isCompleted, isTrue);
      if (action.startsWith('background')) {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        if (action == 'background and resume') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        }
      } else if (action == 'exit') {
        await tester.pumpWidget(const SizedBox.shrink());
      } else {
        await tester.tap(find.byTooltip('Session audio'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('reset-active-master-mute')));
      }
      await tester.pump();
      player.sourceReady.complete();
      await tester.pump();
      expect(
        player.played,
        action == 'background and resume' ? ['sounds/deep_drift.mp3'] : isEmpty,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  }
}
