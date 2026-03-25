-- Add demographic fields to profiles for social group analytics
-- All columns nullable (backward-safe, no existing data affected)

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS display_name text,
  ADD COLUMN IF NOT EXISTS birth_year smallint CHECK (birth_year BETWEEN 1920 AND 2010),
  ADD COLUMN IF NOT EXISTS gender text CHECK (gender IN ('male', 'female', 'non_binary', 'prefer_not_to_say'));

-- RLS: columns covered by existing profiles RLS policies (auth.uid() = id)
-- No new policies needed — existing SELECT/UPDATE policies apply to all columns
