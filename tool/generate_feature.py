#!/usr/bin/env python3
"""Google Play feature graphic (1024x500) for Tablas de Verdad.

Language-neutral: the centered logo mark over a brand-orange gradient, with a
faint scatter of logic operators for texture. No text. Rendered at 4x and
downscaled for crisp edges.
"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from PIL import Image, ImageDraw  # noqa: E402
from generate_icon import (  # noqa: E402
    S, BG_TOP, BG_BOT, vgradient, draw_op, draw_mark,
)

FW, FH = 1024, 500
W, H = FW * S, FH * S


def build():
    img = vgradient(W, H, BG_TOP, BG_BOT).convert("RGBA")

    # Faint white logic operators, scattered to the sides (avoid the center
    # where the mark sits). Coordinates as fractions of the 1024x500 frame:
    # (kind, x, y, size, opacity)
    deco = [
        ("and", 0.11, 0.30, 0.30, 0.18),
        ("or",  0.05, 0.70, 0.24, 0.15),
        ("imp", 0.19, 0.82, 0.22, 0.16),
        ("not", 0.26, 0.20, 0.18, 0.13),
        ("not", 0.90, 0.26, 0.26, 0.17),
        ("imp", 0.81, 0.70, 0.28, 0.16),
        ("or",  0.95, 0.74, 0.20, 0.14),
        ("and", 0.74, 0.22, 0.18, 0.13),
    ]
    for kind, fx, fy, fsize, op in deco:
        layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        box = fsize * H
        w = max(2, int(box * 0.13))
        draw_op(d, kind, fx * W, fy * H, box, w, color=(255, 255, 255, 255))
        alpha = layer.split()[3].point(lambda a, o=op: int(a * o))
        layer.putalpha(alpha)
        img.alpha_composite(layer)

    # Centered logo mark
    draw_mark(img, W / 2, H / 2, int(H * 0.70))

    return img.resize((FW, FH), Image.LANCZOS)


if __name__ == "__main__":
    out = "playstore/play_feature_1024x500.png"
    build().convert("RGB").save(out)
    print("wrote", out)
