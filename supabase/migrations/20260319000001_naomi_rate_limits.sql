-- Per-user daily cap for naomi-feedback edge function (enforced in Edge + optional client UX)
create table if not exists naomi_rate_limits (
  user_id uuid not null references auth.users(id) on delete cascade,
  rate_date date not null,
  count int not null default 0,
  primary key (user_id, rate_date)
);

comment on table naomi_rate_limits is 'Tracks Edge Function naomi-feedback invokes per user per UTC date; updated only via service role.';

alter table naomi_rate_limits enable row level security;
