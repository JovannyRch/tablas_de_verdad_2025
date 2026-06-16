#!/usr/bin/env python3
"""Generates the launcher icon assets for Tablas de Verdad.

Produces three 1024x1024 PNGs (rendered 4x then downscaled for crisp edges):
  assets/icon.png            full icon (iOS / legacy / web)  — gradient bg + grid
  assets/icon_background.png  Android adaptive background     — gradient only
  assets/icon_foreground.png  Android adaptive foreground     — grid, safe-zoned

Design: brand-orange gradient with a 2x2 grid of white rounded tiles, each
bearing a logic operator (∨ → ¬ ∧) in orange. Language-neutral.
"""

from PIL import Image, ImageDraw, ImageFilter

S = 4                      # supersampling factor
OUT = 1024
N = OUT * S                # working canvas

# ── Brand palette ────────────────────────────────────────────
BG_TOP = (255, 173, 84)    # #FFAD54  warm light orange
BG_BOT = (244, 121, 7)     # #F47907  deeper orange
TILE = (255, 255, 255)
OP = (243, 124, 0)         # #F37C00  operator orange on white


def vgradient(w, h, top, bottom):
    """Vertical (slightly diagonal) gradient image."""
    base = Image.new("RGB", (w, h), top)
    draw = ImageDraw.Draw(base)
    for y in range(h):
        t = y / (h - 1)
        r = round(top[0] + (bottom[0] - top[0]) * t)
        g = round(top[1] + (bottom[1] - top[1]) * t)
        b = round(top[2] + (bottom[2] - top[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return base


def round_poly(draw, pts, width, color):
    """Polyline with rounded joints and caps."""
    draw.line(pts, fill=color, width=width, joint="curve")
    rad = width // 2
    for (x, y) in pts:
        draw.ellipse([x - rad, y - rad, x + rad, y + rad], fill=color)


def draw_op(draw, kind, cx, cy, box, w):
    """Draw a logic operator centered at (cx, cy) within a `box`-sized area."""
    h = box / 2
    if kind == "or":      # ∨
        round_poly(draw, [(cx - h, cy - h), (cx, cy + h), (cx + h, cy - h)], w, OP)
    elif kind == "and":   # ∧
        round_poly(draw, [(cx - h, cy + h), (cx, cy - h), (cx + h, cy + h)], w, OP)
    elif kind == "not":   # ¬
        round_poly(
            draw,
            [(cx - h, cy - 0.18 * box), (cx + h, cy - 0.18 * box),
             (cx + h, cy + 0.30 * box)],
            w, OP,
        )
    elif kind == "imp":   # →
        tip = cx + h
        round_poly(draw, [(cx - h, cy), (tip, cy)], w, OP)                  # shaft
        round_poly(draw, [(tip - 0.42 * box, cy - 0.34 * box), (tip, cy)], w, OP)  # head up
        round_poly(draw, [(tip - 0.42 * box, cy + 0.34 * box), (tip, cy)], w, OP)  # head down


def draw_grid(img, motif):
    """Draw the 2x2 tile grid spanning `motif` px, centered, with soft shadow."""
    cx = cy = N / 2
    gap = motif * 0.07
    ts = (motif - gap) / 2          # tile side
    rad = int(ts * 0.24)            # corner radius
    op_box = ts * 0.46              # operator extent inside a tile
    op_w = max(2, int(ts * 0.11))   # operator stroke width

    # tile top-left origins
    left = cx - motif / 2
    top = cy - motif / 2
    cells = [
        (left,            top,            "or"),
        (left + ts + gap, top,            "imp"),
        (left,            top + ts + gap, "not"),
        (left + ts + gap, top + ts + gap, "and"),
    ]

    # soft drop shadow
    shadow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    for (x, y, _) in cells:
        sdraw.rounded_rectangle([x, y, x + ts, y + ts], radius=rad,
                                fill=(60, 28, 0, 95))
    shadow = shadow.filter(ImageFilter.GaussianBlur(ts * 0.06))
    shadow = Image.eval(shadow, lambda p: p)  # noop keep
    img.alpha_composite(shadow, (0, int(ts * 0.045)))

    # tiles + operators
    draw = ImageDraw.Draw(img)
    for (x, y, kind) in cells:
        draw.rounded_rectangle([x, y, x + ts, y + ts], radius=rad, fill=TILE)
        draw_op(draw, kind, x + ts / 2, y + ts / 2, op_box, op_w)


def build_full():
    img = vgradient(N, N, BG_TOP, BG_BOT).convert("RGBA")
    draw_grid(img, motif=N * 0.66)
    return img


def build_background():
    return vgradient(N, N, BG_TOP, BG_BOT).convert("RGBA")


def build_foreground():
    # flutter_launcher_icons wraps this in a 16% inset, which already provides
    # the adaptive safe-zone margin, so the motif can fill like the full icon.
    img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    draw_grid(img, motif=N * 0.66)
    return img


def build_splash():
    """Centered rounded-square logo mark on transparent bg (no text), so the
    native splash works on both light and dark backgrounds and in any
    language."""
    img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    mark = int(N * 0.52)
    rad = int(mark * 0.22)
    x0 = (N - mark) // 2
    y0 = (N - mark) // 2

    # soft shadow under the mark
    shadow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x0, y0, x0 + mark, y0 + mark], radius=rad, fill=(60, 28, 0, 70)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(mark * 0.03))
    img.alpha_composite(shadow, (0, int(mark * 0.02)))

    # gradient-filled rounded square
    grad = vgradient(N, N, BG_TOP, BG_BOT).convert("RGBA")
    mask = Image.new("L", (N, N), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [x0, y0, x0 + mark, y0 + mark], radius=rad, fill=255
    )
    img.paste(grad, (0, 0), mask)

    # the operator grid, sized to sit inside the mark
    draw_grid(img, motif=mark * 0.66)
    return img


def save(img, path, size=OUT):
    img.resize((size, size), Image.LANCZOS).save(path)
    print("wrote", path)


if __name__ == "__main__":
    save(build_full(), "assets/icon.png")
    save(build_background(), "assets/icon_background.png")
    save(build_foreground(), "assets/icon_foreground.png")
    save(build_splash(), "assets/splash.png", size=1152)
