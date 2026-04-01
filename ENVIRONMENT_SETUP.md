# SoberSteps Environment Separation: Dev vs Production

## Overview

SoberSteps uses strict **environment separation** between sandbox (dev) and production:

- **DEV (Sandbox)**: Local development, debug builds, test Supabase project
- **PROD (Production)**: Release builds, production Supabase project, Google Play

---

## 1. Build Flavors (Android)

### Dev Flavor
```bash
flutter build apk --flavor dev --release  # Creates app with .dev suffix
# Output: app-dev-release.apk
# Package: com.soberstepsod.soberstepsod.dev
```

### Prod Flavor
```bash
flutter build appbundle --flavor prod --release  # Production bundle
# Output: app-prod-release.aab
# Package: com.soberstepsod.soberstepsod
```

---

## 2. Environment Variables (Dart)

### Dev (Bundled with App)
- Loaded from: `assets/config.dev.env` (committed, safe)
- Supabase: **DEV project** (sandbox)
- Purpose: `flutter run`, local testing

### Prod (Secrets Only)
- Loaded from: GitHub Actions secrets (CI/CD pipeline)
- Supabase: **PRODUCTION project** (production)
- Never stored locally or committed

---

## 3. Secret Management

### Production Secrets (MUST NOT be in code)

| Secret | Storage | Purpose |
|--------|---------|---------|
| `CRON_SECRET` | GitHub Secrets + Supabase Vault | Edge Function webhook auth |
| `BREVO_API_KEY` | GitHub Secrets | Email sending (Brevo) |
| `SUPABASE_URL` | GitHub Secrets | Production database URL |
| `SUPABASE_ANON_KEY` | GitHub Secrets | Anon client API key |
| `REVENUE_CAT_KEY` | GitHub Secrets | Subscription management |
| `ONESIGNAL_APP_ID` | GitHub Secrets | Push notifications |
| `SENTRY_DSN` | GitHub Secrets | Error tracking |
| `ELEVENLABS_API_KEY` | GitHub Secrets | TTS (optional) |

### GitHub Secrets Setup

1. Go to: **Settings → Secrets and variables → Actions**
2. Create each secret with exact name (case-sensitive)
3. For `CRON_SECRET`: paste value from `/tmp/prod_secrets.txt` (not shown here)
4. Never expose secrets in logs, commit messages, or chat

### Supabase Vault Setup

1. Go to: **Supabase Console → Settings → Vault**
2. Add `CRON_SECRET` key with value from `/tmp/prod_secrets.txt`
3. Add `ADMIN_SECRET` key for webhook verification
4. Reference in Edge Functions: `Deno.env.get('CRON_SECRET')`

---

## 4. CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy-prod.yml
env:
  FLAVOR: prod
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  BREVO_API_KEY: ${{ secrets.BREVO_API_KEY }}
  CRON_SECRET: ${{ secrets.CRON_SECRET }}  # ← Injected at build time
  # ... other secrets
```

---

## 5. Local Dev Setup

### For Local Development (Not Production)

```bash
# 1. Copy template
cp .env.prod.local.example .env.prod.local

# 2. Fill in **DEV** values only (never production)
echo "SUPABASE_URL=https://dev-project.supabase.co" >> .env.prod.local
echo "SUPABASE_ANON_KEY=dev_anon_key_here" >> .env.prod.local

# 3. Run with dev flavor
flutter run --flavor dev  # Loads .env.prod.local for local testing
```

### Never Local Production

Production secrets SHOULD NOT be stored locally. They only exist in:
- GitHub Secrets (for CI/CD)
- Supabase Vault (for Edge Functions)

---

## 6. Verification Checklist

- [ ] `android/app/build.gradle.kts` has `flavorDimensions` (dev/prod)
- [ ] `.env.prod.local` is in `.gitignore` (verified)
- [ ] GitHub Secrets are set (CRON_SECRET, BREVO_API_KEY, SUPABASE_*, etc.)
- [ ] Supabase Vault has CRON_SECRET
- [ ] Production build uses `--flavor prod`
- [ ] Dev build uses `--flavor dev`
- [ ] CI/CD pipeline injects secrets via `${{ secrets.* }}`

---

## 7. Deployment Steps

### ETAP 1: Stable v1.0.0+1 (Today)
1. Commit: android config, migrations, constants
2. Generate fresh CRON_SECRET → GitHub Secrets + Supabase Vault
3. Deploy Supabase migrations
4. Deploy Edge Functions
5. Build release: `flutter build appbundle --flavor prod --release`
6. Upload to Google Play Console (Internal Testing)

### ETAP 2: Feature v1.0.1 (Tomorrow)
1. Fix memory leaks in providers
2. Complete http_client.dart
3. Test new screens (daily_self_act, inner_critic_log, self_compassion_hub)
4. Verify UI/UX matches design screenshots
5. Repeat ETAP 1 steps with v1.0.1+2

---

## 8. Security Notes

⚠️ **NEVER**:
- Commit `.env.prod.local` or production secrets
- Display secrets in logs or terminal output
- Share CRON_SECRET / API keys in chat or email
- Build production release without `--flavor prod`

✓ **ALWAYS**:
- Use GitHub Secrets for CI/CD
- Use Supabase Vault for Edge Function secrets
- Rotate secrets periodically
- Audit GitHub Secrets access logs
- Test in dev flavor first before prod

---

## Questions?

Contact: sobersteps@pm.me
