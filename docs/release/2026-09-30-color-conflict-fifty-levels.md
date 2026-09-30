# Color Conflict — 50-level progression checkpoint (2026-09-30)

Color Conflict now has playable profiles through level 50. Levels 1–12 retain their prior color count by round and difficulty, round count, session clock, trial generation and score multiplier. Only the `color_conflict` live progression cap rises; saved progress, completion and Leaves semantics are unchanged.

Levels 13–50 use five choices, bounded 14–25-round sessions and 18–40-second clocks depending on selected difficulty and level. Controlled congruent trials are mixed with conflicting word/ink trials; their cadence varies by challenge band. The player still answers the ink color. The new profile is tested across all levels and difficulties, by full level-13 completion, and on a 320 dp display at 200% text scaling.

Verification on the frozen batch:

- `flutter test --no-pub --reporter expanded test/color_conflict_level_profile_test.dart test/brain_flow_test.dart test/brain_level_contract_test.dart test/legacy_brain_difficulty_test.dart test/n_back_level_profile_test.dart test/signal_scan_level_profile_test.dart test/spatial_span_level_profile_test.dart`: 90/90 passed.
- `flutter analyze --no-pub`: no issues found.
- `flutter test --no-pub --reporter expanded`: 719/719 passed.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`: succeeded; `build/app/outputs/flutter-apk/app-debug.apk`, 224,031,674 bytes, SHA-256 `11C118AD59F5D6077B12406376310F50746D2507FF9E7676F8E6F9DDE3F659C9`. The ignored local Dart-define contents were not displayed or committed. The build printed a non-failing warning that Kotlin 2.2.20 support will be dropped in a future Flutter release.
- `git diff --check`: passed.

No device installation or physical Color Conflict review was performed. Brain core remains IN PROGRESS: seven other registered games are still capped at level 12, cross-game level-50 replay and final device QA remain open.
