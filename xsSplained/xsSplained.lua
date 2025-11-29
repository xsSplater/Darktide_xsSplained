-- xsSplained.lua
local mod = get_mod("xsSplained")

local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")


--[+ ++ЗАГРУЗКА ОПИСАНИЙ МЕХАНИК++ +]--
local ingame_descriptions = {}

local function load_mechanics_descriptions()
	local success, result = pcall(function()
		return mod:io_dofile("xsSplained/xsSplained_mechanics_desc")
	end)
	
	if success and result then
		ingame_descriptions = result
		mod:info("Mechanics descriptions loaded successfully")
	else
		mod:error("Failed to load mechanics descriptions: " .. tostring(result))
		ingame_descriptions = {}
	end
end

--[+ ++КОНФИГУРАЦИЯ++ +]--
local CONFIG = {
	UI = {
		BUTTON = {
			SIZE = { 350, 40 },
			POSITION = { x = 70, y = 50 },
			SPACING = 10,
			TEXT_STYLE = {
				font_size = 25,
				font_type = "machine_medium",
				text_color = { 255, 255, 255, 255 },
				offset = { 0, 0, 3 },
				size_addition = { -20, 0 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				text_vertical_alignment = "center",
				text_horizontal_alignment = "center",
				drop_shadow = true,
			}
		},
		WINDOW = {
			SIZE = { 1300, 930 },
			POSITION = { x = 122, y = 22 },
			PADDING = { x = 30, y = 20 },
			TEXT_STYLE = {
				font_size = 24,
				font_type = "proxima_nova_bold",
				text_color = { 255, 255, 255, 255 },
				offset = { 30, 20, 1 },
				size_addition = { -60, -40 },
				text_vertical_alignment = "top",
				text_horizontal_alignment = "left",
				drop_shadow = true,
			},
			DIVIDER_OFFSET_Y = 45 -- Разделитель 2 полоски
		},
		CAMERA = {
			HORIZONTAL = 42.6,
			FORWARD = -0.9,
			VERTICAL = 0.5
		},
		COLORS = {
			terminal_text_header = { 255, 255, 255, 255 },
			terminal_text_body = { 220, 220, 220, 255 },
			terminal_grid_background = { 30, 30, 30, 200 },
			terminal_frame = { 100, 100, 100, 200 },
			active_highlight = { 80, 160, 255, 60 },
			hover_highlight = { 120, 120, 120, 80 }
		}
	},
	ANIMATION = {
		BUTTON_ENTRANCE_DELAY = 0.05,
		BUTTON_ENTRANCE_DURATION = 0.2,
		DESCRIPTION_FADE_DURATION = 0.15
	}
}

--[+ ++УТИЛИТЫ++ +]--
local safe_localize = function(key)
	local success, result = pcall(function() 
		return mod:localize(key) or "["..key.."]"
	end)
	return success and result or "["..key.."]"
end

local safe_table_clone = function(original)
	if not original or type(original) ~= "table" then
		return {}
	end
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

--[+ ++СОСТОЯНИЕ++ +]--
local UIState = {
	buttons = {},
	current_selected_idx = nil,
	description_widget = nil,
	is_initialized = false
}

local reset_ui_state = function()
	UIState.buttons = {}
	UIState.current_selected_idx = nil
	UIState.description_widget = nil
end

--[+ ++СПИСОК МЕХАНИК++ +]--
local mechanics_list = {
	{ mechanics_key = "strength",
		mechanics_title = safe_localize("strength"),
			mechanics_txt = "strength_ingame_description" },
	{ mechanics_key = "finesse",
		mechanics_title = safe_localize("finesse"),
			mechanics_txt = "finesse_ingame_description" },
	{ mechanics_key = "health",
		mechanics_title = safe_localize("health"),
			mechanics_txt = "health_ingame_description" },
	{ mechanics_key = "toughness",
		mechanics_title = safe_localize("toughness"),
			mechanics_txt = "toughness_ingame_description" },
	{ mechanics_key = "stamina",
		mechanics_title = safe_localize("stamina"),
			mechanics_txt = "stamina_ingame_description" },
	{ mechanics_key = "cleave",
		mechanics_title = safe_localize("cleave"),
			mechanics_txt = "cleave_ingame_description" },
	{ mechanics_key = "crit_chance",
		mechanics_title = safe_localize("crit_chance"),
			mechanics_txt = "crit_chance_ingame_description" },
	{ mechanics_key = "impact",
		mechanics_title = safe_localize("impact"),
			mechanics_txt = "impact_ingame_description" },
	{ mechanics_key = "hitmass",
		mechanics_title = safe_localize("hitmass"),
			mechanics_txt = "hitmass_ingame_description" },
	{ mechanics_key = "stagger",
		mechanics_title = safe_localize("stagger"),
			mechanics_txt = "stagger_ingame_description" },
	{ mechanics_key = "weakspot",
		mechanics_title = safe_localize("weakspot"),
			mechanics_txt = "weakspot_ingame_description" },
	{ mechanics_key = "rending",
		mechanics_title = safe_localize("rending"),
			mechanics_txt = "rending_ingame_description" },
	{ mechanics_key = "brittleness",
		mechanics_title = safe_localize("brittleness"),
			mechanics_txt = "brittleness_ingame_description" },
}

--[+ ++ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ ОПИСАНИЯ++ +]--
local function get_mechanics_description(description_key)
	if ingame_descriptions[description_key] then
		local current_language = Managers and Managers.localization and Managers.localization._language or "en"
		return ingame_descriptions[description_key][current_language] or ingame_descriptions[description_key]["en"] or "Description not found"
	end
	return "Description not found for: " .. description_key
end

--[+ ++ПЕРЕМЕННЫЕ ИЗ КОНФИГА++ +]--
local button_size = CONFIG.UI.BUTTON.SIZE
local button_position_x = CONFIG.UI.BUTTON.POSITION.x
local button_position_y = CONFIG.UI.BUTTON.POSITION.y
local button_spacing = CONFIG.UI.BUTTON.SPACING
local button_text_style = safe_table_clone(CONFIG.UI.BUTTON.TEXT_STYLE)

local text_window_size = CONFIG.UI.WINDOW.SIZE
local desc_window_pos_x = CONFIG.UI.WINDOW.POSITION.x
local desc_window_pos_y = CONFIG.UI.WINDOW.POSITION.y
local window_spacing = 10
local bg_padding_x = CONFIG.UI.WINDOW.PADDING.x
local bg_padding_y = CONFIG.UI.WINDOW.PADDING.y
local description_text_style = safe_table_clone(CONFIG.UI.WINDOW.TEXT_STYLE)
local divider_top_lines_offset_y = CONFIG.UI.WINDOW.DIVIDER_OFFSET_Y

local camera_pos_h = CONFIG.UI.CAMERA.HORIZONTAL
local camera_pos_lr = CONFIG.UI.CAMERA.FORWARD
local camera_pos_v = CONFIG.UI.CAMERA.VERTICAL

local missing_text = Localize("loc_popup_header_service_unavailable_error")

--[+ ++ПРОСТАЯ СИСТЕМА АНИМАЦИЙ++ +]--
local SimpleAnimations = {
	active_animations = {},
	animation_id_counter = 0
}

SimpleAnimations.start_animation = function(widget, target_alpha, duration, delay, on_complete)
	local animation_id = SimpleAnimations.animation_id_counter + 1
	SimpleAnimations.animation_id_counter = animation_id
	
	SimpleAnimations.active_animations[animation_id] = {
		widget = widget,
		start_alpha = widget.alpha or 0,
		target_alpha = target_alpha,
		duration = duration or 0.3,
		progress = 0,
		delay = delay or 0,
		start_time = Managers.time:time("main"),
		on_complete = on_complete
	}
	
	return animation_id
end

SimpleAnimations.update_animations = function(dt)
	local current_time = Managers.time:time("main")
	local to_remove = {}
	
	for id, animation in pairs(SimpleAnimations.active_animations) do
		local elapsed = current_time - animation.start_time
		
		-- Обработка задержки
		if elapsed < animation.delay then
			animation.progress = 0
		else
			local animation_elapsed = elapsed - animation.delay
			animation.progress = math.min(animation_elapsed / animation.duration, 1.0)
			
			if animation.progress >= 0 then
				animation.widget.alpha = math.lerp(animation.start_alpha, animation.target_alpha, animation.progress)
			end
		end
		
		if animation.progress >= 1.0 then
			if animation.on_complete then
				animation.on_complete()
			end
			table.insert(to_remove, id)
		end
	end
	
	for _, id in ipairs(to_remove) do
		SimpleAnimations.active_animations[id] = nil
	end
end

SimpleAnimations.stop_animation = function(animation_id)
	SimpleAnimations.active_animations[animation_id] = nil
end

SimpleAnimations.stop_all_animations = function()
	SimpleAnimations.active_animations = {}
end

--[+ ++ОСНОВНЫЕ ФУНКЦИИ++ +]--
local show_description = function(idx)
	if not idx or not UIState.buttons[idx] then 
		-- Скрытие описания
		if UIState.description_widget then
			SimpleAnimations.start_animation(
				UIState.description_widget, 
				0, 
				CONFIG.ANIMATION.DESCRIPTION_FADE_DURATION,
				0,
				function()
					if UIState.description_widget then
						UIState.description_widget.visible = false
					end
				end
			)
		end
		UIState.current_selected_idx = nil
		return 
	end

	-- Если нажимаем на уже выбранную кнопку - скрываем
	if UIState.current_selected_idx == idx then
		show_description(nil)
		return
	end

	-- Показ нового описания
	UIState.current_selected_idx = idx
	local content = UIState.buttons[idx].content
	
	if UIState.description_widget then
		local description_text = get_mechanics_description(content.mechanics_txt)
		UIState.description_widget.content.text = description_text or missing_text
		
		if not UIState.description_widget.visible then
			UIState.description_widget.visible = true
			UIState.description_widget.alpha = 0
			SimpleAnimations.start_animation(UIState.description_widget, 1, CONFIG.ANIMATION.DESCRIPTION_FADE_DURATION)
		else
			-- Если окно уже видимо, просто меняем текст без анимации
			UIState.description_widget.alpha = 1
		end
		
		-- Обновить состояние кнопок
		for i, button in pairs(UIState.buttons) do
			button.content.is_active = (i == idx)
		end
	end
end

--[+ ++SCENEGRAPH ОПРЕДЕЛЕНИЯ++ +]--
mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(view_defs)
	local screen_height = view_defs.scenegraph_definition.canvas.size[2]
	local total_buttons_height = (#mechanics_list * (button_size[2] + button_spacing)) - button_spacing
	local vertical_offset = (screen_height - total_buttons_height) / 2 + button_position_y

	view_defs.scenegraph_definition.mechanics_buttons = {
		parent = "canvas",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { button_size[1], total_buttons_height },
		position = { button_position_x, vertical_offset, 1 }
	}

	view_defs.scenegraph_definition.mechanics_description = {
		parent = "canvas",
		horizontal_alignment = "left",
		vertical_alignment = "center",
		size = text_window_size,
		position = { desc_window_pos_x + button_size[1] + window_spacing, desc_window_pos_y, 1 }
	}
end)

--[+ ++BLUEPRINTS++ +]--
mod:hook_require("scripts/ui/views/inventory_view/inventory_view_content_blueprints", function(blueprints)
-- BUTTONS
	blueprints.mechanics_button = {
		size = button_size,
		pass_template = {
			{
				pass_type = "hotspot",
				content_id = "hotspot",
				content = {
					on_hover_sound = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click,
					on_complete_sound = UISoundEvents.default_click
				}
			},
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/terminal_basic",
				style = {
					color = Color.terminal_grid_background(255, true),
					offset = { 0, 0, 0 }
				}
			},
			{
				pass_type = "slug_icon",
				value = "content/ui/vector_textures/symbols/cog_skull_01",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "center",
					size = { 35, 35 },
					offset = { 5, 0, 0 },
					color = { 30, 110, 250, 0 },
				},
			},
			{
				pass_type = "slug_icon",
				value = "content/ui/vector_textures/symbols/cog_skull_01",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					size = { 35, 35 },
					offset = { -5, 0, 0 },
					color = { 30, 110, 250, 0 },
				},
			},
			{
				pass_type = "texture",
				style_id = "frame",
				value = "content/ui/materials/frames/frame_tile_2px",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "center",
					color = Color.terminal_frame(nil, true),
					offset = { 0, 0, 3 },
				},
			},
			{
				pass_type = "texture",
				style_id = "corner",
				value = "content/ui/materials/frames/frame_corner_2px",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "center",
					default_color = Color.terminal_corner(nil, true),
					hover_color = Color.terminal_corner_selected(nil, true),
					offset = { 0, 0, 4 },
				},
				change_function = terminal_button_change_function,
				visibility_function = ButtonPassTemplates.list_button_focused_visibility_function,
			},
			{
				pass_type = "text",
				value_id = "text",
				style_id = "text",
				value = "",
				style = safe_table_clone(button_text_style)
			},
			{
				pass_type = "rect",
				style_id = "hover",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "left",
					color = CONFIG.UI.COLORS.hover_highlight,
					offset = { 0, 0, 1 },
					size_addition = { 0, 0 }
				},
				change_function = function (content, style)
					style.color[1] = content.hotspot.is_hover and 120 or 0
				end
			},
			{
				pass_type = "rect",
				style_id = "active_highlight",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					color = CONFIG.UI.COLORS.active_highlight,
					offset = { 0, 0, -1 },
					size_addition = { -4, -4 }
				},
				visibility_function = function(content, style)
					return content.is_active == true
				end
			},
		},
		init = function(parent, widget, element, callback_name)
			local content = widget.content
			content.text = element.mechanics_title
			content.mechanics_txt = element.mechanics_txt or "missing_description"
			content.is_active = false

			if not content.hotspot then
				content.hotspot = {
					on_hover_sound = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click,
					on_complete_sound = UISoundEvents.default_click
				}
			end
			
			widget.offset = { 0, (button_size[2] + button_spacing) * (element.mechanics_idx - 1), 0 }
			widget.mechanics_idx = element.mechanics_idx
			UIState.buttons[element.mechanics_idx] = widget
			
			-- Анимация входа
			widget.alpha = 0
			SimpleAnimations.start_animation(
				widget, 
				1, 
				CONFIG.ANIMATION.BUTTON_ENTRANCE_DURATION,
				(element.mechanics_idx - 1) * CONFIG.ANIMATION.BUTTON_ENTRANCE_DELAY
			)
			
			content.hotspot.pressed_callback = function()
				if UIState.current_selected_idx == element.mechanics_idx then
					show_description(nil)
				else
					show_description(element.mechanics_idx)
				end
			end
		end,
		destroy = function(parent, widget, element, ui_renderer)
			if widget.mechanics_idx then
				UIState.buttons[widget.mechanics_idx] = nil
			end
		end,
	}
