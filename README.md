<p align="center">
  <img src="media/icon-400.png" width="96" alt="Hoard Forever">
</p>

<h1 align="center">Hoard Forever</h1>

<p align="center">Search your bags, bank, alts and guild vault in one window.</p>

Hoard Forever answers one question fast: where is that item? Type a name and it lists every place the item sits, across the character you are on, your bank, your guild's vault and every alt that has logged in since the addon was installed.

## Features

- **One search, every container.** Bags, reagent bag, bank, warband bank, the guild vault and your alts' cached bags and banks, ranked so the closest match comes first.
- **Card and tab layout.** `All`, `Bags`, `Bank`, `Alts` and `Guild` tabs, so a search can be narrowed to one source without retyping it.
- **Counts that add up.** Each result shows the total and a per-source breakdown, so a stack in the bank is not mistaken for one in your bags.
- **Alt stashes without logging over.** Each character records its bags and bank when they change; the account-wide save keeps the last reading with its timestamp.
- **Client-native look.** The window is built from the client's own templates, fonts and atlases, and adds nothing to your action bars or minimap.

## Install

1. Unzip into `World of Warcraft/_classic_beta_/Interface/AddOns/`.
2. Restart the client, or `/reload` after an update.

## Usage

- `/hoard` or `/hoardforever` opens the window. The addon compartment button opens it too.
- Type to filter. `Enter` links the first result to chat; `Shift`-click any row links it.
- `Esc` closes the window.

Screenshots and the store description arrive with the first published release.

## Development

Specs run on LuaJIT against a mock client (`tests/wow_mock.lua`):

```sh
for spec in tests/*_spec.lua; do luajit "$spec" || exit 1; done
```

## Licence

GPL-3.0-or-later. See `LICENSE`.
