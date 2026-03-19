CREATE TABLE IF NOT EXISTS reddit_config (
  id int PRIMARY KEY DEFAULT 1,
  phase text DEFAULT 'warmup' CHECK (phase IN ('warmup','beta')),
  karma_threshold int DEFAULT 50,
  daily_comment_count int DEFAULT 5,
  subreddit_index int DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

INSERT INTO reddit_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS reddit_activity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp timestamptz DEFAULT now(),
  type text NOT NULL CHECK (type IN ('comment','post','failed')),
  subreddit text NOT NULL,
  post_id text,
  content text,
  karma_before int DEFAULT 0,
  status text DEFAULT 'posted'
);

ALTER TABLE reddit_activity ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service role full access" ON reddit_activity FOR ALL USING (true) WITH CHECK (true);
