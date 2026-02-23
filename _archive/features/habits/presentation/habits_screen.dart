// FILE: lib/features/habits/presentation/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsControllerProvider);
    final controller = ref.read(habitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Tap once to log today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...state.habits.map((h) {
              final done = state.doneToday.contains(h.id);
              final streak = controller.streakFor(h.id);

              return Card(
                child: ListTile(
                  title: Text(h.title),
                  subtitle: Text('Streak: $streak day(s)'),
                  trailing: Checkbox(
                    value: done,
                    onChanged: (_) => controller.toggleDone(h.id),
                  ),
                  onTap: () => controller.toggleDone(h.id),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Używane w DailyLoop jako szybki widok (bez scaffold).
class HabitsQuickLogView extends ConsumerWidget {
  const HabitsQuickLogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsControllerProvider);
    final controller = ref.read(habitsControllerProvider.notifier);

    return ListView(
      children: [
        const Text('Log just ONE habit and you are done.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ...state.habits.map((h) {
          final done = state.doneToday.contains(h.id);
          return Card(
            child: ListTile(
              title: Text(h.title),
              trailing: Checkbox(
                value: done,
                onChanged: (_) => controller.toggleDone(h.id),
              ),
              onTap: () => controller.toggleDone(h.id),
            ),
          );
        }),
      ],
    );
  }
}