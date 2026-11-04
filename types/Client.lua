---@meta

-- FrameXML surfaces absent from Ketho's pinned Core annotations. Signatures follow
-- Gethe/wow-ui-source forever (see tools/typecheck.sh for the pinned revision). These declarations never load in the
-- client.

---@type table<string, fun(msg: string)>
SlashCmdList = {}

-- Frames Escape closes, by name.
---@type string[]
UISpecialFrames = {}

-- The number of carried bag slots (the backpack is 0, the setup bags follow it) and of bank bags.
---@type integer
NUM_BAG_SLOTS = 4
---@type integer
NUM_BANKBAGSLOTS = 6

---@type table<number, {r: number, g: number, b: number}>
ITEM_QUALITY_COLORS = {}

ChatFrameUtil = {}
---@type fun(text: string?): boolean
function ChatFrameUtil.InsertLink(text) end

---@type fun(tab: Frame)
function PanelTemplates_SelectTab(tab) end
---@type fun(tab: Frame)
function PanelTemplates_DeselectTab(tab) end

-- The Forever client's container names, which Core/Snapshots.lua reads by name so a client without the enum keeps its
-- numeric fallbacks. Enum.BagIndex carries Keyring = -1, Characterbanktab = -2, ReagentBag = 5 and
-- CharacterBankTab_1..9 = 6..14, and no Reagentbank.
---@class ForeverBagIndex
---@field Keyring? integer
---@field Characterbanktab? integer
---@field ReagentBag? integer
---@field CharacterBankTab_1? integer
---@field CharacterBankTab_2? integer
---@field CharacterBankTab_3? integer
---@field CharacterBankTab_4? integer
---@field CharacterBankTab_5? integer
---@field CharacterBankTab_6? integer
---@field CharacterBankTab_7? integer
---@field CharacterBankTab_8? integer
---@field CharacterBankTab_9? integer

-- Settings: the canvas category UI/SettingsPage.lua registers the addon's page as. Both are dot calls on the table,
-- as the client's own Settings API is.
---@class ForeverSettings
---@field RegisterCanvasLayoutCategory fun(frame: Frame, name: string): table
---@field RegisterAddOnCategory fun(category: table)
---@type ForeverSettings
Settings = nil
