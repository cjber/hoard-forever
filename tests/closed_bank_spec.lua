local Mock = dofile("tests/wow_mock.lua")
local h = Mock.Harness()
h:Fire("ADDON_LOADED", "HoardForever")
h.env.BankFrame = h.env.CreateFrame("Frame", "BankFrame")
h.env.C_Container = {
	GetContainerNumSlots = function(container)
		return (container == 0 or container == -1) and 1 or 0
	end,
	GetContainerItemInfo = function(container)
		return { itemID = container == 0 and 55 or 66, stackCount = container == 0 and 3 or 7 }
	end,
}
h.env.C_Item = {
	GetItemInfo = function(id)
		return tostring(id)
	end,
}
local function total(id)
	for _, item in ipairs(h.ns.index) do
		if item.itemID == id then
			return item.total
		end
	end
	return 0
end
h.env.BankFrame:Show()
h.ns.Rebuild()
assert(total(55) == 3 and total(66) == 7, "open bank and bags are counted once")
h.env.BankFrame:Hide()
h:Fire("BAG_UPDATE_DELAYED")
assert(total(55) == 3 and total(66) == 7, "closed bank keeps cached current-character items")
h.env.BankFrame:Show()
h.ns.Rebuild()
assert(total(66) == 7, "reopening the bank does not double-count cached contents")
print("closed bank: ok")
