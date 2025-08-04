-- xsSplained_data.lua
local mod = get_mod("xsSplained")

local widgets = {}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}