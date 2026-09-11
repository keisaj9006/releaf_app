# Meditation guidance quality — 11 September 2026

First milestone of the owner-approved [quality programme](../plans/2026-09-11-product-quality-programme.md),
implemented on `releaf-development` from `1b24990`. No external account, purchase,
deployment, narration asset or provider configuration changed.

## Change and cause

Library and Premium preview copy treated scripted practices as audio-guided even
when their recordings were absent. Such practices also opened with guidance
hidden and no caption shortcut. The library, preview and player now distinguish
recorded guidance, partial voice plus captions, captions only and unguided timers.
Missing recordings never imply that purchasing Premium supplies a voice.

Incomplete recordings default to visible captions for that session. Opening a
session does not rewrite the stored preference; an explicit caption choice does.
The approved fully recorded session retains its saved caption preference. Silent
steps in partially recorded practices no longer say to follow a voice. Unguided
timers retain their own quiet-practice copy and have no caption shortcut.

The hero grows with its content; library rails, player header/stage/dock and audio
controls accommodate 320-pixel width and 2× text. Caption controls have explicit
button/toggle semantics and at least 48 logical pixels of height. Existing art,
navigation, access, IDs, rewards, separate audio layers and the 0.82× Releaf Guide
contract are preserved.

## Files

- `lib/features/meditation/presentation/meditation_guidance_labels.dart` (new shared copy)
- `lib/features/meditation/presentation/meditation_screen.dart`
- `lib/features/meditation/presentation/meditation_player_screen.dart`
- `lib/features/meditation/application/meditation_voice_controller.dart`
- `test/meditation_premium_preview_test.dart`
- `test/primary_wellbeing_tabs_test.dart`
- `test/meditation_recorded_narration_contract_test.dart`
- This evidence, the programme plan, CURRENT_STATE, ROADMAP and canonical gate notes.

## Verification

Commands ran from the repository with Flutter 3.47.2 / Dart 3.13.2. All final
commands below exited 0. Regression tests failed before the fixes for absent
disclosure, hidden captions, overflow, misleading silent-step copy and missing
toggle semantics. Harness-only failures were resolved before the final results.

| Command | Exact result |
| --- | --- |
| `flutter pub get` | Dependency resolution succeeded; no lockfile change. |
| `dart format` on the seven changed Dart files | Formatting applied and checked. |
| `flutter test --no-pub test/meditation_premium_preview_test.dart test/primary_wellbeing_tabs_test.dart test/meditation_recorded_narration_contract_test.dart --reporter expanded` | 40/40 passed. |
| `flutter test --no-pub --reporter expanded` | 383/383 passed. |
| `flutter analyze --no-pub` | No issues found (19.8 seconds). |
| `flutter test --no-pub tool/local/meditation_visual_smoke_test.dart --reporter expanded` | 4/4 passed; local render harness, ignored and not a committed CI test. |
| `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json` | Built APK; Gradle assembleDebug 85.5 seconds. Ignored local public SDK configuration; no value printed. |
| `git diff --check` | Passed. |
| `adb devices -l` | No device attached. No installation or physical-device test claimed. |

Artifact: `build/app/outputs/flutter-apk/app-debug.apk`, **223,796,686 bytes**,
SHA-256 `59B177809EEC7D90A0F7E66919F7E049364BD7C01738A2BB538DCDA8004BF620`.
This is a debug Test Store APK, not a production release artifact.

Local Flutter-rendered images are under `build/quality/meditation-m1/`: recorded
and captioned library, large-text library and large-text player. Layout inspection
used actual catalog/widgets with fake audio drivers. It does not establish phone
audio, screen-reader navigation or TalkBack quality. Independent code review
completed with no remaining important defects after the caption/large-text fixes.

Build output warns that Flutter support for Gradle 8.14.0, AGP 8.11.1 and Kotlin
2.2.20 will soon be dropped (suggested minima: 9.1.0, 9.0.1 and 2.3.20). The build
passed without a dependency-validation bypass. Assess upgrades separately against
the existing Android release contracts; no toolchain upgrade is included here.

## Release impact and next task

Meditation remains **DONE / CONTENT**. Only `mindfulness-basics-2` has approved
recorded narration; this change neither approves nor generates other recordings.
Content approval, production signing/billing/public resources/store actions and
the final physical-device matrix remain open. Releaf is not release-ready.

Next: stop rejected breathing tones from playing in Reset while keeping silent
and reduced-motion phase guidance usable. Natural cue recording approval remains
an independent content prerequisite.
