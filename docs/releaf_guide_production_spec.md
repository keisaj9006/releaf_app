# Releaf Guide — Production Voice Specification

## Decision — voice locked 6 September 2026

System TTS is a fallback only. Releaf's premium guided experience uses one consistent, pre-rendered female Releaf Guide voice.

The owner-selected voice is now the production baseline. Reference generation ID: `d730719be8654c93bddd639a96da7417`.

Canonical delivery speed: **0.82x**. Generate narration at 0.82 in the voice provider when supported. When the approved provider does not expose numeric speed control, apply pitch-preserving 0.82 mastering before bundling the asset. Never alter narration playback speed in Flutter.

The voice applies to **Meditate**, guided Reset experiences, and Emergency guidance where voice is enabled. **Sleep is voice-free** and must contain only sleep audio/music/nature sound content.

## Voice identity

- Female
- Native or highly natural British English
- Perceived age: approximately early 30s to early 40s
- Warm low-mid register
- Soft, grounded, intimate delivery
- Calm without sounding sleepy unless the session is explicitly for sleep
- Reassuring without sounding therapeutic, clinical, parental, or patronising
- Natural breath and phrasing
- No radio/podcast presenter cadence
- No advertising intonation
- No exaggerated whisper or ASMR style
- No dramatic emotional acting

## Delivery

The listener should feel that one calm person is sitting nearby and guiding them, not that software is reading instructions.

### Pace
- Slow conversational base
- Short phrases
- Natural sentence-final fall
- Deliberate silence after instructions
- Never rush lists
- Do not over-emphasise keywords
- Avoid identical rhythm from sentence to sentence

### Silence
Silence is part of the product, not dead air.

Typical pattern:
1. short instruction
2. 1–2 seconds of natural breathing room
3. longer practice silence appropriate to the exercise
4. next cue only when useful

Longer sessions should generally contain a lower narration density than short introductory sessions.

## Session profiles

### Beginner / Foundations
- slightly more guidance
- clear transitions
- reassuring orientation
- frequent but brief cues

### Focus
- concise, neutral instructions
- less soothing than sleep
- longer quiet windows for practice

### Anxiety / Settling
- slower delivery
- no urgency
- avoid promising calm
- permissive language

### Evening / settling
- softer energy
- longer gaps
- reduced verbal density toward the end
- still clearly guided; do not turn the delivery into whisper/ASMR

### Sleep
No Releaf Guide narration. Sleep is a voice-free audio destination.

## Recording / generation workflow

### Production path after voice lock
1. Use the owner-selected Releaf Guide voice consistently across the guided library.
2. Deliver at **0.82x speed**, using native provider control where available or pitch-preserving offline mastering before bundling.
3. Use real Releaf scripts with intentional punctuation and short phrasing; silence belongs in the session timing, not as filler words.
4. Export final sessions as clean isolated voice.
5. Edit breath/noise only when distracting; do not sterilise natural speech.
6. Master all narration to a consistent loudness.
7. Export narration separately from ambience.
8. Mix dynamically in-app so users retain independent Guide/Ambience controls.
9. QA every generated session for naturalness, pronunciation, cadence, clipping, and comfort before shipping.

### Scalable synthetic path
If a verified professional voice clone is used:
- the voice owner must create/verify the clone under the provider's rules;
- training material must be recorded in the exact Releaf meditation style;
- use long-form/high-fidelity synthesis rather than realtime/low-latency models;
- export and QA every generated session before shipping;
- never synthesize directly on the user's device for core content.

## File structure

Recommended asset convention:

assets/narration/releaf-guide/<meditation-id>/<step-number>.mp3

Example:

assets/narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3
assets/narration/releaf-guide/mindfulness-basics-2/02-notice.mp3

The player already supports recorded narration per MeditationStep and falls back to system TTS only when a recorded asset is unavailable.

## Acceptance test

A recording is not premium-ready unless:
- listener identifies the voice as female without ambiguity;
- it remains comfortable for at least 10 minutes;
- pauses sound intentional rather than generated;
- no sentence has obvious TTS-like emphasis or cadence;
- consonants are clear at low playback volume;
- ambience never masks words;
- pause/resume does not overlap voice layers;
- the same guide identity is consistent across the library;
- at least one real-device blind listener cannot reliably identify it as synthetic from delivery alone, if synthetic production is used.

## Brand principle

Releaf Guide should become an audio brand asset in the same way the launcher icon and visual language are brand assets. Consistency matters more than having many narrator options at launch.
