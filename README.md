# SoberSteps

Mobile app (Flutter + Supabase) focused on gentle daily sobriety support.

## Landing

- Website: [https://soberstepsdev.github.io/sobersteps-landing/](https://soberstepsdev.github.io/sobersteps-landing/)
- Waitlist: [Join here](https://soberstepsdev.github.io/sobersteps-landing/#waitlist)

## Stack

- Flutter / Dart
- Supabase (Postgres, Auth, Edge Functions)
- OneSignal (push notifications)
- RevenueCat (subscriptions)

## Prerequisites

- Flutter SDK installed and available in PATH
- Xcode (iOS) and/or Android Studio (Android)
- Supabase project (URL + anon key)
- Optional for local Edge Functions: Supabase CLI

## Configuration

Single source of truth: `docs/ENV_SETUP.md`

### 1) App runtime variables (`--dart-define`)

Required:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Optional:
- `REVENUE_CAT_KEY`
- `ONESIGNAL_APP_ID`
- `SENTRY_DSN`
- `DEEP_LINK_DOMAIN`
- `ELEVENLABS_API_KEY`

Example run:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=ONESIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID
```

### 2) Optional local `.env` files

The app also reads local env values in this order:
- `assets/config.env.example` (bundled defaults)
- `assets/config.env` (local override, not committed)
- `.env` (local override, not committed)

Template files:
- `.env.example`
- `assets/config.env.example`
- `supabase/.env.example` (Edge Function secrets reference)

Full end-to-end flow (local + CI + Supabase): `docs/ENV_SETUP.md`

## Local development

Install deps:

```bash
flutter pub get
```

Run analyzer:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run app:

```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Supabase

Schema and migrations:
- `supabase/migrations/`

Functions:
- `supabase/functions/notify_users/`
- `supabase/functions/naomi-feedback/`
- `supabase/functions/moderate_three_am_post/`
- `supabase/functions/send_moderation_email_brevo/`

Deploy is automated by GitHub workflow:
- `.github/workflows/supabase-deploy.yml`

### `notify_users` function

Used by:
- `.github/workflows/notify-users-cron.yml`

Required Supabase Edge Function secrets:
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`
- `CRON_SECRET`

The workflow calls:
- `type=checkin&hour=<0-23>` hourly
- `type=letter` at 08:00 UTC
- `type=path` at 09:00 UTC
- `type=milestone` at 20:00 UTC

## CI

- Flutter CI: `.github/workflows/flutter-ci.yml` (`pub get`, `analyze`, `test`)
- Supabase deploy: `.github/workflows/supabase-deploy.yml`
- Notification cron: `.github/workflows/notify-users-cron.yml`

## Process docs

- Release management: `docs/RELEASE.md`
- Changelog: `CHANGELOG.md`
- Contributing guide: `CONTRIBUTING.md`
- Code ownership: `.github/CODEOWNERS`
- Security policy: `SECURITY.md`

## Repo structure

- `lib/app/` app shell (`theme`, route table)
- `lib/config/` bootstrap/config initialization
- `lib/constants/` compile-time/runtime constants
- `lib/core/` shared core utilities (philosophy/supabase helpers)
- `lib/l10n/` localization strings
- `lib/models/` domain and DTO models
- `lib/providers/` state management (`ChangeNotifier`)
- `lib/screens/` UI modules (auth, check-in, community, milestones, return-to-self, etc.)
- `lib/services/` integrations and business services (Supabase, notifications, sync, purchases, encryption)
- `lib/widgets/` reusable UI components
- `test/` widget/unit tests
- `integration_test/` integration tests
- `supabase/` migrations + functions
- `.github/workflows/` CI/CD

## Task runner

Unified local commands are available via `Makefile`:

```bash
make help
```
