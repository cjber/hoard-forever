local _, ns = ...
local L = ns.L
local Results = {}
ns.Results = Results

-- How long ago an alt's snapshot was saved, in the tooltip's dimmed right-hand column.
---@param seconds number
---@return string
function Results.Age(seconds)
	if seconds < 60 then
		return L["Updated just now"]
	elseif seconds < 3600 then
		return L["Updated %dm ago"]:format(math.floor(seconds / 60))
	elseif seconds < 86400 then
		return L["Updated %dh ago"]:format(math.floor(seconds / 3600))
	end
	return L["Updated %dd ago"]:format(math.floor(seconds / 86400))
end

-- The item's own tooltip, then one line per alt stack with the age of that alt's snapshot, so an old reading is
-- never mistaken for a current one.
local function ShowTooltip(row)
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(row.item.link or ("item:" .. row.item.itemID))
	local now = time()
	for _, source in ipairs(row.item.sources) do
		if source.character and source.updated and source.kind ~= "guild" then
			local gray = GRAY_FONT_COLOR
			GameTooltip:AddDoubleLine(
				source.character .. " " .. (L[source.kind] or source.kind) .. " " .. source.count,
				Results.Age(now - source.updated),
				1,
				1,
				1,
				gray.r,
				gray.g,
				gray.b
			)
		end
	end
	GameTooltip:Show()
end

function Results.Render(parent, items)
	if not parent.rows then
		parent.rows = {}
	end
	for _, row in ipairs(parent.rows) do
		row:Hide()
	end
	-- The list is a scroll child: its height is what lets the scroll frame reach rows past the visible area.
	parent:SetHeight(math.max(1, #items * 50))
	for index, item in ipairs(items) do
		local row = parent.rows[index]
		if not row then
			row = CreateFrame("Button", nil, parent)
			row:SetHeight(46)
			row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
			row.icon = row:CreateTexture(nil, "ARTWORK")
			row.icon:SetSize(37, 37)
			row.icon:SetPoint("LEFT", 6, 0)
			row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -3)
			row.name:SetWidth(420)
			row.name:SetWordWrap(false)
			row.count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
			row.count:SetPoint("TOPRIGHT", -8, -5)
			row.sources = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.sources:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 4)
			row.sources:SetWidth(500)
			row.sources:SetWordWrap(false)
			row:SetScript("OnClick", function(self)
				if IsShiftKeyDown() and self.item.link then
					ChatEdit_InsertLink(self.item.link)
				end
			end)
			row:SetScript("OnEnter", ShowTooltip)
			row:SetScript("OnLeave", function()
				if GameTooltip then
					GameTooltip:Hide()
				end
			end)
			parent.rows[index] = row
		end
		row.item = item
		row:SetPoint("TOPLEFT", 0, -((index - 1) * 50))
		row:SetPoint("TOPRIGHT", 0, -((index - 1) * 50))
		row.icon:SetTexture(item.icon)
		row.name:SetText(item.name)
		local colour = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.quality or 1]
		if colour then
			row.name:SetTextColor(colour.r, colour.g, colour.b)
		end
		row.count:SetText(item.total)
		local chips = {}
		for _, source in ipairs(item.sources) do
			chips[#chips + 1] = (source.character and (source.character .. " ") or "")
				.. (L[source.kind] or source.kind)
				.. " "
				.. source.count
		end
		row.sources:SetText(table.concat(chips, "  ·  "))
		row:Show()
	end
end

return Results
