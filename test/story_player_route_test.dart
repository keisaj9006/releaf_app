import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/stories/story_preview_config.dart';
import 'package:releaf_app/routing/app_routes.dart';

void main() {
  test('Stories preview route redirects to Sleep when preview is disabled', () {
    expect(
      StoryPreviewConfig.redirectWhenDisabled(
        enabled: false,
        sleepRoute: AppRoutes.sleep,
      ),
      AppRoutes.sleep,
    );
  });

  test('Stories preview route stays open when preview is enabled', () {
    expect(
      StoryPreviewConfig.redirectWhenDisabled(
        enabled: true,
        sleepRoute: AppRoutes.sleep,
      ),
      isNull,
    );
  });
}
