import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/subscription/revenuecat_auth_identity_coordinator.dart';

void main() {
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

  test('sign in and sign out synchronize identity then refresh Premium', () async {
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
  });

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
    expect(
      calls,
      <String>['boundary', 'identify:user-b:closed', 'refresh'],
    );
    expect(premiumVisible, isFalse);
    expect(coordinator.activeUserId, 'user-b');
  });

  test('failed identity mutation is retryable and restores authoritative state', () async {
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
    expect(refreshes, 1);

    expect(await coordinator.syncUser('user-3'), isTrue);
    expect(coordinator.activeUserId, 'user-3');
    expect(attempts, 2);
    expect(boundaries, 2);
    expect(refreshes, 2);
  });

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
    final second = coordinator.syncUser('user-b');

    await Future<void>.delayed(Duration.zero);
    expect(calls, <String>['start:user-a']);

    firstGate.complete();

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(
      calls,
      <String>[
        'start:user-a',
        'done:user-a',
        'start:user-b',
        'done:user-b',
      ],
    );
    expect(coordinator.activeUserId, 'user-b');
  });
}
