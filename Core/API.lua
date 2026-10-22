local _, ns = ...

local api = { version = "1.0.0" }
function api.Count(itemID)
	if not ns.index then
		return nil
	end
	local total, sources = 0, {}
	for _, item in ipairs(ns.index) do
		if item.itemID == itemID then
			total = total + item.total
			for _, source in ipairs(item.sources) do
				sources[#sources + 1] = source
			end
		end
	end
	return total, sources
end
function api.Open(query)
	if ns.Open then
		return ns.Open(query)
	end
end
HoardForever = api
return api
