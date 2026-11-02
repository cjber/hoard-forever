-- The addon loads, declares its defaults, and publishes its namespace.
local Mock = dofile("tests/wow_mock.lua")

Mock.Reset()
local harness = Mock.Harness()
local ns = harness.ns

assert(type(ns) == "table", "the addon did not publish its namespace")
assert(type(ns.DEFAULTS) == "table", "ns.DEFAULTS must be declared (WFA-14)")
assert(type(ns.DEFAULTS.window) == "table", "ns.DEFAULTS.window is missing")

-- With "Record this character for the Alts tab" off, a rebuild indexes the bags but saves nothing.
harness:Fire("ADDON_LOADED", "HoardForever")
local db = harness.env.HoardForeverDB
harness.env.C_Container = {
	GetContainerNumSlots = function(container)
		return container == 0 and 1 or 0
	end,
	GetContainerItemInfo = function()
		return { itemID = 55, stackCount = 3, hyperlink = "item:55" }
	end,
}
harness.env.C_Item = {
	GetItemInfo = function()
		return "Mock Item"
	end,
}
db.settings.recordAlts = false
ns.Rebuild()
assert(next(db.chars) == nil, "a character with recording off should not be saved")
assert(#ns.index == 1 and ns.index[1].total == 3, "recording off should still index this character's bags")
db.settings.recordAlts = true
ns.Rebuild()
assert(next(db.chars) ~= nil, "a character with recording on should be saved")

-- The result list grows with its rows, so its scroll frame can reach every one, and a row explains itself on hover.
local list = harness.env.CreateFrame("Frame", nil, harness.env.UIParent)
list.rows = {} -- the mock answers any unknown field with a function, where the client answers nil
local items = {}
for index = 1, 8 do
	items[index] = { itemID = index, name = "Item " .. index, total = 1, sources = { { kind = "bags", count = 1 } } }
end
ns.Results.Render(list, items)
assert(list:GetHeight() == 8 * 52, "the list should be as tall as its rows")
assert(list.rows[1]:GetScript("OnEnter"), "a result row should show its tooltip on hover")

print("core_spec: ok")
