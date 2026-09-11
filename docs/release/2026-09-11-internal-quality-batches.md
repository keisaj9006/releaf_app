# Internal quality batches — 11 September 2026

## Batch 1 — recorded audio cancellation

Base: `efbcf58` on `releaf-development`, the preserved and pushed audit batch.

Delayed audio configuration and source loading could start an obsolete clip after
stop, disposal, or a newer cue. Reset phase changes now invalidate pending driver
work before configuring the next cue, including silent phases. The shared driver
serializes player operations and checks cancellation after source loading, before
resume. Meditation also guards delayed configuration against stop/mute/disposal.

Files: `meditation_voice_controller.dart`, `reset_voice_playback.dart`,
`breathing_widget.dart`, and three focused test files (`meditation_voice_cancellation_test.dart`,
`recorded_voice_driver_cancellation_test.dart`, `reset_voice_playback_test.dart`).

TDD evidence: configuration regressions failed before implementation; three
source-loading regressions and two Reset/driver integration regressions also
failed before their fixes. The final focused set passed 17 tests. Independent
review identified both source-loading gaps; both were fixed and re-reviewed with
no remaining material findings.

Final verification: `flutter test --no-pub --reporter expanded` passed **346 tests**;
`flutter analyze --no-pub` returned **No issues found**; `flutter build apk --debug
--no-pub` succeeded and produced `build/app/outputs/flutter-apk/app-debug.apk`.
`git diff --check` passed. Existing Gradle/Kotlin deprecation warnings remain;
this debug artifact is not a production-signing or device-QA result.

Affected gates: RESET core and Meditation player reliability. No new recording,
narrator, route, access rule, reward, or cloud-sync behavior is introduced.
Production content approval and Samsung physical-device audio QA remain open.

Next priority: correct breathing-content readiness reporting, then prepare an
Atmosphere II headroom candidate without replacing the active asset.

## External candidate-generation dependency

Separate natural-breath sound-effect audition requests to
`fal-ai/elevenlabs/sound-effects/v2` returned HTTP 403: account balance exhausted.
No candidate audio was generated or installed. No narration provider identity was
selected or substituted. This dependency does not block local pipeline or player work.

## Batch 2 — breathing-content readiness

Base: `e5b1cab`. The Reset manifest previously reported zero breathing cues
needing rendering because the two rejected tone assets existed. It now exposes
presence, existing/target cue type, rejection and production-approval status
separately, with two replacements and approvals pending. Hold/rest are silent
and require no asset. Runtime paths and audio bytes are unchanged.

Files: Reset manifest exporter and its test; Reset guidance quality test copy;
Releaf Guide production standard; CURRENT_STATE; canonical gate; this evidence.
The RESET core gate is now honestly DONE / CONTENT.

Verification: the new manifest assertion failed with expected 2 / actual 0 before
the fix. Final focused run passed **14 tests**; analyzer reported **No issues
found**; web release build succeeded. An earlier command used a nonexistent test
filename and was corrected. The web build emitted existing dependency Wasm
dry-run warnings but completed successfully. `git diff --check` passed.
The previous full-suite checkpoint remains 346 passing tests; this batch changes
tooling metadata and documentation only.

Next: objective Atmosphere II candidate comparison, followed by Sleep timer
boundary verification. Owner listening/approval and natural-breath candidate
generation remain external dependencies; no runtime candidate was shipped.

## Batch 3 — Atmosphere II headroom audition

Base: `97ab2ce`. Created a separate unapproved MP3 and objective JSON comparison
under `audio-candidates/2026-09-11`, with a README containing processing commands
and limitations. Active `relief_02.mp3` SHA-256 is unchanged. No Flutter asset
registration or runtime code changed.

FFmpeg decode/EBU R128 scans passed for both files. Source: +0.8 dBTP, -9.0 LUFS,
5,646,537 bytes. Candidate: -2.5 dBTP, -12.3 LUFS, 5,550,432 bytes. Static -3 dB
attenuation plus MP3 re-encoding creates headroom; it is not restoration of
existing distortion or owner listening approval. The initial measurement helper
hit a Windows metadata-decoding error; explicit UTF-8 fixed it without replacing
the already-created candidate.

Affected gate: Sleep/Sound CONTENT remains open pending owner listening and
selection. Runtime build/test evidence remains the verified batch 1 Android and
batch 2 web artifacts. Fresh analyzer: **No issues found**. `git diff --check`
passed; no `audio-candidates` references exist in lib or pubspec. Next internal
task: Sleep timer deadline boundaries.

## Batch 4 — exact Sleep timer expiry

Base: `f1b6856`. The wall-clock countdown added one to truncated seconds,
showing 901 seconds immediately after a 15-minute selection and remaining active
at its exact deadline. It now rounds fractional seconds upward without adding a
whole second. The final positive fraction displays one second; the exact deadline
expires once. Fade behavior, selected duration, background resync and narration-free
Sleep are preserved.

Files: Sound player controller, Sound experience tests, this evidence.
Both new deterministic-time regressions failed before the fix. Focused
Sound/Sleep tests: **16 passed**. Analyzer: **No issues found**.
Full suite: **348 tests passed**. Android debug APK built successfully at
`build/app/outputs/flutter-apk/app-debug.apk`; existing Gradle/Kotlin warnings
remain. `git diff --check` passed.

Affected gate: Sleep player/timer reliability. Samsung screen-off/background
verification remains deferred to the production-equivalent RC. Next priority:
Meditation ambience cancellation during delayed startup.

## Batch 5 — Meditation ambience cancellation

Base: `54132e3`. Delayed ambience startup could fade in after pause, stop or mute;
old fades could continue after a newer action. Playback and fade generations now
guard asynchronous completions. Native player operations are serialized; source
preparation is separate from resume, and only a current prepared source is
resumable. Muting starts cancellation before preference persistence. Platform
cleanup errors remain nonfatal.

Files: Meditation audio controller; new ambience cancellation tests; shared
driver cancellation tests; this evidence. No narrator, track, catalog volume,
mix preference, route or audio-layer contract was changed.

TDD: three controller delayed-start cases, four native-driver cancellation cases,
two resume/preparation cases and the initial-stop-failure case failed before
their fixes. Disposal and fade supersession also have regression coverage.
Independent review found the resumable-source edge case; it was fixed and
re-reviewed with no remaining material findings. Focused verification: **49
tests passed**. Analyzer: **No issues found** after fixing six brace-style lints.
Full suite: **360 tests passed**. Android debug build succeeded and produced
`build/app/outputs/flutter-apk/app-debug.apk`. `git diff --check` passed.

Gate affected: Meditation player reliability. Device interruption and background
audio QA remain open. Next internal task: browsing the existing Daily Insight
collection without changing daily rotation, evidence copy or navigation.

### Targeted user-reported checks

- Meditation already has its own audio-first ambient visual and optional captions,
  protected by `primary_wellbeing_tabs_test.dart`; no Reset-style rewrite needed.
- Approved Mindfulness Basics uses Deep Drift at 0.18 multiplied by the saved
  ambience mix (default 0.72), independent of voice volume (default 0.92).
  Audit means are -30.4 dB for Deep Drift and -24.9 to -25.3 dB for the four
  narration clips. Applying default linear gains predicts approximately -48.1 dB
  ambience versus -25.6 to -26.0 dB narration. This static estimate does not
  reproduce narration being masked at defaults; preserve user controls and verify
  perceived balance on Samsung at RC rather than arbitrarily remastering approved
  voice assets. Decode measurements are not listening approval.
