alter table public.progress_events
  add constraint progress_events_excludes_emergency_reset
  check (
    not (
      kind = 'resetSessionCompleted'
      and lower(btrim(entity_id)) = 'emergency-grounding'
    )
  );

comment on constraint progress_events_excludes_emergency_reset
  on public.progress_events is
  'Emergency usage is intentionally excluded from standard Releaf progress sync, even when represented as a generic Reset completion.';
