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
          spokenGuidance:
              'Begin by noticing one neutral sensation in the body. Maybe the weight of your hands, '
              'the contact of your feet, or the support beneath you. There is nothing special to find. '
              'Choose one ordinary sensation and let it give your attention somewhere simple to rest.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance: 'Notice when a thought becomes the centre of attention.',
          spokenGuidance:
              'As you sit here, notice when a thought becomes the centre of attention. It may arrive '
              'quietly or pull you in straight away. See if you can recognise the moment you are thinking, '
              'without needing to finish the thought or work out what it means.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Label',
          guidance:
              'Use a simple label such as thinking, planning, remembering, or judging.',
          spokenGuidance:
              'If it is useful, give the mental activity a light label. Thinking. Planning. Remembering. '
              'Judging. Keep the label simple. The label is not there to judge the thought or make it '
              'stop. It is just a small way of noticing what the mind is doing right now.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Let the thought remain or leave on its own while attention returns to the body.',
          spokenGuidance:
              'Now bring some attention back to the body. The thought does not have to disappear first. '
              'It can stay, change, or leave in its own time. Feel one physical sensation again and notice '
              'that attention can return even while the mind continues to produce thoughts.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Notice the room again and finish without deciding whether the practice was good or bad.',
          spokenGuidance:
              'Let attention widen to the room around you. Notice sound, light, and the position of the '
              'body. There is no need to decide whether the practice worked or whether you did it well. '
              'Simply notice that you spent a few minutes practising how to return.',
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
          spokenGuidance:
              'Begin with one simple anchor. You might notice the natural breath, the weight of the body, '
              'or a point of contact beneath you. Stay with that sensation for a few moments, not to hold '
              'attention perfectly, but to give yourself a clear place to begin.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Sounds',
          guidance: 'Let sounds come and go without searching for them.',
          spokenGuidance:
              'Now allow sounds to enter awareness. You do not need to search for them or identify every '
              'source. Notice a sound as it appears, changes, and fades. Let the next sound arrive on its '
              'own, while the body remains supported where you are.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Body',
          guidance: 'Include changing sensations throughout the body.',
          spokenGuidance:
              'Include more of the body now. Notice pressure, temperature, movement, tension, or ease '
              'wherever these sensations are present. There is no need to scan every area. Let sensations '
              'come into awareness and change without having to keep any one of them in place.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Thoughts',
          guidance: 'Notice thoughts as another kind of changing experience.',
          spokenGuidance:
              'Thoughts can be included too. When one becomes noticeable, see if it can be experienced '
              'as another changing event rather than something you must immediately follow. A thought may '
              'stay for a while or pass quickly. Either way, notice what arrives next.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Allow sounds, sensations, and thoughts to share the same field of attention.',
          spokenGuidance:
              'Let attention become a little wider. Sounds, body sensations, breathing, and thoughts can '
              'all be present in the same field. You do not need to choose the most important one. Notice '
              'how experience keeps changing when you are not trying to hold it still.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Finish',
          guidance: 'Reconnect with the room and the next thing you intend to do.',
          spokenGuidance:
              'Begin to reconnect with the room more deliberately. Feel the body, notice the nearest '
              'sounds, and let the eyes open when you are ready. Before moving on, remember the next '
              'ordinary thing you intend to do, and take this wider attention with you.',
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
          spokenGuidance:
              'Take a moment to recognise that something difficult is ahead. You do not need to rehearse '
              'the whole conversation, journey, or task right now. Simply notice the anticipation that is '
              'already here, and give yourself permission to pause before moving into it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Ground',
          guidance: 'Feel both feet or another clear point of physical support.',
          spokenGuidance:
              'Bring attention to something physically reliable. Feel both feet on the floor, the chair '
              'supporting you, or another clear point of contact. Let that sensation be simple and factual. '
              'For this moment, you are here, supported by the surface beneath you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'Let the uncomfortable feeling be present without needing to solve it first.',
          spokenGuidance:
              'If discomfort is present, see if you can make a little room for it. You do not have to '
              'like the feeling, and you do not have to remove it before you continue. Notice where it '
              'shows up in the body, while keeping some attention on the support beneath you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Choose',
          guidance:
              'Name one quality you want to bring into the next moment, such as steadiness or clarity.',
          spokenGuidance:
              'As you prepare to move on, choose one quality you would like to bring with you. Steadiness. '
              'Clarity. Patience. Courage. Keep it simple. You do not need to feel completely ready. Let '
              'that one quality be a direction for the next small step.',
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
          spokenGuidance:
              'For this minute, stop switching. Let the tabs, messages, and unfinished tasks wait. '
              'You do not need to decide what deserves attention yet. Give the mind one clear signal: '
              'for the next few moments, there is only this pause.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Body',
          guidance: 'Notice posture, jaw, shoulders, and one point of support.',
          spokenGuidance:
              'Notice how the body has been holding the work. Feel the jaw, the shoulders, the hands, '
              'and the way you are sitting or standing. Find one point of support beneath you and let '
              'that physical contact bring attention out of the task and back into the room.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Anchor',
          guidance: 'Stay with one simple sensation.',
          spokenGuidance:
              'Choose one simple sensation to stay with. It might be the feeling of your feet, the '
              'temperature of the air, or the natural movement of breathing. Let that one sensation be '
              'the place you return to, without trying to concentrate perfectly.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Drift',
          guidance: 'Notice distraction when it appears.',
          spokenGuidance:
              'Sooner or later, attention will move. A thought, sound, message, or plan may pull you '
              'away. When you notice that, let the noticing itself count. You do not need to be annoyed '
              'with the distraction. You have simply recognised where attention went.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Return gently instead of trying to hold attention rigidly.',
          spokenGuidance:
              'Come back to the anchor gently. No tightening, no forcing. If attention moves again, '
              'return again. This is the practice: not never becoming distracted, but noticing sooner '
              'and choosing where attention goes next.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Next',
          guidance: 'Choose one concrete next action and finish the practice.',
          spokenGuidance:
              'Before you return to work, choose one concrete next action. One email. One paragraph. '
              'One decision. Let the rest remain outside the frame for now. When this practice ends, '
              'give that single action your first piece of attention.',
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
          spokenGuidance:
              'Bring attention to the face. Notice the forehead, the space around the eyes, the cheeks, '
              'and the jaw. You do not need to relax anything deliberately. Just notice where there is '
              'movement, pressure, warmth, tightness, or very little sensation at all.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Shoulders',
          guidance: 'Move attention through the neck and shoulders.',
          spokenGuidance:
              'Let attention move through the neck and shoulders. Notice their weight and position. '
              'If there is tension, you do not need to push it away. Feel the difference between the '
              'muscles that are working and the areas that can simply be supported.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Center',
          guidance: 'Notice the chest, back, and abdomen.',
          spokenGuidance:
              'Move into the centre of the body. Notice the chest, the upper and lower back, and the '
              'abdomen. Feel any small movement that comes with breathing, as well as pressure or contact '
              'from clothing and the surface beneath you.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Legs',
          guidance: 'Notice the hips, legs, and feet.',
          spokenGuidance:
              'Now notice the hips, thighs, knees, lower legs, and feet. Feel where the legs are heavy, '
              'warm, cool, supported, or restless. There is nothing you need to change. Let attention '
              'move slowly enough to register what is already here.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance: 'Notice the whole body as one field of sensation.',
          spokenGuidance:
              'Let the separate areas come together into one sense of the whole body. Face, shoulders, '
              'centre, legs, and feet can all be present at once. Notice the body being supported here '
              'without needing to check each part individually.',
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
          spokenGuidance:
              'Notice a few places that often work harder than necessary: the jaw, the muscles around '
              'the eyes, the hands, and the shoulders. Do not correct them yet. First, simply notice '
              'how much effort each area is using right now.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Compare',
          guidance:
              'Notice the difference between effort that is useful and effort that is not needed.',
          spokenGuidance:
              'Some muscular effort is useful. It helps you sit, hold the phone, or keep your head '
              'upright. See if you can distinguish that useful effort from extra gripping or bracing '
              'that is not doing a job for you in this moment.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Soften',
          guidance:
              'Experiment with using slightly less muscular effort without forcing relaxation.',
          spokenGuidance:
              'Experiment with using a little less effort. Perhaps let the jaw be less fixed, the hands '
              'less clenched, or the shoulders less lifted. Keep the change small. You are not trying '
              'to make the body completely relaxed, only to stop doing work that is not needed.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance: 'Notice the whole body and let it settle in its own way.',
          spokenGuidance:
              'Now notice the whole body together. Let it settle in whatever way is available today. '
              'Some tension may remain, and that is fine. Finish by noticing the difference between '
              'forcing relaxation and simply giving the body permission to use less effort.',
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
          spokenGuidance:
              'Notice what feels difficult right now without turning it into a bigger story. It may be '
              'a feeling, a mistake, a conversation, or simply a hard day. Name the difficulty quietly '
              'and notice what happens in the body when you acknowledge it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Soften',
          guidance:
              'See if you can speak to yourself without adding criticism to the difficulty.',
          spokenGuidance:
              'Notice the tone you are using with yourself. See if you can remove one layer of criticism '
              'without pretending the situation is easy. The aim is not positive thinking. It is simply '
              'to stop adding unnecessary hostility to something that is already difficult.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Kindness',
          guidance:
              'Try one simple phrase you would offer to someone you care about.',
          spokenGuidance:
              'Think of one simple sentence you might offer to someone you care about in the same '
              'situation. Maybe: this is hard, take one thing at a time, or you do not have to solve '
              'everything right now. Try offering the same sentence to yourself.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'Let the difficulty and the kinder response exist together for a moment.',
          spokenGuidance:
              'Let both things be true for a moment: this may still be difficult, and you can respond '
              'to yourself with less aggression. You do not need the kinder response to erase the '
              'feeling. Notice whether it changes the way you are carrying it.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Return attention to the room and to what matters next.',
          spokenGuidance:
              'Bring attention back to the room. Notice one sound, one point of support, and the next '
              'thing that actually needs your attention. Finish without demanding a particular feeling '
              'from yourself. A kinder next step is enough.',
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
          spokenGuidance:
              'For this minute, stop doing the task. Let your hands move away from the keyboard or '
              'whatever you have been working on. The work can remain unfinished. This pause is not '
              'another task to complete; it is simply a short break from task pressure.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Notice',
          guidance:
              'Notice three things in the room and one sensation in the body.',
          spokenGuidance:
              'Look around and notice three ordinary things in the room. Then notice one clear sensation '
              'in the body: feet on the floor, hands resting, or the support of the chair. Let attention '
              'move from the work into the environment you are actually sitting in.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Return',
          guidance: 'Choose the first useful action when you return to work.',
          spokenGuidance:
              'Before you return, choose the first useful action. Make it specific and small enough to '
              'begin immediately. You do not need to organise the whole workload during this break. '
              'When the session ends, return to that one action first.',
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
          spokenGuidance:
              'Settle into a position you can stay with for a while. Notice where the chair, floor, or bed is already supporting you. Let your hands rest. There is no need to prepare perfectly. Give the body a moment to arrive before asking attention to do anything.',
          durationSeconds: 75,
        ),
        MeditationStep(
          label: 'Anchor',
          guidance:
              'Choose one clear sensation and let it be the main place your attention returns to.',
          spokenGuidance:
              'Choose one clear sensation as an anchor. It might be breathing, the pressure of your feet, or the contact of your hands. Stay close to the actual sensation rather than the idea of it. You do not need to hold attention there continuously. Let it simply be the place you return to.',
          durationSeconds: 120,
        ),
        MeditationStep(
          label: 'Drift',
          guidance:
              'Notice the moment attention has moved into a thought, sound, or plan.',
          spokenGuidance:
              'At some point attention will move. Perhaps into a thought, a sound, a memory, or a plan. See if you can notice that movement without treating it as a mistake. The useful moment is not perfect focus. The useful moment is recognising that attention has gone somewhere else.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Come back to the anchor without tightening around it or judging the distraction.',
          spokenGuidance:
              'Return to the anchor with as little drama as possible. No need to force concentration or make the next moment better than the last. Notice the sensation again. If attention moves, return again. Repetition is the practice here.',
          durationSeconds: 120,
        ),
        MeditationStep(
          label: 'Widen',
          guidance:
              'Keep the anchor present while allowing sounds and other sensations into awareness.',
          spokenGuidance:
              'Let awareness become a little wider. Keep some contact with the anchor while also allowing sounds and other body sensations to be present. Nothing has to be pushed out. Practise letting attention stay organised without becoming narrow.',
          durationSeconds: 105,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Let the anchor go and notice the room before choosing what you will do next.',
          spokenGuidance:
              'Let the anchor become less important now. Notice the whole body, the room, and the sounds around you. Before you finish, choose where you want your attention to go next. Let that choice be deliberate rather than automatic.',
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
          spokenGuidance:
              'Begin with what is certain in this moment. Notice the room, the surface beneath you, and one ordinary sound. Let these simple details remind you that you are here now, before the mind moves ahead into what might happen.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Name',
          guidance:
              'Notice that uncertainty is here without turning it into a prediction about what will happen.',
          spokenGuidance:
              'Notice the simple fact that you do not know exactly what comes next. Try not to turn that uncertainty into a prediction. Not knowing is different from knowing that something bad will happen. For now, just name the uncertainty and let it be unfinished.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Body',
          guidance:
              'Find where the feeling shows up physically and describe the sensation simply.',
          spokenGuidance:
              'Notice where uncertainty shows up in the body. Perhaps pressure, tightness, warmth, restlessness, or something harder to name. Describe the sensation simply, without explaining why it is there. Stay with the physical information rather than the prediction.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Allow',
          guidance:
              'See if the sensation can be present for this moment without needing to disappear first.',
          spokenGuidance:
              'See if the sensation can be here for this moment without becoming a problem you must solve immediately. You are not agreeing with it or asking it to stay. You are only noticing that you can continue to sit here while the feeling changes in its own way.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Space',
          guidance:
              'Let thoughts come and go while keeping some attention with the body and the room.',
          spokenGuidance:
              'Let thoughts come and go without following every branch. Keep some awareness with the body and the room at the same time. The mind may keep offering possibilities. You do not need to answer each one.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Finish by choosing one useful next action that does not require certainty.',
          spokenGuidance:
              'Before you finish, choose one useful next action that does not require certainty. Something small and real that can be done with the information you already have. Let action come from what is available now, rather than waiting to feel completely sure.',
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
          spokenGuidance:
              'Notice the weight of the body and the places already being supported. Let the surface beneath you take the weight it can take. There is nothing to scan yet. Begin with the simple sense of the whole body being here.',
          durationSeconds: 60,
        ),
        MeditationStep(
          label: 'Face & Neck',
          guidance:
              'Move attention through the face, jaw, neck, and the space around the eyes.',
          spokenGuidance:
              'Bring attention through the forehead, eyes, cheeks, jaw, and neck. Notice pressure, temperature, movement, or areas with very little sensation. There is no need to make the face soft. Let yourself notice before changing anything.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Upper Body',
          guidance:
              'Notice shoulders, arms, hands, upper back, and any changing sensations there.',
          spokenGuidance:
              'Move through the shoulders, arms, hands, and upper back. Notice heaviness, contact, warmth, tension, or ease. If one area calls for more attention, let it have a few moments without trying to fix what you find.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Center',
          guidance:
              'Bring attention through the chest, ribs, abdomen, and lower back.',
          spokenGuidance:
              'Bring attention through the chest, ribs, abdomen, and lower back. Notice the movement already happening with breathing. Feel pressure from clothing or support beneath you. Let the centre of the body be experienced rather than analysed.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Lower Body',
          guidance:
              'Notice hips, legs, knees, ankles, and feet without needing them to relax.',
          spokenGuidance:
              'Notice the hips, legs, knees, ankles, and feet. Feel their weight and contact with the surface beneath you. There may be restlessness or tension. Let those sensations be part of the scan without needing the lower body to become still.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance:
              'Let the whole body be present as one changing field of sensation.',
          spokenGuidance:
              'Now let the separate regions come together. Notice the whole body at once, not as a picture but as changing sensation. Some areas may feel clear and others vague. Let all of that belong to one field of experience.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Widen attention to sounds and the room, then let the practice end.',
          spokenGuidance:
              'Let attention widen beyond the body. Notice sounds and the room again. Allow the scan to end without deciding whether anything changed enough. When you are ready, reconnect with what comes next.',
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
          spokenGuidance:
              'Begin with one simple sensation. Let it give attention a clear starting point. Stay there for a while, not because you need to exclude everything else, but because a stable place to begin makes it easier to notice when awareness widens.',
          durationSeconds: 90,
        ),
        MeditationStep(
          label: 'Sounds',
          guidance:
              'Let sounds arrive and leave without choosing which one should be present.',
          spokenGuidance:
              'Allow sounds to become part of awareness. Near or distant, pleasant or ordinary. Do not search for the next sound. Let it arrive, change, and disappear in its own time while you remain here listening.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Body',
          guidance:
              'Include sensations throughout the body without moving from one region to another.',
          spokenGuidance:
              'Include the body now without scanning it part by part. Let pressure, temperature, breathing, and other sensations appear wherever they are noticeable. There is no need to move attention around deliberately.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Thoughts',
          guidance:
              'Notice thoughts as events appearing in the same field rather than instructions to follow.',
          spokenGuidance:
              'Thoughts can be included too. Notice when one appears and when another takes its place. A thought may feel important without needing to be followed right now. Let thinking be one more changing event inside awareness.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Open',
          guidance:
              'Allow sounds, sensations, thoughts, and silence to share attention without holding one tightly.',
          spokenGuidance:
              'Let the field stay open. Sounds, sensations, thoughts, and quiet can all be present together. Nothing needs to become the centre for long. Notice how experience changes when you stop choosing one thing to hold onto.',
          durationSeconds: 140,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Narrow attention back to the body, then reconnect with the room.',
          spokenGuidance:
              'Begin to narrow attention again. Feel the body, the surface beneath you, and the room around you. Let the practice close gradually. Take a moment before moving into the next task.',
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
          spokenGuidance:
              'Let the body become heavier where it is supported. Notice the bed, chair, or floor beneath you. You do not need to make yourself sleepy or relaxed. Simply allow the body to stop holding more weight than it needs to hold.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Face',
          guidance:
              'Notice the forehead, eyes, jaw, and tongue. Use only as much muscular effort as you need.',
          spokenGuidance:
              'Notice the forehead, the muscles around the eyes, the jaw, and the tongue. See whether any of these areas are doing work that is not needed now. If so, let the effort reduce a little. No forcing.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Shoulders',
          guidance:
              'Move attention through the neck, shoulders, arms, and hands without forcing them to relax.',
          spokenGuidance:
              'Move through the neck, shoulders, arms, and hands. Feel their weight and position. Let the arms be carried by the surface beneath them. If tension remains, allow it to remain without turning it into another task.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Center',
          guidance:
              'Notice the chest, back, abdomen, and the movement that is already happening there.',
          spokenGuidance:
              'Notice the chest, back, and abdomen. Feel the movement already happening with breathing without changing its pace. Let the centre of the body move in its own small rhythm while the rest of you becomes quieter.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Lower Body',
          guidance:
              'Notice the hips, legs, feet, and the contact between your body and the bed or chair.',
          spokenGuidance:
              'Bring attention to the hips, legs, and feet. Notice contact, warmth, heaviness, or restlessness. Let the lower body be held where it can be held. You do not need every muscle to become still.',
          durationSeconds: 80,
        ),
        MeditationStep(
          label: 'Whole Body',
          guidance:
              'Let the whole body be present at once and allow the practice to become quieter.',
          spokenGuidance:
              'Let the whole body be present at once. Nothing more needs to be scanned. Allow attention to become less deliberate now. The guidance can recede while the body stays supported in its own way.',
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
          spokenGuidance:
              'Begin with the ordinary details of this moment. Notice the room, the surface beneath you, and a few sounds. There is nothing to prepare and nowhere else to get to. Let the night be exactly as it is for now.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Unhook',
          guidance:
              'When a thought asks for attention, notice that thinking is happening without following the next branch.',
          spokenGuidance:
              'When a thought asks for attention, notice that thinking is happening. You do not need to follow the next branch of the story. Let the thought be incomplete. Another thought may come, or there may be a little quiet.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Return',
          guidance:
              'Return to one simple sensation: contact, warmth, sound, or the natural movement of breathing.',
          spokenGuidance:
              'Return to one simple sensation. Contact with the bed or chair. Warmth. A sound. The natural movement of breathing. Let something simple carry attention for a while without asking you to solve anything.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Widen',
          guidance:
              'Let thoughts and sensations come and go inside a wider field of attention.',
          spokenGuidance:
              'Let awareness widen. Thoughts and sensations can come and go without becoming a task. You do not need to monitor them closely. Notice that experience can keep changing while you do less with it.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Less',
          guidance:
              'There is nothing to perform now. Let attention become less deliberate and less effortful.',
          spokenGuidance:
              'There is nothing to perform now. Let attention become less deliberate. If you drift, drift. If you notice a sound, notice it. If thoughts continue, they can continue. The practice does not require you to stay alert in a particular way.',
          durationSeconds: 100,
        ),
        MeditationStep(
          label: 'Close',
          guidance:
              'Let the guidance end and remain with the quiet in your own way.',
          spokenGuidance:
              'The guidance can end here. You do not need to do anything with the remaining quiet. Stay with the sounds, the body, or simply let attention loosen. Continue in your own way.',
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
