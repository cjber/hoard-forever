Hoard Forever answers one question fast: where is that item? Type a name and it lists every place the item sits, on the character you are on and on every alt that has logged in since the addon was installed.

![The Hoard Forever window with a search for linen cloth and its results split by source](https://raw.githubusercontent.com/cjber/hoard-forever/main/docs/screenshots/window.png)

The window is the game's own frame, search box and tabs.

## Features

- **One search, every container.** Bags, the reagent bag, the bank and its reagent bank are read when the window opens and again when a container changes.
- **Tabs.** `All`, `Bags`, `Bank`, `Alts` and `Guild` keep the query and switch the source.
- **Counts per source.** A result shows the total and where the stacks sit.
- **Alts record themselves.** Each character writes its bags and bank when they change and at logout, with a timestamp.
- **Filters in the search box.** `q:epic`, `t:weapon` and `ilvl:>200` narrow a search; anything else is searched as text.
- **Best match first.** An exact name, then a name prefix, then a word inside the name, then any match, ignoring case and accents.
- **Link a result.** `Enter` links the first result to chat; `Shift`-click a row to link that one.

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

## Usage

`/hoard` or `/hoardforever` opens the window, and so does the addon compartment button. `Esc` closes it.

Settings > AddOns > Hoard Forever holds **Cache the guild vault**, **Record this character for the Alts tab** and a button to **Clear alt snapshots**.

The addon only reads. It never moves, sells, mails or uses an item.

Source: [github.com/cjber/hoard-forever](https://github.com/cjber/hoard-forever), GPL-3.0-or-later.

The addon is free. If it saves you time, you can [buy me a coffee on Ko-fi](https://ko-fi.com/cjber59408).

Built with AI assistance.
