# Release size budget checkpoint — 24 September 2026

Scope: fail-closed Android release artifact and bundled runtime-asset growth
checks. This checkpoint changes release tooling only; it does not change Flutter
runtime behavior, content, billing, signing material or production configuration.

## Measured baseline and limits

The locally retained release AAB measured **93,375,235 bytes**. The current
`assets/` tree measured **56,348,319 bytes** across 138 files. These measurements
define the documented baseline; the retained AAB is not claimed to be the final
production-signed artifact or the latest production-equivalent RC.

`tool/release/release_size_budget_policy.dart` now enforces:

- release AAB: at most **105,000,000 bytes**;
- bundled runtime assets: at most **63,000,000 bytes**.

Both limits leave roughly twelve percent above the measured baseline. A future
approved content intake may deliberately revise a limit, but must do so as a
reviewable policy change rather than allowing unnoticed artifact growth.

The policy runs after the AAB build in both the local production release script
and the manual signed-AAB GitHub Actions workflow. It reports byte counts only
and never reads or prints signing or RevenueCat secrets.

## Verification

- `flutter test test/release_size_budget_policy_test.dart test/production_android_release_workflow_contract_test.dart --no-pub --reporter expanded`
  — **5/5 passed**.
- `dart run tool/release/release_size_budget_policy.dart --aab build/app/outputs/bundle/release/app-release.aab --assets assets`
  — **PASS**, AAB `93,375,235 / 105,000,000`, assets
  `56,348,319 / 63,000,000` bytes.
- `flutter analyze --no-pub` — **no issues found**.
- `flutter test --no-pub --reporter expanded` — **640/640 passed**.
- `git diff --check` — **PASS**.

No APK rebuild or device installation is required for this tooling-only change.
The exact production-signed AAB, Play-distributed download behavior and physical
performance matrix remain separate release gates.
