# Releaf product-quality programme

Backend checkpoint: [runtime SDK key validation](../release/2026-09-12-runtime-sdk-key-validation.md),
510 tests, clean analysis, Android build and Samsung replacement passed.
Next independently confirmed defect: a failed RevenueCat identity transition can
refresh old-account entitlements. Add a regression with the real controller and
fake service; keep an unresolved-identity gate closed for refresh/listeners and
billing actions until the latest requested auth identity succeeds. Route retries
through the app coordinator, preserve same-account offline entitlement recovery,
and cover overlapping transitions and password-recovery callers. No real account
switch, purchase or deletion is needed to reproduce this in tests.

Latest progress checkpoint: [daily progress rollover](../release/2026-09-12-daily-progress-rollover.md).
Cached dates no longer prevent new-day rewards; Home refreshes daily flags.
509 full tests, clean analysis, Android debug build and Samsung replacement
installation passed. Reward semantics remain unchanged. Next: backend/offline
and release-quality requirements, with owner listening and overnight QA pending.

Owner-approved on 11 September 2026 after the capability checkpoint. Work only
in `C:\Users\joann\Releaf-Codex` on `releaf-development`. The canonical
[release gate](../release/releaf_1_0_release_gate.md) remains authoritative.

## Execution

Completed owner checkpoint instruction, 12 September: pause further feature development
and prepare the cumulative Meditation/Reset/Sound batch for Samsung review.
Finish only batch defects and verification, update the existing app with
`adb install -r`, and create/push a checkpoint after successful verification.
See [checkpoint evidence](../release/2026-09-12-device-review-checkpoint.md).

The owner subsequently resumed the programme from committed/pushed `16a0f2c`. Continue Reset audio lifecycle work, then the remaining tracks. Listening, approved missing narration and long-duration hardware checks remain pending.

Implement small vertical milestones with TDD, focused verification, analysis,
UI inspection, appropriate builds and conventional commits. Push only this
branch. Use independent review for substantial changes. Continue unblocked work;
record hardware and external prerequisites without treating them as completed.

No account-deletion E2E repeat in this programme. Preserve the primary QA account,
all user data, local progress, Leaves/reward semantics, access rules and public IDs.
No cloud-backup claim, substitute narrator, Sleep narration, purchases, paid
generation, production deployment or store submission under this approval.

## Prioritised tracks

| Priority | Track | Next milestone / dependency |
| --- | --- | --- |
| 1 | Meditate, visual design, accessibility | COMPLETE: honest recording availability in library/preview/player, usable captions and large-text layouts. Approved remaining recordings and device QA remain open. |
| 2 | Reset / Emergency | COMPLETE: rejected breathing cues cannot reach runtime; silent/reduced-motion guidance and saved preferences are covered; audio settings are readable. Approved natural breathing cues remain an owner/content dependency. |
| 3 | Sleep / Sound | COMPLETE: playback/volume intent, loading/error/retry and interruption recovery (447 full tests, clean analysis, APK and bounded Samsung smoke). Owner review is next; Atmosphere II candidate still awaits listening approval. |
| 4 | Brain | IMPLEMENTED: Memory has 50 defined profiles, persisted progression and browsable all-level stats; legacy profiles and rewards preserved. Labyrinth 50-stage architecture preserved; physical game-quality review pending. |
| 5 | Progress / personalisation / mascot | Home time-dependent content now refreshes while active/on resume; Sleep recommendations describe actual sound/timer behavior. Next: verify daily progress rollover. Saved focus, reward semantics and character identity remain unchanged. |
| 6 | Backend / subscriptions / offline | Strengthen configured/missing-key SDK coverage and startup guarantees; preserve UUID identity, local-first behaviour and account isolation. |
| 7 | Release / performance / security | Refresh evidence, asset provenance, measured budgets and store deliverables up to the explicit deployment/submission boundary. |

## Milestone 1: know the guidance before starting

Root cause: the catalog and player distinguish recorded narration, but library
labels assume every non-timer session has a voice. Missing recordings also start
with captions hidden and lack a caption shortcut. The approved recorded session
must remain audio-first; other existing scripted practices must explicitly offer
on-screen guidance, with no promise that Premium supplies missing audio.

Keep the existing library, art, routes, access policy, separate audio layers and
recording contract. Disclose complete/partial/absent narration and unguided timers.
Expose captions by default in practices without complete recordings without
overwriting the stored preference merely by opening them. Preserve explicit
caption toggles and approved-recording preferences.

