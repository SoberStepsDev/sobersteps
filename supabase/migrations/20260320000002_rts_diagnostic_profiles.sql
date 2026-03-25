alter table profiles add column if not exists rts_diagnostic_score int check (rts_diagnostic_score is null or (rts_diagnostic_score >= 0 and rts_diagnostic_score <= 30));
alter table profiles add column if not exists rts_diagnostic_profile text;
