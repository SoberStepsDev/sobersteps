# GitHub Actions — wymagane sekrety (nie commituj wartości)

| Sekret | Użycie |
|--------|--------|
| `CURSOR_API_KEY` | **Wymagany** dla `rls-security-review.yml` i `test-coverage-cron.yml` — wywołanie [Cloud Agents API](https://cursor.com/docs/background-agent/api/overview) (`https://api.cursor.com/v0/agents`). Utwórz klucz w [Cursor Dashboard](https://cursor.com/dashboard) (Cloud Agents / ustawienia API — klucz w formacie `key_…`). W `curl` używany jako użytkownik Basic Auth, hasło puste: `-u "$CURSOR_API_KEY:"`. Ustaw w GitHub: **Settings → Secrets and variables → Actions → New repository secret**. Lokalnie: `gh secret set CURSOR_API_KEY --repo OWNER/REPO` (wklej wartość po monicie). |
| `SUPABASE_URL` | Pełny URL projektu, np. `https://xxxx.supabase.co` — workflow `notify-users-cron.yml` |
| `SUPABASE_PROJECT_REF` | Sam `ref` (segment przed `.supabase.co`) — `supabase-deploy.yml` |
| `SUPABASE_ACCESS_TOKEN` | CLI Supabase |
| `SUPABASE_DB_PASSWORD` | `db push` |
| `CRON_SECRET` | Ten sam string co secret Edge Function `notify_users`; workflow wysyła `Authorization: Bearer <CRON_SECRET>` |
| `ONESIGNAL_APP_ID` | Klient Flutter (push) — też w `release-build` / `release-publish` jako `--dart-define` |
| `REVENUE_CAT_KEY` | **Public** SDK key RevenueCat (Play / App Store w dashboardzie) — w buildach CI jako `--dart-define`; nigdy secret `sk_…` w aplikacji |
| `ONESIGNAL_REST_API_KEY` | Tylko backend / skrypty — **nie** dodawaj do workflow Flutter ani do repo |

Lokalny Flutter: `.env` (gitignored) lub `--dart-define=SUPABASE_URL=...` / `SUPABASE_ANON_KEY=...` / `ONESIGNAL_APP_ID=...` / `REVENUE_CAT_KEY=...` (patrz `assets/config.env.example` / `.env.example`).
