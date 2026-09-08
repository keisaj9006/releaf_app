import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/audio/releaf_audio_session.dart';

void main() {
  test('Sound lets the platform duck but pauses for stronger interruptions', () {
    expect(
      releafShouldPauseForInterruption(
        ReleafAudioMode.sound,
        AudioInterruptionType.duck,
      ),
      isFalse,
    );
    expect(
      releafShouldPauseForInterruption(
        ReleafAudioMode.sound,
        AudioInterruptionType.pause,
      ),
      isTrue,
    );
    expect(
      releafShouldPauseForInterruption(
        ReleafAudioMode.sound,
        AudioInterruptionType.unknown,
      ),
      isTrue,
    );
  });

  test('Guided meditation pauses for duck pause and unknown interruptions', () {
    for (final type in AudioInterruptionType.values) {
      expect(
        releafShouldPauseForInterruption(
          ReleafAudioMode.guidedMeditation,
          type,
        ),
        isTrue,
        reason: type.name,
      );
    }
  });

  test('Unknown interruptions never auto-resume', () {
    for (final mode in ReleafAudioMode.values) {
      expect(
        releafShouldAutoResumeAfterInterruption(
          mode,
          AudioInterruptionType.unknown,
        ),
        isFalse,
      );
    }
  });

  test('Normal pause can auto-resume and meditation duck can resume', () {
    expect(
      releafShouldAutoResumeAfterInterruption(
        ReleafAudioMode.sound,
        AudioInterruptionType.pause,
      ),
      isTrue,
    );
    expect(
      releafShouldAutoResumeAfterInterruption(
        ReleafAudioMode.guidedMeditation,
        AudioInterruptionType.duck,
      ),
      isTrue,
    );
    expect(
      releafShouldAutoResumeAfterInterruption(
        ReleafAudioMode.sound,
        AudioInterruptionType.duck,
      ),
      isFalse,
    );
  });
}
