# AGENTS.md

Hoard Forever targets the WoW: Forever client (Interface 16001). It is the suite's inventory search: one window that
answers where an item is and how many you have, across bags, bank, alts and the guild vault. It only reads. It never
moves, sells, mails or uses an item, and it never touches a protected function.

Read `docs/build-brief.md` for the product boundaries and the vault behavior before changing scope.

## Commands

```sh
python3 .sift/gate.py --base origin/main
python3 .sift/agents.py check
python3 tools/typecheck.sh
stylua --check .
luacheck .
for spec in tests/*_spec.lua; do luajit "$spec" || exit 1; done
uvx ruff@0.16.8 check tools && uvx ruff@0.16.8 format --check tools
python3 tools/changelog.py --check
FOREVER_CORE=/path/to/forever-core python3 tools/screenshots.py  # after changing a mock scene
python3 tools/check_screenshots.py
```

Specs are Lua 5.1 scripts run with LuaJIT through `tests/wow_mock.lua`, a headless client with inert frames and
hand-delivered events. `tools/` holds development tooling, which `.pkgmeta` keeps out of the package:
`tools/changelog.py` prints or checks a release's entry, `tools/check_package.py` checks what the packager built, and
`tools/release_check.py` gates the release on a green full CI run. Screenshot regeneration uses the shared renderer in a sibling `forever-core` checkout; set `FOREVER_CORE` when it is elsewhere.

## Layout

- `HoardForever.toc` is the client's runtime file list and load order. Files sit at the repository root or in one of
  the flat folders below; no other nesting.
- `Locales/enUS.lua` contains every player-visible phrase. UI code uses `ns.L["whole sentence"]`, never a bare string.
- `Core/Model.lua` is pure: grouping container records into one record per item, ranking and query parsing, with no WoW
  API, no frames and no clock.
- `Core/Snapshots.lua` reads bags, bags' reagent bag, bank and bank reagent slots through `C_Container` inside `pcall`,
  and writes this character's snapshot. A source the client does not offer is absent, never zero.
- `Core/Core.lua` owns the saved variables, the event handlers and the slash command; `Core/Settings.lua` is the
  Settings > AddOns page; `Core/API.lua` is the versioned addon-to-addon contract, read as `HoardForever.API`.
- `UI/` holds the window and the result rows. The window is `PortraitFrameTemplate` with the client's search box and
  tab buttons; `UI/Results.lua` renders one row per item.

## Scope

Owns: searching containers and cached alt stashes, the window, and the saved per-character snapshots.

Never: craft, mail, sell or use an item, plan a route (`shortest-path-forever`), choose quests
(`adventure-guide-forever`), price a recipe (`skillup-forever`), or draw a bag or bank window of its own.

## Standards

- `wow-forever-addon` — https://github.com/cjber/forever-core/tree/3fd1b7fe109e709c4952bb04622e94d05636585e/.agents/skills/wow-forever-addon (shared UI, icon, docs, CI and release requirements)

## Rules

- Runtime code targets Lua 5.1. Keep new globals limited to SavedVariables, the public API table, and the
  client-required slash and compartment globals.
- The addon works with nothing else installed. Never make a sibling addon the only path.
- Every client API that may be absent is called through `pcall` and a missing source is hidden, not faked.
- Keep `Core/Model.lua` pure and its specs free of a client. Never rebuild the index per keystroke: keystrokes filter
  a cached index, and no `OnUpdate` or polling timer exists anywhere.
- Keep SavedVariables flat and serialisable: no frames, functions, userdata, or caches of client tables.
- Do not hook Blizzard methods. Every change must be safe for secure UI and taint.
- Use tabs, annotations, `local addonName, ns = ...`, the established palette and Blizzard fonts. Add a
  `read_globals` entry to `.luacheckrc` only for a genuine client API, never to hide a real warning.
- Never hand-write item data. Names, quality, icons and links come from the client at runtime.
- Do not edit `.pkgmeta` to include development-only tools, tests, or screenshots.

## Release flow

Keep changes under an appropriate `CHANGELOG.md` version heading, run the full gate, and check the packaged TOC
contents before releasing. The BigWigs packager reads `.pkgmeta`, substitutes the release version in the TOC, and
publishes the changelog entry as release notes. Commit without `-s`; signing is handled by GitHub.
