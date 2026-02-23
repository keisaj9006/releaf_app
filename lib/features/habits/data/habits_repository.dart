// FILE: lib/features/habits/data/habits_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/habit.dart';

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository();
});

/// Repository responsible for loading and updating habit data. Habits are
/// persisted per day and reset when the day changes.
class HabitsRepository {
  /// Predefined list of habits available in the application.
  static const List<Habit> predefinedHabits = [
    Habit(id: 'drink-water', title: 'Drink water'),
    Habit(id: 'two-min-tidy', title: '2 min tidy'),
    Habit(id: 'one-min-stretch', title: '1 min stretch'),
    Habit(id: 'deep-breaths', title: '3 deep breaths'),
    Habit(id: 'ten-min-walk', title: '10 min walk'),
  ];

  String _currentDateKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Loads all habits with their current completion status.
  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _currentDateKey();
    final List<Habit> result = [];

    for (final habit in predefinedHabits) {
      final String dateKey = '${habit.id}_date';
      final String doneKey = '${habit.id}_done';

      final storedDate = prefs.getString(dateKey);
      bool isDone = false;

      if (storedDate == today) {
        isDone = prefs.getBool(doneKey) ?? false;
      } else {
        await prefs.setString(dateKey, today);
        await prefs.setBool(doneKey, false);
        isDone = false;
      }

      result.add(habit.copyWith(isDone: isDone));
    }
    return result;
  }

  /// Toggles a habit’s completion status and returns the updated list of habits.
  Future<List<Habit>> toggleHabit(Habit habit) async {
    final prefs = await SharedPreferences.getInstance();

    final String dateKey = '${habit.id}_date';
    final String doneKey = '${habit.id}_done';
    final today = _currentDateKey();
    final bool newDone = !habit.isDone;

    await prefs.setString(dateKey, today);
    await prefs.setBool(doneKey, newDone);

    final updatedHabits = await loadHabits();
    return updatedHabits
        .map((h) => h.id == habit.id ? h.copyWith(isDone: newDone) : h)
        .toList();
  }
}