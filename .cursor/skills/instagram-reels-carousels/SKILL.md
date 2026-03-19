---
name: instagram-reels-carousels
description: Generates Instagram Reels scripts and Carousel content (slides, copy, captions, hashtags). Use when creating IG reels, carousel posts, short-form video scripts, or multi-slide Instagram content.
---

# Instagram Reels & Carousels

## When to use

- User asks for Instagram reels, reels scripts, or short-form video content for IG
- User asks for carousel posts, multi-slide content, or infographic-style posts for IG
- User mentions "reel", "carousel", "Instagram post" without specifying format

---

## Reels

### Specs (quick reference)

| Param | Value |
|-------|-------|
| Dimensions | 1080×1920px (9:16) |
| Duration | 15–35s (optimal), max 180s |
| Format | MP4, H.264, 30fps |
| Safe zones | Top 15%, bottom 10% — keep key text/CTAs centered |

### Script structure

```
Hook (0–3s):   Stop the scroll. One line.
Middle (3–25s): 3 points max. Bullets or short beats.
Close (25–35s): One clear takeaway + CTA
```

### Reel output template

```markdown
## Reel: [Title]

**Hook (0–3s)**
[Copy]

**Middle (3–25s)**
1) ...
2) ...
3) ...

**Close + CTA**
[Copy]

**Caption**
[2–4 sentences. Line breaks for readability.]

**Hashtags** (5–8)
#Tag1 #Tag2 ...
```

---

## Carousels

### Specs (quick reference)

| Param | Value |
|-------|-------|
| Slide size | 1080×1350px (4:5) — recommended |
| Alt | 1080×1080px (1:1), 1080×1440px (3:4) |
| Slides | Typically 5–10. All slides same size. |
| Text margin | Avoid edges; keep 10% buffer |

### Carousel structure

```
Slide 1:   Hook / cover — main claim or question
Slides 2–N-1: One idea per slide. Minimal text (under ~15 words per slide ideal)
Slide N:   CTA / follow / save
```

### Carousel output template

```markdown
## Carousel: [Title]

**Slide 1 (cover)**
[Headline or hook — bold, 1 line]

**Slide 2**
[Copy]

**Slide 3**
[Copy]

[... ]

**Slide N (CTA)**
[Call to action]

**Caption**
[Opening line. Expand on hook. Optional story or list.]

**Hashtags** (5–8)
#Tag1 #Tag2 ...
```

---

## Workflow

1. **Clarify** (internally): Topic, goal (awareness/engagement/conversion), audience.
2. **Pick format**: Reel (storytelling, demo, vibe) vs Carousel (tips, list, before/after).
3. **Apply template**: Use structure above. Keep copy tight.
4. **Caption**: First 1–2 lines visible without "more" — put hook there.

---

## Guardrails

- **Reels:** Hook in first 1–2 seconds. No slow intros.
- **Carousels:** Slide 1 must work standalone in feed (users may not swipe).
- **Hashtags:** 5–8 per post. Mix niche + broad. No banned or irrelevant tags.
- **No wall of text:** Carousel slides = scannable. Reels = spoken pace.

---

## Optional: Brand skills

For SoberSteps or other project-specific content, combine this skill with the project's social/brand skill (e.g. `sobersteps-social-formats`) for voice and guardrails. This skill provides format and specs only.

## Additional resources

- Full technical specs (codecs, file sizes, alt dimensions): [reference.md](reference.md)
