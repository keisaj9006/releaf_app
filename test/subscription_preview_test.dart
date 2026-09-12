import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:releaf_app/core/subscription/revenuecat_error_message.dart';
import 'package:releaf_app/core/subscription/revenuecat_auth_identity_coordinator.dart';
import 'package:releaf_app/core/subscription/revenuecat_lifecycle_policy.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';

void main() {
  test(
    'unresolved identity rejects fresh reads and listener entitlements',
    () async {
      final service = _DelayedPremiumService();
      final controller = SubscriptionController(service);
      addTearDown(controller.dispose);
      await controller.refresh();
      expect(controller.state.isPremium, isTrue);
      controller.beginIdentityChange();
      await controller.refresh();
      service.listener!(_TestCustomerInfo());
      expect(controller.state.isPremium, isFalse);
      expect(controller.state.customerInfo, isNull);
      expect(await controller.purchase(_TestPackage()), isFalse);
      expect(await controller.restore(), isFalse);
      controller.completeIdentityChange();
      await controller.refresh();
      expect(controller.state.isPremium, isTrue);
    },
  );

  test(
    'failed identity switch stays closed until a successful retry',
    () async {
      final service = _DelayedPremiumService();
      final controller = SubscriptionController(service);
      addTearDown(controller.dispose);
      await controller.refresh();
      var succeeds = false;
      final coordinator = RevenueCatAuthIdentityCoordinator(
        identifyUser: (_) async => succeeds,
        clearUser: () async => succeeds,
        initialUserId: 'account-a',
        beginIdentityChange: controller.beginIdentityChange,
        completeIdentityChange: controller.completeIdentityChange,
        failIdentityChange: controller.failIdentityChange,
        refreshSubscriptions: controller.refresh,
      );
      expect(await coordinator.syncUser('account-b'), isFalse);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.error, contains('Account sync is pending'));
      await controller.refresh();
      service.listener!(_TestCustomerInfo());
      expect(controller.state.isPremium, isFalse);
      succeeds = true;
      service.customerInfoGate = Completer<CustomerInfo?>()
        ..complete(_TestCustomerInfo(premium: false));
      expect(await coordinator.syncUser('account-b'), isTrue);
      expect(controller.state.isPremium, isFalse);
      expect(coordinator.activeUserId, 'account-b');
    },
  );

  for (final latestPremium in [true, false]) {
    test(
      'delayed snapshot cannot replace listener Premium=$latestPremium',
      () async {
        final service = _DelayedPremiumService();
        final controller = SubscriptionController(service);
        addTearDown(controller.dispose);
        await controller.refresh();
        final snapshot = service.customerInfoGate = Completer<CustomerInfo?>();
        final refresh = controller.refresh();
        service.listener!(_TestCustomerInfo(premium: latestPremium));
        snapshot.complete(_TestCustomerInfo(premium: !latestPremium));
        await refresh;
        expect(controller.state.isPremium, latestPremium);
        expect(controller.state.isLoading, isFalse);
      },
    );
  }

  test('valid Premium refresh propagates before offerings finish', () async {
    final service = _DelayedPremiumService()
      ..offeringsGate = Completer<Offerings?>();
    final controller = SubscriptionController(service);
    addTearDown(controller.dispose);
    await service.waiting.future;
    expect(controller.state.isPremium, isTrue);
    service.offeringsGate!.complete(null);
    await Future<void>.delayed(Duration.zero);
  });

  test('older refresh cannot overwrite a newer CustomerInfo event', () async {
    final service = _DelayedPremiumService();
    final controller = SubscriptionController(service);
    addTearDown(controller.dispose);
    await controller.refresh();
    service.offeringsGate = Completer<Offerings?>();
    final refresh = controller.refresh();
    await service.waiting.future;
    service.listener!(_TestCustomerInfo(premium: false));
    expect(controller.state.isPremium, isFalse);
    service.offeringsGate!.complete(null);
    await refresh;
    expect(controller.state.isPremium, isFalse);
  });

  for (final operation in ['purchase', 'restore']) {
    test(
      'obsolete $operation result cannot cross an identity boundary (fake service)',
      () async {
        final service = _DelayedPremiumService();
        final controller = SubscriptionController(service);
        addTearDown(controller.dispose);
        await controller.refresh();
        final pending = operation == 'purchase'
            ? controller.purchase(_TestPackage())
            : controller.restore();
        controller.beginIdentityChange();
        service.billingGate.complete(_TestCustomerInfo());
        expect(await pending, isFalse);
        expect(controller.state.isPremium, isFalse);
        expect(controller.state.customerInfo, isNull);
      },
    );
  }

  test('delayed refresh is harmless after disposal', () async {
    final service = _DelayedPremiumService();
    final controller = SubscriptionController(service);
    await controller.refresh();
    service.offeringsGate = Completer<Offerings?>();
    final pending = controller.refresh();
    await service.waiting.future;
    controller.dispose();
    service.offeringsGate!.complete(null);
    await pending;
  });

  test(
    'obsolete refresh failure cannot replace the new identity state',
    () async {
      final service = _DelayedPremiumService();
      final controller = SubscriptionController(service);
      addTearDown(controller.dispose);
      await controller.refresh();
      final oldGate = service.offeringsGate = Completer<Offerings?>();
      final pending = controller.refresh();
      await service.waiting.future;
      controller.beginIdentityChange();
      service.offeringsGate = null;
      controller.completeIdentityChange();
      await controller.refresh();
      oldGate.completeError(StateError('old request failed'));
      await pending;
      expect(controller.state.error, isNull);
      expect(controller.state.isPremium, isTrue);
    },
  );

  test('identity change rejects an older Premium refresh', () async {
    final service = _DelayedPremiumService();
    final controller = SubscriptionController(service);
    addTearDown(controller.dispose);
    await controller.refresh();
    expect(controller.state.isPremium, isTrue);
    service.offeringsGate = Completer<Offerings?>();
    final oldRefresh = controller.refresh();
    await service.waiting.future;
    controller.beginIdentityChange();
    expect(controller.state.isPremium, isFalse);
    service.offeringsGate!.complete(null);
    await oldRefresh;
    expect(controller.state.isPremium, isFalse);
    expect(controller.state.customerInfo, isNull);
  });

  test('RevenueCat configuration reuses restored user identity at launch', () {
    final identified = RevenueCatService.buildConfiguration(
      apiKey: ' public-key ',
      appUserId: ' user-123 ',
    );
    final anonymous = RevenueCatService.buildConfiguration(
      apiKey: 'public-key',
      appUserId: '   ',
    );

    expect(identified.apiKey, 'public-key');
    expect(identified.appUserID, 'user-123');
    expect(anonymous.appUserID, isNull);
  });

  test(
    'subscription controller attaches and detaches RevenueCat updates',
    () async {
      final service = _ListenerTrackingRevenueCatService();
      final controller = SubscriptionController(service);

      expect(service.addCalls, 1);
      expect(service.listener, isNotNull);

      await controller.refresh();
      controller.dispose();

      expect(service.removeCalls, 1);
      expect(service.listener, isNull);
    },
  );

  test('standard build exposes missing RevenueCat configuration', () async {
    final controller = SubscriptionController(RevenueCatService());
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.state.isPremium, isFalse);
    expect(
      controller.state.error,
      'Premium store is not configured in this build.',
    );
  });

  test(
    'owner Premium preview keeps entitlement active without RevenueCat',
    () async {
      final controller = SubscriptionController(
        RevenueCatService(),
        premiumPreview: true,
      );
      addTearDown(controller.dispose);

      expect(controller.state.isPremium, isTrue);

      await controller.refresh();

      expect(controller.state.isPremium, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.error, isNull);
    },
  );

  test('transient subscription read failure preserves last known state', () {
    expect(
      resolvePremiumAfterRefresh(
        currentIsPremium: true,
        fetchedIsPremium: null,
      ),
      isTrue,
    );
    expect(
      resolvePremiumAfterRefresh(
        currentIsPremium: false,
        fetchedIsPremium: null,
      ),
      isFalse,
    );
  });

  test('successful subscription refresh is authoritative', () {
    expect(
      resolvePremiumAfterRefresh(
        currentIsPremium: true,
        fetchedIsPremium: false,
      ),
      isFalse,
    );
    expect(
      resolvePremiumAfterRefresh(
        currentIsPremium: false,
        fetchedIsPremium: true,
      ),
      isTrue,
    );
  });

  test('Premium refreshes on resume only when RevenueCat is ready', () {
    expect(
      shouldRefreshRevenueCatOnLifecycle(
        state: AppLifecycleState.resumed,
        isRevenueCatInitialized: true,
      ),
      isTrue,
    );
    expect(
      shouldRefreshRevenueCatOnLifecycle(
        state: AppLifecycleState.resumed,
        isRevenueCatInitialized: false,
      ),
      isFalse,
    );
    expect(
      shouldRefreshRevenueCatOnLifecycle(
        state: AppLifecycleState.paused,
        isRevenueCatInitialized: true,
      ),
      isFalse,
    );
    expect(
      shouldRefreshRevenueCatOnLifecycle(
        state: AppLifecycleState.inactive,
        isRevenueCatInitialized: true,
      ),
      isFalse,
    );
  });

  test('billing copy treats cancellation as a normal user action', () {
    expect(
      revenueCatBillingMessage(
        PurchasesErrorCode.purchaseCancelledError,
        action: RevenueCatBillingAction.purchase,
      ),
      isNull,
    );
  });

  test(
    'billing copy explains pending Google Play payment without failure wording',
    () {
      expect(
        revenueCatBillingMessage(
          PurchasesErrorCode.paymentPendingError,
          action: RevenueCatBillingAction.purchase,
        ),
        'Your payment is pending in Google Play. Premium will unlock automatically after the payment is confirmed.',
      );
    },
  );

  test(
    'billing copy maps connectivity and ownership errors to useful recovery',
    () {
      expect(
        revenueCatBillingMessage(
          PurchasesErrorCode.networkError,
          action: RevenueCatBillingAction.purchase,
        ),
        contains('Check your connection'),
      );
      expect(
        revenueCatBillingMessage(
          PurchasesErrorCode.productAlreadyPurchasedError,
          action: RevenueCatBillingAction.purchase,
        ),
        contains('Restore purchases'),
      );
    },
  );

  test('billing copy never exposes raw configuration errors', () {
    expect(
      revenueCatBillingMessage(
        PurchasesErrorCode.configurationError,
        action: RevenueCatBillingAction.restore,
      ),
      'Premium store setup is unavailable in this build.',
    );
  });

  test('Premium offer exposes only annual then monthly packages', () {
    expect(
      orderedPremiumPackages<String>(annual: 'annual', monthly: 'monthly'),
      <String>['annual', 'monthly'],
    );
    expect(orderedPremiumPackages<String>(monthly: 'monthly'), <String>[
      'monthly',
    ]);
  });

  test('Premium offer fails closed when supported packages are missing', () {
    expect(orderedPremiumPackages<String>(), isEmpty);
  });
}

