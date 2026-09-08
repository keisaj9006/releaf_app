# Releaf bundled audio standard

Last reviewed: 2026-09-08

## Scope

This standard covers audio committed under `assets/sounds/` and used by the
Sound and Sleep experiences.

## Ownership and provenance

- Releaf Atmosphere I and II are pre-existing Releaf library assets.
- Brown Noise, Pink Noise, White Noise, Soft Rain, Night Air, Deep Drift,
  Ocean Wash and Forest Canopy are generated from
  `tooling/audio/generate_sleep_assets.py`.
- The generator uses fixed seeds, synthetic noise and additive tones only.
  It contains no third-party samples or field recordings.
- Generated files are reproducible from source and are intended to be owned
  product assets rather than placeholders.

## Minimum technical quality

Every bundled looping MP3 must:

- decode successfully with ffprobe;
- be at least 60 seconds long;
- report a valid sample rate and channel count;
- remain loop-safe enough that the boundary is not an obvious transient;
- avoid claims that a particular audio frequency treats or cures sleep,
  anxiety or another health condition.

The main Flutter validation workflow enforces the decode and duration rules
for every `assets/sounds/*.mp3` file.

## Current generated targets

- Brown Noise — 120 s, mono, 44.1 kHz.
- Pink Noise — 120 s, mono, 44.1 kHz.
- White Noise — 120 s, mono, 44.1 kHz.
- Soft Rain — 180 s, stereo, 44.1 kHz.
- Night Air — 180 s, stereo, 44.1 kHz.
- Deep Drift — 180 s, stereo, 44.1 kHz.
- Ocean Wash — 180 s, stereo, 44.1 kHz.
- Forest Canopy — 180 s, stereo, 44.1 kHz.

## Product rules

- Sleep stays voice-free.
- Noise and nature tracks may be synthetic when the copy accurately describes
  them and the audio is owned.
- Do not invent Forest, Ocean, Fireplace, stories or music titles without a
  corresponding real asset.
- Musical content should be produced intentionally; a short placeholder loop
  must not be presented as premium long-form audio.
