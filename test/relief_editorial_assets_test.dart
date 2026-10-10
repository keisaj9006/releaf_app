import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/theme/widgets/relief_editorial_image.dart';
import 'package:releaf_app/theme/widgets/releaf_artwork.dart';
import 'package:releaf_app/theme/widgets/releaf_brain_artwork.dart';
import 'package:releaf_app/theme/widgets/releaf_sleep_artwork.dart';
import 'package:releaf_app/theme/widgets/releaf_sound_artwork.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all ten bundled illustrations decode at the approved resolution', () async {
    expect(ReliefEditorialAsset.values, hasLength(10));
    final paths = <String>{};
    var totalBytes = 0;
    for (final asset in ReliefEditorialAsset.values) {
      expect(paths.add(asset.assetPath), isTrue);
      expect(asset.assetPath, startsWith('assets/art/relief/'));
      final data = await rootBundle.load(asset.assetPath);
      totalBytes += data.lengthInBytes;
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1024);
      expect(frame.image.height, 735);
      frame.image.dispose();
      codec.dispose();
    }
    expect(totalBytes, lessThan(2000000));
  });

  Widget host(Widget child, {Size size = const Size(320, 220)}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  for (final size in [
    const Size(160, 140),
    const Size(320, 180),
    const Size(720, 260),
  ]) {
    testWidgets('editorial image respects tile bounds at $size', (tester) async {
      await tester.pumpWidget(
        host(
          const ReliefEditorialImage(
            asset: ReliefEditorialAsset.reset,
            fallback: ColoredBox(color: Colors.black),
          ),
          size: size,
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
      expect(image.excludeFromSemantics, isTrue);
      expect(tester.getSize(find.byType(ReliefEditorialImage)), size);
      expect(find.byType(AnimatedOpacity), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('decoration does not take the parent card tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        GestureDetector(
          onTap: () => taps++,
          child: const ReliefEditorialImage(
            asset: ReliefEditorialAsset.breathe,
            fallback: ColoredBox(color: Colors.black),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ReliefEditorialImage));
    expect(taps, 1);
  });

  testWidgets('zero intensity retains fallback without image loading', (tester) async {
    await tester.pumpWidget(
      host(
        const ReliefEditorialImage(
          asset: ReliefEditorialAsset.reset,
          intensity: 0,
          fallback: ColoredBox(
            key: Key('fallback'),
            color: Colors.black,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('fallback')), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('non-finite intensity does not break layout', (tester) async {
    await tester.pumpWidget(
      host(
        const ReliefEditorialImage(
          asset: ReliefEditorialAsset.reset,
          intensity: double.nan,
          fallback: ColoredBox(color: Colors.black),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  for (final variant in ReleafArtworkVariant.values) {
    testWidgets(
      'Reset $variant selects an approved bundled illustration',
      (tester) async {
        await tester.pumpWidget(host(ReleafArtwork(variant: variant)));
        expect(find.byType(ReliefEditorialImage), findsOneWidget);
      },
    );
  }

  for (final variant in ReleafSleepArtworkVariant.values) {
    testWidgets(
      'Sleep $variant selects an approved bundled illustration',
      (tester) async {
        await tester.pumpWidget(host(ReleafSleepArtwork(variant: variant)));
        expect(find.byType(ReliefEditorialImage), findsOneWidget);
      },
    );
  }

  testWidgets(
    'Brain hero uses new image but game identities remain distinct',
    (tester) async {
      await tester.pumpWidget(
        host(
          const ReleafBrainArtwork(
            variant: ReleafBrainArtworkVariant.hero,
          ),
        ),
      );
      expect(
        tester
            .widget<ReliefEditorialImage>(find.byType(ReliefEditorialImage))
            .asset,
        ReliefEditorialAsset.brainGames,
      );
      for (final variant in ReleafBrainArtworkVariant.values.where(
        (value) => value != ReleafBrainArtworkVariant.hero,
      )) {
        await tester.pumpWidget(host(ReleafBrainArtwork(variant: variant)));
        expect(find.byType(ReliefEditorialImage), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Sound library gets imagery without replacing track-specific art',
    (tester) async {
      await tester.pumpWidget(
        host(
          const ReleafSoundArtwork(
            variant: ReleafSoundArtworkVariant.field,
          ),
        ),
      );
      expect(
        tester
            .widget<ReliefEditorialImage>(find.byType(ReliefEditorialImage))
            .asset,
        ReliefEditorialAsset.soundscapes,
      );
      for (final variant in ReleafSoundArtworkVariant.values.where(
        (value) => value != ReleafSoundArtworkVariant.field,
      )) {
        await tester.pumpWidget(host(ReleafSoundArtwork(variant: variant)));
        expect(find.byType(ReliefEditorialImage), findsNothing);
      }
    },
  );
}
