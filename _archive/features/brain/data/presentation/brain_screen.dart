// FILE: lib/features/brain/presentation/brain_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../data/game_registry.dart';

class BrainScreen extends StatelessWidget {
  const BrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = GameRegistry.all();

    return Scaffold(
      appBar: AppBar(title: const Text('Brain')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Pick a quick game (1–2 minutes)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...games.map((g) => Card(
                  child: ListTile(
                    title: Text(g.title),
                    subtitle: Text(g.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('${AppRoutes.brain}/game/${g.id}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}