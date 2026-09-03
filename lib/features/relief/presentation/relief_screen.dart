// FILE: lib/features/relief/presentation/relief_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../application/relief_paywall_hooks.dart';
import '../data/audio_catalog.dart';

class ReliefScreen extends ConsumerWidget {
  const ReliefScreen({super.key});

  Future<void> _openSession(
    BuildContext context,
    WidgetRef ref,
    ReliefSession session,
    bool isPremiumUser,
  ) async {
    if (session.isPremiumOnly && !isPremiumUser) {
      await maybeShowPaywall(context, ref, force: true);
      return;
    }

    await reliefStarted(ref);

    if (!context.mounted) return;
    final helpedALot = await context.push<bool>(
      '/relief/session/${session.id}',
    );

    if (helpedALot == null || !context.mounted) return;

    await reliefCompleted(ref, helpedALot: helpedALot);

    if (context.mounted) {
      await maybeShowPaywall(
        context,
        ref,
        softOffer: helpedALot,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(audioCatalogProvider);
    final sessions = catalog.getSessions();
    final isPremiumUser = ref.watch(subscriptionControllerProvider).isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121417),
        elevation: 0,
        title: const Text(
          'Fast Resets',
          style: TextStyle(
            color: Color(0xFFF0F2F5),
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final locked = session.isPremiumOnly && !isPremiumUser;

            return _SessionCard(
              title: session.title,
              durationMinutes: session.durationSeconds ~/ 60,
              isLocked: locked,
              onTap: () => _openSession(
                context,
                ref,
                session,
                isPremiumUser,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final int durationMinutes;
  final bool isLocked;
  final VoidCallback onTap;

  const _SessionCard({
    required this.title,
    required this.durationMinutes,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E323B)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF0F2F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLocked ? 'Premium Protocol' : '$durationMinutes min reset',
                    style: TextStyle(
                      color: isLocked
                          ? const Color(0xFF686D7B)
                          : const Color(0xFFA1A6B4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(
                Icons.lock_outline,
                color: Color(0xFFE2C792),
                size: 22,
              )
            else
              const Icon(
                Icons.play_circle_fill,
                color: Color(0xFF6B9080),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
