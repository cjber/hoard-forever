local _, ns = ...
local window, queryText, selectedTab
local tabs = { "All", "Bags", "Bank", "Alts", "Guild" }

-- Selects a tab by name, showing it as the selected tab button.
local function SelectTab(name)
	selectedTab = name
	for index, button in ipairs(window.tabs) do
		if tabs[index] == name then
			PanelTemplates_SelectTab(button)
		else
			PanelTemplates_DeselectTab(button)
		end
	end
end

-- The tab the window opens on: the player's choice from the settings page, or All for a value no tab has.
local function DefaultTab()
	local saved = HoardForeverDB and HoardForeverDB.settings and HoardForeverDB.settings.defaultTab
	for _, name in ipairs(tabs) do
		if name == saved then
			return name
		end
	end
	return "All"
end

local function Refresh()
	if not window or not ns.index then
		return
	end
	local results = ns.Model.Query(ns.index, queryText:GetText(), selectedTab)
	ns.Results.Render(window.list, results)
	local count = #results == 1 and ("1 " .. ns.L["result"] .. ".") or (#results .. " " .. ns.L["results"] .. ".")
	window.status:SetText(count .. " " .. ns.L["Shift-click to link an item."])
	window.empty:SetShown(#results == 0)
	local query = queryText:GetText()
	window.empty:SetText(query == "" and ns.L["No items found."] or ns.L["No items found for “%s”."]:format(query))
end

function ns.Open(query)
	if not window then
		window = CreateFrame("Frame", "HoardForeverWindow", UIParent, "PortraitFrameTemplate")
		window:SetSize(720, 460)
		window:SetPoint("CENTER")
		window:SetMovable(true)
		window:EnableMouse(true)
		window:RegisterForDrag("LeftButton")
		window:SetScript("OnDragStart", window.StartMoving)
		window:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
		end)
		window.TitleText:SetText("Hoard Forever")
		if window.SetPortraitToAsset then
			window:SetPortraitToAsset("Interface\\AddOns\\HoardForever\\media\\Icon")
		end
		window.search = CreateFrame("EditBox", nil, window, "SearchBoxTemplate")
		window.search:SetSize(300, 26)
		window.search:SetPoint("TOPLEFT", 24, -54)
		window.search:SetAutoFocus(false)
		window.search:HookScript("OnTextChanged", Refresh)
		window.search:SetScript("OnEnterPressed", function(self)
			local results = ns.Model.Query(ns.index or {}, self:GetText(), selectedTab)
			if results[1] and results[1].link then
				ChatEdit_InsertLink(results[1].link)
			end
		end)
		-- Rows live in a scroll child, so a search with more results than fit scrolls instead of drawing past the frame.
		window.scroll = CreateFrame("ScrollFrame", "HoardForeverResultsScroll", window, "UIPanelScrollFrameTemplate")
		window.scroll.scrollBarHideable = true
		window.scroll:SetPoint("TOPLEFT", window.search, "BOTTOMLEFT", 0, -12)
		window.scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -50, 48)
		window.list = CreateFrame("Frame", nil, window.scroll)
		window.list:SetSize(720 - 24 - 50, 1)
		window.scroll:SetScrollChild(window.list)
		window.empty = window.list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		window.empty:SetPoint("TOPLEFT", 8, -8)
		window.status = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		window.status:SetPoint("BOTTOMRIGHT", -28, 28)
		window.tabs = {}
		for index, name in ipairs(tabs) do
			local tab = CreateFrame("Button", nil, window, "PanelTabButtonTemplate")
			tab:SetID(index)
			tab:SetText(ns.L[name])
			if index == 1 then
				tab:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", 18, 0)
			else
				tab:SetPoint("LEFT", window.tabs[index - 1], "RIGHT", 3, 0)
			end
			tab:SetScript("OnClick", function(self)
				SelectTab(tabs[self:GetID()])
				Refresh()
			end)
			window.tabs[index] = tab
		end
		window:Hide()
		table.insert(UISpecialFrames, "HoardForeverWindow")
	end
	if not window:IsShown() then
		SelectTab(DefaultTab())
	end
	queryText = window.search
	if query then
		window.search:SetText(query)
	end
	window:Show()
	if ns.Rebuild then
		ns.Rebuild()
	end
	window.search:SetFocus()
	Refresh()
end

ns.OnIndexReady = Refresh
return window
