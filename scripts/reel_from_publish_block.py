#!/usr/bin/env python3
"""Build captioned reel from PUBLISH_BLOCK. Usage: python reel_from_publish_block.py path/to/pubblock.md [output.mp4]"""

import json
import sys
import os
import subprocess

def parse_publish_block(path: str) -> dict:
    with open(path) as f:
        text = f.read()
    out = {}
    for line in text.split("\n"):
        if line.startswith("VIDEO_PATH:"):
            out["video_path"] = line.split(":", 1)[1].strip()
        if line.startswith("CAPTION_OVERLAY:"):
            idx = text.index("CAPTION_OVERLAY:")
            rest = text[idx + len("CAPTION_OVERLAY:"):].strip()
            # Find JSON - from { to matching }
            start = rest.find("{")
            if start >= 0:
                depth, i = 0, start
                while i < len(rest):
                    if rest[i] == "{": depth += 1
                    elif rest[i] == "}": depth -= 1
                    if depth == 0:
                        out["captions"] = json.loads(rest[start:i+1])
                        break
                    i += 1
    return out

def main():
    if len(sys.argv) < 2:
        print("Usage: python reel_from_publish_block.py path/to/pubblock.md [output.mp4]", file=sys.stderr)
        sys.exit(1)
    block_path = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else None
    data = parse_publish_block(block_path)
    if "video_path" not in data or "captions" not in data:
        print("Missing VIDEO_PATH or CAPTION_OVERLAY in block", file=sys.stderr)
        sys.exit(1)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cmd = [sys.executable, os.path.join(script_dir, "burn_captions.py"),
           data["video_path"], json.dumps(data["captions"])]
    if output:
        cmd.append(output)
    subprocess.run(cmd, check=True)

if __name__ == "__main__":
    main()
