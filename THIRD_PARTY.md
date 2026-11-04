# Third party

Hoard ships no third-party code or client data. Its offline README screenshots use the first-party renderer in
[forever-core](https://github.com/cjber/forever-core/tree/main/tools/wowmock); it fetches Blizzard client art and item
records for the pinned Forever build from wago.tools when screenshots are generated. The fetched inputs remain in the
local cache; only the rendered documentation images are committed.

## Ideas and contributors

Credit for the ideas and reports behind the addon.

| Who | What | Notes |
|---|---|---|
| cjber | Asked for a standalone search across bags, bank, alts and the guild vault | |
| cjber | Asked for item tooltips that say where the item is, and an alts summary | #48, #49 |
| [Syndicator](https://www.curseforge.com/wow/addons/syndicator) | Item counts per character in the tooltip | Idea only, no code copied (#48) |
| [Altoholic](https://www.curseforge.com/wow/addons/altoholic) | One view of every character's gold, level and professions | Idea only, no code copied (#49) |

Thanks also to everyone else who reported a bug or asked for a feature, here or on CurseForge.
