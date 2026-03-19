# Schedule 18–29 marca — minimalne zużycie tokenów

## Zasady oszczędności

| Zasada | Jak |
|--------|-----|
| **Topic-only** | Każdy content-publisher dostaje tylko 1 zdanie topicu |
| **Batch równoległy** | 3 posty dziennie = 3× mcp_task jednocześnie (nie sekwencyjnie) |
| **Model fast** | Zawsze `model: fast` dla content-publisher i reddit-helper |
| **Bez social-publisher** | PUBLISH_BLOCK → ręczny paste do Later/Buffer = 0 tokenów |
| **Engagement batch** | reddit-helper 1× na blok (np. "10 komentarzy") zamiast 10× po 1 |

## Workflow (token‑minimal)

```
Topic (1 zdanie) → sobersteps-content-publisher → PUBLISH_BLOCK (do .cursor/output/)
                                                   ↓
                              Ręcznie: paste caption + upload → Later/Buffer
```

**social-publisher** = tylko gdy musisz (browser automation kosztuje). Lepiej: skrypt `reel_from_publish_block.py` + ręczny upload.

## Dzień 1 (18 marca) — topic strings

| Czas | Topic (input do content-publisher) |
|------|-----------------------------------|
| 08:00 | 26 days. 3AM still hits. VIDEO 1 STRENGTH |
| 13:00 | The 3AM Wall exists. Here's how I break through it. |
| 18:00 | Building SoberSteps so 3AM doesn't destroy you. 11 days. |

**Engagement:** 1× reddit-helper — "10 meaningful replies for #sobriety trending on r/stopdrinking, r/dryalcoholics. 100% value, 10% rule."

## Szacunek tokenów

- 1× content-publisher (1 topic): ~2–4K tokens
- 3× równolegle dzień: ~6–12K
- 1× reddit-helper (10 komentarzy): ~3–5K
- **Dzień 1 total:** ~10–17K
- **11 dni (posty only):** ~70–130K  
- **+ engagement:** +20–40K

**vs. sekwencyjnie / bez batchy:** ~2–3× więcej
