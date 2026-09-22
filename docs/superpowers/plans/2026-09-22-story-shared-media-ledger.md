# Execution ledger — plan: docs/superpowers/plans/2026-09-22-relief-story-player-batch2.md

## Continuation: shared media ownership, Batch 2B
Base: 9c4a0edd5b24eb983f534299d064a5647858ae8b. Existing PR #3 and isolated feature branch retained. Prior validation run 35780614741 is now fully SUCCESS including debug APK, preview APK, release smoke AAB and 16 KB checks. No phone/listening QA claimed.

Ruling: reuse the tested Sound and Story drivers with separate native decoder instances under ONE initialized AudioService handler and exclusive audible ownership. Sharing one AudioPlayer between the drivers' independent queues would permit stale commands to target the wrong source. This does not permit mixing or competing notification services.
Ruling: reserve ownership synchronously when an eligible playback request enters the controller, cancel the other controller immediately, and await its native shutdown before allowing audible output. Warning refusal and missing audio must not take ownership.
Ruling: media actions route to the current controller, not directly to its decoder. This preserves Story warning, restore, rate and cancellation rules. Stop invalidates pending handoffs too.
Ruling: keep public default-off startup unchanged until the new handler passes its tests; then wire the shared service only in explicitly enabled Owner Preview builds. No new assets, dependencies, billing or public release scope.

Tasks:
1. Shared handler, exclusive ownership, notification projection and controls; tests use real controllers/drivers and fake only the native plugin boundary.
2. App/provider/system-event hookup with no duplicate screen-local Sound listeners in managed mode.
3. Full regression and build verification; UI/pilot work follows only after this integration is safe.

Test-first record:
- 97cf877 adds behavior contracts; 7738fb5 adds a compile-only handler, not instantiated by main.
- Run 35783298584 failed analysis because the native test fixture field `release` conflicts with AudioPlayer.release(). Rename it releaseModeSeen; no assertion weakened. This is not a behavioral RED result.
- Handoff signal waits have a 2-second bound so an absent handoff fails instead of hanging the suite.

No source audio, owner Windows directories, finished artwork or legal evidence has been modified.
