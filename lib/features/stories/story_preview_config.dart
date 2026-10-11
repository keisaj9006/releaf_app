abstract final class StoryPreviewConfig {
  static const audioBundled = bool.fromEnvironment(
    'RELIEF_STORIES_AUDIO_BUNDLED',
    defaultValue: false,
  );

  static const previewRequested = bool.fromEnvironment(
    'RELIEF_STORIES_PREVIEW',
    defaultValue: bool.fromEnvironment(
      'RELEAF_PREMIUM_PREVIEW',
      defaultValue: false,
    ),
  );

  static const enabled = audioBundled && previewRequested;

  static String? redirectWhenDisabled({
    required bool enabled,
    required String sleepRoute,
  }) {
    return enabled ? null : sleepRoute;
  }
}
