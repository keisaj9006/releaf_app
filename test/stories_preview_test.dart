import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/stories/presentation/stories_preview_screen.dart';

Future<void> _pumpStories(
  WidgetTester tester, {
  Size size = const Size(800, 900),
  double textScale = 1.0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const StoriesPreviewScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Stories preview exposes TS01 and TS02 as unavailable drafts', (
    WidgetTester tester,
  ) async {
    await _pumpStories(tester);

    expect(find.byKey(const Key('stories-preview-back')), findsOneWidget);
    expect(find.text('OWNER PREVIEW'), findsOneWidget);
    expect(find.text('Stories Preview'), findsOneWidget);
    expect(find.text('TRUE STORIES OF COURAGE'), findsOneWidget);

    expect(
      find.byKey(const Key('story-preview-TS01_BEYOND_THE_GATE')),
      findsOneWidget,
    );
    expect(find.text('Beyond the Gate'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('story-preview-TS02_KRYSTYNA_SKARBEK')),
      260,
    );
    expect(
      find.byKey(const Key('story-preview-TS02_KRYSTYNA_SKARBEK')),
      findsOneWidget,
    );
    expect(find.text('The Woman Who Crossed Every Border'), findsOneWidget);
    expect(find.text('Narration not imported yet'), findsNWidgets(2));
    expect(find.text('TRUE STORY'), findsNWidgets(2));
    expect(find.text('WORLD WAR II'), findsNWidgets(2));
    expect(find.text('NON-GRAPHIC'), findsNWidgets(2));
    expect(find.text('About 28 min'), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Play'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stories preview stays usable at 320x640', (
    WidgetTester tester,
  ) async {
    await _pumpStories(tester, size: const Size(320, 640));

    expect(find.text('Stories Preview'), findsOneWidget);
    expect(
      find.byKey(const Key('story-preview-TS01_BEYOND_THE_GATE')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stories preview stays usable at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpStories(
      tester,
      size: const Size(320, 640),
      textScale: 2.0,
    );

    expect(find.text('Stories Preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
