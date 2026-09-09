import '../../meditation/application/meditation_voice_controller.dart';
import '../domain/reset_voice_guidance.dart';

/// Session-scoped Reset narration playback.
///
/// Recorded Releaf Guide assets always win. If an asset is not bundled or
/// cannot be decoded, the path is remembered for the rest of this session so
/// we do not repeatedly trigger the same asset error on every breathing cycle.
/// Device TTS remains the resilience fallback until the approved recordings are
/// available.
class ResetVoicePlayback {
  ResetVoicePlayback(this._driver);

  final MeditationVoiceDriver _driver;
  final Set<String> _unavailableRecordedAssets = <String>{};

  Set<String> get unavailableRecordedAssets =>
      Set<String>.unmodifiable(_unavailableRecordedAssets);

  Future<void> playCue(ResetVoiceGuidanceCue cue) async {
    final guidance = cue.spokenText.trim();
    if (guidance.isEmpty) return;

    final assetPath = cue.narrationAssetPath?.trim();
    if (assetPath != null &&
        assetPath.isNotEmpty &&
        !_unavailableRecordedAssets.contains(assetPath)) {
      try {
        await _driver.playAsset(assetPath);
        return;
      } catch (_) {
        _unavailableRecordedAssets.add(assetPath);
      }
    }

    await _driver.speak(guidance);
  }

  void resetAssetFailures() {
    _unavailableRecordedAssets.clear();
  }
}
