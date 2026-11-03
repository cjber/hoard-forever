local Mock = dofile("tests/wow_mock.lua")
local h = Mock.Harness()
local ns, env = h.ns, h.env
local create = env.CreateFrame
env.CreateFrame = function(kind, name, parent, template)
	local frame = create(kind, name, parent, template)
	-- The inert mock does not instantiate template children or plain Lua fields.
	rawset(frame, "rows", {})
	if template == "PortraitFrameTemplate" then
		rawset(frame, "TitleText", frame:CreateFontString())
	end
	return frame
end
env.PanelTemplates_SelectTab = function() end
env.PanelTemplates_DeselectTab = function() end
env.GRAY_FONT_COLOR = { r = 0.5, g = 0.5, b = 0.5 }
env.time = function()
	return 1000
end
local tooltip
env.GameTooltip.AddDoubleLine = function(_, left)
	tooltip = left
end
ns.L.bank = "Banque"
ns.Rebuild = nil
ns.index = ns.Model.Build({
	{ itemID = 100, name = "Test Item", kind = "bank", count = 7, character = "Alt-Realm", updated = 900 },
})
ns.Open("Test Item")
local window = env.HoardForeverWindow
local row = window.list.rows[1]
assert(row.sources:GetText() == "Alt-Realm Banque 7", "row uses the localized source label")
row:GetScript("OnEnter")(row)
assert(tooltip == "Alt-Realm Banque 7", "tooltip uses the same localized label as the row")
assert(window.status:GetText() == ns.L["1 result. Shift-click to link an item."], "a result keeps its link hint")
ns.Open("missing")
assert(window.empty:IsShown(), "an empty search explains why no items are shown")
assert(window.status:GetText() == "", "an empty search has no inapplicable link hint")
ns.index = {}
ns.Open("")
assert(window.empty:GetText() == ns.L["No items found."], "an empty inventory has its own explanation")
assert(window.status:GetText() == "", "an empty inventory has no link hint either")
assert(window:GetWidth() == 720 and window:GetHeight() == 460, "empty searches preserve the window dimensions")
print("results_ui_spec: localized tooltip and useful empty states ok")
