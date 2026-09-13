import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('Full Body Scan exposes all eight attention stages', (
    tester,
  ) async {
    const phases = [
      'Face',
      'Shoulders',
      'Arms',
      'Chest',
      'Center',
      'Legs',
      'Feet',
      'Whole Body',
    ];

    for (var index = 0; index < phases.length; index++) {
      final phase = phases[index];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 420,
              child: ReleafBodyReleaseVisual(
                sessionId: 'tension-body-scan',
                progress: (index + 0.5) / phases.length,
                phaseLabel: phase,
                reducedMotion: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('reset-body-scan-stage-indicator')),
        findsOneWidget,
      );
      expect(find.text('${index + 1} OF 8'), findsOneWidget);
      expect(find.text(phase.toUpperCase()), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Full Body Scan. Stage ${index + 1} of 8. $phase is the current area of attention.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
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

  testWidgets('Shoulder Drop gives a clear cue for every movement state', (
    tester,
  ) async {
    const states = <String, String>{
      'Notice': 'NOTICE YOUR SHOULDERS',
      'Lift': 'LIFT GENTLY',
      'Release': 'LET THEM DROP',
      'Settle': 'SETTLE HERE',
    };

    for (final entry in states.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 420,
              child: ReleafBodyReleaseVisual(
                sessionId: 'shoulder-drop-reset',
                progress: 0.5,
                phaseLabel: entry.key,
                reducedMotion: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('reset-shoulder-movement-cue')),
        findsOneWidget,
      );
      expect(find.text(entry.value), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Shoulder Drop. ${entry.value.toLowerCase()}. Use only a small comfortable movement.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('reduced motion keeps pilot visuals static and accessible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 420,
            child: ReleafBodyReleaseVisual(
              sessionId: 'tension-body-scan',
              progress: 0.5,
              phaseLabel: 'Chest',
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-body-motion-static')), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Full Body Scan. Stage 4 of 8. Chest is the current area of attention. Motion reduced.',
      ),
      findsOneWidget,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pilot visuals stay overflow-free at 320px with large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              height: 480,
              child: ReleafBodyReleaseVisual(
                sessionId: 'tension-body-scan',
                progress: 0.875,
                phaseLabel: 'Whole Body',
                reducedMotion: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-full-body-scan-map')), findsOneWidget);
    expect(find.text('8 OF 8'), findsOneWidget);
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

  testWidgets('Full Body Scan route keeps its map on an ambiguous phase', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/relief/session/tension-body-scan',
      routes: [
        GoRoute(
          path: '/relief/session/:sessionId',
          builder: (context, state) => const Scaffold(
            body: SizedBox.square(
              dimension: 320,
              child: ReleafBodyReleaseVisual(
                progress: 0.20,
                phaseLabel: 'Shoulders',
                reducedMotion: true,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-full-body-scan-map')), findsOneWidget);
    expect(find.byKey(const Key('reset-body-release-visual')), findsNothing);
    expect(find.byKey(const Key('reset-shoulder-drop-guide')), findsNothing);
    expect(find.text('SHOULDERS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shoulder Drop route keeps its guide on its opening phase', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/relief/session/shoulder-drop-reset',
      routes: [
        GoRoute(
          path: '/relief/session/:sessionId',
          builder: (context, state) => const Scaffold(
            body: SizedBox.square(
              dimension: 320,
              child: ReleafBodyReleaseVisual(
                progress: 0.05,
                phaseLabel: 'Notice',
                reducedMotion: true,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-shoulder-drop-guide')), findsOneWidget);
    expect(find.byKey(const Key('reset-body-release-visual')), findsNothing);
    expect(find.byKey(const Key('reset-full-body-scan-map')), findsNothing);
    expect(find.text('NOTICE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
