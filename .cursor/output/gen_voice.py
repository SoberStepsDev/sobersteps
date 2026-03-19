#!/usr/bin/env python3
"""Generate voiceover via ElevenLabs TTS API."""
import json, urllib.request, sys, os

OUT = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PATH = os.path.join(OUT, "reel-voice.mp3")

API_KEY = "sk_97915962e00b599a96157f611528fad99f1b1dbd974c863e"
VOICE_ID = "2Hw5QTX3wstf1sLYfhhk"

body = json.dumps({
    "text": (
        "Home after eight hours. Laptop open again. "
        "Not because someone's paying me. "
        "Because someone tonight… might need this to work. "
        "Some things you build because you remember what it felt like… "
        "to have nothing at three AM. "
        "SoberSteps. Link in bio."
    ),
    "model_id": "eleven_multilingual_v2",
    "voice_settings": {
        "stability": 0.6,
        "similarity_boost": 0.8,
        "style": 0.3
    }
}).encode()

req = urllib.request.Request(
    f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}",
    data=body,
    headers={
        "xi-api-key": API_KEY,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    },
)

print("Requesting TTS from ElevenLabs...")
try:
    with urllib.request.urlopen(req, timeout=60) as resp:
        audio = resp.read()
    with open(OUTPUT_PATH, "wb") as f:
        f.write(audio)
    print(f"Saved: {OUTPUT_PATH} ({len(audio)} bytes)")
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
