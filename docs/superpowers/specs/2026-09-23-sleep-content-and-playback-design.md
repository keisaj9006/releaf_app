# Sleep content and playback design

## Intent

Elevate Sleep into a scalable Releaf product area without replacing the working
Sound, Meditation, subscription, routing or Emergency systems. The user should
eventually discover Stories, Nature, sleep-specific Meditations and Sleep Music
through one calm Sleep surface and resume reliable playback across the app.

## Content boundary

Sleep has exactly four categories: Stories, Nature, Meditations and Sleep Music.
`All` is a filter over those categories. Stories have exactly five editorial
collections: Dream Classics, Night Mysteries, Fiction Escapes, Wonder Journeys
and Drift Through History.

The existing `ReliefStory` and `StoryCatalog` types are the canonical Story
source. The Sleep registry owns cross-category editorial placement and
references canonical Story, Sound or Meditation IDs. It does not copy audio
paths, scripts or access rules from those catalogs. Missing production audio
remains an explicit non-playable state.

`ST-DC-004`, *The Princess and the Pea — A Rainy Night at the Palace*, is the
first registered Story. Its narrator display name is Theo Silk. Its final
duration, artwork, access decision and audio source remain unset until approved
production material arrives. ElevenLabs is a production tool only; the runtime
contains no provider dependency, API key or generation request.

## Playback boundary

The existing Sound controller and `audio_service` driver remain the starting
point. The playback boundary will gain an explicit finite/looping mode and a
content-neutral now-playing identity. Nature and Sleep Music continue to loop;
Stories stop at completion. Sleep Meditations keep their established separate
narration and ambience behavior.

Long-form progress is stored separately from immutable catalog metadata. It
records content ID, clamped position, optional current chapter, last-played time,
completion and favourite state. Story chapter data consists of stable chapter
IDs, labels and ordered start positions; chapter UI follows only after this
capability is tested.

## Discovery boundary

The Sleep page will read the registry for category filters, Featured/Tonight,
Continue Listening, Popular and Story collection rails. Cards resolve their
playback target through the registry, retain subtle Premium treatment and never
offer a start action for missing audio. The legacy Sound library stays reachable
and its routes remain valid.

Nature and Sleep Music remain narration-free. Stories and guided Sleep
Meditations may use their approved narration contracts. This intentionally
refines older broad documentation that said all Sleep must be voice-free; it does
not authorize narration in Nature or Sleep Music and does not unpark general
daytime Meditate for the 1.0 marketing surface.

## Failure and safety behavior

- Unknown catalog references fail validation and never render as playable.
- Seeking clamps to zero and the known duration; relative ten-second controls
  move exactly ten seconds before clamping.
- Missing Story audio is visible as coming soon/asset pending, with no fallback
  narrator or generated substitute.
- Premium access remains enforced by the existing entitlement layer.
- Emergency routes, data exclusion and free access remain untouched.
- Playback persistence remains local-first and does not imply cloud backup.

## Verification

Each milestone starts with focused failing tests, then runs formatting, focused
tests and `flutter analyze`. Full tests and an Android build run at meaningful
checkpoints. Hardware-only background, Bluetooth and lock-screen behavior stays
open until a production-equivalent device pass.

