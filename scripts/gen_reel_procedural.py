#!/usr/bin/env python3
"""Generate SoberSteps reel video with zero photos — procedural gradients + grain + voice."""

import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
OUT = REPO / ".cursor/output"
FPS = 30

VOICE_DEFAULT = OUT / "voice-reel.mp3"
SILENT = OUT / "reel-procedural-silent.mp4"
VOICED = OUT / "reel-procedural-voiced.mp4"
FINAL = OUT / "reel-final-0800.mp4"


def ffprobe_duration(path: Path) -> float:
    r = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        capture_output=True,
        text=True,
    )
    return float(r.stdout.strip())


def main() -> int:
    voice = Path(sys.argv[1]) if len(sys.argv) > 1 else VOICE_DEFAULT
    if not voice.is_file():
        print(f"Voice file missing: {voice}", file=sys.stderr)
        print("Generate with ElevenLabs or pass path to MP3.", file=sys.stderr)
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    dur_audio = ffprobe_duration(voice)
    # Keep full caption timeline (~20s end); pad audio with silence so video isn't -shortest-trimmed
    dur_video = max(22.0, dur_audio + 2.0)

    print(
        f"→ Procedural video {dur_video:.1f}s (no images), {FPS}fps 1080×1920",
        flush=True,
    )

    # SoberSteps palette: background / surface / indigo depth / primary / gold whisper
    grad = (
        f"gradients=s=1080x1920:r={FPS}:d={dur_video:.3f}"
        ":c0=#0A0A0F:c1=#111118:c2=#1e1b4b:c3=#6366F1:c4=#2a2510"
        ":nb_colors=5:n=5:speed=0.007"
        ":x0=540:y0=400:x1=540:y1=1700"
    )

    vf = "gblur=sigma=72,noise=alls=4:allf=t+u,format=yuv420p"

    r1 = subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-f",
            "lavfi",
            "-i",
            grad,
            "-vf",
            vf,
            "-c:v",
            "libx264",
            "-preset",
            "fast",
            "-crf",
            "19",
            "-pix_fmt",
            "yuv420p",
            str(SILENT),
        ],
        capture_output=True,
        text=True,
    )
    if r1.returncode != 0:
        print(r1.stderr[-600:], file=sys.stderr)
        return 1
    print(f"  ✓ {SILENT.name}", flush=True)

    r2 = subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(SILENT),
            "-i",
            str(voice),
            "-filter_complex",
            f"[1:a]apad=whole_dur={dur_video}[aout]",
            "-map",
            "0:v",
            "-map",
            "[aout]",
            "-c:v",
            "copy",
            "-c:a",
            "aac",
            "-b:a",
            "160k",
            "-t",
            f"{dur_video}",
            str(VOICED),
        ],
        capture_output=True,
        text=True,
    )
    if r2.returncode != 0:
        print(r2.stderr[-600:], file=sys.stderr)
        return 1
    print(f"  ✓ {VOICED.name}", flush=True)

    overlay = REPO / ".cursor/output" / "overlay_captions.py"
    r3 = subprocess.run(
        [sys.executable, str(overlay), str(VOICED), str(FINAL)],
        cwd=str(REPO / ".cursor/output"),
    )
    if r3.returncode != 0:
        return r3.returncode
    print(f"  ✓ {FINAL.name}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
