const double releafGuideNarrationSpeedMultiplier = 0.82;

const String releafGuideName = 'Releaf Guide';
const String releafGuideProvider = 'ElevenCreative';
const String releafGuideVoiceDirection =
    'selected female British-English meditation narrator';
const String releafGuideDelivery =
    'natural, warm, calm, intimate, premium; no whisper or ASMR';
const String releafGuideReferenceGenerationId =
    'd730719be8654c93bddd639a96da7417';

/// The exact provider voice ID was not preserved when the reference narration
/// was approved. Production rendering stays blocked rather than silently
/// substituting another voice.
const String? releafGuideExactProviderVoiceId = null;

const Map<String, Object?> releafGuideProductionProfile = <String, Object?>{
  'name': releafGuideName,
  'provider': releafGuideProvider,
  'voice': releafGuideVoiceDirection,
  'delivery': releafGuideDelivery,
  'speedReference': releafGuideNarrationSpeedMultiplier,
  'referenceGenerationId': releafGuideReferenceGenerationId,
  'exactProviderVoiceId': releafGuideExactProviderVoiceId,
  'renderBlockedUntilVoiceIdIsRecovered': true,
};
