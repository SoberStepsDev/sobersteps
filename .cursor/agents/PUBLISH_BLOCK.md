# PUBLISH_BLOCK — shared format

Used by sobersteps-content-publisher (output) and sobersteps-social-publisher (input).

```
TYPE: reel|image
PLATFORMS: IG,TikTok|X,LinkedIn
VIDEO_PATH: content_videos/subfolder/filename.mp4
DATETIME_UTC: YYYY-MM-DDTHH:MM:SSZ

HOOK:
MIDDLE:
CLOSE:

CAPTION:
...
https://soberstepsdev.github.io/sobersteps/

HASHTAGS: #SoberSteps ...

CAPTION_OVERLAY: {"captions":[{"start", "end", "text", "fade_in", "fade_out"}]}
```

Image: add HEADLINE, IMAGE_SPEC (1080×1080).
