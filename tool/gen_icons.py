#!/usr/bin/env python3
"""Generate AniWorthy branding PNGs with no third-party dependencies.

Draws the AniWorthy mark — a bold question mark inside a rounded gradient
tile — as:
  <app_root>/assets/images/app_icon.png             (512, gradient background)
  <app_root>/assets/images/app_icon_foreground.png  (1024, transparent, adaptive)
  <app_root>/assets/images/splash_logo.png          (512, transparent)
  <app_root>/assets/images/play_icon_512.png        (512, Play Store icon)

Usage:
  python3 gen_icons.py [app_root]     (default: current directory)
"""
import math
import struct
import sys
import zlib
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
OUT = APP_ROOT / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

BG = (0x0E, 0x0B, 0x1F)
PINK = (0xFF, 0x4F, 0x9D)
VIOLET = (0x7C, 0x5C, 0xFF)


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def write_png(path, width, height, pixels):
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))
    compressed = zlib.compress(bytes(raw), 9)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data +
                struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) +
           chunk(b"IDAT", compressed) + chunk(b"IEND", b""))
    path.write_bytes(png)


def _edge(d):
    if d >= 0.5:
        return 1.0
    if d <= -0.5:
        return 0.0
    return d + 0.5


def rounded_square_bg(x, y, cx, cy, half, radius):
    dx = abs(x - cx) - (half - radius)
    dy = abs(y - cy) - (half - radius)
    dx = max(dx, 0.0)
    dy = max(dy, 0.0)
    return _edge(radius - math.hypot(dx, dy))


def disc_coverage(x, y, cx, cy, r):
    return _edge(r - math.hypot(x - cx, y - cy))


def ring_coverage(x, y, cx, cy, r, half_w):
    return _edge(half_w - abs(math.hypot(x - cx, y - cy) - r))


def arc_coverage(x, y, cx, cy, r, half_w, start_deg, end_deg):
    """Coverage of a stroked arc between [start_deg, end_deg] (deg, y-down)."""
    if ring_coverage(x, y, cx, cy, r, half_w) <= 0:
        return 0.0
    ang = math.degrees(math.atan2(y - cy, x - cx)) % 360.0
    s = start_deg % 360.0
    e = end_deg % 360.0
    if s <= e:
        inside = s <= ang <= e
    else:
        inside = ang >= s or ang <= e
    return 1.0 if inside else 0.0


def segment_coverage(x, y, ax, ay, bx, by, half_w):
    vx, vy = bx - ax, by - ay
    wx, wy = x - ax, y - ay
    seg_len2 = vx * vx + vy * vy
    t = 0.0 if seg_len2 == 0 else max(0.0, min(1.0, (wx * vx + wy * vy) / seg_len2))
    px, py = ax + t * vx, ay + t * vy
    return _edge(half_w - math.hypot(x - px, y - py))


def render(size, with_background, scale=1.0, supersample=2):
    pixels = [[(0, 0, 0, 0)] * size for _ in range(size)]
    cx = cy = size / 2.0

    box = (size / 2.0) * 0.74 * scale
    x0, y0, x1, y1 = cx - box, cy - box, cx + box, cy + box

    # Question mark geometry (relative to the box).
    q_hook_cx = cx
    q_hook_cy = y0 + (y1 - y0) * 0.34          # centre of the upper hook circle
    q_hook_r = (x1 - x0) * 0.205               # radius of the hook
    hook_hw = (x1 - x0) * 0.060                # stroke half-width

    stem_top = q_hook_cy + q_hook_r * 0.55
    stem_bot = y0 + (y1 - y0) * 0.63
    dot_cy = y0 + (y1 - y0) * 0.85
    dot_r = hook_hw * 1.12

    ss = supersample
    n = ss * ss
    for py in range(size):
        for px in range(size):
            acc = [0.0, 0.0, 0.0, 0.0]
            for sy in range(ss):
                for sx in range(ss):
                    fx = px + (sx + 0.5) / ss
                    fy = py + (sy + 0.5) / ss

                    r = g = b = 0.0
                    a = 0.0

                    if with_background:
                        bg_a = rounded_square_bg(
                            fx, fy, cx, cy, size * 0.5, size * 0.24)
                        sheen = max(0.0, min(1.0, (fx + fy) / (2 * size)))
                        bg_rgb = lerp(BG, (0x22, 0x1B, 0x44), sheen * 0.95)
                        r, g, b, a = bg_rgb[0], bg_rgb[1], bg_rgb[2], bg_a

                    gt = max(0.0, min(1.0, ((fx - x0) + (fy - y0)) / (2 * box)))
                    mark_rgb = lerp(PINK, VIOLET, gt)

                    # Hook: a ring, then carve the bottom so it opens into the
                    # stem. We build coverage as: ring minus nothing; the stem
                    # overlaps and the dot is separate.
                    cov = 0.0
                    # Open hook: a wide gap at the bottom (45-135 deg) so the
                    # shape reads as a question mark rather than a closed ring.
                    cov = max(cov, arc_coverage(
                        fx, fy, q_hook_cx, q_hook_cy, q_hook_r, hook_hw,
                        135.0, 45.0))
                    # Stem: from the centre of the hook straight down.
                    cov = max(cov, segment_coverage(
                        fx, fy, cx, q_hook_cy,
                        cx, stem_bot, hook_hw))
                    # Dot.
                    cov = max(cov, disc_coverage(fx, fy, cx, dot_cy, dot_r))

                    if cov > 0:
                        ta = cov
                        r = r * (1 - ta) + mark_rgb[0] * ta
                        g = g * (1 - ta) + mark_rgb[1] * ta
                        b = b * (1 - ta) + mark_rgb[2] * ta
                        a = a * (1 - ta) + 1.0 * ta

                    acc[0] += r * a
                    acc[1] += g * a
                    acc[2] += b * a
                    acc[3] += a

            alpha = acc[3] / n
            if alpha <= 0.0001:
                pixels[py][px] = (0, 0, 0, 0)
            else:
                pixels[py][px] = (
                    int(round(min(255.0, acc[0] / acc[3]))),
                    int(round(min(255.0, acc[1] / acc[3]))),
                    int(round(min(255.0, acc[2] / acc[3]))),
                    int(round(alpha * 255)),
                )
    return pixels


def main():
    icon = render(512, with_background=True, scale=1.0)
    write_png(OUT / "app_icon.png", 512, 512, icon)
    write_png(OUT / "play_icon_512.png", 512, 512, icon)

    fg = render(1024, with_background=False, scale=0.84)
    write_png(OUT / "app_icon_foreground.png", 1024, 1024, fg)

    splash = render(512, with_background=False, scale=0.95)
    write_png(OUT / "splash_logo.png", 512, 512, splash)

    for name in ("app_icon.png", "app_icon_foreground.png",
                 "splash_logo.png", "play_icon_512.png"):
        p = OUT / name
        print(f"  {name}: {p.stat().st_size} bytes")


if __name__ == "__main__":
    main()