-- WINDOW
	blueprints.mechanics_description = {
		size = text_window_size,
		pass_template = {
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/terminal_basic",
				style = {
					scale_to_material = true,
					offset = { -9, -13, -2 },
					color = Color.terminal_grid_background(255, true),
					size_addition = { 18, 26 }
				},
			},
			{
				pass_type = "texture",
				style_id = "frame_top",
				value = "content/ui/materials/dividers/horizontal_frame_big_upper",
				style = {
					vertical_alignment = "top",
					horizontal_alignment = "center",
					size = { nil, 36 },
					offset = { 0, -15, 2 },
					color = { 255, 255, 255, 255 },
				},
			},
			{
				pass_type = "text",
				value_id = "text",
				style_id = "text",
				value = "",
				style = safe_table_clone(description_text_style)
			},
			{
				pass_type = "texture",
				style_id = "frame_bottom",
				value = "content/ui/materials/dividers/horizontal_frame_big_lower",
				style = {
					vertical_alignment = "bottom",
					size = { nil, 36 },
					offset = { 0, 15, 2 },
				},
			},
			{
				pass_type = "texture",
				style_id = "divider_top_lines",
				value = "content/ui/materials/dividers/skull_center_03", -- Полоски сверху
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "top",
					size = { 700, 30 },
					offset = { 0, divider_top_lines_offset_y, 10 },
					color = Color.terminal_text_header(155, true),
				},
			},
			{
				pass_type = "texture",
				style_id = "divider_bottom_scull",
				value = "content/ui/materials/dividers/skull_center_02", -- Череп снизу
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "bottom",
					size = { 1100, 50 },
					offset = { 0, 5, 0 },
					color = Color.terminal_grid_background(155, true),
				},
			},
		},
		init = function(parent, widget, element, callback_name)
			widget.content.text = ""
			widget.visible = false
			widget.alpha = 0
			UIState.description_widget = widget
		end,
		destroy = function(parent, widget, element, ui_renderer)
			UIState.description_widget = nil
			UIState.current_selected_idx = nil
		end,
	}
