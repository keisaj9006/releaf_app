import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/release/release_size_budget_policy.dart' as policy;

void main() {
  test('measured release artifact and asset tree fit the frozen budgets', () {
    final result = policy.auditReleaseSizeBudget(
      appBundleBytes: 93375235,
      releaseAssetTreeBytes: 56348319,
    );

    expect(result.isReady, isTrue, reason: result.errors.join('\n'));
    expect(result.appBundleHeadroomBytes, greaterThan(0));
    expect(result.releaseAssetTreeHeadroomBytes, greaterThan(0));
  });

  test('oversized app bundle fails with measured byte evidence', () {
    final result = policy.auditReleaseSizeBudget(
      appBundleBytes: policy.maxAppBundleBytes + 1,
      releaseAssetTreeBytes: 1,
    );

    expect(result.isReady, isFalse);
    expect(result.errors.single, contains('${policy.maxAppBundleBytes + 1}'));
    expect(result.errors.single, contains('${policy.maxAppBundleBytes}'));
  });

  test('oversized release asset tree fails independently of app bundle', () {
    final result = policy.auditReleaseSizeBudget(
      appBundleBytes: 1,
      releaseAssetTreeBytes: policy.maxReleaseAssetTreeBytes + 1,
    );

    expect(result.isReady, isFalse);
    expect(result.errors.single, contains('Release asset tree'));
  });

  test('production release paths enforce the size budget after building', () {
    final workflow = File(
      '.github/workflows/android_production_release.yml',
    ).readAsStringSync();
    final localScript = File('tool/build_play_release.ps1').readAsStringSync();

    for (final source in <String>[workflow, localScript]) {
      expect(source, contains('release_size_budget_policy.dart'));
      expect(source, contains('app-release.aab'));
    }
  });
}
