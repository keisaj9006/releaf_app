// FILE: lib/features/home/daily_loop_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import '../habits/presentation/habits_screen.dart';
import '../relief/presentation/breathing_widget.dart';
import '../brain/data/game_registry.dart';

class DailyLoopScreen extends StatefulWidget {
  const DailyLoopScreen({super.key});

  @override
  State<DailyLoopScreen> createState() => _DailyLoopScreenState();
}

class _DailyLoopScreenState extends State<DailyLoopScreen> {
  int step = 0;

  late final GameEntry suggestedGame = GameRegistry.all()[Random().nextInt(GameRegistry.all().length)];

  void _next() {
    setState(() => step = (step + 1).clamp(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Loop'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: IndexedStack(
          index: step,
          children: [
            _StepCard(
              title: 'Step 1/3 — Relief (60s)',
              child: BreathingWidget(
                totalSeconds: 60,
                onFinished: _next,
              ),
            ),
            _StepCard(
              title: 'Step 2/3 — Brain (1–2 min)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Suggested: ${suggestedGame.title}'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      // Start the suggested game inside Brain tab routes.
                      context.go('${AppRoutes.brain}/game/${suggestedGame.id}');
                    },
                    child: const Text('Start game'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _next,
                    child: const Text('Skip (go to habits)'),
                  ),
                ],
              ),
            ),
            _StepCard(
              title: 'Step 3/3 — Log 1 habit',
              child: const HabitsQuickLogView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}