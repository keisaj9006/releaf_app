import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../application/relief_paywall_hooks.dart';
import '../data/reset_catalog.dart';
import '../domain/models/reset_content.dart';
import '../domain/reset_access_policy.dart';

class ReliefScreen extends ConsumerWidget {
  const ReliefScreen({super.key});

  Future<void> _openSession(
    BuildContext context,
    WidgetRef ref,
    ResetContent session,
    bool isPremiumUser,
  ) async {
    final accessPolicy = ref.read(resetAccessPolicyProvider);
    if (!accessPolicy.canAccess(
      session,
      hasPremiumEntitlement: isPremiumUser,
    )) {
      await maybeShowPaywall(context, ref, force: true);
      return;
    }

    await reliefStarted(ref);

    if (!context.mounted) return;
    final helpedALot = await context.push<bool>(
      AppRoutes.reliefSessionFor(session.id),
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
    final catalog = ref.watch(resetCatalogProvider);
    final regularContent = catalog.getRegularContent();
    final quickSessions = regularContent
        .where((session) => session.level == ResetLevel.quick)
        .toList();
    final deepSessions = regularContent
        .where((session) => session.level == ResetLevel.deep)
        .toList();
    final accessPolicy = ref.watch(resetAccessPolicyProvider);
    final isPremiumUser = ref.watch(subscriptionControllerProvider).isPremium;

    return Theme(
      data: AppTheme.premiumDark(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: ReleafColors.background,
          body: Stack(
            children: [
              const Positioned.fill(child: _ResetBackdrop()),
              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    key: const Key('reset-content-column'),
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: CustomScrollView(
                      key: const Key('reset-scroll-view'),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            ReleafSpacing.section,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ResetHeader(
                                  onEmergencyPressed: () {
                                    context.push(
                                      AppRoutes.reliefSessionFor(
                                        ResetCatalog.emergencySessionId,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: ReleafSpacing.section),
                                const ReleafSectionHeading(
                                  title: 'Quick Reset',
                                  description: 'Feel steadier in 2–4 minutes.',
                                ),
                                const SizedBox(height: ReleafSpacing.lg),
                                _CategoryOverview(sessions: quickSessions),
                                const SizedBox(height: ReleafSpacing.xl),
                                const _AvailabilityLabel(),
                                const SizedBox(height: ReleafSpacing.sm),
                                ..._sessionCards(
                                  quickSessions,
                                  accessPolicy,
                                  isPremiumUser,
                                  context,
                                  ref,
                                ),
                                const SizedBox(height: ReleafSpacing.section),
                                const ReleafSectionHeading(
                                  title: 'Deep Reset',
                                  description:
                                      'Go deeper with guided 8-minute protocols.',
                                ),
                                const SizedBox(height: ReleafSpacing.xs),
                                const Text(
                                  'The current library begins with a focused '
                                  '3-minute protocol.',
                                  style: ReleafTypography.meta,
                                ),
                                const SizedBox(height: ReleafSpacing.lg),
                                ..._sessionCards(
                                  deepSessions,
                                  accessPolicy,
                                  isPremiumUser,
                                  context,
                                  ref,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sessionCards(
    List<ResetContent> sessions,
    ResetAccessPolicy accessPolicy,
    bool isPremiumUser,
    BuildContext context,
    WidgetRef ref,
  ) {
    return [
      for (var index = 0; index < sessions.length; index++) ...[
        _ResetSessionCard(
          session: sessions[index],
          isLocked: !accessPolicy.canAccess(
            sessions[index],
            hasPremiumEntitlement: isPremiumUser,
          ),
          onPressed: () => _openSession(
            context,
            ref,
            sessions[index],
            isPremiumUser,
          ),
        ),
        if (index != sessions.length - 1)
          const SizedBox(height: ReleafSpacing.sm),
      ],
    ];
  }
}

class _ResetBackdrop extends StatelessWidget {
  const _ResetBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1712),
            ReleafColors.background,
            Color(0xFF080D0B),
          ],
          stops: [0, 0.42, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.92, -0.92),
            radius: 0.78,
            colors: [ReleafColors.glowSage, Colors.transparent],
            stops: [0, 0.72],
          ),
        ),
      ),
    );
  }
}

class _ResetHeader extends StatelessWidget {
  const _ResetHeader({required this.onEmergencyPressed});

  final VoidCallback onEmergencyPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text('Reset', style: ReleafTypography.display),
            ),
            const SizedBox(width: ReleafSpacing.md),
            ReleafRoundIconButton(
              key: const Key('reset-emergency-action'),
              icon: Icons.health_and_safety_outlined,
              tooltip: 'Open Emergency Grounding',
              onPressed: onEmergencyPressed,
              isWarm: true,
            ),
          ],
        ),
        const SizedBox(height: ReleafSpacing.xs),
        const Text(
          'Choose what you need right now.',
          style: ReleafTypography.body,
        ),
      ],
    );
  }
}

class _CategoryOverview extends StatelessWidget {
  const _CategoryOverview({required this.sessions});

