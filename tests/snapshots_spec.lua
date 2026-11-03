local Mock = dofile("tests/wow_mock.lua")
local harness = Mock.Harness()
harness.env.C_Container = {
	GetContainerNumSlots = function(container)
		return container == 0 and 1 or 0
	end,
	GetContainerItemInfo = function(container, slot)
		if container == 0 and slot == 1 then
			return { itemID = 55, stackCount = 7, hyperlink = "item:55" }
		end
	end,
}
harness.env.C_Item = {
	GetItemInfo = function()
		return "Mock Item", "item:55", 3, 42, 40, "Trade Goods", "Other", 20, "", 1234
	end,
}
local scan = harness.ns.Snapshots.Scan()
assert(#scan.bags == 1 and scan.bags[1].count == 7, "bags should become item records")
assert(scan.bags[1].itemID == 55 and scan.bags[1].name == "Mock Item", "item metadata should be captured")
assert(scan.bank == nil, "closed bank should not appear as an empty source")

local original = { updated = 1000, bags = scan.bags, bank = { { itemID = 99, count = 2 } } }
local copy = { updated = original.updated, bags = {}, bank = {} }
for _, item in ipairs(original.bags) do
	copy.bags[#copy.bags + 1] = { itemID = item.itemID, count = item.count }
end
for _, item in ipairs(original.bank) do
	copy.bank[#copy.bank + 1] = { itemID = item.itemID, count = item.count }
end
assert(
	copy.updated == original.updated and copy.bags[1].count == 7 and copy.bank[1].itemID == 99,
	"snapshots should round trip through flat saved values"
)

-- The Forever client's Enum.BagIndex, in full: the keyring is -1, the character bank is -2, the reagent bag is 5 and
-- the character bank tabs run 6 to 14. There is no Reagentbank.
local FOREVER_BAG_INDEX = {
	Keyring = -1,
	Characterbanktab = -2,
	Backpack = 0,
	Bag_1 = 1,
	Bag_2 = 2,
	Bag_3 = 3,
	Bag_4 = 4,
	ReagentBag = 5,
	CharacterBankTab_1 = 6,
	CharacterBankTab_2 = 7,
	CharacterBankTab_3 = 8,
	CharacterBankTab_4 = 9,
	CharacterBankTab_5 = 10,
	CharacterBankTab_6 = 11,
	CharacterBankTab_7 = 12,
	CharacterBankTab_8 = 13,
	CharacterBankTab_9 = 14,
}

-- The container the Forever client keeps the reagent bag in, which the carried bags now include.
local REAGENT_BAG = 5

-- Every container the scan asks about, with how many times it was read, and one slot of item in each: the item id
-- records which container produced it.
local function Record()
	local read = {}
	harness.env.C_Container.GetContainerNumSlots = function(container)
		read[container] = (read[container] or 0) + 1
		return 1
	end
	harness.env.C_Container.GetContainerItemInfo = function(container)
		return { itemID = 200 + container, stackCount = 1, hyperlink = "item:" .. (200 + container) }
	end
	return read
end

local function Scanned(records)
	local ids = {}
	for _, record in ipairs(records) do
		ids[record.itemID - 200] = true
	end
	return ids
end

-- A client with no Enum at all: the carried bags are 0 to NUM_BAG_SLOTS, the reagent bag follows them, and the bank is
-- -1 plus NUM_BANKBAGSLOTS bank bags numbered from 6.
harness.env.Enum = nil
harness.env.NUM_BAG_SLOTS, harness.env.NUM_BANKBAGSLOTS = 4, 6
-- No BankFrame at all: the open/closed events carry this, not the frame.
local plain = Record()
local plainScan = harness.ns.Snapshots.Scan(true)
assert(#plainScan.bags == 6 and #plainScan.bank == 7, "an open bank should not count the carried bags again")
assert(plain[5] == 1, "the reagent bag is a carried bag")
for container = 0, 11 do
	assert(plain[container] == 1, "container " .. container .. " should be read exactly once")
end
assert(plain[12] == nil, "nothing past the last bank bag should be read")
assert(plain[-1] == 1, "a client without the enum keeps its own bank container")
assert(plain[-2] == nil, "the enum's character bank is not read on a client without the enum")

-- Bag-only, and on the Forever client: the reagent bag is read with the carried bags, and no bank is read at all.
harness.env.Enum = { BagIndex = FOREVER_BAG_INDEX }
local closed = Record()
local closedScan = harness.ns.Snapshots.Scan(false)
assert(closedScan.bank == nil, "a closed bank should not appear as an empty source")
assert(#closedScan.bags == 6, "the backpack, the setup bags and the reagent bag are the carried bags")
assert(closed[5] == 1 and closed[-2] == nil, "a closed bank is never read")
assert(Scanned(closedScan.bags)[REAGENT_BAG] == true, "the reagent bag's item is a bag item")
-- With the Forever bank open: the character bank is Enum.BagIndex.Characterbanktab (-2) and its tabs are 6 to 14. The
-- keyring (-1) is not the bank.
local booked = Record()
local open = harness.ns.Snapshots.Scan(true)
assert(#open.bags == 6 and #open.bank == 10, "the bank is the character bank plus nine bank tabs")
assert(booked[-1] == nil, "the keyring is never read as the bank")
assert(booked[-2] == 1, "the character bank is read once, through the enum")
for container = 0, 14 do
	assert(booked[container] == 1, "container " .. container .. " should be read exactly once")
end
assert(booked[15] == nil, "nothing past the last bank tab should be read")
assert(
	Scanned(open.bank)[-2] == true and Scanned(open.bank)[14] == true,
	"the bank reads its own container and its tabs"
)
assert(Scanned(open.bags)[-2] == nil, "a bank item is never a bag item")

print("snapshots_spec: ok")

harness.env.C_GuildBank = {
	GetNumGuildBankTabs = function()
		return 1
	end,
	GetGuildBankTabInfo = function()
		return { name = "Materials", isViewable = true }
	end,
	GetGuildBankNumSlots = function()
		return 2
	end,
	GetGuildBankItemInfo = function(_, slot)
		return slot == 1 and { count = 12 } or nil
	end,
	GetGuildBankItemLink = function(_, slot)
		return slot == 1 and "item:77" or nil
	end,
}
local guild = harness.ns.Snapshots.Guild("Guild-TestRealm")
assert(#guild == 1 and guild[1].kind == "guild", "the open guild vault should produce guild records")
assert(guild[1].itemID == 77 and guild[1].count == 12, "guild item links and stack counts should be cached")

harness.env.C_GuildBank.GetNumGuildBankTabs = function()
	error("vault unavailable")
end
assert(#harness.ns.Snapshots.Guild("Guild-TestRealm") == 0, "missing guild bank data should fail closed")

-- BankFrame is gone entirely here: the client's own open/closed events are what say the bank is open, because a bag
-- replacement such as Baganator keeps that frame reparented to a hidden parent for the whole session.
harness.env.BankFrame = nil
harness.env.Enum = nil
harness.env.C_Container.GetContainerNumSlots = function(container)
	return container == -1 and 1 or 0
end
harness.env.C_Container.GetContainerItemInfo = function(container, slot)
	if container == -1 and slot == 1 then
		return { itemID = 56, stackCount = 2, hyperlink = "item:56" }
	end
end
local openBank = harness.ns.Snapshots.Scan(true)
assert(openBank.bank and openBank.bank[1] and openBank.bank[1].itemID == 56, "an open bank is read without BankFrame")
assert(harness.ns.Snapshots.Scan(false).bank == nil, "a closed bank is not read")
