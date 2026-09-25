# Execution ledger — plan: docs/superpowers/plans/2026-09-22-relief-story-player-batch2.md

## Continuation: shared media ownership, Batch 2B
Base: 9c4a0edd5b24eb983f534299d064a5647858ae8b. Existing PR #3 and isolated feature branch retained. Prior validation run 35780614741 is fully SUCCESS including debug APK, preview APK, release smoke AAB and 16 KB checks. No phone/listening QA claimed.

Ruling: reuse the tested Sound and Story drivers with separate native decoder instances under ONE initialized AudioService handler and exclusive audible ownership. Sharing one AudioPlayer between the drivers' independent queues would permit stale commands to target the wrong source. This does not permit mixing or competing notification services.
Ruling: reserve ownership synchronously when an eligible playback request enters the controller, cancel the other controller immediately, and await its native shutdown before allowing audible output. Warning refusal and missing audio must not take ownership.
Ruling: media actions route to the current controller, not directly to its decoder. This preserves Story warning, restore, rate and cancellation rules. Stop invalidates pending handoffs too.
Ruling: keep the default-off public startup on its original handler. Shared service is instantiated only for explicitly enabled Owner Preview. Its fallback reuses the same shared handler, not another background service. No new assets, dependencies, billing or public release scope.

## Task 1: shared handler — complete
- Tests introduced at 97cf877; compile-only boundary 7738fb5. Run 35783298584 stopped at a fixture name collision with AudioPlayer.release(); rename to releaseModeSeen, no assertions weakened.
- Behavioral RED: run 35784005976 at 34c91ba, 661 passing / 15 failing. All failing tests were new shared-handler contracts.
- GREEN: 0eb20d8d8e8a022fcb6bc308616913ceb93d2eeb, run 35785248595 analyzer and full suite SUCCESS. Native shutdown failure blocks handoff; slow source/handoff cancellation, notification projection/controls, interruption intent and timer/headphone behavior are covered.
- Tests run real controllers and real drivers; only the native audio-plugin boundary is simulated. This is not phone listening QA.

## Task 2: root runtime/provider hookup — implementation awaiting verification
- Tests introduced at 534d7ec; compile-only runtime 73eec771207b5ed342c110de23b535683b50c9d4.
- Behavioral RED: run 35785806289 / job 106942623281: analyzer and targeted Brain/Reset/access suites SUCCESS; full suite 678 passing / 4 failing. Missing root event delivery, lifecycle checkpoint/resync, safe error pause and preview-only main/provider wiring.
- Implementation adds application-scoped interruption/noisy subscriptions and lifecycle checkpoints, idempotent start/close, late-setup cancellation and contained callback failures.
- One handler supplies both controller providers. Managed Sound screens skip their local session setup/event subscriptions and resume timer callbacks to avoid duplicate event delivery.
- Main's billing/auth configuration, old public audio startup, catalog, source recordings and legal evidence remain unchanged.

## Remaining before exposing native Story playback
- Verify task 2 analyzer/full-suite/build results on its exact commit.
- Cross-feature audio exclusion: active Reset/Emergency and parked Meditation entry/return must cancel Stories and prevent notification restarts while their session is active. Existing gates only pause Sound; do not expose Story UI until this is covered.
- Story Player guarded UI, warning flow, ownership-aware return/back handling, narrow/large-text tests and explicitly flagged Owner Preview APK.
- Import one actual owner-supplied measured delivery recording only after file access/version/permission verification. Physical-device/background audio/listening QA remains open.

Self-review is the available review mode; no independent reviewer was dispatched. PR remains draft and unmerged. No owner Windows files, production audio, artwork, scripts or rights evidence were modified.
