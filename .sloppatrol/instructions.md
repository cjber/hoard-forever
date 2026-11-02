# About the code

Hoard Forever is a World of Warcraft: Forever addon in Lua 5.1. The files the TOC lists are what the game
loads; `tests/*_spec.lua` load them in that order inside a stubbed client.

- Keep every saved variable name and every global the TOC exposes unchanged.
- Generated data, `Locales/` and `tools/forever_tools/` are never edited by hand.
- Never replace a Blizzard global, hook a secure function, or write a field on a Blizzard table: the
  gate's taint lint refuses it, and so does the game.
- Never launch the game, Battle.net, Lutris or Wine, and never use the network.

This addon is read-only by design: it searches bags, bank, alts and the guild vault and never moves an
item. A refactor that writes to a container is a bug, however small.
