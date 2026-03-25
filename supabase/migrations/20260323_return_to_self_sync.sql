-- Sync Return to Self schema with app/runtime expectations.
-- Add-only migration for production safety.

ALTER TABLE return_to_self_karma
  ADD COLUMN IF NOT EXISTS subcategory text;

ALTER TABLE return_to_self_karma
  ADD COLUMN IF NOT EXISTS response text;

ALTER TABLE return_to_self_karma
  ADD COLUMN IF NOT EXISTS response_date date;

ALTER TABLE return_to_self_naomi
  ADD COLUMN IF NOT EXISTS subcategory text;

ALTER TABLE return_to_self_naomi
  ADD COLUMN IF NOT EXISTS response text;

ALTER TABLE return_to_self_naomi
  ADD COLUMN IF NOT EXISTS response_date date;
