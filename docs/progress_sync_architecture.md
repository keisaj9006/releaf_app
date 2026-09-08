# Releaf Progress Sync Architecture

Status: design + local event foundation only  
Last reviewed: 2026-09-08

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
