// FILE: lib/features/relief/domain/models/content_item.dart
// ACTION: CREATE

enum ContentType {
  breath,
  noBreath,
  sound,
  emergency
}

enum AccessTier {
  free,
  premium,
  alwaysFreeEmergency
}

class ContentItem {
  final String id;
  final String title;
  final String oneLiner;
  final ContentType type;
  final int durationSec;
  final AccessTier accessTier;
  final List<String> emotionTags;

  const ContentItem({
    required this.id,
    required this.title,
    required this.oneLiner,
    required this.type,
    required this.durationSec,
    required this.accessTier,
    this.emotionTags = const [],
  });

  // Wymagane dla bezpieczeństwa - emergency zawsze nadpisuje premium
  bool get isAlwaysFree => accessTier == AccessTier.alwaysFreeEmergency;
}