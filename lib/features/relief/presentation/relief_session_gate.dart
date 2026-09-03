import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../application/relief_paywall_hooks.dart';
import '../data/audio_catalog.dart';
import 'breathing_widget.dart';

bool canAccessReliefSession(
  ReliefSession session, {
  required bool isPremiumUser,
}) {
  return session.isEmergency || !session.isPremiumOnly || isPremiumUser;
}

class ReliefSessionGate extends ConsumerStatefulWidget {
  final String sessionId;

  const ReliefSessionGate({super.key, required this.sessionId});

  @override
  ConsumerState<ReliefSessionGate> createState() =>
      _ReliefSessionGateState();
}

class _ReliefSessionGateState extends ConsumerState<ReliefSessionGate> {
  bool _handlingDeniedAccess = false;
  bool _handlingUnknownSession = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(audioCatalogProvider).getById(widget.sessionId);

    if (session == null) {
      _returnUnknownSessionToRelief();
      return const _LoadingSession();
    }

    // Emergency and free sessions never read or depend on RevenueCat state.
    if (session.isEmergency || !session.isPremiumOnly) {
      return BreathingWidget(sessionId: session.id);
    }

    final subscription = ref.watch(subscriptionControllerProvider);
    if (subscription.isLoading) return const _LoadingSession();

    if (canAccessReliefSession(
      session,
      isPremiumUser: subscription.isPremium,
    )) {
      return BreathingWidget(sessionId: session.id);
    }

    _showPaywallAndReturnToRelief();
    return const _LoadingSession();
  }

  void _returnUnknownSessionToRelief() {
    if (_handlingUnknownSession) return;
    _handlingUnknownSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.relief);
    });
  }

  void _showPaywallAndReturnToRelief() {
    if (_handlingDeniedAccess) return;
    _handlingDeniedAccess = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await maybeShowPaywall(context, ref, force: true);
      if (!mounted) return;

      final isPremium = ref.read(subscriptionControllerProvider).isPremium;
      if (!isPremium) context.go(AppRoutes.relief);
    });
  }
}

class _LoadingSession extends StatelessWidget {
  const _LoadingSession();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121417),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6B9080)),
      ),
    );
  }
}
