---
name: sobersteps-product-context
description: Product context for SoberSteps (modules, freemium, philosophy). Use this to ground coding/planning decisions in what the app is and what it must never promise.
---

## When to use
- You’re writing or reviewing **code/microcopy** for SoberSteps features.
- You’re planning roadmap/experiments and need the **north star** without turning the output into marketing.

## Core philosophy filter
Everything should stay compatible with:

```
←— Uśmiech ↔ Perspektywa ↔ Droga —→
```

- **Uśmiech**: curiosity, resilience independent of circumstances (not “toxic positivity”).
- **Perspektywa**: replace goals with a way of seeing (never-ending).
- **Droga**: long-term context; small steps compound.

## What SoberSteps is (in one paragraph)
SoberSteps is a recovery app for iOS/Android (Flutter) that combines classic sobriety tracking with deep work on the relationship with yourself — including the journey out of **self-hatred**. It supports chemical and behavioral addictions, and treats “returning to yourself” as the main path.

## Key modules (product reality)
- **Sobriety tracking**: streak/days + milestones (1/7/30/90/180/365/…); can include TTS celebrations.
- **Craving Surf**: urge surfing; white noise (FREE) and richer soundscapes (PRO).
- **3 AM SOS**: offline-first “when it’s worst” screen; immediate actions (breath / write / call).
- **Journal**: quick ratings (mood/craving) + history and filtering.
- **Letters to self**: perspective of the future sober self / compassionate self.
- **Return to Self (30-Day Path)**: awareness → distance → repair → integration.
- **Mirror Moment**: short practice; “stay with yourself” tone.
- **Naomi Mode**: motivation anchored in a close person; AI feedback (Claude API).
- **Wall of Strength**: anonymous global feed; one sentence after a week (UGC/community proof).

## Freemium truth (what we can safely imply)
- **FREE** includes meaningful value (mini-lessons, white-noise Craving Surf, generic milestones, community map, self-hatred module).
- **PRO** adds depth (more lessons, multiple letters, soundscapes, dedicated milestones, streak protection, personalized TTS, accountability).

### Guardrail
- Never say “buy PRO”. Show the FREE value so well that the user asks.

## Microcopy & messaging constraints (hard rules)
- No clinical/therapeutic language.
- No promises or guarantees (e.g., “you will quit in 30 days”).
- No manipulative pressure; don’t treat relapse as failure.

## Quick decision checklist (coding/planning)
Before proposing a change, answer:
- Does it touch **safety** (craving, 3 AM) — is it calming and immediate?
- Does it touch **money/identity** (paywall, auth) — is it clear and non-coercive?
- Does it reduce self-hatred or reinforce it — does it feel like a “return” not a “score”?
- Is the wording aligned with **curiosity + perspective + road**?

