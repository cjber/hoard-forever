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

-- Closing the bank must refresh bags without deleting the last bank scan or its older age.
local current = next(db.chars)
local bankTime = harness.env.time()
db.chars[current].bank = { { itemID = 99, count = 2, name = "Bank Item" } }
db.chars[current].bankUpdated = bankTime - 600
db.chars[current].bagsUpdated = bankTime - 60
ns.Rebuild()
assert(
	db.chars[current].bank and db.chars[current].bank[1].itemID == 99,
	"a closed bank must keep its cached bank items"
)
assert(db.chars[current].bankUpdated == bankTime - 600, "a bag scan must not refresh the bank age")
local bankResults = ns.Model.Query(ns.index, "bank", "Bank")
assert(bankResults[1] and bankResults[1].itemID == 99, "a closed bank must remain searchable in the current Bank tab")

-- The result list grows with its rows, so its scroll frame can reach every one, and a row explains itself on hover.
local list = harness.env.CreateFrame("Frame", nil, harness.env.UIParent)
list.rows = {} -- the mock answers any unknown field with a function, where the client answers nil
local items = {}
for index = 1, 8 do
	items[index] = { itemID = index, name = "Item " .. index, total = 1, sources = { { kind = "bags", count = 1 } } }
end
ns.Results.Render(list, items)
assert(list:GetHeight() == 8 * 50, "the list should be as tall as its rows")
assert(list.rows[1]:GetScript("OnEnter"), "a result row should show its tooltip on hover")

-- Each alt's stack carries the time its snapshot was saved, and the row's tooltip says how old it is, dimmed.
local env = harness.env
db.chars["Arderin-TestRealm"] =
	{ updated = env.time() - 3 * 86400, bags = { { itemID = 55, count = 2, name = "Mock Item" } } }
ns.Rebuild()
local altSource

for _, item in ipairs(ns.index) do
	if item.itemID == 55 then
		for _, source in ipairs(item.sources) do
			if source.character == "Arderin-TestRealm" then
				altSource = source
			end
		end
	end
end
assert(altSource and altSource.updated == env.time() - 3 * 86400, "an alt's stack should keep its snapshot's time")
env.GRAY_FONT_COLOR = { r = 0.5, g = 0.5, b = 0.5 }
local lines = {}
env.GameTooltip.AddDoubleLine = function(_, left, right, _, _, _, r)
	lines[#lines + 1] = { left = left, right = right, r = r }
end
local item55
for _, item in ipairs(ns.index) do
	if item.itemID == 55 then
		item55 = item
	end
end
ns.Results.Render(list, { item55 })
list.rows[1]:GetScript("OnEnter")(list.rows[1])
assert(#lines == 1, "the tooltip should name the one alt stack, not this character's bags")
assert(lines[1].left == "Arderin-TestRealm Bags 2", "the line should name the alt and its stack")
assert(lines[1].right == "Updated 3d ago" and lines[1].r == 0.5, "the snapshot's age should show, dimmed")
assert(ns.Results.Age(30) == "Updated just now" and ns.Results.Age(7200) == "Updated 2h ago", "ages read plainly")

-- The window opens on the tab chosen in settings, and falls back to All for a value no tab has.
local selected
env.PanelTemplates_SelectTab = function(button)
	selected = button
end
env.PanelTemplates_DeselectTab = function() end
local createFrame = env.CreateFrame
env.CreateFrame = function(kind, name, parent, template)
	local frame = createFrame(kind, name, parent, template)
	frame.rows = {} -- the mock answers any unknown field with a function, where the client answers nil
	if template == "PortraitFrameTemplate" then
		frame.TitleText = createFrame("FontString")
	end
	return frame
end
local queried
local query = ns.Model.Query
ns.Model.Query = function(index, text, tab)
	queried = tab
	return query(index, text, tab)
end
db.settings.defaultTab = "Bank"
ns.Open()
local window = env.HoardForeverWindow
assert(queried == "Bank", "the window should open on the saved default tab, not " .. tostring(queried))
assert(selected == window.tabs[3], "the Bank tab button should be the selected one")
window.tabs[4]:GetScript("OnClick")(window.tabs[4])
ns.Open()
assert(queried == "Alts", "reopening a shown window keeps the tab the player picked")
window:Hide()
db.settings.defaultTab = "Nowhere"
ns.Open()
assert(queried == "All" and selected == window.tabs[1], "an unknown saved tab opens on All")

print("core_spec: ok")
