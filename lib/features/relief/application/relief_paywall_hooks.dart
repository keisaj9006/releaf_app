import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../paywall/presentation/paywall_sheet.dart';

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
    }) async {
  final isPremium = ref.read(subscriptionControllerProvider).isPremium;
  if (isPremium) return;

  final trigger = ref.read(paywallTriggerProvider);
  final shouldShow = trigger.shouldShowPaywall();
  if (!shouldShow) return;
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1C1F24),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => PaywallSheet(softOffer: softOffer),
  );

  await trigger.markPaywallShown();
}