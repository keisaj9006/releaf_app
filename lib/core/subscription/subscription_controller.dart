// === lib/core/subscription/subscription_controller.dart ===
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_service.dart';
import 'subscription_state.dart';

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final RevenueCatService _service;

  SubscriptionController(this._service) : super(const SubscriptionState()) {
    initAndRefresh();
  }

  Future<void> initAndRefresh() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customerInfo = await _service.getCustomerInfoSafe();
      final offerings = await _service.getOfferingsSafe();
      final isPremium = customerInfo != null ? _service.hasPremium(customerInfo) : false;

      state = state.copyWith(
        isLoading: false,
        customerInfo: customerInfo,
        offerings: offerings,
        isPremium: isPremium,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to sync subscriptions.');
    }
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
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(isLoading: false, error: e.message);
      } else {
        state = state.copyWith(isLoading: false);
      }
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
    } on PlatformException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  List<Package> getOrderedPackages() {
    final current = state.offerings?.current;
    if (current == null) return [];

    final list = <Package>[];
    if (current.annual != null) list.add(current.annual!);
    if (current.monthly != null) list.add(current.monthly!);

    if (list.isEmpty && current.availablePackages.isNotEmpty) {
      list.add(current.availablePackages.first);
    }
    return list;
  }
}