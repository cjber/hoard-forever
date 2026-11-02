# About the app

Hoard Forever is a World of Warcraft: Forever addon written in Lua 5.1. It cannot run outside the game
client, and you must never start the game. What runs here is its headless test harness: each
`tests/<name>_spec.lua` stubs the client API, loads the addon files the TOC lists, and checks one
feature. Run a spec with `luajit tests/<name>_spec.lua`; a failing spec exits non-zero and prints the
failed assertion. `luacheck <file>` lints a file, and `bash tools/typecheck.sh` runs the load-graph
checks (it is a shell script, despite the name).

The addon is read-only by design: it searches bags, bank, other characters and the guild vault and never
moves an item. A change that writes to a container is a bug, however small.

Use the specs and `luajit -e` one-liners that load the harness to check what a change claims. Report a
spec that fails, an error that a spec prints, or a behaviour a spec shows that the change does not
intend.

## Sign in

No sign-in.

## Important flows

- Searching across bags, bank, alts and the guild vault, including when the vault is closed or the
  character has no bank data yet.
- Item counts that combine several characters, and what happens when one character's data is stale.
- Filtering and sorting results, and the empty state.
- Tooltips on a result, and the item link.

## Never do these things

- Never launch the game, Battle.net, Lutris or Wine.
- Never edit, move or delete files.
- Never use the network.
- Never accept a change that moves, sells or modifies an item.
