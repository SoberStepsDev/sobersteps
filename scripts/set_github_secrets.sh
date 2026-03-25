#!/usr/bin/env bash
# Ustaw wszystkie GitHub Actions secrets z .env + keystore
# Wymagania: gh CLI zalogowany (gh auth login) + uprawnienia secrets:write
# Użycie: ./scripts/set_github_secrets.sh

set -euo pipefail
REPO="SoberStepsDev/sobersteps"
DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$DIR/.env"
KEYSTORE="$DIR/android/app/upload-keystore.jks"

if ! command -v gh &>/dev/null; then
  echo "❌ Zainstaluj gh CLI: https://cli.github.com"
  exit 1
fi

load() { grep "^$1=" "$ENV_FILE" | cut -d= -f2-; }

echo "📦 Ustawianie sekretów dla $REPO..."

# Core
gh secret set SUPABASE_URL          --body "$(load SUPABASE_URL)"             --repo "$REPO"
gh secret set SUPABASE_PROJECT_REF  --body "kznhbcwozpjflewlzxnu"             --repo "$REPO"
gh secret set SUPABASE_ACCESS_TOKEN --body "$(load SUPABASE_ACCESS_TOKEN)"    --repo "$REPO"
gh secret set SUPABASE_DB_PASSWORD  --body "$(load SUPABASE_DB_PASSWORD)"     --repo "$REPO"
gh secret set SUPABASE_ANON_KEY     --body "$(load SUPABASE_ANON_PUBLIC_KEY)" --repo "$REPO"
gh secret set ONESIGNAL_APP_ID      --body "$(load ONESIGNAL_APP_ID)"         --repo "$REPO"
gh secret set REVENUE_CAT_KEY       --body "$(load REVENUE_CAT_SDK_API_KEY)"  --repo "$REPO"
gh secret set CRON_SECRET           --body "$(load CRON_SECRET)"              --repo "$REPO"
gh secret set CURSOR_API_KEY        --body "$(load CURSOR_API_KEY)"           --repo "$REPO"

# Android keystore (base64)
if [ -f "$KEYSTORE" ]; then
  gh secret set KEYSTORE_BASE64           --body "$(base64 -w 0 "$KEYSTORE")"  --repo "$REPO"
  gh secret set KEYSTORE_STORE_PASSWORD   --body "sobersteps2026"               --repo "$REPO"
  gh secret set KEYSTORE_KEY_PASSWORD     --body "sobersteps2026"               --repo "$REPO"
  echo "  ✅ KEYSTORE_BASE64 + passwords"
else
  echo "  ⚠️  keystore nie znaleziony: $KEYSTORE"
fi

echo ""
echo "✅ Ustawiono 12 sekretów automatycznie."
echo ""
echo "⚠️  Brakujące — dodaj ręcznie:"
echo "   • SENTRY_DSN               — sentry.io → Settings → Client Keys → DSN"
echo "   • PLAY_STORE_SERVICE_ACCOUNT_JSON — patrz docs/GOOGLE_SERVICE_ACCOUNT.md"
echo ""
echo "⚠️  Supabase Dashboard → Edge Functions → notify_users → Secrets:"
echo "   CRON_SECRET=$(load CRON_SECRET)"
echo "   ONESIGNAL_APP_ID / ONESIGNAL_REST_API_KEY / SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY"
