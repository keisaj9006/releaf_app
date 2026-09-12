# Sound loop boundary evidence

Parent `0a11f9c`, `releaf-development`. Ten read-only decoded-waveform scans
completed using existing FFmpeg 7.1. Source hashes matched before/after every scan.
No audio was generated or replaced, and no playback algorithm was changed.

## Method and limits

```text
ffmpeg -hide_banner -nostdin -xerror -i <source.mp3> -map 0:a:0 -c:a pcm_f32le -f f32le -
```

Decode at the source sample rate/channel count. Compare pooled channel RMS over
the first/last second; compute the maximum absolute last-to-first sample jump
across channels. Compare that jump with the 99.9th percentile of per-frame maximum
adjacent-sample jumps within the file. Values are amplitude dBFS, not LUFS, dBTP
or device SPL. Zero values use a reporting floor of -240 dBFS. This heuristic
does not establish click audibility, psychoacoustic continuity or native gapless
playback. No automatic pass/fail threshold is inferred from it.

Machine results: ignored `build/qa-manifests/sound-seam-measurements.json`.
Hashes are identical to the source loudness evidence; all scans exited 0 and
all decoded samples were finite. Each source is 44100 Hz; noise tracks are mono,
the other tracks stereo. Exact decoded sample counts give 120s/180s for the
generated tracks; Atmosphere I is 194.770045s and II 230.968889s.

## Results

| Source | First second RMS dBFS | Last second RMS dBFS | Wrap jump dBFS | Wrap relative to internal P99.9, dB |
|---|---:|---:|---:|---:|
| Atmosphere I | -48.20 | -82.20 | -110.98 | -96.64 |
| Atmosphere II | -43.47 | zero | zero | n/a |
| Brown Noise | -25.90 | -25.41 | -72.91 | -35.75 |
| Soft Rain | -31.32 | -31.38 | -24.86 | -3.41 |
| Night Air | -31.11 | -31.42 | -41.51 | -6.62 |
| Ocean Wash | -31.96 | -32.43 | -42.26 | -7.18 |
| Forest Canopy | -34.22 | -34.49 | -43.04 | -15.96 |
| White Noise | -26.86 | -26.85 | -17.12 | -2.47 |
| Pink Noise | -26.12 | -26.25 | -28.83 | -8.36 |
| Deep Drift | -29.80 | -29.82 | -48.83 | +6.06 |

## Engineering findings

- The eight generated sources use periodic FFT noise and periodic modulation;
  Deep Drift also uses additive tones with whole cycles over the source duration.
  Their first/last second RMS differences are small, but MP3 boundary behavior
  still requires native/device listening. Deep Drift's wrap step is 6.06 dB above
  its internal P99.9 step, at an absolute -48.83 dBFS: prioritize that join for
  listening without claiming a proven audible click.
- Atmosphere sources have very quiet boundaries; Atmosphere II's final second
  is exactly zero in the decoded waveform. Small wrap jumps therefore do not
  prove uninterrupted perceived texture. Existing headroom candidates do not
  repair this structural issue. Loop-compatible mastering/selection remains open.
- Sound currently calls `ReleaseMode.loop`; there is no Sound crossfade engine
  in this path. Do not infer native gapless performance from that API request.
- The player badge now says `Continuous loop`, matching the existing library
  wording. Removed the unverified `seamless` quality promise; timing, controls,
  access, assets and runtime behavior are preserved.
- Samsung speaker/headphones, screen-off joins and long-duration playback remain
  required. No source or candidate received owner approval in this batch.

## Verification

Ten scans completed successfully, source hashes unchanged and rechecked against
the JSON results after verification.

- `flutter test --no-pub test/sleep_experience_test.dart test/sound_loading_recovery_test.dart`:
  28 passed, exit 0.
- `dart format lib/features/sound/presentation/sound_player_screen.dart`: completed.
- `flutter analyze`: no issues, exit 0, 28.6 seconds.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  success, exit 0, assembleDebug 84.1 seconds. APK:
  `build/app/outputs/flutter-apk/app-debug.apk`; local configuration remains ignored.
- `git diff --check`: passed; source diff is one visible-label replacement.
- `adb devices -l`: no connected device. No installation or listening claimed.
- Full suite not repeated for this label-only follow-up; last runtime checkpoint
  `fac50ec` passed 544 tests. Audio measurement is not a new playback implementation.
