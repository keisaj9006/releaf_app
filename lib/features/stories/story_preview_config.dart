abstract final class StoryPreviewConfig {
  static const enabled = bool.fromEnvironment(
    'RELIEF_STORIES_PREVIEW',
    defaultValue: false,
  );

  static String? redirectWhenDisabled({
    required bool enabled,
    required String sleepRoute,
  }) {
    return enabled ? null : sleepRoute;
  }
}
