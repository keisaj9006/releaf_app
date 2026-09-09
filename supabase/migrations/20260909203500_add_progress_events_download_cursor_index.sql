create index if not exists progress_events_user_created_at_event_id_idx
  on public.progress_events (user_id, created_at asc, event_id asc);

comment on index public.progress_events_user_created_at_event_id_idx is
  'Supports stable progress sync download paging by server cursor (created_at, event_id).';
