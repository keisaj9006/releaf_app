import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/meditation_content.dart';

final meditationCatalogProvider = Provider<MeditationCatalog>((ref) {
  return const MeditationCatalog();
});

class MeditationCatalog {
  const MeditationCatalog();

  static const List<MeditationContent> _content = [
    MeditationContent(
      id: 'mindfulness-basics-2',
      title: 'Mindfulness Basics',
      subtitle: 'A short introduction to noticing without fixing.',
      durationSeconds: 120,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.20,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance:
              'Notice where your body is supported. You do not need to change anything.',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Notice',
          guidance:
              'Choose one simple sensation and notice it for a few moments.',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'When attention moves away, notice that gently and come back.',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Finish',
          guidance:
              'Widen attention to the room and finish without judging how it went.',
          durationSeconds: 30,
        ),
      ],
    ),
    MeditationContent(
      id: 'anxious-thoughts-5',
      title: 'Anxious Thoughts',
      subtitle: 'Practice noticing thoughts without following every one.',
      durationSeconds: 300,
      category: MeditationCategory.anxiety,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.18,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance: 'Notice your body and the room around you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance:
              'When a thought appears, notice that a thought is happening.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Name',
          guidance:
              'If it helps, name it simply: planning, worrying, remembering, judging.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Return attention to one neutral sensation without pushing the thought away.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Notice the room again and let the practice end without needing a result.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'body-scan-5',
      title: 'Body Scan',
      subtitle: 'Move attention slowly through the body.',
      durationSeconds: 300,
      category: MeditationCategory.body,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.20,
      steps: [
        MeditationStep(
          label: 'Face',
          guidance: 'Notice the face, jaw, and the space around the eyes.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Shoulders',
          guidance: 'Move attention through the neck and shoulders.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Center',
          guidance: 'Notice the chest, back, and abdomen.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Legs',
          guidance: 'Notice the hips, legs, and feet.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance: 'Notice the whole body as one field of sensation.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'self-kindness-5',
      title: 'Self-Kindness',
      subtitle: 'Practice a less hostile response to a difficult moment.',
      durationSeconds: 300,
      category: MeditationCategory.mind,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.20,
      steps: [
        MeditationStep(
          label: 'Notice',
          guidance: 'Notice what feels difficult right now.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Soften',
          guidance:
              'See if you can speak to yourself without adding criticism to the difficulty.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Kindness',
          guidance:
              'Try one simple phrase you would offer to someone you care about.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'Let the difficulty and the kinder response exist together for a moment.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Return attention to the room and to what matters next.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'work-break-3',
      title: 'Work Break',
      subtitle: 'Three minutes away from task pressure.',
      durationSeconds: 180,
      category: MeditationCategory.everyday,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.16,
      steps: [
        MeditationStep(
          label: 'Stop',
          guidance: 'For this minute, stop doing the task.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance:
              'Notice three things in the room and one sensation in the body.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Choose the first useful action when you return to work.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'unguided-5',
      title: 'Unguided 5',
      subtitle: 'Five quiet minutes with a simple timer.',
      durationSeconds: 300,
      category: MeditationCategory.unguided,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.22,
      unguided: true,
      steps: [
        MeditationStep(
          label: 'Quiet',
          guidance: 'Stay with the practice in your own way.',
          durationSeconds: 300,
        ),
      ],
    ),
  ];

  List<MeditationContent> getAll() => _content;

  MeditationContent? getById(String id) {
    for (final item in _content) {
      if (item.id == id) return item;
    }
    return null;
  }
}
