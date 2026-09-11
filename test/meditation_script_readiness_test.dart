import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';

void main() {
  test('Every guided meditation has a complete spoken narration script', () {
    const catalog = MeditationCatalog();
    final guided = catalog
        .getAll()
        .where((session) => !session.unguided)
        .toList(growable: false);

    expect(guided, hasLength(20));

    for (final session in guided) {
      expect(session.steps, isNotEmpty, reason: session.id);
      for (final step in session.steps) {
        final spoken = step.spokenGuidance?.trim() ?? '';
        expect(
          spoken,
          isNotEmpty,
          reason: '${session.id} / ${step.label} needs spoken guidance',
        );

        // Text length is not a reliable proxy for recorded duration:
        // Releaf Guide uses deliberately slow delivery and pauses. Actual
        // pacing is validated against the rendered narration asset duration.
        expect(
          spoken.length,
          greaterThan(40),
          reason:
              '${session.id} / ${step.label} needs narration-ready copy',
        );
      }
    }
  });
}
