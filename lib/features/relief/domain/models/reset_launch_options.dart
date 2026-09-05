/// Presentation preferences selected before a Reset session starts.
///
/// They are intentionally optional and backwards-compatible: direct routes
/// still use the defaults.
class ResetLaunchOptions {
  const ResetLaunchOptions({
    this.showGuidanceText = true,
    this.showSessionTimer = true,
  });

  final bool showGuidanceText;
  final bool showSessionTimer;

  ResetLaunchOptions copyWith({
    bool? showGuidanceText,
    bool? showSessionTimer,
  }) {
    return ResetLaunchOptions(
      showGuidanceText: showGuidanceText ?? this.showGuidanceText,
      showSessionTimer: showSessionTimer ?? this.showSessionTimer,
    );
  }
}
