# Unapproved listening candidates

These files are outside the Flutter asset bundle. Do not move them into the
runtime path, add them to pubspec, or call them production-approved without
explicit owner listening approval.

## Releaf Atmosphere II headroom candidate

| Measurement | Active source | Candidate |
| --- | ---: | ---: |
| Integrated loudness | -9.0 LUFS | -12.3 LUFS |
| True peak | +0.8 dBTP | -2.5 dBTP |
| Size | 5,646,537 bytes | 5,550,432 bytes |

Source: `assets/sounds/relief_02.mp3`. Candidate:
`audio-candidates/2026-09-11/atmosphere-ii-minus-3db.mp3`.

Processing: FFmpeg 7.1, static `volume=-3dB`, MP3 at 192 kbps; no limiter,
compression, voice, or other content added. MP3 re-encoding can introduce a small
additional level difference. Attenuation provides headroom but cannot repair any
distortion already baked into the source. Owner listening, level matching against
the other soundscapes, and loop-boundary review remain necessary.

Reproduction (choose a new output filename; `-n` refuses overwriting):

```text
ffmpeg -hide_banner -nostdin -n -i assets/sounds/relief_02.mp3 -map 0:a:0 -af volume=-3dB -c:a libmp3lame -b:a 192k audio-candidates/2026-09-11/atmosphere-ii-minus-3db.mp3
ffmpeg -hide_banner -nostdin -xerror -i <file> -af ebur128=peak=true -f null -
```

Both files decoded with exit 0 during measurement. Source SHA-256 was verified
unchanged before/after processing; hashes and measurements are preserved in
`atmosphere-ii-comparison.json`. Successful decoding is not content approval.

## Breathing candidates

No inhale/exhale candidate was generated. Fal sound-effect requests returned
HTTP 403 (exhausted balance). Existing runtime tones remain rejected. A future
audition must use natural gentle human inhale and longer calming exhale, with
silent holds/rests. No substitute narration is authorized.
