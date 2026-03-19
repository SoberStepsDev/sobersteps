#!/usr/bin/env python3
"""Generate complete reel: Ken Burns zoom on photo + text overlays → frames → video."""
from PIL import Image, ImageDraw, ImageFont
import os, subprocess, sys

OUT = os.path.dirname(os.path.abspath(__file__))
BG = os.path.join(OUT, "bg.png")
FRAMES_DIR = os.path.join(OUT, "frames")
VIDEO_NO_AUDIO = os.path.join(OUT, "reel-noaudio.mp4")
VOICE = os.path.join(OUT, "reel-voice.mp3")
FINAL = os.path.join(OUT, "reel-final.mp4")
FINAL_TIKTOK = os.path.join(OUT, "reel-final-tiktok.mp4")

W, H = 1080, 1920
FPS = 30
FADE_FRAMES = 10

def load_font(name, size):
    for p in [f"/System/Library/Fonts/Supplemental/{name}.ttf",
              f"/System/Library/Fonts/{name}.ttf",
              f"/System/Library/Fonts/{name}.ttc",
              f"/System/Library/Fonts/Supplemental/{name}.ttc",
              f"/Library/Fonts/{name}.ttf"]:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                continue
    return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)

font_tag = load_font("HelveticaNeue", 26)
font_italic = load_font("HelveticaNeue-LightItalic", 32)
font_main = load_font("HelveticaNeue-Medium", 56)
font_sub = load_font("HelveticaNeue", 44)
font_sm = load_font("HelveticaNeue", 24)

GOLD = (251, 191, 36)
WHITE = (226, 232, 240)
GRAY = (148, 163, 184)

src_img = Image.open(BG).convert("RGBA")
ratio = max(W / src_img.width, H / src_img.height) * 1.2
src_big = src_img.resize((int(src_img.width * ratio), int(src_img.height * ratio)), Image.LANCZOS)

def get_zoomed_frame(zoom):
    cw = int(W / zoom)
    ch = int(H / zoom)
    cx = (src_big.width - cw) // 2 - int(30 * (zoom - 1))
    cy = (src_big.height - ch) // 2 - int(20 * (zoom - 1))
    cx = max(0, min(cx, src_big.width - cw))
    cy = max(0, min(cy, src_big.height - ch))
    cropped = src_big.crop((cx, cy, cx + cw, cy + ch))
    return cropped.resize((W, H), Image.LANCZOS)

def apply_darken(img, brightness=0.40):
    dark = Image.new("RGBA", (W, H), (0, 0, 0, int(255 * (1 - brightness))))
    return Image.alpha_composite(img, dark)

def apply_gradient(img):
    grad = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(grad)
    for y in range(H):
        if y < H * 0.12:
            a = int(100 * (1 - y / (H * 0.12)))
        elif y > H * 0.55:
            a = int(210 * ((y - H * 0.55) / (H * 0.45)))
        else:
            a = 0
        d.line([(0, y), (W, y)], fill=(0, 0, 0, a))
    return Image.alpha_composite(img, grad)

TEXT_BLOCKS = [
    {
        "start": 0, "end": 150,
        "lines": [("SOBERSTEPS / BEHIND THE SCREEN", font_tag, (255, 255, 255), 0.35)],
        "y_start": 80, "spacing": 0, "align": "left", "x": 60,
    },
    {
        "start": 30, "end": 155,
        "lines": [
            ("home after 8 hours.", font_italic, GRAY, 1.0),
            ("laptop open again.", font_italic, GRAY, 1.0),
        ],
        "y_start": H - 530, "spacing": 50, "align": "left", "x": 60,
    },
    {
        "start": 155, "end": 310,
        "lines": [
            ("not because someone's", font_main, WHITE, 1.0),
            ("paying me.", font_main, WHITE, 1.0),
        ],
        "y_start": H - 500, "spacing": 70, "align": "left", "x": 60,
    },
    {
        "start": 310, "end": 500,
        "lines": [
            ("because someone tonight", font_main, GOLD, 1.0),
            ("might need this to work.", font_main, GOLD, 1.0),
        ],
        "y_start": H - 480, "spacing": 70, "align": "left", "x": 60,
    },
    {
        "start": 500, "end": 610,
        "lines": [
            ("some things you build because", font_sub, GRAY, 1.0),
            ("you remember what it felt like", font_sub, GRAY, 1.0),
            ("to have nothing at 3 AM.", font_sub, GRAY, 1.0),
        ],
        "y_start": H - 480, "spacing": 56, "align": "left", "x": 60,
    },
    {
        "start": 610, "end": 690,
        "lines": [("sobersteps — link in bio", font_sm, (255, 255, 255), 0.4)],
        "y_start": H - 200, "spacing": 0, "align": "center", "x": 0,
    },
]

