// FILE: lib/features/home/daily_loop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/app_routes.dart';
import '../progress/data/leaves_repository.dart';
import '../progress/model/leaves_state.dart';

class DailyLoopScreen extends ConsumerWidget {
  const DailyLoopScreen({super.key});

  // Wybieramy kolejny krok na podstawie flag dziennych.
  ({String route, String title, String subtitle}) _nextStep(LeavesState s) {
    if (!s.reliefDone) {
      return (route: AppRoutes.relief, title: 'Relief', subtitle: 'Quick calm (1–3 min)');
    }
    if (!s.brainDone) {
      return (route: AppRoutes.brain, title: 'Brain', subtitle: 'One daily game (1–3 min)');
    }
    if (!s.habitDone) {
      return (route: AppRoutes.habits, title: 'Habit', subtitle: 'One micro habit');
    }
    return (route: AppRoutes.home, title: 'Done', subtitle: 'Back to Home');
  }

  void _goNext(BuildContext context, LeavesState state) {
    final step = _nextStep(state);
    context.go(step.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leavesNotifierProvider);
    final next = _nextStep(state);

    final completedCount =
        (state.reliefDone ? 1 : 0) + (state.brainDone ? 1 : 0) + (state.habitDone ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Loop'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Today progress: $completedCount / 3',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _StepRow(title: 'Relief', done: state.reliefDone),
              _StepRow(title: 'Brain', done: state.brainDone),
              _StepRow(title: 'Habit', done: state.habitDone),
              const Spacer(),
              FilledButton(
                onPressed: () => _goNext(context, state),
                child: Text(next.title == 'Done' ? 'Back to Home' : 'Continue: ${next.title}'),
              ),
              const SizedBox(height: 10),
              Text(
                next.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.title, required this.done});
  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF1E4D2B) : Colors.black45,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}