// FILE: lib/features/brain/presentation/brain_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/brain_repository.dart';
import '../model/brain_game.dart';

/// Displays the list of brain games. Selecting a game navigates to the
/// corresponding route defined in the app router.
class BrainScreen extends StatelessWidget {
  const BrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const BrainRepository();
    final List<BrainGame> games = repository.getGames();
    return Scaffold(
      appBar: AppBar(title: const Text('Brain')),
      body: SafeArea(
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return ListTile(
              title: Text(game.title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to the nested route for the selected game.
                // For Math Race the full path is /brain/math-race.
                context.go('/brain/${game.id}');
              },
            );
          },
        ),
      ),
    );
  }
}