end)

--[+ ++СИСТЕМА ВКЛАДКИ++ +]--
local safe_setup_tab = function(self, ...)
	local success, error_msg = pcall(function()
		local layout_data = {}
		local num_buttons = 0

		for i = 1, #mechanics_list do
			local tuple = mechanics_list[i]
			if tuple and tuple.mechanics_key and mod:get(tuple.mechanics_key) then
				num_buttons = num_buttons + 1
				layout_data[num_buttons] = {
					scenegraph_id = "mechanics_buttons",
					widget_type = "mechanics_button",
					mechanics_idx = num_buttons,
					mechanics_title = tuple.mechanics_title or "Missing Title",
					mechanics_txt = tuple.mechanics_txt or "missing_description",
				}
			end
		end

		if num_buttons == 0 then
			mod:warning("No mechanics enabled in xsSplained mod")
			return
		end

		layout_data[num_buttons + 1] = {
			scenegraph_id = "mechanics_description",
			widget_type = "mechanics_description",
		}

		local mechanics_tab = {
			display_name = safe_localize("mechanics_tab_name"),
			view_name = "inventory_view",
			update = function(content, style, dt)
				content.hotspot.disabled = not self:is_inventory_synced()
				
				-- Обновление анимаций
				SimpleAnimations.update_animations(dt)
			end,
			view_context = {
				tabs = {
					{
						allow_item_hover_information = true,
						draw_wallet = false,
						is_grid_layout = false,
						camera_settings = {
							{
								"event_inventory_set_target_camera_offset",
								camera_pos_h, camera_pos_lr, camera_pos_v
							},
							{
								"event_inventory_set_target_camera_rotation",
								false,
							},
							{
								"event_inventory_set_camera_default_focus",
							},
						},
						layout = layout_data,
					},
				},
			},
		}

		local mechanics_tab_idx = #self._views_settings + 1
		self._views_settings[mechanics_tab_idx] = mechanics_tab

		local cb = callback(function()
			self:_on_panel_option_pressed(mechanics_tab_idx)
		end)

		self._top_panel:add_entry(mechanics_tab.display_name, cb, mechanics_tab.update)
		
		UIState.is_initialized = true
		mod:info("xsSplained tab initialized successfully with " .. num_buttons .. " mechanics")
		
	end)
	
	if not success then
		mod:error("Failed to setup xsSplained tab: " .. tostring(error_msg))
	end
end

--[+ ++ОБРАБОТЧИКИ СОБЫТИЙ++ +]--
mod:hook_safe(CLASS.InventoryBackgroundView, "_setup_top_panel", safe_setup_tab)

mod.on_all_mods_loaded = function()
	load_mechanics_descriptions()
	mod:info("xsSplained initialization complete")
end

mod.on_enabled = function()
	load_mechanics_descriptions()
	mod:info("xsSplained initialization complete")
end

mod.on_unload = function()
	reset_ui_state()
	SimpleAnimations.stop_all_animations()
end

mod.on_game_state_changed = function(status, state)
	if state == "StateGameplay" then
		reset_ui_state()
		SimpleAnimations.stop_all_animations()
	end
end
