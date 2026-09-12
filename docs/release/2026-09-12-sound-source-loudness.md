# Sound source loudness comparison

Measured on `fac50ec`, `releaf-development`, 12 September 2026. Read-only
measurement fills the eight source-level loudness gaps left by the earlier
decode audit. No source, runtime gain, mix, candidate or approval changed.

## Method

Existing local FFmpeg 7.1 binary:
`build/audio-qa-deps/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe`.
For each of the eight files, run:

```text
ffmpeg -hide_banner -nostats -i <source.mp3> -af ebur128=peak=true -f null -
```

Use the final integrated loudness and True peak summary, not sample peak or
interim frames. FFmpeg labels that true-peak value dBFS; here it is reported as
dBTP. All eight scans exited 0; SHA-256 matched before/after every scan.
Durations are approximate input-container durations; all eight files are 44100 Hz.
Full logs and JSON are retained locally under ignored `build/qa-manifests/`.

## New measurements

All files below are under `assets/sounds/`.

| File | Seconds | Bytes | Integrated LUFS | True peak dBTP |
|---|---:|---:|---:|---:|
| relief_01.mp3 | 194.80 | 3318994 | -12.7 | -0.8 |
| brown_noise.mp3 | 120.03 | 960514 | -28.1 | -12.0 |
| soft_rain.mp3 | 180.04 | 2520913 | -26.3 | -17.1 |
| night_air.mp3 | 180.04 | 2520913 | -29.5 | -15.7 |
| ocean_wash.mp3 | 180.04 | 2520913 | -32.7 | -16.7 |
| forest_canopy.mp3 | 180.04 | 2520913 | -30.6 | -19.5 |
| white_noise.mp3 | 120.03 | 960514 | -23.7 | -12.2 |
| pink_noise.mp3 | 120.03 | 960514 | -25.3 | -12.0 |

| File | SHA-256, unchanged |
|---|---|
| relief_01.mp3 | bc4ad5ebfb6c5277919e47c906e0481de5484439afac2ee0b6db53ad0f853581 |
| brown_noise.mp3 | 7f19e3d11ba608f05a324783fc880972548e5a39ec514b94bef4fd449c3dcb42 |
| soft_rain.mp3 | b103ae6704c007e8bc7333f28f90595c2a20c72129f07d3b10bc86baa274afc9 |
| night_air.mp3 | 1825f4edf69bbb79c4aabbaca9892d5659aafd0f57c681079d27f53d120b0064 |
| ocean_wash.mp3 | 5a0bda31b6e56c556e284764f194bc05abaec337063bad1d4563f11ab2227642 |
| forest_canopy.mp3 | 9d83bcc977c5ce627ac60abf1ff14623e1fb66e0601b38d8cdce74dbcd801705 |
| white_noise.mp3 | 35c672271c819c255bd4b79d9a4d206cfbcdaaf3190555862ef44155cfa91119 |
| pink_noise.mp3 | 5dc667ec3c2052333bb6df60000961881749bbcb4823501c3e06b18c465759ad |

## Existing measurements retained

Deep Drift remains **-29.2 LUFS / -21.4 dBTP**, from the
[approved narration/ambience measurement](2026-09-12-approved-narration-measurements.md).
Its current hash still matches that evidence.

Atmosphere II remains **-9.0 LUFS / +0.8 dBTP**, with the source hash matching
the [existing candidate comparison](../../audio-candidates/2026-09-11/atmosphere-ii-comparison.json).
Its unapproved candidate is -12.3 LUFS / -2.5 dBTP. Neither was rescanned or promoted.

## Interpretation and remaining gates

- Atmosphere I is 0.2 dB above the shared approximately -1 dBTP production
  reference. Record this for headroom review; it is not evidence of audible clipping.
- Sources span -9.0 to -32.7 LUFS. Atmosphere II and Ocean Wash differ by 23.7 LU.
  These are source measurements, not actual player/device output or a perceived
  loudness guarantee across different spectra. Do not normalize active files
  automatically or equate app volume percentages with sound-pressure levels.
- All ten catalogued Sound sources now have source LUFS/true-peak evidence.
  Seamless loop listening, actual mix transitions, speaker/headphone comfort,
  final selection and Atmosphere asset rights evidence remain open.
- Synthetic nature/noise provenance is documented in the shared audio standard;
  these Sleep sounds must never substitute for owner-required human Reset cues.
- No new source approval, Samsung result, mastering acceptance or release
  readiness follows from these measurements.

Documentation-only batch: no APK rebuild or full Flutter-suite repetition needed.
Last runtime checkpoint `fac50ec` passed 544 tests, analysis and configured build.
Current `flutter analyze`: no issues, exit 0, 15.3 seconds. Eight report hashes
were compared with the machine-readable results and current files; all matched.
`git diff --check` passed. Only documentation is included in this checkpoint.
