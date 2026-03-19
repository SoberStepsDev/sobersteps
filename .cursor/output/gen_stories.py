#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, textwrap

OUT = os.path.dirname(os.path.abspath(__file__))
BG_PATH = os.path.join(OUT, "bg.png")
W, H = 1080, 1920

def load_font(name, size):
    paths = [
        f"/System/Library/Fonts/Supplemental/{name}.ttf",
        f"/System/Library/Fonts/{name}.ttf",
        f"/Library/Fonts/{name}.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)

font_sm = load_font("HelveticaNeue", 28)
font_md = load_font("HelveticaNeue-Medium", 44)
font_lg = load_font("HelveticaNeue-Medium", 54)
font_it = load_font("HelveticaNeue-LightItalic", 30)
try:
    font_mono = ImageFont.truetype("/System/Library/Fonts/SFMono-Regular.otf", 26)
except:
    font_mono = load_font("Menlo-Regular", 26)

GOLD = (251, 191, 36)
WHITE = (226, 232, 240)
GRAY = (148, 163, 184)
DIM = (255, 255, 255, 102)

def make_bg(brightness=0.38):
    img = Image.open(BG_PATH).convert("RGBA")
    ratio = max(W / img.width, H / img.height)
    img = img.resize((int(img.width * ratio), int(img.height * ratio)), Image.LANCZOS)
    left = (img.width - W) // 2
    top = (img.height - H) // 2
    img = img.crop((left, top, left + W, top + H))
    dark = Image.new("RGBA", (W, H), (0, 0, 0, int(255 * (1 - brightness))))
    img = Image.alpha_composite(img, dark)
    grad = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(grad)
    for y in range(H):
        if y < H * 0.15:
            a = int(120 * (1 - y / (H * 0.15)))
        elif y > H * 0.6:
            a = int(200 * ((y - H * 0.6) / (H * 0.4)))
        else:
            a = 0
        d.line([(0, y), (W, y)], fill=(0, 0, 0, a))
    return Image.alpha_composite(img, grad)

def draw_text(draw, x, y, text, font, color, max_w=None, line_spacing=8):
    if max_w:
        avg_char_w = font.getlength("x")
        wrap_w = int(max_w / avg_char_w)
        lines = textwrap.wrap(text, width=wrap_w)
    else:
        lines = text.split("\n")
    cy = y
    for line in lines:
        draw.text((x, cy), line, font=font, fill=color)
        bbox = font.getbbox(line)
        cy += (bbox[3] - bbox[1]) + line_spacing
    return cy

# --- STORY 1: "The Double Shift" ---
def story1():
    img = make_bg(0.4)
    draw = ImageDraw.Draw(img)
    draw.text((60, 80), "SOBERSTEPS / BEHIND THE SCREEN", font=font_sm, fill=DIM)
    y = H - 520
    draw.text((60, y), "home after 8 hours.", font=font_it, fill=GRAY)
    y += 50
    draw.text((60, y), "laptop open again.", font=font_it, fill=GRAY)
    y += 70
    lines_main = [
        "not because someone's",
        "paying me.",
    ]
    for l in lines_main:
        draw.text((60, y), l, font=font_lg, fill=WHITE)
        y += 68
    y += 10
    lines_gold = [
        "because someone tonight",
        "might need this to work.",
    ]
    for l in lines_gold:
        draw.text((60, y), l, font=font_lg, fill=GOLD)
        y += 68
    y += 30
    draw.text((60, y), "building the app I wish I had —", font=font_md, fill=GRAY)
    y += 56
    draw.text((60, y), "one evening at a time.", font=font_md, fill=GRAY)
    img.convert("RGB").save(os.path.join(OUT, "story-1-ready.png"), quality=95)
    print("story-1-ready.png ✓")

# --- STORY 2: "The Second Shift" ---
def story2():
    img = make_bg(0.35)
    draw = ImageDraw.Draw(img)
    draw.text((W // 2 - font_mono.getlength("localhost:50145") // 2, H // 2 - 260),
              "localhost:50145", font=font_mono, fill=(99, 102, 241))
    lines = [
        ("the second shift", WHITE),
        ("no one asked me to do.", WHITE),
        ("", WHITE),
        ("I asked myself.", GOLD),
    ]
    y = H // 2 - 170
    for txt, col in lines:
        if txt:
            tw = font_lg.getlength(txt)
            draw.text(((W - tw) // 2, y), txt, font=font_lg, fill=col)
        y += 72
    y += 20
    sub = [
        "some things you build because",
        "you remember what it felt like",
        "to have nothing at 3 AM.",
    ]
    for s in sub:
        tw = font_md.getlength(s)
        draw.text(((W - tw) // 2, y), s, font=font_md, fill=GRAY)
        y += 56
    draw.text((W // 2 - font_sm.getlength("sobersteps — link in bio") // 2, H - 140),
              "sobersteps — link in bio", font=font_sm, fill=DIM)
    img.convert("RGB").save(os.path.join(OUT, "story-2-ready.png"), quality=95)
    print("story-2-ready.png ✓")

# --- STORY 3: "Real. Not a render." ---
def story3():
    img = make_bg(0.32)
    draw = ImageDraw.Draw(img)
    draw.text((W - 60 - font_sm.getlength("REAL. NOT A RENDER."), 80),
              "REAL. NOT A RENDER.", font=font_sm, fill=DIM)
    y = H - 580
    short = ["tired hands.", "cold coffee.", "quiet room."]
    for s in short:
        draw.text((72, y), s, font=font_lg, fill=WHITE)
        y += 72
    y += 24
    italic_line = "this is how it actually looks."
    draw.text((72, y), italic_line, font=font_it, fill=GOLD)
    y += 60
    y += 20
    sub = [
        "no studio. no team. just me,",
        "building something I needed",
        "and didn't find.",
    ]
    for s in sub:
        draw.text((72, y), s, font=font_md, fill=GRAY)
        y += 56
    img.convert("RGB").save(os.path.join(OUT, "story-3-ready.png"), quality=95)
    print("story-3-ready.png ✓")

story1()
story2()
story3()
print("Done — 3 stories ready in", OUT)
