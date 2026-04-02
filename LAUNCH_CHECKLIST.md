# SoberSteps — Launch Checklist 29.03.2026

**Data wygenerowania:** 2026-03-25
**Status:** Gotowy do wykonania przez właściciela konta
**Cel:** Launch 29 marca — wszystkie poniższe punkty muszą być zamknięte lub świadomie zaakceptowane.

---

## ✅ Naprawione automatycznie (w kodzie)

| # | Co | Plik |
|---|-----|------|
| 1 | **iOS auth callback** — dodano `CFBundleURLTypes` z scheme `com.patryk.sobersteps`; bez tego magic link / OAuth na iOS nigdy nie otwierał aplikacji | `ios/Runner/Info.plist` |
| 2 | **supabase/config.toml** — dodano `notify_users` (verify_jwt=false) i `send_moderation_email_brevo` (verify_jwt=true) | `supabase/config.toml` |
| 3 | **release-build.yml** — dodano `--dart-define=SENTRY_DSN` do buildów Android i iOS; bez tego Sentry było wyłączone w produkcji | `.github/workflows/release-build.yml` |
| 4 | **SECRETS.md** — dodano dokumentację sekretów `SUPABASE_ANON_KEY` i `SENTRY_DSN` | `.github/SECRETS.md` |

---

## 🔴 BLOKER: Wymagane działanie właściciela — PRZED 29.03

### 1. Supabase: Migration repair (PRIORYTET 1)

**Problem:** 11 migracji jest zastosowanych w DB ale nie jest trackowanych przez Supabase CLI.
Efekt: `supabase db push` przez workflow CI wyrzuci błąd lub spróbuje re-aplikować migracjejeśli divergencja nie zostanie naprawiona.
**DB jest poprawna** — wszystkie tabele istnieją, RLS włączone — to wyłącznie problem historii CLI.

**Wykonaj lokalnie** (wymaga `SUPABASE_ACCESS_TOKEN` w env lub w `.env`):

```bash
export SUPABASE_ACCESS_TOKEN=<twój_token_sbp_...>

# Link projektu
supabase link --project-ref kznhbcwozpjflewlzxnu

# Oznacz wszystkie untracked migracje jako "applied" (DB już je ma)
supabase migration repair --status applied 20260311000001
supabase migration repair --status applied 20260313000001
supabase migration repair --status applied 20260318000001
supabase migration repair --status applied 20260319000001
supabase migration repair --status applied 20260320000001
supabase migration repair --status applied 20260320000002
supabase migration repair --status applied 20260321000001
supabase migration repair --status applied 20260323000001
supabase migration repair --status applied 20260323000002
supabase migration repair --status applied 20260323000000  # return_to_self_sync (brak sekundy)
supabase migration repair --status applied 20260324000001

# Weryfikacja — powinno pokazać 13 migracji jako applied
supabase migration list
```

> ⚠️ `20260323_return_to_self_sync.sql` ma nieprawidłowy timestamp (bez godziny/minuty). Jeśli `migration repair` zwróci błąd dla tego wersji, uruchom: `supabase migration repair --status applied 20260323` i sprawdź czy pasuje.

---

### 2. Supabase Dashboard: Auth Redirect URLs (PRIORYTET 1)

**Problem:** App i AndroidManifest używają scheme `com.patryk.sobersteps://login-callback`.
`.env` ma `com.sobersteps.sobersteps://login-callback` — to NIE jest używane przez kod.
Jeśli w Dashboard jest tylko ta druga wersja, auth będzie broken.

