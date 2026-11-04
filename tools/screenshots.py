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

from wowmock import (  # noqa: E402
    ARIALN,
    FONTS,
    WHITE,
    Font,
    TooltipLine,
    Ui,
    coin_texture_string,
    container_frame,
    item_tooltip_lines,
    panel_tabs,
    portrait_frame_art,
    scene,
    search_box,
    tiled,
    tooltip,
)

BUILD = "1.60.1.70124"
WIDTH, HEIGHT = 764, 500
FRAME = (22, 20, 720, 460)
ITEM_IDS = {"Linen Cloth": 2589, "Copper Ore": 2770, "Hearthstone": 6948, "Wool Cloth": 2592}
COUNT_FONT = Font(ARIALN, 10, WHITE, None, True)
QUALITY = {1: (0.9, 0.9, 0.9, 1), 2: (0.12, 0.72, 0.16, 1), 3: (0.14, 0.57, 0.94, 1), 4: (0.66, 0.25, 0.85, 1)}


TABS = ["All", "Bags", "Bank", "Alts", "Guild", "Characters"]
# RAID_CLASS_COLORS for the classes the Characters scene shows.
CLASS_COLOR = {"mage": (0.25, 0.78, 0.92, 1), "warrior": (0.78, 0.61, 0.43, 1), "priest": (1, 1, 1, 1)}
GRAY = (0.5, 0.5, 0.5, 1)


def window(ui, query, tab):
    """The Hoard window with its search box and tabs; returns the canvas and the list's origin and width."""
    canvas = ui.canvas(WIDTH, HEIGHT)
    x, y, w, h = FRAME
    # PortraitFrameTexturedBaseTemplate: tiled Bg, then its 43-unit TopTileStreaks layer.
    rock = ui.texture("interface/framegeneral/ui-background-rock.blp")
    tiled(canvas, rock, x + 2, y + 21, w - 4, h - 23, rock.width / ui.scale, rock.height / ui.scale)
    streaks = ui.atlas("_UI-Frame-TopTileStreaks")
    tiled(canvas, streaks.image, x + 6, y + 21, w - 8, 43, 256, 43)
    portrait = Image.open(ROOT / "media/icon-400.png").convert("RGBA")
    portrait_frame_art(canvas, x, y, w, h, portrait, "Hoard Forever")

    search_box(canvas, x + 24, y + 54, 300, 26, "")
    canvas.text(x + 41, y + 57, query, FONTS["GameFontHighlightSmall"], box_height=20)
    panel_tabs(canvas, x + 18, y + h - 22, TABS, tab)
    return canvas, (x + 24, y + 92, w - 74)


def items_scene(ui, query, tab, rows, empty=False):
    canvas, (list_x, list_y, list_w) = window(ui, query, tab)
    x, y, w, h = FRAME
    if empty:
        empty = "No items found." if not query else f"No items found for “{query}”."
        canvas.text(list_x + 8, list_y + 8, empty, FONTS["GameFontDisableSmall"])
    else:
        for index, (item_name, total, sources) in enumerate(rows):
            item = ui.item(ITEM_IDS[item_name])
            row_y = list_y + index * 50
            canvas.draw(ui.texture(item.icon), list_x + 6, row_y + 4.5, 37, 37)
            color = QUALITY.get(item.quality, FONTS["GameFontHighlight"].color)
            canvas.text(list_x + 51, row_y + 8, item.name, FONTS["GameFontHighlight"], color)
            canvas.text(list_x + list_w - 42, row_y + 8, str(total), COUNT_FONT, justify="RIGHT", width=34)
            canvas.text(list_x + 51, row_y + 29, sources, FONTS["GameFontHighlightSmall"])

    status = "" if empty else f"{len(rows)} results. Shift-click to link an item."
    canvas.text(x + w - 388, y + h - 40, status, FONTS["GameFontHighlightSmall"], justify="RIGHT", width=360)
    return canvas


