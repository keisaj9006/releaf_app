import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/reset_content.dart';

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
        'Take a deep breath in through your nose and exhale slowly.',
        'Notice the sensations in your body and the contact with the chair.',
        'Let thoughts come and go without judgement.',
      ],
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
        'Close your eyes if you feel comfortable.',
        'Breathe deeply, counting slowly to four on each inhale and exhale.',
        'Relax your shoulders and unclench your jaw.',
        'Imagine a peaceful place and allow your body to soften.',
      ],
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
