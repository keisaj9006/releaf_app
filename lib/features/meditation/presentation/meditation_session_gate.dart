import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../data/meditation_catalog.dart';
import '../domain/meditation_content.dart';
import '../domain/meditation_resume_state.dart';
import 'meditation_player_screen.dart';

bool canAccessMeditationSession(
  MeditationContent item, {
  required bool isPremiumUser,
}) {
  return !item.isPremium || isPremiumUser;
}

class MeditationSessionGate extends ConsumerStatefulWidget {
  const MeditationSessionGate({
    super.key,
    required this.meditationId,
    this.resumeState,
  });

  final String meditationId;
  final MeditationResumeState? resumeState;

  @override
  ConsumerState<MeditationSessionGate> createState() =>
      _MeditationSessionGateState();
}

class _MeditationSessionGateState
    extends ConsumerState<MeditationSessionGate> {
  bool _handlingDeniedAccess = false;
  bool _handlingUnknownSession = false;

  @override
  Widget build(BuildContext context) {
    final item =
        ref.watch(meditationCatalogProvider).getById(widget.meditationId);

    if (item == null) {
      _returnUnknownSessionToMeditate();
      return const _LoadingMeditation();
    }

    // Free practices never depend on RevenueCat state.
    if (!item.isPremium) {
      return MeditationPlayerScreen(
        meditationId: item.id,
        resumeState: widget.resumeState,
      );
    }

    final subscription = ref.watch(subscriptionControllerProvider);
    if (subscription.isLoading) return const _LoadingMeditation();

    if (canAccessMeditationSession(
      item,
      isPremiumUser: subscription.isPremium,
    )) {
      return MeditationPlayerScreen(
        meditationId: item.id,
        resumeState: widget.resumeState,
      );
    }

    _showPaywallAndReturnToMeditate();
    return const _LoadingMeditation();
  }

  void _returnUnknownSessionToMeditate() {
    if (_handlingUnknownSession) return;
    _handlingUnknownSession = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.meditate);
    });
  }

  void _showPaywallAndReturnToMeditate() {
    if (_handlingDeniedAccess) return;
    _handlingDeniedAccess = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await maybeShowPaywall(context, ref, force: true);
      if (!mounted) return;

      final isPremium = ref.read(subscriptionControllerProvider).isPremium;
      if (!isPremium) context.go(AppRoutes.meditate);
    });
  }
}

class _LoadingMeditation extends StatelessWidget {
  const _LoadingMeditation();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0D0B),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB9AFC4),
        ),
      ),
    );
  }
}
