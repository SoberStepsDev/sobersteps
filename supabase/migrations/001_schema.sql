-- SoberSteps Complete Schema

-- PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text,
  sobriety_start_date date,
  substance_type text,
  checkin_reminder_hour int DEFAULT 21,
  emergency_contact_name text,
  emergency_contact_phone text,
  ab_variant char(1) DEFAULT 'A',
  created_at timestamptz DEFAULT now()
);

-- JOURNAL ENTRIES
CREATE TABLE IF NOT EXISTS journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  mood smallint CHECK (mood BETWEEN 1 AND 5),
  craving_level smallint CHECK (craving_level BETWEEN 0 AND 10),
  triggers text[],
  note text CHECK (length(note) <= 2000),
  created_at timestamptz DEFAULT now()
);

-- MILESTONES ACHIEVED
CREATE TABLE IF NOT EXISTS milestones_achieved (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  days int NOT NULL,
  achieved_at timestamptz DEFAULT now(),
  shared bool DEFAULT false,
  UNIQUE(user_id, days)
);

-- COMMUNITY POSTS
CREATE TABLE IF NOT EXISTS community_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category text CHECK (category IN ('wins','hard','advice','milestones')),
  content text CHECK (length(content) <= 1000),
  likes_count int DEFAULT 0,
  is_flagged bool DEFAULT false,
  flag_count int DEFAULT 0,
  flag_reason text,
  created_at timestamptz DEFAULT now()
);

-- FUTURE LETTERS
CREATE TABLE IF NOT EXISTS future_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content text CHECK (length(content) <= 2000),
  deliver_at date NOT NULL,
  delivered_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- THREE AM WALL
CREATE TABLE IF NOT EXISTS three_am_wall (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  resolved_at timestamptz,
  outcome_text text CHECK (length(outcome_text) <= 500),
  is_visible bool DEFAULT false,
  auto_moderated_at timestamptz
);

-- CRAVING SURF SESSIONS
CREATE TABLE IF NOT EXISTS craving_surf_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  soundscape_used text
);

-- FAMILY OBSERVERS
CREATE TABLE IF NOT EXISTS family_observers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscriber_user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  observer_email text NOT NULL,
  status text DEFAULT 'pending',
  invited_at timestamptz DEFAULT now(),
  accepted_at timestamptz
);

-- EMAIL LEADS
CREATE TABLE IF NOT EXISTS email_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  converted_at timestamptz
);

-- MODERATION QUEUE
CREATE TABLE IF NOT EXISTS moderation_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  row_id uuid NOT NULL,
  reason text,
  created_at timestamptz DEFAULT now()
);

-- =================== RLS POLICIES ===================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones_achieved ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE future_letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE three_am_wall ENABLE ROW LEVEL SECURITY;
ALTER TABLE craving_surf_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_observers ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_queue ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);

-- journal_entries
CREATE POLICY "journal_select_own" ON journal_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "journal_insert_own" ON journal_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "journal_update_own" ON journal_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "journal_delete_own" ON journal_entries FOR DELETE USING (auth.uid() = user_id);

-- milestones_achieved
CREATE POLICY "milestones_select_own" ON milestones_achieved FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "milestones_insert_own" ON milestones_achieved FOR INSERT WITH CHECK (auth.uid() = user_id);

-- community_posts
CREATE POLICY "posts_select_visible" ON community_posts FOR SELECT USING (is_flagged = false);
CREATE POLICY "posts_insert_own" ON community_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_update_own" ON community_posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "posts_delete_own" ON community_posts FOR DELETE USING (auth.uid() = user_id);

-- future_letters
CREATE POLICY "letters_select_own" ON future_letters FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "letters_insert_own" ON future_letters FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "letters_update_own" ON future_letters FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "letters_delete_own" ON future_letters FOR DELETE USING (auth.uid() = user_id);

-- three_am_wall
CREATE POLICY "three_am_select_resolved" ON three_am_wall FOR SELECT USING (resolved_at IS NOT NULL AND is_visible = true);
CREATE POLICY "three_am_insert_own" ON three_am_wall FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "three_am_update_own" ON three_am_wall FOR UPDATE USING (auth.uid() = user_id AND resolved_at IS NULL);

-- craving_surf_sessions
CREATE POLICY "surf_select_own" ON craving_surf_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "surf_insert_own" ON craving_surf_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "surf_select_count" ON craving_surf_sessions FOR SELECT USING (true);

-- family_observers
CREATE POLICY "observers_select_own" ON family_observers FOR SELECT USING (auth.uid() = subscriber_user_id);
CREATE POLICY "observers_insert_own" ON family_observers FOR INSERT WITH CHECK (auth.uid() = subscriber_user_id);

-- email_leads: anon insert allowed
CREATE POLICY "leads_insert_anon" ON email_leads FOR INSERT WITH CHECK (true);

-- moderation_queue: service role only (no policies for regular users)

-- =================== RPC FUNCTIONS ===================

CREATE OR REPLACE FUNCTION get_days_sober(p_user_id uuid)
RETURNS int
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT COALESCE(
    (SELECT (CURRENT_DATE - sobriety_start_date)::int FROM profiles WHERE id = p_user_id),
    0
  );
$$;

CREATE OR REPLACE FUNCTION check_checkin_rate_limit(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT NOT EXISTS (
    SELECT 1 FROM journal_entries
    WHERE user_id = p_user_id
    AND created_at::date = CURRENT_DATE
  );
$$;

CREATE OR REPLACE FUNCTION check_post_rate_limit(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT (
    SELECT COUNT(*) FROM community_posts
    WHERE user_id = p_user_id
    AND created_at > NOW() - INTERVAL '1 hour'
  ) < 5;
$$;

CREATE OR REPLACE FUNCTION check_three_am_rate_limit(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT (
    SELECT COUNT(*) FROM three_am_wall
    WHERE user_id = p_user_id
    AND resolved_at IS NULL
    AND created_at > NOW() - INTERVAL '6 hours'
  ) < 1
  AND (
    SELECT COUNT(*) FROM three_am_wall
    WHERE user_id = p_user_id
    AND created_at::date = CURRENT_DATE
  ) < 5;
$$;

CREATE OR REPLACE FUNCTION get_ab_variant(p_user_id uuid)
RETURNS char(1)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT ab_variant FROM profiles WHERE id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION flag_post(p_post_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE community_posts
  SET flag_count = flag_count + 1,
      is_flagged = CASE WHEN flag_count + 1 >= 3 THEN true ELSE is_flagged END
  WHERE id = p_post_id;
END;
$$;
