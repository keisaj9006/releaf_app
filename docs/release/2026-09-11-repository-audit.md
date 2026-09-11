# Releaf repository audit — 11 September 2026

This is evidence for the canonical `releaf_1_0_release_gate.md`, not a replacement gate or a release-readiness declaration.

## Repository and scope

- Root: `C:/Users/joann/Releaf-Codex`.
- Branch: `releaf-development`; `main` was not modified.
- Initial HEAD: `7a422a753f2a048ed254aa1db008fcb2c30d0cbb`.
- Initial working tree: 14 staged context-pack additions, preserved. During the audit these were committed as `b949ab3fff6bcc460c376b682430d499e3c3682a`; this commit changes documentation only.
- SDK matches CI: Flutter 3.47.2 stable / Dart 3.13.2.
- Version remains `0.1.0+1`. No production signing configuration was created, no production-signed artifact was built, and no backend data was changed. The release smoke run used only the existing CI-style temporary test key.

## Architecture findings

The active app uses Riverpod providers and GoRouter, with existing feature modules for Reset, Brain, Meditation, Sound/Sleep and account/legal flows. The persistent shell remains Home / Reset / Brain / Sound. Meditation and Sleep have separate routes. No navigation or architectural migration is warranted by this audit.

The canonical Brain registry contains 15 games, with the existing host/result/progression flow. Tests cover all enabled games, L1–L12 training progression, Memory lifecycle and Labyrinth's separate 50-stage progression. Hardware accelerometer quality still requires the device matrix; automated progression tests do not prove physical-device playability.

Emergency access is checked before subscription entitlement, and its existing history/sync exclusion contracts remain covered. Progress synchronization primitives are not enabled as runtime cloud backup. Local progress remains the 1.0 truth.

Recorded Releaf Guide playback and independent ambience controls remain in place. The production pace is 0.82×, and the exact provider voice ID remains null. Missing narration stays silent. The Sleep route continues to use sound playback without narration.

## Verification evidence

| Check | Result |
| --- | --- |
| `flutter pub get` | PASS; lockfile unchanged. Required SDK/cache access outside the workspace. |
| `flutter analyze` | PASS; no issues, 160.5 seconds. |
| `flutter test --no-pub --reporter expanded` | PASS; 333 tests, 0 failures, 4m37s test-reporter duration. Includes existing policy/release contracts and all three manifest exports. |
| Formatter check on the three files in `7a422a7` | Initially failed for all 3; formatting applied; repeat check PASS, 3 files / 0 changes. |
| Focused Reset guidance and lifecycle tests after formatting | PASS; 9 tests, 0 failures. |
| Formatter equivalence against HEAD | PASS; all 3 changed Dart files exactly match freshly formatted HEAD source, with line endings normalized. No application behavior edits. |
| Release/deletion documentation contracts after documentation updates | PASS; 12 tests, 0 failures. |
| `flutter build web --release --no-pub` | PASS; `build/web` produced, compiler reported 481.3 seconds. |
| Built web deletion-resource checks from CI | PASS; non-empty index, JS bundle and deletion page, account link and browser-use copy present, no service-role identifier in deletion HTML. |
| Final `flutter analyze --no-pub` | PASS; no issues, 75.3 seconds, after formatter/generated changes. |
| `flutter build apk --debug --no-pub` | PASS; generated `build/app/outputs/flutter-apk/app-debug.apk` (198,635,273 bytes); Gradle reported 533.3 seconds. |
| Android configuration checks from CI | PASS; API 36 compile/target, NDK 28.2.13676358, Billing permission, singleTop launch and no debug release-signing fallback. |
| CI-equivalent temporary-key release AAB | PASS; 93,327,757 bytes (Flutter reports 89.0 MB), Gradle 513.4 seconds. This uses the documented CI test-key identity, not the private production upload key. |
| CI-equivalent release APK / 16 KB checks | PASS; release APK built, `zipalign -c -P 16 -v 4` passed, all 9 native libraries have ELF LOAD alignment at least 2**14. Entire smoke script exited 0. |
| Full FFmpeg MP3 decode audit | PASS; 16/16 files: 10 sound tracks, 2 breath cues and 4 narration clips. Every looping sound meets the CI minimum of 60 seconds. Detailed duration/sample-rate/peak metadata: `build/qa-manifests/audio-audit.json`. |
| `git diff --exit-code -- pubspec.lock` | PASS; dependency resolution did not change the lockfile. |
| `git check-ignore android/key.properties` | PASS; private signing properties remain ignored. |
| Live Supabase security advisor | PASS; 0 lints. This is an advisory result, not an end-to-end authorization test. |

Detailed local output is in ignored `baseline-*.log` files. The local smoke script is `build/smoke_release.ps1`, adapting the existing CI steps to Windows; audio inspection uses `build/audit_audio.py` with a temporary FFmpeg package under `build/audio-qa-deps`. No prior CI success is substituted for this local run. Android build warnings identify future Gradle/AGP/Kotlin support work and older SDK XML tooling; builds completed without bypassing dependency validation. Temporary smoke signing files were removed by the script's cleanup path. Smoke artifacts lack production signing, billing and legal configuration and must not be uploaded to Play.

## Changes in this batch

- Formatter-only changes to `lib/features/relief/presentation/breathing_widget.dart`, `lib/theme/widgets/releaf_movement_demo_visual.dart` and `test/reset_guidance_quality_test.dart`.
- Flutter-generated platform exclusions in `analysis_options.yaml`, compatibility flags in `android/gradle.properties`, and refreshed Linux/macOS/Windows plugin registrations for already-resolved dependencies. These are generated updates, not new dependency choices or proof of desktop builds.
- Current-state documentation updated for the context commit, automated baseline and live deployment evidence.
- `android/.gitignore` now excludes the Kotlin compiler session cache created by the Android build.

