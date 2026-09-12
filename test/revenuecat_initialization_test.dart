import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('purchases_flutter');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('failed native configuration can be retried', () async {
    var setups = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'setupPurchases') {
        setups++;
        if (setups == 1) throw PlatformException(code: 'unavailable');
      }
      return null;
    });
    final service = RevenueCatService();
    await service.init(apiKey: 'test_abcdefghijklmnop', debug: false);
    expect(service.isInitialized, isFalse);
    await service.init(apiKey: 'test_abcdefghijklmnop', debug: false);
    expect(service.isInitialized, isTrue);
    expect(setups, 2);
  });

  test(
    'missing or secret-shaped configuration never reaches native SDK',
    () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        return null;
      });
      final service = RevenueCatService();
      await service.init(apiKey: '', debug: false);
      await service.init(apiKey: 'sk_abcdefghijklmnop', debug: false);
      expect(calls, 0);
      expect(service.isInitialized, isFalse);
      await service.init(apiKey: 'test_abcdefghijklmnop', debug: false);
      expect(service.isInitialized, isTrue);
    },
  );

  test(
    'overlapping initialization configures native Purchases only once',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      var setups = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'setupPurchases') {
          setups++;
          if (!entered.isCompleted) entered.complete();
          await release.future;
        }
        return null;
      });
      final service = RevenueCatService();
      final first = service.init(
        apiKey: 'test_abcdefghijklmnop',
        debug: false,
        appUserId: 'qa-a',
      );
      await entered.future;
      final second = service.init(
        apiKey: 'test_abcdefghijklmnop',
        debug: false,
        appUserId: 'qa-a',
      );
      await Future<void>.delayed(Duration.zero);
      release.complete();
      await Future.wait([first, second]);
      expect(setups, 1);
      expect(service.isInitialized, isTrue);
      await service.init(apiKey: 'test_abcdefghijklmnop', debug: false);
      expect(setups, 1);
    },
  );
}
