# Releaf device-review checkpoint — 12 September 2026

Status: automated verification, APK build, non-destructive install and the
bounded Samsung UI smoke below passed. Owner visual/listening review remains.
Feature development is paused by the owner.
Work remains in `C:\Users\joann\Releaf-Codex` on `releaf-development`.
Starting HEAD: `9fdf3df3e96b2f623a5de641b2f8f2ddcc4869d3`.

## Review scope

The cumulative batch starts at `1b24990` and includes the committed Meditation
guidance (`03f65af`), rejected Reset cue exclusion (`cb64fcd`), Sound transport
ordering (`9fdf3df`), and the pending Sound loading/recovery fixes. The working
tree initially had four changed/untracked files; this is not a new 33-file audit.
No architecture replacement or further Brain/progression feature is included.

Independent review covered all 16 Meditation/Reset production/test/exporter files
and all five pending Sound production/test files. Root review covers Sound,
context and evidence documentation. No unrelated/generated/signing/credential
paths or credential-shaped added values were found. The existing local
`tool/local/revenuecat-test-store.json` is ignored and untracked; no key values
were printed or changed. No dependency constraint, lockfile, route, entitlement,
reward, auth, account or cloud-sync change is included.

## Defects resolved before building

- Sound now discloses loading and recoverable startup failure. Cancel/retry
  actions match both the full player and the library mini-player.
- Configuration and source failures keep the selected track retryable; obsolete
  failures cannot replace a newer selection. Native error details remain hidden.
- System interruptions cancel pending starts. Auto-resume waits for native pause
  and rechecks both controller and notification intent, preserving later pause
  or stop decisions.
- Sound header/loop text wraps at 320 px with double text size.

Regression runs reproduced these failures before the fixes. A helper renderer
under ignored `tool/local` initially failed analysis after font setup was
inserted in the wrong place; the helper was repaired. This is separate from the
unavailable `/workspace/scratch/.../project_sources` references, which are not
used for this build.

## Verification record

| Command | Result |
| --- | --- |
| `flutter pub get` | Dependencies resolved, exit 0; no lockfile change. |
| `dart format --output=none --set-exit-if-changed` on all 23 cumulative changed Dart files | 23 files, 0 changes; exit 0. |
| `flutter analyze --no-pub` | No issues found; 80.7 seconds; exit 0 after helper repair. |
| `flutter test --no-pub <27 Meditation/Reset/Sound/audio/primary-tab test files> --reporter expanded` | 245/245 passed; 1:23; exit 0. File selection: `rg --files test`, filtered by `(meditation|reset|relief_access|sound|sleep|audio_interruption|background_audio|primary_wellbeing_tabs|releaf_guide)`. |
| `flutter test --no-pub test/sound_loading_recovery_test.dart --reporter expanded` | 18/18 passed after adding exact relative seek/boundary coverage; exit 0. |
| `flutter test --no-pub --reporter expanded` | Final 447/447 passed; 4:11; exit 0. Includes the additional seeking test. |
| `git diff --check` | Passed. |

The preceding reviewer-regression run reproduced three failures (short native
pause, mini-player loading, mini-player retry) before their fixes; final driver
and recovery tests passed 51/51 before the additional seek test.

| Build / installation command | Result |
| --- | --- |
| `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json` | Built successfully; assembleDebug 303.5 seconds; exit 0. Existing Gradle/AGP/Kotlin and SDK XML future/support warnings did not fail the build; no bypass flag used. |
| `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk` | `Performing Streamed Install` / `Success`; exit 0. No uninstall or app-data clearing. |
| `adb -s R5CX11J26SD shell am start -n app.releaf.mobile/.MainActivity` | Activity started; exit 0. |

APK: `build/app/outputs/flutter-apk/app-debug.apk`, **223,807,456 bytes**.
SHA-256: `FCF69AA7DB9964C98C73CC02B7B22D2F8199AAB57D6B197BD91F5D5D1D267193`.
This remains a debug/Test Store review artifact, not a production release build.

Allowlisted app-process logs confirm `public SDK key present=true` and
`Purchases.configure completed`. The scan found zero `FATAL EXCEPTION` /
`Unhandled Exception` markers. No key, token or raw SDK logs were printed.
The Samsung initially required owner unlock. After the owner unlocked it, the
following smoke checks were performed on the installed APK. Initial lock-screen
captures are not used as Releaf UI evidence.

## Samsung smoke observations

| Check | Actual observation / limit |
| --- | --- |
| Home and primary navigation | Home, Reset, Brain and Sound rendered and navigation worked. No game completion or reward test was performed on the device. |
| Meditation discovery | Sound → Meditate showed recorded/captions-only distinctions. Mindfulness Basics was labelled Recorded guide; other entries disclosed Captions only. |
| Premium preview | Anxiety & Worry → Before a Difficult Moment opened its Premium preview with Captions only and explicit no-recorded-voice copy. Unlock/purchase was not activated. |
| Meditation player | Mindfulness Basics rendered its recorded-guide player, started and paused. Audio controls showed independent narration (92%) and background mix (72%) with the approved-recording notice. No voice substitution, recording approval or acoustic listening assessment is claimed. |
| Meditation seeking | While paused, observed elapsed time changed exactly `00:28 → 00:38 → 00:28` using forward/back 10-second controls. Exited early. |
| Reset | Reset → Breath → 5–5 Balanced opened preview and the breathing visual. Session audio showed disabled Breathing cues and the unavailable-audio explanation, with a separate calming background control at 16%. Exited early. No rejected cue was enabled. |
| Sound playback | Releaf Atmosphere I reached PLAYING; pause showed PAUSED/Play sound. Resuming and briefly backgrounding/returning preserved PLAYING. Paused again at the end. |
| Sound timer | Selected 15 minutes; observed 14:58 and continued countdown after the short background/foreground transition (14:27 then 14:24). Restored Off. Full 15-minute expiry was not waited out on hardware. |
| Sound loading/retry/seeking | Native loading completed successfully. Delayed loading, injected errors/retry, notification races and exact relative seek/bounds are automated coverage; this continuous-loop player has no visible ±10-second buttons, and those cases were not artificially induced on the phone. |
| RevenueCat | Safe logs confirmed SDK key present, configure completed and `Purchases.getOfferings completed; current offering present=true`. No key/token printed. No purchase performed. |
| Runtime errors | Final app-process log scan found zero fatal, unhandled or Flutter layout-exception markers. |

Local screenshots: `build/quality/device-review/03-home.png` through
`12-sound-return.png`. The return screenshot includes the Android task-transition
frame; subsequent UI extraction confirmed the resumed player and ongoing timer.
One UIAutomator dump could not reach idle during Sound animation; its stale XML
was not used as player evidence. Screenshots and a fresh paused-state dump were
used instead.

The app was left on the paused Sound player with timer Off. No uninstall, data
clearing, purchase, deletion, production configuration or publication occurred.
This debug smoke does not close DQA-04/DQA-05/DQA-06 or the full production-
equivalent matrix. Final listening, long background/timer runs, real interruption
scenarios and Play-distributed billing remain separate release checks.

The connected device was identified as Samsung SM-S928B. Its existing package
is `app.releaf.mobile`, version `0.1.0`, version code 1, target SDK 36. Only
`adb install -r` is authorised; uninstall, purchase, account deletion, production
configuration and Play publication are excluded from this checkpoint.
