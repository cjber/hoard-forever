local _, ns = ...
local window, queryText, selectedTab
local tabs = { "All", "Bags", "Bank", "Alts", "Guild" }

local function Refresh()
	if not window or not ns.index then
		return
	end
	local results = ns.Model.Query(ns.index, queryText:GetText(), selectedTab)
	ns.Results.Render(window.list, results)
	window.status:SetText(#results .. " results. Shift-click to link an item.")
	window.empty:SetShown(#results == 0)
	window.empty:SetText("No items found for “" .. queryText:GetText() .. "”.")
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
		window.search = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
		window.search:SetSize(300, 26)
		window.search:SetPoint("TOPLEFT", 24, -54)
		window.search:SetAutoFocus(false)
		window.search:SetScript("OnTextChanged", Refresh)
		window.search:SetScript("OnEnterPressed", function(self)
			local results = ns.Model.Query(ns.index or {}, self:GetText(), selectedTab)
			if results[1] and results[1].link then
				ChatEdit_InsertLink(results[1].link)
			end
		end)
		window.list = CreateFrame("Frame", nil, window)
		window.list:SetPoint("TOPLEFT", window.search, "BOTTOMLEFT", 0, -60)
		window.list:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -28, 48)
		window.empty = window.list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		window.empty:SetPoint("TOPLEFT", 8, -8)
		window.status = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		window.status:SetPoint("BOTTOMLEFT", 28, 22)
		window.tabs = {}
		for index, name in ipairs(tabs) do
			local tab = CreateFrame("Button", nil, window, "PanelTabButtonTemplate")
			tab:SetID(index)
			tab:SetText(name)
			tab:SetPoint("TOPLEFT", window, "TOPLEFT", 18 + (index - 1) * 84, -82)
			tab:SetScript("OnClick", function(self)
				selectedTab = tabs[self:GetID()]
				for _, button in ipairs(window.tabs) do
					PanelTemplates_DeselectTab(button)
				end
				PanelTemplates_SelectTab(self)
				Refresh()
			end)
			window.tabs[index] = tab
		end
		selectedTab = "All"
		table.insert(UISpecialFrames, "HoardForeverWindow")
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
