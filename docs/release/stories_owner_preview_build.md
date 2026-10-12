# Relief Stories owner-preview build

The three long-form Story masters remain private, rights-pending production
assets. They are **not committed to GitHub** and ordinary CI APKs do not contain
them. The local builder overlays the exact verified files temporarily, builds an
APK, checks its Story entries, and removes the temporary audio copies. Existing
local asset copies are restored and a failed audit preserves the previous output.

## Current input — received 12 October 2026

The owner supplied a ZIP of **85,229,350 bytes**, containing three actual M4A files
and macOS metadata. The actual files are **AAC, 48 kHz, stereo**:

- `ST_TS01_BEYOND_THE_GATE_v01_128k.m4a` — 32:50.667 (1970.666667 seconds)
- `ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a` — 36:38.292 (2198.291667 seconds)
- `ST_L05_COMPUTER_v01_128k.m4a` — 20:45.000 (1245.000000 seconds)

Exact SHA-256 pins are in `tool/stories/build_owner_preview_with_local_audio.sh`.
Every file must match its hash. When ffprobe is installed, the builder also checks
duration within 0.05 seconds, 48 kHz sample rate, and two channels.

The earlier 44.1 kHz pin set does **not** describe this received ZIP. The current
contract deliberately supersedes those private-preview pins based on inspection
of the actual owner upload. Do not resample or recompress these files to force
agreement with an older description. See
[the measured intake checkpoint](2026-10-12-stories-received-audio-intake.md).

## Build on macOS or Linux

This requires a configured Flutter/Android development environment; the script
does not install Flutter, the Android SDK or Java. From the project root:

```bash
bash tool/stories/build_owner_preview_with_local_audio.sh \
  "/absolute/path/to/Relief-Stories-Audio-Delivery-Pack-v2(2).zip"
```

An `APP_DELIVERY` directory containing the same three exact files is also accepted.
The output is `build/qa-apks/Relief-Stories-Owner-Preview.apk`.

The builder enables Premium Preview and Stories Preview and runs the focused
Stories tests. Keep the resulting APK private because it contains the recordings.
Its debug signing must be considered when installing over an existing app; do not
uninstall an existing installation merely to resolve a signing mismatch, because
local progress may be lost.

## CI and release boundary

Flutter P0 Validation runs the shell-flow regressions using synthetic fixtures,
then the focused Stories configuration/screens with audio and Premium defines,
and the ordinary full suite after a compiler reset. These checks do not publish
private audio and do not certify that an ordinary CI APK contains the recordings.

The private owner-preview APK still needs a real build, final embedded-file
verification and owner/device playback review. Input decoding is not listening
approval. No public promotion, licence clearance, production signing, Play billing
approval or final physical-device QA is implied. `ST-DC-004` remains separate and
unavailable.
