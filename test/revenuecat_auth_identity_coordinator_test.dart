import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/subscription/revenuecat_auth_identity_coordinator.dart';

void main() {
  test('only the latest transition can reopen access', () async {
    final first = Completer<bool>();
    final second = Completer<bool>();
    var closed = false;
    var resolutions = 0;
    final coordinator = RevenueCatAuthIdentityCoordinator(
      initialUserId: 'a',
      identifyUser: (id) => id == 'b' ? first.future : second.future,
      clearUser: () async => false,
      beginIdentityChange: () => closed = true,
      completeIdentityChange: () {
        closed = false;
        resolutions++;
      },
      refreshSubscriptions: () async {},
    );
    final toB = coordinator.syncUser('b');
    await Future<void>.delayed(Duration.zero);
    final toC = coordinator.syncUser('c');
    expect(closed, isTrue);
    first.complete(true);
    expect(await toB, isFalse);
    expect(closed, isTrue);
    expect(resolutions, 0);
    second.complete(true);
    expect(await toC, isTrue);
    expect(closed, isFalse);
    expect(resolutions, 1);
  });

  test(
    'failed logout remains closed and retries without old-account refresh',
    () async {
      var success = false;
      var refreshes = 0;
      var failures = 0;
      final coordinator = RevenueCatAuthIdentityCoordinator(
        initialUserId: 'a',
        identifyUser: (_) async => true,
        clearUser: () async => success,
        failIdentityChange: () => failures++,
        refreshSubscriptions: () async {
          refreshes++;
        },
      );
      expect(await coordinator.syncUser(null), isFalse);
      expect(failures, 1);
      expect(refreshes, 0);
      success = true;
      expect(await coordinator.syncUser(null), isTrue);
      expect(coordinator.activeUserId, isNull);
      expect(refreshes, 1);
    },
  );

  test('restored launch identity is not logged in twice', () async {
    final identified = <String>[];
    var clears = 0;
    var refreshes = 0;

    final coordinator = RevenueCatAuthIdentityCoordinator(
      identifyUser: (userId) async {
        identified.add(userId);
        return true;
      },
      clearUser: () async {
        clears++;
        return true;
      },
      refreshSubscriptions: () async {
        refreshes++;
      },
      initialUserId: ' user-1 ',
    );

    expect(await coordinator.syncUser('user-1'), isTrue);
    expect(coordinator.activeUserId, 'user-1');
    expect(identified, isEmpty);
    expect(clears, 0);
    expect(refreshes, 0);
  });

  test(
    'sign in and sign out synchronize identity then refresh Premium',
    () async {
      final calls = <String>[];
      var refreshes = 0;

      final coordinator = RevenueCatAuthIdentityCoordinator(
        identifyUser: (userId) async {
          calls.add('identify:$userId');
          return true;
        },
        clearUser: () async {
          calls.add('clear');
          return true;
        },
        refreshSubscriptions: () async {
          refreshes++;
        },
      );

      expect(await coordinator.syncUser(' user-2 '), isTrue);
      expect(coordinator.activeUserId, 'user-2');
      expect(await coordinator.syncUser(null), isTrue);
      expect(coordinator.activeUserId, isNull);

      expect(calls, <String>['identify:user-2', 'clear']);
      expect(refreshes, 2);
    },
  );

  test('identity boundary runs before RevenueCat account mutation', () async {
    var premiumVisible = true;
    final calls = <String>[];

    final coordinator = RevenueCatAuthIdentityCoordinator(
      identifyUser: (userId) async {
        calls.add('identify:$userId:${premiumVisible ? 'premium' : 'closed'}');
        return true;
      },
      clearUser: () async => true,
      beginIdentityChange: () {
        calls.add('boundary');
        premiumVisible = false;
      },
      refreshSubscriptions: () async {
        calls.add('refresh');
      },
      initialUserId: 'user-a',
    );

    expect(await coordinator.syncUser('user-b'), isTrue);
    expect(calls, <String>['boundary', 'identify:user-b:closed', 'refresh']);
    expect(premiumVisible, isFalse);
    expect(coordinator.activeUserId, 'user-b');
  });

  test(
    'failed identity mutation is retryable without refreshing old access',
    () async {
      var attempts = 0;
      var refreshes = 0;
      var boundaries = 0;

      final coordinator = RevenueCatAuthIdentityCoordinator(
        identifyUser: (userId) async {
          attempts++;
          return attempts > 1;
        },
        clearUser: () async => true,
        beginIdentityChange: () {
          boundaries++;
        },
        refreshSubscriptions: () async {
          refreshes++;
        },
      );

      expect(await coordinator.syncUser('user-3'), isFalse);
      expect(coordinator.activeUserId, isNull);
      expect(boundaries, 1);
      expect(refreshes, 0);

      expect(await coordinator.syncUser('user-3'), isTrue);
      expect(coordinator.activeUserId, 'user-3');
      expect(attempts, 2);
      expect(boundaries, 2);
      expect(refreshes, 1);
    },
  );

  test('rapid auth changes are serialized in arrival order', () async {
    final firstGate = Completer<void>();
    final calls = <String>[];

    final coordinator = RevenueCatAuthIdentityCoordinator(
      identifyUser: (userId) async {
        calls.add('start:$userId');
        if (userId == 'user-a') {
          await firstGate.future;
        }
        calls.add('done:$userId');
        return true;
      },
      clearUser: () async {
        calls.add('clear');
        return true;
      },
      refreshSubscriptions: () async {},
    );

    final first = coordinator.syncUser('user-a');
    await Future<void>.delayed(Duration.zero);
    final second = coordinator.syncUser('user-b');
    expect(calls, <String>['start:user-a']);

    firstGate.complete();

    expect(await first, isFalse);
    expect(await second, isTrue);
    expect(calls, <String>[
      'start:user-a',
      'done:user-a',
      'start:user-b',
      'done:user-b',
    ]);
    expect(coordinator.activeUserId, 'user-b');
  });
}
