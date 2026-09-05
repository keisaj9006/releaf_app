import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/presentation/sound_screen.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  test('Sound catalog only exposes real bundled audio', () {
    const catalog = SoundCatalog();
    final tracks = catalog.getAll();

    expect(tracks, hasLength(2));
    expect(tracks.map((track) => track.assetPath), contains('sounds/relief_01.mp3'));
    expect(tracks.map((track) => track.assetPath), contains('sounds/relief_02.mp3'));
    expect(tracks.every((track) => track.assetPath.endsWith('.mp3')), isTrue);
  });

  testWidgets('Sound library renders its own audio-first visual language', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('AMBIENT AUDIO'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.byKey(const Key('sound-featured-card')), findsOneWidget);
    expect(find.text('Releaf Atmosphere I'), findsWidgets);
    expect(find.text('Releaf Atmosphere II'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sound library stays overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sound-featured-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('AVAILABLE NOW'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
