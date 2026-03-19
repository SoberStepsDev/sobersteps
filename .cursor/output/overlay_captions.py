#!/usr/bin/env python3
"""Overlay captions on reel using Pillow-rendered PNGs + ffmpeg overlay filter."""
import os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.dirname(os.path.abspath(__file__))
VIDEO_IN = os.path.join(OUT, "reel-voiced.mp4")
VIDEO_OUT = os.path.join(OUT, "reel-final-0800.mp4")
if len(sys.argv) >= 3:
    VIDEO_IN = os.path.abspath(sys.argv[1])
    VIDEO_OUT = os.path.abspath(sys.argv[2])
elif len(sys.argv) == 2:
    VIDEO_IN = os.path.abspath(sys.argv[1])
W, H = 1080, 1920
FPS = 30

CAPTIONS = [
    {"start": 0.0, "end": 3.5, "text": "home after 8 hours.\nlaptop open again.", "fi": 0.3, "fo": 0.3},
    {"start": 4.0, "end": 8.0, "text": "not because someone's\npaying me.", "fi": 0.3, "fo": 0.3},
    {"start": 8.5, "end": 14.0, "text": "because someone tonight\nmight need this to work.", "fi": 0.3, "fo": 0.3},
    {"start": 15.0, "end": 20.0, "text": "building the app I wish I had —\none evening at a time.", "fi": 0.4, "fo": 0.5},
]

def load_font(size):
    for p in ["/System/Library/Fonts/Supplemental/HelveticaNeue-Medium.otf",
              "/System/Library/Fonts/Helvetica.ttc"]:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

font = load_font(46)

def get_alpha(t, c):
    s, e, fi, fo = c["start"], c["end"], c["fi"], c["fo"]
    if t < s or t > e:
        return 0
    if t < s + fi:
        return (t - s) / fi
    if t > e - fo:
        return (e - t) / fo
    return 1.0

def get_duration():
    r = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1", VIDEO_IN],
        capture_output=True, text=True
    )
    return float(r.stdout.strip())

def render_frame(t):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for c in CAPTIONS:
        a = get_alpha(t, c)
        if a <= 0:
            continue
        alpha_int = int(a * 255)
        lines = c["text"].split("\n")
        y = 1520
        for line in lines:
            bbox = font.getbbox(line)
            tw = bbox[2] - bbox[0]
            x = (W - tw) // 2
            draw.text((x + 3, y + 3), line, font=font, fill=(0, 0, 0, int(alpha_int * 0.6)))
            draw.text((x, y), line, font=font, fill=(255, 255, 255, alpha_int))
            y += 58
    return img

def main():
    dur = get_duration()
    total_frames = int(dur * FPS)
    frames_dir = os.path.join(OUT, "_caption_frames")
    os.makedirs(frames_dir, exist_ok=True)

    print(f"Rendering {total_frames} caption overlay frames...")
    for i in range(total_frames):
        t = i / FPS
        frame = render_frame(t)
        frame.save(os.path.join(frames_dir, f"{i:05d}.png"))
        if i % 60 == 0:
            print(f"  frame {i}/{total_frames}")

    print("Compositing with ffmpeg overlay...")
    cmd = [
        "ffmpeg", "-y",
        "-i", VIDEO_IN,
        "-framerate", str(FPS),
        "-i", os.path.join(frames_dir, "%05d.png"),
        "-filter_complex", "[0:v][1:v]overlay=0:0:shortest=1[out]",
        "-map", "[out]", "-map", "0:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "22",
        "-c:a", "copy",
        VIDEO_OUT
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        sz = os.path.getsize(VIDEO_OUT)
        print(f"✅ {VIDEO_OUT} ({sz // 1024}KB)")
    else:
        print(f"❌ ffmpeg overlay failed: {r.stderr[-400:]}")

    # Cleanup frames
    import shutil
    shutil.rmtree(frames_dir, ignore_errors=True)

if __name__ == "__main__":
    main()
