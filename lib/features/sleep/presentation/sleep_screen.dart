import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../relief/data/reset_catalog.dart';
import '../../relief/domain/models/reset_content.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  static const _sleepResetIds = [
    'evening-unwind',
    'overthinking-night',
    'tension-body-scan',
    'longer-exhale',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(resetCatalogProvider);
    final sessions = _sleepResetIds
        .map(catalog.getById)
        .whereType<ResetContent>()
        .toList();
    final tonight = catalog.getById('evening-unwind');

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _SleepBackdrop()),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            ReleafSpacing.xxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              const SizedBox(height: ReleafSpacing.xxl),
                              if (tonight != null)
                                _TonightCard(
                                  session: tonight,
                                  onPressed: () => context.push(
                                    AppRoutes.reliefSessionFor(tonight.id),
                                  ),
                                ),
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Wind Down',
                                description:
                                    'Choose the kind of support your evening needs.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              for (final session in sessions) ...[
                                _SleepResetCard(
                                  session: session,
                                  onPressed: () => context.push(
                                    AppRoutes.reliefSessionFor(session.id),
                                  ),
                                ),
                                const SizedBox(height: ReleafSpacing.sm),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Sound',
                                description:
                                    'Keep a quiet audio layer playing while you settle.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _SoundCard(
                                onPressed: () => context.push(AppRoutes.sound),
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
    );
  }
}

class _SleepBackdrop extends StatelessWidget {
  const _SleepBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafArtwork(variant: ReleafArtworkVariant.ambient),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xD70A1210),
                Color(0xEE080C0B),
                ReleafColors.background,
              ],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIGHT',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.premium,
                  letterSpacing: 1.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sleep',
                style: ReleafTypography.display.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(
                'Reduce stimulation and make the evening simpler.',
                style: ReleafTypography.body.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ReleafSpacing.md),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ReleafColors.premium.withValues(alpha: 0.08),
            border: Border.all(
              color: ReleafColors.premium.withValues(alpha: 0.22),
            ),
            boxShadow: const [
              BoxShadow(
                color: ReleafColors.glowPremium,
                blurRadius: 22,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.bedtime_outlined,
            color: ReleafColors.premium,
            size: 23,
          ),
        ),
      ],
    );
  }
}

class _TonightCard extends StatelessWidget {
  const _TonightCard({
    required this.session,
    required this.onPressed,
  });

  final ResetContent session;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: onPressed,
      warmAccent: true,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return SizedBox(
            height: compact ? 370 : 294,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ReleafArtwork(
                  variant: ReleafArtworkVariant.ambient,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x08000000),
                        Color(0x42000000),
                        Color(0xED000000),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TONIGHT',
                        style: ReleafTypography.eyebrow.copyWith(
                          color: ReleafColors.premium,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        session.title,
                        style: ReleafTypography.display.copyWith(
                          fontSize: compact ? 26 : 29,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      Text(
                        'An 8-minute guided transition out of the unfinished day.',
                        style: ReleafTypography.body.copyWith(
                          color: ReleafColors.textPrimary.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.lg),
                      SizedBox(
                        width: compact ? double.infinity : null,
                        height: ReleafControlSizes.standard,
                        child: FilledButton.icon(
                          onPressed: onPressed,
                          icon: const Icon(Icons.nights_stay_rounded),
                          label: const Text('Start tonight'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ReleafColors.premium,
                            foregroundColor: ReleafColors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SleepResetCard extends StatelessWidget {
  const _SleepResetCard({
    required this.session,
    required this.onPressed,
  });

  final ResetContent session;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: onPressed,
      warmAccent: session.isPremium,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReleafArtwork(variant: _artworkFor(session.id)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color(0x28000000),
                    Color(0xEA000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _eyebrowFor(session.id),
                          style: ReleafTypography.eyebrow.copyWith(
                            color: session.isPremium
                                ? ReleafColors.premium
                                : ReleafColors.sage,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.cardTitle,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _durationLabel(session.durationSeconds),
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ReleafSpacing.md),
                  Icon(
                    session.isPremium
                        ? Icons.lock_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: session.isPremium
                        ? ReleafColors.premium
                        : ReleafColors.sage,
                    size: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return SizedBox(
            height: compact ? 198 : 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ReleafArtwork(
                  variant: ReleafArtworkVariant.ambient,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0x20000000),
                        Color(0xE5000000),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    compact ? ReleafSpacing.md : ReleafSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 48 : 58,
                        height: compact ? 48 : 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ReleafColors.sage.withValues(alpha: 0.09),
                          border: Border.all(
                            color: ReleafColors.sage.withValues(alpha: 0.20),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          size: compact ? 25 : 30,
                          color: ReleafColors.sage,
                        ),
                      ),
                      SizedBox(
                        width: compact
                            ? ReleafSpacing.sm
                            : ReleafSpacing.lg,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sound Space',
                              style: ReleafTypography.sectionTitle.copyWith(
                                fontSize: compact ? 19 : 22,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Loop ambient audio and set a sleep timer.',
                              maxLines: compact ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ReleafSpacing.xs),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: ReleafColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _eyebrowFor(String id) {
  return switch (id) {
    'overthinking-night' => 'RACING MIND',
    'tension-body-scan' => 'BODY',
    'longer-exhale' => 'BREATH',
    _ => 'EVENING',
  };
}

String _durationLabel(int seconds) {
  if (seconds < 60) return '$seconds sec';
  final minutes = seconds ~/ 60;
  return '$minutes min';
}

ReleafArtworkVariant _artworkFor(String id) {
  return switch (id) {
    'overthinking-night' => ReleafArtworkVariant.focus,
    'tension-body-scan' => ReleafArtworkVariant.grounding,
    'longer-exhale' => ReleafArtworkVariant.breath,
    _ => ReleafArtworkVariant.ambient,
  };
}
