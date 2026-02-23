// FILE: lib/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/progress/data/leaves_repository.dart';
import '../features/progress/model/leaves_state.dart';

/// Provider dla SharedPreferences (override w main.dart jeśli chcesz go używać gdzie indziej).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

class ProgressState {
  final int totalLeaves;
  final bool isHabitDone;
  final bool isReliefDone;
  final bool isBrainDone;

  final int completedCount;
  final bool isComplete;

  const ProgressState({
    required this.totalLeaves,
    required this.isHabitDone,
    required this.isReliefDone,
    required this.isBrainDone,
    required this.completedCount,
    required this.isComplete,
  });

  factory ProgressState.fromLeaves(LeavesState s) {
    final count =
        (s.habitDone ? 1 : 0) + (s.reliefDone ? 1 : 0) + (s.brainDone ? 1 : 0);

    return ProgressState(
      totalLeaves: s.totalLeaves,
      isHabitDone: s.habitDone,
      isReliefDone: s.reliefDone,
      isBrainDone: s.brainDone,
      completedCount: count,
      isComplete: count == 3,
    );
  }
}

/// UI bierze progres tylko z LeavesNotifier (jedno źródło prawdy).
final progressStateProvider = Provider<ProgressState>((ref) {
  final leavesState = ref.watch(leavesNotifierProvider);
  return ProgressState.fromLeaves(leavesState);
});

/// Cienka warstwa akcji dla UI.
class ProgressActions {
  final LeavesNotifier _leaves;
  ProgressActions(this._leaves);

  Future<RewardResult?> markHabitDone() => _leaves.markHabitDone();
  Future<RewardResult?> markReliefDone() => _leaves.markReliefDone();
  Future<RewardResult?> markBrainDone() => _leaves.markBrainDone();
}

final progressActionsProvider = Provider<ProgressActions>((ref) {
  final leaves = ref.read(leavesNotifierProvider.notifier);
  return ProgressActions(leaves);
});