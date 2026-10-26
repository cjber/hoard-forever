#!/usr/bin/env python3
"""Render Hoard's README screens with the shared forever-core mock renderer."""

import os
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
FOREVER_CORE = Path(os.environ.get("FOREVER_CORE", ROOT.parent / "forever-core")).expanduser()
WOWMOCK = FOREVER_CORE / "tools" / "wowmock"
if not (WOWMOCK / "wowmock.py").is_file():
    raise SystemExit(f"wowmock.py not found in {WOWMOCK}; set FOREVER_CORE to the forever-core checkout")
sys.path.insert(0, str(WOWMOCK))

from wowmock import ARIALN, FONTS, WHITE, Font, Ui, panel_tabs, portrait_frame_art, search_box, tiled  # noqa: E402

BUILD = "1.60.1.70532"
WIDTH, HEIGHT = 764, 500
FRAME = (22, 20, 720, 460)
ITEM_IDS = {"Linen Cloth": 2589, "Copper Ore": 2770, "Hearthstone": 6948, "Wool Cloth": 2592}
COUNT_FONT = Font(ARIALN, 10, WHITE, None, True)
QUALITY = {1: (0.9, 0.9, 0.9, 1), 2: (0.12, 0.72, 0.16, 1), 3: (0.14, 0.57, 0.94, 1), 4: (0.66, 0.25, 0.85, 1)}


def scene(ui, query, tab, rows, empty=False):
    canvas = ui.canvas(WIDTH, HEIGHT)
    x, y, w, h = FRAME
    rock = ui.texture("interface/framegeneral/ui-background-rock.blp")
    tiled(canvas, rock, x + 5, y + 23, w - 10, h - 28, rock.width / ui.scale, rock.height / ui.scale)
    canvas.fill(x + 5, y + 23, w - 10, h - 28, (0.10, 0.11, 0.13, 0.74))
    portrait = Image.open(ROOT / "media/icon-400.png").convert("RGBA")
    portrait_frame_art(canvas, x, y, w, h, portrait, "Hoard Forever")

    search_box(canvas, x + 24, y + 54, 300, 26, "")
    canvas.text(x + 41, y + 57, query, FONTS["GameFontHighlightSmall"], box_height=20)
    panel_tabs(canvas, x + 18, y + 82, ["All", "Bags", "Bank", "Alts", "Guild"], tab)

    list_x, list_y, list_w = x + 28, y + 142, w - 56
    if empty:
        canvas.text(list_x + 8, list_y + 8, f"No items found for “{query}”.", FONTS["GameFontDisableSmall"])
    else:
        for index, (item_name, total, sources) in enumerate(rows):
            item = ui.item(ITEM_IDS[item_name])
            row_y = list_y + index * 52
            if index:
                canvas.fill(list_x, row_y, list_w, 1, (0.32, 0.32, 0.30, 0.48))
            canvas.draw(ui.texture(item.icon), list_x + 6, row_y + 7, 36, 36)
            color = QUALITY.get(item.quality, FONTS["GameFontHighlight"].color)
            canvas.text(list_x + 50, row_y + 8, item.name, FONTS["GameFontHighlight"], color)
            canvas.text(list_x + list_w - 42, row_y + 8, str(total), COUNT_FONT, justify="RIGHT", width=34)
            canvas.text(list_x + 50, row_y + 29, sources, FONTS["GameFontHighlightSmall"])

    status = (
        "0 results. Shift-click to link an item." if empty else f"{len(rows)} results. Shift-click to link an item."
    )
    canvas.text(x + 28, y + h - 38, status, FONTS["GameFontHighlightSmall"])
    return canvas


def main():
    ui = Ui(build=BUILD, scale=2)
    out = ROOT / "docs" / "screenshots"
    out.mkdir(parents=True, exist_ok=True)
    scenes = {
        "search.png": scene(
            ui,
            "cloth",
            0,
            [
                ("Linen Cloth", 38, "Bags 12  ·  Bank 26"),
                ("Wool Cloth", 18, "Bags 6  ·  Bank 12"),
                ("Copper Ore", 14, "Bags 8  ·  Bank 6"),
            ],
        ),
        "alts.png": scene(
            ui,
            "cloth",
            3,
            [
                ("Linen Cloth", 46, "Arderin Bags 12  ·  Maro Bank 26  ·  Talandra Bags 8"),
                ("Wool Cloth", 18, "Arderin Bank 10  ·  Maro Bags 8"),
            ],
        ),
        "empty.png": scene(ui, "legacy key", 0, [], empty=True),
    }
    for name, canvas in scenes.items():
        canvas.image.save(out / name, optimize=True)
        print(f"wrote {out / name}")


if __name__ == "__main__":
    main()
