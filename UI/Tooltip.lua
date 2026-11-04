-- Where an item is, under its own tooltip: one line per place Hoard has seen it (this character's bags and bank, each
-- alt and the guild vault) with the count there, read from the index the last rebuild left. Nothing is added for an
-- item Hoard has never seen. Lines are added after the client's own (TooltipDataProcessor), never by hooking a
-- Blizzard method, and a forbidden tooltip is left alone.
local _, ns = ...
local L = ns.L
local Tooltip = {}
ns.Tooltip = Tooltip

-- Set while a result row draws its own tooltip, so the item post-call does not add the same lines a second time.
local drawingRow = false

-- A character key without the player's own realm, so "Maro-Realm" reads "Maro" for an alt on the same realm.
---@param key string
---@return string
function Tooltip.Holder(key)
	local realm = type(GetRealmName) == "function" and GetRealmName()
	if type(realm) == "string" and key:sub(-(#realm + 1)) == "-" .. realm then
		return key:sub(1, -(#realm + 2))
	end
	return key
end

-- What a source is called in a row's chips and in a tooltip: "Bags", "Maro Bank", "Guild (Tab 1)".
---@param source table
---@return string
function Tooltip.Label(source)
	local kind = L[source.kind] or source.kind
	if source.kind == "guild" then
		return source.tab and (kind .. " (" .. source.tab .. ")") or kind
	end
	if source.character then
		return Tooltip.Holder(source.character) .. " " .. kind
	end
	return kind
end

-- How long ago an alt's snapshot was saved, in the tooltip's dimmed right-hand column.
---@param seconds number
---@return string
function Tooltip.Age(seconds)
	if seconds < 60 then
		return L["Updated just now"]
	elseif seconds < 3600 then
		return L["Updated %dm ago"]:format(math.floor(seconds / 60))
	elseif seconds < 86400 then
		return L["Updated %dh ago"]:format(math.floor(seconds / 3600))
	end
	return L["Updated %dd ago"]:format(math.floor(seconds / 86400))
end

-- One line per source: its label and count, and for an alt's stack the age of that alt's snapshot, dimmed, so an old
-- reading is never mistaken for a current one.
---@param tooltip GameTooltip
---@param sources table[]
function Tooltip.AddSources(tooltip, sources)
	local now = time()
	local gray = GRAY_FONT_COLOR
	for _, source in ipairs(sources) do
		local age = ""
		if source.character and source.updated and source.kind ~= "guild" then
			age = Tooltip.Age(now - source.updated)
		end
		tooltip:AddDoubleLine(
			Tooltip.Label(source) .. " " .. source.count,
			age,
			1,
			1,
			1,
			gray and gray.r or 0.5,
			gray and gray.g or 0.5,
			gray and gray.b or 0.5
		)
	end
end

-- A result row's tooltip: the item's own, then the alts' stacks with their ages. The row's chips already show every
-- source, so the tooltip adds only what they cannot: how old each alt's reading is.
---@param row table a result row with its item
function Tooltip.ShowRow(row)
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	drawingRow = true
	pcall(GameTooltip.SetHyperlink, GameTooltip, row.item.link or ("item:" .. row.item.itemID))
	drawingRow = false
	local alts = {}
	for _, source in ipairs(row.item.sources) do
		if source.character and source.updated and source.kind ~= "guild" then
			alts[#alts + 1] = source
		end
	end
	Tooltip.AddSources(GameTooltip, alts)
	GameTooltip:Show()
end

-- The item post-call: the main tooltip and a clicked link's tooltip only, not the comparison tooltips beside them.
---@param tooltip GameTooltip
---@param data table?
function Tooltip.OnItem(tooltip, data)
	if not ns.Usable(tooltip) or drawingRow then
		return
	end
	if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then
		return
	end
	local settings = HoardForeverDB and HoardForeverDB.settings
	if not settings or not settings.tooltip or not ns.byItem then
		return
	end
	local itemID = data and ns.Readable(data.id)
	local sources = type(itemID) == "number" and ns.byItem[itemID]
	if sources and #sources > 0 then
		Tooltip.AddSources(tooltip, sources)
	end
end

local processor = TooltipDataProcessor
local itemType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item
if processor and type(processor.AddTooltipPostCall) == "function" and itemType then
	processor.AddTooltipPostCall(itemType, Tooltip.OnItem)
end

return Tooltip
