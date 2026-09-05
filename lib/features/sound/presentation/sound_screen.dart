import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
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
                                description:
                                    'Real audio already bundled with Releaf.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              for (final track in tracks) ...[
                                _SoundTrackRow(
                                  track: track,
                                  state: state,
                                ),
                                const SizedBox(height: ReleafSpacing.sm),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const _SoundLibraryNote(),
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
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1513),
            ReleafColors.background,
            Color(0xFF060A09),
          ],
          stops: [0, 0.46, 1],
        ),
      ),
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
          onPressed: onBack,
        ),
        const SizedBox(width: ReleafSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sound',
                style: ReleafTypography.display.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(
                'A quieter layer for the moment you are in.',
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
    return Semantics(
      button: true,
      onTap: onOpen,
      label: '${track.title}. ${track.subtitle}',
      child: ReleafPressableCard(
        onPressed: onOpen,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ReleafArtwork(variant: ReleafArtworkVariant.ambient),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x08000000),
                      Color(0x33000000),
                      Color(0xE9000000),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ReleafSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _GlassTag(
                      icon: Icons.graphic_eq_rounded,
                      label: 'FEATURED SOUND',
                    ),
                    const Spacer(),
                    Text(
                      track.title,
                      style: ReleafTypography.display.copyWith(
                        fontSize: 29,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Text(
                        track.subtitle,
                        style: ReleafTypography.body.copyWith(
                          color: ReleafColors.textPrimary.withValues(alpha: 0.76),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    Row(
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
                            backgroundColor: ReleafColors.sage,
                            foregroundColor: ReleafColors.background,
                            padding: const EdgeInsets.symmetric(
                              horizontal: ReleafSpacing.lg,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: ReleafSpacing.md),
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
          ReleafArtwork(
            variant: track.id.endsWith('02')
                ? ReleafArtworkVariant.focus
                : ReleafArtworkVariant.ambient,
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
                    color: ReleafColors.sage.withValues(alpha: 0.10),
                    border: Border.all(
                      color: ReleafColors.sage.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.equalizer_rounded
                        : Icons.graphic_eq_rounded,
                    color: ReleafColors.sage,
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
                        isCurrent ? 'Current sound' : 'Ambient • Loop',
                        style: ReleafTypography.meta.copyWith(
                          color: isCurrent
                              ? ReleafColors.sage
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
        borderRadius: BorderRadius.circular(ReleafRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xF21B2722),
            borderRadius: BorderRadius.circular(ReleafRadii.lg),
            border: Border.all(color: ReleafColors.border),
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
                color: ReleafColors.sage,
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

class _SoundLibraryNote extends StatelessWidget {
  const _SoundLibraryNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.lg),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.library_music_outlined,
            color: ReleafColors.sage,
          ),
          const SizedBox(width: ReleafSpacing.md),
          Expanded(
            child: Text(
              'This first Sound library intentionally shows only audio that is '
              'already bundled with Releaf. Rain, ocean, forest, noise layers '
              'and stories will be added only with real owned or licensed audio.',
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
            Icon(icon, size: 13, color: ReleafColors.sage),
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
