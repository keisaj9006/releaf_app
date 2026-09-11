import '../../meditation/application/meditation_voice_controller.dart';
import '../domain/reset_voice_guidance.dart';

/// Session-scoped Reset narration playback.
///
/// Only approved recorded Releaf Guide assets or approved natural breathing cues
/// may play. If an asset is not bundled or cannot be decoded, the path is
/// remembered for the rest of this session so we do not repeatedly trigger the
/// same asset error. Releaf deliberately stays silent instead of substituting a
/// device/system voice.
class ResetVoicePlayback {
  ResetVoicePlayback(this._driver);

  final MeditationVoiceDriver _driver;
  final Set<String> _unavailableRecordedAssets = <String>{};
  int _request = 0;

  Set<String> get unavailableRecordedAssets =>
      Set<String>.unmodifiable(_unavailableRecordedAssets);

  void cancelPending() {
    _request++;
  }

  Future<void> playCue(ResetVoiceGuidanceCue cue, {double? volume}) async {
    final request = ++_request;
    // Invalidate the driver before configuration can queue behind an older load.
    try {
      await _driver.stop();
    } catch (_) {
      // A failed stop must not prevent future approved cues from playing.
    }
    if (request != _request) return;
    final assetPath = cue.narrationAssetPath?.trim();
    if (assetPath == null ||
        assetPath.isEmpty ||
        _unavailableRecordedAssets.contains(assetPath)) {
      return;
    }

    if (volume != null) await _driver.configure(volume: volume);
    if (request != _request) return;
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
