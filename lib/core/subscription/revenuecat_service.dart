// FILE: lib/core/subscription/revenuecat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // TODO: ustaw ID entitlementu dokładnie jak w RevenueCat (np. "premium")
  static const String _premiumEntitlementId = 'premium';

  bool _initialized = false;

  Future<void> init({required String apiKey, required bool debug}) async {
    if (_initialized) return;

    await Purchases.setLogLevel(debug ? LogLevel.debug : LogLevel.info);

    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    _initialized = true;
  }

  Future<CustomerInfo?> getCustomerInfoSafe() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  Future<Offerings?> getOfferingsSafe() async {
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
    final result = await Purchases.purchasePackage(package);
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }
}