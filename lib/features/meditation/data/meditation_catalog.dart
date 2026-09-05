import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/meditation_content.dart';

final meditationCatalogProvider = Provider<MeditationCatalog>((ref) {
  return const MeditationCatalog();
});

class MeditationCatalog {
  const MeditationCatalog();

  static const foundationsSeriesId = 'foundations';

  static const List<MeditationContent> _content = [
    MeditationContent(
      id: 'mindfulness-basics-2',
      title: 'Mindfulness Basics',
      subtitle: 'A short introduction to noticing without fixing.',
      durationSeconds: 120,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.18,
      seriesId: foundationsSeriesId,
      seriesOrder: 1,
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
      id: 'breath-and-body-4',
      title: 'Breath & Body',
      subtitle: 'Use breath and contact points as steady places to return to.',
      durationSeconds: 240,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.16,
      seriesId: foundationsSeriesId,
      seriesOrder: 2,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance: 'Feel where your body meets the chair, bed, or floor.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Breathe',
          guidance:
              'Notice one part of the breath without changing its pace or depth.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Wander',
          guidance:
              'If attention drifts, recognise that and return to one physical sensation.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Let sounds and sensations join the breath in a wider field of attention.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'working-with-thoughts-5',
      title: 'Working with Thoughts',
      subtitle: 'Notice mental activity without treating every thought as an instruction.',
      durationSeconds: 300,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.16,
      seriesId: foundationsSeriesId,
      seriesOrder: 3,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance: 'Begin with one neutral sensation in the body.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'Notice when a thought becomes the centre of attention.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Label',
          guidance:
              'Use a simple label such as thinking, planning, remembering, or judging.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Let the thought remain or leave on its own while attention returns to the body.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Notice the room again and finish without deciding whether the practice was good or bad.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'open-awareness-6',
      title: 'Open Awareness',
      subtitle: 'Practise noticing changing experience without holding one object tightly.',
      durationSeconds: 360,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.15,
      seriesId: foundationsSeriesId,
      seriesOrder: 4,
      steps: [
        MeditationStep(
          label: 'Anchor',
          guidance: 'Begin with the breath or another simple body sensation.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Sounds',
          guidance: 'Let sounds come and go without searching for them.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Body',
          guidance: 'Include changing sensations throughout the body.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Thoughts',
          guidance: 'Notice thoughts as another kind of changing experience.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Allow sounds, sensations, and thoughts to share the same field of attention.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Finish',
          guidance: 'Reconnect with the room and the next thing you intend to do.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'anxious-thoughts-5',
      title: 'Anxious Thoughts',
      subtitle: 'Practise noticing thoughts without following every one.',
      durationSeconds: 300,
      category: MeditationCategory.anxiety,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.16,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance: 'Notice your body and the room around you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'When a thought appears, notice that a thought is happening.',
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
      id: 'before-a-difficult-moment-4',
      title: 'Before a Difficult Moment',
      subtitle: 'Create a little space before a conversation, journey, or task.',
      durationSeconds: 240,
      category: MeditationCategory.anxiety,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.14,
      steps: [
        MeditationStep(
          label: 'Pause',
          guidance: 'Notice that you are anticipating something difficult.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Ground',
          guidance: 'Feel both feet or another clear point of physical support.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'Let the uncomfortable feeling be present without needing to solve it first.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance:
              'Name one quality you want to bring into the next moment, such as steadiness or clarity.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'focus-anchor-5',
      title: 'Focus Anchor',
      subtitle: 'Practise returning to one task after attention moves away.',
      durationSeconds: 300,
      category: MeditationCategory.focus,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.12,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance: 'Choose one sensation to use as an attention anchor.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Stay',
          guidance: 'Stay with the anchor for a few breaths at a time.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'Recognise the moment attention has moved elsewhere.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Come back without turning distraction into a failure.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance: 'End by naming the single task you will return to next.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'after-distraction-6',
      title: 'After Distraction',
      subtitle: 'Reset attention after interruptions without forcing concentration.',
      durationSeconds: 360,
      category: MeditationCategory.focus,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.12,
      steps: [
        MeditationStep(
          label: 'Stop',
          guidance: 'For this minute, stop switching between tasks.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Body',
          guidance: 'Notice posture, jaw, shoulders, and one point of support.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Anchor',
          guidance: 'Stay with one simple sensation.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Drift',
          guidance: 'Notice distraction when it appears.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Return gently instead of trying to hold attention rigidly.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Next',
          guidance: 'Choose one concrete next action and finish the practice.',
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
      backgroundSoundVolume: 0.16,
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
      id: 'soften-tension-4',
      title: 'Soften Tension',
      subtitle: 'Notice muscular effort and experiment with using a little less.',
      durationSeconds: 240,
      category: MeditationCategory.body,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.14,
      steps: [
        MeditationStep(
          label: 'Notice',
          guidance: 'Notice the jaw, eyes, hands, and shoulders.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Compare',
          guidance:
              'Notice the difference between effort that is useful and effort that is not needed.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Soften',
          guidance:
              'Experiment with using slightly less muscular effort without forcing relaxation.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance: 'Notice the whole body and let it settle in its own way.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'self-kindness-5',
      title: 'Self-Kindness',
      subtitle: 'Practise a less hostile response to a difficult moment.',
      durationSeconds: 300,
      category: MeditationCategory.mind,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.16,
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
      id: 'morning-arrival-4',
      title: 'Morning Arrival',
      subtitle: 'Begin the day by noticing before immediately reacting.',
      durationSeconds: 240,
      category: MeditationCategory.everyday,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'releaf-atmosphere-01',
      backgroundSoundVolume: 0.13,
      steps: [
        MeditationStep(
          label: 'Wake',
          guidance: 'Notice how the body feels before trying to change it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Listen',
          guidance: 'Notice the sounds already present around you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Breathe',
          guidance: 'Stay with a few natural breaths.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance: 'Name one thing you want to give your attention to today.',
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
      backgroundSoundVolume: 0.12,
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
          guidance: 'Choose the first useful action when you return to work.',
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
      backgroundSoundVolume: 0.18,
      unguided: true,
      steps: [
        MeditationStep(
          label: 'Quiet',
          guidance: 'Stay with the practice in your own way.',
          durationSeconds: 300,
        ),
      ],
    ),
    MeditationContent(
      id: 'unguided-10',
      title: 'Unguided 10',
      subtitle: 'Ten quiet minutes with a simple timer and optional ambience.',
      durationSeconds: 600,
      category: MeditationCategory.unguided,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'releaf-atmosphere-02',
      backgroundSoundVolume: 0.18,
      unguided: true,
      steps: [
        MeditationStep(
          label: 'Quiet',
          guidance: 'Stay with the practice in your own way.',
          durationSeconds: 600,
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

  List<MeditationContent> getByCategory(MeditationCategory category) =>
      _content.where((item) => item.category == category).toList(growable: false);

  List<MeditationContent> getSeries(String seriesId) {
    final items = _content
        .where((item) => item.seriesId == seriesId)
        .toList(growable: false);
    return [...items]
      ..sort(
        (a, b) => (a.seriesOrder ?? 999).compareTo(b.seriesOrder ?? 999),
      );
  }
}
