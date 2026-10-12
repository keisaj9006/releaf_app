# Relief Stories — actual owner-upload intake, 12 October 2026

Starting branch: `releaf-development` at
`bf09937be60ed8d84f43ce7666e00c4dafd644b4`. Its Flutter P0 Validation run
`38224526730` was independently read as completed/success. This is prior-commit
evidence, not a result for the input-contract change documented here.

## Actual supplied media

The owner uploaded `Relief-Stories-Audio-Delivery-Pack-v2(2).zip` directly. Its
size is 85,229,350 bytes. Only the three exact M4A filenames were extracted;
macOS resource-fork files were ignored. Each source file was hashed and probed,
and the entire audio stream was decoded using:

```bash
ffmpeg -v error -nostdin -xerror -i INPUT.m4a -map 0:a:0 -f null -
```

All three full decoder passes completed with exit 0 and no error output.
No resampling, trimming, mastering or re-encoding was performed.

| File | Bytes | Duration (s) | Sample rate | Channels | SHA-256 |
| --- | ---: | ---: | ---: | ---: | --- |
| ST_TS01_BEYOND_THE_GATE_v01_128k.m4a | 32063702 | 1970.666667 | 48000 | 2 | e060325cab7eb37128430e33103688f288b24208463f8dd1efb36cc3d87961cf |
| ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a | 36378762 | 2198.291667 | 48000 | 2 | b2f549476bab0e948ceb82ba886a873ac43497ef723753db5a736cc1bb36cbb8 |
| ST_L05_COMPUTER_v01_128k.m4a | 20596293 | 1245.000000 | 48000 | 2 | 3b9801a65c76d9052624135a430cf26369842d586d50737b21fe49cbf0341982 |

## Reproduced mismatch and bounded correction

The original builder blob `1bedf55a6010c995c4e0ad3ee0a59b5ce0912dc6` was
restored locally and its Git blob hash verified. With the real owner input it
failed at the first Story with exit 65 / SHA-256 mismatch. Its 44.1 kHz metadata
and three hashes described different bytes, not this supplied pack.

The existing private-builder pins are deliberately updated to the actual upload;
strict SHA-256 validation, duration tolerance, temporary-asset restoration and
APK-entry audit remain in place. The recordings are unchanged. The matching
Dart/Python contract fixtures and build runbook use the same measured values.
No runtime application code, public discovery, access policy or signing setup is
changed in this batch.

## Verification in this session

- Updated Python fixtures were run against the old builder first: 3 failures,
  caused by the old hashes rejecting the new expected input; 2 tests passed.
- After the configuration-only correction: all 5 existing Python shell-flow
  tests passed. These tests use synthetic archives and Flutter/hash/probe doubles.
- `bash -n` passed.
- The corrected builder was then run against the **actual** M4A input with real
  SHA-256 and ffprobe commands. All three input checks passed. It subsequently
  stopped with exit 69 because Flutter is absent; its cleanup removed the
  temporary Story assets. This is an input-validation result, **not an APK build**.
- Flutter analysis, the focused Dart tests and the full suite for this change
  require the new CI run. Do not inherit success from the preceding SHA.

## Remaining boundary

This session has Java and ffmpeg, but no Flutter/Android SDK; direct outbound DNS
for downloading the build environment is unavailable. No actual owner-audio APK
was produced by this checkpoint. The audio has not been uploaded to GitHub or
any public artifact. Device playback, listening/editorial approval, rights and
public release remain open. A separate installable preview application ID is not
authorised by this checkpoint and has not been introduced.
