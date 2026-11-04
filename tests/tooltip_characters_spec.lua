-- The item tooltip names every place Hoard has seen the item, and the Characters tab summarises each recorded
-- character from its saved snapshot.
local Mock = dofile("tests/wow_mock.lua")
Mock.Reset()

-- The client's post-call registry, captured so the spec can call what the addon registered.
local postCalls = {}
local h = Mock.Harness()
local ns, env = h.ns, h.env

-- The registration ran at load against the harness globals; register again now the mock has a processor.
env.Enum.TooltipDataType = { Item = 0 }
env.TooltipDataProcessor = {
	AddTooltipPostCall = function(kind, fn)
		postCalls[#postCalls + 1] = { kind = kind, fn = fn }
	end,
}
h.Load("UI/Tooltip.lua")
assert(#postCalls == 1 and postCalls[1].kind == 0, "the addon registers one item tooltip post-call")
local OnItem = postCalls[1].fn

h:Fire("ADDON_LOADED", "HoardForever")
local db = env.HoardForeverDB
assert(db.settings.tooltip == true, "the tooltip lines are on by default (WFA-2)")

-- This character's snapshot records what the Characters tab shows.
env.C_Container = {
	GetContainerNumSlots = function(container)
		return container == 0 and 2 or 0
	end,
	GetContainerItemInfo = function(_, slot)
		return { itemID = 2589, stackCount = slot == 1 and 12 or 8, hyperlink = "item:2589" }
	end,
}
env.C_Item = {
	GetItemInfo = function()
		return "Linen Cloth"
	end,
}
env.GetMoney = function()
	return 123456
end
env.GetBindLocation = function()
	return "Ironforge"
end
env.GetProfessions = function()
	return 1, nil, 2
end
env.GetProfessionInfo = function(index)
	if index == 1 then
		return "Tailoring", 0, 225, 300
	end
	return "Mining", 0, 150, 150
end
ns.Rebuild()
local mine = db.chars["Tester-TestRealm"]
assert(mine.money == 123456 and mine.level == 60 and mine.class == "WARRIOR", "gold, level and class are recorded")
assert(mine.hearth == "Ironforge", "the hearth is recorded")
assert(#mine.professions == 2 and mine.professions[1].name == "Tailoring", "both professions are recorded")
assert(mine.professions[2].rank == 150, "a profession keeps its skill")

-- A client without the profession API keeps the last recorded list rather than blanking it.
env.GetProfessions = nil
ns.Rebuild()
assert(#db.chars["Tester-TestRealm"].professions == 2, "a missing API keeps the recorded professions")

-- An alt on the same realm, one on another, and the guild vault, each holding Linen Cloth.
db.chars["Maro-TestRealm"] = {
	updated = env.time() - 2 * 86400,
	level = 42,
	class = "MAGE",
	money = 5000,
	bags = { { itemID = 2589, count = 3, name = "Linen Cloth" } },
	bank = { { itemID = 2589, count = 26, name = "Linen Cloth" } },
}
db.chars["Talandra-Elsewhere"] = { updated = env.time() - 3600, bags = {} }
ns.Rebuild()

local lines = {}
env.GameTooltip.AddDoubleLine = function(_, left, right)
	lines[#lines + 1] = { left = left, right = right }
end
OnItem(env.GameTooltip, { id = 2589 })
local text = {}
for _, line in ipairs(lines) do
	text[line.left] = line.right
end
assert(text["Bags 20"] == "", "this character's two bag stacks read as one line, with no age")
assert(text["Maro Bags 3"] == "Updated 2d ago", "a same-realm alt reads without its realm, with its age")
assert(text["Maro Bank 26"], "an alt's bank is its own line")
assert(#lines == 3, "one line per source, and none for a character without the item")

-- Nothing for an item Hoard has never seen, a forbidden tooltip, a comparison tooltip, or with the setting off.
lines = {}
OnItem(env.GameTooltip, { id = 1 })
assert(#lines == 0, "an unknown item adds nothing")
env.GameTooltip.IsForbidden = function()
	return true
end
OnItem(env.GameTooltip, { id = 2589 })
assert(#lines == 0, "a forbidden tooltip is left alone")
env.GameTooltip.IsForbidden = function()
	return false
end
OnItem(env.CreateFrame("GameTooltip", "ShoppingTooltip1"), { id = 2589 })
assert(#lines == 0, "comparison tooltips get no lines")
db.settings.tooltip = false
OnItem(env.GameTooltip, { id = 2589 })
assert(#lines == 0, "the setting turns the lines off")
db.settings.tooltip = true

-- A secret item ID is never compared or indexed.
env.canaccessvalue = function()
	return false
end
OnItem(env.GameTooltip, { id = 2589 })
assert(#lines == 0, "a secret item ID adds nothing")
env.canaccessvalue = nil

-- The model: this character first, then the most recently seen, filtered by name.
local characters = ns.Model.Characters(db.chars, "Tester-TestRealm", "")
assert(#characters == 3 and characters[1].current, "this character leads the list")
assert(characters[2].key == "Talandra-Elsewhere" and characters[3].key == "Maro-TestRealm", "then by last seen")
assert(characters[1].bags == 20 and characters[1].bank == nil, "a bank never opened has no total")
assert(characters[3].bank == 26, "a recorded bank has its total")
assert(#ns.Model.Characters(db.chars, "Tester-TestRealm", "maro") == 1, "the search box filters characters")

-- The Characters tab draws one row per character in the shared list.
env.PanelTemplates_SelectTab = function() end
env.PanelTemplates_DeselectTab = function() end
env.RAID_CLASS_COLORS = { MAGE = { r = 0.25, g = 0.78, b = 0.92 } }
env.GetMoneyString = function(money)
	return money .. "c"
end
local create = env.CreateFrame
env.CreateFrame = function(kind, name, parent, template)
	local frame = create(kind, name, parent, template)
	rawset(frame, "rows", {})
	rawset(frame, "characterRows", {})
	if template == "PortraitFrameTemplate" then
		rawset(frame, "TitleText", frame:CreateFontString())
	end
	return frame
end
db.settings.defaultTab = "Characters"
ns.Open()
local window = env.HoardForeverWindow
local rows = window.list.characterRows
assert(#rows == 3 and rows[1]:IsShown(), "one row per recorded character")
assert(rows[1].name:GetText() == "Tester" and rows[1].seen:GetText() == "Playing now", "this character is current")
assert(rows[1].money:GetText() == "123456c", "gold is shown in the client's money format")
assert(
	rows[1].details:GetText() == "Level 60  ·  Tailoring 225  ·  Mining 150  ·  Hearth: Ironforge  ·  Bags 20",
	"the details line reads " .. rows[1].details:GetText()
)
assert(rows[3].details:GetText() == "Level 42  ·  Bags 3  ·  Bank 26", "an alt shows only what was recorded")
assert(rows[2].name:GetText() == "Talandra-Elsewhere", "an alt on another realm keeps its realm")
assert(window.status:GetText() == "3 characters.", "the status line counts characters")
for _, row in ipairs(window.list.rows) do
	assert(not row:IsShown(), "no item row shows on the Characters tab")
end

-- Back on an item tab, the character rows give way to items.
window.tabs[1]:GetScript("OnClick")(window.tabs[1])
for _, row in ipairs(rows) do
	assert(not row:IsShown(), "character rows hide on an item tab")
end
assert(window.list.rows[1] and window.list.rows[1]:IsShown(), "item rows return")

print("tooltip_characters_spec: ok")
