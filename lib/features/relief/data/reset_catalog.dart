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
      id: 'one-small-next-step',
      title: 'One Small Next Step',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.lifeUpgrade,
      modality: ResetModality.guidedPractice,
      accessTier: ResetAccessTier.free,
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
      id: 'before-panic-builds',
      title: 'Before Panic Builds',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.situational,
      modality: ResetModality.grounding,
      accessTier: ResetAccessTier.free,
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
      title: 'Equal Rhythm',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
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
      title: '90s Calm Down',
      durationSeconds: 90,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
      instructions: [
        'Let your breathing stay comfortable.',
        'Follow a gentle four-count in and four-count out.',
        'Keep the breath easy rather than making it bigger.',
        'Let go of the count and return to your natural breathing.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 4,
          exhaleSeconds: 4,
          label: 'Gentle 4–4',
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
            guidance: 'Follow the rhythm. Keep the breath gentle and easy.',
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
      title: 'Longer Exhale',
      durationSeconds: 120,
      level: ResetLevel.quick,
      quickCategory: QuickResetCategory.breath,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.free,
      instructions: [
        'Let your shoulders soften and keep the breath gentle.',
        'Breathe in for 3 seconds.',
        'Breathe out for 4 seconds.',
        'Let go of the count and return to a comfortable natural rhythm.',
      ],
      program: ResetSessionProgram.breathing(
        breathPattern: BreathPattern(
          inhaleSeconds: 3,
          exhaleSeconds: 4,
          label: 'Longer exhale 3–4',
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
                'Follow the rhythm: a gentle 3-count in and a slightly longer 4-count out.',
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
      id: 'wired-steady',
      title: 'Wired → Steady',
      durationSeconds: 480,
      level: ResetLevel.deep,
      modality: ResetModality.breathing,
      accessTier: ResetAccessTier.premium,
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
