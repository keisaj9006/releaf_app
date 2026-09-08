import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';

void main() {
  test('Foundations and core Anxiety sessions are narration-script ready', () {
    const catalog = MeditationCatalog();
    const ids = [
      'mindfulness-basics-2',
      'breath-and-body-4',
      'working-with-thoughts-5',
      'open-awareness-6',
      'anxious-thoughts-5',
      'before-a-difficult-moment-4',
    ];

    for (final id in ids) {
      final session = catalog.getById(id);
      expect(session, isNotNull, reason: '$id must exist');
      expect(session!.unguided, isFalse, reason: '$id must be guided');
      expect(
        session.steps.every(
          (step) =>
              step.spokenGuidance != null &&
              step.spokenGuidance!.trim().isNotEmpty,
        ),
        isTrue,
        reason: '$id must have spoken guidance for every step',
      );
    }
  });
}
