import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content_manifest.dart';

import '../tool/release/sleep_content_manifest_policy.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory('build').createTempSync('sleep-policy-');
    File('${root.path}/assets/sounds/quiet.mp3')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);
    File('${root.path}/assets/art/quiet.webp')
      ..createSync(recursive: true)
      ..writeAsBytesSync([4, 5]);
  });

  tearDown(() => root.deleteSync(recursive: true));

  const ready = SleepManifestEntry(
    id: 'soft-rain',
    title: 'Quiet',
    description: 'A sound for winding down.',
    category: SleepCategory.nature,
    audioAsset: 'assets/sounds/quiet.mp3',
    artworkAsset: 'assets/art/quiet.webp',
    duration: Duration(minutes: 10),
    accessTier: SleepAccessTier.free,
    source: SleepPlaybackSource.sound('soft-rain'),
    creatorSource: 'Releaf original',
    licenceRecord: 'Owner production record 2026-09-24',
    approval: SleepApprovalState.approved,
    rights: SleepRightsState.cleared,
    releaseNotes: 'Approved local asset.',
  );

  test('valid local material reports measured bytes and can be promoted', () {
    final result = auditSleepContentManifest(
      root: root,
      entries: [ready],
      promotedIds: {'soft-rain'},
    );

    expect(result.releaseErrors, isEmpty);
    expect(result.runtimeReadyIds, {'soft-rain'});
    expect(result.candidateBytes, 5);
    expect(result.promotedBytes, 5);
  });

  test('pending material is reported but cannot be promoted', () {
    final pending = ready.copyWith(approval: SleepApprovalState.pending);
    final review = auditSleepContentManifest(root: root, entries: [pending]);
    final promoted = auditSleepContentManifest(
      root: root,
      entries: [pending],
      promotedIds: {'soft-rain'},
    );

    expect(
      review.candidateIssues,
      contains('soft-rain: content is not approved'),
    );
    expect(review.releaseErrors, isEmpty);
    expect(
      promoted.releaseErrors,
      contains('soft-rain: promoted item is not ready'),
    );
  });

  test('missing or unsupported approved media blocks promotion', () {
    final missing = auditSleepContentManifest(
      root: root,
      entries: [ready.copyWith(audioAsset: 'assets/sounds/missing.mp3')],
      promotedIds: {'soft-rain'},
    );
    final unsupported = auditSleepContentManifest(
      root: root,
      entries: [ready.copyWith(audioAsset: 'assets/sounds/quiet.exe')],
      promotedIds: {'soft-rain'},
    );

    expect(
      missing.releaseErrors,
      contains('soft-rain: audio asset is missing'),
    );
    expect(
      unsupported.releaseErrors,
      contains('soft-rain: audio format is unsupported'),
    );
  });

  test('duplicate ID or unknown source fails instead of shadowing content', () {
    final duplicate = auditSleepContentManifest(
      root: root,
      entries: [ready, ready],
      promotedIds: {'soft-rain'},
    );
    final unknown = auditSleepContentManifest(
      root: root,
      entries: [
        ready.copyWith(source: const SleepPlaybackSource.sound('unknown')),
      ],
      promotedIds: {'soft-rain'},
    );

    expect(
      duplicate.releaseErrors,
      contains('soft-rain: duplicate content ID'),
    );
    expect(
      unknown.releaseErrors,
      contains('soft-rain: player source is unknown'),
    );
  });

  test('relative path escape is rejected even if the target exists', () {
    final result = auditSleepContentManifest(
      root: root,
      entries: [ready.copyWith(audioAsset: '../outside.mp3')],
      promotedIds: {'soft-rain'},
    );

    expect(
      result.releaseErrors,
      contains('soft-rain: audio asset path is unsafe'),
    );
  });

  test('a promoted ID absent from the manifest fails closed', () {
    final result = auditSleepContentManifest(
      root: root,
      entries: const [],
      promotedIds: {'unknown'},
    );

    expect(result.releaseErrors, contains('unknown: promoted item is absent'));
  });

  test('approval cannot change the canonical player access tier', () {
    final result = auditSleepContentManifest(
      root: root,
      entries: [ready.copyWith(accessTier: SleepAccessTier.premium)],
      promotedIds: {'soft-rain'},
    );

    expect(
      result.releaseErrors,
      contains('soft-rain: access tier conflicts with player source'),
    );
  });

  test('a candidate ID must resolve to the same registered Sleep source', () {
    final result = auditSleepContentManifest(
      root: root,
      entries: [ready.copyWith(id: 'different-id')],
      promotedIds: {'different-id'},
    );

    expect(
      result.releaseErrors,
      contains('different-id: content ID is not registered in Sleep'),
    );
  });
}
