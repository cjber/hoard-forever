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
}
