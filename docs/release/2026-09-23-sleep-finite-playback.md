# Sleep finite playback foundation — 2026-09-23

## Scope

This batch extends the existing Sound controller and Releaf background audio
driver so the same playback path can serve looped soundscapes and finite
long-form Stories. It does not add a second AudioService or expose an unfinished
Story to users.

## Implemented

- Explicit `looping` and `finite` playback modes.
- Existing Sound catalog playback continues to use native loop mode.
- Long-form assets use native stop mode and retain a stable completed state.
- Replaying a completed finite item seeks to zero before resuming.
- Relative and absolute seek operations clamp at zero and known duration.
- Before duration metadata arrives, negative seeking clamps to zero and forward
  seeking remains available.
- Android AudioService repeat metadata reports `one` for looped playback and
  `none` for finite playback.
- Existing cancellation, interruption, timer fade and retry behavior remains on
  the shared controller.

## Verification

- New long-form playback tests: PASS, 6/6.
- Focused Sound/Sleep/background audio regression: PASS, 102/102.
- Post-completion-state focused regression: PASS, 67/67.
- Full Flutter suite: PASS, 619/619.
- `flutter analyze --no-pub`: PASS before the final completion-state hardening;
  rerun recorded in the checkpoint report.

## Remaining

The finite playback boundary is ready for the Story player. Production Story
audio is still unavailable, so real long-duration, lock-screen, Bluetooth and
headphone behavior remains a physical-device/asset dependency.
