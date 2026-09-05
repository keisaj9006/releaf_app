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
