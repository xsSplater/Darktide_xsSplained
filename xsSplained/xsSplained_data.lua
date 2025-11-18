-- xsSplained_data.lua
local mod = get_mod("xsSplained")

local widgets = {}

local choice_order = {
	"strength",
	"finesse", 
	"health",
	"toughness",
	"stamina",
	"cleave",
	"crit_chance", 
	"impact",
	"hitmass",
	"stagger",
	"weakspot",
	"rending",
	"brittleness",
}

-- Создаем группу для всех механик
local mechanics_widgets = {}
for i = 1, #choice_order do
	local k = choice_order[i]
	mechanics_widgets[#mechanics_widgets + 1] = {
		setting_id = k,
		type = "checkbox",
		default_value = true,
	}
end

widgets[#widgets + 1] = {
	setting_id = "mechanics_group",
	type = "group",
	sub_widgets = mechanics_widgets
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}