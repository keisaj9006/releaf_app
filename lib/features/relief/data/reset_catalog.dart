import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/breath_pattern.dart';
import '../domain/models/reset_content.dart';
import '../domain/models/reset_session_program.dart';

final resetCatalogProvider = Provider<ResetCatalog>((ref) {
  return const ResetCatalog();
});

/// The single source of truth for active Reset content.
class ResetCatalog {
  const ResetCatalog();

  static const emergencySessionId = 'emergency-grounding';

  static const List<ResetContent> _activeContent = [
    ResetContent(
      id: emergencySessionId,
      title: 'Emergency Calm',
      durationSeconds: 120,
      level: ResetLevel.emergency,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      instructions: [
        'Place both feet on the floor and notice the support beneath you.',
        'Look around and name five things you can see.',
        'Notice four things you can physically feel around you.',
        'Listen for three sounds without trying to change them.',
        'Continue at your own pace. You can stop at any time.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance:
                'Place both feet on the floor and notice the support beneath you.',
            durationSeconds: 24,
            advanceActionLabel: 'I can feel the support',
          ),
          ResetSessionStep(
            label: 'Look',
            guidance: 'Look around and name five things you can see.',
            durationSeconds: 24,
            advanceActionLabel: 'I can see them',
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance:
                'Notice four things you can physically feel around you.',
            durationSeconds: 24,
            advanceActionLabel: 'I can feel them',
          ),
          ResetSessionStep(
            label: 'Listen',
            guidance: 'Listen for three sounds without trying to change them.',
            durationSeconds: 24,
            advanceActionLabel: 'I can hear them',
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Notice the room around you again. Stay here for a moment if you need to.',
            durationSeconds: 24,
            advanceActionLabel: 'Finish',
          ),
        ],
      ),
    ),
    ResetContent(
      id: '60s-grounding',
      title: '60s Grounding',
      durationSeconds: 60,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A one-minute body-contact grounding practice for returning attention to physical support.',
      methodLabel: 'Body-contact grounding',
      bestFor:
          'Fast settling when attention feels scattered, tense or pulled into repetitive thinking.',
      whyItMayHelp:
          'The exercise narrows attention to concrete body contact and present-moment sensation instead of asking you to solve the thought.',
      safetyNote:
          'Keep the position comfortable. If closing attention onto body sensations feels unpleasant, switch to an external object or sound anchor.',
      instructions: [
        'Sit comfortably and place your feet on the ground.',
        'Notice three physical sensations where your body meets the floor or chair.',
        'Notice the sensations in your body and the contact with the chair.',
        'Let thoughts come and go without judgement.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Sit comfortably and place your feet on the ground.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance:
                'Notice three physical sensations where your body meets the floor or chair.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice the sensations in your body and the contact with the chair.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Let thoughts come and go without judgement.',
            durationSeconds: 15,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'back-to-room',
      title: 'Back to the Room',
      durationSeconds: 180,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A full 5–4–3–2–1 sensory grounding sequence with a shorter 3–2–1 option.',
      methodLabel: '5–4–3–2–1 sensory grounding',
      bestFor:
          'Feeling detached, overwhelmed or caught in internal monitoring when external orientation feels useful.',
      whyItMayHelp:
          'The sequence deliberately moves attention through several senses and back toward concrete details in the environment.',
      safetyNote:
          'Use only senses that are comfortable and available. You may skip smell or taste and use the shorter 3–2–1 path at any time.',
      visualType: ResetVisualType.sensoryHalo,
      instructions: [
        'Look around the space you are in.',
        'Notice five things you can see.',
        'Notice four things you can physically feel.',
        'Listen for three different sounds.',
        'Notice two things you can smell, or imagine two familiar scents.',
        'Notice one taste, or imagine a familiar taste.',
        'Notice the room around you again.',
      ],
      program: ResetSessionProgram.guided(
        simplifyActionLabel: 'Too much right now? Try 3–2–1',
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Look around the space you are in.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'See',
            guidance: 'Notice five things you can see.',
            durationSeconds: 45,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance: 'Notice four things you can physically feel.',
            durationSeconds: 40,
          ),
          ResetSessionStep(
            label: 'Hear',
            guidance: 'Listen for three different sounds.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Smell',
            guidance:
                'Notice two things you can smell, or imagine two familiar scents.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Taste',
            guidance: 'Notice one taste, or imagine a familiar taste.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance: 'Notice the room around you again.',
            durationSeconds: 10,
          ),
        ],
        simplifiedSteps: [
          ResetSessionStep(
            label: 'See',
            guidance: 'Notice three things you can see.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance: 'Notice two things you can physically feel.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Hear',
            guidance: 'Notice one sound you can hear.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'jaw-shoulders',
      title: 'Jaw & Shoulders',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A brief tension-awareness and release sequence for the jaw and shoulders.',
      methodLabel: 'Jaw + shoulder release',
      bestFor:
          'Desk tension, clenching or moments when the upper body feels rigid.',
      whyItMayHelp:
          'Alternating small muscular effort with release makes the contrast easier to notice without requiring the body to become fully relaxed.',
      safetyNote:
          'Use a small comfortable range. Stop if jaw, neck or shoulder movement is painful or causes dizziness.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice your jaw and shoulders without changing anything yet.',
        'Let your teeth separate slightly and let the tongue rest.',
        'Gently lift your shoulders and hold for a moment.',
        'Let your shoulders drop and notice the difference.',
        'Lift gently once more, only as much as feels comfortable.',
        'Release the shoulders again.',
        'Notice what feels different now.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice your jaw and shoulders without changing anything yet.',
            durationSeconds: 10,
          ),
          ResetSessionStep(
            label: 'Jaw',
            guidance:
                'Let your teeth separate slightly. Let the tongue rest.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Shoulders',
            guidance:
                'Gently lift your shoulders. Hold for a moment without straining.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Let your shoulders drop. Notice the difference.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Again',
            guidance:
                'Lift gently once more, only as much as feels comfortable.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Let Go',
            guidance: 'Release the shoulders again.',
            durationSeconds: 10,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice what feels different now.',
            durationSeconds: 10,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'name-the-thought',
      title: 'Name the Thought',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A short cognitive-defusion practice for creating distance from a recurring thought.',
      methodLabel: 'Name + unhook',
      bestFor:
          'Repetitive thoughts that keep demanding attention even when you do not need to solve them immediately.',
      whyItMayHelp:
          'Adding the phrase I am noticing the thought that can help frame a thought as a mental event rather than an instruction that must be followed.',
      safetyNote:
          'Do not use the exercise to argue with or suppress a thought. If the content becomes more distressing, stop and orient to the room or seek appropriate support.',
      visualType: ResetVisualType.thoughtUnhook,
      instructions: [
        'Notice what your mind keeps returning to.',
        'Put the thought into one short sentence in your mind.',
        'Try adding: I am noticing the thought that...',
        'Let the thought be there for a moment without trying to solve it.',
        'Notice one thing you can see, one thing you can hear, and one thing you can feel.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice what your mind keeps returning to.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Name',
            guidance:
                'Put the thought into one short sentence in your mind. You do not need to type or save it.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Unhook',
            guidance:
                'Try adding: “I am noticing the thought that…” before the sentence.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Space',
            guidance:
                'Let the thought be there for a moment. You do not have to solve it right now.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Refocus',
            guidance:
                'Notice one thing you can see, one thing you can hear, and one thing you can feel.',
            durationSeconds: 25,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'object-anchor',
      title: 'Object Anchor',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A visual and tactile attention anchor using one ordinary object nearby.',
      methodLabel: 'Single-object sensory anchor',
      bestFor:
          'Mental noise, distraction or moments when an external focus feels easier than body-based grounding.',
      whyItMayHelp:
          'Looking closely at shape, texture and contact gives attention a simple external target with clear sensory detail.',
      safetyNote:
          'Choose a safe ordinary object. Do not use anything hot, sharp, breakable or otherwise unsafe to handle.',
      visualType: ResetVisualType.objectFocus,
      instructions: [
        'Choose one ordinary object near you.',
        'Notice its shape and edges.',
        'Notice its texture or surface.',
        'Notice temperature, weight, or pressure if you are holding it.',
        'Find one small detail you had not noticed before.',
        'Return your attention to the room.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Choose',
            guidance: 'Choose one ordinary object near you.',
            durationSeconds: 15,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Shape',
            guidance: 'Notice its shape, edges, and outline.',
            durationSeconds: 18,
            advanceActionLabel: 'I see it',
          ),
          ResetSessionStep(
            label: 'Texture',
            guidance: 'Notice its texture or surface.',
            durationSeconds: 18,
            advanceActionLabel: 'I notice it',
          ),
          ResetSessionStep(
            label: 'Contact',
            guidance:
                'If you are holding it, notice temperature, weight, or pressure.',
            durationSeconds: 18,
            advanceActionLabel: 'Got it',
          ),
          ResetSessionStep(
            label: 'Detail',
            guidance: 'Find one small detail you had not noticed before.',
            durationSeconds: 12,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Return',
            guidance: 'Return your attention to the room around you.',
            durationSeconds: 9,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'sound-anchor',
      title: 'Sound Anchor',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A listening practice that moves from near sounds to farther and layered sounds.',
      methodLabel: 'Near-to-far sound anchor',
      bestFor:
          'Overthinking or visual overload when listening feels like the easiest route back to the environment.',
      whyItMayHelp:
          'Shifting between near, far and layered sounds broadens attention without requiring you to change the sounds themselves.',
      safetyNote:
          'Keep environmental awareness when near traffic, work equipment or other situations where important sounds must not be ignored.',
      visualType: ResetVisualType.soundRipple,
      instructions: [
        'Let your attention move toward the sounds already around you.',
        'Notice one sound that feels close.',
        'Notice one sound that feels farther away.',
        'See if you can notice more than one layer of sound at once.',
        'Return to the room without needing the sounds to change.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Listen',
            guidance:
                'Let your attention move toward the sounds already around you.',
            durationSeconds: 12,
          ),
          ResetSessionStep(
            label: 'Near',
            guidance: 'Notice one sound that feels close.',
            durationSeconds: 18,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Far',
            guidance: 'Notice one sound that feels farther away.',
            durationSeconds: 18,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Layers',
            guidance:
                'See if you can notice more than one layer of sound at once.',
            durationSeconds: 20,
            advanceActionLabel: 'I can hear them',
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Return to the room without needing the sounds to change.',
            durationSeconds: 22,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'press-release',
      title: 'Press & Release',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A gentle pressure-and-release exercise using the hands or feet against a stable surface.',
      methodLabel: 'Gentle pressure + release',
      bestFor:
          'Physical bracing, restless energy or moments when a simple muscular contrast feels useful.',
      whyItMayHelp:
          'A small voluntary press followed by release can make the difference between active effort and support easier to notice.',
      safetyNote:
          'Use light comfortable pressure only. Stop for pain, cramping, numbness or joint discomfort.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice where your body is supported.',
        'Press your feet or hands gently into a stable surface.',
        'Release the pressure and notice the change.',
        'Press gently once more without straining.',
        'Release again.',
        'Notice what feels different now.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Notice where your body is supported.',
            durationSeconds: 10,
          ),
          ResetSessionStep(
            label: 'Press',
            guidance:
                'Press your feet or hands gently into a stable surface. Keep it comfortable.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Release the pressure and notice the change.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Again',
            guidance: 'Press gently once more without straining.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Let Go',
            guidance: 'Release again and let the effort stop.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice what feels different now.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'make-room',
      title: 'Make Room',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'An acceptance-based pause for allowing a difficult feeling or thought without letting it choose the next action.',
      methodLabel: 'Notice + allow + choose',
      bestFor:
          'Moments when fighting an emotion or thought is adding a second layer of struggle.',
      whyItMayHelp:
          'The practice separates allowing an internal experience to exist from automatically acting on it.',
      safetyNote:
          'This is not a request to tolerate danger or harmful treatment. If the situation itself is unsafe, prioritise practical safety and support.',
      visualType: ResetVisualType.acceptanceSpace,
      instructions: [
        'Notice the feeling or thought that is here right now.',
        'See if you can let it be present without fixing it for this moment.',
        'Imagine making a little more room around the experience.',
        'Let it come with you without letting it choose your next action.',
        'Return attention to what is around you now.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice the feeling or thought that is here right now.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Allow',
            guidance:
                'See if you can let it be present without fixing it for this moment.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Room',
            guidance:
                'Imagine making a little more room around the experience.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Carry',
            guidance:
                'Let it come with you without letting it choose your next action.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance: 'Return attention to what is around you now.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'cool-water-reset',
      title: 'Cool Water Reset',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A brief sensory reset using comfortably cool water on the hands or face.',
      methodLabel: 'Temperature anchor',
      bestFor:
          'Moments when you feel mentally stuck and a clear physical sensory cue may help you re-orient.',
      whyItMayHelp:
          'The useful part is the noticeable change in temperature and attention. Releaf does not present cold exposure as a cure or require extreme temperatures.',
      safetyNote:
          'Use comfortably cool—not painfully cold—water. Do not use ice-water immersion or prolonged cold exposure.',
      visualType: ResetVisualType.sensoryHalo,
      instructions: [
        'Use comfortably cool water.',
        'Notice the temperature rather than chasing intensity.',
        'Return attention to the room afterwards.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Prepare',
            guidance:
                'Use comfortably cool water on your hands, wrists or face. No ice is needed.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice the temperature, the edges of the sensation and how it changes over a few moments.',
            durationSeconds: 35,
          ),
          ResetSessionStep(
            label: 'Orient',
            guidance:
                'Look around and name three ordinary things in the room.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Dry off, settle your posture and choose what you want to do next.',
            durationSeconds: 15,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'pushups-activation',
      title: '10 Push-Ups Activation',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A short movement reset using up to ten comfortable push-ups, wall push-ups or a seated press.',
      methodLabel: 'Brief movement activation',
      bestFor:
          'Low-momentum moments when a small amount of movement feels more useful than another thinking exercise.',
      whyItMayHelp:
          'The goal is simply to interrupt stillness and change physical state through a brief, manageable effort.',
      safetyNote:
          'Choose a wall or seated version if needed. Stop for pain, dizziness, chest symptoms or unusual shortness of breath.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Choose a safe version for your body.',
        'Do up to ten controlled repetitions.',
        'Notice the change without pushing to exhaustion.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Choose floor push-ups, wall push-ups, or a seated press that feels safe today.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Move',
            guidance:
                'Do up to ten controlled repetitions. Stop before form or comfort breaks down.',
            durationSeconds: 45,
          ),
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Pause and notice warmth, muscle effort and where your attention is now.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Choose the next useful action while the shift in momentum is still fresh.',
            durationSeconds: 10,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'shoulder-drop-reset',
      title: 'Shoulder Drop Reset',
      durationSeconds: 60,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A one-minute check for shoulder tension that has crept up unnoticed.',
      methodLabel: 'Shoulder release',
      bestFor:
          'Desk work, scrolling, driving breaks or any moment when the shoulders feel lifted and rigid.',
      whyItMayHelp:
          'The exercise makes unnecessary muscular effort easier to notice, then gives the shoulders a chance to settle.',
      safetyNote:
          'Use a small range of motion and stop if shoulder or neck movement is painful.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice where the shoulders are now.',
        'Lift gently, then let go.',
        'Keep only the muscle effort you need.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice where your shoulders are sitting without changing them yet.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Lift',
            guidance:
                'Gently lift both shoulders a little. Keep the movement comfortable.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let them drop and notice the contrast.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let the shoulders rest where they need to be rather than forcing them down.',
            durationSeconds: 15,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'eye-focus-reset',
      title: 'Eye Focus Reset',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.premium,
      summary:
          'A short visual-attention reset after prolonged close-up screen focus.',
      methodLabel: 'Near-to-far visual anchor',
      bestFor:
          'Long screen sessions or moments when attention feels visually narrow and stuck on one close target.',
      whyItMayHelp:
          'The routine deliberately changes visual distance and gives attention a different target. It is not an eye treatment.',
      safetyNote:
          'Keep head and eye movement comfortable. Stop if visual shifting causes pain, double vision, marked dizziness or nausea.',
      visualType: ResetVisualType.objectFocus,
      instructions: [
        'Look at a comfortable near object.',
        'Shift to something farther away.',
        'Let the eyes rest rather than straining to focus.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Near',
            guidance:
                'Choose one comfortable object nearby and notice one detail.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Far',
            guidance:
                'Shift your gaze to something farther away and let the eyes settle there.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Wide',
            guidance:
                'Without staring hard, notice more of the space around that object.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Blink naturally and return to the room before going back to the screen.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'shake-it-out',
      title: 'Shake It Out',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A brief loose-movement reset for hands, arms and legs after holding the body still.',
      methodLabel: 'Loose movement reset',
      bestFor:
          'After sitting rigidly, clenching or carrying restless energy in the body.',
      whyItMayHelp:
          'The value is straightforward: change the body from rigid holding to loose voluntary movement, then notice the contrast.',
      safetyNote:
          'Keep movements small and controlled. Use a seated version if balance is uncertain.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Loosen the hands first.',
        'Add only comfortable movement.',
        'Finish by becoming still again and noticing the difference.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Hands',
            guidance:
                'Loosen the fingers and gently shake out the hands.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Arms',
            guidance:
                'Let the forearms and arms move loosely without forcing the shoulders.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Legs',
            guidance:
                'If safe, add a little movement through the legs or feet. Stay seated if that is better.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Still',
            guidance:
                'Become still again and notice what feels different.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Use the next ten seconds to choose where your attention goes now.',
            durationSeconds: 10,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'micro-walk-reset',
      title: 'Micro Walk Reset',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A two-minute walking reset that uses movement and environmental detail as the anchor.',
      methodLabel: 'Movement + orientation',
      bestFor:
          'When you have been sitting, looping on a problem or need a clean transition between tasks.',
      whyItMayHelp:
          'Walking changes posture, location and sensory input at the same time, giving attention several concrete cues outside the thought loop.',
      safetyNote:
          'Walk only where it is safe. Do not use the screen while crossing roads, stairs or busy areas.',
      visualType: ResetVisualType.sensoryHalo,
      instructions: [
        'Walk somewhere safe.',
        'Notice contact with the ground.',
        'Use the environment instead of the screen as your anchor.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Start',
            guidance:
                'Put the phone down or hold it safely and begin walking somewhere clear.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Steps',
            guidance:
                'Notice the changing pressure through your feet as you walk.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Look',
            guidance:
                'Notice three things that are farther away than the screen.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Listen',
            guidance:
                'Notice one nearby sound and one more distant sound.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Finish the walk and choose the next task before reopening everything else.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'one-small-next-step',
      title: 'One Small Next Step',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A short planning reset that turns a broad problem into one visible next action.',
      methodLabel: 'Shrink to one next action',
      bestFor:
          'Overwhelm, procrastination or a task that feels too large to start.',
      whyItMayHelp:
          'Reducing a broad goal to one concrete physical action lowers the amount of information that must be held and chosen at once.',
      safetyNote:
          'Choose an action that is realistic and safe. If the task involves urgent health, legal or safety decisions, use appropriate professional help instead of relying on the reset.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Pause and name what needs your attention next.',
        'Choose one action that would move things forward a little.',
        'Make the action smaller until it feels realistically doable.',
        'Picture the first physical step.',
        'Keep only that next step for now.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Pause',
            guidance: 'Pause and name what needs your attention next.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Choose one action that would move things forward a little.',
            durationSeconds: 30,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Shrink',
            guidance:
                'Make the action smaller until it feels realistically doable.',
            durationSeconds: 30,
            advanceActionLabel: 'That feels doable',
          ),
          ResetSessionStep(
            label: 'Start',
            guidance: 'Picture the first physical step.',
            durationSeconds: 25,
            advanceActionLabel: 'I know the first step',
          ),
          ResetSessionStep(
            label: 'Commit',
            guidance: 'Keep only that next step for now.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'sleep-faster-routine',
      title: 'Pre-Sleep Downshift',
      durationSeconds: 180,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A short pre-sleep routine for reducing unfinished-task friction and lowering stimulation before bed.',
      methodLabel: 'Pre-sleep downshift',
      bestFor:
          'The last few minutes before bed when your mind is still carrying tasks, screens or tomorrow.',
      whyItMayHelp:
          'The routine combines a simple mental off-load with lower stimulation and one repeatable bedtime cue. It is designed to reduce friction, not guarantee immediate sleep.',
      safetyNote:
          'If you are not sleepy, do not force sleep. Keep the routine gentle and return to it as a consistent cue over time.',
      visualType: ResetVisualType.acceptanceSpace,
      instructions: [
        'Put tomorrow somewhere outside your head.',
        'Reduce one source of stimulation.',
        'Choose one simple cue that means the day is over.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance:
                'Stop adding new tasks. This short routine is only about closing the day.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Off-load',
            guidance:
                'Name or write the one thing your mind is trying hardest to remember for tomorrow.',
            durationSeconds: 45,
          ),
          ResetSessionStep(
            label: 'Lower input',
            guidance:
                'Dim one source of stimulation: screen brightness, overhead light, sound, or active scrolling.',
            durationSeconds: 45,
          ),
          ResetSessionStep(
            label: 'Cue',
            guidance:
                'Choose one repeatable cue for sleep: plug in the phone, lower the light, or get into the same resting position.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Finish',
            guidance:
                'Let unfinished things stay unfinished. Your next task is only to rest.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'morning-reset-ritual',
      title: 'Morning Reset Ritual',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A two-minute morning sequence for orienting, moving and choosing the first useful priority.',
      methodLabel: 'Morning orientation',
      bestFor:
          'Starting the day without immediately handing attention to notifications or a long task list.',
      whyItMayHelp:
          'The routine creates a small pause between waking and reacting, then turns the morning into one visible next action.',
      safetyNote:
          'Use a seated version if standing or moving is uncomfortable.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Orient to where you are.',
        'Add a small amount of movement.',
        'Choose one first priority.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Orient',
            guidance:
                'Look around the room before looking at the task list. Notice where you are and what time of day it is.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Posture',
            guidance:
                'Come a little more upright and let your feet or body feel supported.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Move',
            guidance:
                'Add a small comfortable movement: stand, stretch, roll the shoulders, or walk a few steps.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Pick one priority that would make the next part of the morning easier.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Begin',
            guidance:
                'Shrink that priority to its first visible action and start there.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'confidence-posture-reset',
      title: 'Grounded Posture Reset',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A grounded posture-and-attention reset before a meeting, conversation or task.',
      methodLabel: 'Stable posture cue',
      bestFor:
          'Moments when nerves are making you physically collapse inward or over-monitor yourself.',
      whyItMayHelp:
          'The goal is not to manufacture confidence with a pose. It is to remove avoidable tension, create a stable stance and give attention somewhere useful to go.',
      safetyNote:
          'Do not force your spine, shoulders or neck into an uncomfortable position.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Find stable contact through your feet or seat.',
        'Reduce unnecessary tension.',
        'Choose where you want attention to go next.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Ground',
            guidance:
                'Feel both feet or your seat against something stable.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Lengthen',
            guidance:
                'Let the chest and head come a little more upright without forcing the shoulders back.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Unclench the hands and soften the jaw.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Look outward',
            guidance:
                'Move attention away from how you might look and toward the person, task or room in front of you.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'First line',
            guidance:
                'Choose your first sentence or first action. You only need to begin.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'deep-focus-method',
      title: 'Single-Task Setup',
      durationSeconds: 180,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      safetyNote:
          'Use this as a task-setup aid rather than a productivity demand. Take a break if sustained focus is becoming physically uncomfortable or counterproductive.',
      summary:
          'A three-minute setup for reducing competing tasks and entering one focused work block.',
      methodLabel: 'Single-task setup',
      bestFor:
          'Starting work when several tabs, tasks or unfinished thoughts are competing for attention.',
      whyItMayHelp:
          'The method reduces the number of active choices and defines one visible target before the work block begins.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Remove one distraction.',
        'Choose one concrete outcome.',
        'Start before trying to feel perfectly ready.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Clear',
            guidance:
                'Close or move one thing that does not belong to the next work block.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Define one outcome for this block in a single sentence.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Shrink',
            guidance:
                'Turn that outcome into the smallest visible first action.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Start',
            guidance:
                'Begin that action now. Do not optimise the whole plan while you are starting.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Commit',
            guidance:
                'Keep this one task active. Everything else can wait until the block ends.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'emotional-stability-drill',
      title: 'Pause Before Reacting',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      safetyNote:
          'Do not use the pause to remain in an unsafe situation. If there is risk of harm, prioritise distance, safety and appropriate support.',
      summary:
          'A short pause between a strong feeling and the action you take next.',
      methodLabel: 'Name → separate → choose',
      bestFor:
          'Moments when a strong emotion is pushing you toward an immediate message, decision or reaction.',
      whyItMayHelp:
          'The drill creates a small distinction between what you feel, what you want to do and what you choose to do next.',
      visualType: ResetVisualType.acceptanceSpace,
      instructions: [
        'Name the strongest feeling.',
        'Notice the urge without obeying it immediately.',
        'Choose the next response deliberately.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Name',
            guidance:
                'Use one simple word for the strongest feeling here.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Locate',
            guidance:
                'Notice where the activation is easiest to feel in the body.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Separate',
            guidance:
                'Name the urge as an urge. You can feel it without acting on it yet.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Ask what response would still make sense ten minutes from now.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Next',
            guidance:
                'Take only the next deliberate step.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'night-nervous-system-unwind',
      title: 'Night Unwind',
      durationSeconds: 180,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A low-stimulation body-and-environment unwind for the end of the day.',
      methodLabel: 'Night downshift',
      bestFor:
          'Evenings when your body is tired but your attention is still behaving as if the day is active.',
      whyItMayHelp:
          'The routine removes small sources of activation and gives the body a repeatable sequence for ending the day.',
      safetyNote:
          'Keep every movement small and comfortable. This is a wind-down routine, not a treatment for insomnia.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Lower one source of stimulation.',
        'Release easy-to-miss tension.',
        'Let tomorrow remain tomorrow.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Dim',
            guidance:
                'Reduce one source of stimulation around you.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Jaw',
            guidance:
                'Let the teeth separate and soften the tongue and jaw.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Shoulders',
            guidance:
                'Let the shoulders drop only as far as feels natural.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Off-load',
            guidance:
                'Name one unfinished thing and deliberately leave it for tomorrow.',
            durationSeconds: 45,
          ),
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Choose a quieter position and let the next few minutes contain less input.',
            durationSeconds: 45,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'quick-mood-shift',
      title: 'Momentum Reset',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A brief behaviour-and-environment reset when you feel flat, stuck or mentally stale.',
      methodLabel: 'Change state through action',
      bestFor:
          'Low-momentum moments when sitting and thinking harder is not helping.',
      whyItMayHelp:
          'The routine changes a few controllable inputs—movement, light, sensory context and one small action—without promising an instant emotional transformation.',
      safetyNote:
          'Choose movement that is safe and comfortable for your body.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Change one physical input.',
        'Move briefly.',
        'Do one small useful action.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Move',
            guidance:
                'Stand, stretch, or change position for a few comfortable moments.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Light',
            guidance:
                'If practical, move toward brighter natural light or a different part of the room.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Sense',
            guidance:
                'Notice one sound, colour or temperature that is different from a moment ago.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Act',
            guidance:
                'Complete one tiny useful action before deciding what your mood should be.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'body-recalibration',
      title: 'Body Tension Check',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A short head-to-toe check for unnecessary effort after sitting, scrolling or working in one position.',
      methodLabel: 'Posture and tension check',
      bestFor:
          'After long periods in one position or when your body feels compressed, tense or disconnected from the task.',
      whyItMayHelp:
          'The sequence simply checks common tension points and adds small movement where useful.',
      safetyNote:
          'Nothing should hurt. Skip any movement that aggravates pain, injury or dizziness.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Check support through the feet or seat.',
        'Release unnecessary effort.',
        'Add one small comfortable movement.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Support',
            guidance:
                'Notice how your feet, legs or seat are being supported.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Jaw',
            guidance:
                'Check whether the jaw or face is working harder than it needs to.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Shoulders',
            guidance:
                'Let the shoulders move once, then settle where they feel easiest.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Hands',
            guidance:
                'Unclench the hands and let the fingers rest.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Posture',
            guidance:
                'Adjust your position only enough to feel supported and alert.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Move',
            guidance:
                'Finish with one small movement that feels useful: stand, walk, stretch or reset your working position.',
            durationSeconds: 25,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'before-panic-builds',
      title: 'Before Panic Builds',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A no-hold sensory orientation routine for early rising panic or strong activation.',
      methodLabel: 'Orient + widen + next step',
      bestFor:
          'Early signs of panic or escalating self-monitoring when breath counting feels unhelpful.',
      whyItMayHelp:
          'The routine shifts attention toward stable external cues and physical support instead of asking you to control breathing or eliminate sensations.',
      safetyNote:
          'If symptoms are new, severe or include concerning chest pain, fainting or significant breathing difficulty, seek medical assessment rather than assuming they are anxiety.',
      visualType: ResetVisualType.sensoryHalo,
      instructions: [
        'Look around and name where you are.',
        'Notice two or three stable points of physical contact.',
        'Let your attention widen to the room instead of monitoring every body sensation.',
        'Release effort in the jaw, hands, or shoulders if that feels comfortable.',
        'Choose one simple next action and stay with only that.',
      ],
      program: ResetSessionProgram.guided(
        simplifyActionLabel: 'Too much? Make it simpler',
        steps: [
          ResetSessionStep(
            label: 'Orient',
            guidance:
                'Look around and name where you are. Let your eyes land on a few ordinary details.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Contact',
            guidance:
                'Notice two or three stable points of contact: feet, chair, floor, wall, or your hands.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Widen',
            guidance:
                'Let attention widen to the room instead of checking every body sensation.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'If it feels comfortable, loosen the jaw, hands, or shoulders without forcing anything.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Next',
            guidance:
                'Choose one simple next action. You do not need to solve the whole moment at once.',
            durationSeconds: 25,
          ),
        ],
        simplifiedSteps: [
          ResetSessionStep(
            label: 'See',
            guidance: 'Name three ordinary things you can see.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance: 'Notice two points where your body is supported.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Next',
            guidance: 'Choose one small next action.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'before-exam',
      title: 'Before an Exam',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A short pre-exam routine that narrows attention from the whole subject to the first concrete action.',
      methodLabel: 'Reduce load + first step',
      bestFor:
          'Final-minute overload, frantic revision or difficulty starting once the exam begins.',
      whyItMayHelp:
          'The exercise stops last-minute task switching and gives attention one defined starting point instead of the whole exam at once.',
      safetyNote:
          'Use this as a focus routine, not a substitute for required exam accommodations, medication plans or other support already arranged.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Stop trying to revise everything in the final minutes.',
        'Choose the first thing you will do when the exam begins.',
        'Notice your feet, chair, or another stable point of support.',
        'Release unnecessary tension in your jaw, hands, and shoulders.',
        'Keep only the first question or first instruction in front of you.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Stop',
            guidance:
                'Stop trying to revise everything in the final minutes. You do not need to hold the whole subject at once.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'First Step',
            guidance:
                'Choose the first thing you will do when the exam begins: read the instructions, scan the page, or start with one question.',
            durationSeconds: 30,
            advanceActionLabel: 'I know my first step',
          ),
          ResetSessionStep(
            label: 'Support',
            guidance:
                'Notice your feet, chair, or another stable point of physical support.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let unnecessary effort soften in your jaw, hands, and shoulders.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Begin',
            guidance:
                'Keep only the first question or first instruction in front of you. The rest can arrive one step at a time.',
            durationSeconds: 35,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'before-interview',
      title: 'Before an Interview',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A pre-interview routine for reducing mental load and choosing one clear opening action.',
      methodLabel: 'Message + stable posture + first step',
      bestFor:
          'Interview nerves, over-preparing or trying to rehearse every possible question at once.',
      whyItMayHelp:
          'Selecting one message and one opening action gives attention a smaller target than mentally simulating the whole conversation.',
      safetyNote:
          'Keep posture changes comfortable and do not force yourself to suppress visible nervousness. The goal is preparation, not perfect calm.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Notice the urge to prepare everything at once.',
        'Choose one thing you want to communicate clearly.',
        'Let your shoulders drop and place both feet somewhere stable.',
        'Choose one small action you can take when the conversation begins.',
        'Keep only that first step for now.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance:
                'Notice the urge to prepare everything at once. You do not need to solve the whole interview right now.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance: 'Choose one thing you want to communicate clearly.',
            durationSeconds: 35,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let your shoulders drop and place both feet somewhere stable.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'First Step',
            guidance:
                'Choose one small action you can take when the conversation begins.',
            durationSeconds: 35,
            advanceActionLabel: 'I know my first step',
          ),
          ResetSessionStep(
            label: 'Ready',
            guidance: 'Keep only that first step for now.',
            durationSeconds: 25,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'before-presentation',
      title: 'Before a Presentation',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A pre-presentation body-and-attention routine focused on releasing extra effort and choosing the opening line.',
      methodLabel: 'Release + ground + first line',
      bestFor:
          'Tension and mental overload immediately before speaking to a group.',
      whyItMayHelp:
          'Combining a small body release with one chosen opening action reduces the number of things you are trying to manage at the start.',
      safetyNote:
          'Use only gentle pressure through the feet and comfortable shoulder or jaw release. Stop any movement that causes pain.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice where you are holding tension.',
        'Let your jaw loosen and your shoulders drop.',
        'Press your feet gently into the floor and release.',
        'Choose the first sentence or first action you need.',
        'Let the rest of the presentation wait until it arrives.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice where you are holding tension.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Let your jaw loosen and your shoulders drop.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Press',
            guidance:
                'Press your feet gently into the floor, then let the effort go.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'First Line',
            guidance: 'Choose the first sentence or first action you need.',
            durationSeconds: 35,
            advanceActionLabel: 'I have it',
          ),
          ResetSessionStep(
            label: 'Begin',
            guidance: 'Let the rest of the presentation wait until it arrives.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'after-conflict',
      title: 'After a Conflict',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A post-conflict pause for naming activation and choosing whether the next step is pause, repair or distance.',
      methodLabel: 'Name + allow + choose',
      bestFor:
          'The period immediately after an argument when the urge to message, decide or react is still strong.',
      whyItMayHelp:
          'The routine inserts time between feeling an urge and choosing an action without requiring the emotion to disappear first.',
      safetyNote:
          'If the conflict involves threats, coercion or violence, prioritise safety and outside support rather than using the exercise to stay engaged.',
      visualType: ResetVisualType.acceptanceSpace,
      instructions: [
        'Notice what is still activated in you after the conflict.',
        'Name the strongest feeling without deciding who was right.',
        'Let the feeling be present for this moment without acting on it.',
        'Create a little space between the feeling and your next action.',
        'Choose whether the next useful step is pause, repair, or distance.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice what is still activated in you after the conflict.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Name',
            guidance:
                'Name the strongest feeling without deciding who was right.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Allow',
            guidance:
                'Let the feeling be present for this moment without acting on it.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Room',
            guidance:
                'Create a little space between the feeling and your next action.',
            durationSeconds: 35,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Choose whether the next useful step is pause, repair, or distance.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'panic-spike',
      title: 'Panic Spike',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A rapid external sensory grounding sequence for a sudden spike of panic-like activation.',
      methodLabel: '5–4–3 sensory orientation',
      bestFor:
          'A sudden surge of fear when external grounding feels easier than deliberate breathing.',
      whyItMayHelp:
          'Counting visible, physical and auditory details gives attention concrete information from the current environment.',
      safetyNote:
          'Panic-like symptoms can overlap with medical problems. Seek urgent medical help for new or severe chest pain, fainting, severe breathing difficulty or other concerning symptoms.',
      visualType: ResetVisualType.sensoryHalo,
      instructions: [
        'Look around and remind yourself where you are.',
        'Notice five things you can see.',
        'Notice four points of contact or physical sensation.',
        'Listen for three sounds around you.',
        'Return attention to the room.',
      ],
      program: ResetSessionProgram.guided(
        simplifyActionLabel: 'Too much? Use 3–2–1',
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance: 'Look around and remind yourself where you are.',
            durationSeconds: 10,
          ),
          ResetSessionStep(
            label: 'See',
            guidance: 'Notice five things you can see.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance: 'Notice four points of contact or physical sensation.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Hear',
            guidance: 'Listen for three sounds around you.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance: 'Return attention to the room.',
            durationSeconds: 5,
          ),
        ],
        simplifiedSteps: [
          ResetSessionStep(
            label: 'See',
            guidance: 'Notice three things you can see.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance: 'Notice two points of contact or physical sensation.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Hear',
            guidance: 'Notice one sound around you.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'overthinking-night',
      title: 'Overthinking at Night',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A night-time thought-unhooking routine that avoids turning bedtime into another problem-solving session.',
      methodLabel: 'Name thought + unhook + sensory return',
      bestFor:
          'Repetitive night-time thinking when trying harder to solve the issue is keeping attention activated.',
      whyItMayHelp:
          'The practice labels thinking as thinking, then redirects attention to one simple sensation without demanding that thoughts stop.',
      safetyNote:
          'If persistent sleep difficulty is affecting daytime function or continues for a prolonged period, consider discussing it with a healthcare professional.',
      visualType: ResetVisualType.thoughtUnhook,
      instructions: [
        'Notice the thought your mind keeps returning to.',
        'Name it as a thought rather than a problem you must solve now.',
        'Try: I am noticing the thought that...',
        'Let the thought stay without following it into another problem.',
        'Return attention to one simple sensation in the room or bed.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice the thought your mind keeps returning to.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Name',
            guidance:
                'Name it as a thought rather than a problem you must solve now.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Unhook',
            guidance: 'Try: “I am noticing the thought that…”',
            durationSeconds: 35,
          ),
          ResetSessionStep(
            label: 'Space',
            guidance:
                'Let the thought stay without following it into another problem.',
            durationSeconds: 30,
          ),
          ResetSessionStep(
            label: 'Refocus',
            guidance:
                'Return attention to one simple sensation in the room or bed.',
            durationSeconds: 30,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'social-pressure',
      title: 'Social Pressure',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'An external-focus routine for moments of strong self-monitoring in social situations.',
      methodLabel: 'External anchor + one social action',
      bestFor:
          'Feeling watched, judged or preoccupied with how you appear during an interaction.',
      whyItMayHelp:
          'Moving attention toward a neutral object, physical support and one simple action reduces the amount of attention spent continuously checking yourself.',
      safetyNote:
          'The goal is not to ignore genuinely unsafe or hostile behaviour. Leave or seek support when a social situation is not safe.',
      visualType: ResetVisualType.objectFocus,
      instructions: [
        'Choose one neutral object in the room.',
        'Notice one detail about its shape or surface.',
        'Let your attention widen enough to notice where your body is supported.',
        'Choose one simple social action rather than monitoring how you appear.',
        'Return attention to the conversation or space around you.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Anchor',
            guidance: 'Choose one neutral object in the room.',
            durationSeconds: 20,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Detail',
            guidance: 'Notice one detail about its shape or surface.',
            durationSeconds: 25,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Support',
            guidance:
                'Let your attention widen enough to notice where your body is supported.',
            durationSeconds: 25,
          ),
          ResetSessionStep(
            label: 'Next',
            guidance:
                'Choose one simple social action rather than monitoring how you appear.',
            durationSeconds: 30,
            advanceActionLabel: 'I know the next action',
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Return attention to the conversation or space around you.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'travel-stress',
      title: 'Travel Stress',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
      summary:
          'A travel-specific grounding routine using support, sound and one concrete next travel step.',
      methodLabel: 'Support + sound + next step',
      bestFor:
          'Queues, delays, transfers or travel overload when the whole journey feels mentally too large.',
      whyItMayHelp:
          'The routine combines environmental orientation with one practical next action so attention does not have to hold the entire journey at once.',
      safetyNote:
          'Keep full awareness around platforms, roads, luggage and announcements. Do not use the screen when doing so would reduce travel safety.',
      visualType: ResetVisualType.soundRipple,
      instructions: [
        'Notice one stable point of contact beneath you.',
        'Listen for one nearby sound.',
        'Listen for one farther-away sound.',
        'Name the next concrete travel step you actually need to take.',
        'Let everything after that wait.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Support',
            guidance: 'Notice one stable point of contact beneath you.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Near',
            guidance: 'Listen for one nearby sound.',
            durationSeconds: 20,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Far',
            guidance: 'Listen for one farther-away sound.',
            durationSeconds: 20,
            advanceActionLabel: 'Found one',
          ),
          ResetSessionStep(
            label: 'Next',
            guidance:
                'Name the next concrete travel step you actually need to take.',
            durationSeconds: 35,
            advanceActionLabel: 'I know the next step',
          ),
          ResetSessionStep(
            label: 'Only This',
            guidance: 'Let everything after that wait.',
            durationSeconds: 25,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'work-overwhelm',
      title: 'Work Overwhelm',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
      summary:
          'A work reset that reduces a crowded workload to one visible action and clears competing tasks from attention.',
      methodLabel: 'Choose + shrink + clear',
      bestFor:
          'Too many open tasks, task switching or difficulty deciding what to do first.',
      whyItMayHelp:
          'Defining one next action creates a smaller decision space than repeatedly reviewing the full workload.',
      safetyNote:
          'Do not use the exercise to push through exhaustion, pain or unsafe working conditions. Take breaks and follow workplace safety requirements.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Stop trying to hold the whole workload in your head.',
        'Choose the one task that matters next.',
        'Shrink it to the first visible action.',
        'Set aside everything that does not belong to this next action.',
        'Start with only that step.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Pause',
            guidance:
                'Stop trying to hold the whole workload in your head.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance: 'Choose the one task that matters next.',
            durationSeconds: 30,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Shrink',
            guidance: 'Shrink it to the first visible action.',
            durationSeconds: 30,
            advanceActionLabel: 'That is small enough',
          ),
          ResetSessionStep(
            label: 'Clear',
            guidance:
                'Set aside everything that does not belong to this next action.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Start',
            guidance: 'Start with only that step.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'equal-rhythm',
      title: '5–5 Balanced',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
      methodLabel: '5–5 balanced breathing',
      bestFor: 'Everyday settling, steady focus, and learning paced breathing.',
      whyItMayHelp:
          'A 10-second breathing cycle is 6 breaths per minute, a commonly studied slow-breathing range.',
      safetyNote:
          'Keep the breath comfortable rather than deep. Stop the paced pattern if you feel light-headed.',
      instructions: [
        'Let the breath stay easy and comfortable.',
        'Follow an even five-count in and five-count out.',
        'Keep the breath smooth rather than deep.',
        'Let go of the count and return to your natural rhythm.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 5,
          exhaleSeconds: 5,
          label: 'Equal 5–5',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let the breath stay easy and comfortable. There is no need to make it bigger.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance: 'Follow an even five-count in and five-count out.',
            durationSeconds: 90,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and return to your natural rhythm.',
            durationSeconds: 15,
          ),
        ],
      ),
    ),
    ResetContent(
      id: '90s-calm-down',
      title: '4–6 Calm Rhythm',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
      methodLabel: '4–6 extended-exhale breathing',
      bestFor: 'Stress, nervous energy, and a breathing pace that feels too fast.',
      whyItMayHelp:
          'The 10-second cycle slows breathing to 6 breaths per minute and lengthens the exhale without adding a breath hold.',
      safetyNote:
          'Breathe gently. If 6 seconds out feels strained, shorten the exhale and keep it comfortable.',
      instructions: [
        'Let your breathing stay comfortable.',
        'Breathe in gently for 4 seconds.',
        'Breathe out smoothly for 6 seconds.',
        'Let go of the count and return to your natural breathing.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          exhaleSeconds: 6,
          label: 'Calm 4–6',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let your breathing stay comfortable. There is no need to take a bigger breath.',
            durationSeconds: 15,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance:
                'Follow the rhythm: a gentle 4-count in and a smooth 6-count out.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and return to your natural breathing.',
            durationSeconds: 15,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'longer-exhale',
      title: 'Long Exhale Reset',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
      methodLabel: '3–6 long-exhale breathing',
      bestFor: 'A stronger downshift when equal breathing still feels too busy.',
      whyItMayHelp:
          'This 1:2 inhale-to-exhale pattern emphasises a slow exhale. Research supports slow breathing overall, while the ideal inhale-to-exhale ratio is not settled.',
      safetyNote:
          'Do not empty the lungs forcefully. Make the exhale smaller or shorter if the pattern creates air hunger.',
      instructions: [
        'Let your shoulders soften and keep the breath gentle.',
        'Breathe in for 3 seconds.',
        'Breathe out for 6 seconds.',
        'Let go of the count and return to a comfortable natural rhythm.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 3,
          exhaleSeconds: 6,
          label: 'Long exhale 3–6',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let your shoulders soften. Keep the breath gentle and comfortable.',
            durationSeconds: 12,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance:
                'Follow the rhythm: a gentle 3-count in and a long, easy 6-count out.',
            durationSeconds: 98,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and return to a comfortable natural rhythm.',
            durationSeconds: 10,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'box-breathing',
      title: 'Box Breathing',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      methodLabel: '4–4–4–4 box breathing',
      bestFor: 'Structured focus, composure, and people who find counting helpful.',
      whyItMayHelp:
          'Equal inhale, hold, exhale and hold phases create a highly structured attentional rhythm. The holds make it a different experience from continuous slow breathing.',
      safetyNote:
          'Breath holds can feel uncomfortable during panic or air hunger. Skip this method if holding increases distress.',
      instructions: [
        'Breathe in gently for 4 seconds.',
        'Hold comfortably for 4 seconds.',
        'Breathe out for 4 seconds, then pause for 4 seconds.',
        'Keep every phase easy rather than forcing a full breath.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          holdAfterInhaleSeconds: 4,
          exhaleSeconds: 4,
          holdAfterExhaleSeconds: 4,
          label: 'Box 4–4–4–4',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Settle into a comfortable position. Keep every phase gentle.',
            durationSeconds: 16,
          ),
          ResetSessionStep(
            label: 'Box',
            guidance:
                'Follow four equal phases: in, hold, out, hold. Do not strain.',
            durationSeconds: 88,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and return to your natural breathing.',
            durationSeconds: 16,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'sleep-downshift',
      title: 'Sleep Downshift 4–7–8',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      methodLabel: '4–7–8 breathing',
      bestFor: 'Bedtime wind-down when you are comfortable with a longer breath hold.',
      whyItMayHelp:
          'The method combines a deliberately slow pace, counting and a prolonged exhale. The exact 4–7–8 numbers should be treated as a pacing method, not a magic formula.',
      safetyNote:
          'Use this only when the hold feels easy. Switch to 4–6 Calm Rhythm if you feel air hunger, dizziness or more anxiety.',
      instructions: [
        'Breathe in gently for 4 seconds.',
        'Hold comfortably for 7 seconds.',
        'Breathe out slowly for 8 seconds.',
        'Keep the breath quiet and stop forcing the count if it becomes uncomfortable.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          holdAfterInhaleSeconds: 7,
          exhaleSeconds: 8,
          label: 'Sleep 4–7–8',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let your body be supported. Keep the breath smaller than you think you need.',
            durationSeconds: 18,
          ),
          ResetSessionStep(
            label: 'Downshift',
            guidance:
                'Follow four in, seven hold, eight out. Stay comfortable and never force the hold.',
            durationSeconds: 84,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Drop the count and let breathing return to its own rhythm.',
            durationSeconds: 18,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'energy-up-breath',
      title: 'Energy Up Breath',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      methodLabel: '3–3 active paced breathing',
      bestFor:
          'Low-energy moments when you want a simple rhythm that feels more active than the slower calming protocols.',
      whyItMayHelp:
          'The 6-second cycle is quicker than the calming Reset patterns. Releaf uses it mainly as a structured attention cue rather than claiming a proven stimulant effect.',
      safetyNote:
          'Keep every breath small and comfortable. This is not forceful breathwork and should not become rapid or deep hyperventilation.',
      instructions: [
        'Sit or stand in a comfortable upright position.',
        'Breathe in gently for 3 seconds.',
        'Breathe out gently for 3 seconds.',
        'Keep the rhythm light and stop if you feel dizzy or tingly.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 3,
          exhaleSeconds: 3,
          label: 'Active 3–3',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Come a little more upright. Keep the breath light rather than deep.',
            durationSeconds: 12,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance:
                'Follow an easy 3-count in and 3-count out. Keep it smooth and unforced.',
            durationSeconds: 66,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Drop the count and notice whether attention feels a little more awake.',
            durationSeconds: 12,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'focus-breath',
      title: 'Focus Breath',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      methodLabel: '4–4 focus breathing',
      bestFor:
          'Starting a work block, returning after distraction, or using the count as one clear attentional anchor.',
      whyItMayHelp:
          'The main value is the repeating count as a simple focus target. Evidence for paced breathing is stronger for regulation than for directly improving cognitive performance.',
      safetyNote:
          'Keep the breath easy and natural in size. If counting becomes distracting, use the visual pacer without words.',
      instructions: [
        'Choose one point on the screen or in the room to rest your gaze.',
        'Breathe in gently for 4 seconds.',
        'Breathe out gently for 4 seconds.',
        'Return attention to the count whenever the mind wanders.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          exhaleSeconds: 4,
          label: 'Focus 4–4',
        ),
        steps: [
          ResetSessionStep(
            label: 'Anchor',
            guidance:
                'Choose one visual point. Let the count become the only task for the next moment.',
            durationSeconds: 16,
          ),
          ResetSessionStep(
            label: 'Focus',
            guidance:
                'Follow four in and four out. When attention drifts, return to the next count.',
            durationSeconds: 88,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Release the count and choose the first task you want to return to.',
            durationSeconds: 16,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'anxiety-slow-cycle',
      title: 'Anxiety Slow Cycle',
      durationSeconds: 150,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      methodLabel: '5–7 slow-cycle breathing',
      bestFor:
          'When you want a slower continuous pattern without adding a breath hold.',
      whyItMayHelp:
          'The 12-second cycle equals 5 breaths per minute, within the slow-breathing range studied in autonomic and HRV research.',
      safetyNote:
          'Slower is not automatically better. Shorten the counts if the pattern creates air hunger, effort or dizziness.',
      instructions: [
        'Let the breath stay quiet and comfortable.',
        'Breathe in for 5 seconds.',
        'Breathe out for 7 seconds.',
        'Use a smaller breath rather than trying to fill or empty the lungs completely.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 5,
          exhaleSeconds: 7,
          label: 'Slow 5–7',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let the breath stay quiet. A smaller comfortable breath is enough.',
            durationSeconds: 18,
          ),
          ResetSessionStep(
            label: 'Slow cycle',
            guidance:
                'Follow five in and seven out. Keep both phases smooth, with no hold between them.',
            durationSeconds: 114,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and allow your breathing to choose its own pace again.',
            durationSeconds: 18,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'wired-steady',
      title: 'Wired → Steady',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      summary:
          'An eight-minute paced-breathing reset for high activation and restless energy.',
      methodLabel: '4–5 steady breathing',
      bestFor:
          'Feeling wired, restless or overstimulated when you want a longer continuous breathing practice without holds.',
      whyItMayHelp:
          'The session keeps the breath gentle and slightly lengthens the exhale while giving enough time for the rhythm to settle.',
      safetyNote:
          'Keep the breath small and comfortable. Shorten the count if the pace creates air hunger or dizziness.',
      instructions: [
        'Let the breath stay gentle and comfortable.',
        'Follow a four-count in and five-count out.',
        'Keep the exhale smooth rather than forceful.',
        'Let the rhythm become quieter as the session continues.',
        'Return to your natural breathing before you finish.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          exhaleSeconds: 5,
          label: 'Steady 4–5',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance:
                'Let the breath stay gentle and comfortable. There is no need to make it bigger.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance:
                'Follow a four-count in and five-count out. Keep the exhale smooth rather than forceful.',
            durationSeconds: 360,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance:
                'Let go of the count and return to your natural breathing.',
            durationSeconds: 60,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'tension-body-scan',
      title: 'Tension → Full Body Scan',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'A slow eight-minute scan through common tension points without forcing the body to relax.',
      methodLabel: 'Full-body attention scan',
      bestFor:
          'Held muscular tension, long desk days, or moments when the body feels tight but you do not want a breathing exercise.',
      whyItMayHelp:
          'The scan moves attention systematically through the body so unnecessary effort is easier to notice and soften.',
      safetyNote:
          'Nothing needs to be released. If a body area is painful or emotionally difficult, skip it and return to a neutral point of support.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice the face and jaw.',
        'Move attention through neck and shoulders.',
        'Notice arms and hands.',
        'Notice chest and upper back.',
        'Notice abdomen and lower back.',
        'Notice hips and legs.',
        'Notice feet and points of support.',
        'Finish by noticing the body as a whole.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Face',
            guidance:
                'Notice the face and jaw. Let any unnecessary effort soften if it can.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Shoulders',
            guidance:
                'Move attention through the neck and shoulders. Notice tension without forcing it away.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Arms',
            guidance: 'Notice the arms, hands, and fingers.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Chest',
            guidance: 'Notice the chest and upper back.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Center',
            guidance: 'Notice the abdomen and lower back.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Legs',
            guidance: 'Notice the hips, thighs, knees, and lower legs.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Feet',
            guidance:
                'Notice the feet and the places where your body is supported.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Whole Body',
            guidance:
                'Finish by noticing the body as a whole, exactly as it is right now.',
            durationSeconds: 60,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'overwhelm-stability',
      title: 'Overwhelm → Stability',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'An eight-minute overload reset that turns too many active demands into one realistic next action.',
      methodLabel: 'Overload → one next action',
      bestFor:
          'Cognitive overload, too many open tasks, or the feeling that everything needs attention at once.',
      whyItMayHelp:
          'The protocol separates now from later, restores physical orientation, then reduces the problem to one visible action.',
      visualType: ResetVisualType.nextStep,
      instructions: [
        'Stop trying to organise everything at once.',
        'Notice what is physically supporting you.',
        'Separate what needs attention now from what can wait.',
        'Choose one useful priority.',
        'Shrink it to one visible action.',
        'Return to that action and leave the rest outside this moment.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Pause',
            guidance:
                'Stop trying to organise everything at once. For this moment, nothing else has to be solved.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Support',
            guidance:
                'Notice what is physically supporting you: floor, chair, wall, or another stable surface.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Separate',
            guidance:
                'Separate what genuinely needs attention now from what can wait.',
            durationSeconds: 80,
            advanceActionLabel: 'I can separate them',
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance: 'Choose one useful priority.',
            durationSeconds: 80,
            advanceActionLabel: 'I have one',
          ),
          ResetSessionStep(
            label: 'Shrink',
            guidance: 'Shrink it to one visible, realistic action.',
            durationSeconds: 80,
            advanceActionLabel: 'That feels doable',
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Return to that action and leave the rest outside this moment.',
            durationSeconds: 80,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'evening-unwind',
      title: 'Evening → Proper Unwind',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'An eight-minute evening downshift for unfinished thoughts, residual tension and difficulty ending the day.',
      methodLabel: 'Evening psychological off-load',
      bestFor:
          'The transition from an active day into a quieter evening when your mind is still carrying unfinished work.',
      whyItMayHelp:
          'The routine deliberately stops problem-solving, reconnects with physical support and gives unfinished tasks permission to wait.',
      safetyNote:
          'This is a wind-down practice, not a treatment for persistent insomnia.',
      visualType: ResetVisualType.acceptanceSpace,
      instructions: [
        'Notice what your mind is still carrying from the day.',
        'Let unfinished things remain unfinished for this moment.',
        'Notice where your body is supported.',
        'Make room for any remaining tension without solving it.',
        'Reduce attention to the room, bed, or chair around you.',
        'Finish without needing to feel perfectly calm.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Arrive',
            guidance:
                'Notice what your mind is still carrying from the day.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Allow',
            guidance:
                'Let unfinished things remain unfinished for this moment.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Support',
            guidance: 'Notice where your body is supported.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Room',
            guidance:
                'Make room for any remaining tension without trying to solve it.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Quiet',
            guidance:
                'Reduce attention to the room, bed, or chair immediately around you.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Finish',
            guidance:
                'Finish without needing to feel perfectly calm. Let this be enough for now.',
            durationSeconds: 80,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'anger-release',
      title: 'Anger → Release & Calm',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'An eight-minute pause for strong activation before you choose what to say or do next.',
      methodLabel: 'Activation → release → choice',
      bestFor:
          'After conflict or during strong anger when acting immediately is likely to make the situation worse.',
      whyItMayHelp:
          'The practice gives physical activation time to change and separates the feeling from the next decision.',
      safetyNote:
          'Use gentle pressure only. If you feel unsafe or at risk of harming yourself or someone else, leave the situation and seek immediate support.',
      visualType: ResetVisualType.bodyRelease,
      instructions: [
        'Notice where anger is showing up in your body.',
        'Press your feet or hands gently into a stable surface.',
        'Release the pressure fully.',
        'Loosen the jaw and lower the shoulders.',
        'Create space before deciding what to do next.',
        'Choose the next action only after the body has had time to settle.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance: 'Notice where anger is showing up in your body.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Press',
            guidance:
                'Press your feet or hands gently into a stable surface. Keep it comfortable and controlled.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Release the pressure fully and notice the contrast.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Soften',
            guidance: 'Loosen the jaw and lower the shoulders.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Space',
            guidance:
                'Create space before deciding what to do next. You do not need to act on the first impulse.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Choose',
            guidance:
                'Choose the next action only after the body has had time to settle.',
            durationSeconds: 80,
          ),
        ],
      ),
    ),
    ResetContent(
      id: 'overthinking-let-go',
      title: 'Overthinking → Let It Go',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.premium,
      summary:
          'An eight-minute thought-unhooking practice for loops that keep reopening without producing a useful next step.',
      methodLabel: 'Thought defusion + return',
      bestFor:
          'Repetitive thinking, rumination or mental replay when more analysis is no longer helping.',
      whyItMayHelp:
          'The practice changes the relationship to the thought rather than trying to prove it wrong, then returns attention to something concrete.',
      safetyNote:
          'If a thought concerns immediate danger, safety or a real urgent problem, address the practical issue rather than using the exercise to dismiss it.',
      visualType: ResetVisualType.thoughtUnhook,
      instructions: [
        'Notice the thought or problem your mind keeps reopening.',
        'Put it into one short sentence.',
        'Add: I am noticing the thought that...',
        'Notice the difference between the thought and the room around you.',
        'Let the thought remain without following every branch.',
        'Return attention to one real thing you want to do next.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'Notice',
            guidance:
                'Notice the thought or problem your mind keeps reopening.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Name',
            guidance: 'Put it into one short sentence in your mind.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Unhook',
            guidance: 'Add: “I am noticing the thought that…”',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Distance',
            guidance:
                'Notice the difference between the thought and the room around you.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Space',
            guidance:
                'Let the thought remain without following every branch.',
            durationSeconds: 80,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Return attention to one real thing you want to do next.',
            durationSeconds: 80,
          ),
        ],
      ),
    ),
    ResetContent(
      id: '3min-breath',
      title: '3 min Deep Reset',
      durationSeconds: 180,
      level: ResetLevel.deep,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
      taxonomyStatus: ResetTaxonomyStatus.legacyCompatible,
      instructions: [
        'Inhale through your nose for 4 seconds.',
        'Hold your breath for 4 seconds.',
        'Exhale slowly through your mouth for 4 seconds.',
        'Pause for 4 seconds, then repeat.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          holdAfterInhaleSeconds: 4,
          exhaleSeconds: 4,
          holdAfterExhaleSeconds: 4,
          label: 'Box 4–4–4–4',
        ),
        steps: [
          ResetSessionStep(
            label: 'Settle',
            guidance: 'Let the breath stay comfortable as you find the rhythm.',
            durationSeconds: 20,
          ),
          ResetSessionStep(
            label: 'Rhythm',
            guidance:
                'Follow the four-part rhythm without forcing any phase.',
            durationSeconds: 140,
          ),
          ResetSessionStep(
            label: 'Release',
            guidance: 'Let go of the count and return to a natural rhythm.',
            durationSeconds: 20,
          ),
        ],
      ),
    ),
    ResetContent(
      id: '5min-focus',
      title: '5 min Focus Anchor',
      durationSeconds: 300,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.noBreath,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.premium,
      summary:
          'A longer 5–4–3–2–1 sensory anchor for deliberately returning attention to the immediate environment.',
      methodLabel: '5–4–3–2–1 focus anchor',
      bestFor:
          'A longer grounding break when you want a structured sensory sequence rather than a breathing exercise.',
      whyItMayHelp:
          'Moving systematically through sight, touch, sound, smell and taste provides a repeatable external attention sequence.',
      safetyNote:
          'Use only senses that are comfortable and available. Skip smell or taste when needed, and remain aware of your surroundings.',
      taxonomyStatus: ResetTaxonomyStatus.legacyCompatible,
      instructions: [
        'Name five things you can see around you.',
        'Name four things you can touch.',
        'Name three things you can hear.',
        'Name two things you can smell.',
        'Name one thing you can taste.',
      ],
      program: ResetSessionProgram.guided(
        steps: [
          ResetSessionStep(
            label: 'See',
            guidance: 'Name five things you can see around you.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Touch',
            guidance: 'Name four things you can touch.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Hear',
            guidance: 'Name three things you can hear.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Smell',
            guidance: 'Name two things you can smell.',
            durationSeconds: 60,
          ),
          ResetSessionStep(
            label: 'Taste',
            guidance: 'Name one thing you can taste.',
            durationSeconds: 60,
          ),
        ],
      ),
    ),
  ];

  List<ResetContent> getAll() => _activeContent;

  List<ResetContent> getRegularContent() {
    return _activeContent.where((content) => !content.isEmergency).toList();
  }

  ResetContent? getById(String id) {
    for (final content in _activeContent) {
      if (content.id == id) return content;
    }
    return null;
  }
}