  final List<ResetContent> sessions;

  int _countFor(QuickResetCategory category) {
    return sessions.where((session) => session.quickCategory == category).length;
  }

  @override
  Widget build(BuildContext context) {
    const categories = QuickResetCategory.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 4 : 2;
        final gapWidth = ReleafSpacing.sm * (columns - 1);
        final cardWidth = (constraints.maxWidth - gapWidth) / columns;

        return Wrap(
          spacing: ReleafSpacing.sm,
          runSpacing: ReleafSpacing.sm,
          children: [
            for (final category in categories)
              SizedBox(
                width: cardWidth,
                height: 116,
                child: _CategoryCard(
                  category: category,
                  sessionCount: _countFor(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.sessionCount});

  final QuickResetCategory category;
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    final available = sessionCount > 0;
    final accent = available ? ReleafColors.sage : ReleafColors.textMuted;

    return ReleafPressableCard(
      key: Key('reset-category-${category.name}'),
      padding: const EdgeInsets.all(ReleafSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: available ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(ReleafRadii.small),
            ),
            alignment: Alignment.center,
            child: Icon(_categoryIcon(category), size: 17, color: accent),
          ),
          const Spacer(),
          Text(
            _categoryLabel(category),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ReleafTypography.cardTitle.copyWith(
              color: available
                  ? ReleafColors.textPrimary
                  : ReleafColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: ReleafSpacing.xxs),
          Text(
            available
                ? '$sessionCount ${sessionCount == 1 ? 'session' : 'sessions'}'
                : 'Coming later',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ReleafTypography.meta.copyWith(
              color: available ? ReleafColors.sage : ReleafColors.textMuted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityLabel extends StatelessWidget {
  const _AvailabilityLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('AVAILABLE NOW', style: ReleafTypography.eyebrow),
        SizedBox(width: ReleafSpacing.sm),
        Expanded(child: Divider(height: 1, color: ReleafColors.borderSoft)),
      ],
    );
  }
}

class _ResetSessionCard extends StatelessWidget {
  const _ResetSessionCard({
    required this.session,
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = session.isPremium
        ? ReleafColors.premium
        : ReleafColors.sage;

    return Semantics(
      button: true,
      label: '${session.title}, ${_durationLabel(session.durationSeconds)}, '
          '${session.isPremium ? 'Premium' : 'Free'}',
      child: ReleafPressableCard(
        key: Key('reset-session-${session.id}'),
        onPressed: onPressed,
        warmAccent: session.isPremium,
        padding: const EdgeInsets.symmetric(
          horizontal: ReleafSpacing.md,
          vertical: ReleafSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(ReleafRadii.medium),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(_sessionIcon(session), size: 21, color: accent),
            ),
            const SizedBox(width: ReleafSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.cardTitle,
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: ReleafSpacing.xs,
                    runSpacing: ReleafSpacing.xs,
                    children: [
                      Text(
                        _durationLabel(session.durationSeconds),
                        style: ReleafTypography.meta,
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: ReleafColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        _sessionTypeLabel(session),
                        style: ReleafTypography.meta,
                      ),
                      if (session.isPremium)
                        const ReleafPremiumBadge()
                      else
                        Text(
                          'Free',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.sage,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: ReleafSpacing.sm),
            Container(
              width: ReleafControlSizes.compact,
              height: ReleafControlSizes.compact,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(
                isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
                size: 19,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _durationLabel(int durationSeconds) {
  if (durationSeconds < 120) return '$durationSeconds sec';
  if (durationSeconds % 60 == 0) return '${durationSeconds ~/ 60} min';
  final minutes = durationSeconds ~/ 60;
  final seconds = durationSeconds % 60;
  return '$minutes min $seconds sec';
}

String _categoryLabel(QuickResetCategory category) {
  return switch (category) {
    QuickResetCategory.situational => 'Situational',
    QuickResetCategory.breath => 'Breath',
    QuickResetCategory.noBreath => 'No-Breath',
    QuickResetCategory.lifeUpgrade => 'Life Upgrade',
  };
}

IconData _categoryIcon(QuickResetCategory category) {
  return switch (category) {
    QuickResetCategory.situational => Icons.adjust_rounded,
    QuickResetCategory.breath => Icons.air_rounded,
    QuickResetCategory.noBreath => Icons.spa_outlined,
    QuickResetCategory.lifeUpgrade => Icons.auto_awesome_outlined,
  };
}

IconData _sessionIcon(ResetContent session) {
  return switch (session.modality) {
    ResetModality.breathing => Icons.air_rounded,
    ResetModality.grounding => Icons.spa_outlined,
    ResetModality.guidedPractice => Icons.headphones_rounded,
  };
}

String _sessionTypeLabel(ResetContent session) {
  if (session.quickCategory != null) {
    return _categoryLabel(session.quickCategory!);
  }

  return switch (session.modality) {
    ResetModality.breathing => 'Breathing',
    ResetModality.grounding => 'Grounding',
    ResetModality.guidedPractice => 'Guided',
  };
}
