# Research scope triage for the 1.0 engineering handoff

This completes completion-plan Task 8's proposal step. It follows
`docs/DECISION_CONFLICTS.md` and the owner's locked decisions. It does not
rebaseline the release gate or authorize new product scope.

| Topic | Current implementation / evidence | Benefit and proposed direction | Cost / risk | 1.0 decision |
| --- | --- | --- | --- | --- |
| One-tap Reset | Home has `home-emergency-action` routing directly to canonical Emergency Calm; free/access/privacy protections have automated coverage. | Preserve immediate access; measure time-to-action in RC usability testing. | Low for testing; high if Emergency semantics are changed. | Retain current flow. No rename or access change. |
| Intent/time-first Home | Home need chips, persisted focus, recommendations and Continue already exist. Daily Insight now browses its 30-entry collection. | Validate existing recommendations and discoverability before adding more selectors. | Low for usability QA; medium for a new recommendation engine. | Existing implementation plus completed browsing/accessibility fixes. |
| Emergency naming | Consumer Emergency Calm and internal safety/access flags are implemented. | A calmer consumer name may merit an owner-led copy decision later. | Medium: copy/IA changes can obscure urgent access. | Defer; internal semantics stay locked. |
| Leaves simplification | Earned total persists; daily reward flags and third-pillar bonus exist. | Simpler presentation could reduce completion pressure. | High if reward persistence or idempotency changes. | No change without explicit authorization. |
| Four versus five tabs | Home / Reset / Brain / Sound remain persistent; Meditation and Sleep have their own Sound destinations. | Separate tabs could improve visibility, but change the approved primary model. | High routing/navigation regression risk. | Four tabs retained; no rebaseline. |
| Sleep mixer | Canonical 10-track catalog, playback, volume, deadline timer and fade exist. | Layered mixing/saved combinations are possible future expansion. | Medium/high: multiple audio lifecycles and new persistence. | Defer to 1.1 proposal; not a hidden P0. |
| Onboarding under two minutes | Router starts at Home; optional Home welcome/personalization and account flows already exist. | Time the first useful action in RC QA rather than creating another onboarding architecture. | Low for testing; medium for redesign. | Preserve existing flow; device/usability evidence remains external. |
| Privacy-minimal analytics | No dedicated usage-analytics feature is required by the gate; local progress is release truth. | A later measurement proposal can define the minimum events and retention before selecting tools. | Medium privacy/disclosure and operational cost. | No new SDK, user tracking or pseudo-clinical score for this pass. |
| Offline audio | Current playback uses bundled assets; missing approved recordings remain silent. | Bundled availability already avoids a download dependency for present content. | High for a separate download/cache manager, low value before approved content exists. | Preserve bundled playback; defer download infrastructure. |

Release impact: none of these optional expansions is required to close a current
canonical P0. Existing automated coverage and final production-equivalent device
QA remain the applicable engineering standard. Any later rebaseline must be an
explicit owner decision, not an inference from research.
