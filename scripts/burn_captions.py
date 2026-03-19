#!/usr/bin/env python3
"""Burn CAPTION_OVERLAY into video. Uses ffmpeg + ASS. Run: python scripts/burn_captions.py VIDEO_PATH CAPTIONS_JSON [OUTPUT_PATH]"""

import json
import subprocess
import sys
import tempfile
import os

# SoberSteps: text #E2E8F0, font Inter-style, centered, safe zone
ASS_HEADER = """[Script Info]
Title: SoberSteps Reel
ScriptType: v4.00+
WrapStyle: 0

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Inter,48,&H00E2E8F0,&H80000000,0,0,1,2,1,2,40,40,180,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

def sec_to_ass(sec: float) -> str:
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    cs = int((sec % 1) * 100)
    return f"{h}:{m:02d}:{s:02d}.{cs:02d}"

def mk_ass(captions: list) -> str:
    lines = [ASS_HEADER]
    for c in captions:
        fi = int((c.get("fade_in") or 0.3) * 1000)
        fo = int((c.get("fade_out") or 0.3) * 1000)
        txt = c["text"].replace("\n", "\\N")
        line = f"Dialogue: 0,{sec_to_ass(c['start'])},{sec_to_ass(c['end'])},Default,,0,0,0,,{{\\fad({fi},{fo})}}{txt}"
        lines.append(line)
    return "\n".join(lines)

def main():
    if len(sys.argv) < 3:
        print("Usage: python burn_captions.py VIDEO_PATH CAPTIONS_JSON [OUTPUT_PATH]", file=sys.stderr)
        sys.exit(1)
    video_path = sys.argv[1]
    captions_arg = sys.argv[2]
    output_path = sys.argv[3] if len(sys.argv) > 3 else None

    if not os.path.isfile(video_path):
        print(f"Video not found: {video_path}", file=sys.stderr)
        sys.exit(1)

    # Parse captions: file path or JSON string
    if captions_arg.endswith(".json") or os.path.isfile(captions_arg):
        with open(captions_arg) as f:
            data = json.load(f)
    else:
        data = json.loads(captions_arg)
    captions = data.get("captions", data) if isinstance(data, dict) else data

    ass_content = mk_ass(captions)
    base, _ = os.path.splitext(video_path)
    if not output_path:
        # Prefer same dir as video; fallback to cwd
        out_dir = os.path.dirname(video_path)
        base_name = os.path.basename(base)
        output_path = os.path.join(out_dir, f"{base_name}_captioned.mp4")

    # Save ASS next to output for manual import if ffmpeg lacks libass
    ass_path = os.path.join(os.path.dirname(output_path), os.path.splitext(os.path.basename(video_path))[0] + "_captions.ass")
    with open(ass_path, "w", encoding="utf-8") as f:
        f.write(ass_content)

    # ass filter requires libass; try ass=filename=path then subtitles=
    for vf_arg in [f"ass=filename='{ass_path}'", f"subtitles={repr(ass_path)}"]:
        cmd = [
            "ffmpeg", "-y", "-i", video_path, "-vf", vf_arg,
            "-c:a", "copy", "-c:v", "libx264", "-preset", "fast", "-crf", "23",
            output_path
        ]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode == 0:
            print(f"Output: {output_path}")
            return
        if "No such filter" in r.stderr or "Filter not found" in r.stderr:
            continue

    print("ffmpeg lacks libass. Install: brew reinstall ffmpeg", file=sys.stderr)
    print(f"ASS saved: {ass_path} — import in CapCut / DaVinci / Shotcut, then export", file=sys.stderr)
    print(f"Output path would be: {output_path}", file=sys.stderr)

if __name__ == "__main__":
    main()
