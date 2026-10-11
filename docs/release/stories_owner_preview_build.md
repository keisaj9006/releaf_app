# Relief Stories owner-preview build

The three long-form Story masters are rights-pending production assets. They are
therefore **not committed to GitHub** and are not included in ordinary CI APKs.
The owner-preview build overlays verified local masters, builds an APK and then
removes those masters from the working tree automatically.

## Verified input

Use either the full delivery ZIP or its `APP_DELIVERY` directory. It must contain:

- `ST_TS01_BEYOND_THE_GATE_v01_128k.m4a` — 32:50.667
- `ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a` — 36:38.292
- `ST_L05_COMPUTER_v01_128k.m4a` — 20:45.000

The build script verifies the exact SHA-256 of every master and, when `ffprobe`
is available, checks duration, 48 kHz sample rate and stereo channel count.

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
APK. The local M4A copies are deleted automatically after success or failure.

## Release boundary

This APK is for owner/device review only. The three Stories must not be promoted
to a public store build until rights, editorial approval and final release access
are recorded. The pending `ST-DC-004` Dream Classics candidate remains separate
and unavailable.
