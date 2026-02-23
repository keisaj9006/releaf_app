// FILE: lib/features/brain/presentation/game_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../data/brain_repository.dart';

class GameResultScreen extends StatelessWidget {
  const GameResultScreen({super.key, required this.result});

  final BrainSessionResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session end')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Game: ${result.gameId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Score: ${result.score}'),
                    Text('Time: ${result.durationSeconds}s'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go(AppRoutes.brain),
              child: const Text('Back to Brain'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('${AppRoutes.home}/${AppRoutes.dailyLoop}'),
              child: const Text('Start Daily Loop'),
            ),
          ],
        ),
      ),
    );
  }
}