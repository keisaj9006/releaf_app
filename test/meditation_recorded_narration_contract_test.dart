import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';

void main() {
  test('Mindfulness Basics is wired for recorded Releaf Guide narration', () {
    const catalog = MeditationCatalog();
    final session = catalog.getById('mindfulness-basics-2');

    expect(session, isNotNull);
    expect(session!.steps, hasLength(4));

    expect(
      session.steps.map((step) => step.narrationAssetPath).toList(),
      const [
        'narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3',
        'narration/releaf-guide/mindfulness-basics-2/02-notice.mp3',
        'narration/releaf-guide/mindfulness-basics-2/03-return.mp3',
        'narration/releaf-guide/mindfulness-basics-2/04-finish.mp3',
      ],
    );

    expect(
      session.steps.every(
        (step) => step.spokenGuidance != null && step.spokenGuidance!.isNotEmpty,
      ),
      isTrue,
    );
  });
}
