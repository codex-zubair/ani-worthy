#!/usr/bin/env python3
"""Render AniWorthy Play Store graphics as HTML mockups, screenshotted with
headless Chrome. No third-party Python deps.

Writes:
  <app>/store_assets/graphics/feature_graphic_1024x500.png
  <app>/store_assets/screenshots/01..05_*.png            (1080x1920)

Usage:
  python3 make_graphics.py [app_root]
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
GRAPHICS = APP_ROOT / "store_assets" / "graphics"
SHOTS = APP_ROOT / "store_assets" / "screenshots"
for d in (GRAPHICS, SHOTS):
    d.mkdir(parents=True, exist_ok=True)

CHROME = (shutil.which("google-chrome-stable") or shutil.which("google-chrome")
          or shutil.which("brave") or shutil.which("chromium"))

CSS = """
*{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased}
body{font-family:'DejaVu Sans','Segoe UI',Roboto,sans-serif;background:#0E0B1F;color:#F1ECFF}
.screen{width:1080px;height:1920px;position:relative;display:flex;flex-direction:column;overflow:hidden}
.status{display:flex;justify-content:space-between;font-size:28px;color:#A79FD0;padding:24px 40px 0}
.hdr{display:flex;align-items:center;gap:18px;padding:18px 44px 18px}
.logo{width:72px;height:72px;border-radius:22px;background:linear-gradient(135deg,#FF4F9D,#7C5CFF);display:flex;align-items:center;justify-content:center;color:#fff;font-weight:900;font-size:44px}
.word{font-size:44px;font-weight:800;letter-spacing:-1px}
.word small{display:block;font-size:22px;font-weight:500;color:#A79FD0;letter-spacing:0}
.chip{margin-left:auto;display:flex;align-items:center;gap:10px;background:#181330;border:2px solid #2E2656;border-radius:40px;padding:14px 24px;font-size:24px;color:#A79FD0;font-weight:600}
.chip .d{color:#7C5CFF}
.sect{color:#7A72A8;font-size:22px;font-weight:800;letter-spacing:3px;margin:22px 44px 16px}
.hero{margin:0 44px 22px;padding:40px;border-radius:30px;background:linear-gradient(135deg,rgba(255,79,157,.28),rgba(124,92,255,.22));border:2px solid rgba(255,79,157,.45)}
.hero h2{font-size:44px;font-weight:900;line-height:1.15;margin:8px 0 14px}
.hero p{color:#C7BEE8;font-size:27px;line-height:1.5}
.stats{display:flex;gap:34px;margin:26px 0 8px}
.stat b{font-size:44px;font-weight:900}
.stat span{color:#A79FD0;font-size:24px;margin-left:10px}
.btn{margin-top:26px;background:#FF4F9D;color:#fff;border-radius:20px;padding:28px;text-align:center;font-size:32px;font-weight:800}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:22px;padding:0 44px}
.gcard{background:#181330;border:2px solid #2E2656;border-radius:24px;padding:26px;min-height:200px;display:flex;flex-direction:column;justify-content:space-between}
.gemoji{font-size:52px}
.gname{font-size:32px;font-weight:800;margin-top:14px}
.gblurb{color:#A79FD0;font-size:22px;margin-top:4px}
.pill{display:inline-block;background:rgba(255,194,75,.14);color:#FFC24B;border:2px solid rgba(255,194,75,.4);border-radius:20px;padding:8px 18px;font-size:21px;font-weight:700;margin-top:12px}
.fact{margin:0 44px;background:#181330;border:2px solid #2E2656;border-radius:24px;padding:30px;display:flex;gap:22px}
.fact .i{font-size:40px}
.fact p{font-size:28px;line-height:1.5;color:#E6DFFF}
.q{padding:0 44px}
.qmeta{display:flex;justify-content:space-between;color:#A79FD0;font-size:26px;font-weight:600}
.pbar{height:14px;background:#181330;border-radius:8px;margin-top:16px;overflow:hidden}
.pbar i{display:block;height:100%;background:#FF4F9D}
.prompt{font-size:44px;font-weight:800;line-height:1.3;margin:34px 0 30px}
.opt{background:#181330;border:2px solid #2E2656;border-radius:20px;padding:30px 28px;font-size:31px;font-weight:600;margin-bottom:20px;display:flex;justify-content:space-between;align-items:center}
.opt.ok{background:rgba(52,211,153,.14);border-color:#34D399;color:#8FF0C4}
.opt.bad{background:rgba(248,113,113,.14);border-color:#F87171;color:#FFB4B4}
.note{margin:0 44px;background:#221B44;border-radius:18px;padding:24px;font-size:25px;color:#B7AEDB;line-height:1.45}
.result{margin:20px 44px 0;padding:48px 40px;border-radius:30px;background:linear-gradient(135deg,rgba(255,79,157,.26),rgba(124,92,255,.20));border:2px solid rgba(255,79,157,.45);text-align:center}
.result .pct{font-size:110px;font-weight:900}
.result .sub{color:#C7BEE8;font-size:30px;margin-top:10px}
.result .grade{display:inline-block;margin-top:26px;background:rgba(124,92,255,.2);color:#B79DFF;border:2px solid rgba(124,92,255,.5);border-radius:24px;padding:14px 34px;font-size:30px;font-weight:800}
.review{margin:22px 44px 0;background:#181330;border:2px solid #34D399;border-radius:20px;padding:26px}
.review .t{font-size:28px;font-weight:700;line-height:1.35}
.review .a{color:#34D399;font-size:24px;margin-top:10px;font-weight:700}
.nav{position:absolute;left:0;right:0;bottom:0;height:150px;background:#0B0919;border-top:2px solid #221B44;display:flex;align-items:center;justify-content:space-around;padding-bottom:14px}
.nav .it{display:flex;flex-direction:column;align-items:center;gap:8px;color:#7A72A8;font-size:20px}
.nav .it.on{color:#7C5CFF}
.nav .ic{width:56px;height:56px;border-radius:16px;background:#1C1640;display:flex;align-items:center;justify-content:center;font-size:30px}
.nav .on .ic{background:rgba(124,92,255,.2)}
.feature{width:1024px;height:500px;background:radial-gradient(120% 160% at 15% 10%,#2A1145 0%,#0E0B1F 55%,#08060F 100%);position:relative;overflow:hidden;display:flex;align-items:center;padding:0 70px}
.fglow{position:absolute;right:-120px;top:-140px;width:560px;height:560px;border-radius:50%;background:radial-gradient(circle,rgba(255,79,157,.5),transparent 62%)}
.fglow2{position:absolute;right:120px;bottom:-220px;width:520px;height:520px;border-radius:50%;background:radial-gradient(circle,rgba(124,92,255,.4),transparent 62%)}
.fleft{z-index:2;display:flex;align-items:center;gap:34px}
.flogo{width:170px;height:170px;border-radius:46px;background:linear-gradient(135deg,#FF4F9D,#7C5CFF);display:flex;align-items:center;justify-content:center;box-shadow:0 30px 70px rgba(255,79,157,.5);color:#fff;font-weight:900;font-size:104px}
.fname{font-size:88px;font-weight:900;letter-spacing:-3px}
.ftag{font-size:34px;color:#C7BEE8;margin-top:6px}
.fbadges{display:flex;gap:14px;margin-top:24px}
.fb{font-size:26px;font-weight:800;border-radius:16px;padding:12px 22px}
.fb1{color:#7C5CFF;background:rgba(124,92,255,.16);border:2px solid rgba(124,92,255,.5)}
.fb2{color:#FF4F9D;background:rgba(255,79,157,.14);border:2px solid rgba(255,79,157,.45)}
.fb3{color:#FFC24B;background:rgba(255,194,75,.13);border:2px solid rgba(255,194,75,.4)}
"""


def render_html(html, out, w, h):
    if CHROME is None:
        print("No Chrome found; skipping", out.name)
        return
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(html)
        path = f.name
    subprocess.run(
        [CHROME, "--headless=new", "--no-sandbox", "--disable-gpu",
         "--hide-scrollbars", "--force-device-scale-factor=1",
         f"--window-size={w},{h}", f"--screenshot={out}", f"file://{path}"],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    Path(path).unlink(missing_ok=True)
    print(f"  {out.relative_to(APP_ROOT)}")


def page(body, w, h):
    return (f"<!DOCTYPE html><html><head><meta charset='utf-8'><style>"
            f"{CSS}\nhtml,body{{width:{w}px;height:{h}px}}</style></head>"
            f"<body>{body}</body></html>")


def status():
    return "<div class='status'><span>9:41</span><span>&#9679; &#9679; &#9679; &#9679;</span></div>"


def header():
    return ("<div class='hdr'><div class='logo'>?</div>"
            "<div class='word'>AniWorthy<small>Offline Anime Trivia</small></div>"
            "<div class='chip'><span class='d'>&#10003;</span> Offline</div></div>")


def nav(active):
    items = [("&#10067;", "Quiz"), ("&#9881;", "Settings"), ("&#9432;", "About")]
    out = []
    for i, (ic, label) in enumerate(items):
        cls = "it on" if i == active else "it"
        out.append(f"<div class='{cls}'><div class='ic'>{ic}</div>{label}</div>")
    return f"<div class='nav'>{''.join(out)}</div>"


def screen_home():
    cats = [("&#127916;", "Studios", "Who animated what", "Best 90%"),
            ("&#128250;", "Series", "Iconic shows and movies", ""),
            ("&#129489;", "Characters", "Heroes and villains", "Best 70%"),
            ("&#9997;", "Creators", "Mangaka and directors", ""),
            ("&#127919;", "General", "Terms and traditions", "Best 80%")]
    cells = ""
    for emoji, name, blurb, best in cats:
        pill = f"<div class='pill'>&#9733; {best}</div>" if best else ""
        cells += (f"<div class='gcard'><div><div class='gemoji'>{emoji}</div>"
                  f"<div class='gname'>{name}</div><div class='gblurb'>{blurb}</div></div>{pill}</div>")
    body = (f"<div class='screen'>{status()}{header()}"
            "<div class='hero'><h2>Test your anime knowledge</h2>"
            "<p>10 quick questions, all offline. How high can you score?</p>"
            "<div class='stats'><div class='stat'><b>90%</b><span>Best</span></div>"
            "<div class='stat'><b>12</b><span>Quizzes</span></div></div>"
            "<div class='btn'>&#9654; Start quiz</div></div>"
            "<div class='sect'>CATEGORIES</div>"
            f"<div class='grid'>{cells}</div>{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_question():
    body = (f"<div class='screen'>{status()}{header()}"
            "<div class='q'><div class='qmeta'><span>Question 3 of 10</span>"
            "<span>&#128293; 2 streak</span></div>"
            "<div class='pbar'><i style='width:30%'></i></div>"
            "<div class='prompt'>Which studio produced the film \"Spirited Away\"?</div>"
            "<div class='opt ok'><span>Studio Ghibli</span><span>&#10004;</span></div>"
            "<div class='opt'><span>Madhouse</span></div>"
            "<div class='opt'><span>Sunrise</span></div>"
            "<div class='opt'><span>Toei Animation</span></div>"
            "<div class='note'>&#8505; Spirited Away (2001) is a Studio Ghibli film "
            "directed by Hayao Miyazaki.</div></div>"
            f"{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_categories():
    cats = [("&#127916;", "Studios", "20 questions"),
            ("&#128250;", "Series", "24 questions"),
            ("&#129489;", "Characters", "24 questions"),
            ("&#9997;", "Creators", "24 questions"),
            ("&#127919;", "General", "24 questions")]
    cells = ""
    for emoji, name, sub in cats:
        cells += (f"<div class='gcard'><div><div class='gemoji'>{emoji}</div>"
                  f"<div class='gname'>{name}</div><div class='gblurb'>{sub}</div></div></div>")
    body = (f"<div class='screen'>{status()}{header()}"
            "<div class='sect'>PICK A CATEGORY</div>"
            f"<div class='grid'>{cells}</div>{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_results():
    body = (f"<div class='screen'>{status()}{header()}"
            "<div class='result'><div class='pct'>80%</div>"
            "<div class='sub'>8 of 10 correct</div>"
            "<div class='grade'>Otaku Pro</div></div>"
            "<div class='sect'>REVIEW</div>"
            "<div class='review'><div class='t'>Which demographic does \"shonen\" target?</div>"
            "<div class='a'>Answer: Teenage boys</div></div>"
            "<div class='review' style='border-color:#34D399'><div class='t'>Who created \"One Piece\"?</div>"
            "<div class='a'>Answer: Eiichiro Oda</div></div>"
            f"{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_about():
    body = (f"<div class='screen'>{status()}{header()}"
            "<div style='text-align:center;padding:30px 44px 0'>"
            "<div class='logo' style='margin:0 auto;width:150px;height:150px;border-radius:44px;font-size:92px'>?</div>"
            "<div style='font-size:56px;font-weight:900;letter-spacing:-1px;margin-top:26px'>AniWorthy</div>"
            "<div style='color:#A79FD0;font-size:28px;margin-top:6px'>Offline Anime Trivia</div>"
            "<div style='margin-top:20px'><span class='chip' style='margin:0;display:inline-flex'>v1.0.0 &middot; by codex-zubair</span></div></div>"
            "<div style='margin:44px;background:linear-gradient(135deg,rgba(255,79,157,.16),rgba(124,92,255,.10));"
            "border:2px solid rgba(255,79,157,.4);border-radius:28px;padding:34px'>"
            "<div style='font-size:34px;font-weight:800;color:#7C5CFF'>&#128737; Private by design</div>"
            "<div style='color:#F1ECFF;font-size:28px;line-height:1.55;margin-top:14px'>"
            "No internet, no ads, no tracking. Everything runs on your device and your scores stay with you.</div></div>"
            "<div style='margin:0 44px'>"
            "<div class='gcard' style='min-height:auto;margin-bottom:18px'><div style='font-size:30px;font-weight:800'>0 permissions requested</div></div>"
            "<div class='gcard' style='min-height:auto;margin-bottom:18px'><div style='font-size:30px;font-weight:800'>No ads &middot; no analytics</div></div>"
            "<div class='gcard' style='min-height:auto'><div style='font-size:30px;font-weight:800'>100% offline trivia</div></div>"
            "</div></div>")
    return page(body, 1080, 1920)


def feature_graphic():
    body = ("<div class='feature'><div class='fglow'></div><div class='fglow2'></div>"
            "<div class='fleft'><div class='flogo'>?</div>"
            "<div><div class='fname'>AniWorthy</div>"
            "<div class='ftag'>Offline anime trivia &amp; quiz</div>"
            "<div class='fbadges'><span class='fb fb1'>100% offline</span>"
            "<span class='fb fb2'>0 permissions</span>"
            "<span class='fb fb3'>No ads</span></div></div></div></div>")
    return page(body, 1024, 500)


def main():
    if CHROME is None:
        print("Chrome not found; cannot render graphics.")
        return
    render_html(feature_graphic(), GRAPHICS / "feature_graphic_1024x500.png", 1024, 500)
    shots = [
        ("01_home", screen_home()),
        ("02_question", screen_question()),
        ("03_categories", screen_categories()),
        ("04_results", screen_results()),
        ("05_about_privacy", screen_about()),
    ]
    for name, html in shots:
        render_html(html, SHOTS / f"{name}.png", 1080, 1920)


if __name__ == "__main__":
    main()
