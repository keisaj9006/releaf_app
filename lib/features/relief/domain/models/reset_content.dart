import 'reset_session_program.dart';

enum ResetLevel { quick, deep, emergency }

enum QuickResetCategory { situational, breath, noBreath, lifeUpgrade }

enum ResetModality { breathing, grounding, guidedPractice }

enum ResetAccessTier { free, premium }

/// Describes whether the current content already fits the frozen Reset
/// taxonomy or is being preserved temporarily during the migration.
enum ResetTaxonomyStatus { canonical, legacyCompatible }

/// Canonical model for all active Reset content.
///
/// The model intentionally contains only metadata needed by the existing
/// player and the frozen future taxonomy. Presentation-specific fields belong
/// in later phases.
class ResetContent {
  final String id;
  final String title;
  final int durationSeconds;
  final ResetLevel level;
  final QuickResetCategory? quickCategory;
  final ResetModality modality;
  final ResetAccessTier accessTier;
  final List<String> instructions;
  final String? audioAsset;
  final String? summary;
  final ResetTaxonomyStatus taxonomyStatus;
  final ResetSessionProgram? program;

  const ResetContent({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.level,
    required this.modality,
    required this.accessTier,
    required this.instructions,
    this.quickCategory,
    this.audioAsset,
    this.summary,
    this.taxonomyStatus = ResetTaxonomyStatus.canonical,
    this.program,
  }) : assert(id != ''),
       assert(durationSeconds > 0),
       assert(
         level == ResetLevel.quick
             ? quickCategory != null
             : quickCategory == null,
         'Only Quick Reset content may have a Quick Reset category.',
       ),
       assert(
         level != ResetLevel.emergency ||
             accessTier == ResetAccessTier.free,
         'Emergency content must always be free.',
       );

  bool get isEmergency => level == ResetLevel.emergency;
  bool get isPremium => accessTier == ResetAccessTier.premium;
  bool get isLegacyCompatible =>
      taxonomyStatus == ResetTaxonomyStatus.legacyCompatible;
}
