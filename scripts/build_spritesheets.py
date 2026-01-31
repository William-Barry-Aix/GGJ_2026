from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PLAYERS_DIR = ROOT / "assets" / "art" / "sprites" / "player"


def build_spritesheet(folder: Path) -> None:
    frames = sorted(folder.glob("*.png"))
    if not frames:
        return

    images = [Image.open(path) for path in frames]
    try:
        widths = [img.width for img in images]
        heights = [img.height for img in images]

        sheet_width = sum(widths)
        sheet_height = max(heights)
        sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

        x = 0
        for img in images:
            sheet.paste(img, (x, 0))
            x += img.width

        out_path = folder / f"{folder.name}_spritesheet.png"
        sheet.save(out_path)
    finally:
        for img in images:
            img.close()


def main() -> None:
    for child in sorted(PLAYERS_DIR.iterdir()):
        if child.is_dir():
            build_spritesheet(child)


if __name__ == "__main__":
    main()
