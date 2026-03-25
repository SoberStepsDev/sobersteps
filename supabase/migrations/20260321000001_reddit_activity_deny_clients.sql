-- reddit_activity is written by automation using service_role only; lock out anon/authenticated JWT.
DROP POLICY IF EXISTS "Service role full access" ON reddit_activity;
CREATE POLICY "deny_jwt_access" ON reddit_activity FOR ALL USING (false) WITH CHECK (false);
