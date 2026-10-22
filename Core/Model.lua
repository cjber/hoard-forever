-- Pure item grouping and search. Inputs are plain records so this module is easy to spec.
local _, ns = ...
local Model = {}
ns.Model = Model

local function Fold(value)
	value = tostring(value or "")
	local replacements = {
		["á"] = "a",
		["à"] = "a",
		["â"] = "a",
		["ä"] = "a",
		["ã"] = "a",
		["Á"] = "a",
		["À"] = "a",
		["Â"] = "a",
		["Ä"] = "a",
		["Ã"] = "a",
		["é"] = "e",
		["è"] = "e",
		["ê"] = "e",
		["ë"] = "e",
		["í"] = "i",
		["ï"] = "i",
		["É"] = "e",
		["È"] = "e",
		["Ê"] = "e",
		["Ë"] = "e",
		["Í"] = "i",
		["Ï"] = "i",
		["ó"] = "o",
		["ô"] = "o",
		["ö"] = "o",
		["õ"] = "o",
		["ú"] = "u",
		["ü"] = "u",
		["ç"] = "c",
		["Ó"] = "o",
		["Ô"] = "o",
		["Ö"] = "o",
		["Õ"] = "o",
		["Ú"] = "u",
		["Ü"] = "u",
		["Ç"] = "c",
	}
	for from, to in pairs(replacements) do
		value = value:gsub(from, to)
	end
	return value:lower()
end

function Model.Build(scan)
	local grouped = {}
	for _, raw in ipairs(scan or {}) do
		if raw.itemID and raw.count and raw.count > 0 then
			local key =
				table.concat({ raw.itemID, raw.suffix or "", raw.quality or "", raw.icon or "", raw.name or "" }, "|")
			local item = grouped[key]
			if not item then
				item = {
					itemID = raw.itemID,
					suffix = raw.suffix,
					quality = raw.quality,
					icon = raw.icon,
					name = raw.name or tostring(raw.itemID),
					class = raw.class,
					ilvl = raw.ilvl,
					link = raw.link,
					sources = {},
					total = 0,
				}
				grouped[key] = item
			end
			local sourceKey = table.concat({ raw.kind or "bags", raw.character or "", raw.tab or "" }, "|")
			local source = item._sources and item._sources[sourceKey]
			if not source then
				source = { kind = raw.kind or "bags", character = raw.character, tab = raw.tab, count = 0 }
				item._sources = item._sources or {}
				item._sources[sourceKey] = source
				item.sources[#item.sources + 1] = source
			end
			source.count = source.count + raw.count
			item.total = item.total + raw.count
		end
	end
	local result = {}
	for _, item in pairs(grouped) do
		item._sources = nil
		result[#result + 1] = item
	end
	return result
end

local function Parse(text)
	local filters, words = {}, {}
	for token in tostring(text or ""):gmatch("%S+") do
		local q = token:match("^q:(%a+)$")
		local class = token:match("^t:(%a+)$")
		local op, level = token:match("^ilvl:([<>]=?)(%d+)$")
		if q then
			local qualities =
				{ poor = 0, common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, artifact = 6, heirloom = 7 }
			if qualities[q:lower()] then
				filters.quality = qualities[q:lower()]
			else
				words[#words + 1] = token
			end
		elseif class then
			filters.class = Fold(class)
		elseif op then
			filters.level = { op = op, value = tonumber(level) }
		else
			words[#words + 1] = Fold(token)
		end
	end
	return filters, table.concat(words, " ")
end

local function MatchSource(item, tab)
	if not tab or tab == "All" then
		return true
	end
	for _, source in ipairs(item.sources) do
		if tab == "Alts" and source.character then
			return true
		end
		if tab == "Bags" and source.kind == "bags" and not source.character then
			return true
		end
		if tab == "Bank" and source.kind == "bank" and not source.character then
			return true
		end
		if tab == "Guild" and source.kind == "guild" then
			return true
		end
	end
	return false
end

local function Rank(item, query)
	local name = Fold(item.name)
	if query == "" then
		return 0
	end
	if name == query then
		return 1
	end
	if name:sub(1, #query) == query then
		return 2
	end
	for word in name:gmatch("%S+") do
		if word:sub(1, #query) == query then
			return 3
		end
	end
	if name:find(query, 1, true) then
		return 4
	end
	return nil
end

local function PassLevel(actual, filter)
	if not filter then
		return true
	end
	local op, value = filter.op, filter.value
	if op == ">" then
		return actual and actual > value
	end
	if op == ">=" then
		return actual and actual >= value
	end
	if op == "<" then
		return actual and actual < value
	end
	if op == "<=" then
		return actual and actual <= value
	end
	return false
end

function Model.Query(index, text, tab)
	local filters, query = Parse(text)
	local result = {}
	for _, item in ipairs(index or {}) do
		local rank = Rank(item, query)
		local matchingSources, visibleTotal = {}, 0
		for _, source in ipairs(item.sources) do
			local holder = { sources = { source } }
			if MatchSource(holder, tab) then
				matchingSources[#matchingSources + 1] = source
				visibleTotal = visibleTotal + source.count
			end
		end
		local passes = rank
			and #matchingSources > 0
			and (not filters.quality or (item.quality or -1) >= filters.quality)
			and (not filters.class or Fold(item.class) == filters.class)
			and PassLevel(item.ilvl, filters.level)
		if passes then
			local visible = {}
			for key, value in pairs(item) do
				visible[key] = value
			end
			visible.sources, visible.total = matchingSources, visibleTotal
			result[#result + 1] = { item = visible, rank = rank }
		end
	end
	table.sort(result, function(a, b)
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		if a.item.total ~= b.item.total then
			return a.item.total > b.item.total
		end
		return Fold(a.item.name) < Fold(b.item.name)
	end)
	local items = {}
	for _, entry in ipairs(result) do
		items[#items + 1] = entry.item
	end
	return items
end

return Model
