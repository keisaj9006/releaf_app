import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/meditation_content.dart';

final meditationCatalogProvider = Provider<MeditationCatalog>((ref) {
  return const MeditationCatalog();
});

class MeditationCatalog {
  const MeditationCatalog();

  static const foundationsSeriesId = 'foundations';
  static const deeperPracticeSeriesId = 'deeper-practice';
  static const sleepSeriesId = 'sleep-practice';

  static const List<MeditationContent> _content = [
    MeditationContent(
      id: 'mindfulness-basics-2',
      title: 'Mindfulness Basics',
      subtitle: 'A short introduction to noticing without fixing.',
      durationSeconds: 120,
      category: MeditationCategory.startHere,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.18,
      seriesId: foundationsSeriesId,
      seriesOrder: 1,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance:
              'Notice where your body is supported. You do not need to change anything.',
          spokenGuidance:
              'Let your eyes close if that feels comfortable. Notice the places where your body is '
              'already supported by the surface beneath you. There is nothing to fix right now. Give '
              'yourself a few moments simply to arrive.',
          narrationAssetPath:
              'narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Notice',
          guidance:
              'Choose one simple sensation and notice it for a few moments.',
          spokenGuidance:
              'Bring your attention to one simple sensation. It might be the feeling of your feet, your '
              'hands, or the breath moving naturally. Stay with that one sensation for a little while, '
              'without trying to make it stronger or calmer.',
          narrationAssetPath:
              'narration/releaf-guide/mindfulness-basics-2/02-notice.mp3',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'When attention moves away, notice that gently and come back.',
          spokenGuidance:
              'At some point your attention will move away. That is part of the practice, not a '
              'mistake. When you notice that you are thinking, planning, or listening to something '
              'else, gently return to the sensation you chose.',
          narrationAssetPath:
              'narration/releaf-guide/mindfulness-basics-2/03-return.mp3',
          durationSeconds: 30,
        ),
        MeditationStep(
          label: 'Finish',
          guidance:
              'Widen attention to the room and finish without judging how it went.',
          spokenGuidance:
              'Now let your attention widen again. Notice the whole body, the sounds around you, and '
              'the room you are in. There is no need to decide whether the meditation went well. Just '
              'notice that you took these two minutes for yourself.',
          narrationAssetPath:
              'narration/releaf-guide/mindfulness-basics-2/04-finish.mp3',
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
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.16,
      seriesId: foundationsSeriesId,
      seriesOrder: 2,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance: 'Feel where your body meets the chair, bed, or floor.',
          spokenGuidance:
              'Let the body settle into the surface beneath you. Feel where your weight is being held '
              'by the chair, the bed, or the floor. You do not need to sit perfectly. Allow the body to '
              'be supported instead of holding it up with extra effort.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Breathe',
          guidance:
              'Notice one part of the breath without changing its pace or depth.',
          spokenGuidance:
              'Bring attention to one place where breathing is easy to notice. Maybe the nostrils, the '
              'chest, or the abdomen. Let the breath keep its own pace. Your job is only to notice one '
              'breath arriving, and one breath leaving.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Wander',
          guidance:
              'If attention drifts, recognise that and return to one physical sensation.',
          spokenGuidance:
              'If the mind drifts into a thought, a sound, or a plan, notice that gently. You do not '
              'need to push anything away. Choose one clear physical sensation again and let attention '
              'rest there for the next few moments.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Let sounds and sensations join the breath in a wider field of attention.',
          spokenGuidance:
              'Begin to widen attention. Keep some awareness of breathing, while also noticing sounds '
              'and other sensations in the body. Let everything be present without needing to focus '
              'tightly on any one thing.',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.16,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance: 'Notice your body and the room around you.',
          spokenGuidance:
              'If it feels comfortable, let the eyes close or soften your gaze. Notice the room around '
              'you, and then notice the body sitting or lying here. For this minute, you do not have to '
              'solve the thoughts that brought you here.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'When a thought appears, notice that a thought is happening.',
          spokenGuidance:
              'When a thought appears, see if you can notice the moment it arrives. Instead of entering '
              'the story immediately, recognise simply: a thought is happening. Give it a little space '
              'before deciding whether it needs your attention.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Name',
          guidance:
              'If it helps, name it simply: planning, worrying, remembering, judging.',
          spokenGuidance:
              'If it helps, give the thought a very simple name. Planning. Worrying. Remembering. '
              'Judging. The label is not there to get rid of the thought. It is only a reminder that '
              'the thought is something you can notice.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Return attention to one neutral sensation without pushing the thought away.',
          spokenGuidance:
              'Now return some attention to one neutral sensation in the body. Feel a point of contact, '
              'the temperature of the air, or the natural breath. The thought is allowed to stay in the '
              'background. You do not have to fight it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Notice the room again and let the practice end without needing a result.',
          spokenGuidance:
              'Let attention widen back to the room. Notice a sound, the body, and the space around '
              'you. You do not need to feel completely calm for this practice to count. Let it end '
              'exactly where you are.',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.12,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance: 'Choose one sensation to use as an attention anchor.',
          spokenGuidance:
              'Choose one simple sensation to become your anchor for this practice. It could be the '
              'breath, your feet, or the contact of your hands. Pick something ordinary and easy to '
              'return to.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Stay',
          guidance: 'Stay with the anchor for a few breaths at a time.',
          spokenGuidance:
              'Stay with that anchor for a few breaths at a time. You do not need perfect '
              'concentration. Just notice the details that are already there, and let attention rest on '
              'them for a moment.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'Recognise the moment attention has moved elsewhere.',
          spokenGuidance:
              'Notice the moment attention has moved somewhere else. Maybe into a thought, a sound, or '
              'something you need to do later. The important part is noticing the shift, not preventing '
              'it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Come back without turning distraction into a failure.',
          spokenGuidance:
              'Return to your anchor without making distraction into a problem. Each return is the '
              'practice. Let the next few moments be simple: notice, drift, and come back again.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance: 'End by naming the single task you will return to next.',
          spokenGuidance:
              'Begin to end the meditation by thinking of the one task that deserves your attention '
              'next. Keep it specific. When you finish here, let that be the first place your attention '
              'goes.',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.13,
      steps: [
        MeditationStep(
          label: 'Wake',
          guidance: 'Notice how the body feels before trying to change it.',
          spokenGuidance:
              'Before the day gathers speed, notice how the body actually feels. Heavy or light, rested '
              'or tired, comfortable or tense. You do not need to improve the feeling. Just begin the '
              'morning by knowing what is already here.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Listen',
          guidance: 'Notice the sounds already present around you.',
          spokenGuidance:
              'Let attention move to the sounds that are already present. Near sounds, distant sounds, '
              'quiet sounds. There is nothing you need to search for. Let listening bring you into the '
              'room and into this morning.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Breathe',
          guidance: 'Stay with a few natural breaths.',
          spokenGuidance:
              'Now notice a few natural breaths. Do not make them deeper unless the body wants to. Feel '
              'the small movement of breathing and give yourself permission not to rush the next '
              'moment.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance: 'Name one thing you want to give your attention to today.',
          spokenGuidance:
              'Before you finish, choose one thing that genuinely deserves your attention today. Not '
              'everything at once. Just one direction, task, or person you would like to meet with a '
              'little more presence.',
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
      backgroundSoundId: 'deep-drift',
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
      id: 'steady-attention-10',
      title: 'Steady Attention',
      subtitle: 'Ten minutes of returning to one anchor without forcing concentration.',
      durationSeconds: 600,
      category: MeditationCategory.focus,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.10,
      seriesId: deeperPracticeSeriesId,
      seriesOrder: 1,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance:
              'Settle into a stable position and notice where your body is supported.',
          durationSeconds: 75,
        ),
        MeditationStep(
          label: 'Anchor',
          guidance:
              'Choose one clear sensation and let it be the main place your attention returns to.',
          durationSeconds: 120,
        ),
        MeditationStep(
          label: 'Drift',
          guidance:
              'Notice the moment attention has moved into a thought, sound, or plan.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Come back to the anchor without tightening around it or judging the distraction.',
          durationSeconds: 120,
        ),
        MeditationStep(
          label: 'Widen',
          guidance:
              'Keep the anchor present while allowing sounds and other sensations into awareness.',
          durationSeconds: 105,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Let the anchor go and notice the room before choosing what you will do next.',
          durationSeconds: 90,
        ),
      ],
    ),
    MeditationContent(
      id: 'sitting-with-uncertainty-8',
      title: 'Sitting with Uncertainty',
      subtitle: 'Practise making room for not knowing without solving the next moment.',
      durationSeconds: 480,
      category: MeditationCategory.anxiety,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.12,
      seriesId: deeperPracticeSeriesId,
      seriesOrder: 2,
      steps: [
        MeditationStep(
          label: 'Orient',
          guidance:
              'Notice the room, the surface beneath you, and one ordinary sound around you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Name',
          guidance:
              'Notice that uncertainty is here without turning it into a prediction about what will happen.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Body',
          guidance:
              'Find where the feeling shows up physically and describe the sensation simply.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'See if the sensation can be present for this moment without needing to disappear first.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Space',
          guidance:
              'Let thoughts come and go while keeping some attention with the body and the room.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Finish by choosing one useful next action that does not require certainty.',
          durationSeconds: 70,
        ),
      ],
    ),
    MeditationContent(
      id: 'whole-body-scan-10',
      title: 'Whole Body Scan',
      subtitle: 'A slower scan through the body with time to notice each region.',
      durationSeconds: 600,
      category: MeditationCategory.body,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.13,
      seriesId: deeperPracticeSeriesId,
      seriesOrder: 3,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance:
              'Notice the weight of the body and the points that are supported.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Face & Neck',
          guidance:
              'Move attention through the face, jaw, neck, and the space around the eyes.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Upper Body',
          guidance:
              'Notice shoulders, arms, hands, upper back, and any changing sensations there.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Center',
          guidance:
              'Bring attention through the chest, ribs, abdomen, and lower back.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Lower Body',
          guidance:
              'Notice hips, legs, knees, ankles, and feet without needing them to relax.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance:
              'Let the whole body be present as one changing field of sensation.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Widen attention to sounds and the room, then let the practice end.',
          durationSeconds: 50,
        ),
      ],
    ),
    MeditationContent(
      id: 'open-field-10',
      title: 'Open Field',
      subtitle: 'Stay with a wider field of sounds, sensations, and thoughts.',
      durationSeconds: 600,
      category: MeditationCategory.mind,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.11,
      seriesId: deeperPracticeSeriesId,
      seriesOrder: 4,
      steps: [
        MeditationStep(
          label: 'Anchor',
          guidance:
              'Begin with one simple sensation until attention feels settled enough to widen.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Sounds',
          guidance:
              'Let sounds arrive and leave without choosing which one should be present.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Body',
          guidance:
              'Include sensations throughout the body without moving from one region to another.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Thoughts',
          guidance:
              'Notice thoughts as events appearing in the same field rather than instructions to follow.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Allow sounds, sensations, thoughts, and silence to share attention without holding one tightly.',
          durationSeconds: 140,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Narrow attention back to the body, then reconnect with the room.',
          durationSeconds: 70,
        ),
      ],
    ),
    MeditationContent(
      id: 'let-the-day-go-6',
      title: 'Let the Day Go',
      subtitle: 'A gentle transition away from unfinished tasks and into the night.',
      durationSeconds: 360,
      category: MeditationCategory.everyday,
      accessTier: MeditationAccessTier.free,
      backgroundSoundId: 'night-air',
      backgroundSoundVolume: 0.12,
      seriesId: sleepSeriesId,
      seriesOrder: 1,
      steps: [
        MeditationStep(
          label: 'Arrive',
          guidance:
              'Notice where your body is supported. For these few minutes, there is nothing else you need to complete.',
          spokenGuidance:
              'Let your body be held by the surface beneath you. Feel the weight of the day beginning '
              'to settle. For these next few minutes there is nothing else you need to complete, '
              'organise, or solve.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Day',
          guidance:
              'Notice what your mind is still carrying from today without reopening the whole story.',
          spokenGuidance:
              'Notice what your mind is still carrying from today. A conversation, an unfinished task, '
              'something you wish had gone differently. You do not need to reopen the whole story. Just '
              'recognise what is still asking for your attention.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Set Down',
          guidance:
              'Let unfinished things stay unfinished until tomorrow. You do not need to solve them here.',
          spokenGuidance:
              'See if you can let unfinished things remain unfinished for tonight. Tomorrow can hold '
              'tomorrow\'s decisions. Right now, you are allowed to stop working on the day, even if '
              'everything is not perfectly resolved.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Body',
          guidance:
              'Notice the jaw, shoulders, hands, and the weight of the body against the surface beneath you.',
          spokenGuidance:
              'Bring attention to the jaw, the shoulders, and the hands. Notice where the body is still '
              'using effort. You do not have to force relaxation. Simply let the surface beneath you '
              'carry a little more of your weight.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Quiet',
          guidance:
              'Let sounds, breath, and body sensations become more important than the next thought.',
          spokenGuidance:
              'Let ordinary sensations become more important than the next thought. A sound in the '
              'room. The natural breath. The weight and temperature of the body. Each time the mind '
              'starts another story, return to something simple and physical.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Allow the practice to end without checking whether you feel perfectly calm.',
          spokenGuidance:
              'Let the guidance begin to fade into the background. There is no need to check whether '
              'you are perfectly calm or ready for sleep. Simply notice that the day is no longer '
              'asking anything from you in this moment.',
          durationSeconds: 60,
        ),
      ],
    ),
    MeditationContent(
      id: 'body-into-stillness-8',
      title: 'Body Into Stillness',
      subtitle: 'A slow evening body practice with less effort and less stimulation.',
      durationSeconds: 480,
      category: MeditationCategory.body,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.10,
      seriesId: sleepSeriesId,
      seriesOrder: 2,
      steps: [
        MeditationStep(
          label: 'Settle',
          guidance:
              'Feel the weight of your body and the places where you are fully supported.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Face',
          guidance:
              'Notice the forehead, eyes, jaw, and tongue. Use only as much muscular effort as you need.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Shoulders',
          guidance:
              'Move attention through the neck, shoulders, arms, and hands without forcing them to relax.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Center',
          guidance:
              'Notice the chest, back, abdomen, and the movement that is already happening there.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Lower Body',
          guidance:
              'Notice the hips, legs, feet, and the contact between your body and the bed or chair.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance:
              'Let the whole body be present at once and allow the practice to become quieter.',
          durationSeconds: 80,
        ),
      ],
    ),
    MeditationContent(
      id: 'quiet-night-10',
      title: 'Quiet Night',
      subtitle: 'Ten unhurried minutes for a mind that does not need another task.',
      durationSeconds: 600,
      category: MeditationCategory.mind,
      accessTier: MeditationAccessTier.premium,
      backgroundSoundId: 'deep-drift',
      backgroundSoundVolume: 0.10,
      seriesId: sleepSeriesId,
      seriesOrder: 3,
      steps: [
        MeditationStep(
          label: 'Orient',
          guidance:
              'Notice the room, the surface beneath you, and a few ordinary sounds around you.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Unhook',
          guidance:
              'When a thought asks for attention, notice that thinking is happening without following the next branch.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Return to one simple sensation: contact, warmth, sound, or the natural movement of breathing.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Widen',
          guidance:
              'Let thoughts and sensations come and go inside a wider field of attention.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Less',
          guidance:
              'There is nothing to perform now. Let attention become less deliberate and less effortful.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Let the guidance end and remain with the quiet in your own way.',
          durationSeconds: 100,
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
      backgroundSoundId: 'deep-drift',
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
      backgroundSoundId: 'deep-drift',
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
