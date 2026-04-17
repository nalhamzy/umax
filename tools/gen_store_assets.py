"""UMAX - full store-asset generator.

Emits to `store_assets/`:
  feature_graphic_1024x500.png
  og_card_1200x630.png
  phone/01_home.png ... 05_paywall.png    (1290x2796)
  tablet/01_home.png ... 05_paywall.png   (2064x2752)
  android/icon-512.png

Dark luxe theme with electric purple + coral accents.
"""
from __future__ import annotations
import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "store_assets")
ICON_PATH = os.path.join(
    ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset",
    "Icon-App-1024x1024@1x.png",
)

BG = (11, 11, 20)
BG_ELEV = (20, 20, 31)
CARD = (28, 28, 43)
BORDER = (38, 38, 56)
TEXT = (242, 242, 247)
T2 = (155, 155, 179)
MUTE = (92, 92, 117)
ACCENT = (123, 97, 255)     # electric purple
ACCENT2 = (0, 229, 209)     # cyan
ACCENT3 = (255, 61, 113)    # coral
GOLD = (255, 199, 95)
SUCCESS = (0, 209, 122)
WARN = (255, 181, 71)

PHONE_W, PHONE_H = 1290, 2796
TABLET_W, TABLET_H = 2064, 2752


def _font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/seguibl.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def _glow(w, h, cx, cy, color, max_r, alpha_peak=120, steps=24):
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps):
        t = 1 - i / steps
        alpha = int(alpha_peak * t * t)
        rr = int(max_r * (1 - i / steps))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr],
                  fill=(color[0], color[1], color[2], alpha))
    return layer.filter(ImageFilter.GaussianBlur(max_r // 6))


def _bg(w, h):
    base = Image.new("RGBA", (w, h), BG + (255,))
    base.alpha_composite(_glow(w, h, int(w * 0.2), int(h * 0.15),
                               ACCENT, max_r=w, alpha_peak=90))
    base.alpha_composite(_glow(w, h, int(w * 0.85), int(h * 0.85),
                               ACCENT3, max_r=w, alpha_peak=70))
    return base


def _rr(d, box, r, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, radius=r, fill=fill, outline=outline, width=width)


def _wrap(text, font, max_w):
    words = text.split()
    lines, cur = [], ""
    d = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    for w in words:
        trial = (cur + " " + w).strip()
        if d.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines


def _text_center(img, text, y, font, fill, max_w):
    d = ImageDraw.Draw(img)
    for line in _wrap(text, font, max_w):
        bbox = d.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        d.text(((img.width - tw) // 2, y), line, font=font, fill=fill)
        y += int((bbox[3] - bbox[1]) * 1.25)


def _device(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = int(min(w, h) * 0.09)
    _rr(d, [0, 0, w, h], r, fill=(14, 14, 22, 255))
    inset = 18
    _rr(d, [inset, inset, w - inset, h - inset], r - inset // 2, fill=BG + (255,))
    iw, ih = int(w * 0.32), int(w * 0.09)
    ix = (w - iw) // 2
    iy = int(w * 0.05)
    _rr(d, [ix, iy, ix + iw, iy + ih], ih // 2, fill=(6, 6, 12, 255))
    return img, (inset, inset, w - inset, h - inset)


def _header(canvas, title, subtitle=""):
    ft = _font(120, bold=True)
    fs = _font(56)
    y = int(canvas.height * 0.05)
    _text_center(canvas, title, y, ft, TEXT + (255,),
                 int(canvas.width * 0.86))
    if subtitle:
        d = ImageDraw.Draw(canvas)
        bbox = d.textbbox((0, 0), title, font=ft)
        lines = len(_wrap(title, ft, int(canvas.width * 0.86)))
        y += lines * int((bbox[3] - bbox[1]) * 1.25) + 20
        _text_center(canvas, subtitle, y, fs, ACCENT2 + (255,),
                     int(canvas.width * 0.8))
    return int(canvas.height * 0.28)


def _score_ring(ui, cx, cy, radius, score, color):
    """Draw a circular progress ring showing score/100."""
    d = ImageDraw.Draw(ui)
    # Background track
    stroke = int(radius * 0.12)
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
              outline=BORDER + (255,), width=stroke)
    # Arc
    # PIL arcs start at 3 o'clock; we want to start at 12 o'clock (-90deg)
    deg = 360 * (score / 100)
    for w in range(stroke):
        d.arc([cx - radius + w // 2, cy - radius + w // 2,
               cx + radius - w // 2, cy + radius - w // 2],
              start=-90, end=-90 + deg, fill=color + (255,), width=1)
    # Score text
    f = _font(int(radius * 0.9), bold=True)
    s = f"{int(score)}"
    tw = d.textlength(s, font=f)
    bbox = d.textbbox((0, 0), s, font=f)
    th = bbox[3] - bbox[1]
    d.text((cx - tw / 2, cy - th / 2 - bbox[1] // 2 - 10),
           s, font=f, fill=TEXT + (255,))
    f2 = _font(int(radius * 0.18), bold=True)
    lbl = "OVERALL"
    lw = d.textlength(lbl, font=f2)
    d.text((cx - lw / 2, cy + radius // 3 + 10), lbl, font=f2, fill=T2 + (255,))


def _paint_home(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:41",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    # Top bar: streak + pro badge
    _rr(d, [pad, y, pad + 260, y + 80], 40, fill=CARD + (255,))
    d.text((pad + 30, y + 24), "STREAK", font=_font(22, bold=True), fill=T2)
    d.text((pad + 150, y + 18), "12", font=_font(42, bold=True), fill=GOLD)
    # Pro badge
    _rr(d, [W - pad - 210, y, W - pad, y + 80], 40, fill=GOLD + (255,))
    f = _font(24, bold=True)
    tw = d.textlength("UMAX PRO", font=f)
    d.text((W - pad - 210 + (210 - tw) / 2, y + 26), "UMAX PRO", font=f, fill=BG)
    y += 110

    # Score hero card
    _rr(d, [pad, y, W - pad, y + 860], 36, fill=CARD + (255,),
        outline=BORDER + (255,), width=2)
    ui.alpha_composite(_glow(W, H, W // 2, y + 340, ACCENT,
                              max_r=520, alpha_peak=130), (0, 0))
    d = ImageDraw.Draw(ui)
    d.text((pad + 40, y + 36), "LATEST SCAN",
           font=_font(22, bold=True), fill=T2)
    d.text((pad + 40, y + 70), "2 hrs ago  -  Front light",
           font=_font(26), fill=MUTE)
    _score_ring(ui, W // 2, y + 360, 240, 82, GOLD)
    # Mini stats row
    mini_y = y + 640
    stats = [("Jawline", "78", ACCENT2), ("Symmetry", "86", ACCENT),
             ("Skin", "82", ACCENT3)]
    sw = (W - 2 * pad - 80) // 3
    for i, (label, val, col) in enumerate(stats):
        sx = pad + 40 + i * sw
        _rr(d, [sx, mini_y, sx + sw - 20, mini_y + 160], 24,
            fill=BG_ELEV + (255,), outline=BORDER + (255,), width=2)
        f1 = _font(48, bold=True)
        vw = d.textlength(val, font=f1)
        d.text((sx + (sw - 20) / 2 - vw / 2, mini_y + 20),
               val, font=f1, fill=col)
        fl = _font(22, bold=True)
        lw = d.textlength(label, font=fl)
        d.text((sx + (sw - 20) / 2 - lw / 2, mini_y + 100),
               label, font=fl, fill=T2)
    y += 900

    # Quick actions
    actions = [("New scan", ACCENT, "+"), ("Routine", ACCENT2, ">"),
               ("History", ACCENT3, "H")]
    aw = (W - 2 * pad - 40) // 3
    for i, (lbl, col, g) in enumerate(actions):
        ax = pad + i * (aw + 20)
        _rr(d, [ax, y, ax + aw, y + 220], 28, fill=CARD + (255,),
            outline=col + (255,), width=3)
        # Icon circle
        gx, gy = ax + aw // 2 - 40, y + 30
        d.ellipse([gx, gy, gx + 80, gy + 80], fill=col + (255,))
        f = _font(52, bold=True)
        gw = d.textlength(g, font=f)
        d.text((gx + 40 - gw / 2, gy + 12), g, font=f, fill=BG)
        f2 = _font(28, bold=True)
        tw = d.textlength(lbl, font=f2)
        d.text((ax + aw / 2 - tw / 2, y + 140), lbl, font=f2, fill=TEXT)


def _paint_scan(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:42",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "NEW SCAN", font=_font(28, bold=True), fill=ACCENT2)
    y += 48
    d.text((pad, y), "Align your face", font=_font(72, bold=True), fill=TEXT)
    y += 120

    # Camera preview area with face outline guide
    cam_h = 1600
    _rr(d, [pad, y, W - pad, y + cam_h], 40, fill=(15, 15, 24, 255))
    # Face oval guide
    fx1 = pad + 220
    fy1 = y + 200
    fx2 = W - pad - 220
    fy2 = y + cam_h - 240
    # Dashed-ish outline (many short arcs)
    d.ellipse([fx1, fy1, fx2, fy2], outline=ACCENT + (255,), width=10)
    # Tint inside
    ui.alpha_composite(_glow(W, H, (fx1 + fx2) // 2, (fy1 + fy2) // 2,
                              ACCENT, max_r=500, alpha_peak=70), (0, 0))
    d = ImageDraw.Draw(ui)
    # Corner brackets
    brack = 70
    thick = 8
    corners = [(pad + 60, y + 60), (W - pad - 60 - brack, y + 60),
               (pad + 60, y + cam_h - 60 - brack),
               (W - pad - 60 - brack, y + cam_h - 60 - brack)]
    for cx, cy in corners:
        d.line([cx, cy, cx + brack, cy], fill=ACCENT2, width=thick)
        d.line([cx, cy, cx, cy + brack], fill=ACCENT2, width=thick)
    # Center hint pill
    hint = "Hold steady - front light"
    f = _font(28, bold=True)
    hw = d.textlength(hint, font=f)
    _rr(d, [W // 2 - int(hw / 2) - 40, fy2 + 40,
            W // 2 + int(hw / 2) + 40, fy2 + 110], 35,
        fill=(0, 0, 0, 200))
    d.text((W // 2 - hw / 2, fy2 + 58), hint, font=f, fill=TEXT)
    y += cam_h + 40

    # Checklist
    checks = [("Even lighting", True, ACCENT2),
              ("Face centered", True, ACCENT2),
              ("No filters", True, SUCCESS)]
    cw = (W - 2 * pad) // 3
    for i, (lbl, ok, col) in enumerate(checks):
        cx = pad + i * cw
        # Check circle
        ccx, ccy = cx + cw // 2, y + 30
        d.ellipse([ccx - 30, ccy, ccx + 30, ccy + 60], fill=col + (255,))
        d.line([ccx - 14, ccy + 30, ccx - 4, ccy + 40], fill=BG, width=6)
        d.line([ccx - 4, ccy + 40, ccx + 16, ccy + 18], fill=BG, width=6)
        f = _font(22, bold=True)
        lw = d.textlength(lbl, font=f)
        d.text((cx + cw / 2 - lw / 2, y + 110), lbl, font=f, fill=T2)
    y += 180

    # Capture button
    cap_r = 90
    cx, cy = W // 2, y + cap_r + 20
    ui.alpha_composite(_glow(W, H, cx, cy, ACCENT, 250, alpha_peak=150), (0, 0))
    d = ImageDraw.Draw(ui)
    d.ellipse([cx - cap_r - 12, cy - cap_r - 12, cx + cap_r + 12, cy + cap_r + 12],
              outline=ACCENT + (255,), width=8)
    d.ellipse([cx - cap_r, cy - cap_r, cx + cap_r, cy + cap_r],
              fill=ACCENT + (255,))


def _paint_result(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:43",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "< Back", font=_font(28, bold=True), fill=T2)
    y += 60
    d.text((pad, y), "Your score", font=_font(76, bold=True), fill=TEXT)
    y += 100
    d.text((pad, y), "Scanned April 17, 2026",
           font=_font(26), fill=MUTE)
    y += 70

    # Big score ring
    ui.alpha_composite(_glow(W, H, W // 2, y + 340, GOLD, 520, alpha_peak=140), (0, 0))
    d = ImageDraw.Draw(ui)
    _score_ring(ui, W // 2, y + 340, 300, 82, GOLD)
    y += 700

    # Traits bars
    traits = [("Jawline", 78, ACCENT2), ("Symmetry", 86, ACCENT),
              ("Skin clarity", 82, ACCENT3), ("Eye area", 74, GOLD),
              ("Harmony", 80, SUCCESS)]
    for name, val, col in traits:
        d.text((pad, y), name, font=_font(30, bold=True), fill=TEXT)
        f = _font(30, bold=True)
        vs = f"{val}"
        vw = d.textlength(vs, font=f)
        d.text((W - pad - vw, y), vs, font=f, fill=col)
        # Bar
        by = y + 58
        bw = W - 2 * pad
        _rr(d, [pad, by, pad + bw, by + 20], 10, fill=BORDER + (255,))
        _rr(d, [pad, by, pad + int(bw * val / 100), by + 20], 10,
            fill=col + (255,))
        y += 120

    y += 30
    # Primary CTA
    _rr(d, [pad, y, W - pad, y + 140], 34, fill=ACCENT + (255,))
    f = _font(40, bold=True)
    tw = d.textlength("Get my routine", font=f)
    d.text(((W - tw) / 2, y + 48), "Get my routine", font=f, fill=TEXT)


def _paint_routine(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:44",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "7-DAY PROTOCOL", font=_font(28, bold=True), fill=ACCENT)
    y += 48
    d.text((pad, y), "Your routine", font=_font(72, bold=True), fill=TEXT)
    y += 100
    d.text((pad, y), "Personalized from your scan.",
           font=_font(28), fill=T2)
    y += 90

    # Progress card
    _rr(d, [pad, y, W - pad, y + 200], 32, fill=CARD + (255,),
        outline=BORDER + (255,), width=2)
    d.text((pad + 40, y + 32), "DAY 4 OF 7",
           font=_font(22, bold=True), fill=ACCENT)
    d.text((pad + 40, y + 70), "6 of 8 tasks done",
           font=_font(40, bold=True), fill=TEXT)
    bx, by = pad + 40, y + 150
    bw = W - 2 * pad - 80
    _rr(d, [bx, by, bx + bw, by + 24], 12, fill=BORDER + (255,))
    _rr(d, [bx, by, bx + int(bw * 0.75), by + 24], 12, fill=ACCENT + (255,))
    y += 240

    # Task list
    tasks = [
        (True, "Morning", "Cold rinse  -  3 min", ACCENT2),
        (True, "Morning", "Mewing practice  -  10 min", ACCENT),
        (True, "Afternoon", "Gua sha jawline  -  5 min", ACCENT3),
        (False, "Evening", "Cleanse + moisturize", GOLD),
        (False, "Evening", "Sleep posture check", SUCCESS),
    ]
    for done, slot, title, col in tasks:
        bg = (28, 28, 43) if not done else (30, 42, 40)
        _rr(d, [pad, y, W - pad, y + 170], 28,
            fill=bg + (255,), outline=BORDER + (255,), width=2)
        # Check
        ccx, ccy = pad + 70, y + 85
        if done:
            d.ellipse([ccx - 36, ccy - 36, ccx + 36, ccy + 36], fill=SUCCESS + (255,))
            d.line([ccx - 16, ccy + 2, ccx - 4, ccy + 14], fill=BG, width=7)
            d.line([ccx - 4, ccy + 14, ccx + 18, ccy - 12], fill=BG, width=7)
        else:
            d.ellipse([ccx - 36, ccy - 36, ccx + 36, ccy + 36],
                      fill=CARD + (255,), outline=col + (255,), width=5)
        # Slot pill
        f_slot = _font(20, bold=True)
        sw = d.textlength(slot, font=f_slot) + 30
        _rr(d, [pad + 140, y + 30, pad + 140 + int(sw), y + 66], 18,
            fill=(col[0], col[1], col[2], 60))
        d.text((pad + 155, y + 38), slot, font=f_slot, fill=col)
        d.text((pad + 140, y + 82), title, font=_font(32, bold=True), fill=TEXT)
        y += 190


def _paint_paywall(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 50, int(H * 0.03)), "X",
           font=_font(60, bold=True), fill=TEXT)

    y = int(H * 0.08)
    _rr(d, [pad, y, pad + 210, y + 64], 32,
        fill=(GOLD[0], GOLD[1], GOLD[2], 50))
    d.text((pad + 30, y + 16), "UMAX PRO",
           font=_font(26, bold=True), fill=GOLD)
    y += 100

    d.text((pad, y), "Unlock your", font=_font(96, bold=True), fill=TEXT)
    d.text((pad, y + 112), "full potential.",
           font=_font(96, bold=True), fill=GOLD)
    y += 260
    d.text((pad, y), "Scan pro, routines, trend history.",
           font=_font(30), fill=T2)
    y += 100

    perks = [
        ("Unlimited scans + trend graph", ACCENT),
        ("Deep trait analysis (20+ metrics)", ACCENT2),
        ("Personalized 7-day protocols", ACCENT3),
        ("Hairline, skin, jawline zoom", GOLD),
        ("Private - no face uploaded to servers", SUCCESS),
    ]
    for title, col in perks:
        cx, cy = pad + 40, y + 40
        d.ellipse([cx - 28, cy - 28, cx + 28, cy + 28], fill=col + (255,))
        d.line([cx - 14, cy + 2, cx - 4, cy + 12], fill=BG, width=6)
        d.line([cx - 4, cy + 12, cx + 16, cy - 10], fill=BG, width=6)
        d.text((pad + 110, y + 20), title, font=_font(32, bold=True), fill=TEXT)
        y += 95
    y += 20

    tiers = [
        ("Pro Yearly", "Save 58%. Just $4.16/mo.", "$49.99", True, "BEST VALUE"),
        ("Pro Monthly", "Cancel anytime.", "$9.99", False, None),
        ("Pro Lifetime", "One payment. Forever.", "$79.99", False, None),
    ]
    for name, desc, price, selected, badge in tiers:
        fill = (GOLD[0], GOLD[1], GOLD[2], 40) if selected else CARD + (255,)
        _rr(d, [pad, y, W - pad, y + 160], 30, fill=fill,
            outline=GOLD + (255,) if selected else BORDER + (255,),
            width=4 if selected else 2)
        cx = pad + 50
        cy = y + 80
        d.ellipse([cx - 24, cy - 24, cx + 24, cy + 24],
                  fill=GOLD + (255,) if selected else CARD + (255,),
                  outline=GOLD + (255,) if selected else BORDER + (255,), width=4)
        if selected:
            d.line([cx - 10, cy + 2, cx - 2, cy + 10], fill=BG, width=5)
            d.line([cx - 2, cy + 10, cx + 12, cy - 7], fill=BG, width=5)
        name_x = pad + 110
        d.text((name_x, y + 36), name, font=_font(34, bold=True), fill=TEXT)
        if badge:
            nw = _font(34, bold=True).getlength(name)
            bw_ = _font(18, bold=True).getlength(badge) + 24
            _rr(d, [int(name_x + nw + 16), y + 40,
                    int(name_x + nw + 16 + bw_), y + 76], 18, fill=GOLD + (255,))
            d.text((int(name_x + nw + 28), y + 46), badge,
                   font=_font(18, bold=True), fill=BG)
        d.text((name_x, y + 88), desc, font=_font(22), fill=T2)
        pw_ = _font(38, bold=True).getlength(price)
        d.text((W - pad - 30 - int(pw_), y + 58), price,
               font=_font(38, bold=True), fill=TEXT)
        y += 180

    y += 30
    _rr(d, [pad, y, W - pad, y + 140], 34, fill=GOLD + (255,))
    f = _font(44, bold=True)
    tw = d.textlength("Unlock UMAX Pro", font=f)
    d.text(((W - tw) / 2, y + 46), "Unlock UMAX Pro", font=f, fill=BG)


def render_phone(title, sub, painter):
    canvas = _bg(PHONE_W, PHONE_H)
    content_y = _header(canvas, title, sub)
    dw = int(PHONE_W * 0.82)
    dh = int(dw * (19.5 / 9))
    device, inner = _device(dw, dh)
    ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]), BG + (255,))
    painter(ui)
    device.paste(ui, (inner[0], inner[1]), ui)
    sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [20, 40, dw - 20, dh - 20],
        radius=int(min(dw, dh) * 0.09), fill=(0, 0, 0, 180))
    sh = sh.filter(ImageFilter.GaussianBlur(50))
    dx = (PHONE_W - dw) // 2
    dy = content_y
    canvas.alpha_composite(sh, (dx, dy))
    canvas.alpha_composite(device, (dx, dy))
    return canvas


def render_feature():
    w, h = 1024, 500
    canvas = _bg(w, h)
    d = ImageDraw.Draw(canvas)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((220, 220), Image.LANCZOS)
        canvas.alpha_composite(_glow(w, h, 190, 250, ACCENT, 300, alpha_peak=140))
        canvas.alpha_composite(icon, (80, 140))
    d = ImageDraw.Draw(canvas)
    d.text((340, 150), "UMAX", font=_font(100, bold=True), fill=TEXT)
    d.text((340, 270), "Your looks. Measured.",
           font=_font(36, bold=True), fill=ACCENT2)
    d.text((340, 340), "AI scan + 7-day protocol.",
           font=_font(30), fill=TEXT)
    d.text((340, 390), "Private, on-device.",
           font=_font(30), fill=T2)
    return canvas


def render_og():
    w, h = 1200, 630
    canvas = _bg(w, h)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((260, 260), Image.LANCZOS)
        canvas.alpha_composite(_glow(w, h, 230, 310, ACCENT, 400, alpha_peak=160))
        canvas.alpha_composite(icon, (100, 180))
    d = ImageDraw.Draw(canvas)
    d.text((400, 190), "UMAX", font=_font(100, bold=True), fill=TEXT)
    d.text((400, 310), "Measure. Improve. Track.",
           font=_font(44, bold=True), fill=ACCENT2)
    d.text((400, 380), "AI scan + personalized protocols.",
           font=_font(32), fill=TEXT)
    d.text((400, 500), "nalhamzy.github.io/umax",
           font=_font(28, bold=True), fill=T2)
    return canvas


def main():
    os.makedirs(os.path.join(OUT, "phone"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "tablet"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "android"), exist_ok=True)

    print("> feature graphic")
    render_feature().convert("RGB").save(
        os.path.join(OUT, "feature_graphic_1024x500.png"))
    print("> og card")
    render_og().convert("RGB").save(
        os.path.join(OUT, "og_card_1200x630.png"))

    shots = [
        ("01_home", "Your scan. One glance.",
         "Latest score, streak, and what to do next.", _paint_home),
        ("02_scan", "Align. Capture. Done.",
         "On-device AI in seconds.", _paint_scan),
        ("03_result", "Deep trait analysis.",
         "20+ metrics. Clear, honest scores.", _paint_result),
        ("04_routine", "A plan, not just a score.",
         "Personalized 7-day protocols.", _paint_routine),
        ("05_paywall", "Unlock UMAX Pro.",
         "Unlimited scans. Every metric. Every protocol.",
         _paint_paywall),
    ]
    for name, title, sub, painter in shots:
        print(f"> phone/{name}.png")
        img = render_phone(title, sub, painter)
        img.convert("RGB").save(
            os.path.join(OUT, "phone", f"{name}.png"), optimize=True)

    if os.path.exists(ICON_PATH):
        print("> android/icon-512.png")
        Image.open(ICON_PATH).convert("RGB").resize((512, 512), Image.LANCZOS).save(
            os.path.join(OUT, "android", "icon-512.png"))

    tablet_titles = {
        "01_home": "Your scan, one glance",
        "02_scan": "Align. Capture. Done",
        "03_result": "Deep trait analysis",
        "04_routine": "A plan, not just a score",
        "05_paywall": "Unlock UMAX Pro",
    }
    for name, _t, _s, painter in shots:
        print(f"> tablet/{name}.png")
        canvas = _bg(TABLET_W, TABLET_H)
        d = ImageDraw.Draw(canvas)
        title = tablet_titles[name]
        f = _font(130, bold=True)
        tw = d.textlength(title, font=f)
        d.text(((TABLET_W - tw) // 2, int(TABLET_H * 0.05)),
               title, font=f, fill=TEXT)
        dw = int(TABLET_W * 0.58)
        dh = int(dw * (19.5 / 9))
        device, inner = _device(dw, dh)
        ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]),
                       BG + (255,))
        painter(ui)
        device.paste(ui, (inner[0], inner[1]), ui)
        sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            [20, 40, dw - 20, dh - 20],
            radius=int(min(dw, dh) * 0.09), fill=(0, 0, 0, 180))
        sh = sh.filter(ImageFilter.GaussianBlur(50))
        dx = (TABLET_W - dw) // 2
        dy = int(TABLET_H * 0.18)
        canvas.alpha_composite(sh, (dx, dy))
        canvas.alpha_composite(device, (dx, dy))
        canvas.convert("RGB").save(
            os.path.join(OUT, "tablet", f"{name}.png"), optimize=True)

    print("\nAll UMAX store assets emitted to:")
    print(f"  {OUT}")


if __name__ == "__main__":
    main()
