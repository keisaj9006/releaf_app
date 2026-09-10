import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:releaf_app/core/subscription/revenuecat_error_message.dart';
import 'package:releaf_app/core/subscription/revenuecat_lifecycle_policy.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';

void main() {
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

  test('subscription controller attaches and detaches RevenueCat updates', () async {
    final service = _ListenerTrackingRevenueCatService();
    final controller = SubscriptionController(service);

    expect(service.addCalls, 1);
    expect(service.listener, isNotNull);

    await controller.refresh();
    controller.dispose();

    expect(service.removeCalls, 1);
    expect(service.listener, isNull);
  });

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

  test('owner Premium preview keeps entitlement active without RevenueCat', () async {
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
  });

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

  test('billing copy explains pending Google Play payment without failure wording', () {
    expect(
      revenueCatBillingMessage(
        PurchasesErrorCode.paymentPendingError,
        action: RevenueCatBillingAction.purchase,
      ),
      'Your payment is pending in Google Play. Premium will unlock automatically after the payment is confirmed.',
    );
  });

  test('billing copy maps connectivity and ownership errors to useful recovery', () {
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
  });

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
      orderedPremiumPackages<String>(
        annual: 'annual',
        monthly: 'monthly',
      ),
      <String>['annual', 'monthly'],
    );
    expect(
      orderedPremiumPackages<String>(monthly: 'monthly'),
      <String>['monthly'],
    );
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
