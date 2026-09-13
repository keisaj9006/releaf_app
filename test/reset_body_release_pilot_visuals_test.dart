import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/theme/widgets/releaf_body_release_visual.dart';

void main() {
  testWidgets('Full Body Scan phases use the dedicated whole-body map', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ReleafBodyReleaseVisual(
              progress: 0.25,
              phaseLabel: 'Face',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reset-full-body-scan-map')), findsOneWidget);
    expect(find.byKey(const Key('reset-shoulder-drop-guide')), findsNothing);
    expect(find.text('FACE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shoulder Drop phases use the dedicated movement guide', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ReleafBodyReleaseVisual(
              progress: 0.50,
              phaseLabel: 'Lift',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reset-shoulder-drop-guide')), findsOneWidget);
    expect(find.byKey(const Key('reset-full-body-scan-map')), findsNothing);
    expect(find.text('LIFT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('other body-release phases keep the generic guide', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ReleafBodyReleaseVisual(
              progress: 0.75,
              phaseLabel: 'Jaw',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reset-body-release-visual')), findsOneWidget);
    expect(find.byKey(const Key('reset-full-body-scan-map')), findsNothing);
    expect(find.byKey(const Key('reset-shoulder-drop-guide')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
