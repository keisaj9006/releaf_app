import '../../meditation/application/meditation_voice_controller.dart';
import '../domain/reset_voice_guidance.dart';

/// Session-scoped Reset narration playback.
///
/// Only approved recorded Releaf Guide assets or the non-verbal breathing cues
/// may play. If an asset is not bundled or cannot be decoded, the path is
/// remembered for the rest of this session so we do not repeatedly trigger the
/// same asset error. Releaf deliberately stays silent instead of substituting a
/// device/system voice.
class ResetVoicePlayback {
  ResetVoicePlayback(this._driver);

  final MeditationVoiceDriver _driver;
  final Set<String> _unavailableRecordedAssets = <String>{};

  Set<String> get unavailableRecordedAssets =>
      Set<String>.unmodifiable(_unavailableRecordedAssets);

  Future<void> playCue(ResetVoiceGuidanceCue cue) async {
    final assetPath = cue.narrationAssetPath?.trim();
    if (assetPath == null ||
        assetPath.isEmpty ||
        _unavailableRecordedAssets.contains(assetPath)) {
      return;
    }

    try {
      await _driver.playAsset(assetPath);
    } catch (_) {
      _unavailableRecordedAssets.add(assetPath);
    }
  }

  void resetAssetFailures() {
    _unavailableRecordedAssets.clear();
  }
}
