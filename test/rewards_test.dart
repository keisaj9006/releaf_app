import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';

const _today = '2026-09-03';

Future<ProviderContainer> _createContainer([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();

  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      todayProvider.overrideWithValue(_today),
    ],
  );
}

void main() {
  test('Relief completion is idempotent under overlapping calls', () async {
    final container = await _createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(leavesNotifierProvider.notifier);

    final results = await Future.wait(
      List.generate(5, (_) => notifier.markReliefDone()),
    );

    expect(results.where((result) => result != null), hasLength(1));
    expect(container.read(leavesNotifierProvider).reliefDone, isTrue);
    expect(container.read(leavesNotifierProvider).totalLeaves, 1);
  });

  test('Brain completion is idempotent under overlapping calls', () async {
    final container = await _createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(leavesNotifierProvider.notifier);

    final results = await Future.wait(
      List.generate(5, (_) => notifier.markBrainDone()),
    );

    expect(results.where((result) => result != null), hasLength(1));
    expect(container.read(leavesNotifierProvider).brainDone, isTrue);
    expect(container.read(leavesNotifierProvider).totalLeaves, 2);
  });

  test('Habit completion is idempotent under overlapping calls', () async {
    final container = await _createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(leavesNotifierProvider.notifier);

    final results = await Future.wait(
      List.generate(5, (_) => notifier.markHabitDone()),
    );

    expect(results.where((result) => result != null), hasLength(1));
    expect(container.read(leavesNotifierProvider).habitDone, isTrue);
    expect(container.read(leavesNotifierProvider).totalLeaves, 1);
  });

  test('Perfect-day bonus is awarded only once', () async {
    final container = await _createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(leavesNotifierProvider.notifier);

    expect((await notifier.markReliefDone())?.totalAdded, 1);
    expect((await notifier.markHabitDone())?.totalAdded, 1);
    final finalReward = await notifier.markBrainDone();

    expect(finalReward?.added, 2);
    expect(finalReward?.bonusAdded, 2);
    expect(container.read(leavesNotifierProvider).totalLeaves, 6);

    final duplicateResults = await Future.wait([
      notifier.markReliefDone(),
      notifier.markHabitDone(),
      notifier.markBrainDone(),
      notifier.markBrainDone(),
    ]);

    expect(duplicateResults, everyElement(isNull));
    expect(container.read(leavesNotifierProvider).totalLeaves, 6);

    final preferences = container.read(sharedPreferencesProvider);
    expect(preferences.getInt('totalLeaves'), 6);
    expect(preferences.getBool('reliefDone'), isTrue);
    expect(preferences.getBool('habitDone'), isTrue);
    expect(preferences.getBool('brainDone'), isTrue);
  });

  test('A new day reset cannot lose the first completion', () async {
    final container = await _createContainer({
      'todayKey': '2026-09-02',
      'totalLeaves': 7,
      'reliefDone': true,
      'habitDone': true,
      'brainDone': true,
    });
    addTearDown(container.dispose);
    final notifier = container.read(leavesNotifierProvider.notifier);

    await notifier.markReliefDone();

    final state = container.read(leavesNotifierProvider);
    expect(state.todayKey, _today);
    expect(state.totalLeaves, 8);
    expect(state.reliefDone, isTrue);
    expect(state.habitDone, isFalse);
    expect(state.brainDone, isFalse);
  });
}
