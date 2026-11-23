#!/usr/bin/env python3
"""Draws the Google Play feature graphic (1024 x 500) for every listing
language, and copies the 512 px icon next to it.

Needs Pillow, rsvg-convert and the Inter font (or pass --font-dir).
Usage: python3 tool/store_graphics.py [--font-dir DIR]
"""

import argparse
import pathlib
import subprocess

from PIL import Image, ImageDraw, ImageFont

GREEN = "#1E8E4E"
PALE = "#EAF6EE"
SUBTITLES = {
    "en-US": ["ECB reference rates", "38 currencies, even offline"],
    "fr-FR": ["Taux de référence de la BCE", "38 devises, même hors ligne"],
    "de-DE": ["Referenzkurse der EZB", "38 Währungen, auch offline"],
    "es-ES": ["Tipos de referencia del BCE", "38 divisas, también sin conexión"],
    "it-IT": ["Tassi di riferimento della BCE", "38 valute, anche offline"],
    "pl-PL": ["Kursy referencyjne EBC", "38 walut, także offline"],
    "ro": ["Cursurile de referință BCE", "38 de valute, chiar și offline"],
    "lt": ["ECB orientaciniai kursai", "38 valiutos, net ir be ryšio"],
}


def feature_graphic(lines, bold, medium, out):
    width, height = 1024, 500
    image = Image.new("RGB", (width, height), GREEN)
    draw = ImageDraw.Draw(image)
    scale = 0.42
    bill_w, bill_h = 720 * scale, 400 * scale
    gap = 56
    text_w = max([draw.textlength("Money Converter", font=bold)]
                 + [draw.textlength(line, font=medium) for line in lines])
    x0 = (width - (bill_w + gap + text_w)) / 2
    mid = height / 2
    y0 = mid - bill_h / 2
    # Same banknote as the app icon, pale on green.
    draw.rounded_rectangle((x0, y0, x0 + bill_w, y0 + bill_h), radius=56 * scale, fill=PALE)
    cx = x0 + bill_w / 2
    ring, stroke = 104 * scale, 36 * scale
    draw.ellipse((cx - ring - stroke / 2, mid - ring - stroke / 2,
                  cx + ring + stroke / 2, mid + ring + stroke / 2), fill=GREEN)
    draw.ellipse((cx - ring + stroke / 2, mid - ring + stroke / 2,
                  cx + ring - stroke / 2, mid + ring - stroke / 2), fill=PALE)
    for dx in (-236 * scale, 236 * scale):
        dot = 26 * scale
        draw.ellipse((cx + dx - dot, mid - dot, cx + dx + dot, mid + dot), fill=GREEN)
    tx = x0 + bill_w + gap
    draw.text((tx, mid - 18), "Money Converter", font=bold, fill="white", anchor="ls")
    y = mid + 8
    for line in lines:
        draw.text((tx, y), line, font=medium, fill=PALE, anchor="lt")
        y += 44
    image.save(out)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--font-dir", default="/usr/share/fonts/opentype/inter")
    args = parser.parse_args()
    fonts = pathlib.Path(args.font_dir)
    bold = ImageFont.truetype(str(fonts / "Inter-Bold.otf"), 64)
    medium = ImageFont.truetype(str(fonts / "Inter-Medium.otf"), 32)
    root = pathlib.Path(__file__).resolve().parent.parent
    base = root / "fastlane/metadata/android"
    icon = base / "icon.png"
    subprocess.run(["rsvg-convert", "-w", "512", "-h", "512",
                    str(root / "assets/icon/bill.svg"), "-o", str(icon)], check=True)
    for locale, lines in SUBTITLES.items():
        images = base / locale / "images"
        images.mkdir(parents=True, exist_ok=True)
        feature_graphic(lines, bold, medium, images / "featureGraphic.png")
        (images / "icon.png").write_bytes(icon.read_bytes())
    icon.unlink()
    print(f"Graphics written for {len(SUBTITLES)} languages")


if __name__ == "__main__":
    main()
