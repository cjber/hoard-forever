-- The Characters tab: one row per recorded character with gold, level, professions, hearth, bag and bank totals and
-- when it was last seen, read from the saved snapshots alone. It shares the result list's frame and row rhythm.
local _, ns = ...
local L = ns.L
local Characters = {}
ns.Characters = Characters

local ROW_STEP, ROW_HEIGHT = 50, 46

-- Gold in the client's coin format, or nil when the snapshot never recorded it.
---@param money number?
---@return string?
local function Money(money)
	if type(money) ~= "number" then
		return nil
	end
	if type(GetMoneyString) == "function" then
		local ok, text = pcall(GetMoneyString, money, true)
		if ok and type(text) == "string" then
			return text
		end
	end
	return tostring(money)
end

-- The row's second line: level, then each profession's skill, hearth and the bag and bank totals that were recorded.
---@param character table one entry of ns.Model.Characters
---@return string
function Characters.Details(character)
	local parts = {}
	if character.level then
		parts[#parts + 1] = L["Level %d"]:format(character.level)
	end
	for _, profession in ipairs(character.professions or {}) do
		parts[#parts + 1] = profession.rank and (profession.name .. " " .. profession.rank) or profession.name
	end
	if character.hearth then
		parts[#parts + 1] = L["Hearth: %s"]:format(character.hearth)
	end
	parts[#parts + 1] = L["bags"] .. " " .. character.bags
	if character.bank then
		parts[#parts + 1] = L["bank"] .. " " .. character.bank
	end
	return table.concat(parts, "  ·  ")
end

local function NewRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(37, 37) -- art-ok: classicon atlases are square, drawn square
	row.icon:SetPoint("LEFT", 6, 0)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -3)
	row.name:SetWidth(360)
	row.name:SetWordWrap(false)
	row.money = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.money:SetPoint("TOPRIGHT", -8, -5)
	row.seen = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.seen:SetPoint("BOTTOMRIGHT", -8, 8)
	row.details = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.details:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 4)
	row.details:SetWidth(480)
	row.details:SetWordWrap(false)
	return row
end

---@param parent table the scroll child frame the result rows also use
---@param characters table[] from ns.Model.Characters
function Characters.Render(parent, characters)
	if type(parent.characterRows) ~= "table" then
		parent.characterRows = {}
	end
	for _, row in ipairs(parent.characterRows) do
		row:Hide()
	end
	if #characters == 0 then
		return
	end
	parent:SetHeight(math.max(1, #characters * ROW_STEP))
	local now = time()
	for index, character in ipairs(characters) do
		local row = parent.characterRows[index]
		if not row then
			row = NewRow(parent)
			parent.characterRows[index] = row
		end
		row:SetPoint("TOPLEFT", 0, -((index - 1) * ROW_STEP))
		row:SetPoint("TOPRIGHT", 0, -((index - 1) * ROW_STEP))
		local class = type(character.class) == "string" and character.class or nil
		row.icon:SetShown(class ~= nil)
		if class then
			row.icon:SetAtlas("classicon-" .. class:lower())
		end
		row.name:SetText(ns.Tooltip.Holder(character.key))
		local colour = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
		if colour then
			row.name:SetTextColor(colour.r, colour.g, colour.b)
		else
			row.name:SetTextColor(1, 1, 1)
		end
		row.money:SetText(Money(character.money) or "")
		if character.current then
			row.seen:SetText(L["Playing now"])
		elseif character.updated then
			row.seen:SetText(ns.Tooltip.Age(now - character.updated))
		else
			row.seen:SetText("")
		end
		row.details:SetText(Characters.Details(character))
		row:Show()
	end
end

return Characters
