---
name: sift-project
description: Project profile for Sift quality gates in Hoard Forever.
---

# Sift project profile: Hoard Forever

Hoard Forever targets WoW: Forever (Interface 16001). The addon reads item data through client APIs and keeps each character's bag and bank snapshots plus the guild cache in saved variables. The addon is read-only: it never moves, sells, mails or uses items.

## Gate

Run from the repository root: `stylua --check .`, `luacheck .`, every `tests/*_spec.lua` with LuaJIT, Ruff 0.16.8 on `tools`, `python3 tools/changelog.py --check`, `python3 tools/typecheck.sh`, then `.sift/gate.py --base origin/main` and `.sift/agents.py check`.

## Live roots

- `HoardForever.toc` is the client file list and load order.
- `Core/Model.lua` is pure grouping, ranking and query parsing; keep it free of client APIs and frames.
- `Core/Snapshots.lua` reads client-visible containers and builds serialisable item records.
- `Core/Core.lua` owns the saved snapshots, event handlers and index rebuild.
- The guild cache is keyed by guild name and only refreshed while the guild bank is open; never call deposit, withdraw or item movement APIs.
