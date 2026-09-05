// FILE: lib/features/relief/application/relief_paywall_hooks.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/paywall/presentation/paywall_sheet.dart';
import '../../../theme/releaf_design_tokens.dart';

Future<void> reliefStarted(WidgetRef ref) async {
  final isPremium = ref.read(subscriptionControllerProvider).isPremium;
  if (isPremium) return;

  await ref.read(paywallTriggerProvider).incrementReliefStart();
}

Future<void> reliefCompleted(WidgetRef ref, {required bool helpedALot}) async {
  final isPremium = ref.read(subscriptionControllerProvider).isPremium;
  if (isPremium) return;

  await ref.read(paywallTriggerProvider).incrementReliefComplete();
}

Future<void> maybeShowPaywall(
  BuildContext context,
  WidgetRef ref, {
  bool softOffer = false,
  bool force = false,
}) async {
  final isPremium = ref.read(subscriptionControllerProvider).isPremium;
  if (isPremium) return;

  final trigger = ref.read(paywallTriggerProvider);
  if (!force && !trigger.shouldShowPaywall()) return;

  if (!force) {
    final subscription = ref.read(subscriptionControllerProvider.notifier);
    if (subscription.getOrderedPackages().isEmpty) return;
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: ReleafColors.backgroundRaised,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ReleafRadii.extraLarge),
      ),
    ),
    builder: (_) => PaywallSheet(softOffer: softOffer),
  );

  await trigger.markPaywallShown();
}
