// === lib/core/subscription/subscription_controller.dart ===
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_error_message.dart';
import 'revenuecat_service.dart';
import 'subscription_state.dart';

const bool premiumPreviewFromBuild = bool.fromEnvironment(
  'RELEAF_PREMIUM_PREVIEW',
  defaultValue: false,
);

/// A transient RevenueCat read failure must never be interpreted as a
/// subscription cancellation. Keep the last known entitlement until a later
/// successful CustomerInfo refresh gives us an authoritative answer.
bool resolvePremiumAfterRefresh({
  required bool currentIsPremium,
  required bool? fetchedIsPremium,
}) {
  return fetchedIsPremium ?? currentIsPremium;
}

/// Releaf 1.0 intentionally sells only the explicitly supported annual and
/// monthly packages. If RevenueCat is misconfigured, fail closed instead of
/// silently exposing an arbitrary custom/legacy package to customers.
List<T> orderedPremiumPackages<T>({T? annual, T? monthly}) {
  final result = <T>[];
  if (annual != null) result.add(annual);
  if (monthly != null) result.add(monthly);
  return List<T>.unmodifiable(result);
}

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final RevenueCatService _service;
  final bool _premiumPreview;
  late final CustomerInfoUpdateListener _customerInfoListener;

  SubscriptionController(
    this._service, {
    bool premiumPreview = premiumPreviewFromBuild,
  })  : _premiumPreview = premiumPreview,
        super(SubscriptionState(isPremium: premiumPreview)) {
    _customerInfoListener = _handleCustomerInfoUpdate;
    _service.addCustomerInfoUpdateListener(_customerInfoListener);
    initAndRefresh();
  }

  Future<void> initAndRefresh() async {
    await refresh();
  }

  Future<void> refresh() async {
    if (_premiumPreview) {
      state = const SubscriptionState(isPremium: true);
      return;
    }

    if (!_service.isInitialized) {
      state = state.copyWith(
        isLoading: false,
        error: 'Premium store is not configured in this build.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.getCustomerInfoSafe();
      final offerings = await _service.getOfferingsSafe();
      final fetchedIsPremium = customerInfo == null
          ? null
          : _service.hasPremium(customerInfo);
      final isPremium = resolvePremiumAfterRefresh(
        currentIsPremium: state.isPremium,
        fetchedIsPremium: fetchedIsPremium,
      );

      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        offerings: offerings,
        isPremium: isPremium,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sync subscriptions.',
      );
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    if (_premiumPreview || !mounted) return;
    state = state.copyWith(
      customerInfo: customerInfo,
      isPremium: _service.hasPremium(customerInfo),
      clearError: true,
    );
  }

  @override
  void dispose() {
    _service.removeCustomerInfoUpdateListener(_customerInfoListener);
    super.dispose();
  }

  Future<bool> purchase(Package package) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.purchasePackage(package);
      final isPremium = _service.hasPremium(customerInfo);
      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        isPremium: isPremium,
      );
      return isPremium;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      final message = revenueCatBillingMessage(
        code,
        action: RevenueCatBillingAction.purchase,
      );
      state = state.copyWith(
        isLoading: false,
        error: message,
        clearError: message == null,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to complete the purchase right now. Please try again.',
      );
      return false;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.restorePurchases();
      final isPremium = _service.hasPremium(customerInfo);
      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        isPremium: isPremium,
        error: isPremium ? null : 'No active subscriptions found.',
      );
      return isPremium;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      final message = revenueCatBillingMessage(
        code,
        action: RevenueCatBillingAction.restore,
      );
      state = state.copyWith(
        isLoading: false,
        error: message,
        clearError: message == null,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to restore purchases right now. Please try again.',
      );
      return false;
    }
  }

  List<Package> getOrderedPackages() {
    final current = state.offerings?.current;
    if (current == null) return const <Package>[];

    return orderedPremiumPackages<Package>(
      annual: current.annual,
      monthly: current.monthly,
    );
  }
}
