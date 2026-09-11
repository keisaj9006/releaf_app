import '../domain/meditation_content.dart';

String meditationGuidanceLabel(MeditationContent item) {
  if (item.unguided) return 'Unguided timer';
  if (item.hasRecordedNarration) return 'Recorded guide';
  if (item.hasAnyRecordedNarration) return 'Voice + captions';
  return 'Captions only';
}

String meditationGuidanceDescription(MeditationContent item) {
  if (item.unguided) {
    return 'A quiet timer without spoken or on-screen guidance.';
  }
  if (item.hasRecordedNarration) {
    return 'Listen to the recorded Releaf Guide, with optional on-screen guidance.';
  }
  if (item.hasAnyRecordedNarration) {
    return 'Some steps have a recorded voice. Read the on-screen guidance for the remaining steps.';
  }
  return 'Read the on-screen guidance. This practice has no recorded voice.';
}

String meditationStartLabel(MeditationContent item) {
  if (item.unguided) return 'Start timer';
  return item.hasRecordedNarration ? 'Start practice' : 'Read & practise';
}
