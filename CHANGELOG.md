# Changelog

All notable changes to this addon are recorded here. The format follows Keep a Changelog, and the project adheres to Semantic Versioning.

## [Unreleased]

### Added

- **Guild vault snapshots now appear in search after the vault is opened.** Hoard keeps a read-only cache for the current guild so the Guild tab can show its items after you close the bank.

### Changed

- Shared tooling and CI now check the vendored forever_tools package, project profile and suite drift.

- **The README and store page now match the rest of the Forever suite.** They carry the family block, the badges, the icon and the licence and credits sections every sibling has, and they describe only what this build does: bags, the reagent bag, the bank, cached alts and the search filters. The guild vault is not read yet, and the README says so.

## [0.1.0] - 2026-10-22

- **Search everything you own from one window.** Bags, reagent bag, bank, warband bank, the guild vault and your alts' cached stashes are indexed the moment the window opens, so a name finds every stack instead of one bag.
- **Tabs narrow a search without retyping it.** `All`, `Bags`, `Bank`, `Alts` and `Guild` keep the query and switch the source.
- **Counts are per source.** A result shows the total plus where the stacks sit, so a bank stack is never read as a bag one.
- **Alts record themselves.** Each character writes its bags and bank snapshot when they change and at logout, with a timestamp on the reading.
- **Built from the client's own UI.** No new art, no minimap button, and nothing touched outside the window.
