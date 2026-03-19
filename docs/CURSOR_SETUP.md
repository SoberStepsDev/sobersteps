## Cursor setup dla SoberSteps (1 workspace)

### Cel
Jedno repo, ale świadomie rozdzielone zachowania agenta: **Coding**, **Social**, **Planning** — plus skills jako “pamięć/procedury”.

### Gdzie jest konfiguracja
- **Rules** (zawsze aktywne): `.cursor/rules/`
  - `sobersteps-coding.mdc`
  - `sobersteps-social.mdc`
  - `sobersteps-planning.mdc`
- **Skills** (uruchamiane kontekstowo): `.cursor/skills/`
  - `sobersteps-product-context`
  - `sobersteps-social-formats`

### Modele (praktycznie)
Ustaw to per-zadanie, nie “raz na zawsze”:
- **Coding**: model nastawiony na kod/refaktor/testy (Dart/Flutter/SQL/TS).
- **Social**: model nastawiony na narrację i ton.
- **Planning**: model nastawiony na syntezę i trade-offy.

### Sekrety i API keys (twarde zasady)
- **Nie commituj sekretów** — nigdy.
- W repo trzymamy tylko nazwy zmiennych w `.env.example`.
- Prawdziwe wartości:
  - w ustawieniach Cursora (provider keys),
  - i/lub w lokalnym `.env` (ignorowany przez git).

#### Checklist “czy przypadkiem nie wpycham sekretu?”
Jeśli zmiana dotyka:
- `.env`, `SUPABASE_SERVICE_ROLE_KEY`, tokenów, kluczy API
- `android/key.properties`, `*.jks`
- service-account JSON

…to traktuj to jako **blokadę**: stop i wróć do polityki sekretów.

### Ask vs Agent (kiedy które)
- **Ask** używaj gdy chcesz:
  - diagnozy, analizy, architektury, ryzyk,
  - propozycji planu i zakresu zmian.
- **Agent** używaj gdy chcesz:
  - faktycznych zmian w kodzie/plikach,
  - wdrożenia migracji, refaktorów, nowych ekranów.

### Minimalny “prompt” przed większym zadaniem (polecam)
W 1–2 zdaniach doprecyzuj zakres, np.:
- “Pracujemy tylko nad `lib/screens/craving_surf_screen.dart` i usługą audio. Nie ruszaj nic poza tym.”

### Claude Cowork (przeglądarka)
Ustawień Cowork nie zapisuje się w repo — używasz pliku [`docs/COWORK_SETUP.md`](COWORK_SETUP.md) jako źródła: skopiuj Custom instructions, szablony Ideas i checklisty connectorów/pluginów do interfejsu Anthropic.

