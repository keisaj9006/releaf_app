# Meditation production manifest — 12 September 2026

Branch `releaf-development`, parent `389c138`. Tooling/documentation only; no
runtime, script, timing, access, reward, narrator or audio asset changes.

## Changes and evidence

The existing exporter now supplies contiguous programmed start/end seconds for
every guided step, subtitle/series metadata and recording availability. It rejects
duplicate IDs, empty/invalid steps, non-positive durations, inconsistent total
durations, missing/empty declared recording sources and unknown/missing ambience.
Canonical recording path checks and the exact-voice render block remain intact.

The new [session matrix](../product/meditation-session-matrix.md) covers all 22
catalog entries: 20 guided sessions with 103 steps (4 recorded, 99 pending), plus
two unguided timers. It explicitly distinguishes programmed intervals from measured
speech/captions, file availability from owner approval, and current implementation
from production acceptance.

Independent review identified that source-file existence does not prove Flutter
bundle inclusion. The regression suite now reads the actual Flutter AssetManifest
and checks every exported recording and ambience. This protects against forgetting
a new non-recursive asset-directory declaration. The exporter checks source files;
the integration test separately checks bundle inclusion. No claim is made that
these checks establish decoding quality, provenance, licensing or voice approval.

## Verification

- RED: missing timeline fields reproduced; six malformed-catalog tests separately
  reproduced absent validation before the guards were added.
- `flutter test --no-pub test/meditation_narration_manifest_export_test.dart
  test/meditation_recorded_narration_contract_test.dart`: initially **11 passed**;
  final **13 passed** after actual-bundle and complete/partial/captions-only tests.
- `flutter test --no-pub`: **489 passed**, exit 0, before the final two additional
  test-only cases. Both additional cases passed in the final focused run.
- `dart format` on changed Dart files: completed.
- Final `flutter analyze`: **No issues found**, exit 0, including the final
  test-only additions.
- `flutter build apk --debug
  --dart-define-from-file=tool/local/revenuecat-test-store.json`: PASS, exit 0.
  Existing ignored configuration; no values printed. Existing Kotlin future-support
  warning remains. Runtime code/assets are unchanged; no repeated installation.

## Remaining work

The current catalogue still requires per-session production listening, approved
narrator recordings, provenance/licence evidence, measured audio and unique visual
acceptance. The exact approved voice is unavailable; do not replace it or label
unrecorded sessions complete. No owner/hardware gate closes here.

Next verified gap: both unguided timers start the configured ambience through the
ordinary player path. Implement silence by default with explicit optional ambience,
without overwriting a user's stored guided-session preference on entry.
