import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/theme/widgets/releaf_artwork.dart';
import 'package:releaf_app/theme/widgets/releaf_session_living_form.dart';

void main() {
  testWidgets('breathing Reset uses the dedicated lung living form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: ReleafSessionLivingForm(
                variant: ReleafArtworkVariant.breath,
                progress: 0.35,
                breathing: true,
                phaseLabel: 'Inhale',
                reducedMotion: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reset-breathing-lungs')), findsOneWidget);
    expect(find.byType(ReleafLivingForm), findsNothing);
    expect(find.text('Inhale'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-breathing Reset keeps the generic living form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: ReleafSessionLivingForm(
                variant: ReleafArtworkVariant.noBreath,
                progress: 0.35,
                breathing: false,
                reducedMotion: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reset-breathing-lungs')), findsNothing);
    expect(find.byType(ReleafLivingForm), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
