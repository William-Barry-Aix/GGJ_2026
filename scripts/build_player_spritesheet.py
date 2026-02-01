from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SPRITESHEETS_DIR = ROOT / "assets" / "art" / "sprites" / "player" / "spritesheets"

ORDERED_FILES = [
    "io_walking_left_spritesheet.png",
    "io_walking_right_spritesheet.png",
    "io_attacking_left_spritesheet.png",
    "io_attacking_right_spritesheet.png",
]


def load_images() -> list[Image.Image]:
    images: list[Image.Image] = []
    for name in ORDERED_FILES:
        path = SPRITESHEETS_DIR / name
        if not path.is_file():
            raise FileNotFoundError(f"Missing spritesheet: {path}")
        images.append(Image.open(path))
    return images


def main() -> None:
    images = load_images()
    try:
        widths = [img.width for img in images]
        heights = [img.height for img in images]

        sheet_width = max(widths)
        sheet_height = sum(heights)
        sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

        y = 0
        for img in images:
            sheet.paste(img, (0, y))
            y += img.height

        out_path = SPRITESHEETS_DIR / "player_spritesheet.png"
        sheet.save(out_path)
    finally:
        for img in images:
            img.close()


if __name__ == "__main__":
    main()
