local _ = ...

local function Register()
	if not Settings or not Settings.RegisterCanvasLayoutCategory then
		return
	end
	local panel = CreateFrame("Frame")
	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Hoard Forever")
	local guild = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	guild:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -18)
	guild.Text:SetText("Cache the guild vault")
	guild:SetScript("OnClick", function(self)
		HoardForeverDB.settings.cacheGuild = self:GetChecked()
	end)
	guild:SetChecked(HoardForeverDB.settings.cacheGuild)
	local alts = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	alts:SetPoint("TOPLEFT", guild, "BOTTOMLEFT", 0, -8)
	alts.Text:SetText("Record this character for the Alts tab")
	alts:SetScript("OnClick", function(self)
		HoardForeverDB.settings.recordAlts = self:GetChecked()
	end)
	alts:SetChecked(HoardForeverDB.settings.recordAlts)
	local clear = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	clear:SetSize(180, 24)
	clear:SetPoint("TOPLEFT", alts, "BOTTOMLEFT", 0, -14)
	clear:SetText("Clear alt snapshots")
	clear:SetScript("OnClick", function()
		local current = UnitName("player") .. "-" .. GetRealmName()
		for key in pairs(HoardForeverDB.chars) do
			if key ~= current then
				HoardForeverDB.chars[key] = nil
			end
		end
	end)
	local category = Settings.RegisterCanvasLayoutCategory(panel, "Hoard Forever")
	Settings.RegisterAddOnCategory(category)
end

if C_Timer and C_Timer.After then
	C_Timer.After(0, Register)
else
	Register()
end
