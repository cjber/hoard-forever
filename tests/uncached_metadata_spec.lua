local Mock = dofile("tests/wow_mock.lua")
local ns = Mock.Harness().ns
for _, missingFirst in ipairs({ true, false }) do
	local missing = { itemID = 100, count = 3, character = "Uncached" }
	local known = { itemID = 100, count = 6, name = "Arcane Crystal", icon = 123, character = "Known" }
	local records = missingFirst and { missing, known } or { known, missing }
	local index = ns.Model.Build(records)
	assert(#index == 1 and index[1].total == 9, "cached metadata must not split item totals")
	assert(index[1].name == "Arcane Crystal" and index[1].icon == 123, "known metadata fills missing fields")
	assert(#index[1].sources == 2, "all characters remain represented")
	local hits = ns.Model.Query(index, "crystal", "All")
	assert(#hits == 1 and hits[1].total == 9, "name searches include uncached copies")
end
print("uncached metadata: ok")
