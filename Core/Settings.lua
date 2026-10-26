local _, ns = ...

-- The settings page's chrome -- the panel, its title, the rows that stack down it and the category registration -- is
-- Forever Core's UI/SettingsPage.lua, vendored byte for byte. What stays here is Hoard's own two options, its one
-- button, the phrases they show, and what each of them does to the saved variables.
local function Register()
	local _, panel = ns.SettingsPage.Register("Hoard Forever", function(target, page)
		page.AddCheck(target, "Cache the guild vault", function()
			return HoardForeverDB.settings.cacheGuild
		end, function(checked)
			HoardForeverDB.settings.cacheGuild = checked
			if checked and ns.RefreshGuild then
				ns.RefreshGuild()
			end
			if ns.Rebuild then
				ns.Rebuild()
			end
		end)
		page.AddCheck(target, "Record this character for the Alts tab", function()
			return HoardForeverDB.settings.recordAlts
		end, function(checked)
			HoardForeverDB.settings.recordAlts = checked
		end)
		page.AddButton(target, "Clear alt snapshots", function()
			local current = UnitName("player") .. "-" .. GetRealmName()
			for key in pairs(HoardForeverDB.chars) do
				if key ~= current then
					HoardForeverDB.chars[key] = nil
				end
			end
		end)
	end)
	return panel
end

if C_Timer and C_Timer.After then
	C_Timer.After(0, Register)
else
	Register()
end
