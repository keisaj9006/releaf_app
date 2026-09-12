# Releaf canonical master continuation prompt — owner-corrected 12 September 2026

Canonical repository copy of the owner-supplied `Releaf_Master_Prompt_v2_breathing-preserved_2026-09-12.md`, with the subsequent explicit owner corrections incorporated. The Downloads source remains unchanged. This document specifies approved direction and future work; it does not claim that navigation, audio candidates or other remediation is already implemented.

Owner-approved primary destination order: **Home / Reset / Meditate / Sleep / Brain**. This deliberately supersedes the prior four-tab target; preserve route aliases, access and user data during implementation.

The corrected **RESET AUDIO — AUTHENTIC HUMAN BREATHING** section supersedes the source document's synthetic inhale/exhale and hold-texture proposal. Human cue recordings require owner audition/approval. Holds contain no breathing cue; synthetic hold sounds need separate owner approval.


## Important interpretation

Existing breathing methods are owner-approved product content. Their names, stable IDs and phase timings must be preserved. Research is used to improve how each method is explained, voiced, sonified, mixed, visualised and tested. Research must not silently replace, merge, reverse or delete the methods.

The following concepts must never be conflated:

| Concept | Unit | Meaning in Releaf |
| --- | --- | --- |
| Breathing phase timing | seconds | Inhale, hold, exhale and hold duration, e.g. 5–5 or 6–4 |
| Respiratory frequency | cycles/minute | Derived from the full cycle: `60 / total phase seconds` |
| Narrator delivery rate | words/minute and approved generator speed | How quickly guidance is spoken and how much silence follows |
| Musical tempo | BPM | Pulse/event rate of the ambience, if it has a perceptible beat |
| Acoustic frequency/spectrum | Hz | Tonal and noise content; not a proven “healing frequency” |
| Loudness | LUFS, dBTP and relative dB | Asset consistency, peak safety and balance between layers |

Examples, assuming no holds:

- 5 seconds inhale + 5 seconds exhale = a 10-second cycle = 6 cycles/minute.
- 6 seconds + 4 seconds also = a 10-second cycle = 6 cycles/minute, but it is a different phase ratio and therefore remains a different method.
- 4–6 and 6–4 are not interchangeable. Codex must inspect the existing model and UI to determine which phase comes first and must report any label/code mismatch instead of silently “correcting” it.

## Copy/paste prompt

