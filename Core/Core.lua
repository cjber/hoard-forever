-- Entry point: saved settings, the slash command and the addon compartment button.
-- Feature code lives in the modules the TOC loads after this file; nothing here draws a frame.
local addonName, ns = ...

ns.name = addonName
ns.L = ns.L or setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})

-- Every setting the addon reads is declared here, so an old save file and a new option always agree (WFA-14).
ns.DEFAULTS = {
	window = { point = "CENTER", x = 0, y = 0, width = 720, height = 460 },
	settings = { defaultTab = "All", cacheGuild = true, recordAlts = true },
}

local defaults = ns.DEFAULTS
local function MergeDefaults(target, source)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if type(target[key]) ~= "table" then
				target[key] = {}
			end
			MergeDefaults(target[key], value)
		elseif target[key] == nil then
			target[key] = value
		end
	end
end

local function CharacterKey()
	local name, realm = UnitName("player"), GetRealmName()
	return tostring(name or "Unknown") .. "-" .. tostring(realm or "Unknown")
end

local function SaveSnapshot()
	if not HoardForeverDB.settings.recordAlts then
		return
	end
	local scan = ns.Snapshots.Scan()
	local key = CharacterKey()
	local previous = HoardForeverDB.chars[key] or {}
	previous.bags = scan.bags
	if scan.bank then
		previous.bank = scan.bank
	end
	previous.updated = time()
	HoardForeverDB.chars[key] = previous
end

local function Rebuild()
	local scan = ns.Snapshots.Scan()
	HoardForeverDB.chars = HoardForeverDB.chars or {}
	local current = CharacterKey()
	local old = HoardForeverDB.chars[current] or {}
	old.bags = scan.bags
	if scan.bank then
		old.bank = scan.bank
	end
	old.updated = time()
	HoardForeverDB.chars[current] = old
	for character, snapshot in pairs(HoardForeverDB.chars) do
		if character ~= current and type(snapshot) == "table" then
			for _, kind in ipairs({ "bags", "bank", "guild" }) do
				for _, item in ipairs(snapshot[kind] or {}) do
					local copy = {}
					for key, value in pairs(item) do
						copy[key] = value
					end
					copy.kind, copy.character = kind, character
					scan.records[#scan.records + 1] = copy
				end
			end
		end
	end
	ns.index = ns.Model.Build(scan.records)
	if ns.OnIndexReady then
		ns.OnIndexReady()
	end
end
ns.Rebuild = Rebuild

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, arg)
	if event == "ADDON_LOADED" and arg == addonName then
		HoardForeverDB = HoardForeverDB or {}
		MergeDefaults(HoardForeverDB, defaults)
		HoardForeverDB.schema = 1
		HoardForeverDB.chars = HoardForeverDB.chars or {}
		frame:UnregisterEvent("ADDON_LOADED")
		for _, name in ipairs({
			"BAG_UPDATE_DELAYED",
			"PLAYERBANKSLOTS_CHANGED",
			"PLAYERBANKBAGSLOTS_CHANGED",
			"GUILDBANK_UPDATE_TABS",
		}) do
			frame:RegisterEvent(name)
		end
		frame:RegisterEvent("PLAYER_LOGOUT")
	elseif event == "PLAYER_LOGOUT" then
		SaveSnapshot()
	else
		Rebuild()
	end
end)

SLASH_HOARDFOREVER1 = "/hoard"
SLASH_HOARDFOREVER2 = "/hoardforever"
SlashCmdList.HOARDFOREVER = function(message)
	if ns.Open then
		ns.Open(message)
	end
end

function HoardForever_OnAddonCompartmentClick()
	if ns.Open then
		ns.Open()
	end
end