def draw_texts(frame_img, frame_idx):
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for block in TEXT_BLOCKS:
        if frame_idx < block["start"] or frame_idx > block["end"]:
            continue
        fade = 1.0
        if frame_idx < block["start"] + FADE_FRAMES:
            fade = (frame_idx - block["start"]) / FADE_FRAMES
        elif frame_idx > block["end"] - FADE_FRAMES:
            fade = (block["end"] - frame_idx) / FADE_FRAMES
        fade = max(0, min(1, fade))
        y = block["y_start"]
        for text, font, base_color, base_alpha in block["lines"]:
            alpha = int(255 * base_alpha * fade)
            color = (*base_color, alpha)
            if block["align"] == "center":
                tw = font.getlength(text)
                x = (W - tw) // 2
            else:
                x = block["x"]
            draw.text((x, y), text, font=font, fill=color)
            bbox = font.getbbox(text)
            y += (bbox[3] - bbox[1]) + block["spacing"] - (bbox[3] - bbox[1]) // 2 + 10
            if block["spacing"] > 0:
                y = y - 10 + block["spacing"] - (bbox[3] - bbox[1]) + (bbox[3] - bbox[1])
            else:
                y += 10
        # Simpler y increment
    return Image.alpha_composite(frame_img, overlay)

def draw_texts_v2(frame_img, frame_idx):
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for block in TEXT_BLOCKS:
        if frame_idx < block["start"] or frame_idx > block["end"]:
            continue
        fade = 1.0
        if frame_idx < block["start"] + FADE_FRAMES:
            fade = (frame_idx - block["start"]) / FADE_FRAMES
        elif frame_idx > block["end"] - FADE_FRAMES:
            fade = (block["end"] - frame_idx) / FADE_FRAMES
        fade = max(0.0, min(1.0, fade))
        y = block["y_start"]
        for text, font, base_color, base_alpha in block["lines"]:
            alpha = int(255 * base_alpha * fade)
            color = (*base_color, alpha)
            if block["align"] == "center":
                tw = font.getlength(text)
                x = int((W - tw) // 2)
            else:
                x = block["x"]
            draw.text((int(x), int(y)), text, font=font, fill=color)
            bbox = font.getbbox(text)
            line_h = bbox[3] - bbox[1]
            y += line_h + 12
    return Image.alpha_composite(frame_img, overlay)

os.makedirs(FRAMES_DIR, exist_ok=True)

total_frames = 23 * FPS
print(f"Generating {total_frames} frames...")

bg_cache = None
for i in range(total_frames):
    zoom = 1.0 + 0.15 * (i / total_frames)
    frame = get_zoomed_frame(zoom)
    frame = apply_darken(frame)
    frame = apply_gradient(frame)
    frame = draw_texts_v2(frame, i)
    frame.convert("RGB").save(os.path.join(FRAMES_DIR, f"frame_{i:04d}.png"), optimize=True)
    if i % 30 == 0:
        print(f"  frame {i}/{total_frames}")

print(f"Frames done: {total_frames}")

# Assemble video from frames
print("Assembling video from frames...")
cmd = [
    "ffmpeg", "-y",
    "-framerate", str(FPS),
    "-i", os.path.join(FRAMES_DIR, "frame_%04d.png"),
    "-c:v", "libx264", "-preset", "fast", "-crf", "20",
    "-pix_fmt", "yuv420p",
    VIDEO_NO_AUDIO
]
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode != 0:
    print(f"ffmpeg error: {r.stderr}", file=sys.stderr)
    sys.exit(1)
print(f"Video (no audio): {VIDEO_NO_AUDIO}")

# Add voice if available
if os.path.exists(VOICE):
    print("Adding voiceover...")
    cmd = [
        "ffmpeg", "-y",
        "-i", VIDEO_NO_AUDIO,
        "-i", VOICE,
        "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
        "-shortest",
        FINAL
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        print(f"Final reel: {FINAL}")
        # TikTok copy (same file, different name for clarity)
        import shutil
        shutil.copy2(FINAL, FINAL_TIKTOK)
        print(f"TikTok copy: {FINAL_TIKTOK}")
    else:
        print(f"Audio merge error: {r.stderr}", file=sys.stderr)
        print(f"Video without audio is at: {VIDEO_NO_AUDIO}")
else:
    print(f"No voice file at {VOICE} — video without audio: {VIDEO_NO_AUDIO}")
    print("Run gen_voice.py first, then re-run to merge.")

# Get duration
probe = subprocess.run(
    ["ffprobe", "-v", "error", "-show_entries", "format=duration",
     "-of", "default=noprint_wrappers=1:nokey=1",
     FINAL if os.path.exists(FINAL) else VIDEO_NO_AUDIO],
    capture_output=True, text=True
)
print(f"Duration: {probe.stdout.strip()}s")
print("DONE")
