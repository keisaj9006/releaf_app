# Sleep long-form progress foundation — 2026-09-23

## Scope

This batch adds the local persistence boundary required before a long-form
Story player can safely resume playback. It does not expose unfinished Stories,
enable cloud progress sync or change existing Sound playback.

## Implemented

- Versioned SharedPreferences storage for Sleep progress.
- Position, known duration, current chapter, explicit completion and favourite
  state per stable Sleep content ID.
- Per-account local isolation using the authenticated account UUID when one is
  available, with a separate anonymous scope. No e-mail address is stored.
- Serialized writes so rapid position updates persist in call order.
- Fail-closed decoding for corrupt records and clamping to zero/known duration.
- Recency-ordered Continue Listening records that exclude zero-position and
  completed items.

## Verification

- Red test: the focused test initially failed because the progress boundary did
  not exist.
- `flutter test --no-pub test/sleep_progress_store_test.dart --reporter expanded`:
  PASS, 8/8.
- Focused Sleep/Stories/account regression set: PASS, 57/57.
- `flutter analyze --no-pub`: PASS, no issues.

## Remaining

The store is ready for the future Story player but is not yet wired to playback.
Finite long-form playback, exact seek boundaries, UI resume and physical
background/lock-screen verification remain open.
