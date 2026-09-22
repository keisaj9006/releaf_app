import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/sound/application/sound_player_controller.dart';
import '../../features/sound/data/sound_catalog.dart';
import '../../features/stories/application/story_playback_driver.dart';
import '../../features/stories/application/story_player_controller.dart';
import '../../features/stories/data/story_playback_store.dart';

enum ReliefMediaOwner { none, sound, story }

/// Compile-only TDD boundary. Not installed in main.dart. The next commit must
/// implement exclusive ownership before this can be used by an app build.
class ReliefSharedAudioHandler extends BaseAudioHandler {
  ReliefSharedAudioHandler({
    required SharedPreferences preferences,
    required SoundPlaybackDriver soundDriver,
    required StoryPlaybackDriver storyDriver,
    required Future<void> Function() configureSoundSession,
    DateTime Function()? now,
  }) : sound = SoundPlayerController(const SoundCatalog(), preferences, driver: soundDriver, now: now),
       stories = StoryPlayerController(store: StoryPlaybackStore(preferences), driver: storyDriver, now: now);

  final SoundPlayerController sound;
  final StoryPlayerController stories;
  ReliefMediaOwner get owner => ReliefMediaOwner.none;
  Future<void> handleAudioInterruption(AudioInterruptionEvent event) async {}
  Future<void> handleBecomingNoisy() async {}
  Future<void> onAppResumed() async {}
  Future<void> close() async { sound.dispose(); stories.dispose(); }
}