**Akcja:**
1. Idź do: [Supabase Dashboard](https://supabase.com/dashboard/project/kznhbcwozpjflewlzxnu) → Authentication → URL Configuration
2. W polu **Redirect URLs** upewnij się, że istnieje:
   ```
   com.patryk.sobersteps://login-callback
   ```
3. Opcjonalnie zostaw też `com.sobersteps.sobersteps://login-callback` dla bezpieczeństwa.
4. Zapisz.

---

### 3. Supabase Dashboard: Edge Function Secrets (PRIORYTET 1)

Sprawdź: Dashboard → Edge Functions → każda funkcja → Secrets.

Dla `notify_users` muszą być ustawione:
- `CRON_SECRET` — **identyczny** ze secretem GitHub Actions `CRON_SECRET`
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Dla `naomi-feedback`:
- `ANTHROPIC_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Dla `moderate_three_am_post` i `send_moderation_email_brevo`:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

---

### 4. GitHub Actions: Secrets (PRIORYTET 1)

Idź do: GitHub repo → Settings → Secrets and variables → Actions.

Muszą istnieć wszystkie sekrety z `.github/SECRETS.md`:

| Secret | Wartość (skąd wziąć) |
|--------|---------------------|
| `SUPABASE_URL` | `https://kznhbcwozpjflewlzxnu.supabase.co` |
| `SUPABASE_PROJECT_REF` | `kznhbcwozpjflewlzxnu` |
| `SUPABASE_ACCESS_TOKEN` | Supabase Dashboard → Account → Access Tokens |
| `SUPABASE_DB_PASSWORD` | z `.env` (SUPABASE_DB_PASSWORD) |
| `SUPABASE_ANON_KEY` | z `.env` (SUPABASE_ANON_PUBLIC_KEY) |
| `CRON_SECRET` | Dowolny silny string — **musi być identyczny** z secretem Edge Function |
| `ONESIGNAL_APP_ID` | z `.env` (ONESIGNAL_APP_ID) |
| `REVENUE_CAT_KEY` | z `.env` (REVENUE_CAT_SDK_API_KEY) |
| `SENTRY_DSN` | Sentry Dashboard → projekt SoberSteps → Settings → Client Keys → DSN |
| `CURSOR_API_KEY` | Cursor Dashboard — dla `rls-security-review.yml` |

---

### 5. RevenueCat (PRIORYTET 1 — paywall)

Sekcja `docs/REVENUECAT_PRODUCTS.md` — do wykonania:

**Android:**
1. Play Console → utwórz produkty in-app z ID:
   - `sobersteps_monthly_699`
   - `sobersteps_annual_5999`
   - `sobersteps_family_999`
   - `sobersteps_lifetime_8999`
2. RevenueCat Dashboard → dodaj Android App (package: `com.sobersteps.sobersteps`)
3. Połącz z Play Console (Service Account)
4. Utwórz Entitlement `pro`, przypisz produkty
5. Ustaw produkcyjny `REVENUE_CAT_KEY` (Android) w GitHub Secrets

**iOS:**
1. Xcode → Runner → Signing & Capabilities → `+` → **In-App Purchase**
2. App Store Connect → utwórz te same 4 produkty
3. RevenueCat Dashboard → dodaj iOS App (bundle: `com.sobersteps.sobersteps`)
4. Ustaw iOS `REVENUE_CAT_KEY` — uwaga: wartość jest inna niż Android (`appl_...`)

> ⚠️ Aktualny `app_constants.dart` ma domyślny key `test_yugqnTsxrHsXuQwYbZXcWIMMqsu` — to klucz testowy. Musi być zastąpiony przez `--dart-define=REVENUE_CAT_KEY=...` w buildach release.

---

### 6. Sentry: DSN

1. Zaloguj się na [sentry.io](https://sentry.io)
2. Utwórz projekt Flutter (lub użyj istniejącego `SoberSteps`)
3. Settings → Client Keys → skopiuj DSN
4. Dodaj jako GitHub Secret `SENTRY_DSN`
5. Opcjonalnie: dodaj `sentry.properties` z `auth.token` do CI (dla source maps)

---

### 7. Android: Weryfikacja keystore

`android/app/upload-keystore.jks` musi istnieć (jest w `.gitignore`).
`android/key.properties` jest wypełniony ✅

Jeśli `upload-keystore.jks` nie istnieje lokalnie:
```bash
# Jeśli to pierwsze przesyłanie do Play — możesz użyć "upload key" z Play Console
# lub wygenerować nowy:
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass sobersteps2026 \
  -keypass sobersteps2026
```

---

### 8. iOS: Signing & Provisioning

Wymaga Xcode + Apple Developer Account:
1. Xcode → Runner → Signing & Capabilities → Team: wybierz konto
2. Bundle ID: `com.sobersteps.sobersteps`
3. Provisioning Profile: App Store distribution
4. `flutter build ipa --release --dart-define=...` (patrz `docs/RELEASE.md`)
5. Upload do App Store Connect przez Xcode Organizer lub Transporter

---

### 9. Store Listing: Privacy Policy URL

**Wymagane przez oba sklepy.**

`privacy/privacypolicy.html` istnieje w repo — musi być dostępna pod **publicznym URL**.
Opcje:
- GitHub Pages: włącz w repo Settings → Pages → branch: main → folder: `/privacy` → URL: `https://OWNER.github.io/REPO/privacypolicy.html`
- Lub hostuj na `https://sobersteps.app/privacy`

W store listing podaj ten URL.

---

### 10. Store Listing: Wiek 18+

**Android (Play Console):** Content Rating → zaznacz że aplikacja jest dla 18+
**iOS (App Store Connect):** Age Rating → 17+ (wymagane dla treści zdrowotnych/trzeźwość)

Disclaimer + age gate jest zaimplementowany w `DisclaimerScreen` ✅

---

## 🟡 Do weryfikacji na urządzeniu (Smoke przed submitem)

- [ ] Auth: magic link (email) → otwiera aplikację przez deep link (Android + iOS)
- [ ] Check-in: zapis lokalny + sync do Supabase
- [ ] Paywall: wyświetla się, zakup sandbox działa, przywracanie działa
- [ ] Push (OneSignal): token rejestruje się, testowe powiadomienie dochodzi
- [ ] Three AM SOS: przycisk ratunkowy, numer SAMHSA widoczny
- [ ] Offline: sprawdź check-in bez internetu → sync po powrocie
- [ ] Deep link: `com.patryk.sobersteps://login-callback` → otwiera odpowiedni screen

---

## 📋 Definition of Done (29.03)

- [ ] Migration repair wykonane, `supabase migration list` pokazuje 13 applied
- [ ] Supabase Dashboard: redirect URL `com.patryk.sobersteps://login-callback` ✅
- [ ] Supabase Dashboard: wszystkie sekrety Edge Functions ustawione ✅
- [ ] GitHub Actions: wszystkie 10 sekretów ustawione ✅
- [ ] RevenueCat: produkty + entitlement `pro` skonfigurowane na Android + iOS ✅
- [ ] Sentry DSN w GitHub Secrets ✅
- [ ] Android AAB zbudowany + przesłany do Play Console (internal track)
- [ ] iOS IPA zbudowany + przesłany do TestFlight
- [ ] Smoke na urządzeniu: auth, check-in, paywall, push, deep link ✅
- [ ] Privacy policy URL publiczny i podany w listing ✅
- [ ] Wiek 18+ ustawiony w obu sklepach ✅
