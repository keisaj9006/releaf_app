# CI full audio decoding

Parent `4f0aa1e`, branch `releaf-development`.

The bundled Sound CI audit previously queried duration, bitrate, sample rate
and channels using ffprobe. These metadata checks do not fully decode every
audio packet. The step now also requires ffmpeg and runs a full decoder pass
with `-xerror`, retaining the existing duration/sample-rate checks and bounded
execution time. Metadata errors and decode errors have distinct diagnostics.

```text
timeout 30s ffmpeg -v error -nostdin -xerror -i "$file" -map 0:a:0 -f null -
```

This checks all ten current `assets/sounds/*.mp3` tracks. It is not a new
licensing, loudness, loop-comfort or owner-approval gate, and does not scan
separate narration/cue subdirectories under this particular workflow step.
No asset, application behavior, signing or billing configuration changed.

## Verification

- Created an ignored corruption fixture by zeroing bytes 100000–299999 of a
  copy of Brown Noise; the source remained unchanged. The new decoder command
  rejected it with native Windows exit `-1094995529` (invalid audio data).
- The unchanged original decoded with exit 0 using the same command.
- All ten current bundled Sound files fully decoded with the new ffmpeg
  arguments: exit 0 for every file.
- Initial YAML helper could not run because Python's `yaml` module is absent.
  Used the project's existing Dart `package:yaml` instead; workflow parsed and
  the exact audio step was extracted successfully. No dependency installed.
- Git Bash `bash -n build/ci-audio-step.sh`: exit 0.
- `flutter analyze`: no issues, exit 0, 13.7 seconds.
- `git diff --check`: passed; full scoped workflow/documentation diff reviewed.
- No APK/full-suite rerun is needed for this
  CI-only change. Last complete runtime suite remains 544 tests on `fac50ec`.

This is local command verification. The Ubuntu Actions run after push must
supply its own execution result; no remote CI PASS is implied here.
