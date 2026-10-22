local Mock = dofile("tests/wow_mock.lua")
local ns = Mock.Harness().ns
local function row(name, kind, count, character, extra)
	local value =
		{ itemID = 100, name = name, quality = 4, icon = 1, kind = kind, count = count, character = character }
	for key, item in pairs(extra or {}) do
		value[key] = item
	end
	return value
end

local index = ns.Model.Build({
	row("Arcane Crystal", "bags", 2),
	row("Arcane Crystal", "bank", 3),
	row("Arcane Crystal", "bags", 4, "Alt-Realm"),
	row("Arcane Crystal", "guild", 5),
	row("Arcane Crystal", "bank", 6, "Second-Realm"),
	row("Arcane Dust", "bags", 10, nil, { itemID = 101, quality = 2, class = "Trade Goods", ilvl = 1 }),
	row("Bronze Sword", "bags", 1, nil, { itemID = 102, quality = 1, class = "Weapon", ilvl = 12 }),
})
assert(#index == 3, "items should be grouped by identity")
local crystal = ns.Model.Query(index, "arcane crystal", "All")[1]
assert(crystal and crystal.total == 20 and #crystal.sources == 5, "all five source stacks should add up")
assert(ns.Model.Query(index, "crystal", "Bags")[1].total == 2, "source tab should filter")
assert(ns.Model.Query(index, "q:epic", "All")[1].itemID == 100, "quality token should filter")
assert(ns.Model.Query(index, "t:weapon", "All")[1].name == "Bronze Sword", "class token should filter")
assert(ns.Model.Query(index, "ilvl:>10", "All")[1].name == "Bronze Sword", "item level token should filter")
assert(ns.Model.Query(index, "ilvl:>=12", "All")[1].name == "Bronze Sword", "inclusive level token should filter")
assert(ns.Model.Query(index, "ilvl:<12", "All")[1].name == "Arcane Dust", "less-than level token should filter")
assert(ns.Model.Query(index, "ilvl:<=1", "All")[1].name == "Arcane Dust", "inclusive less-than token should filter")
assert(#ns.Model.Query(index, "q:mythic", "All") == 0, "unknown quality tokens should remain text")
assert(#ns.Model.Query({}, "anything", "All") == 0, "empty index should be safe")
local ranked = ns.Model.Query(index, "arcane", "All")
assert(ranked[1].name == "Arcane Crystal", "prefix result with more copies should rank first")
local accentIndex = ns.Model.Build({ row("Élan Crystal", "bags", 1, nil, { itemID = 103 }) })
assert(#ns.Model.Query(accentIndex, "elan", "All") == 1, "search should ignore accents")

print("model_spec: ok")
