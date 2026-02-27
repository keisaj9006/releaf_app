// FILE: lib/features/progress/data/leaves_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../model/leaves_state.dart';

final leavesNotifierProvider =
StateNotifierProvider<LeavesNotifier, LeavesState>(
      (ref) => LeavesNotifier(ref),
);

/// Zwracamy to do UI, żeby móc pokazać SnackBar / Haptic / “Perfect day”.
class RewardResult {
  final int added; // baza (np. Brain=2)
  final int bonusAdded; // bonus za 3/3 (np. +2)
  final int newTotal;
  final int completedToday; // 0..3

  const RewardResult({
    required this.added,
    required this.bonusAdded,
    required this.newTotal,
    required this.completedToday,
  });

  bool get hasBonus => bonusAdded > 0;
  int get totalAdded => added + bonusAdded;
}

class LeavesNotifier extends StateNotifier<LeavesState> {
  /// Riverpod reference to access other providers (prefs, todayProvider)
  final Ref ref;

  LeavesNotifier(this.ref)
      : super(
    LeavesState(
      totalLeaves: 0,
      todayKey: _currentDateString(),
      reliefDone: false,
      habitDone: false,
      brainDone: false,
    ),
  ) {
    _load();
  }

  // ---- Rewards (P0) ----
  static const int _habitReward = 1;
  static const int _reliefReward = 1;
  static const int _brainReward = 2;

  // “podwójnie za trzeci filar” = bonus równy bazie trzeciego filaru
  static int _bonusForThird(int base) => base;

  // ---- Pref keys (z migracją) ----
  static const String _kTotalLeaves = 'totalLeaves';
  static const String _kOldLeavesTotal = 'leaves_total'; // legacy (BrokenMirror itp.)
  static const String _kTodayKey = 'todayKey';
  static const String _kReliefDone = 'reliefDone';
  static const String _kHabitDone = 'habitDone';
  static const String _kBrainDone = 'brainDone';

  static String _currentDateString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int _completedCount(LeavesState s) {
    var c = 0;
    if (s.habitDone) c++;
    if (s.reliefDone) c++;
    if (s.brainDone) c++;
    return c;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);

    // migracja: jeśli ktoś ma stary klucz, przenieś do nowego
    final old = prefs.getInt(_kOldLeavesTotal);
    final storedNew = prefs.getInt(_kTotalLeaves);
    final total = storedNew ?? old ?? 0;

    if (old != null && storedNew == null) {
      await prefs.setInt(_kTotalLeaves, old);
    }

    // ✅ gwarantujemy String (nigdy null)
    final savedTodayKey = prefs.getString(_kTodayKey);
    final today = ref.read(todayProvider);
    final date = (savedTodayKey == null || savedTodayKey.isEmpty) ? today : savedTodayKey;

    final reliefDone = prefs.getBool(_kReliefDone) ?? false;
    final habitDone = prefs.getBool(_kHabitDone) ?? false;
    final brainDone = prefs.getBool(_kBrainDone) ?? false;

    state = LeavesState(
      totalLeaves: total,
      todayKey: date,
      reliefDone: reliefDone,
      habitDone: habitDone,
      brainDone: brainDone,
    );

    await _resetIfNewDay();
  }

  Future<void> _resetIfNewDay() async {
    final current = ref.read(todayProvider);
    if (state.todayKey == current) return;

    final prefs = ref.read(sharedPreferencesProvider);

    state = state.copyWith(
      todayKey: current,
      reliefDone: false,
      habitDone: false,
      brainDone: false,
    );

    await prefs.setString(_kTodayKey, current);
    await prefs.setBool(_kReliefDone, false);
    await prefs.setBool(_kHabitDone, false);
    await prefs.setBool(_kBrainDone, false);
  }

  Future<void> _persistTotal(int total) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_kTotalLeaves, total);
  }

  Future<void> _persistFlag(String key, bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(key, value);
  }

  /// Zostawiamy jako “narzędzie”, ale UI NIE powinno tego wołać za filary.
  Future<void> addLeaves(int amount) async {
    await _resetIfNewDay();
    final newTotal = state.totalLeaves + amount;
    state = state.copyWith(totalLeaves: newTotal);
    await _persistTotal(newTotal);
  }

  /// Relief: raz dziennie +1 (i bonus jeśli to 3/3)
  Future<RewardResult?> markReliefDone() async {
    return _complete(
      baseReward: _reliefReward,
      isDone: state.reliefDone,
      setDone: () async {
        state = state.copyWith(reliefDone: true);
        await _persistFlag(_kReliefDone, true);
      },
    );
  }

  /// Habits: raz dziennie +1 (i bonus jeśli to 3/3)
  Future<RewardResult?> markHabitDone() async {
    return _complete(
      baseReward: _habitReward,
      isDone: state.habitDone,
      setDone: () async {
        state = state.copyWith(habitDone: true);
        await _persistFlag(_kHabitDone, true);
      },
    );
  }

  /// Brain: raz dziennie +2 (i bonus jeśli to 3/3)
  Future<RewardResult?> markBrainDone() async {
    return _complete(
      baseReward: _brainReward,
      isDone: state.brainDone,
      setDone: () async {
        state = state.copyWith(brainDone: true);
        await _persistFlag(_kBrainDone, true);
      },
    );
  }

  Future<RewardResult?> _complete({
    required int baseReward,
    required bool isDone,
    required Future<void> Function() setDone,
  }) async {
    await _resetIfNewDay();
    if (isDone) return null;

    await setDone();

    final completedNow = _completedCount(state);
    final isThird = completedNow == 3;
    final bonus = isThird ? _bonusForThird(baseReward) : 0;

    final newTotal = state.totalLeaves + baseReward + bonus;
    state = state.copyWith(totalLeaves: newTotal);
    await _persistTotal(newTotal);

    return RewardResult(
      added: baseReward,
      bonusAdded: bonus,
      newTotal: newTotal,
      completedToday: completedNow,
    );
  }
}