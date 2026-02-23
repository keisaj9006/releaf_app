// FILE: lib/features/habits/presentation/habits_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/habits_repository.dart';
import '../model/habit.dart';
import '../../progress/data/leaves_repository.dart';

final habitsControllerProvider =
StateNotifierProvider<HabitsController, AsyncValue<List<Habit>>>(
      (ref) {
    final repository = ref.read(habitsRepositoryProvider);
    final leavesNotifier = ref.read(leavesNotifierProvider.notifier);
    return HabitsController(
      repository: repository,
      leavesNotifier: leavesNotifier,
    );
  },
);

class HabitsController extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsController({
    required this.repository,
    required this.leavesNotifier,
  }) : super(const AsyncLoading()) {
    _load();
  }

  final HabitsRepository repository;
  final LeavesNotifier leavesNotifier;

  Future<void> _load() async {
    try {
      final habits = await repository.loadHabits();
      state = AsyncData(habits);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Zwraca RewardResult? (na SnackBar / haptic w UI).
  /// RewardResult jest null, jeśli:
  /// - habit był już done i user odznacza
  /// - filar Habits był już zaliczony dzisiaj
  Future<RewardResult?> toggleHabit(Habit habit) async {
    try {
      final updatedList = await repository.toggleHabit(habit);
      state = AsyncData(updatedList);

      // ważne: habit w argumencie to "stary" stan.
      // jeśli było false -> teraz true, próbujemy zaliczyć filar.
      if (!habit.isDone) {
        return await leavesNotifier.markHabitDone();
      }
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}