Complete tracked-file inventory for this batch (changes left uncommitted):

```text
analysis_options.yaml
android/.gitignore
android/gradle.properties
docs/CURRENT_STATE.md
docs/plans/2026-09-11-releaf-1.0-completion-plan.md
docs/release/releaf_1_0_release_gate.md
docs/release/2026-09-11-repository-audit.md (new)
lib/features/relief/presentation/breathing_widget.dart
lib/theme/widgets/releaf_movement_demo_visual.dart
test/reset_guidance_quality_test.dart
linux/flutter/generated_plugin_registrant.cc
linux/flutter/generated_plugins.cmake
macos/Flutter/GeneratedPluginRegistrant.swift
windows/flutter/generated_plugin_registrant.cc
windows/flutter/generated_plugins.cmake
```

Temporary signing cleanup was verified: neither `android/key.properties` nor `android/ci-upload-keystore.jks` remains. `git diff --check` passed. No commit or push was performed by the agent.

## Live account-deletion gap

Read-only inspection of project `mgajdbdzflspypxhgmaw` found `delete-account` ACTIVE at version 1 with `verify_jwt: true`. Its deployed source calls Supabase user deletion but contains no RevenueCat erasure call. The repository source already authenticates the caller, requires the server-only erasure secret, erases RevenueCat first and fails closed before Supabase deletion if that step fails.

Next priority is the existing Account deletion gate: configure the real server-only `REVENUECAT_SECRET_API_KEY`, deploy the reviewed repository function, and verify both providers with a disposable identified account. Do not deploy the hardened function without first arranging its required secret; that would leave authenticated deletion returning its deliberate configuration error. No secret value was requested, read or written during this audit.

Required closure evidence:

1. Deployed source/version matches `supabase/functions/delete-account/index.ts`, including RevenueCat erasure before Supabase deletion.
2. The real erasure credential is configured only in the Edge environment; no client or repository secret fallback exists.
3. A disposable signed-in account with an identified RevenueCat customer is deleted through the app; both provider records are absent afterward and the app returns to a signed-out state.
4. A provider-erasure failure leaves the Supabase identity intact; a retry after a partial deletion remains safe. Use a controlled test environment for injected failures.
5. The same authenticated flow works through the deployed public browser resource, and evidence is entered in DQA-18 and the related device/public-deletion rows.

The existing Flutter deletion test checks source ordering and the client tests exercise application behavior; they do not execute the deployed Edge function against real providers.

## Content inventory

Fresh `build/qa-manifests/releaf-guide-manifest.json` output contains 20 guided meditations, 103 steps, 4 recorded paths and 99 steps still to render. `mindfulness-basics-2` is the only fully recorded session. The remaining sessions are:

| Session ID | Steps requiring recording |
| --- | ---: |
| breath-and-body-4 | 4 |
| working-with-thoughts-5 | 5 |
| open-awareness-6 | 6 |
| anxious-thoughts-5 | 5 |
| before-a-difficult-moment-4 | 4 |
| focus-anchor-5 | 5 |
| after-distraction-6 | 6 |
| body-scan-5 | 5 |
| soften-tension-4 | 4 |
| self-kindness-5 | 5 |
| morning-arrival-4 | 4 |
| work-break-3 | 3 |
| steady-attention-10 | 6 |
| sitting-with-uncertainty-8 | 6 |
| whole-body-scan-10 | 7 |
| open-field-10 | 6 |
| let-the-day-go-6 | 6 |
| body-into-stillness-8 | 6 |
| quiet-night-10 | 6 |

This table is a snapshot of the generated manifest, not a second script source. Use the exporter for production scripts and target paths. Missing provider identity blocks new production rendering; recover the approved reference's exact voice or obtain deliberate replacement approval after auditioning.

The Reset manifest covers 50 sessions, 10 breathing methods and 247 steps; 0 steps have recorded narration and 217 require rendering. Paced breathing uses shared non-verbal inhale/exhale cues, with silent hold/rest phases. Those phases do not require spoken recordings.

The canonical Sound catalog still has 10 bundled tracks. Decode/metadata checks cannot establish owner approval, licensing, seamless listening quality or physical-device background behavior. Final selection and listening/device QA remain required.

All ten sound tracks decode at 44.1 kHz and run 120–231 seconds. The four narration clips decode at 24 kHz, last 16.08–17.16 seconds and fit their respective 30-second steps. No files were remastered or substituted.

Asset-QA finding: `assets/sounds/relief_02.mp3` (Releaf Atmosphere II) reaches 0.0 dB sample peak. A follow-up FFmpeg `ebur128=peak=true` scan reports **+0.8 dB true peak and -9.0 LUFS integrated loudness**. This needs headroom/level review during final sound mastering and selection; the decode PASS must not be interpreted as clipping-free or loudness-matched approval. Compare it with the quieter generated sounds before accepting the final content set. The source asset remains unchanged.

## Gate impact and remaining work

No gate is closed by this batch. Account deletion's existing deployment dependency is now confirmed against live source. Supabase's MONITOR status has fresh clean advisory evidence. Baseline, Reset guidance, web build and policy contract evidence are refreshed.

Remaining release dependencies are the erasure secret/deployment and end-to-end test; real RevenueCat/Play configuration and Play-distributed purchase/restore; private production signing; controller/contact/retention/legal details and stable public URLs; approved recordings and final sound selection; final store assets and declarations; RC versioning; physical-device QA; and the account-specific Play closed-testing process. Preserve the existing release gate and device matrix for these closure records.

Research navigation, mixer, pricing, Leaves and expanded content-count proposals remain scope decisions, not authorization for a late rewrite.
