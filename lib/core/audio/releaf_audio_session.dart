import 'package:audio_session/audio_session.dart';

enum ReleafAudioMode {
  sound,
  guidedMeditation,
}

bool releafShouldPauseForInterruption(
  ReleafAudioMode mode,
  AudioInterruptionType type,
) {
  return switch (type) {
    AudioInterruptionType.duck => mode == ReleafAudioMode.guidedMeditation,
    AudioInterruptionType.pause => true,
    AudioInterruptionType.unknown => true,
  };
}

bool releafShouldAutoResumeAfterInterruption(
  ReleafAudioMode mode,
  AudioInterruptionType type,
) {
  return switch (type) {
    AudioInterruptionType.duck => mode == ReleafAudioMode.guidedMeditation,
    AudioInterruptionType.pause => true,
    AudioInterruptionType.unknown => false,
  };
}

Future<AudioSession> configureReleafAudioSession(ReleafAudioMode mode) async {
  final session = await AudioSession.instance;
  await session.configure(
    switch (mode) {
      ReleafAudioMode.sound => const AudioSessionConfiguration.music(),
      ReleafAudioMode.guidedMeditation =>
        const AudioSessionConfiguration.speech(),
    },
  );
  return session;
}
