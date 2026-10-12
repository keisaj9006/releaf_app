# Relief Stories owner-preview build

The three long-form Story masters are rights-pending production assets. They are
therefore **not committed to GitHub** and are not included in ordinary CI APKs.
The owner-preview build overlays verified local masters, builds an APK and then
removes those masters from the working tree automatically.

## Pinned input

Use either the full delivery ZIP or its `APP_DELIVERY` directory. The final v2
input is pinned by SHA-256 in
`tool/stories/build_owner_preview_with_local_audio.sh` and must contain:

- `ST_TS01_BEYOND_THE_GATE_v01_128k.m4a` — 32:51.960 (1971.960 seconds)
- `ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a` — 36:38.667 (2198.667 seconds)
- `ST_L05_COMPUTER_v01_128k.m4a` — 20:45.260 (1245.260 seconds)

The build script verifies the exact SHA-256 of every master and, when `ffprobe`
is available, checks duration within 0.05 seconds, **44.1 kHz** sample rate and
stereo channel count. Do not resample the pinned masters to 48 kHz: that would
change their hashes and invalidate this input contract.

## Build on macOS or Linux

From the project root:

```bash
chmod +x tool/stories/build_owner_preview_with_local_audio.sh
./tool/stories/build_owner_preview_with_local_audio.sh \
  "/absolute/path/to/Relief-Stories-Audio-Delivery-Pack-v2.zip"
```

A directory is accepted as well:

```bash
./tool/stories/build_owner_preview_with_local_audio.sh \
  "/absolute/path/to/APP_DELIVERY"
```

The resulting APK is:

```text
build/qa-apks/Relief-Stories-Owner-Preview.apk
```

The build enables both Premium Preview and Stories Preview, validates the focused
Stories screens, and confirms all three M4A files are physically present in the
APK. The local M4A copies are deleted automatically after success or failure;
any pre-existing copies are restored. Keep the resulting APK private as it
contains the recordings.

## CI boundary

Flutter P0 Validation runs the focused Stories configuration, discovery and player
route tests with the owner-preview audio and Premium defines, then resets the
Flutter test compiler before running the ordinary full suite. Large-text coverage
includes 320 x 640 at 200% text and scrolling to each of the three Story controls.
These tests exercise UI and configuration contracts without publishing the
private recordings. Passing them is **not** proof of audio decoding, owner
listening approval, or the recordings being inside a downloadable APK.

## Release boundary

This APK is for owner/device review only. The three Stories must not be promoted
to a public store build until rights, editorial approval and final release access
are recorded. The pending `ST-DC-004` Dream Classics candidate remains separate
and unavailable.
