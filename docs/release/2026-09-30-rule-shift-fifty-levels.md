# Rule Shift — 50-level progression checkpoint (2026-09-30)

Rule Shift now has playable profiles through level 50. Levels 1–12 retain their exact trial counts, rule counts, switch cadence, trial-value sequence and difficulty adjustment. The live cap rises only for `rule_shift`. Saved levels, session completion, scoring (100 per correct answer) and Leaves semantics are unchanged.

Levels 13–50 use bounded 23–30-trial sessions. The rule set grows from four to six, adding prime-number and less-than-four decisions at later bands while switching each trial. The level-13 session does not drop below the level-12 trial count. Easy/Medium/Hard adjust the practice profile while the displayed saved level remains unchanged; high-level sessions remain readable on a 320 dp screen with 200% text scaling.

Verification on the frozen batch:

- `flutter test --no-pub --reporter expanded test/rule_shift_level_profile_test.dart test/legacy_brain_difficulty_test.dart test/brain_flow_test.dart test/brain_level_contract_test.dart test/n_back_level_profile_test.dart test/signal_scan_level_profile_test.dart test/memory_level_profiles_test.dart`: 93/93 passed.
- `flutter analyze --no-pub`: no issues found.
- `flutter test --no-pub --reporter expanded`: 714/714 passed.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`: succeeded; `build/app/outputs/flutter-apk/app-debug.apk`, 224,028,461 bytes, SHA-256 `6674A260AC8B9CC0E00FFFDBAA2B522A2E30567F6D10DC5007A7174608A18056`. The local Dart-define file is ignored and its contents were not displayed or committed. The build printed a non-failing warning that Kotlin 2.2.20 support will be dropped in a future Flutter release.
- `git diff --check`: passed.

No phone installation or physical Rule Shift playability review was performed in this checkpoint. Brain core remains IN PROGRESS: eight other registered games are still capped at level 12, cross-game level-50 replay and final device QA remain open.
