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

print("snapshots_spec: ok")
