// FILE: lib/features/brain/presentation/game_host_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../routing/routes.dart';
import '../data/brain_repository.dart';
import '../data/game_registry.dart';

class GameHostScreen extends ConsumerStatefulWidget {
  const GameHostScreen({super.key, required this.entry});

  final GameEntry entry;

  @override
  ConsumerState<GameHostScreen> createState() => _GameHostScreenState();
}

class _GameHostScreenState extends ConsumerState<GameHostScreen> {
  late final DateTime startedAt;

  @override
  void initState() {
    super.initState();
    startedAt = DateTime.now();
  }

  Future<void> _finish(int score) async {
    final duration = DateTime.now().difference(startedAt).inSeconds;
    final result = BrainSessionResult(
      gameId: widget.entry.id,
      score: score,
      durationSeconds: duration,
      finishedAt: DateTime.now(),
    );

    await ref.read(brainRepositoryProvider).saveSession(result);

    if (!mounted) return;
    context.goNamed(AppRoutes.gameResult, extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.title),
      ),
      body: widget.entry.builder(context, _finish),
    );
  }
}