-- notification_prefs: sync from app to backend for push scheduling
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS notification_prefs jsonb DEFAULT '{"daily_checkin":true,"milestone":true,"streak":true,"letter":true,"community":false,"night":false}'::jsonb;
