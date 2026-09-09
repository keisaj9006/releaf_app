create table public.progress_events (
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text not null,
  schema_version smallint not null default 1,
  kind text not null,
  entity_id text not null,
  occurred_at timestamptz not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),

  primary key (user_id, event_id),

  constraint progress_events_schema_version_v1
    check (schema_version = 1),

  constraint progress_events_event_id_valid
    check (
      length(btrim(event_id)) between 1 and 200
    ),

  constraint progress_events_entity_id_valid
    check (
      length(btrim(entity_id)) between 1 and 200
    ),

  constraint progress_events_kind_allowed
    check (
      kind in (
        'brainSessionCompleted',
        'meditationCompleted',
        'meditationFavoriteChanged',
        'meditationOpened',
        'resetSessionCompleted'
      )
    ),

  constraint progress_events_payload_object
    check (jsonb_typeof(payload) = 'object'),

  constraint progress_events_favorite_payload
    check (
      case
        when kind = 'meditationFavoriteChanged' then
          payload ? 'favorite'
          and jsonb_typeof(payload -> 'favorite') = 'boolean'
        else true
      end
    ),

  constraint progress_events_reset_duration_payload
    check (
      case
        when kind = 'resetSessionCompleted' then
          jsonb_typeof(payload -> 'durationSeconds') = 'number'
          and (payload ->> 'durationSeconds')::numeric > 0
          and (payload ->> 'durationSeconds')::numeric =
              trunc((payload ->> 'durationSeconds')::numeric)
        else true
      end
    ),

  constraint progress_events_brain_score_payload
    check (
      case
        when kind = 'brainSessionCompleted' and payload ? 'score' then
          jsonb_typeof(payload -> 'score') = 'number'
        else true
      end
    )
);

create index progress_events_user_occurred_at_idx
  on public.progress_events (user_id, occurred_at desc, event_id desc);

comment on table public.progress_events is
  'Append-only normal Releaf progress events. Emergency usage is intentionally excluded from the client event schema and cloud sync.';

alter table public.progress_events enable row level security;

revoke all on table public.progress_events from anon, authenticated;
grant select, insert on table public.progress_events to authenticated;

create policy "Users can read own progress events"
  on public.progress_events
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert own progress events"
  on public.progress_events
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
