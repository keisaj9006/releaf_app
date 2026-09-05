import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sleep_artwork.dart';
import '../../relief/data/reset_catalog.dart';
import '../../relief/domain/models/reset_content.dart';
import '../../sound/data/sound_catalog.dart';
import '../../sound/domain/sound_content.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  static const _sleepResetIds = [
    'overthinking-night',
    'tension-body-scan',
    'longer-exhale',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetCatalog = ref.watch(resetCatalogProvider);
    final soundCatalog = ref.watch(soundCatalogProvider);
    final sessions = _sleepResetIds
        .map(resetCatalog.getById)
        .whereType<ResetContent>()
        .toList(growable: false);
    final sounds = soundCatalog.getAll();
    final tonight = resetCatalog.getById('evening-unwind');
    final hasPremiumEntitlement =
        ref.watch(subscriptionControllerProvider).isPremium;

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
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            124,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              const SizedBox(height: ReleafSpacing.xxl),
                              if (tonight != null)
                                _TonightCard(
                                  session: tonight,
                                  isLocked: tonight.isPremium &&
                                      !hasPremiumEntitlement,
                                  onPressed: () => context.push(
                                    AppRoutes.reliefSessionFor(tonight.id),
                                  ),
                                ),
                              if (sounds.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _SectionHeading(
                                  eyebrow: 'SOUND FOR SLEEP',
                                  title: 'Stay with one quiet sound.',
                                  description:
                                      'Long-form ambient audio that can keep playing while you settle.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _SoundRail(
                                  sounds: sounds,
                                  onOpen: (track) => context.push(
                                    AppRoutes.soundPlayerFor(track.id),
                                  ),
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        context.push(AppRoutes.sound),
                                    icon: const Icon(
                                      Icons.library_music_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Open sound library'),
                                  ),
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const _SectionHeading(
                                eyebrow: 'WIND DOWN',
                                title: 'Choose the kind of support you need.',
                                description:
                                    'Short guided exercises for a racing mind, body tension or slower breathing.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _SleepResetRail(
                                sessions: sessions,
                                hasPremiumEntitlement:
                                    hasPremiumEntitlement,
                                onOpen: (session) => context.push(
                                  AppRoutes.reliefSessionFor(session.id),
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const _NightNote(),
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
        ReleafSleepArtwork(
          variant: ReleafSleepArtworkVariant.night,
          intensity: 0.72,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x9E070A11),
                Color(0xE5080A0F),
                ReleafColors.background,
              ],
              stops: [0, 0.50, 1],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NIGHT',
              style: ReleafTypography.eyebrow.copyWith(
                color: const Color(0xFFB8B9C9),
                letterSpacing: 1.9,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Sleep',
              style: ReleafTypography.display.copyWith(fontSize: 34),
            ),
            const SizedBox(height: 6),
            Text(
              'A quieter final part of the day, built around guided wind-down and long-form audio.',
              style: ReleafTypography.body.copyWith(
                color: ReleafColors.textSecondary,
              ),
            ),
          ],
        );

        if (compact) return copy;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: copy),
            const SizedBox(width: ReleafSpacing.md),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF141725),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF9A9DB4).withValues(alpha: 0.24),
                ),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: Color(0xFFD4D5DE),
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TonightCard extends StatelessWidget {
  const _TonightCard({
    required this.session,
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Semantics(
          container: true,
          label: 'Tonight. ${session.title}. 8 minute guided wind-down.',
          child: Container(
            key: const Key('sleep-tonight-hero'),
            height: compact ? 366 : 324,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
              border: Border.all(
                color: const Color(0xFF9E9FB1).withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF505775).withValues(alpha: 0.14),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ReleafSleepArtwork(
                  variant: ReleafSleepArtworkVariant.night,
                  intensity: 1,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x05000000),
                        Color(0x35000000),
                        Color(0xED07090D),
                      ],
                      stops: [0, 0.56, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  child: const _GlassTag(
                    icon: Icons.dark_mode_outlined,
                    label: 'TONIGHT',
                  ),
                ),
                Positioned(
                  top: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  right: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  child: _GlassTag(
                    icon: Icons.schedule_rounded,
                    label: _durationLabel(session.durationSeconds),
                  ),
                ),
                Positioned(
                  left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  right: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  bottom: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.display.copyWith(
                          fontSize: compact ? 27 : 31,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      Text(
                        'A guided transition out of unfinished tasks and into a lower-stimulation evening.',
                        maxLines: compact ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.body.copyWith(
                          color:
                              ReleafColors.textPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                      SizedBox(
                        width: compact ? double.infinity : null,
                        height: ReleafControlSizes.standard,
                        child: FilledButton.icon(
                          onPressed: onPressed,
                          icon: Icon(
                            isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.nights_stay_rounded,
                          ),
                          label: Text(
                            isLocked ? 'Unlock tonight' : 'Start tonight',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD8D5CB),
                            foregroundColor: const Color(0xFF101116),
                            padding: const EdgeInsets.symmetric(
                              horizontal: ReleafSpacing.lg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: ReleafTypography.eyebrow.copyWith(
            color: const Color(0xFF9EA4BC),
          ),
        ),
        const SizedBox(height: ReleafSpacing.xs),
        Text(title, style: ReleafTypography.sectionTitle),
        const SizedBox(height: 4),
        Text(description, style: ReleafTypography.body),
      ],
    );
  }
}

class _SoundRail extends StatelessWidget {
  const _SoundRail({
    required this.sounds,
    required this.onOpen,
  });

  final List<SoundContent> sounds;
  final ValueChanged<SoundContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sounds.length,
        separatorBuilder: (_, _) => const SizedBox(width: ReleafSpacing.sm),
        itemBuilder: (context, index) {
          final track = sounds[index];
          final compact = MediaQuery.sizeOf(context).width < 360;

          return SizedBox(
            width: compact ? 232 : 270,
            child: _SoundCard(
              track: track,
              onPressed: () => onOpen(track),
            ),
          );
        },
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.track,
    required this.onPressed,
  });

  final SoundContent track;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1218),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: const Color(0xFF6E8796).withValues(alpha: 0.25),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 122,
                child: ReleafSleepArtwork(
                  variant: ReleafSleepArtworkVariant.sound,
                  intensity: 0.92,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xB30B1218),
                      Color(0xFF0B1218),
                    ],
                    stops: [0.10, 0.50, 0.70],
                  ),
                ),
              ),
              const Positioned(
                top: ReleafSpacing.md,
                left: ReleafSpacing.md,
                child: _GlassTag(
                  icon: Icons.graphic_eq_rounded,
                  label: 'AMBIENT',
                ),
              ),
              Positioned(
                left: ReleafSpacing.md,
                right: ReleafSpacing.md,
                bottom: ReleafSpacing.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Long-form loop',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.xs),
                    Row(
                      children: [
                        Text(
                          'Open player',
                          style: ReleafTypography.meta.copyWith(
                            color: const Color(0xFFABC2CF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 19,
                          color: Color(0xFFC5D5DC),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepResetRail extends StatelessWidget {
  const _SleepResetRail({
    required this.sessions,
    required this.hasPremiumEntitlement,
    required this.onOpen,
  });

  final List<ResetContent> sessions;
  final bool hasPremiumEntitlement;
  final ValueChanged<ResetContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (_, _) => const SizedBox(width: ReleafSpacing.sm),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final compact = MediaQuery.sizeOf(context).width < 360;

          return SizedBox(
            width: compact ? 232 : 270,
            child: _SleepResetCard(
              session: session,
              isLocked: session.isPremium && !hasPremiumEntitlement,
              onPressed: () => onOpen(session),
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
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1015),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: const Color(0xFF787E92).withValues(alpha: 0.23),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 122,
                child: ReleafSleepArtwork(
                  variant: _artworkForSession(session.id),
                  intensity: 0.86,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xB50D1015),
                      Color(0xFF0D1015),
                    ],
                    stops: [0.12, 0.50, 0.70],
                  ),
                ),
              ),
              Positioned(
                top: ReleafSpacing.md,
                left: ReleafSpacing.md,
                child: _GlassTag(
                  icon: _iconFor(session.id),
                  label: _eyebrowFor(session.id),
                ),
              ),
              Positioned(
                left: ReleafSpacing.md,
                right: ReleafSpacing.md,
                bottom: ReleafSpacing.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _durationLabel(session.durationSeconds),
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.xs),
                    Row(
                      children: [
                        Text(
                          isLocked ? 'Premium' : 'Guided',
                          style: ReleafTypography.meta.copyWith(
                            color: isLocked
                                ? ReleafColors.premium
                                : const Color(0xFFB6BBCB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isLocked
                              ? Icons.lock_outline_rounded
                              : Icons.play_arrow_rounded,
                          size: 19,
                          color: isLocked
                              ? ReleafColors.premium
                              : const Color(0xFFCDD0DA),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTag extends StatelessWidget {
  const _GlassTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xA3090B10),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: const Color(0xFFD7D9E3).withValues(alpha: 0.13),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: const Color(0xFFC7CAD6),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: ReleafTypography.meta.copyWith(
                color: const Color(0xFFD4D6DF),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NightNote extends StatelessWidget {
  const _NightNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xE6090C11),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(
          color: const Color(0xFF5F6575).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.bedtime_outlined,
            size: 18,
            color: Color(0xFFA8ADBE),
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Sleep is designed as a wind-down space, not a sleep score or a promise that you will fall asleep.',
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
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

IconData _iconFor(String id) {
  return switch (id) {
    'overthinking-night' => Icons.psychology_outlined,
    'tension-body-scan' => Icons.accessibility_new_rounded,
    'longer-exhale' => Icons.air_rounded,
    _ => Icons.nights_stay_outlined,
  };
}

String _durationLabel(int seconds) {
  if (seconds < 60) return '$seconds sec';
  final minutes = seconds ~/ 60;
  return '$minutes min';
}

ReleafSleepArtworkVariant _artworkForSession(String id) {
  return switch (id) {
    'overthinking-night' => ReleafSleepArtworkVariant.racingMind,
    'tension-body-scan' => ReleafSleepArtworkVariant.body,
    'longer-exhale' => ReleafSleepArtworkVariant.breath,
    _ => ReleafSleepArtworkVariant.night,
  };
}
