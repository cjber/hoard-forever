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
L["Cache the guild vault"] = "Cache the guild vault"
L["Record this character for the Alts tab"] = "Record this character for the Alts tab"
L["Clear alt snapshots"] = "Clear alt snapshots"
L["Open on tab"] = "Open on tab"
L["All"] = "All"
L["Bags"] = "Bags"
L["Bank"] = "Bank"
L["Alts"] = "Alts"
L["Guild"] = "Guild"
L["Updated just now"] = "Updated just now"
L["Updated %dm ago"] = "Updated %dm ago"
L["Updated %dh ago"] = "Updated %dh ago"
L["Updated %dd ago"] = "Updated %dd ago"
L["No items found for “%s”."] = "No items found for “%s”."
L["No items found."] = "No items found."
L["bags"] = "Bags"
L["bank"] = "Bank"
L["guild"] = "Guild"
L["1 result. Shift-click to link an item."] = "1 result. Shift-click to link an item."
L["%d results. Shift-click to link an item."] = "%d results. Shift-click to link an item."
