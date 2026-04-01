# SoberSteps CI/CD Deployment Guide

## Environment Variables Setup (GitHub Secrets)

Add the following secrets to GitHub (Settings → Secrets and variables → Actions):

### Required for Development Builds
```
SUPABASE_URL=https://kznhbcwozpjflewlzxnu.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ANTHROPIC_API_KEY=<retrieve from Supabase Vault>
```

### Required for Production Builds
```
SUPABASE_URL_PROD=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY_PROD=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ANTHROPIC_API_KEY_PROD=<retrieve from Supabase Vault>
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
```

### Optional (for automation)
```
ONESIGNAL_APP_ID=your-onesignal-id
REVENUE_CAT_KEY=your-revcat-key
```

---

## GitHub Actions Workflow Example

Create `.github/workflows/flutter-build.yml`:

```yaml
name: Flutter Build & Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: |
          flutter test test/services/
          flutter test integration_test/

      - name: Build APK (Dev)
        if: github.ref == 'refs/heads/develop'
        run: |
          flutter build apk \
            --dart-define=FLAVOR=dev \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }} \
            --dart-define=ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }}

      - name: Build APK (Prod)
        if: github.ref == 'refs/heads/main'
        run: |
          flutter build apk --release \
            --dart-define=FLAVOR=prod \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL_PROD }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY_PROD }} \
            --dart-define=ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY_PROD }} \
            --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: sobersteps-apk
          path: build/app/outputs/apk/release/app-release.apk
```

---

## Local Development Build

```bash
# Dev build (uses .env)
flutter pub get
flutter run --flavor dev

# Dev build with manual dart-defines
flutter run \
  --dart-define=ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# Production build (requires all --dart-define flags)
flutter build apk --release \
  --dart-define=FLAVOR=prod \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY_PROD \
  --dart-define=ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY_PROD \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
```

---

## API Key Security Best Practices

### ✅ DO
- Store API keys in GitHub Secrets, Supabase Vault, or environment files
- Rotate keys regularly (especially after developer changes)
- Use `--dart-define` for production values (never hardcode)
- Use `flutter_dotenv` for local dev (load from .env, gitignored)
- Audit API key usage in logs (should never appear in plain text)

### ❌ DON'T
- Commit API keys to git (even in .env if not gitignored)
- Expose keys in CI/CD logs (use `secrets.*`)
- Use same key for dev and production
- Share keys via email or chat
- Leave expired/unused keys active

---

## Verifying Secrets in CI/CD

The workflow should never output secrets. Verify with:

```bash
# List secrets (doesn't show values, only names)
gh secret list

# After deploy, check logs don't contain key fragments
# CI automatically masks secret values in output
```

---

## Troubleshooting

**Build fails with "anthropic_key_missing"**
→ Check GitHub Secrets are set correctly
→ Verify `--dart-define=ANTHROPIC_API_KEY=...` in build command

**OAuth redirect fails**
→ Verify AndroidManifest.xml has `com.patryk.sobersteps://login-callback`
→ Check Supabase console: Authentication → Redirect URLs includes this value

**Tests fail locally but pass in CI**
→ Ensure .env file is gitignored (never commit dev secrets)
→ Run `flutter pub get` before tests
→ Check Flutter version matches CI (3.16.0+)

---

## Next: Continuous Deployment

Once CI/CD is stable, add CD pipeline:
1. Auto-upload APK to Google Play Console
2. Release notes from git tags
3. Sentry release tracking
4. Notification to Slack on deploy

See: `IMPLEMENTATION_REPORT.md` for code changes.