Verification: regression tests for entry points and player, entitlement/audio
checks, small-screen/large-text layouts, analyzer, full-suite checkpoint and an
Android debug build using the ignored local Test Store configuration. Device
verification remains pending while ADB reports no device.

## Milestone 3 plan: latest Sound playback intent

Current `play` increments a request counter without checking it after awaited
configuration. Native foreground/background drivers combine source load and
resume, so cancellation can arrive before a stale load resumes. Volume writes
also complete out of order. Reproduce delayed configuration, source loading,
pause/stop/disposal and competing volume requests first. Add controller request
checks, reuse a guarded native driver in the background handler, and restore the
latest desired output after stale writes. Keep controller operations concurrent
so existing timer race tests remain meaningful. Preserve metadata, looping,
timer semantics, catalogue and access. Loading-error presentation is a following
bounded task; this batch only tracks source readiness needed for safe resume.

## Completed evidence

### Next Brain milestone: Memory Mirror through level 50

After Reset lifecycle verification, the bounded Sleep/Sound review found no
additional demonstrable code defect. Continue the authorized Memory extension.
Preserve exact levels 1–12, including existing Easy/Hard boundary behaviour.
Use a Memory-only profile resolver: Medium 13–18 has 8 pairs and 45–40 seconds;
19–26 has 9 pairs and 48–41 seconds; 27–34 has 10 pairs and 50–43 seconds;
35–42 has 11 pairs and 52–45 seconds; 43–50 has 12 pairs and 54–47 seconds.
Decrease one second per step within each band and allow extra time for a larger
board. Above level 12, Easy/Hard keep the existing -2/+2 practice offset capped
at 50. Other games retain their current caps.

Verify profiles, hosted and standalone persistence, real board completion,
pending-pair reset/timeout safety and largest-board layout. Keep score/reward
formulas, preference keys and cumulative completion counts. Update the result
and hub maximum labels to use the game's own cap. Hardware review remains open.

### Milestone 4 plan: visible Sound loading and recoverable failure

The Sound player currently labels an unfinished start PAUSED and lets a current
source/configuration failure escape from its unawaited startup. Add explicit
loading and safe failure state, with the existing primary control offering
cancel while loading and retry after failure. Preserve the selected track on a
failed start so retry reloads the source. Do not display native errors or paths.
Test delayed configuration/load, failure then retry, stale failures, cancellation
and narrow/large-text layout. System pause/unknown interruptions must also cancel
pending startup; a permitted auto-resume must not override a later user decision.
Keep existing artwork, access gates, timer deadlines and notification behaviour.

### Milestone 2 plan: silent breathing until approved

The export manifest marks both bundled breathing tones rejected, but the runtime
resolver still selects them. Add one shared production-approval guard to cue
resolution and manifest runtime eligibility. Keep target paths/assets for the
content pipeline. Disable unavailable cue controls without rewriting saved voice
preferences; retain ambience controls and visible/semantic breathing phases.
Regression sequence: fail runtime playback, manifest and UI tests first; implement
the smallest shared guard; run Reset access/lifecycle/completion tests, analyzer,
full checkpoint and Android debug build. No asset replacement or new approval.

- Starting HEAD `1b24990`: clean and synchronised with origin. Fresh focused
  Meditate baseline 5/5 passed. Previous full checkpoint: 376 tests; analyzer clean.
- Capability check: local Flutter/Gradle and GitHub/Supabase available. Canva and
  direct ElevenLabs connector unavailable; neither blocks milestone 1. No paid
  generation or external mutations were performed.
- Milestone 1: [guidance quality evidence](../release/2026-09-11-meditation-guidance-quality.md).
  Focused tests 40/40, full suite 383/383, analyzer clean, four local Flutter
  renders and Android debug APK built. ADB reported no device; physical QA is open.
- Milestone 2: [Reset cue eligibility evidence](../release/2026-09-11-reset-cue-eligibility.md).
  Focused Reset tests 69/69; follow-up contrast/UI tests 40/40; full suite 386/386;
  analyzer clean. No audio replacement, recording approval or physical QA claimed.
- Milestone 3: [Sound playback evidence](../release/2026-09-11-sound-playback-intent.md).
  Focused tests 70/70; full suite 425/425; analyzer clean and Android debug build
  passed. No connected device, physical playback test or purchase performed.
- Device checkpoint, 12 September: [Samsung review evidence](../release/2026-09-12-device-review-checkpoint.md).
  447 full tests passed, analyzer clean, APK installed with `adb install -r`.
  Bounded UI smoke passed; no purchase or deletion. Checkpoint
  completed as `16a0f2c`; independent development has resumed while owner review remains pending.
