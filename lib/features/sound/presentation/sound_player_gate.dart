import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../data/sound_catalog.dart';
import '../domain/sound_content.dart';
import 'sound_player_screen.dart';

bool canAccessSoundTrack(
  SoundContent track, {
  required bool isPremiumUser,
}) {
  return !track.isPremium || isPremiumUser;
}

class SoundPlayerGate extends ConsumerStatefulWidget {
  const SoundPlayerGate({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  ConsumerState<SoundPlayerGate> createState() => _SoundPlayerGateState();
}

class _SoundPlayerGateState extends ConsumerState<SoundPlayerGate> {
  bool _handlingDeniedAccess = false;
  bool _handlingUnknownTrack = false;

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(soundCatalogProvider).getById(widget.trackId);

    if (track == null) {
      _returnToSound();
      return const _LoadingSound();
    }

    if (!track.isPremium) {
      return SoundPlayerScreen(trackId: track.id);
    }

    final subscription = ref.watch(subscriptionControllerProvider);
    if (subscription.isLoading) return const _LoadingSound();

    if (canAccessSoundTrack(
      track,
      isPremiumUser: subscription.isPremium,
    )) {
      return SoundPlayerScreen(trackId: track.id);
    }

    _showPaywallAndReturn();
    return const _LoadingSound();
  }

  void _returnToSound() {
    if (_handlingUnknownTrack) return;
    _handlingUnknownTrack = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.sound);
    });
  }

  void _showPaywallAndReturn() {
    if (_handlingDeniedAccess) return;
    _handlingDeniedAccess = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await maybeShowPaywall(context, ref, force: true);
      if (!mounted) return;

      final isPremium = ref.read(subscriptionControllerProvider).isPremium;
      if (!isPremium) context.go(AppRoutes.sound);
    });
  }
}

class _LoadingSound extends StatelessWidget {
  const _LoadingSound();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF071013),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFBFDDE2),
        ),
      ),
    );
  }
}
