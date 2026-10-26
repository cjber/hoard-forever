#!/usr/bin/env python3
"""Check that each Hoard screenshot still matches its UI and scene source."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
from forever_tools import screens  # noqa: E402

OUT = ROOT / "docs" / "screenshots"
SOURCES = ("tools/screenshots.py", "UI/Window.lua", "UI/Results.lua", "Core/Model.lua")
SCENES = {name: (lambda: screens.files(ROOT, SOURCES)) for name in ("search.png", "alts.png", "empty.png")}

if __name__ == "__main__":
    raise SystemExit(screens.main(OUT, SCENES))
