# Reset cue eligibility and readable audio settings

Second milestone of the owner-approved [quality programme](../plans/2026-09-11-product-quality-programme.md),
implemented on `releaf-development` from `03f65af`.

## Defect and fix

The production manifest marked the two bundled artificial breathing tones
rejected, but runtime phase resolution still passed their paths to the player.
Regression tests reproduced actual driver calls for both rejected assets.

A shared production-approval guard now keeps paced-breathing audio silent. The
manifest exposes `runtimeEligible` and `runtimeAssetPath` from the same resolver.
Existing assets and target paths remain intact for the content pipeline. File
presence and successful decoding do not count as approval. Hold/rest always have
no audio target. Approved natural inhale/exhale recordings remain a content gate.

Preview and active settings explain that breathing audio is unavailable, disable
the cue switch and hide its volume control. They preserve stored voice settings
for other sessions. The master sound indicator uses effective cue availability
plus independent ambience. Reduced-motion breathing still advances its visible
and semantic inhale/exhale instructions.

Visual inspection also exposed dark inherited text on the dark audio sheet.
The sheet now uses the existing dark theme, explicit cue text styles and existing
button typography. A regression assertion measures the rendered cue description
against the sheet background and requires at least 4.5:1 contrast.

Guided narration, routes, access, IDs, rewards and Emergency privacy/exclusion
remain unchanged. No audio asset, account or external provider was changed.

## Files

- `lib/features/relief/domain/reset_voice_guidance.dart`
- `lib/features/relief/application/reset_voice_playback.dart` (contract comment)
- `lib/features/relief/presentation/breathing_widget.dart`
- `lib/features/relief/presentation/reset_session_preview_sheet.dart`
- `tooling/reset/export_narration_manifest.dart`
- `test/reset_session_engine_test.dart`
- `test/reset_voice_playback_test.dart`
- `test/reset_narration_manifest_export_test.dart`
- `test/reset_breathing_cue_availability_test.dart` (new)
- This evidence, programme plan, CURRENT_STATE, ROADMAP, production guide and gate notes.

## Verification

Initial regression run failed for rejected runtime paths, driver playback,
missing manifest eligibility and misleading preview controls. The widget harness
was corrected to match merged semantic labels. A later contrast assertion failed
before the sheet theme fix. No product assertions were weakened.

| Command | Result |
| --- | --- |
| `flutter test --no-pub test/reset_session_engine_test.dart test/reset_voice_playback_test.dart test/reset_narration_manifest_export_test.dart test/reset_breathing_cue_availability_test.dart test/reset_hub_test.dart test/reset_lifecycle_test.dart test/reset_guidance_quality_test.dart test/reset_audio_preferences_test.dart test/relief_access_test.dart --reporter expanded` | 69/69 passed. |
| `flutter test --no-pub test/reset_breathing_cue_availability_test.dart test/reset_hub_test.dart test/relief_access_test.dart --reporter expanded` | 40/40 passed after the contrast fix. |
| `dart format --output=none --set-exit-if-changed` on the nine changed Dart files | 9 files, 0 changes; exit 0. |
| `flutter test --no-pub tool/local/reset_visual_smoke_test.dart --reporter expanded` | 2/2 passed after supplying native channel fakes in the ignored local renderer. |
| `flutter analyze --no-pub` | No issues found; final run 25.0 seconds, exit 0. |
| `flutter test --no-pub --reporter expanded` | 386/386 passed after the final theme/contrast change; exit 0. |
| `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json` | Built successfully after the final theme fix; assembleDebug 131.0 seconds, exit 0. |
| `git diff --check` | Passed. |
| `adb devices -l` | No device attached; no installation or physical-device verification. |

APK: `build/app/outputs/flutter-apk/app-debug.apk`, **223,797,621 bytes**.
SHA-256: `C00E66EC6A99AC99393BB973027AD7926E05542147E5CED3F503C1153176D3A3`.

The ignored configuration was reused without printing or committing its value.
The debug Test Store APK is not a production release artifact. Build-time
dependency resolution succeeded; no lockfile change. Existing Gradle/AGP/Kotlin
future-support warnings remain a separate toolchain task; no bypass used.

Local images under `build/quality/reset-m2/` show the preview and audio settings.
They use Flutter test rendering and fake native channels. They establish layout
and visible copy only, not audible content or Samsung/TalkBack behaviour.
Independent reviews found no remaining important defects in the cue guard or
final theme change.

## Release impact and continuation

RESET remains **DONE / CONTENT**; Emergency privacy/access remains **DONE**.
Rejected cues are excluded from playback, but no replacement recording has been
approved. Production signing, billing, legal/public resources, store actions and
the production-equivalent physical-device matrix remain open. Not release-ready.

Next internal defect: Sound track starts can complete out of order and replace
a newer selection. Add delayed-driver regression tests and preserve the existing
Sleep timer safeguards, independent audio layers and narration-free experience.
