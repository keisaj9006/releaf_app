import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/reset_content.dart';

final resetAccessPolicyProvider = Provider<ResetAccessPolicy>((ref) {
  return const ResetAccessPolicy();
});

enum ResetAccessDecision { allowed, requiresPremium }

/// Pure entitlement policy shared by the Relief list and direct-route guard.
///
/// RevenueCat is deliberately not referenced here. Emergency and free content
/// can therefore be admitted before any subscription state is read.
class ResetAccessPolicy {
  const ResetAccessPolicy();

  bool requiresEntitlement(ResetContent content) {
    if (content.isEmergency) return false;
    return content.accessTier == ResetAccessTier.premium;
  }

  ResetAccessDecision evaluate(
    ResetContent content, {
    required bool hasPremiumEntitlement,
  }) {
    if (!requiresEntitlement(content) || hasPremiumEntitlement) {
      return ResetAccessDecision.allowed;
    }
    return ResetAccessDecision.requiresPremium;
  }

  bool canAccess(
    ResetContent content, {
    required bool hasPremiumEntitlement,
  }) {
    return evaluate(
          content,
          hasPremiumEntitlement: hasPremiumEntitlement,
        ) ==
        ResetAccessDecision.allowed;
  }
}
