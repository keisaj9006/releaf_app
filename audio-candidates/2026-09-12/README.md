# Unapproved Atmosphere I headroom candidate

Prepared from repository source on `97200e0`, 12 September 2026. Outside Flutter
runtime assets. Do not register, replace the active asset or call this approved
until the owner listens on Samsung SM-S928B speaker and headphones and explicitly
accepts the exact candidate hash.

## Objective comparison

| Measurement | Active source | Candidate |
|---|---:|---:|
| Integrated loudness | -12.7 LUFS | -13.9 LUFS |
| True peak | -0.8 dBTP | -1.8 dBTP |
| Bytes | 3,318,994 | 4,676,574 |

Source: `assets/sounds/relief_01.mp3`. Candidate:
`audio-candidates/2026-09-12/atmosphere-i-minus-1db.mp3`.
Source and candidate hashes are in `atmosphere-i-comparison.json`.

Processing: existing local FFmpeg 7.1, static -1 dB attenuation, MP3 encoding at
192 kbps. No limiter, dynamics processing, voice, loop edit, sample or generated
content added. The extra loudness change comes from re-encoding; this is lossy
processing, not restoration. A larger output does not imply improved fidelity.

The source is a pre-existing Releaf library asset. Final rights/source evidence
is still required; this record does not invent a licence or creator attribution.
Both the source and this derivative remain subject to that production gate.

## Reproduction

Choose a new filename. `-n` refuses to overwrite an existing candidate.

```text
ffmpeg -hide_banner -nostdin -n -i assets/sounds/relief_01.mp3 -map 0:a:0 -af volume=-1dB -c:a libmp3lame -b:a 192k audio-candidates/2026-09-12/atmosphere-i-minus-1db.mp3
ffmpeg -hide_banner -nostdin -xerror -i audio-candidates/2026-09-12/atmosphere-i-minus-1db.mp3 -map 0:a:0 -af ebur128=peak=true -f null -
```

Encode and full candidate measurement exited 0. The original source hash was
checked before and after and is unchanged. Source measurements come from
`docs/release/2026-09-12-sound-source-loudness.md` for that identical hash.

## Remaining acceptance

- Source rights evidence, owner listening and final level matching remain open.
- This improves headroom only. The quiet source boundary remains; see
  `docs/release/2026-09-12-sound-loop-boundaries.md`. No seamless-loop claim.
- No device verification occurred. Do not promote it based on decoding or meters.
- No breathing audio or Releaf Guide narration was produced or substituted.
