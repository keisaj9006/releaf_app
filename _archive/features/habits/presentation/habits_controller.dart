// FILE: lib/features/habits/presentation/habits_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../model/habit.dart';

class HabitsState {
  final List<Habit> habits;
  final Set<String> doneToday;

  const HabitsState({required this.habits, required this.doneToday});

  HabitsState copyWith({List<Habit>? habits, Set<String>? doneToday}) {
    return HabitsState(
      habits: habits ?? this.habits,
      doneToday: doneToday ?? this.doneToday,
    );
  }
}

class HabitsController extends Notifier<HabitsState> {
  @override
  HabitsState build() {
    final repo = ref.read(habitsRepositoryProvider);
    final habits = repo.loadHabitsOrDefault();
    // ensure defaults persisted once
    repo.saveHabits(habits);
    final doneToday = repo.loadDoneForDate(DateTime.now());
    return HabitsState(habits: habits, doneToday: doneToday);
  }

  Future<void> toggleDone(String habitId) async {
    final repo = ref.read(habitsRepositoryProvider);
    final updated = {...state.doneToday};
    if (updated.contains(habitId)) {
      updated.remove(habitId);
    } else {
      updated.add(habitId);
    }
    await repo.setDoneForDate(DateTime.now(), updated);
    state = state.copyWith(doneToday: updated);
  }

  int streakFor(String habitId) {
    final repo = ref.read(habitsRepositoryProvider);
    return repo.calculateStreak(habitId, DateTime.now());
  }
}