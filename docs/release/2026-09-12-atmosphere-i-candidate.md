# Atmosphere I headroom candidate

Parent `97200e0`, branch `releaf-development`.

The source-level audit found Atmosphere I at -0.8 dBTP, above the approximately
-1 dBTP shared production reference. A separate unapproved candidate now measures
-1.8 dBTP / -13.9 LUFS, using -1 dB static attenuation and 192 kbps MP3 encoding.
Its 4,676,574 bytes and hashes are recorded in the
[candidate comparison](../../audio-candidates/2026-09-12/atmosphere-i-comparison.json).
The [README](../../audio-candidates/2026-09-12/README.md) records exact processing,
provenance limits, reproduction and required owner speaker/headphone acceptance.

Source unchanged: `bc4ad5ebfb6c5277919e47c906e0481de5484439afac2ee0b6db53ad0f853581`.
Candidate remains outside the Flutter asset bundle. No active asset, player,
breathing method or approval status changed. This headroom edit does not repair
quiet loop boundaries or certify final licensing, perceived quality or comfort.

## Verification

- FFmpeg encode with `-n`: exit 0; no overwrite.
- Full candidate `ebur128=peak=true` decode with `-xerror`: exit 0.
- Source hash checked before/after: identical.
- Both comparison hashes match current files; `audio-candidates` is absent from
  Flutter asset registration. Source/runtime asset declarations are unchanged.
- `flutter analyze`: no issues, exit 0, 14.7 seconds.
- `git diff --check`: passed; candidate metadata, documentation and scoped diff reviewed.
- No runtime change, so no fresh APK or full suite is required. Last full
  runtime verification remains 544 tests on `fac50ec`.
