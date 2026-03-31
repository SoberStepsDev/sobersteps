-- Enable RLS on crash_log_rate_limits (security fix: was missing RLS)
-- Resolves: Supabase security advisor lint rls_disabled_in_public
ALTER TABLE public.crash_log_rate_limits ENABLE ROW LEVEL SECURITY;

-- Deny all direct client access — table is updated only via service role (Edge Function)
CREATE POLICY "deny_client_access" ON public.crash_log_rate_limits
  AS RESTRICTIVE
  FOR ALL
  TO authenticated
  USING (false)
  WITH CHECK (false);
