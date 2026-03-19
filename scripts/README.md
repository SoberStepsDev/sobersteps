# SoberSteps Reel Scripts

## burn_captions.py
Burn CAPTION_OVERLAY into video. **Requires ffmpeg with libass** (`brew install ffmpeg`).

```bash
python scripts/burn_captions.py VIDEO_PATH '{"captions":[...]}' [OUTPUT.mp4]
```

If ffmpeg lacks libass: skrypt zapisuje plik `*_captions.ass` — zaimportuj w CapCut / DaVinci Resolve / Shotcut.

## reel_from_publish_block.py
Build captioned reel from PUBLISH_BLOCK (extracts VIDEO_PATH + CAPTION_OVERLAY).

```bash
python scripts/reel_from_publish_block.py .cursor/output/pubblock_recovery.md [output.mp4]
```

Output: `VIDEO_captioned.mp4` (or custom path).

## gen_reel_procedural.py
Reel **bez zdjęć**: gradienty w palecie SoberSteps + blur + grain, głos z MP3, napisy przez `.cursor/output/overlay_captions.py`.

```bash
python3 scripts/gen_reel_procedural.py   # voice: .cursor/output/voice-reel.mp3
python3 scripts/gen_reel_procedural.py /path/to/voice.mp3
```

Wyjście: `.cursor/output/reel-final-0800.mp4` (nadpisuje).

---

## Video generators (optional)
- **Shotstack** (shotstack.io) — API dla wideo + napisów
- **Creatomate** (creatomate.com) — szablony + overlay API
- **Remotion** (remotion.dev) — programowe wideo w React
