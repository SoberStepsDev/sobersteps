-- Return to Self tables + content_policy_accepted on profiles
-- All tables have RLS: auth.uid() = user_id

alter table profiles add column if not exists content_policy_accepted boolean default false;

-- Return to Self Progress (4 types × 30-day path)
create table if not exists return_to_self_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  type text not null check (type in ('awareness','distance','repair','integration')),
  day int not null check (day between 1 and 30),
  completed boolean default false,
  created_at timestamptz default now()
);
alter table return_to_self_progress enable row level security;
create policy "Users own their progress" on return_to_self_progress
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Path Entries (reflections per day)
create table if not exists return_to_self_path_entries (
  id uuid primary key default gen_random_uuid(),
  progress_id uuid references return_to_self_progress(id) on delete cascade not null,
  practice_type text not null,
  reflection_encrypted text,
  created_at timestamptz default now()
);
alter table return_to_self_path_entries enable row level security;
create policy "Users own their path entries" on return_to_self_path_entries
  for all using (
    exists (select 1 from return_to_self_progress p where p.id = progress_id and p.user_id = auth.uid())
  )
  with check (
    exists (select 1 from return_to_self_progress p where p.id = progress_id and p.user_id = auth.uid())
  );

-- Streak ("Dni bez samobiczowania")
create table if not exists return_to_self_streak (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null unique,
  streak_days int default 0,
  last_check timestamptz default now()
);
alter table return_to_self_streak enable row level security;
create policy "Users own their streak" on return_to_self_streak
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Mirror Sessions (day 7/14/21/28)
create table if not exists return_to_self_mirror_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  duration_sec int not null default 0,
  timestamp timestamptz default now()
);
alter table return_to_self_mirror_sessions enable row level security;
create policy "Users own their mirror sessions" on return_to_self_mirror_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Karma Mirror (evening question + history)
create table if not exists return_to_self_karma (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  answer_encrypted text,
  timestamp timestamptz default now()
);
alter table return_to_self_karma enable row level security;
create policy "Users own their karma" on return_to_self_karma
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Naomi Mode (4 rotating questions + feedback)
create table if not exists return_to_self_naomi (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  question_type text not null,
  answer_encrypted text,
  feedback text,
  created_at timestamptz default now()
);
alter table return_to_self_naomi enable row level security;
create policy "Users own their naomi" on return_to_self_naomi
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Wall of Strength (anonymous, raw feed)
create table if not exists return_to_self_wall (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  content text not null,
  timestamp timestamptz default now(),
  anonymous boolean default true
);
alter table return_to_self_wall enable row level security;
create policy "Anyone can read wall" on return_to_self_wall
  for select using (true);
create policy "Users own their wall posts" on return_to_self_wall
  for insert with check (auth.uid() = user_id);
create policy "Users delete own wall posts" on return_to_self_wall
  for delete using (auth.uid() = user_id);
