import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:releaf_app/games/labyrinth/labyrinth_game_screen.dart';

void main() {
  testWidgets(
    'Labyrinth keeps a user-requested pause across an app lifecycle round trip',
    (WidgetTester tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      final motion = StreamController<AccelerometerEvent>.broadcast(sync: true);
      addTearDown(motion.close);

      await tester.pumpWidget(
        MaterialApp(
          home: LabirynthGameScreen(
            motionStream: motion.stream,
            onFinish: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Pause'), findsOneWidget);
      expect(find.byTooltip('Resume'), findsNothing);

      await tester.tap(find.byTooltip('Pause'));
      await tester.pump();

      expect(find.byTooltip('Resume'), findsOneWidget);
      expect(find.byTooltip('Pause'), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // A lifecycle resume must only undo a lifecycle-owned pause. It must not
      // silently resume a session that the user explicitly paused.
      expect(find.byTooltip('Resume'), findsOneWidget);
      expect(find.byTooltip('Pause'), findsNothing);

      await tester.tap(find.byTooltip('Resume'));
      await tester.pump();

      expect(find.byTooltip('Pause'), findsOneWidget);
      expect(find.byTooltip('Resume'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
