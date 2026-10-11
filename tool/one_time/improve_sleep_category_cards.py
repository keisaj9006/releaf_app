from pathlib import Path

path = Path('lib/features/sleep/presentation/sleep_screen.dart')
text = path.read_text(encoding='utf-8')

old_artwork = """                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: ReliefEditorialImage(
                                  asset: switch (category) {
                                    SleepCategory.stories =>
                                      ReliefEditorialAsset.sleepStories,
                                    SleepCategory.nature =>
                                      ReliefEditorialAsset.soundscapes,
                                    SleepCategory.meditations =>
                                      ReliefEditorialAsset.meditate,
                                    SleepCategory.sleepMusic =>
                                      ReliefEditorialAsset.sleep,
                                  },
                                  fallback: const ReleafSleepArtwork(
                                    variant: ReleafSleepArtworkVariant.night,
                                  ),
                                ),
                              ),
"""
new_artwork = """                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ReliefEditorialImage(
                                      asset: switch (category) {
                                        SleepCategory.stories =>
                                          ReliefEditorialAsset.sleepStories,
                                        SleepCategory.nature =>
                                          ReliefEditorialAsset.soundscapes,
                                        SleepCategory.meditations =>
                                          ReliefEditorialAsset.meditate,
                                        SleepCategory.sleepMusic =>
                                          ReliefEditorialAsset.sleep,
                                      },
                                      fallback: const ReleafSleepArtwork(
                                        variant:
                                            ReleafSleepArtworkVariant.night,
                                      ),
                                    ),
                                    Positioned(
                                      left: ReleafSpacing.xs,
                                      bottom: ReleafSpacing.xs,
                                      child: _CategoryIcon(category: category),
                                    ),
                                  ],
                                ),
                              ),
"""
if text.count(old_artwork) != 1:
    raise SystemExit(
        f'Expected one category artwork block, found {text.count(old_artwork)}.'
    )
text = text.replace(old_artwork, new_artwork, 1)

old_row = """                            Row(
                              children: [
                                _CategoryIcon(category: category),
                                const SizedBox(width: ReleafSpacing.sm),
                                Expanded(
                                  child: Text(
                                    category.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: ReleafTypography.cardTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
"""
new_row = """                            Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      category.label,
                                      maxLines: 1,
                                      style:
                                          ReleafTypography.cardTitle.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: ReleafSpacing.xs),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
"""
if text.count(old_row) != 1:
    raise SystemExit(f'Expected one category label row, found {text.count(old_row)}.')
text = text.replace(old_row, new_row, 1)
path.write_text(text, encoding='utf-8')
