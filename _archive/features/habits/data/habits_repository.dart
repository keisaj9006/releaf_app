// FILE: lib/features/habits/data/habits_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/prefs_keys.dart';
import '../../../core/utils/date_key.dart';
import '../model/habit.dart';

class HabitsRepository {
  HabitsRepository(this._prefs);

  final SharedPreferences _prefs;

  List<Habit> loadHabitsOrDefault() {
    final jsonStr = _prefs.getString(PrefKeys.habitsListJson);
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      // MVP default 3–5 habits (editable later)
      return const [
        Habit(id: 'h_water', title: 'Drink water'),
        Habit(id: 'h_walk', title: 'Short walk'),
        Habit(id: 'h_breathe', title: '1-minute breathing'),
        Habit(id: 'h_sleep', title: 'No screens 30 min before sleep'),
        Habit(id: 'h_focus', title: '2 minutes focus game'),
      ];
    }

    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => Habit(id: e['id'] as String, title: e['title'] as String))
        .toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final jsonStr = json.encode(habits.map((h) => {'id': h.id, 'title': h.title}).toList());
    await _prefs.setString(PrefKeys.habitsListJson, jsonStr);
  }

  Set<String> loadDoneForDate(DateTime date) {
    final key = '${PrefKeys.habitsDonePrefix}${yyyymmdd(date)}';
    final list = _prefs.getStringList(key) ?? const <String>[];
    return list.toSet();
  }

  Future<void> setDoneForDate(DateTime date, Set<String> habitIds) async {
    final key = '${PrefKeys.habitsDonePrefix}${yyyymmdd(date)}';
    await _prefs.setStringList(key, habitIds.toList());
  }

  int calculateStreak(String habitId, DateTime today) {
    var streak = 0;
    var cursor = DateTime(today.year, today.month, today.day);

    while (true) {
      final done = loadDoneForDate(cursor);
      if (done.contains(habitId)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}