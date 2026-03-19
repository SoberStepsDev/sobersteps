#!/usr/bin/env python3
"""Build tomorrow's 08:00 reel: photo → Ken Burns video + ElevenLabs voice + caption overlay."""

import json, os, subprocess, urllib.request, urllib.error, time

OUT = os.path.dirname(os.path.abspath(__file__))
BG = os.path.join(OUT, "bg.png")
VOICE_ID = "2Hw5QTX3wstf1sLYfhhk"
EL_KEY = "sk_97915962e00b599a96157f611528fad99f1b1dbd974c863e"

VOICE_TEXT = (
    "Home after eight hours. Laptop open again. "
    "Not because someone's paying me. "
    "Because someone tonight... might need this to work. "
    "Building the app I wish I had. One evening at a time."
)

CAPTIONS = {
    "captions": [
        {"start": 0.0, "end": 3.5, "text": "home after 8 hours.\nlaptop open again.", "fade_in": 0.3, "fade_out": 0.3},
        {"start": 4.0, "end": 8.0, "text": "not because someone's\npaying me.", "fade_in": 0.3, "fade_out": 0.3},
        {"start": 8.5, "end": 14.0, "text": "because someone tonight\nmight need this to work.", "fade_in": 0.3, "fade_out": 0.3},
        {"start": 15.0, "end": 20.0, "text": "building the app I wish I had —\none evening at a time.", "fade_in": 0.4, "fade_out": 0.5},
    ],
    "duration": 22
}

VOICE_OUT = os.path.join(OUT, "voice-reel.mp3")
VIDEO_SILENT = os.path.join(OUT, "reel-silent.mp4")
VIDEO_VOICED = os.path.join(OUT, "reel-voiced.mp4")
VIDEO_FINAL = os.path.join(OUT, "reel-final-0800.mp4")

def step(msg):
    print(f"\n→ {msg}")

# ─── 1. ElevenLabs TTS ───
def gen_voice():
    step("Generating voice (ElevenLabs, Patryk)")
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}"
    payload = json.dumps({
        "text": VOICE_TEXT,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": 0.55, "similarity_boost": 0.72, "style": 0.15}
    })
    r = subprocess.run([
        "curl", "-s", "-o", VOICE_OUT, "-w", "%{http_code}",
        "-X", "POST", url,
        "-H", f"xi-api-key: {EL_KEY}",
        "-H", "Content-Type: application/json",
        "-H", "Accept: audio/mpeg",
        "-d", payload
    ], capture_output=True, text=True)
    code = r.stdout.strip()
    if code == "200" and os.path.getsize(VOICE_OUT) > 1000:
        print(f"  ✓ {VOICE_OUT} ({os.path.getsize(VOICE_OUT)//1024}KB)")
        return True
    print(f"  ✗ ElevenLabs HTTP {code}")
    return False

# ─── 2. Get audio duration ───
def get_duration(path):
    r = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1", path],
        capture_output=True, text=True
    )
    return float(r.stdout.strip())

# ─── 3. Ken Burns video from photo ───
def make_ken_burns(duration):
    step(f"Creating Ken Burns video ({duration:.1f}s)")
    fps = 30
    frames = int(duration * fps)
    # Slow zoom in + slight pan (1.0→1.15 scale, centered)
    vf = (
        f"scale=4320:-1,"
        f"zoompan=z='1+0.15*in/{frames}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'"
        f":d={frames}:s=1080x1920:fps={fps},"
        f"format=yuv420p"
    )
    cmd = [
        "ffmpeg", "-y", "-loop", "1", "-i", BG,
        "-vf", vf,
        "-t", str(duration),
        "-c:v", "libx264", "-preset", "fast", "-crf", "20",
        "-pix_fmt", "yuv420p",
        VIDEO_SILENT
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"  ✗ ffmpeg error: {r.stderr[-300:]}")
        return False
    print(f"  ✓ {VIDEO_SILENT}")
    return True

# ─── 4. Merge voice + video ───
def merge_audio():
    step("Merging voice onto video")
    cmd = [
        "ffmpeg", "-y",
        "-i", VIDEO_SILENT, "-i", VOICE_OUT,
        "-c:v", "copy", "-c:a", "aac", "-b:a", "128k",
        "-shortest",
        VIDEO_VOICED
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"  ✗ {r.stderr[-300:]}")
        return False
    print(f"  ✓ {VIDEO_VOICED}")
    return True

# ─── 5. Burn captions ───
def burn_captions():
    step("Burning caption overlay")
    scripts = os.path.join(os.path.dirname(OUT), "..", "scripts")
    burn_script = os.path.join(scripts, "burn_captions.py")
    if not os.path.isfile(burn_script):
        burn_script = os.path.join(os.path.dirname(OUT), "..", "scripts", "burn_captions.py")
    
    cmd = [
        "python3", burn_script,
        VIDEO_VOICED,
        json.dumps(CAPTIONS),
        VIDEO_FINAL
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        print(f"  ✓ {VIDEO_FINAL}")
        return True
    else:
        print(f"  ⚠ burn_captions failed, trying manual ffmpeg drawtext...")
        return burn_drawtext()

def burn_drawtext():
    """Fallback: use ffmpeg drawtext filter instead of ASS."""
    filters = []
    for c in CAPTIONS["captions"]:
        txt = c["text"].replace("'", "'\\''").replace("\n", "\\n")
        fi = c.get("fade_in", 0.3)
        fo = c.get("fade_out", 0.3)
        s, e = c["start"], c["end"]
        alpha = (
            f"if(lt(t,{s}),0,"
            f"if(lt(t,{s+fi}),(t-{s})/{fi},"
            f"if(lt(t,{e-fo}),1,"
            f"if(lt(t,{e}),({e}-t)/{fo},0))))"
        )
        f = (
            f"drawtext=text='{txt}'"
            f":fontsize=48:fontcolor=white"
            f":x=(w-text_w)/2:y=h-h*0.18"
            f":alpha='{alpha}'"
            f":shadowcolor=black:shadowx=2:shadowy=2"
        )
        filters.append(f)
    
    vf = ",".join(filters)
    cmd = [
        "ffmpeg", "-y", "-i", VIDEO_VOICED,
        "-vf", vf,
        "-c:a", "copy", "-c:v", "libx264", "-preset", "fast", "-crf", "23",
        VIDEO_FINAL
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode == 0:
        print(f"  ✓ {VIDEO_FINAL}")
        return True
    print(f"  ✗ drawtext also failed: {r.stderr[-300:]}")
    # Last resort: just copy voiced version as final
    import shutil
    shutil.copy2(VIDEO_VOICED, VIDEO_FINAL)
    print(f"  ⚠ Copied voiced video without overlay → {VIDEO_FINAL}")
    return True

# ─── MAIN ───
if __name__ == "__main__":
    has_voice = gen_voice()
    
    if has_voice:
        dur = get_duration(VOICE_OUT)
        dur = max(dur, 20) + 2  # pad 2s
    else:
        dur = 22
    
    if not make_ken_burns(dur):
        print("FATAL: Ken Burns failed")
        exit(1)
    
    if has_voice:
        if merge_audio():
            burn_captions()
        else:
            print("⚠ Audio merge failed, final = silent video")
            import shutil
            shutil.copy2(VIDEO_SILENT, VIDEO_FINAL)
    else:
        import shutil
        shutil.copy2(VIDEO_SILENT, VIDEO_VOICED)
        burn_captions()
    
    print(f"\n✅ DONE → {VIDEO_FINAL}")
    print(f"   Duration: ~{dur:.0f}s | Resolution: 1080×1920 | Format: MP4/H.264")
