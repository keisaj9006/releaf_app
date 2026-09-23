import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _preferences(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  test('progress survives a new store instance for the same account', () async {
    final preferences = await _preferences({});
    final store = SleepProgressStore(
      preferences,
      accountId: 'account-a',
      now: () => DateTime.utc(2026, 9, 23, 10),
    );

    await store.updatePosition(
      contentId: 'ST-DC-004',
      position: const Duration(minutes: 12),
      duration: const Duration(minutes: 40),
      chapterId: 'chapter-2',
    );

    final restored = SleepProgressStore(preferences, accountId: 'account-a');
    final record = restored.recordFor('ST-DC-004');
    expect(record?.position, const Duration(minutes: 12));
    expect(record?.duration, const Duration(minutes: 40));
    expect(record?.chapterId, 'chapter-2');
    expect(record?.isCompleted, isFalse);
  });

  test(
    'corrupt persisted records fail closed without blocking valid data',
    () async {
      final key = SleepProgressStore.storageKeyForAccount('account-a');
      final preferences = await _preferences({
        key: <String>[
          'not-json',
          '{"contentId":"","positionMs":20}',
          '{"contentId":"valid","positionMs":30000,"durationMs":60000,'
              '"updatedAt":"2026-09-23T10:00:00.000Z",'
              '"isCompleted":false,"isFavourite":false}',
        ],
      });

      final store = SleepProgressStore(preferences, accountId: 'account-a');

      expect(store.state, hasLength(1));
      expect(store.recordFor('valid')?.position, const Duration(seconds: 30));
    },
  );

  test('signed-in accounts use isolated local progress stores', () async {
    final preferences = await _preferences({});
    final accountA = SleepProgressStore(preferences, accountId: 'account-a');
    final accountB = SleepProgressStore(preferences, accountId: 'account-b');

    await accountA.updatePosition(
      contentId: 'story-a',
      position: const Duration(minutes: 3),
      duration: const Duration(minutes: 20),
    );

    expect(accountA.recordFor('story-a'), isNotNull);
    expect(accountB.recordFor('story-a'), isNull);
  });

  test('position is clamped to zero and known duration', () async {
    final preferences = await _preferences({});
    final store = SleepProgressStore(preferences);

    await store.updatePosition(
      contentId: 'story',
      position: const Duration(seconds: -5),
      duration: const Duration(minutes: 10),
    );
    expect(store.recordFor('story')?.position, Duration.zero);

    await store.updatePosition(
      contentId: 'story',
      position: const Duration(minutes: 20),
      duration: const Duration(minutes: 10),
    );
    expect(store.recordFor('story')?.position, const Duration(minutes: 10));
  });

  test(
    'completion is explicit and removes the item from continue listening',
    () async {
      final preferences = await _preferences({});
      final store = SleepProgressStore(preferences);

      await store.updatePosition(
        contentId: 'story',
        position: const Duration(minutes: 8),
        duration: const Duration(minutes: 10),
      );
      expect(store.continueListening, hasLength(1));

      await store.markCompleted(
        contentId: 'story',
        duration: const Duration(minutes: 10),
      );

      expect(store.recordFor('story')?.isCompleted, isTrue);
      expect(store.recordFor('story')?.position, const Duration(minutes: 10));
      expect(store.continueListening, isEmpty);
    },
  );

  test('updates do not overwrite another content record', () async {
    final preferences = await _preferences({});
    var minute = 0;
    final store = SleepProgressStore(
      preferences,
      now: () => DateTime.utc(2026, 9, 23, 10, minute++),
    );

    await store.updatePosition(
      contentId: 'story-a',
      position: const Duration(minutes: 2),
      duration: const Duration(minutes: 20),
    );
    await store.updatePosition(
      contentId: 'story-b',
      position: const Duration(minutes: 5),
      duration: const Duration(minutes: 30),
    );
    await store.updatePosition(
      contentId: 'story-a',
      position: const Duration(minutes: 4),
      duration: const Duration(minutes: 20),
    );

    expect(store.state, hasLength(2));
    expect(store.recordFor('story-a')?.position, const Duration(minutes: 4));
    expect(store.recordFor('story-b')?.position, const Duration(minutes: 5));
    expect(store.continueListening.map((item) => item.contentId), [
      'story-a',
      'story-b',
    ]);
  });

  test(
    'favourite can be toggled independently and clear removes one item',
    () async {
      final preferences = await _preferences({});
      final store = SleepProgressStore(preferences);

      await store.toggleFavourite('story-a');
      await store.toggleFavourite('story-b');
      await store.toggleFavourite('story-b');

      expect(store.recordFor('story-a')?.isFavourite, isTrue);
      expect(store.recordFor('story-b')?.isFavourite, isFalse);

      await store.clear('story-b');
      expect(store.recordFor('story-a'), isNotNull);
      expect(store.recordFor('story-b'), isNull);
    },
  );

  test('queued writes preserve rapid updates in call order', () async {
    final preferences = await _preferences({});
    final store = SleepProgressStore(preferences);

    final first = store.updatePosition(
      contentId: 'story',
      position: const Duration(seconds: 10),
      duration: const Duration(minutes: 20),
    );
    final second = store.updatePosition(
      contentId: 'story',
      position: const Duration(seconds: 20),
      duration: const Duration(minutes: 20),
    );
    await Future.wait([first, second]);

    final restored = SleepProgressStore(preferences);
    expect(restored.recordFor('story')?.position, const Duration(seconds: 20));
  });
}
