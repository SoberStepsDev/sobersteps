-- Enable RLS on automation tables (previously had rowsecurity=false)
-- These tables contain internal marketing/strategy data — no user access needed
ALTER TABLE automation_errors ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_strategy ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service role only" ON automation_errors FOR ALL USING (false) WITH CHECK (false);
CREATE POLICY "Service role only" ON automation_strategy FOR ALL USING (false) WITH CHECK (false);
