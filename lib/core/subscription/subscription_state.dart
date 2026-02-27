// === lib/core/subscription/subscription_state.dart ===
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionState {
  final bool isPremium;
  final Offerings? offerings;
  final CustomerInfo? customerInfo;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.isPremium = false,
    this.offerings,
    this.customerInfo,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    Offerings? offerings,
    CustomerInfo? customerInfo,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      offerings: offerings ?? this.offerings,
      customerInfo: customerInfo ?? this.customerInfo,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}