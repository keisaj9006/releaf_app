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
  int _identityVersion = 0;
  int _customerInfoVersion = 0;
  int _refreshVersion = 0;
  bool _identityPending = false;

  bool _currentIdentity(int version) => mounted && version == _identityVersion;

  SubscriptionController(
    this._service, {
    bool premiumPreview = premiumPreviewFromBuild,
  }) : _premiumPreview = premiumPreview,
       super(SubscriptionState(isPremium: premiumPreview)) {
    _customerInfoListener = _handleCustomerInfoUpdate;
    _service.addCustomerInfoUpdateListener(_customerInfoListener);
    initAndRefresh();
  }

  Future<void> initAndRefresh() async {
    await refresh();
  }

  /// Clears account-bound billing state before RevenueCat changes App User ID.
  ///
  /// This is deliberately fail-closed: a Premium entitlement cached for user A
  /// must never remain visible while the SDK is switching to user B. The next
  /// CustomerInfo update or [refresh] restores the authoritative state.
  void beginIdentityChange() {
    if (_premiumPreview || !mounted) return;
    _identityVersion++;
    _identityPending = true;
    state = const SubscriptionState(isLoading: true);
  }

  /// Called only after the latest requested store identity has been confirmed.
  void completeIdentityChange() {
    if (!mounted) return;
    _identityPending = false;
  }

  void failIdentityChange() {
    if (!mounted || !_identityPending) return;
    state = const SubscriptionState(
      error: 'Account sync is pending. Reopen Releaf to retry.',
    );
  }

  Future<void> refresh() async {
    if (!mounted) return;
    if (_identityPending) {
      failIdentityChange();
      return;
    }
    final identityVersion = _identityVersion;
    final refreshVersion = ++_refreshVersion;
    final customerInfoVersion = ++_customerInfoVersion;
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
      if (!_currentIdentity(identityVersion)) return;
      // Access must not wait for store merchandise. A newer listener/billing
      // result is authoritative over the snapshot requested by this refresh.
      if (customerInfo != null && customerInfoVersion == _customerInfoVersion) {
        _handleCustomerInfoUpdate(customerInfo);
      }
      final offerings = await _service.getOfferingsSafe();
      if (!_currentIdentity(identityVersion) ||
          refreshVersion != _refreshVersion) {
        return;
      }

      state = state.copyWith(isLoading: false, offerings: offerings);
    } catch (_) {
      if (!_currentIdentity(identityVersion) ||
          refreshVersion != _refreshVersion) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sync subscriptions.',
      );
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    if (_premiumPreview || !mounted || _identityPending) return;
    _customerInfoVersion++;
    state = state.copyWith(
      customerInfo: customerInfo,
      isPremium: _service.hasPremium(customerInfo),
      clearError: true,
    );
  }

  @override
  void dispose() {
    _identityVersion++;
    _service.removeCustomerInfoUpdateListener(_customerInfoListener);
    super.dispose();
  }

  Future<bool> purchase(Package package) async {
    if (!mounted || _identityPending) return false;
    final identityVersion = _identityVersion;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.purchasePackage(package);
      if (!_currentIdentity(identityVersion)) return false;
      _customerInfoVersion++;
      final isPremium = _service.hasPremium(customerInfo);
      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        isPremium: isPremium,
      );
      return isPremium;
    } on PlatformException catch (error) {
      if (!_currentIdentity(identityVersion)) return false;
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
      if (!_currentIdentity(identityVersion)) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to complete the purchase right now. Please try again.',
      );
      return false;
    }
  }

  Future<bool> restore() async {
    if (!mounted || _identityPending) return false;
    final identityVersion = _identityVersion;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.restorePurchases();
      if (!_currentIdentity(identityVersion)) return false;
      _customerInfoVersion++;
      final isPremium = _service.hasPremium(customerInfo);
      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        isPremium: isPremium,
        error: isPremium ? null : 'No active subscriptions found.',
      );
      return isPremium;
    } on PlatformException catch (error) {
      if (!_currentIdentity(identityVersion)) return false;
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
      if (!_currentIdentity(identityVersion)) return false;
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
