# Changelog

All notable changes to this addon are recorded here. The format follows Keep a Changelog, and the project adheres to Semantic Versioning.

## [Unreleased]

## [0.1.6] - 2026-11-03

- **The bank is read under bag replacements.** Baganator keeps Blizzard's bank frame on a hidden parent for the whole
  session, so asking it whether the bank was open said no and the Bank tab quietly collected nothing. The addon now
  follows the client's own `BANKFRAME_OPENED` and `BANKFRAME_CLOSED` events instead.

## [0.1.5] - 2026-11-03

- **Item tooltips use translated source labels.** Bank and bag labels match the result row in every language.
- **Empty searches show a useful message.** The item-link hint appears only when a search has results.

## [0.1.4] - 2026-11-03

- **Bank items stay searchable after closing the bank.** Your current character uses the last bank snapshot until the bank is opened again.
- **Uncached item names no longer split totals.** Copies of one item share a row and use known metadata from another character.

## [0.1.3] - 2026-11-02

- **The bank is the bank, and the reagent bag is carried.** On the Forever client the bank scan read the keyring as the bank and counted the reagent bag among the bank tabs, while the reagent bag was missing from Bags; the scan now takes its containers from the client's own `Enum.BagIndex`, and falls back to the same numbers on a client without it. Nothing else about a snapshot changed, so saved readings still load.
- **The type check runs the type checker.** CI's typecheck job installed no language server, so `tools/typecheck.sh` stopped after the tooling checks and never checked a type. The job now pins lua-language-server 3.19.1 and the `types/` declarations it needs, and any diagnostic fails the build.
- **Choose the tab the window opens on.** Settings > AddOns > Hoard Forever has an Open on tab option, and the window now opens on it. The setting was saved but never read, so the window always started on whatever tab was last left selected.
- **See how old an alt's stash is.** Hovering a result lists each alt's stack with how long ago that character was recorded, dimmed, such as "Updated 3d ago", so an old reading is not mistaken for what the alt carries now.

## [0.1.2] - 2026-11-02

- **Opening the bank no longer doubles what you carry.** The bank scan read the backpack and bags along with the bank, so every carried stack counted twice while the bank was open. It now reads the bank and its bank bags only.
- **Guild vault items stay on the Guild tab.** They no longer also appear under `Alts`.
- **Turning off "Record this character for the Alts tab" stops the saving.** The character's bags were still written to the saved file on every change; now they are only indexed for this session.
- **A long result list scrolls.** Rows past the fifth used to draw below the window; the list now scrolls, and the status reads "1 result." for a single match.
- **Hovering a result shows the item tooltip.** Clicking is no longer needed to see it.
- **Clearing alt snapshots updates the window at once.** Cleared alts used to stay listed until the next bag change.

## [0.1.1] - 2026-10-30

- **The README credits the people behind the addon.** Its Credits section thanks everyone who reports a bug or asks for a feature, and THIRD_PARTY.md's Ideas and contributors table now has the shape the other Forever addons use, so a player whose report is built is credited the same way in every addon.

## [0.1.0] - 2026-10-26

- **Search everything you own from one window.** Bags, reagent bag, bank, warband bank and your alts' cached stashes are indexed the moment the window opens, so a name finds every stack instead of one bag.
- **Guild vault snapshots appear in search after the vault is opened.** Hoard keeps a read-only cache for the current guild so the Guild tab can show its items after you close the bank.
- **Tabs narrow a search without retyping it.** `All`, `Bags`, `Bank`, `Alts` and `Guild` keep the query and switch the source.
- **Counts are per source.** A result shows the total plus where the stacks sit, so a bank stack is never read as a bag one.
- **Alts record themselves.** Each character writes its bags and bank snapshot when they change and at logout, with a timestamp on the reading.
- **Search folding and result ranking come from Forever Core.** The addon's own accented-letter table is gone; `Core/Text.lua` folds the whole Latin-1 range once for the suite, so every accented item name matches. The settings page's chrome is Forever Core's shared `UI/SettingsPage.lua` too, with the same options and the same button as before.
- **Built from the client's own UI.** No new art, no minimap button, and nothing touched outside the window.
- **The README and store page match the rest of the Forever suite.** They carry the family block, the badges, the icon and the licence and credits sections every sibling has, and they describe only what this build does.
- Shared tooling and CI check the vendored forever_tools package, project profile and suite drift.
