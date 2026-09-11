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

## Batch 6 — browsable Daily Insight and large-text Home

Base: `2dd74b2`. The existing catalog contains 30 entries, but its sheet exposed
only the daily entry. The same sheet now provides previous/next controls and an
announced position count; navigation wraps through the existing collection.
Each entry retains its own evidence/source link, and closing leaves today's
Home recommendation unchanged. No routes or educational claims changed.

The 320px/1.8 text-scale regression also exposed three existing Home overflows.
Intent labels and the Insight badge can now wrap within their available width;
feature-card height grows with text scale. These are layout corrections, not a
navigation or product-pillar redesign.

Files: Home screen, Home hub tests, this evidence. Browsing assertions failed
before implementation; the large-text test reproduced the existing overflows.
Final focused Home tests: **13 passed** (including all 30 entries, backward
navigation and closing). Analyzer: **No issues found**. Independent review found
no actionable regressions. Full suite: **362 tests passed**. Android debug APK
built successfully. `git diff --check` passed.

Affected gates: accessibility and general release QA; no external gate closes.
Next: finish targeted legacy Brain difficulty/progression quality checks.

## Batch 7 — consistent difficulty for legacy Brain games

Base: `a3f76e0`. Memory, Broken Mirror and Rule Shift already had persistent
training progression but lacked the shared difficulty control. Their canonical
game flows now offer Easy/Medium/Hard before interaction. Medium is the existing
behavior; other modes adjust the session practice level by two within 1–12.
The displayed/saved training level is unchanged. Selection locks after the first
card reveal, shard movement or answer. No completion is emitted by selection.

Files: shared difficulty selector/helper; game registry flags; the three game
screens; new legacy difficulty tests; this evidence. Existing statistics remain
keyed to training level and therefore include sessions played at different chosen
difficulties, as elsewhere in the portfolio. Leaves and completion persistence
were not modified.

All three missing-selector regressions failed before implementation. Focused
tests: **68 passed**, covering the new controls at 320px, bounds, Medium
compatibility, locking, Memory statistics, existing progression and completion
idempotency. Independent review found no actionable regressions. Analyzer:
**No issues found** after fixing three brace-style lints. Full suite: **366 tests
passed**. Android debug APK built successfully. `git diff --check` passed.

Affected gate: BRAIN core / QA. Labyrinth accelerometer/collision feel remains
physical-device QA; selectable difficulty and automated progression are already
implemented. Next: Sleep timer request-ordering regression.
