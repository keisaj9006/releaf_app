# Releaf audio production and bundled asset standard

Last reviewed: 2026-09-12

## Scope

This is the shared production standard for Reset breathing cues, recorded Releaf
Guide narration and optional ambience, including Sound/Sleep assets under
`assets/sounds/`. It extends the existing standard rather than introducing a
second conflicting document. The owner-corrected
[master prompt](plans/2026-09-12-releaf-master-prompt.md) and
[canonical release gate](release/releaf_1_0_release_gate.md) remain authoritative.

## Ownership and provenance

- Releaf Atmosphere I and II are pre-existing Releaf library assets.
  That description is not a licence record: retain owner/source rights evidence
  before final production acceptance, and do not infer it from an existing file.
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

## Reset human breathing contract

- Preserve every existing method, stable ID, phase order and programmed duration.
  The [verified ten-method matrix](product/breathing-method-evidence-matrix.md)
  is the timing reference: actual 4–6 must not be silently changed to 6–4.
- Use professionally recorded human nasal inhale and slow natural exhale. Match
  recordings to the unchanged phase; do not extend a phase to fit the recording.
- Synthetic airflow, noise, leaves and ocean sounds cannot substitute for the
  human cue. They may only be separately controlled optional ambience.
- Reject wet mouth/saliva sounds, sniffing, gasping, harsh airflow, whisper/ASMR,
  clinical presentation and panic/hyperventilation-like delivery.
- Hold and rest phases contain no breathing cue. Soft optional ambience may
  continue; a hold tone, texture or bell needs separate explicit owner approval.
- Prepare at least three original, properly licensed or owner-approved natural
  candidate sets outside runtime assets. Prefer duration-matched recorded takes;
  reject noticeable stretching, looping seams, abrupt cuts and unnatural tempo.
- Cues require independent on/off and volume control, plus a fully silent mode.
  Preserve visual/captioned guidance, immediate stop and natural-breath options.
- The existing rejected cues remain disabled. Do not enable any new default until
  the owner auditions it on Samsung SM-S928B speaker and headphones and explicitly
  approves it. Human breathing is a sensory-design preference, not a scientific
  superiority claim; comfort varies between listeners.

## Recorded Releaf Guide contract

- Use only the approved female British-English Releaf Guide identity: natural,
  warm, calm and intimate, without whispering or ASMR. Baseline speed is 0.82x.
- The exact provider voice ID remains unavailable. The reference generation ID
  in `lib/core/audio/releaf_guide_contract.dart` is evidence for recovery, not a
  substitute voice ID or authorization to choose another narrator.
- Only `mindfulness-basics-2` currently has approved recorded narration (four
  assets). Missing approved narration stays silent/captioned; no device TTS,
  guessed narrator or alternate AI voice is permitted.
- Keep speech and ambience separate. Use the exported per-step scripts and
  timelines; do not stretch scripts to fill every second of the practice.
- Roughly 90–110 spoken words/minute is a review range, not an automatic target.
  Report how speech duration was measured. Words divided by the entire session
  duration, which includes practice silence, is not spoken WPM.

## Production measurements and mix review

New source masters should normally be 48 kHz. Preserve the existing 44.1 kHz
bundled deliverables unless a specific re-master is reviewed; this standard does
not authorize mass resampling, replacement or a new content approval.

Measure each source and candidate separately: codec, channels, sample rate,
duration, bytes, SHA-256, integrated LUFS and true peak in dBTP. Retain the tool
version, exact processing chain and measurement command. Decode success alone
does not establish loudness, loop quality, licensing or owner acceptance.

Starting mix targets from the approved programme, subject to measurement/listening:

| Property | Starting point / interpretation |
|---|---|
| Final true peak | Approximately <= -1 dBTP; investigate overshoot/clipping |
| Narration | Perceptual 0 dB reference, not a hardcoded digital peak |
| Ambience during speech | Approximately 12–16 dB below narration |
| Phase cue during speech | Approximately 8–12 dB below narration |
| Ducking | About 200–350 ms attack, 700–1200 ms release |
| Bed fade | About 1.5–3 seconds |
| Loop crossfade | About 2–4 seconds where appropriate; check the actual seam |

These are review starting points, not proven calming levels or instructions to
overwrite current runtime settings. A volume-slider value is not a LUFS or dB
measurement. Check the complete mix at quiet listening levels, on speaker and
headphones, and in a noisy-room case without forcing louder listening.

Keep measured respiratory cycles/minute, narrator WPM, music BPM, acoustic Hz,
LUFS and dBTP as separate fields. Do not infer medical effects from any of them.
Sleep remains narration-free regardless of shared mixing infrastructure.

## Intake record and acceptance

Each candidate needs an explicit record containing:

- stable candidate ID, source/master/deliverable paths and hashes;
- creator/source, recording date and original recording or licence/permission
  evidence reference (unknown must stay unknown);
- intended layer, method/phase and exact duration variant where applicable;
- processing history and technical measurements listed above;
- script/step and approved narrator reference for speech;
- status: candidate, rejected or owner-approved, with dated review evidence;
- Samsung speaker and headphone observations, separately from automated checks;
- reviewer-approved promotion mapping to runtime, if promotion is authorized.

Do not store private licences, credentials or personal correspondence in public
source control. Record a safe evidence reference instead. File presence, a valid
manifest, a decoded MP3 or a proposed filename cannot confer approval. Missing
evidence blocks that asset's promotion, not independent engineering work.

## Current evidence and remaining dependencies

The local [intake consistency checker](../tooling/audio/INTAKE.md) now checks
submitted evidence structure and actual file hashes, with separate measurement
and approval binding. It neither authenticates licences/consent nor grants
approval, and does not replace the existing catalog exporters or listening.

The [Meditation matrix](product/meditation-session-matrix.md),
[Reset blueprints](product/reset-session-production-blueprints.md) and existing
exporters record scripts/timelines and recording availability. They do not yet
certify per-file licensing, measured loudness or owner listening acceptance.

The [Atmosphere II comparison](../audio-candidates/2026-09-11/README.md) already
records active source -9.0 LUFS / +0.8 dBTP and candidate -12.3 LUFS / -2.5 dBTP.
The candidate remains outside runtime and unapproved; do not recreate or promote
it merely because it has headroom. The subsequent
[approved narration measurements](release/2026-09-12-approved-narration-measurements.md)
record all four Basics source files and separate Deep Drift ambience. Existing
FFmpeg was recovered from ignored local QA dependencies. These source measurements
do not replace rendered-mix or phone listening. The approved narration sources
are 24 kHz and remain unchanged.

Three licensed/original human breathing candidates, their duration variants,
the approved narrator identity recovery, missing recordings and actual owner
listening observations remain open dependencies. No existing breathing timing,
audio file, playback control, default mix or approval status changes here.
