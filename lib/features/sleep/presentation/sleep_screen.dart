import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sleep_artwork.dart';
import '../../sound/data/sound_catalog.dart';
import '../../sound/domain/sound_content.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  static const _sleepToneIds = <String>[
    'deep-drift',
    'pink-noise',
    'brown-noise',
    'white-noise',
  ];

  static const _natureSoundIds = <String>[
    'soft-rain',
    'night-air',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(soundCatalogProvider);
    final sleepTones = _sleepToneIds
        .map(catalog.getById)
        .whereType<SoundContent>()
        .toList(growable: false);
    final natureSounds = _natureSoundIds
        .map(catalog.getById)
        .whereType<SoundContent>()
        .toList(growable: false);
    final featured = catalog.getById('deep-drift');

    void open(SoundContent track) {
      context.push(AppRoutes.soundPlayerFor(track.id));
    }

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
                              const SizedBox(height: ReleafSpacing.xl),
                              if (featured != null)
                                _FeaturedSleepSound(
                                  track: featured,
                                  onPressed: () => open(featured),
                                ),
                              if (sleepTones.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _SectionHeading(
                                  eyebrow: 'SLEEP TONES',
                                  title: 'Steady sound, kept low.',
                                  description:
                                      'No voice and no instructions. Choose a soft tonal bed or coloured noise, then let it loop quietly.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _SoundRail(
                                  sounds: sleepTones,
                                  onOpen: open,
                                ),
                              ],
                              if (natureSounds.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _SectionHeading(
                                  eyebrow: 'NATURE AT NIGHT',
                                  title: 'Rain and quiet night air.',
                                  description:
                                      'Simple environmental textures without speech, wildlife calls, thunder or sudden peaks.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _SoundRail(
                                  sounds: natureSounds,
                                  onOpen: open,
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const _ResearchNote(),
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
              'No voice. No instructions. Just low-stimulation sound for the final part of the day.',
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

class _FeaturedSleepSound extends StatelessWidget {
  const _FeaturedSleepSound({
    required this.track,
    required this.onPressed,
  });

  final SoundContent track;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Container(
      key: const Key('sleep-featured-sound'),
      height: compact ? 330 : 300,
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
            variant: ReleafSleepArtworkVariant.sound,
            intensity: 1,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x08000000),
                  Color(0x50000000),
                  Color(0xF007090D),
                ],
                stops: [0, 0.54, 1],
              ),
            ),
          ),
          Positioned(
            top: ReleafSpacing.lg,
            left: ReleafSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(ReleafRadii.pill),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                'TONIGHT · NO VOICE',
                style: ReleafTypography.eyebrow.copyWith(
                  color: const Color(0xFFD1D3DE),
                  fontSize: 8.5,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ),
          Positioned(
            left: ReleafSpacing.lg,
            right: ReleafSpacing.lg,
            bottom: ReleafSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: ReleafTypography.display.copyWith(
                    fontSize: compact ? 27 : 31,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A slow tonal bed with no vocals and no spoken guidance. Start at a low volume and let it fade into the room.',
                  maxLines: compact ? 4 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: ReleafTypography.body.copyWith(
                    color: ReleafColors.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: ReleafSpacing.md),
                FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play for sleep'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD8D5CB),
                    foregroundColor: const Color(0xFF101116),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      key: const Key('sleep-sound-rail'),
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
              Padding(
                padding: const EdgeInsets.all(ReleafSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _soundCategoryLabel(track.category),
                      style: ReleafTypography.eyebrow.copyWith(
                        color: const Color(0xFFA9B8C4),
                        fontSize: 8.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.all_inclusive_rounded,
                          size: 15,
                          color: Color(0xFFA9B8C4),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Continuous loop',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            fontSize: 8.5,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 19,
                          color: Color(0xFFD1D7DE),
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

class _ResearchNote extends StatelessWidget {
  const _ResearchNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-research-note'),
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
            Icons.hearing_outlined,
            size: 18,
            color: Color(0xFFA8ADBE),
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Sound can help some people mask disruptions or settle, but responses vary. Keep playback comfortably low and stop if it feels intrusive. Releaf does not claim that one special carrier frequency treats insomnia.',
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

String _soundCategoryLabel(SoundCategory category) {
  return switch (category) {
    SoundCategory.atmosphere => 'SLEEP TONE',
    SoundCategory.noise => 'COLOURED NOISE',
    SoundCategory.weather => 'NATURE · RAIN',
    SoundCategory.environment => 'NATURE · NIGHT',
  };
}
