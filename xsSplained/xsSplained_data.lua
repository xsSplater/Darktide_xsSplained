-- xsSplained_data.lua
local mod = get_mod("xsSplained")

local widgets = {
    {
        setting_id = "strength",
        type = "checkbox",
        default_value = true,
    },
    {
        setting_id = "agility",
        type = "checkbox",
        default_value = true,
    },
    {
        setting_id = "toughness",
        type = "checkbox",
        default_value = true,
    },
    {
        setting_id = "armor_penetration",
        type = "checkbox",
        default_value = true,
    },
}

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = widgets
    }
}