// FILE: lib/core/subscription/revenuecat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _premiumEntitlementId = 'premium';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init({required String apiKey, required bool debug}) async {
    if (_initialized) return;

    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty || trimmedKey.startsWith('REVENUECAT_')) {
      return;
    }

    try {
      await Purchases.setLogLevel(debug ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(PurchasesConfiguration(trimmedKey));
      _initialized = true;
    } catch (_) {
      _initialized = false;
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

  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    final result = await Purchases.purchasePackage(package);
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    return Purchases.restorePurchases();
  }
}
