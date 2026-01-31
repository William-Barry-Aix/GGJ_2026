from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SPRITES_DIR = ROOT / "assets" / "art" / "sprites" / "player"


def flip_folder(src_name: str, dst_name: str) -> None:
    src_dir = SPRITES_DIR / src_name
    dst_dir = SPRITES_DIR / dst_name

    if not src_dir.is_dir():
        raise FileNotFoundError(f"Source folder not found: {src_dir}")

    dst_dir.mkdir(parents=True, exist_ok=True)

    for png_path in sorted(src_dir.glob("*.png")):
        with Image.open(png_path) as img:
            flipped = img.transpose(Image.FLIP_LEFT_RIGHT)
            out_path = dst_dir / png_path.name
            flipped.save(out_path)


def main() -> None:
    flip_folder("io_attacking_resized", "io_attacking_resized_right")
    flip_folder("io_walking_resized", "io_walking_resized_right")


if __name__ == "__main__":
    main()
