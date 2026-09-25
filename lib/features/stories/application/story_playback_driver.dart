import 'package:audioplayers/audioplayers.dart';

import '../domain/relief_story.dart';

/// A paused-load narration transport, independent of screens and notifications.
/// Implementations must invalidate pending starts synchronously on pause/stop.
abstract interface class StoryPlaybackDriver {
  int get playbackIntentVersion;
  Stream<Duration> get onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged;

  /// Load without audible output. Return measured duration, or null if cancelled.
  Future<Duration?> prepare(ReliefStory story);

  /// Restore media position and rate BEFORE any audible output is permitted.
  Future<void> startAt(Duration position, double rate);
  Future<void> setPlaybackRate(double rate);
  Future<void> seek(Duration position);
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
