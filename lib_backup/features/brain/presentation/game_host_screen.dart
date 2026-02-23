// FILE: lib/features/brain/presentation/game_host_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_registry.dart';

/// Hosts a brain game by its identifier. If a builder is not found, a
/// fallback message is displayed.
class GameHostScreen extends ConsumerWidget {
  final String gameId;

  const GameHostScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builder = gameRegistry[gameId];
    if (builder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game')),
        body: const Center(child: Text('Game not found')),
      );
    }
    return builder(context);
  }
}