import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/story_playback_policy.dart';
import '../domain/relief_story.dart';

class StoryProgress {
  const StoryProgress({
    this.position = Duration.zero,
    this.completed = false,
  });

  static const empty = StoryProgress();

  final Duration position;
  final bool completed;
}

/// Local, non-critical playback preferences; not cloud sync or rights evidence.
/// Use one store per playback scope so writes preserve user-request ordering.
class StoryPlaybackStore {
  StoryPlaybackStore(this._preferences);

  final SharedPreferences _preferences;
  Future<void> _writes = Future<void>.value();

  static const _rateKey = 'stories.v1.rate';
  static const _lastPlayedKey = 'stories.v1.last_played_id';

  String _progressKey(ReliefStory story) =>
      'stories.v1.progress|${Uri.encodeComponent(story.id)}|'
      '${Uri.encodeComponent(story.scriptVersion)}|'
      '${Uri.encodeComponent(story.audioVersion)}';

  String _warningKey(ReliefStory story) =>
      'stories.v1.warning|${Uri.encodeComponent(story.id)}|'
      '${Uri.encodeComponent(story.scriptVersion)}';

  /// A failed write is reported to the caller and cannot poison later writes.
  Future<bool> _enqueue(Future<bool> Function() action) {
    final result = _writes.then((_) async {
      try {
        return await action();
      } catch (_) {
        return false;
      }
    });
    _writes = result.then<void>((_) {});
    return result;
  }

  double get playbackRate =>
      StoryPlaybackPolicy.normaliseRate(_preferences.get(_rateKey));

  String? get lastPlayedId {
    final value = _preferences.get(_lastPlayedKey);
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  StoryProgress readProgress(
    ReliefStory story, {
    required Duration duration,
  }) {
    if (!StoryPlaybackPolicy.hasDeliveryMetadata(story) ||
        duration <= Duration.zero) {
      return StoryProgress.empty;
    }
    final raw = _preferences.get(_progressKey(story));
    if (raw is! String) return StoryProgress.empty;
    try {
      final record = jsonDecode(raw);
      if (record is! Map<String, dynamic> || record['schema'] != 1) {
        return StoryProgress.empty;
      }
      final milliseconds = record['positionMs'];
      final completed = record['completed'];
      if (milliseconds is! int || milliseconds < 0 || completed is! bool) {
        return StoryProgress.empty;
      }
      // Clamp untrusted stored integers before constructing a Duration.
      final safeMs = milliseconds.clamp(0, duration.inMilliseconds).toInt();
      return StoryProgress(
        position: Duration(milliseconds: safeMs),
        completed: completed,
      );
    } on FormatException {
      return StoryProgress.empty;
    }
  }

  Future<bool> saveProgress(
    ReliefStory story, {
    required Duration position,
    required Duration duration,
    bool completed = false,
  }) {
    if (!StoryPlaybackPolicy.hasDeliveryMetadata(story) ||
        duration <= Duration.zero) {
      return Future<bool>.value(false);
    }
    final safe = StoryPlaybackPolicy.clampPosition(position, duration);
    return _enqueue(() async {
      final previous = readProgress(story, duration: duration);
      // The controller must explicitly report a listening completion. Merely
      // seeking into the last 5% is not evidence that playback completed.
      final isComplete = previous.completed ||
          (completed && safe.inMicroseconds / duration.inMicroseconds >= 0.95);
      final saved = await _preferences.setString(
        _progressKey(story),
        jsonEncode(<String, Object>{
          'schema': 1,
          'positionMs': safe.inMilliseconds,
          'completed': isComplete,
        }),
      );
      if (!saved) return false;
      return _preferences.setString(_lastPlayedKey, story.id);
    });
  }

  Future<bool> resetProgress(ReliefStory story) =>
      _enqueue(() => _preferences.remove(_progressKey(story)));

  Future<bool> setPlaybackRate(double rate) {
    if (!rate.isFinite || !StoryPlaybackPolicy.supportedRates.contains(rate)) {
      return Future<bool>.value(false);
    }
    return _enqueue(() => _preferences.setDouble(_rateKey, rate));
  }

  bool isWarningAcknowledged(ReliefStory story) {
    if (story.contentWarning.trim().isEmpty) return true;
    return _preferences.get(_warningKey(story)) == story.contentWarning;
  }

  /// Call only following an explicit acknowledgement in the warning UI.
  /// Exact text matching forces a new acknowledgement when the warning changes.
  Future<bool> acknowledgeWarning(ReliefStory story) {
    if (story.contentWarning.trim().isEmpty) return Future<bool>.value(true);
    return _enqueue(
      () => _preferences.setString(_warningKey(story), story.contentWarning),
    );
  }
}
