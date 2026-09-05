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
      title: 'Emergency Grounding',
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
          ),
          ResetSessionStep(
            label: 'Look',
            guidance: 'Look around and name five things you can see.',
            durationSeconds: 24,
          ),
          ResetSessionStep(
            label: 'Feel',
            guidance:
                'Notice four things you can physically feel around you.',
            durationSeconds: 24,
          ),
          ResetSessionStep(
            label: 'Listen',
            guidance: 'Listen for three sounds without trying to change them.',
            durationSeconds: 24,
          ),
          ResetSessionStep(
            label: 'Return',
            guidance:
                'Continue at your own pace. You can stop at any time.',
            durationSeconds: 24,
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
