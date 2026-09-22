import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/stories/application/story_player_controller.dart';
import '../../features/stories/application/story_player_state.dart';
import 'relief_shared_audio_handler.dart';

/// Supplied only by the explicitly enabled Owner Preview startup path.
final reliefSharedAudioHandlerProvider = Provider<ReliefSharedAudioHandler?>(
  (ref) => null,
);

/// Reuses the system media handler's controller rather than another decoder.
/// A route must still enforce the preview/content/entitlement gates itself.
final storyPlayerControllerProvider =
    StateNotifierProvider<StoryPlayerController, StoryPlayerState>((ref) {
      final audio = ref.watch(reliefSharedAudioHandlerProvider);
      if (audio == null) {
        throw StateError('Stories playback is available only in Owner Preview.');
      }
      return audio.stories;
    });
