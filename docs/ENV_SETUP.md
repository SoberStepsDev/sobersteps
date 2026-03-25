# Environment Setup (Single Source of Truth)

This document defines the end-to-end env flow for app runtime, local overrides, CI, and Supabase functions.

## 1) Flutter app runtime (required)

Pass secrets at build/run time via `--dart-define`.

Required:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Common optional:
- `REVENUE_CAT_KEY`
- `ONESIGNAL_APP_ID`
- `SENTRY_DSN`
- `DEEP_LINK_DOMAIN`
- `ELEVENLABS_API_KEY`

Example:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=ONESIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID
```

## 2) Local optional env files

App-side loader order:

1. `assets/config.env.example` (bundled defaults)
2. `assets/config.env` (local override)
3. `.env` (local override)

Recommended local setup:

```bash
cp assets/config.env.example assets/config.env
cp .env.example .env
```

Then fill only local values (never commit secrets).

## 3) GitHub Actions secrets

Repository secrets are documented in `.github/SECRETS.md`.

Core secrets used by workflows:
- `SUPABASE_URL`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_DB_PASSWORD`
- `CRON_SECRET`
- `CURSOR_API_KEY` (for automation workflows)

## 4) Supabase Edge Functions secrets

Set in Supabase Dashboard -> Edge Functions -> Secrets.

For `notify_users`:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`
- `CRON_SECRET` (identyczny jak `CRON_SECRET` w GitHub Actions)

Reference template: `supabase/.env.example`

## 5) Safety rules

- Never commit real secrets.
- Keep `.env` and `assets/config.env` local-only.
- Use CI secrets for automation and deployment.
- Rotate compromised keys immediately and update relevant services.
