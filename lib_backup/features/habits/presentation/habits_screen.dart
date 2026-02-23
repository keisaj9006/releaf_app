// FILE: lib/features/habits/presentation/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/habit.dart';
import 'habits_controller.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: SafeArea(
        child: habitsAsync.when(
          data: (habits) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final Habit habit = habits[index];

                return _HabitTile(
                  title: habit.title,
                  checked: habit.isDone,
                  onTap: () async {
                    final result = await ref
                        .read(habitsControllerProvider.notifier)
                        .toggleHabit(habit);

                    if (!context.mounted || result == null) return;

                    HapticFeedback.lightImpact();

                    final msg = result.hasBonus
                        ? '+${result.totalAdded} leaves • Perfect day bonus!'
                        : '+${result.totalAdded} leaves';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        behavior: SnackBarBehavior.floating,
                        action: result.completedToday == 3
                            ? SnackBarAction(
                          label: 'Home',
                          onPressed: () => Navigator.of(context)
                              .popUntil((r) => r.isFirst),
                        )
                            : null,
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.title,
    required this.checked,
    required this.onTap,
  });

  final String title;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.75),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Checkbox(
                value: checked,
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}