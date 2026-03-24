# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog and follows Semantic Versioning (`MAJOR.MINOR.PATCH`).

## [1.0.0] — 2026-03-29

### Added
- **Sobriety tracking** — daily check-ins with mood, craving level, triggers
- **Milestone celebrations** — 1, 7, 30, 90, 180, 365 days with TTS audio
- **Community Wall** — anonymous posts: wins, hard moments, advice, milestones
- **Three AM Crisis support** — rate-limited, auto-moderated, crisis detection
- **Future Letters** — write to future self, scheduled delivery
- **Return to Self module** — Self-Hatred assessment (free); Perfectionism, Toxic Relationships (PRO)
- **Naomi AI companion** — powered by Claude API
- **Craving Surf** — 6 soundscapes (rain, ocean, forest, etc.)
- **Accountability Partner** — Family Observers with email invites
- **Karma Mirror** — community reputation & evening reflection
- **Trigger Tracker** — mood and craving pattern tracking
- **Savings & Health** — money/health metrics per substance
- **Offline sync** — full offline support with conflict resolution
- **PRO subscription** — RevenueCat, 7-day trial, $6.99/month
- **Streak Protection** — 2× per month grace day
- **Push notifications** — OneSignal integration
- **Deep linking** — sobersteps:// protocol
- **GDPR data export** — full user data export from settings
- **AB testing** — profiles.ab_variant support
- **Supabase RLS** — security on all 13 tables
- **Sentry monitoring** — error tracking and performance
- **Flutter CI workflow** — `pub get`, `analyze`, `test`
- **Edge Functions** — notify_users, naomi-feedback, moderate_three_am_post, send_moderation_email_brevo
- **Architecture/operations documentation** — ARCHITECTURE.md, SECURITY.md, RELEASE.md, runbooks

### Philosophy
Uśmiech ↔ Perspektywa ↔ Droga — bratni, szczery, bez terapeutycznego cukru.

### Security
- All SECURITY DEFINER functions with SET search_path = public
- Rate limiting: check-ins (1/day), posts (5/hour), three-am (5/day, 1 active)
- Email validation regex on email_leads
- flutter_secure_storage for auth tokens
- AES encryption for future_letters and RTS content
- Gitleaks secret scanning in CI/CD
- CodeQL SAST analysis

### Changed
- README expanded into complete setup/runbook

