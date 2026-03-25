-- ── 1. DENY ALL: tabele wewnętrzne bez RLS policies (service role only) ──────
-- TODO: uncomment after tables are created
-- CREATE POLICY "deny_jwt_access" ON brand_visual_guidelines  FOR ALL USING (false) WITH CHECK (false);
-- CREATE POLICY "deny_jwt_access" ON content_packs_marketing  FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON content_strategy         FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON generated_posts          FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON naomi_rate_limits        FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON optimization_log         FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON performance_reports      FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON reddit_config            FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "deny_jwt_access" ON video_queue              FOR ALL USING (false) WITH CHECK (false);

-- ── 2. reddit_activity: usuń starą permissive policy jeśli istnieje ──────────
DROP POLICY IF EXISTS "Service role full access" ON reddit_activity;

-- ── 3. three_am_wall: usuń nadmiarową/niebezpieczną politykę ALL (true) ──────
DROP POLICY IF EXISTS "authenticated_call_rate_limit_check" ON three_am_wall;

-- ── 4. Napraw mutable search_path w check_three_am_rate_limit ─────────────────
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
