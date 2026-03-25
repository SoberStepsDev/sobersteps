-- Linter: rls_policy_always_true (email_leads INSERT)
DROP POLICY IF EXISTS "leads_insert_anon" ON email_leads;
DROP POLICY IF EXISTS "anon_insert_email_leads" ON email_leads;
DROP POLICY IF EXISTS "leads_insert_validated" ON email_leads;

CREATE POLICY "leads_insert_validated" ON email_leads
FOR INSERT
WITH CHECK (
  length(email) BETWEEN 3 AND 320
  AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
);

-- Linter: function_search_path_mutable (SECURITY DEFINER)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ab_variant char(1) DEFAULT NULL;

CREATE OR REPLACE FUNCTION get_days_sober(p_user_id uuid)
RETURNS int
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT (CURRENT_DATE - sobriety_start_date::date)::int FROM profiles WHERE id = p_user_id),
    0
  );
$$;

CREATE OR REPLACE FUNCTION check_checkin_rate_limit(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
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
SET search_path = public
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
SET search_path = public
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
SET search_path = public
AS $$
  SELECT ab_variant FROM profiles WHERE id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION flag_post(p_post_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE community_posts
  SET flag_count = flag_count + 1,
      is_flagged = CASE WHEN flag_count + 1 >= 3 THEN true ELSE is_flagged END
  WHERE id = p_post_id;
END;
$$;
