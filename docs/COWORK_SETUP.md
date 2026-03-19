# Claude Cowork — konfiguracja dla soberstepsod-2026

**Uwaga:** Ustawień Cowork (Anthropic) nie da się zapisać z repozytorium — konfigurujesz je w przeglądarce (**Customize**, connectory, pluginy). Ten plik jest **jednym źródłem do skopiowania**: wklej sekcje poniżej w odpowiednie miejsca w Cowork.

Szerszy kontekst workspace: [`RULE.md`](../RULE.md), [`CURSOR_SETUP.md`](CURSOR_SETUP.md).

---

## 1. Customize → Custom instructions

Wklej **cały** blok (krótko = mniejszy stały koszt kontekstu w Cowork):

```
Repo: soberstepsod-2026 — Flutter app SoberSteps (offline-first, Supabase, Provider only).

Profiles: (1) Coding — Dart/Flutter, zmiany tylko w wskazanych plikach. (2) Social — IG/TikTok; stosuj zasady z .cursor/skills/sobersteps-social-formats/SKILL.md gdy proszę o social. (3) Planning — architektura i trade-offy; bez edycji kodu, chyba że wyraźnie proszę o kod.

Stack (nie zmieniaj wersji/pakietów bez uzasadnienia): Flutter 3.24.x, Dart 3.5.x; pakiety jak w pubspec (supabase_flutter, purchases_flutter, onesignal_flutter, provider, flutter_animate, lottie, fl_chart, intl, uuid, url_launcher, audioplayers, shared_preferences, path_provider, flutter_secure_storage, connectivity_plus, http, crypto, elevenlabs_flutter) — bez nowych dependency bez wyraźnej prośby.

Filozofia UI: Uśmiech↔Perspektywa↔Droga — bez imperatywów i „musisz”, bez toksycznej pozytywki; zaproszenia i ciekawość. Stringi UI w kodzie: komentarz /// Philosophy applied: [krótki opis].

Bezpieczeństwo: nie commituj .env, SUPABASE_SERVICE_ROLE_KEY, android/key.properties, *.jks, service account JSON. Sekrety tylko lokalnie.

Zachowanie: najpierw potwierdź zakres (1–3 zdania), potem działaj. Nie czytaj całego repo — tylko ścieżki podane w zadaniu. Odpowiedzi zwięzłe; długie listingi tylko gdy proszę.

Kolory UI (jeśli dotykasz stylu): background #0A0A0F, surface #111118, primary #6366F1, accentGold #FBBF24, textPrimary #E2E8F0, textSecondary #94A3B8, error #F87171. Font: Inter (google_fonts).
```

---

## 2. Ideas — szablony (skopiuj jako osobne „Ideas” w Cowork)

**Coding — wąski zakres**  
`Zmień tylko [WSTAW_ŚCIEŻKĘ]. Nie dotykaj innych plików. Po pracy: krótkie podsumowanie + lista zmienionych plików.`

**Stringi / filozofia**  
`Przejrzyj stringi w [WSTAW_PLIK] pod kątem SoberSteps (Uśmiech↔Perspektywa↔Droga). Każda zmiana w kodzie: /// Philosophy applied: …`

**Social**  
`Topic: [TEMAT] — format IG/TikTok wg .cursor/skills/sobersteps-social-formats/SKILL.md; wyjście: skrypt lub caption + hashtagi, bez moralizowania i bez imperatywów.`

**Plan bez kodu**  
`Analiza ryzyk i plan kroków dla [FEATURE]. Bez snippetów kodu, max 15 punktów.`

**Audit sekretów**  
`Sprawdź opis zmian / diff pod kątem wycieku sekretów (.env, klucze API, service role, keystores). Lista: OK lub podejrzane wzorce.`

---

## 3. Customize → Connectors (minimalnie)

| Connector        | Kiedy włączyć                                      |
|------------------|----------------------------------------------------|
| GitHub           | Tylko jeśli Cowork ma pracować na PR/issue z repo. |
| Drive / Notion   | Tylko jeśli masz **jeden** kanoniczny dokument spec. |
| Slack / mail     | Tylko przy realnych automatyzacjach komunikacji.   |

**Zasada:** wyłącz wszystko, czego nie używasz co tydzień — mniej przypadkowego kontekstu i wywołań.

---

## 4. Customize → Plugins

- Włączaj tylko pluginy, których naprawdę używasz.
- W **mapowaniu** ustaw realne narzędzia (żeby model nie szukał domyślnych integracji).
- Sam kod Flutter często wygodniej w Cursorze; Cowork — plany, social, krótkie automatyki.

---

## 5. Foldery / kontekst w Cowork

- Preferuj **wąskie** foldery: np. `docs/`, ewentualnie pojedyncze pliki (`lib/l10n/strings.dart`).
- Unikaj dodawania całego `lib/` jako stałego kontekstu startowego.

---

## 6. Oszczędzanie tokenów (przypomnienie)

- Jedna sesja = jeden cel + jawna lista ścieżek.
- Nie wklejaj pełnego `git status` ani długich logów bez potrzeby.
- Na końcu promptu możesz dodać: *„Odpowiedź max N akapitów”* lub *„bez pełnego kodu, tylko plan”*.