class _ListenerTrackingRevenueCatService extends RevenueCatService {
  CustomerInfoUpdateListener? listener;
  int addCalls = 0;
  int removeCalls = 0;

  @override
  bool get isInitialized => true;

  @override
  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener value) {
    addCalls++;
    listener = value;
  }

  @override
  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener value) {
    removeCalls++;
    if (identical(listener, value)) {
      listener = null;
    }
  }

  @override
  Future<CustomerInfo?> getCustomerInfoSafe() async => null;

  @override
  Future<Offerings?> getOfferingsSafe() async => null;
}

class _TestCustomerInfo implements CustomerInfo {
  _TestCustomerInfo({this.premium = true});
  final bool premium;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestPackage implements Package {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedPremiumService extends _ListenerTrackingRevenueCatService {
  Completer<CustomerInfo?>? customerInfoGate;
  final billingGate = Completer<CustomerInfo>();
  @override
  Future<CustomerInfo> purchasePackage(Package package) => billingGate.future;
  @override
  Future<CustomerInfo> restorePurchases() => billingGate.future;
  Completer<Offerings?>? offeringsGate;
  final waiting = Completer<void>();
  @override
  Future<CustomerInfo?> getCustomerInfoSafe() async => customerInfoGate == null
      ? _TestCustomerInfo()
      : await customerInfoGate!.future;
  @override
  bool hasPremium(CustomerInfo info) => (info as _TestCustomerInfo).premium;
  @override
  Future<Offerings?> getOfferingsSafe() async {
    final gate = offeringsGate;
    if (gate == null) return null;
    if (!waiting.isCompleted) waiting.complete();
    return gate.future;
  }
}
