# Changelog

All notable changes to this addon are recorded here. The format follows Keep a Changelog, and the project adheres to Semantic Versioning.

## [Unreleased]

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
