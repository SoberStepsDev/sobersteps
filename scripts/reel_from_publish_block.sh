#!/bin/bash
# Build captioned reel from PUBLISH_BLOCK. Usage: ./reel_from_publish_block.sh path/to/pubblock.md
set -e
BLOCK="$1"
[[ -z "$BLOCK" ]] && { echo "Usage: $0 path/to/pubblock.md"; exit 1; }
VIDEO=$(grep '^VIDEO_PATH:' "$BLOCK" | cut -d: -f2- | xargs)
[[ -z "$VIDEO" ]] && VIDEO=$(grep '^VIDEO_PATH:' "$BLOCK" | sed 's/VIDEO_PATH: *//')
# Extract CAPTION_OVERLAY JSON (single line)
JSON=$(sed -n '/^CAPTION_OVERLAY:$/,/^[A-Z]/p' "$BLOCK" | tail -n +2 | head -n -1 | tr -d '\n' | sed 's/^[[:space:]]*//')
[[ -z "$JSON" ]] && JSON=$(grep -A1 '^CAPTION_OVERLAY:' "$BLOCK" | tail -1)
python3 "$(dirname "$0")/burn_captions.py" "$VIDEO" "$JSON"
