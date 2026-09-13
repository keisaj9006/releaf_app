import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sound/presentation/sound_screen.dart';

void main() {
  testWidgets('parked Meditate is not discoverable from the Sound library', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sound-open-meditate')), findsNothing);
    expect(find.text('Meditate'), findsNothing);
    expect(find.textContaining('meditation'), findsNothing);
    expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
