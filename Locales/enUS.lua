-- English is the source language: every phrase the addon shows lives here first.
local _, ns = ...

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})
ns.L = L

L["Hoard Forever"] = "Hoard Forever"
L["Search your bags, bank, alts and guild vault."] = "Search your bags, bank, alts and guild vault."
L["Type to search. Press Enter to link the first result."] = "Type to search. Press Enter to link the first result."
