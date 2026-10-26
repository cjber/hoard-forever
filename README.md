<p align="center"><img src="https://raw.githubusercontent.com/cjber/hoard-forever/main/media/icon-400.png" width="96" alt=""></p>

<h1 align="center">Hoard Forever</h1>

<p align="center">
Search your bags, bank and alts in one window.<br>
<a href="https://github.com/cjber/hoard-forever/actions/workflows/ci.yml"><img src="https://github.com/cjber/hoard-forever/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<a href="https://github.com/cjber/hoard-forever/releases/latest"><img src="https://img.shields.io/github/v/release/cjber/hoard-forever" alt="Latest release"></a>
<a href="https://ko-fi.com/cjber59408"><img src="https://img.shields.io/badge/Ko--fi-tip-ff5e5b?logo=ko-fi&logoColor=white" alt="Ko-fi"></a>
</p>

Hoard Forever answers one question fast: where is that item? Type a name and it lists every place the item sits, on the character you are on and on every alt that has logged in since the addon was installed, instead of opening bag after bag.

It only reads. It never moves, sells, mails or uses an item.

## Features

- **One search, every container.** Bags, the reagent bag, the bank and its reagent bank are read when the window opens and again when a container changes, so one name finds every stack instead of one bag's worth.
- **Tabs.** `All`, `Bags`, `Bank`, `Alts` and `Guild` keep the query and switch the source. The Guild tab has no vault reading yet and stays empty until that is built.
- **Counts per source.** A result shows the total and where the stacks sit, so a bank stack is not read as a bag one.
- **Alts record themselves.** Each character writes its bags and bank when they change and at logout, with a timestamp on the reading, so an alt's stash is searchable without logging over to it.
- **Filters in the search box.** `q:epic` for a quality, `t:weapon` for an item class and `ilvl:>200` for a level. A token the box does not recognise is searched as text, never refused.
- **A short list, best match first.** An exact name comes first, then a name that starts with the query, then a word inside the name, then any match. Case and accents are ignored, and an empty box lists the largest stacks first.
- **Link a result.** `Enter` links the first result to chat; hold `Shift` and click any row to link that one instead.
- **The client's own window.** Built from `PortraitFrameTemplate`, the game's search box and its tab buttons. No new art and no minimap button.

## Install

Download the zip from [Releases](https://github.com/cjber/hoard-forever/releases) and extract it into `_classic_beta_/Interface/AddOns/`, so you end up with `AddOns/HoardForever/HoardForever.toc`. After an update, `/reload`.

The addon targets the WoW: Forever client, Interface 16001. It needs nothing else installed.

## Usage

| Command | What it does |
|---|---|
| `/hoard`, `/hoardforever` | Open the search window |

The addon compartment button opens it too, and `Esc` closes it.

Settings > AddOns > Hoard Forever holds three things: **Cache the guild vault**, **Record this character for the Alts tab**, and a button to **Clear alt snapshots**.

## What it reads

Bags and the bank come from the client's container API while you have them open. An alt's stash comes from the saved file each character writes, so a character appears in `Alts` only after it has logged in with the addon installed. A source the client does not offer is left out of the tabs and the counts rather than shown as an empty result.

## Works alongside

Hoard Forever works with nothing else installed and nothing else depends on it. It does not share the bag, bank or tracking addons' frames, so a bag addon's layout is untouched.

<!-- forever-family:start -->

## The Forever addons

Each one works on its own, and they work together when you install more than one.

| Addon | What it does |
|---|---|
| [Shortest Path Forever](https://www.curseforge.com/wow/addons/shortest-path-forever) | Plans journeys on foot, by air, by sea and through portals, with directions in the tracker. |
| [Adventure Guide Forever](https://www.curseforge.com/wow/addons/adventure-guide-forever) | Suggests quests for your level and routes you from one to the next. |
| [SkillUp Forever](https://www.curseforge.com/wow/addons/skillup-forever) | Shows skill-up chances, recipe costs and levelling routes in the Professions window. |
| [Legacy Forever](https://www.curseforge.com/wow/addons/legacy-forever) | Shows your unfinished Legacy challenges on the world map and tracks the ones you choose. |
| [Tweaks Forever](https://www.curseforge.com/wow/addons/tweaks-forever) | Adds quest automation, rare alerts and merchant options to the game's settings. |

<!-- forever-family:end -->

## Development

Specs run on LuaJIT against a mock client (`tests/wow_mock.lua`), so they need no game client:

```sh
for spec in tests/*_spec.lua; do luajit "$spec" || exit 1; done
```

[AGENTS.md](AGENTS.md) has the full gate, the layout and the rules this repository is held to.

## Credits

Made by cjber. Blizzard Entertainment for the game, its item and container APIs and the window templates the addon is built from. The WoW: Forever project for the client it is written for. [THIRD_PARTY.md](THIRD_PARTY.md) lists every input.

World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment.

## Licence

GPL-3.0-or-later. See [LICENSE](LICENSE).

Made by Cillian Berragan · [cillian.dev](https://cillian.dev) · [GitHub](https://github.com/cjber) · [Twitter](https://twitter.com/cjberragan)

Built with AI assistance.
