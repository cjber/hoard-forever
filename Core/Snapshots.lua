-- Reads only client-visible containers and returns serialisable item records.
local _, ns = ...
local Snapshots = {}
ns.Snapshots = Snapshots

local function Record(item, kind, character, tab)
	if not item then
		return nil
	end
	local itemID = item.itemID
	if not itemID and type(item.hyperlink) == "string" then
		itemID = tonumber(item.hyperlink:match("item:(%d+)"))
	end
	if not itemID then
		return nil
	end
	local details = { C_Item.GetItemInfo(item.hyperlink or item.itemID) }
	local name, link, quality, itemLevel = details[1], details[2], details[3], details[4]
	local class, icon = details[6], details[10]
	return {
		itemID = itemID,
		name = name or item.name,
		link = item.hyperlink or link,
		quality = quality,
		icon = item.iconFileID or icon,
		ilvl = itemLevel,
		class = class,
		count = item.stackCount or 1,
		kind = kind,
		character = character,
		tab = tab,
		suffix = item.suffix,
	}
end

local function ReadContainer(container, kind, character)
	local records = {}
	if not C_Container then
		return records
	end
	local ok, slots = pcall(C_Container.GetContainerNumSlots, container)
	if not ok or not slots then
		return records
	end
	for slot = 1, slots do
		local success, info = pcall(C_Container.GetContainerItemInfo, container, slot)
		if success and info then
			local record = Record(info, kind, character)
			if record then
				records[#records + 1] = record
			end
		end
	end
	return records
end

local function Append(into, from)
	for _, item in ipairs(from) do
		into[#into + 1] = item
	end
end

-- The Forever client's Enum.BagIndex names the containers: Keyring = -1, Characterbanktab = -2, ReagentBag = 5 and
-- CharacterBankTab_1..9 = 6..14, with no Reagentbank. It never reads the keyring as the bank. The numbers below are
-- the same values, for a client whose Enum has no name for one of them.
local BACKPACK, BAG_SLOTS = 0, 4
local REAGENT_BAG = 5
local BANK_CONTAINER, BANK_TAB_COUNT = -1, 9
local FIRST_BANK_TAB = 6

-- One container id by enum name, falling back to the value the Forever client uses when the enum is absent or has
-- no such name.
---@param index table<string, any>? the client's Enum.BagIndex
---@param name string
---@param fallback integer
---@return integer
local function ContainerID(index, name, fallback)
	local value = index and index[name]
	if type(value) == "number" then
		return value
	end
	return fallback
end

function Snapshots.Scan()
	local index = Enum and Enum.BagIndex
	local scan = { bags = {}, bank = nil }
	-- The backpack and the setup bags, then the reagent bag as one more carried bag.
	for slot = BACKPACK, NUM_BAG_SLOTS or BAG_SLOTS do
		Append(scan.bags, ReadContainer(slot, "bags"))
	end
	Append(scan.bags, ReadContainer(ContainerID(index, "ReagentBag", REAGENT_BAG), "bags"))
	local bankOpen = BankFrame and BankFrame:IsShown()
	if bankOpen then
		scan.bank = {}
		-- The character bank and its tabs, which the enum numbers after the reagent bag.
		Append(scan.bank, ReadContainer(ContainerID(index, "Characterbanktab", BANK_CONTAINER), "bank"))
		-- The enum names nine bank tabs; a client without the enum reports how many it has.
		local bankTabs = NUM_BANKBAGSLOTS or BANK_TAB_COUNT
		if index or bankTabs > BANK_TAB_COUNT then
			bankTabs = BANK_TAB_COUNT
		end
		for tab = 1, bankTabs do
			local fallback = FIRST_BANK_TAB + tab - 1
			Append(scan.bank, ReadContainer(ContainerID(index, "CharacterBankTab_" .. tab, fallback), "bank"))
		end
	end
	local records = {}
	Append(records, scan.bags)
	if scan.bank then
		Append(records, scan.bank)
	end
	scan.records = records
	return scan
end

-- Guild-bank APIs are not present until the vault is available. Probe each call under pcall and keep
-- only item identifiers, counts and labels in the snapshot; never retain client tables.
local function GuildCall(api, name, ...)
	local fn = api and api[name]
	if type(fn) ~= "function" then
		fn = _G[name]
	end
	if type(fn) ~= "function" then
		return false
	end
	return pcall(fn, ...)
end

function Snapshots.Guild(guildName)
	local records = {}
	local api = C_GuildBank
	local ok, tabs = GuildCall(api, "GetNumGuildBankTabs")
	if not ok or type(tabs) ~= "number" or tabs < 1 then
		return records
	end
	for tab = 1, tabs do
		local visible, tabName
		local infoOK, a, _, c = GuildCall(api, "GetGuildBankTabInfo", tab)
		if infoOK then
			if type(a) == "table" then
				tabName, visible = a.name, a.isViewable
			else
				tabName, visible = a, c
			end
		end
		if visible ~= false then
			local slotsOK, slots = GuildCall(api, "GetGuildBankNumSlots", tab)
			if slotsOK and type(slots) == "number" then
				for slot = 1, slots do
					local itemOK, itemInfo, count = GuildCall(api, "GetGuildBankItemInfo", tab, slot)
					local linkOK, link = GuildCall(api, "GetGuildBankItemLink", tab, slot)
					if itemOK and linkOK and type(link) == "string" then
						local item
						if type(itemInfo) == "table" then
							item = { itemID = itemInfo.itemID, hyperlink = link, stackCount = itemInfo.count }
						else
							item = { hyperlink = link, stackCount = count }
						end
						local record = Record(item, "guild", guildName, tabName or ("Tab " .. tab))
						if record then
							records[#records + 1] = record
						end
					end
				end
			end
		end
	end
	return records
end

return Snapshots
