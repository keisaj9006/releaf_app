// FILE: lib/core/di/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/progress/data/leaves_repository.dart';
import '../../features/progress/model/leaves_state.dart';

import '../paywall/paywall_trigger.dart';
import '../subscription/revenuecat_service.dart';
import '../subscription/subscription_controller.dart';
import '../subscription/subscription_state.dart';

/// Provider zwracający dzisiejszy klucz w formacie YYYY-MM-DD.
/// Używany do określania początku nowego dnia oraz w testach.
final todayProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
});

/// Provider dla SharedPreferences (override w main.dart).
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

/// RevenueCat service (singleton-ish).
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Subscription controller/state.
final subscriptionControllerProvider =
StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return SubscriptionController(service);
});

/// Paywall trigger based on counters in SharedPreferences.
final paywallTriggerProvider = Provider<PaywallTrigger>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PaywallTrigger(prefs);
});