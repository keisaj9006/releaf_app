# Relief Stories build recovery — 12 October 2026

## Verified starting failure

At `311e4bc5a6d8952d7d70e895e0b7728b990b43d4`, Flutter P0 Validation
run `38179789930`, job `114589717150`, failed the full suite with 774 passed,
one skipped and one failure:

`test/stories_preview_test.dart` — `dedicated Stories screen stays usable at 200 percent text`

The reported error was a RenderFlex overflow of 44 pixels on the right. The
preceding analysis, focused Brain/Reset tests and audio-defined configuration
test had passed. APK/AAB steps were skipped; this was not a completed build.

## UI and configuration recovery

`3de1c9b9b9eb6fe5d706866f10407e67cf1ed770` changes only the Stories header,
its regression coverage, the focused CI command and the owner-preview runbook:

- Header controls wrap when they cannot share one row; the count text can wrap.
- The user's 200% text scale is preserved, not clamped or visually scaled down.
- The original failing test remains and now checks control bounds and text scale.
- A new test scrolls to all three Story controls at 320 x 640 / 200% text.
- CI runs the existing private-build focused screen tests with bundled-audio and
  Premium defines, then resets compilation state for the ordinary full suite.
- The runbook matches the pinned v2 44.1 kHz stereo durations; input hashes stay
  unchanged.

In run `38222892642`, job `114723206282`, analysis, the focused owner-preview
screens and the full Flutter suite passed. At the time of preparing this note,
Android artifact production was still in progress; no artifact completion is
claimed by this note. Refer to the actual run result for final artifact status.

## Local builder recovery

The previous `unzip -l | grep -q` audit could fail with SIGPIPE under `pipefail`
even when the entry existed. A synthetic 4,000-entry archive reproduced an
upstream exit code of 141. The complete unmodified builder then rejected the
valid synthetic archive with exit 70.

The builder now consumes the full APK entry list before exact fixed-string
matching and publishes the owner-preview output only after every entry passes.
An invalid/incomplete candidate no longer replaces the previous output. The
existing pinned hashes, format checks and temporary-audio cleanup are retained.

Five subprocess regression tests were executed against the actual shell script.
Before the fix, three failed; after the fix, all five passed. `bash -n` passed.
The locally tested script/test Git blob hashes match the committed contents.
The same Python tests are added to Flutter P0 Validation:

```bash
python3 -m unittest discover -s tool/stories -p 'test_owner_preview_builder.py' -v
```

They cover a large archive, a missing Story entry, an input-hash rejection, a
Flutter build failure and an invalid archive. Each checks relevant output/asset
preservation. **These are shell-flow tests using synthetic files and isolated
Flutter/hash/metadata doubles, not an Android build or production audio test.**

## Remaining owner-preview boundary

The three actual M4A masters remain private and uncommitted. UI/configuration
validation and public CI APKs do not establish that a private owner-preview APK
contains the recordings. Completion still requires an accessible local delivery
pack, a Flutter/Android build environment, running the local builder, checking
the resulting APK/audio bytes and owner/device playback review. Do not publish
private masters or a private-audio APK as public GitHub artifacts.

`ST-DC-004` remains separate and unavailable. Production signing, rights/editorial
approval, Play billing/distribution and final physical-device gates are unchanged.
