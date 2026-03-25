-- Performance: composite indexes on high-frequency query patterns
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_created
  ON journal_entries(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_community_posts_user_created
  ON community_posts(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_three_am_wall_user_created
  ON three_am_wall(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_milestones_achieved_user_days
  ON milestones_achieved(user_id, days);

-- Prevent duplicate progress entries per user/type/day
ALTER TABLE return_to_self_progress
  ADD CONSTRAINT uq_rts_progress_user_type_day
  UNIQUE (user_id, type, day);
