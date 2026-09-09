# Releaf Progress Sync Architecture

Status: local event foundation + inactive transport + server schema; runtime reconciliation remains disabled  
Last reviewed: 2026-09-09

## Current product truth

Releaf authentication is live, but Brain, Reset and Meditation progress is
currently local to the device. The app must continue to say this until a cloud
transport and conflict-tested merge layer are actually shipped.

The sync design is local-first. Cloud availability must never block a game,
meditation completion, favorite toggle or other local action.

## Why simple state copying is unsafe

Copying SharedPreferences values directly to Supabase would create ambiguous
conflicts:

- Brain history is a list of sessions and can be unioned only when events can
  be deduplicated.
- Meditation favorites support both add and remove, so a set union would
  resurrect items the user unfavorited.
- Meditation recents currently have ordering but legacy entries have no
  timestamps.
- Leaves are a reward balance. Merging totals with sum, union or max can all
  produce incorrect balances or duplicate rewards.

Therefore the cloud model is event-based rather than "latest JSON wins".

## Local event journal

Schema version: `progress.sync.events.v1`

Initial event kinds:

- `brainSessionCompleted`
- `meditationCompleted`
- `meditationFavoriteChanged`
- `meditationOpened`
- `resetSessionCompleted`

Each newly created event uses its own cryptographically secure random 128-bit
nonce inside the opaque event id.

Releaf deliberately does **not** persist a device/client instance identifier for
event creation. This keeps cross-device collision risk negligible without
introducing a stable device fingerprint that could correlate different
accounts.

Each event contains:

- globally unique client event id;
- kind;
- entity id;
- UTC occurrence time;
- small JSON payload.

The journal is additional metadata. Existing local progress remains the
immediate source of UI state.

## Merge rules

### Brain sessions

Merge by event id using set union.

A completed session remains a separate historical event. Raw task score stays
task-specific and is never converted into an IQ or clinical score.

Recommended server uniqueness:

`PRIMARY KEY (user_id, event_id)`

### Meditation completed

Completion is monotonic.

If any valid completion event exists for a session, that session is completed.
There is no "uncomplete" event.

### Meditation favorites

Favorites are mutable.

Resolve the latest `meditationFavoriteChanged` event for each session by:

1. `occurred_at`;
2. deterministic event-id tie-break when timestamps are equal.

The payload contains:

`{"favorite": true|false}`

Do not merge favorites using set union.

### Meditation recents

Future recents are derived from timestamped `meditationOpened` events.

Order by newest valid occurrence time and keep the product-defined maximum
number of recent sessions.

Legacy recents without timestamps should not be invented as precise historical
events.

## Reset completions

Normal Reset sessions use an append-only local completion history with:

- completion event id;
- Reset session id;
- UTC completion time;
- actual active duration.

The same completion id is also used as the sync event id so future cloud
inserts are idempotent.

Reset completion history is intentionally separate from the daily Relief leaf
reward. A user can complete multiple Reset sessions in one day while the
pillar reward is still granted at most once.

Emergency sessions are deliberately excluded from Reset completion history and
sync journaling. The fact that a user opened or completed Emergency support is
more sensitive than ordinary wellbeing progress and should not be uploaded by
the standard progress pipeline.

This exclusion is defence-in-depth rather than a UI convention: the canonical
Reset flow skips journaling, the local completion/sync stores reject the
Emergency entity id, and the Supabase table rejects a generic
`resetSessionCompleted` row whose entity is `emergency-grounding`.

### Reset merge rule

Merge Reset completions by event id using set union, the same way as Brain
session history. Do not collapse multiple completions of the same Reset into a
single boolean.

## Leaves

Leaves are intentionally excluded from the first sync schema.

Before cloud sync can include Leaves, rewards need an immutable ledger such as:

- reward event id;
- reward source;
- reward date / occurrence time;
- base reward;
- bonus reward;
- deduplication rule.

The displayed balance should then be derived from ledger events rather than
merged as a mutable integer.

## Legacy-device migration

When cloud progress is eventually enabled for an existing user:

### Brain

Existing `BrainSessionRecord` items have timestamps and scores.

Backfill them with deterministic legacy event ids derived from:

- game id;
- completed-at timestamp;
- score;
- stable duplicate occurrence index when required.

This preserves existing history instead of syncing only newly completed games.

### Meditation completed

Legacy completed ids have no completion timestamp.

At first sync, create a baseline snapshot event using the migration timestamp.
Mark it as a legacy snapshot in payload; do not pretend this is the historical
completion time.

### Meditation favorites

Create one baseline favorite-state event per currently favorited session at the
migration timestamp.

An item absent from the legacy favorite set should not generate a synthetic
"false" event.

### Meditation recents

Do not backfill legacy recents with invented timestamps.

New opens after event journaling begins will naturally populate synced recents.

### Reset

Reset did not previously maintain per-session completion history. Do not invent
historical Reset completions from the daily `reliefDone` reward flag.

Only genuine completions recorded after the Reset completion journal ships
should enter the standard event history.

Emergency usage remains excluded.

### Leaves

Do not migrate a local total into the event journal until reward-ledger rules
exist.

## Proposed Supabase table

A future migration can use an append-only table similar to:

- `user_id uuid not null references auth.users(id) on delete cascade`
- `event_id text not null`
- `schema_version int not null`
- `kind text not null`
- `entity_id text not null`
- `occurred_at timestamptz not null`
- `payload jsonb not null default '{}'`
- `created_at timestamptz not null default now()`

Primary key:

`(user_id, event_id)`

RLS:

- authenticated users can select only their own rows;
- authenticated users can insert only rows where `user_id = auth.uid()`;
- normal client code does not update another event in place.

Server-side validation should constrain allowed event kinds and payload shape.

## Deterministic projection foundation

Before runtime cloud sync is enabled, Releaf uses a pure projection reducer to
turn an unordered union of immutable progress events into deterministic product
state.

The projection:

- deduplicates exact events by event id;
- fails closed when the same immutable id carries conflicting content;
- orders Brain and Reset histories by occurrence time and event-id tie-break;
- derives monotonic Meditation completion;
- resolves Meditation favorites by latest timestamp, then event id;
- derives newest unique Meditation recents with the product limit;
- excludes forbidden Emergency Reset events before they can affect state.

The reducer performs no network access and writes no local state. Runtime sync
must not be enabled until cloud download, local materialization and cursor
advancement are built around this deterministic layer.

## Upload behaviour

1. Local action completes and persists first.
2. Event is appended to the local pending journal.
3. If authenticated and cloud transport is available, pending events are sent
   idempotently.
4. Server accepts duplicates safely via the composite primary key.
5. Successfully acknowledged event ids are removed from the pending journal.
6. Failed uploads remain pending and retry later.

No foreground action waits on network success.

## Download / reconciliation behaviour

A future sync session will:

1. fetch cloud events after the user's sync cursor;
2. merge them with local known events;
3. derive Brain and Meditation state from merge rules;
4. update local materialized state;
5. advance the cursor only after successful local persistence.

## Account deletion

Progress rows must cascade with `auth.users` deletion. The existing
delete-account path must therefore delete all sync data without requiring a
second client-side cleanup call.

## User-facing privacy / copy

Until cloud transport ships:

- continue to say progress remains on this device;
- do not call Account a progress backup;
- do not imply cross-device continuity.

When cloud sync ships, copy must distinguish:

- account identity / Premium;
- synced progress;
- any data intentionally remaining device-only.
