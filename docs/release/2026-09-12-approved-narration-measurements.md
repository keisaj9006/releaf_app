# Approved narration measurements — 12 September 2026

Code checkpoint `329cfdd`, branch `releaf-development`. Read-only measurement of
the four existing approved `mindfulness-basics-2` recordings and their separately
bundled Deep Drift ambience. No audio was generated, processed into a new file,
replaced or newly approved. All five source hashes matched before/after scans.

## Method

Local ignored binary:
`build/audio-qa-deps/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe`.
Version: `7.1-essentials_build-www.gyan.dev`. This existing QA installation was
found after normal sandbox access was denied; no tool download was necessary.

For each file, run:

```text
ffmpeg -hide_banner -nostdin -xerror -i <source.mp3> -map 0:a:0 -af ebur128=peak=true -f null -
```

Use the final integrated loudness and **True peak** summary, not interim frame
values or sample peak. FFmpeg labels the true-peak summary's numerical peak as
dBFS; the table reports that oversampled true-peak result as dBTP. Container
duration is approximate, as reported by FFmpeg's input metadata. All scans exited
0. Machine-readable narration measurements and full logs are under ignored
`build/qa-manifests/`; stable results and source hashes are preserved below.

## Results

Narration directory: `assets/narration/releaf-guide/mindfulness-basics-2/`.

| File | Approx. file seconds | Sample rate | Integrated LUFS | True peak dBTP | Bytes |
|---|---:|---:|---:|---:|---:|
| 01-arrive.mp3 | 16.15 | 24000 Hz | -24.5 | -7.7 | 258861 |
| 02-notice.mp3 | 16.92 | 24000 Hz | -24.7 | -6.4 | 271149 |
| 03-return.mp3 | 16.08 | 24000 Hz | -24.4 | -5.7 | 257709 |
| 04-finish.mp3 | 17.16 | 24000 Hz | -24.9 | -7.8 | 274989 |

Deep Drift (`assets/sounds/deep_drift.mp3`): **-29.2 LUFS**, **-21.4 dBTP**.
This is the source measurement, not the rendered mix or phone output.

| Source | SHA-256 (unchanged before/after) |
|---|---|
| 01-arrive.mp3 | B8683D5C79E46F7922CEAEE4C3C3F169B5ACCEC99827A5637260367422B942D9 |
| 02-notice.mp3 | D6761164A5E05BAEF98CA7AE79B83ED9D25F14DB56D0DF1CD37C0D334F2646CA |
| 03-return.mp3 | 566BDBC968EA4C2B7EA613645CEB58F1ABDA2A11D443B7A489FCCCF3909459BC |
| 04-finish.mp3 | F95B1D865C087BD3EDF80AAF6CE456DD5728E11E9148DC9405BBD7EECB31819C |
| deep_drift.mp3 | C7CB11DBC794939594D1717AF2C0D86EFF5E9BE0E8C7E0EA6436A5308E7CE5ED |

## Interpretation and limits

The narration sources differ by only 0.5 LU in integrated loudness and show
headroom below full-scale true peak. This does not prove absence of audible
artifacts or owner comfort. The approved 24 kHz recordings are preserved; the
future 48 kHz production-source recommendation is not permission to resample them.

Runtime inspection confirms separate players: the recorded-voice driver plays
the existing asset without a new playback-rate transformation. The canonical
0.82x remains the approved production delivery reference; it cannot be verified
as a historical generator setting from an MP3 alone. Do not apply another speed
change to force a word-rate target. Spoken WPM, phoneme alignment and subjective
cadence were not measured here.

Current default configuration uses voice volume 0.92, Basics ambience volume 0.18
and ambience mix 0.72, multiplied by the ambience controller. These are control
values, not measured device loudness. Persisted preferences may differ. Source
measurements alone do not justify raising narration or changing the default mix;
owner speaker/headphone listening remains required.

No new Flutter test/build was needed for this measurement-only batch. Runtime is
unchanged from the 517-test checkpoint. No phone action, purchase, account change
or deployment occurred. Missing narration, human breathing candidates, provenance
records and full production-equivalent listening/device gates remain open.

Checkpoint `flutter analyze`: no issues found, exit 0 (24.3 seconds).
`git diff --check` passed; no diff under assets, lib or test. Independent read-only
review matched all five measurements and hashes against logs/current files,
with no actionable findings.
