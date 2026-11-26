"""Regenerate the placeholder branding PNGs: a plain "S" monogram.

Pure stdlib (zlib/struct), no dependencies. Run from skeleton/:
    python3 tool/generate_branding.py
then regenerate platform files:
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create

shortcut: placeholder monogram drawn from two arcs, replace with real artwork
before release.
"""
import math
import struct
import zlib

BG = (0x3B, 0x4A, 0x5C)
FG = (0xF2, 0xF4, 0xF7)
SS = 3  # samples per axis for anti-aliasing


def _arc_dist(px, py, cx, cy, r, a0, a1):
    """Distance from (px, py) to the arc centre (cx, cy), radius r, angles a0..a1."""
    dx, dy = px - cx, py - cy
    ang = math.atan2(dy, dx)
    lo, hi = min(a0, a1), max(a0, a1)
    for k in (-2, -1, 0, 1, 2):
        if lo <= ang + k * 2 * math.pi <= hi:
            return abs(math.hypot(dx, dy) - r)
    return min(
        math.hypot(px - (cx + r * math.cos(a)), py - (cy + r * math.sin(a)))
        for a in (a0, a1)
    )


def _s_coverage(u, v, r, half):
    """True when unit-space point (u, v), origin at the centre, is inside the S."""
    d1 = _arc_dist(u, v, 0, -r, r, math.radians(-270), math.radians(-40))
    d2 = _arc_dist(u, v, 0, r, r, math.radians(-90), math.radians(140))
    return min(d1, d2) <= half


def _png(path, w, h, pixels, alpha):
    ch = 4 if alpha else 3
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw += pixels[y * w * ch:(y + 1) * w * ch]

    def chunk(t, d):
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF)

    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6 if alpha else 2, 0, 0, 0)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr)
                + chunk(b'IDAT', zlib.compress(bytes(raw), 9))
                + chunk(b'IEND', b''))


def render(path, w, h, s_height, background):
    """Draw the S, `s_height` of the shorter side tall; background None = transparent."""
    short = min(w, h)
    half_stroke = 0.09 * s_height / 0.65 * 0.5  # stroke is 0.09 of unit at 0.65 height
    r = 0.14 * s_height / 0.65
    px = bytearray()
    margin = 0.5 * s_height + 0.02
    for y in range(h):
        for x in range(w):
            u0 = (x - w / 2) / short
            v0 = (y - h / 2) / short
            if abs(u0) > margin or abs(v0) > margin:
                cov = 0.0
            else:
                hit = 0
                for sy in range(SS):
                    for sx in range(SS):
                        u = (x + (sx + 0.5) / SS - w / 2) / short
                        v = (y + (sy + 0.5) / SS - h / 2) / short
                        hit += _s_coverage(u, v, r, half_stroke)
                cov = hit / (SS * SS)
            if background is None:
                px += bytes(FG) + bytes([round(255 * cov)])
            else:
                px += bytes(round(b + (f - b) * cov) for b, f in zip(background, FG))
                px += b'\xff'
    _png(path, w, h, px, True)


if __name__ == '__main__':
    out = 'assets/branding/'
    render(out + 'icon.png', 1024, 1024, 0.65, BG)
    render(out + 'icon_foreground.png', 1024, 1024, 0.45, None)
    render(out + 'splash.png', 1024, 1024, 0.45, None)
    render(out + 'og.png', 1200, 630, 0.5, BG)
