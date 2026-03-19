# PUBLISH_BLOCK — Tomorrow 08:00 CET (07:00 UTC)

---

## 1. REEL (IG + TikTok)

```
TYPE: reel
PLATFORMS: IG,TikTok
VIDEO_PATH: .cursor/output/reel-final-0800.mp4
DATETIME_UTC: 2026-03-20T07:00:00Z

HOOK:
home after 8 hours. laptop open again.

MIDDLE:
not because someone's paying me.
because someone tonight might need this to work.

CLOSE:
building the app I wish I had — one evening at a time.

CAPTION:
the second shift no one asked me to do. I asked myself.
some things you build because you remember what it felt like to have nothing at 3 AM.

https://soberstepsdev.github.io/sobersteps/

HASHTAGS: #SoberSteps #BuildInPublic #RecoveryApp #SoberTikTok #SoberIG #ReturnToSelf #IndieApp #80PercentIsEnough

CAPTION_OVERLAY: {"captions":[{"start":0.0,"end":3.5,"text":"home after 8 hours.\nlaptop open again.","fade_in":0.3,"fade_out":0.3},{"start":4.0,"end":8.0,"text":"not because someone's\npaying me.","fade_in":0.3,"fade_out":0.3},{"start":8.5,"end":14.0,"text":"because someone tonight\nmight need this to work.","fade_in":0.3,"fade_out":0.3},{"start":15.0,"end":20.0,"text":"building the app I wish I had —\none evening at a time.","fade_in":0.4,"fade_out":0.5}],"duration":22}
```

VOICE: Patryk (ElevenLabs) — baked into video; tail padded with silence so on-screen captions through ~20s stay visible.

VIDEO SOURCE: **procedural only** (ffmpeg `gradients` + blur + grain). No photos, no stock footage. Regenerate: `python3 scripts/gen_reel_procedural.py [.cursor/output/voice-reel.mp3]`

---

## 2. FEED POST (IG + X + LinkedIn)

```
TYPE: image
PLATFORMS: IG,X,LinkedIn
IMAGE_PATH: .cursor/output/post-feed-0800.png
DATETIME_UTC: 2026-03-20T07:00:00Z

HEADLINE: the second shift no one asked me to do. I asked myself.

CAPTION:
After 8h at work I sit down and build something I wish existed when I needed it most. No deadline. No client. Just a quiet room and code that might help someone stay one more night.

Some things you build because you remember what it felt like to have nothing at 3 AM.

https://soberstepsdev.github.io/sobersteps/

HASHTAGS: #SoberSteps #BuildInPublic #RecoveryApp #IndieApp #ReturnToSelf #SoberCommunity

IMAGE_SPEC: 1080×1080 (1:1 feed)
```

---

## Files ready

| File | Size | Format | Use |
|------|------|--------|-----|
| `reel-final-0800.mp4` | ~1MB | 1080×1920 H.264 | IG Reel + TikTok |
| `post-feed-0800.png` | ~1.1MB | 1080×1080 PNG | IG Feed + X + LinkedIn |
| `voice-reel.mp3` | 192KB | MP3 | Backup voice file |
| `story-1-ready.png` | — | 1080×1920 | IG Story variant 1 |
| `story-2-ready.png` | — | 1080×1920 | IG Story variant 2 |
| `story-3-ready.png` | — | 1080×1920 | IG Story variant 3 |

## Hootsuite schedule
- Date: **2026-03-20**
- Time: **08:00 CET** (07:00 UTC)
- Post reel to IG + TikTok simultaneously
- Post image to IG feed + X + LinkedIn simultaneously
- Stories: upload manually (Hootsuite doesn't schedule stories for all platforms)
