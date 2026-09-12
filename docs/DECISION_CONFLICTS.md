# Releaf — Decision Conflicts to Handle Deliberately

This file exists to prevent Codex from interpreting the 2026 Deep Research as a command to overwrite a mature codebase.

When a conflict below matters to the task, do not silently choose the research version. Preserve current release behavior and either:
- make a low-risk compatible improvement, or
- surface the scope decision to the owner.

| Topic | Current repo / release position | Deep Research recommendation | Working rule |
|---|---|---|---|
| Bottom navigation | Five-tab implementation; Sound library retained inside Sleep | Five separate product destinations | **Owner resolved, 12 September 2026:** exact approved order is Home / Reset / Meditate / Sleep / Brain. Legacy routes and access/data semantics are preserved. See the [canonical master prompt](plans/2026-09-12-releaf-master-prompt.md). |
| Brain portfolio | 15 registered games; Brain core DONE/QA | Launch six polished games | **Do not delete/rebuild.** Curate/polish existing analogues and daily rotation. Additional games are not a P0 release need. |
| Emergency naming | Internal Emergency semantics are access/privacy critical and DONE | Remove “Emergency” consumer framing | Consumer copy can be redesigned, but **preserve internal free-access/privacy/sync exclusions**. Product choice before broad rename. |
| Leaves reward loop | Accumulated total + daily per-pillar rewards + third-pillar bonus | Quiet accumulated progress; no multipliers/“perfect day” burden | No earned-progress loss. Bonus simplification is a product-polish candidate, not reason to destabilize release. |
| Sleep scope | Player/timer DONE/CONTENT; final sound selection pending | 3-layer mixer + saved mixes + fade as 1.0 | Treat mixer as high-value roadmap item. It only becomes a release blocker if the owner deliberately rebaselines 1.0. |
| Sleep content quantity | Canonical sound catalog currently has 10 real tracks | ~24–30 launch assets | Content expansion is desirable, but do not add fake/unlicensed placeholders or block release without rebaseline. |
| Meditation quantity | Player DONE/CONTENT; final approved Releaf Guide recordings dependency | ~36–45 structured sessions | Prioritize approved/complete content quality. Quantity is not a reason to synthesize unapproved voice or duplicate sessions. |
| Onboarding | Existing bootstrap/account/home flows must be audited | <2 min; first value before account/paywall | High-value target. Inspect actual current path before adding a second onboarding architecture. |
| Analytics | No dedicated analytics dependency is obvious in current `pubspec` | Instrument time-to-action/completion/replay etc. | Beta instrumentation is valuable. Choose privacy-minimal implementation deliberately; do not add invasive SDKs reflexively. |
| Offline downloads | Not a current canonical release gate | Research calls it a 1.0 capability | Roadmap candidate; do not widen P0 release scope without owner decision. |
| Releaf Now name | Existing product uses Reset/Relief routes and UI | Signature action named “Releaf Now” | Treat as naming/IA proposal; the underlying one-tap time-to-action principle can inform current Reset without forced rename. |
| “Six new research games” | Existing games overlap research skill categories | Signal Sweep, Sequence Garden, Switchback, Route Recall, Pattern Pulse, Plan Ahead | First map to existing games: e.g. Signal Scan, Sequence Echo, Rule Shift, Spatial/Labyrinth, Pattern Logic, Tower Plan. Audit mechanics before naming/adding. |
| Cloud progress | Primitives exist; runtime sync deferred/hardened; local is 1.0 truth | Cross-device continuity eventually premium | **Do not enable** until materialization + conflict tests satisfy current architecture/release gate. |
| Pricing | RevenueCat infrastructure exists; final Play config external | $8.99/mo, $59.99/yr, 7-day trial hypothesis | Do not hard-code research pricing. Use current configured products when real external configuration is available. |

## General conflict rule

If research says “required for 1.0” but `docs/release/releaf_1_0_release_gate.md` explicitly does not make it a blocker, the release gate wins unless the owner deliberately changes scope.

Research should improve priorities, UX quality and post-release roadmap—not cause a late uncontrolled rewrite.
