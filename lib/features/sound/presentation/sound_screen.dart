import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sound_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../application/sound_player_controller.dart';
import '../data/sound_catalog.dart';
import '../domain/sound_content.dart';

class SoundScreen extends ConsumerWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(soundCatalogProvider);
    final state = ref.watch(soundPlayerControllerProvider);
    final tracks = catalog.getAll();

    final recent = state.recentIds
        .map(catalog.getById)
        .whereType<SoundContent>()
        .toList();
    final favorites = tracks
        .where((track) => state.favoriteIds.contains(track.id))
        .toList();

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _SoundBackdrop()),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            130,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SoundHeader(onBack: context.pop),
                              const SizedBox(height: ReleafSpacing.xxl),
                              _FeaturedSound(
                                track: tracks.first,
                                isPlaying:
                                    state.currentTrackId == tracks.first.id &&
                                    state.isPlaying,
                                onOpen: () => context.push(
                                  AppRoutes.soundPlayerFor(tracks.first.id),
                                ),
                              ),
                              if (recent.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const ReleafSectionHeading(
                                  title: 'Recently Played',
                                  accentColor: ReleafFeatureAccents.sound,
                                  description: 'Return to a space you used before.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _SoundTrackRail(
                                  tracks: recent,
                                  state: state,
                                ),
                              ],
                              if (favorites.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const ReleafSectionHeading(
                                  title: 'Favorites',
                                  accentColor: ReleafFeatureAccents.sound,
                                  description: 'Your saved sound spaces.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _SoundTrackRail(
                                  tracks: favorites,
                                  state: state,
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Available Now',
                                accentColor: ReleafFeatureAccents.sound,
                                description:
                                    'Ambient spaces, noise and environmental textures ready to loop.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              for (final track in tracks) ...[
                                _SoundTrackRow(
                                  track: track,
                                  state: state,
                                ),
                                const SizedBox(height: ReleafSpacing.sm),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.currentTrackId != null)
              Positioned(
                left: ReleafSpacing.screen,
                right: ReleafSpacing.screen,
                bottom: ReleafSpacing.lg,
                child: _InScreenMiniPlayer(state: state),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoundBackdrop extends StatelessWidget {
  const _SoundBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafSoundArtwork(
          variant: ReleafSoundArtworkVariant.field,
          intensity: 0.72,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x9C061014),
                Color(0xE4080F12),
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

class _SoundHeader extends StatelessWidget {
  const _SoundHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReleafRoundIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          accentColor: ReleafFeatureAccents.sound,
          onPressed: onBack,
        ),
        const SizedBox(width: ReleafSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AMBIENT AUDIO',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafFeatureAccents.sound,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Sound',
                style: ReleafTypography.display.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(
                'Long-form audio for focus, rest and lower-stimulation moments.',
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedSound extends StatelessWidget {
  const _FeaturedSound({
    required this.track,
    required this.isPlaying,
    required this.onOpen,
  });

  final SoundContent track;
  final bool isPlaying;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Semantics(
          button: true,
          onTap: onOpen,
          label: '${track.title}. ${track.subtitle}',
          child: ReleafPressableCard(
            key: const Key('sound-featured-card'),
            onPressed: onOpen,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: compact ? 330 : 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ReleafSoundArtwork(
                    variant: _artworkForTrack(track.id),
                    intensity: 0.96,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x08000000),
                          Color(0x33000000),
                          Color(0xED03080A),
                        ],
                        stops: [0, 0.52, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                    left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                    child: const _GlassTag(
                      icon: Icons.graphic_eq_rounded,
                      label: 'FEATURED SOUND',
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
                          track.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.display.copyWith(
                            fontSize: compact ? 26 : 29,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.xs),
                        Text(
                          track.subtitle,
                          maxLines: compact ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.body.copyWith(
                            color:
                                ReleafColors.textPrimary.withValues(alpha: 0.76),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Wrap(
                          spacing: ReleafSpacing.sm,
                          runSpacing: ReleafSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: onOpen,
                              icon: Icon(
                                isPlaying
                                    ? Icons.equalizer_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                isPlaying ? 'Playing now' : 'Open player',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFBFDDE2),
                                foregroundColor: const Color(0xFF091216),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ReleafSpacing.lg,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const _GlassTag(
                              icon: Icons.all_inclusive_rounded,
                              label: 'LOOPS',
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
      },
    );
  }
}

class _SoundTrackRail extends StatelessWidget {
  const _SoundTrackRail({
    required this.tracks,
    required this.state,
  });

  final List<SoundContent> tracks;
  final SoundPlayerState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tracks.length,
        separatorBuilder: (_, _) => const SizedBox(width: ReleafSpacing.sm),
        itemBuilder: (context, index) {
          final track = tracks[index];
          return SizedBox(
            width: math.min(MediaQuery.sizeOf(context).width * 0.72, 330),
            child: _SoundTrackTile(
              track: track,
              isCurrent: state.currentTrackId == track.id,
              isPlaying:
                  state.currentTrackId == track.id && state.isPlaying,
            ),
          );
        },
      ),
    );
  }
}

class _SoundTrackRow extends StatelessWidget {
  const _SoundTrackRow({
    required this.track,
    required this.state,
  });

  final SoundContent track;
  final SoundPlayerState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 144,
      child: _SoundTrackTile(
        track: track,
        isCurrent: state.currentTrackId == track.id,
        isPlaying: state.currentTrackId == track.id && state.isPlaying,
      ),
    );
  }
}

class _SoundTrackTile extends StatelessWidget {
  const _SoundTrackTile({
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
  });

  final SoundContent track;
  final bool isCurrent;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: () => context.push(AppRoutes.soundPlayerFor(track.id)),
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReleafSoundArtwork(
            variant: _artworkForTrack(track.id),
            intensity: 0.84,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color(0x3A000000),
                  Color(0xDF000000),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ReleafSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ReleafFeatureAccents.sound.withValues(alpha: 0.10),
                    border: Border.all(
                      color: ReleafFeatureAccents.sound.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.equalizer_rounded
                        : Icons.graphic_eq_rounded,
                    color: ReleafFeatureAccents.sound,
                  ),
                ),
                const SizedBox(width: ReleafSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.cardTitle,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isCurrent
                            ? 'Current sound'
                            : '${_categoryLabel(track.category)} • Loop',
                        style: ReleafTypography.meta.copyWith(
                          color: isCurrent
                              ? ReleafFeatureAccents.sound
                              : ReleafColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
  }
}

class _InScreenMiniPlayer extends ConsumerWidget {
  const _InScreenMiniPlayer({required this.state});

  final SoundPlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref
        .watch(soundCatalogProvider)
        .getById(state.currentTrackId ?? '');
    if (track == null) return const SizedBox.shrink();

    final controller = ref.read(soundPlayerControllerProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.soundPlayerFor(track.id)),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xF2121D22),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: ReleafFeatureAccents.sound.withValues(alpha: 0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x52000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ReleafSpacing.md,
            vertical: ReleafSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: ReleafFeatureAccents.sound,
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.isPlaying ? 'Playing' : 'Paused',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: state.isPlaying ? 'Pause sound' : 'Resume sound',
                onPressed: controller.togglePlayPause,
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: ReleafColors.textPrimary,
                ),
              ),
              IconButton(
                tooltip: 'Stop sound',
                onPressed: controller.stop,
                icon: const Icon(
                  Icons.close_rounded,
                  color: ReleafColors.textSecondary,
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
  const _GlassTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafColors.textPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: ReleafFeatureAccents.sound),
            const SizedBox(width: 6),
            Text(
              label,
              style: ReleafTypography.eyebrow.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}


String _categoryLabel(SoundCategory category) {
  return switch (category) {
    SoundCategory.atmosphere => 'Ambient',
    SoundCategory.noise => 'Noise',
    SoundCategory.weather => 'Weather',
    SoundCategory.environment => 'Environment',
  };
}

ReleafSoundArtworkVariant _artworkForTrack(String id) {
  return switch (id) {
    'releaf-atmosphere-02' => ReleafSoundArtworkVariant.atmosphereTwo,
    'brown-noise' => ReleafSoundArtworkVariant.brownNoise,
    'soft-rain' => ReleafSoundArtworkVariant.softRain,
    'night-air' => ReleafSoundArtworkVariant.nightAir,
    'white-noise' => ReleafSoundArtworkVariant.whiteNoise,
    'pink-noise' => ReleafSoundArtworkVariant.pinkNoise,
    'deep-drift' => ReleafSoundArtworkVariant.deepDrift,
    _ => ReleafSoundArtworkVariant.atmosphereOne,
  };
}
