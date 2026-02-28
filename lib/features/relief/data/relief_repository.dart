// FILE: lib/features/relief/data/relief_repository.dart
// ACTION: CREATE
// INFO: Zastępuje stary, hardcodowany audio_catalog.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/content_item.dart';

// Provider udostępniający dane asynchronicznie
final reliefRepositoryProvider = FutureProvider<List<ContentItem>>((ref) async {
  // Symulacja opóźnienia sieci / odczytu z pliku JSON (dla UI Loading State)
  await Future.delayed(const Duration(milliseconds: 800));

  // W przyszłości tutaj zrobisz: return await api.fetchReliefContent();
  return const [
    ContentItem(
      id: 'em_001',
      title: 'Atak Paniki? Zacznij tutaj.',
      oneLiner: 'Natychmiastowe spowolnienie tętna. Prowadzimy Cię za rękę.',
      type: ContentType.emergency,
      durationSec: 120,
      accessTier: AccessTier.alwaysFreeEmergency,
      emotionTags: ['panic', 'overwhelmed'],
    ),
    ContentItem(
      id: 'br_001',
      title: 'Oddech Pudełkowy',
      oneLiner: 'Klasyczny reset systemu nerwowego.',
      type: ContentType.breath,
      durationSec: 240,
      accessTier: AccessTier.free,
      emotionTags: ['stressed', 'anxious'],
    ),
    ContentItem(
      id: 'snd_001',
      title: 'Szum Oceanu',
      oneLiner: 'Głęboki relaks przy falach.',
      type: ContentType.sound,
      durationSec: 600,
      accessTier: AccessTier.premium, // Wymaga paywalla
      emotionTags: ['sleep', 'numb'],
    ),
    ContentItem(
      id: 'br_002',
      title: 'Oddech 4-7-8',
      oneLiner: 'Ułatwia zasypianie i odcina gonitwę myśli.',
      type: ContentType.breath,
      durationSec: 300,
      accessTier: AccessTier.free,
      emotionTags: ['racing_thoughts', 'sleep'],
    ),
  ];
});

final singleReliefContentProvider = FutureProvider.family<ContentItem, String>((ref, id) async {
  final items = await ref.watch(reliefRepositoryProvider.future);
  return items.firstWhere(
        (item) => item.id == id,
    orElse: () => throw Exception('Nie znaleziono ćwiczenia o ID: $id'),
  );
});