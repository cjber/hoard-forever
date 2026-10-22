local _, ns = ...
local Results = {}
ns.Results = Results

function Results.Render(parent, items)
	if not parent.rows then
		parent.rows = {}
	end
	for _, row in ipairs(parent.rows) do
		row:Hide()
	end
	for index, item in ipairs(items) do
		local row = parent.rows[index]
		if not row then
			row = CreateFrame("Button", nil, parent, "BackdropTemplate")
			row:SetHeight(48)
			row.icon = row:CreateTexture(nil, "ARTWORK")
			row.icon:SetSize(36, 36)
			row.icon:SetPoint("LEFT", 6, 0)
			row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -3)
			row.count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
			row.count:SetPoint("TOPRIGHT", -8, -5)
			row.sources = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.sources:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 4)
			row:SetScript("OnClick", function(self)
				if IsShiftKeyDown() and self.item.link then
					ChatEdit_InsertLink(self.item.link)
				elseif GameTooltip then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetHyperlink(self.item.link or ("item:" .. self.item.itemID))
					GameTooltip:Show()
				end
			end)
			row:SetScript("OnLeave", function()
				if GameTooltip then
					GameTooltip:Hide()
				end
			end)
			parent.rows[index] = row
		end
		row.item = item
		row:SetPoint("TOPLEFT", 0, -((index - 1) * 52))
		row:SetPoint("TOPRIGHT", 0, -((index - 1) * 52))
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
				.. source.kind
				.. " "
				.. source.count
		end
		row.sources:SetText(table.concat(chips, "  ·  "))
		row:Show()
	end
end

return Results
