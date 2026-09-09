/// Presentation and audio preferences selected before a Reset session starts.
///
/// They are intentionally optional and backwards-compatible: direct routes
/// still use the defaults.
class ResetLaunchOptions {
  const ResetLaunchOptions({
    this.showGuidanceText = true,
    this.showSessionTimer = true,
    this.voiceGuidanceEnabled = true,
    this.voiceVolume = 0.72,
    this.ambientSoundEnabled = true,
    this.ambientVolume = 0.16,
  });

  final bool showGuidanceText;
  final bool showSessionTimer;

  /// Spoken guidance uses the same Releaf Guide contract as Meditation.
  /// Recorded guide assets take priority; until the exact studio voice is
  /// available, both features share the same calm female en-GB fallback.
  final bool voiceGuidanceEnabled;
  final double voiceVolume;

  /// A deliberately quiet continuous sound bed. Reset currently uses
  /// Deep Drift, an original slow tonal pad already bundled with Releaf.
  final bool ambientSoundEnabled;
  final double ambientVolume;

  ResetLaunchOptions copyWith({
    bool? showGuidanceText,
    bool? showSessionTimer,
    bool? voiceGuidanceEnabled,
    double? voiceVolume,
    bool? ambientSoundEnabled,
    double? ambientVolume,
  }) {
    return ResetLaunchOptions(
      showGuidanceText: showGuidanceText ?? this.showGuidanceText,
      showSessionTimer: showSessionTimer ?? this.showSessionTimer,
      voiceGuidanceEnabled:
          voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      voiceVolume: (voiceVolume ?? this.voiceVolume).clamp(0.0, 1.0).toDouble(),
      ambientSoundEnabled:
          ambientSoundEnabled ?? this.ambientSoundEnabled,
      ambientVolume:
          (ambientVolume ?? this.ambientVolume).clamp(0.0, 1.0).toDouble(),
    );
  }
}
