# Signal Scan — 50-level progression checkpoint (2026-09-30)

Signal Scan now has playable profiles through level 50. Levels 1–12 retain their prior field size, effective difficulty, round count, symbol size, target placement and per-round scoring. The live progression cap is raised only for `signal_scan`; saved progress, completion rewards and other game caps are unchanged.

Levels 13–50 use a fixed 5×5 field sized for a narrow phone, two or three distinct matching targets per round, bounded round counts and the selected Easy/Medium/Hard symbol sets. A round advances and awards points once all targets are found. Duplicate taps cannot score twice, and changing difficulty cannot discard a partially completed round. The target counter, guidance and accessibility labels describe the active field. Higher levels vary target count and round length without shrinking tap targets indefinitely.

Verification on the frozen batch:

- `flutter test --no-pub --reporter expanded test/signal_scan_level_profile_test.dart test/spatial_span_level_profile_test.dart test/brain_flow_test.dart test/brain_level_contract_test.dart`: 77/77 passed.
- `flutter analyze --no-pub`: no issues found.
- `flutter test --no-pub --reporter expanded`: 707/707 passed.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`: succeeded; generated `build/app/outputs/flutter-apk/app-debug.apk`. The ignored local configuration was not displayed or committed.
- `git diff --check`: passed.

Physical device playability, including long sessions at higher levels, remains unverified. This build was not installed on the phone for this checkpoint. Brain core remains IN PROGRESS while nine other registered games remain capped at level 12 and final device QA remains open.
