// FILE: lib/core/subscription/revenuecat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _premiumEntitlementId = 'premium';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init({
    required String apiKey,
    required bool debug,
    String? appUserId,
  }) async {
    if (_initialized) return;

    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty || trimmedKey.startsWith('REVENUECAT_')) {
      return;
    }

    try {
      await Purchases.setLogLevel(debug ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(
        buildConfiguration(
          apiKey: trimmedKey,
          appUserId: appUserId,
        ),
      );
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static PurchasesConfiguration buildConfiguration({
    required String apiKey,
    String? appUserId,
  }) {
    final configuration = PurchasesConfiguration(apiKey.trim());
    final safeAppUserId = appUserId?.trim();
    if (safeAppUserId != null && safeAppUserId.isNotEmpty) {
      configuration.appUserID = safeAppUserId;
    }
    return configuration;
  }

  Future<CustomerInfo?> identifyUser(String appUserId) async {
    if (!_initialized || appUserId.trim().isEmpty) return null;
    try {
      final result = await Purchases.logIn(appUserId.trim());
      return result.customerInfo;
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> clearUserIdentity() async {
    if (!_initialized) return null;
    try {
      return await Purchases.logOut();
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> getCustomerInfoSafe() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  Future<Offerings?> getOfferingsSafe() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  bool hasPremium(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(_premiumEntitlementId);
  }

  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_initialized) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_initialized) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    return Purchases.restorePurchases();
  }
}
