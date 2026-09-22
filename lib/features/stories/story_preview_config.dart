abstract final class StoryPreviewConfig {
  static const enabled = bool.fromEnvironment(
    'RELIEF_STORIES_PREVIEW',
    defaultValue: false,
  );
}
