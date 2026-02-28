// FILE: lib/features/relief/presentation/player/relief_player_screen.dart
// ACTION: CREATE
// INFO: Nowy, bezpieczny ekran odtwarzacza/ćwiczenia z przyciskiem STOP.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/relief_repository.dart';
import '../../domain/models/content_item.dart';

class ReliefPlayerScreen extends ConsumerWidget {
  final String contentId;

  const ReliefPlayerScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(singleReliefContentProvider(contentId));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Ciemny tryb dla skupienia
      body: SafeArea(
        child: contentState.when(
          data: (item) => _buildPlayerView(context, item),
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, _) => Center(child: Text('Błąd ładowania: $err', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildPlayerView(BuildContext context, ContentItem item) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Safety Copy na górze
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Jesteś w bezpiecznym miejscu. Możesz przerwać w każdej chwili.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Spacer(),

        // Główne UI Playera (tutaj podmienisz na faktyczne animacje oddechu / audio)
        Icon(
            item.type == ContentType.emergency ? Icons.health_and_safety : Icons.self_improvement,
            size: 100,
            color: item.type == ContentType.emergency ? Colors.redAccent : Colors.tealAccent
        ),
        const SizedBox(height: 32),
        Text(
          item.title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Czas: ${item.durationSec ~/ 60} min',
          style: const TextStyle(color: Colors.white70),
        ),

        const Spacer(),

        // Wyróżniony, ewidentny przycisk wyjścia (Zasada UX: Control & Freedom)
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 24, right: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // Tu event analityczny: Analytics.track('relief_aborted', {'id': item.id});
                context.pop();
              },
              child: const Text('ZAKOŃCZ ĆWICZENIE', style: TextStyle(letterSpacing: 1.2)),
            ),
          ),
        ),
      ],
    );
  }
}