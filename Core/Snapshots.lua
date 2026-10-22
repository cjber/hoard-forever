-- Reads only client-visible containers and returns serialisable item records.
local _, ns = ...
local Snapshots = {}
ns.Snapshots = Snapshots

local function Record(item, kind, character, tab)
	if not item or not item.itemID then
		return nil
	end
	local details = { C_Item.GetItemInfo(item.hyperlink or item.itemID) }
	local name, link, quality, itemLevel = details[1], details[2], details[3], details[4]
	local class, icon = details[6], details[10]
	return {
		itemID = item.itemID,
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

function Snapshots.Scan()
	local scan = { bags = {}, bank = nil }
	for container = 0, 4 do
		Append(scan.bags, ReadContainer(container, "bags"))
	end
	local bankOpen = BankFrame and BankFrame:IsShown()
	if bankOpen then
		scan.bank = {}
		for container = -1, NUM_BANKGENERAL_SLOTS or 0 do
			Append(scan.bank, ReadContainer(container, "bank"))
		end
		local reagent = Enum and Enum.BagIndex and Enum.BagIndex.Reagentbank
		if reagent then
			Append(scan.bank, ReadContainer(reagent, "bank"))
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

return Snapshots
