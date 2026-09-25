import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sleep/data/sleep_content_manifest.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content_manifest.dart';

void main() {
  const valid = SleepManifestEntry(
    id: 'sleep-test',
    title: 'A Quiet Night',
    description: 'A gentle sound for winding down.',
    category: SleepCategory.nature,
    audioAsset: 'assets/sounds/quiet-night.mp3',
    artworkAsset: 'assets/art/sleep/quiet-night.webp',
    duration: Duration(minutes: 12),
    accessTier: SleepAccessTier.free,
    source: SleepPlaybackSource.sound('quiet-night'),
    creatorSource: 'Releaf original recording',
    licenceRecord: 'docs/rights/quiet-night.md',
    approval: SleepApprovalState.approved,
    rights: SleepRightsState.cleared,
    releaseNotes: 'Approved local master.',
  );
  const existingAssets = <String>{
    'assets/sounds/quiet-night.mp3',
    'assets/art/sleep/quiet-night.webp',
  };

  SleepManifestValidation validate(List<SleepManifestEntry> entries) =>
      SleepContentManifest.validate(
        entries: entries,
        assetExists: existingAssets.contains,
        sourceExists: (source) =>
            source.type == SleepPlaybackSourceType.sound &&
            source.reference == 'quiet-night',
      );

  test(
    'only complete cleared and approved local material is runtime ready',
    () {
      final result = validate([valid]);

      expect(result.errors, isEmpty);
      expect(result.runtimeReadyIds, {'sleep-test'});
    },
  );

  test('missing audio blocks an approved item and names the defect', () {
    final result = validate([
      valid.copyWith(audioAsset: 'assets/sounds/missing.mp3'),
    ]);

    expect(result.errors, contains('sleep-test: audio asset is missing'));
    expect(result.runtimeReadyIds, isEmpty);
    expect(result.releaseErrors, isNotEmpty);
  });

  test('duplicate IDs cannot shadow a valid entry', () {
    final result = validate([valid, valid]);

    expect(result.errors, contains('sleep-test: duplicate content ID'));
    expect(result.runtimeReadyIds, isEmpty);
    expect(result.releaseErrors, isNotEmpty);
  });

  test('undecided access, rights or approval cannot be promoted', () {
    final entries = [
      valid.copyWith(
        id: 'access-pending',
        accessTier: SleepAccessTier.undecided,
      ),
      valid.copyWith(id: 'rights-pending', rights: SleepRightsState.pending),
      valid.copyWith(
        id: 'review-pending',
        approval: SleepApprovalState.pending,
      ),
    ];
    final result = validate(entries);

    expect(result.runtimeReadyIds, isEmpty);
    expect(result.errors, contains('access-pending: access tier is undecided'));
    expect(result.errors, contains('rights-pending: rights are not cleared'));
    expect(result.errors, contains('review-pending: content is not approved'));
  });

  test('unknown player source blocks an otherwise complete entry', () {
    final result = validate([
      valid.copyWith(source: const SleepPlaybackSource.sound('unknown')),
    ]);

    expect(result.errors, contains('sleep-test: player source is unknown'));
    expect(result.runtimeReadyIds, isEmpty);
  });

  test('narrated category requires approved narrator provenance', () {
    final result = validate([
      valid.copyWith(
        category: SleepCategory.stories,
        source: const SleepPlaybackSource.story('quiet-night'),
        narratorProvenance: '',
      ),
    ]);

    expect(
      result.errors,
      contains('sleep-test: narrator provenance is missing'),
    );
    expect(result.runtimeReadyIds, isEmpty);
  });

  test(
    'current asset-pending Story stays a candidate, not a release claim',
    () {
      final entry = SleepContentManifest.candidates.singleWhere(
        (item) => item.id == 'ST-DC-004',
      );

      expect(entry.approval, SleepApprovalState.pending);
      expect(entry.rights, SleepRightsState.pending);
      expect(entry.accessTier, SleepAccessTier.undecided);
    },
  );
}