```text
Continue Releaf only. Ignore MILTA completely.

Work only in C:\Users\joann\Releaf-Codex on releaf-development. Use the current clean synchronized HEAD of that branch as the source of truth. Do not reset to 16a0f2c or another historical checkpoint if later owner-approved Releaf work is already committed. Never change or merge main. Push only origin/releaf-development.

MISSION

Continue the evidence-based Releaf product-quality programme. Pause unrelated expansion and concentrate on:

1. the remaining Premium access defect;
2. separate Meditate and Sleep primary navigation;
3. bringing every Meditation card to the completeness standard of Learn the Basics / Mindfulness Basics;
4. turning Reset into Releaf’s flagship experience, with complete guidance, premium visuals, phase-synchronized audio and immediate, intuitive interaction.

This is not permission to redesign or replace the existing breathing protocols. Preserve the current methods, including 5–5, 6–4 and every other existing ratio/programme. Research must improve how those methods are delivered, not substitute different methods.

CURRENT APPROVED BASELINE — VERIFY AND PRESERVE

New work has already been performed after the earlier device checkpoint. Read the current Git history and these files before changing code:

- docs/release/2026-09-12-programme-verification.md
- docs/release/2026-09-12-reset-ambience-lifecycle.md
- docs/release/2026-09-12-reset-audio-handoff.md
- docs/release/2026-09-12-subscription-identity-isolation.md
- lib/core/subscription/subscription_controller.dart
- lib/features/brain/application/brain_training_controller.dart
- lib/features/relief/presentation/breathing_widget.dart
- lib/games/memory/memory_game_screen.dart
- lib/games/memory/memory_level_profile.dart
- lib/games/memory/memory_stats_screen.dart
- test/memory_board_progression_test.dart
- test/memory_level_profiles_test.dart
- test/memory_stats_test.dart
- test/reset_ambience_lifecycle_test.dart
- test/sound_loading_recovery_test.dart
- test/subscription_preview_test.dart

The duplicated filenames and duplicated code lines in the pasted ChatGPT summary may be display artefacts. Inspect the actual repository. Do not create duplicate files, duplicate test cases or duplicated declarations from that pasted text.

Treat the following as completed behavior unless current tests or code prove otherwise:

- stale Premium refresh results cannot cross an authentication identity boundary;
- obsolete purchase/restore results cannot grant Premium to a different identity;
- delayed refresh completion is harmless after controller disposal;
- Reset ambience lifecycle and Reset-to-audio handoff have dedicated implementation/tests/documentation;
- Sound loading recovery has dedicated coverage;
- Memory progression/profile/stats work already exists and is not part of this remediation unless a regression is caused by the navigation work;
- programme verification evidence already exists.

Do not rewrite those systems merely to make them look new. Extend them only where the current owner-reported defect proves a missing behavior. Preserve all passing regression tests.

OWNER DEVICE FINDINGS

1. Premium does not become usable after choosing an option/package. RevenueCat initializes and the Offering is available. Determine whether the owner only selected a plan, whether a purchase CTA/result is missing, whether CustomerInfo is not propagated, whether the entitlement identifier/configuration is mismatched, or whether route guards use stale state. Diagnose; do not assume.

2. Only Learn the Basics / Mindfulness Basics currently feels like a finished Meditation experience. The remaining cards need their own complete scripts, approved narration, captions, music/ambience, Mix behavior, art, preview metadata and polished player state.

3. Meditate and Sleep must be separate bottom-navigation destinations. “Sound” must not remain the name of a primary destination because it is mistaken for audio settings.

4. Reset must become the product Releaf is proud to lead with and that a psychologist could responsibly recommend as a wellbeing support tool. It currently lacks clarity, consistency and complete sensory guidance.

5. Existing breathing cards have to remain, including their current 5–5, 6–4 and other phase patterns. They need clearer lungs-based motion, dedicated inhale/exhale cue sounds, appropriate narration, music and accessibility — not replacement ratios.

6. 60s Grounding has unacceptable low-effort artwork and lacks a complete guided/audio experience.

7. Back to the Room does not explain the interaction and delays progression even if the user has completed the task immediately. Progress must become clear and user-driven.

NON-NEGOTIABLE PRODUCT CONSTRAINTS

- Preserve current breathing method names, stable IDs, order, phase durations and reward/access semantics.
- Preserve existing user data, local progress, Leaves/rewards, account isolation and public route/content IDs.
- Preserve the primary Joanna QA account and its Supabase/RevenueCat UUID. No account deletion.
- Preserve RevenueCat initialization via the ignored local --dart-define-from-file configuration. Never expose or commit a key.
- Preserve the approved female British-English Releaf narrator: natural, warm, calm and intimate; no whispering or ASMR. Preserve the existing approximately 0.82x baseline and narrator identity across Meditate, Reset and Emergency.
- Sleep remains a separate, non-narrated destination centred on music, nature soundscapes and noise options. Do not add a Sleep narrator.
- Narration, ambience/music and breathing cue SFX remain independent runtime layers.
- Emergency remains global, immediate, free and without marketing or a paywall.
- Preserve Releaf’s dark premium visual identity: deep navy/near-black/plum, soft translucent surfaces, champagne/gold, luminous sage and restrained violet. Controlled red is reserved for Emergency.
- Do not present missing recordings as available. “Captions only” remains honest until an approved recording exists.
- Do not claim that the product diagnoses, treats or cures anxiety, panic, trauma, addiction or sleep disorders.

AUTHORIZATION BOUNDARIES

- No real purchase, RevenueCat Test Store transaction, promotional entitlement grant, account deletion, production configuration mutation, paid media generation, production deployment or Play Store submission without fresh explicit owner authorization.
- Selecting a Premium plan must never fake an entitlement.
- Do not add a hardcoded QA Premium bypass.
- If final Premium E2E requires a zero-cost Test Store transaction or promotional grant, ask once for that exact action and continue all independent work in the meantime.
- Do not replace the approved narrator with a generic AI voice.
- Do not download unlicensed assets or copy competitor artwork, wording, audio or distinctive trade dress.

METHOD: FIRST ESTABLISH THE TRUE CURRENT STATE

1. Confirm branch, current HEAD, upstream synchronization and worktree state. Preserve unexpected owner work.
2. Read the canonical release gate, current state, roadmap, product-quality plan and all 2026-09-12 release evidence.
3. Review the complete Git range from checkpoint 16a0f2c to current HEAD. Build a concise “already completed / partially completed / still missing” matrix. Do not infer completion from filenames alone.
4. Run the existing focused tests for subscription identity, Reset ambience/audio handoff, Sound recovery and Memory progression before editing. Record the true baseline.
5. If Samsung SM-S928B is connected, capture safe screenshots/screen recording and redacted logcat reproducing the current Premium, Meditation and Reset problems. Never uninstall.
6. Inventory available capabilities once: Flutter/Android/ADB, ignored RevenueCat configuration, research/browser, approved narrator configuration, Canva/Figma/Fal or equivalent, licensed audio source and independent review agents.
7. Ask one batched question only for genuinely blocking external permissions. Continue every unblocked task.

RESEARCH TAXONOMY — NEVER MIX THESE VARIABLES

For all research notes and every session specification, use these exact separate fields:

A. BREATHING PROTOCOL
- inhale seconds;
- inhale-hold seconds;
- exhale seconds;
- exhale-hold seconds;
- full cycle duration;
- calculated cycles per minute;
- number of cycles/session;
- owner-approved existing label and stable ID.

B. VOICE PERFORMANCE
- approved narrator identity;
- generator/playback baseline, currently approximately 0.82x;
- measured spoken words per minute;
- phrase length;
- silence after each instruction;
- tone/prosody;
- pronunciation notes;
- caption timings.

C. MUSIC
- presence or absence of a perceptible pulse;
- musical tempo in BPM, if meaningful;
- event density;
- harmonic movement;
- instrumentation/timbre;
- loop duration and crossfade;
- intended emotional role.

D. ACOUSTIC SPECTRUM
- broad tonal/noise character in Hz bands where useful;
- pink/brown/other noise type where applicable;
- avoidance of piercing or fatigue-prone energy;
- no “healing frequency” claim for 432 Hz, 528 Hz or any single tuning.

E. LOUDNESS AND MIX
- narration LUFS/true peak;
- ambience LUFS/true peak;
- cue short-term level/peak;
- relative dB between narration, ambience and cues;
- ducking/fade behavior;
- default user settings;
- phone speaker and headphone listening notes.

The word “frequency” is ambiguous. Always write “breathing cycles/minute”, “music BPM” or “acoustic Hz” rather than using “frequency” alone.

Create a canonical breathing-method matrix based on the actual repository, not memory. Include every method. For example, if there are no holds:

- 5–5 = 5 s inhale + 5 s exhale = 10 s/cycle = 6 cycles/minute.
- 6–4 = 6 s + 4 s = 10 s/cycle = 6 cycles/minute, but a different ratio and therefore a different experience.

Do not assume whether 6–4 means inhale 6/exhale 4 or the reverse. Read the actual phase model and UI copy. If implementation, label and documentation disagree, report the exact mismatch and propose a correction for owner approval. Never silently reverse it to 4–6. If both 6–4 and 4–6 exist, preserve and distinguish both.

RESEARCH GUARDRAILS

Use primary/current research and record evidence strength, population and limitations.

- Music interventions show average stress-related benefits, but there is no universal best track, tuning, Hz value, BPM or volume.
- Slow-paced breathing near approximately six comfortable cycles/minute is a defensible common starting range, but effects vary and emotional outcomes are more modest than many marketing claims imply.
- A longer exhale has not shown a clear universal stress-reduction advantage over equal inhale/exhale in the available randomized comparison. Preserve the existing methods, but do not make superiority claims.
- Nature and gentle breath-like sonification are promising directions. The direct sonification evidence is preliminary and must be described as such.
- Human-like natural narration is preferable to a generic synthetic substitute. Preserve the approved voice.
- Meditation/breathwork can cause discomfort, dizziness, tingling or distress in some people. Every session needs choice, immediate stop and a return-to-natural-breath option.
- App volume percentages do not correspond to one real-world dB SPL across devices. Use LUFS/dBTP for asset consistency and test actual devices.

Minimum evidence sources:

- Music/stress meta-analysis: https://pubmed.ncbi.nlm.nih.gov/31167611/
- Slow-paced breathing meta-analysis: https://link.springer.com/article/10.1007/s12671-023-02294-2
- Breathing practice components review: https://pmc.ncbi.nlm.nih.gov/articles/PMC10741869/
- Equal versus extended-exhale trial: https://pmc.ncbi.nlm.nih.gov/articles/PMC10395759/
- Breath/nature sonification pilot: https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.623110/full
- Natural sounds synthesis: https://pmc.ncbi.nlm.nih.gov/articles/PMC8040792/
- Music tempo and physiological response: https://pubmed.ncbi.nlm.nih.gov/16199412/
- Voice-quality study: https://doi.org/10.1037/tmb0000089
- Meditation adverse-effects review: https://pubmed.ncbi.nlm.nih.gov/41176868/
- WHO safe listening: https://www.who.int/health-topics/hearing-loss
- RevenueCat entitlements/status: https://www.revenuecat.com/docs/customers/customer-info

Create/update these living documents, using existing equivalents rather than duplicating them:

- docs/research/2026-09-12-meditate-reset-evidence-review.md
- docs/product/breathing-method-evidence-matrix.md
- docs/product/meditation-session-matrix.md
- docs/product/reset-session-blueprints.md
- docs/audio_asset_standard.md (existing shared production standard)
- docs/plans/2026-09-12-meditate-reset-remediation.md

PRIORITY 0 — PREMIUM ACCESS DEFECT

Use systematic debugging. Build on the completed identity-isolation protections; do not replace them.

- Trace paywall load → package selection → purchase CTA → purchase/restore result → CustomerInfo → active entitlement identifier → SubscriptionController state → listeners/providers → route guards.
- Distinguish selecting a plan from actually activating an entitlement in both UI and code.
- Verify product-to-entitlement attachment and the exact entitlement identifier expected by the app. Do not mutate RevenueCat configuration without authorization.
- Verify that a valid returned/refreshed CustomerInfo immediately updates every consumer and unlocks eligible routes without app restart.
- Refresh appropriately on app resume and before entering Premium content while preserving caching/offline behavior.
- Keep a discoverable Restore Purchases action and honest success/no-purchase/error states.
- Add regression tests for selection-without-entitlement, successful state propagation, cancellation, restore, stale cache, wrong entitlement ID, logout/login and identity changes.
- Preserve and extend the tests proving obsolete refresh/purchase/restore results cannot cross identity boundaries.
- Log entitlement status and stable internal ID only in safe debug output. Never log keys, tokens, email, receipts or personal content.

PRIORITY 1 — PRIMARY INFORMATION ARCHITECTURE

Use exactly five bottom destinations:

1. Home
2. Reset
3. Meditate
4. Sleep
5. Brain

- Keep Emergency globally available outside these destinations.
- Keep Account/Profile behind the avatar/account entry.
- Remove “Sound” as a primary destination without removing playback capabilities.
- Place sleep soundscapes, nature sounds and pink/brown noise under Sleep.
- Keep ambience selection inside Mix for Meditate and Reset.
- Preserve old routes/deep links/public IDs through aliases or migration-safe redirects.
- Test selected-tab restoration, Android back behavior, mini-player continuity, deep links, text scaling and narrow screens.

PRIORITY 2 — SHARED AUDIO AND SESSION CONTRACTS

Build on the completed Reset ambience lifecycle, Reset audio handoff and Sound recovery work.

- Audit before refactoring. Preserve proven lifecycle/cancellation behavior.
- Maintain separate narration, ambience/music and phase-cue layers.
- Standardize pause/resume, audio focus, backgrounding, interruptions, exact seeking where applicable, timer expiry, cancellation and recovery semantics.
- Add an asset manifest validator for missing files, stable IDs, duration mismatch, captions, sample rate, loop metadata, provenance, licence and entitlement state.

Engineering listening baseline — validate rather than blindly hardcode:

- 48 kHz production sources;
- no clipping/clicks/sudden transients;
- final true peak approximately <= -1 dBTP;
- narration as the perceptual 0 dB reference;
- initial ambience target approximately 12–16 dB below narration while speech is present;
- initial phase-cue target approximately 8–12 dB below narration;
- smooth ducking, roughly 200–350 ms attack and 700–1200 ms release as a starting point;
- gentle 1.5–3 s bed fades and seamless 2–4 s loop crossfades;
- logarithmic user volume controls;
- independent mute/volume for voice, ambience and cues.

These values are production starting points, not scientifically guaranteed calming levels. Measure and listen on Samsung speaker, quiet headphones and in a noisy-room case. Record LUFS, dBTP and subjective findings.

PRIORITY 3 — MEDITATION COMPLETENESS

Inventory every actual Meditation card. Learn/Mindfulness Basics is the completeness benchmark, not text/audio to duplicate.

For every card define and implement or honestly mark the status of:

- stable ID/category/title;
- intended user need;
- duration/level;
- free/Premium policy;
- evidence-supported technique;
- complete script and silence plan;
- approved narrator recording;
- synchronized captions;
- unique music/ambience and Mix defaults;
- unique coherent visual/artwork;
- preview metadata;
- offline behavior;
- accessibility/safety;
- analytics and acceptance tests.

All guided cards should ultimately reach the same complete product standard as Basics, while remaining meaningfully different.

Until an approved recording exists:

- label the session Captions only;
- default captions on for that practice without overwriting the stored global preference merely by opening it;
- never imply Premium supplies unavailable narration;
- complete scripts, timing, caption segmentation and manifests so approved recording can be inserted without reworking the experience.

Narration:

- exact approved narrator only;
- approximately 0.82x established baseline;
- measure the result, with roughly 90–110 spoken words/minute as a review range, not an automatic transformation target;
- one instruction per sentence;
- meaningful silence;
- natural, warm, calm, non-whispered prosody;
- invitational language and eyes-open/stop options.

Music direction must be chosen per session intent, not by assigning one generic track:

- beginner/basic: warm low-motion pad, subtle air/leaves, generous silence;
- anxiety/difficult moment: predictable low-event bed and optional soft nature texture, no heartbeat-like pulse, bright chimes or suspense;
- body scan: non-metric warm ambience with minimal harmonic movement;
- focus: sparse neutral texture; a subtle 60–70 musical BPM implication may be prototyped, but must not be confused with breathing cycles/minute;
- compassion: warm organic low-mid texture without sentimental crescendo;
- unguided timer: silence by default with optional ambience.

No lyrics, abrupt transitions or unsupported frequency claims.

Continue card by card until every repository card has a complete production contract and shipped experience, or an honest externally blocked state. No generic filler and no fake completion.

PRIORITY 4 — RESET FLAGSHIP

Before changing every card, create a blueprint for each actual Reset card containing:

- owner-approved method/stable ID;
- exact breathing phases where relevant;
- calculated cycles/minute;
- user need/job-to-be-done;
- duration and rationale;
- evidence strength/limitations;
- safety copy;
- full phase timeline;
- narrator script and silence;
- voice WPM/prosody;
- musical BPM or explicitly “non-metric”;
- acoustic character in Hz/spectrum terms without magic-frequency claims;
- ambience/cue loudness and ducking;
- visual/interaction/haptics;
- reduced-motion and fully silent alternatives;
- interruption/offline recovery;
- completion action;
- automated/device acceptance tests;
- clear competitive advantage without copying competitors.

Implement one consistent Reset session shell for navigation, progress, phase label, captions, audio controls, pause/resume, immediate exit, optional haptics, reduced motion, lifecycle recovery and completion.

Consistency means one interaction language. Breathing cards use the shared lungs system; grounding/movement cards use intervention-specific central visuals inside the same shell.

BREATHING PROGRAMMES — PRESERVE METHODS

- Do not remove, rename, merge, reverse or replace 5–5, 6–4 or any other current protocol.
- Do not change phase durations based solely on a paper. Any proposed timing change requires a separate owner decision.
- Verify UI labels against the engine and tests.
- If a label is ambiguous, make inhale/hold/exhale explicit in the preview without changing the method.
- Distinguish methods through their actual ratio, purpose, guidance, sound, visuals and safety — not merely colour.

LUNGS VISUAL SYSTEM

- Replace unclear/inconsistent phase visuals with one elegant botanical-organic lungs system for every breathing card.
- Drive it from the actual session phase/timing model.
- Inhale visibly fills and expands the lungs; exhale visibly empties and contracts them.
- Start with an approximately 12–18% readable shape-envelope change, then tune on device.
- Show explicit phase text and time/progress. Never use colour alone.
- Holds remain visibly stable.
- Reduced motion uses a mostly static lung outline with changing fill/progress, phase text and optional audio/haptic.
- Use native Flutter vector/procedural motion or a carefully evaluated Rive asset. Never use a raster AI image as the timing mechanism.
- Confirm smooth rendering and exact phase synchronization on SM-S928B.

RESET AUDIO — AUTHENTIC HUMAN BREATHING

1. Preserve every existing breathing method, name, stable ID, order and exact phase timing, including 5–5, 6–4 and all other currently implemented methods. Never change, reverse, merge or remove a pattern. Verify the actual repository before describing which methods exist; a missing or mismatched label must be reported, not silently added or corrected.

2. Use authentic, professionally recorded human breathing: a calm, natural nasal inhale and a slow, natural exhale. Synchronize each recording precisely with the actual inhale/exhale phases and their programmed durations. A slow exhale must not extend or otherwise alter an existing programmed phase.

3. Do not substitute synthetic pink noise, generated airflow, leaf noise or ocean sounds for human breathing cues. Nature ambience may remain a separate optional background layer; it must never replace the breathing itself.

4. Reject recordings with wet mouth or saliva sounds, sniffing, gasping, harsh airflow, an intimate ASMR character, a medical/clinical character, or any sound resembling panic or hyperventilation.

5. Prepare at least three high-quality natural human breathing candidates for owner listening review. Use only original, properly licensed or owner-approved recordings. Document the source, creator, recording/processing history, licence or permission, date, file hash, duration, sample rate, measured loudness/true peak and approval status. Do not add unverified internet audio. Keep candidates outside active runtime assets until approved; unavailable recordings, licences or paid work are explicit dependencies, not permission to fabricate or substitute audio.

6. Where possible, use separate recordings or professionally recorded variants matching each existing method's phase durations. Avoid noticeable time-stretching, looping artefacts, abrupt cuts and unnatural tempo changes. Fit the recording to the unchanged protocol, never the protocol to the recording.

7. Keep human breathing cues on a separate runtime audio layer with independent on/off and volume controls and a completely silent mode. Narration and optional ambience/music remain independent layers. Users must be able to stop, mute or return to natural breathing immediately.

8. During an actual breath-hold phase, there must be no breathing sound. Optional background ambience may continue very softly. Do not add a synthetic hold texture, sound, tone or bell without separate explicit owner approval. Rest phases likewise receive no breathing cue.

9. Research may inform narration delivery, recording performance, mixing, loudness and safety; it must not change existing phase timings or be used to claim that natural human breathing recordings are scientifically superior. This is an owner-approved product and sensory-design requirement. Validate comfort through listening: some people may find human breathing sounds uncomfortable. Preserve clear stop/return-to-natural-breath guidance and a silent alternative.

10. Test the candidates on Samsung SM-S928B through both the phone speaker and headphones, and document actual listening observations. Do not select, ship or enable the final default until the owner has personally listened and explicitly approved it. Until then, rejected/unapproved breathing cues remain disabled; visual, captioned and fully silent guidance stays available. Do not claim device verification or owner approval before it actually occurs.

60S GROUNDING

- Replace the rejected low-effort visual and rebuild the full experience, not only the card image.
- Create three original premium visual directions in the established Releaf language and independently review them.
- Add immediate approved narration/captions, optional low-event nature ambience, clear interaction, feedback and completion.
- Make the Continue / I found it action available immediately. No arbitrary time lock.
- If the protocol cannot honestly fit a complete 5-4-3-2-1 sequence into 60 seconds, use a genuinely achievable 60-second sensory sequence or label the full version self-paced. Do not misrepresent duration or evidence.

BACK TO THE ROOM

- First frame: clearly state what the user should observe and provide a visible labelled action such as “I found one”.
- The action works immediately; progression follows user input, not elapsed time.
- If tap-anywhere remains, also provide a proper button and TalkBack action.
- Add approved narration/captions, optional restrained ambience, subtle haptic acknowledgement and a clear return.

OTHER RESET CARDS

No card may remain decorative, title-only or generic. Situational, non-breathing, grounding, movement, jaw/shoulder release and eye-focus sessions each require a specific safe mechanism, full guidance, purposeful visual/audio, accessibility and meaningful completion.

Use short video only when movement genuinely cannot be communicated with accessible vector steps and captions. Do not use low-effort or unlicensed media.

VISUAL AND MEDIA WORKFLOW

- Preserve the Releaf identity and mascot/character identity.
- No generic wellness clip art or decorative animation unrelated to the intervention state.
- Generate three lungs directions and three 60s Grounding directions, then create a contact sheet for one owner visual-direction review.
- Continue architecture, Premium diagnosis, scripts, tests and other unblocked work while visual feedback is pending.
- Use Canva for composition/system work and Fal/image generation for original atmospheric candidates if available. Figma may be used if already connected, but do not block the project on it.
- Use AI raster imagery only for atmospheric card/background art, never for functional phase animation.
- Use only owned, appropriately generated or licensed production audio. Shutterstock is optional for licensed SFX/music candidates. Mobbin is optional for interaction research only.
- Record source, licence, tool/prompt, date, creator, hash, duration, sample rate, measured loudness and approval status for every asset.
- No paid generation without authorization.

ACCESSIBILITY AND SAFETY ACCEPTANCE

Test at minimum:

- 200% text scale;
- small/narrow Android layouts;
- TalkBack labels/focus order/live phase announcements;
- minimum 48dp targets;
- contrast and no colour-only meaning;
- captions;
- reduced motion;
- fully silent mode;
- audio-focus loss/background/resume;
- immediate pause/stop/exit.

No user may be forced to close their eyes, hold their breath, breathe deeply, wait after completing an action, listen to cue sounds, use haptics or continue while uncomfortable. Include “return to your natural breath and stop if dizzy, tingly or uncomfortable” where appropriate without alarming routine users.

ENGINEERING EXECUTION

- Use systematic debugging for Premium.
- Use TDD for every behavior change: failing test, minimal implementation, refactor, focused verification.
- Work in small vertical milestones with conventional commits.
- Request independent review for subscription/access, navigation, audio lifecycle, breathing engine/visual synchronization, safety copy and major visual work.
- Preserve all existing passing tests and add focused regression coverage.
- At every checkpoint run formatting, flutter analyze, focused tests and the complete suite.
- Review the complete diff for unrelated/generated/credential-containing files before each commit.
- Build Android debug using the existing ignored local --dart-define-from-file configuration.
- If Samsung SM-S928B is connected, install only non-destructively:
  adb install -r build/app/outputs/flutter-apk/app-debug.apk
- Never uninstall. If replacement fails, report the full ADB error and stop only that step.
- Capture redacted screenshots/recordings/logs for every visible milestone.

CONTINUATION RULE

Do not stop because one document, test group, commit or milestone is complete. Update the living plan, commit/push the verified checkpoint only to releaf-development and continue with the next highest-priority unblocked item.

Stop only for an actual owner decision, exact approved narrator dependency, licence, paid action, RevenueCat transaction/configuration mutation, credential/connector, physical listening judgment or other external prerequisite. Batch blockers once and continue independent work.

CHECKPOINT REPORTS

For every milestone report:

- current HEAD and commit hash;
- what was already present versus newly changed;
- exact breathing methods preserved and confirmation that no ratio/timing/stable ID changed;
- tests/analyzer/build results;
- independent review findings;
- APK path and ADB result;
- device evidence;
- exact phone routes for owner review;
- remaining external dependencies.

FINAL REPORT

Include:

- exact Premium root cause and final state;
- before/after matrix for every Meditation and Reset card;
- canonical breathing-method matrix with phase seconds and calculated cycles/minute;
- separate voice WPM, music BPM, acoustic Hz/spectrum and loudness measurements;
- explicit confirmation that 5–5, 6–4 and every other existing method, ID and timing were preserved unless the owner separately approved a change;
- changed files and commit hashes;
- full verification evidence;
- asset provenance/licences;
- APK/device results and remaining blockers.
```