def characters_scene(ui, rows):
    """The Characters tab: UI/Characters.lua's rows, class icon, name in the class colour, gold, details, last seen."""
    canvas, (list_x, list_y, list_w) = window(ui, "", TABS.index("Characters"))
    x, y, w, h = FRAME
    for index, (name, cls, money, details, seen) in enumerate(rows):
        row_y = list_y + index * 50
        canvas.draw(ui.atlas(f"classicon-{cls}"), list_x + 6, row_y + 4.5, 37, 37)
        canvas.text(list_x + 51, row_y + 8, name, FONTS["GameFontHighlight"], CLASS_COLOR[cls])
        canvas.text(
            list_x + list_w - 208,
            row_y + 5,
            coin_texture_string(money, 12),
            FONTS["GameFontHighlightSmall"],
            justify="RIGHT",
            width=200,
        )
        canvas.text(list_x + 51, row_y + 29, details, FONTS["GameFontHighlightSmall"])
        canvas.text(list_x + list_w - 208, row_y + 26, seen, FONTS["GameFontDisableSmall"], justify="RIGHT", width=200)
    status = f"{len(rows)} characters."
    canvas.text(x + w - 388, y + h - 40, status, FONTS["GameFontHighlightSmall"], justify="RIGHT", width=360)
    return canvas


def tooltip_scene(ui):
    """Hovering Linen Cloth in the backpack: the item's own tooltip, then UI/Tooltip.lua's line per source."""
    slots = [(2589, 12), (2770, 6), (6948, None), (None, None)] + [(None, None)] * 12
    bag, rects = container_frame(ui, "Backpack", "interface/buttons/button-backpack-up.blp", slots, 412345, hover=0)
    item = ui.item(ITEM_IDS["Linen Cloth"])
    lines = item_tooltip_lines(ui, item)
    sources = [
        ("Bags 12", ""),
        ("Bank 26", ""),
        ("Maro Bags 8", "Updated 2d ago"),
        ("Talandra Bank 40", "Updated 5h ago"),
        ("Guild (Tab 1) 60", ""),
    ]
    lines += [TooltipLine(left, WHITE, right or None, GRAY) for left, right in sources]
    tip = tooltip(ui, lines)
    slot_x, slot_y, _, _ = rects["slots"][0]
    tip_w = tip.image.width / ui.scale
    return scene(ui, [(bag, 0, 0), (tip, slot_x - tip_w - 4, slot_y)])


def main():
    ui = Ui(build=BUILD, scale=2)
    out = ROOT / "docs" / "screenshots"
    out.mkdir(parents=True, exist_ok=True)
    scenes = {
        "search.png": items_scene(
            ui,
            "cloth",
            0,
            [
                ("Linen Cloth", 38, "Bags 12  ·  Bank 26"),
                ("Wool Cloth", 18, "Bags 6  ·  Bank 12"),
            ],
        ),
        "alts.png": items_scene(
            ui,
            "cloth",
            3,
            [
                ("Linen Cloth", 46, "Arderin Bags 12  ·  Maro Bank 26  ·  Talandra Bags 8"),
                ("Wool Cloth", 18, "Arderin Bank 10  ·  Maro Bags 8"),
            ],
        ),
        "empty.png": items_scene(ui, "legacy key", 0, [], empty=True),
        "tooltip.png": tooltip_scene(ui),
        "characters.png": characters_scene(
            ui,
            [
                (
                    "Arderin",
                    "warrior",
                    1234567,
                    "Level 60  ·  Mining 300  ·  Blacksmithing 285  ·  Hearth: Ironforge  ·  Bags 212  ·  Bank 640",
                    "Playing now",
                ),
                (
                    "Maro",
                    "mage",
                    456789,
                    "Level 42  ·  Tailoring 225  ·  Enchanting 190  ·  Hearth: Stormwind City  ·  Bags 96  ·  Bank 310",
                    "Updated 2d ago",
                ),
                (
                    "Talandra",
                    "priest",
                    98765,
                    "Level 27  ·  Herbalism 140  ·  Alchemy 120  ·  Hearth: Darnassus  ·  Bags 58",
                    "Updated 5h ago",
                ),
            ],
        ),
    }
    for name, canvas in scenes.items():
        canvas.image.save(out / name, optimize=True)
        print(f"wrote {out / name}")


if __name__ == "__main__":
    main()
