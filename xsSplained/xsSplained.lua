-- xsSplained.lua
local mod = get_mod("xsSplained")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

local bg_x_pad = 50
local bg_y_pad = 10
local entry_size = { 750, 40 }
local vert_spacing = 20 + entry_size[2]
local missing_text = Localize("loc_popup_header_service_unavailable_error")

local text_style = table.clone(UIFontSettings.body_small)
text_style.font_size = 22
text_style.offset = {
    bg_x_pad,
    bg_y_pad * 0.75,
    10
}
text_style.size_addition = {
    -2 * bg_x_pad,
    -2 * bg_y_pad,
}

local mechanics_btn_widgets = {}
local mechanics_text_widget = nil
local mechanics_current_idx = -1

-- Handle accordion
local live_accordion_anim = nil

local show_mechanics_text_at_idx = function(idx)
    mechanics_current_idx = idx == mechanics_current_idx and -1 or idx

    local inv_view = Managers.ui:view_instance("inventory_view")
    if inv_view and live_accordion_anim then
        inv_view:_stop_animation(live_accordion_anim)
        live_accordion_anim = nil
    end

    local text_anim_data = mechanics_text_widget.accordion_anim_data
    text_anim_data.start_height = text_anim_data.end_height

    local text_height = 0
    if mechanics_current_idx < 0 then
        text_anim_data.end_height = 0
    else
        text_anim_data.start_y = mechanics_text_widget.offset[2]
        text_anim_data.end_y = vert_spacing * (idx + 1) - bg_y_pad - 10
        text_anim_data.text = mechanics_btn_widgets[idx].content.mechanics_txt or missing_text

        text_height = 3 * bg_y_pad +
            UIRenderer.text_height(Managers.ui:ui_constant_elements():ui_renderer(), text_anim_data.text,
                text_style.font_type, text_style.font_size, { entry_size[1] - 2 * bg_x_pad, 2000 },
                UIFonts.get_font_options_by_style(text_style))
        text_anim_data.end_height = text_height - bg_y_pad
    end

    for btn_idx = 1, #mechanics_btn_widgets do
        local widget = mechanics_btn_widgets[btn_idx]
        local anim_data = widget.accordion_anim_data
        anim_data.start_y = widget.offset[2]
        anim_data.end_y = vert_spacing * btn_idx + (btn_idx > idx and text_height or 0)
    end

    if inv_view then
        live_accordion_anim = inv_view:_start_animation(
            text_anim_data.start_height == 0 and "mechanics_accordion_open" or "mechanics_accordion", mechanics_btn_widgets,
            mechanics_text_widget)
    else
        for btn_idx = 1, #mechanics_btn_widgets do
            local widget = mechanics_btn_widgets[btn_idx]
            local anim_data = widget.accordion_anim_data
            widget.offset[2] = anim_data.end_y
        end

        local anim_data = mechanics_text_widget.accordion_anim_data
        mechanics_text_widget.offset[2] = anim_data.end_y
        local content = mechanics_text_widget.content
        content.text = anim_data.text
        content.size[2] = anim_data.end_height
        mechanics_text_widget.visible = anim_data.end_height > 0
    end
end

-- Add scenegraph definitions, blueprints
mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(view_defs)
    view_defs.scenegraph_definition.mechanics_entry = {
        parent = "canvas",
        horizontal_alignment = "left",
        vertical_alignment = "top",
        size = entry_size,
        position = {
            250,
            180,
            1
        }
    }
end)

mod:hook_require("scripts/ui/views/inventory_view/inventory_view_content_blueprints", function(blueprints)
    blueprints.mechanics_button = {
        size = entry_size,
        pass_template = ButtonPassTemplates.terminal_button_small,
        init = function(parent, widget, element, callback_name)
            local content = widget.content
            content.text = element.mechanics_title
            content.mechanics_idx = element.mechanics_idx
            content.mechanics_txt = element.mechanics_txt or missing_text

            local start_y = vert_spacing * element.mechanics_idx
            widget.accordion_anim_data = {
                start_y = start_y,
                end_y = start_y,
            }
            widget.offset[2] = start_y

            mechanics_btn_widgets[element.mechanics_idx] = widget
            content.hotspot.pressed_callback = function()
                show_mechanics_text_at_idx(element.mechanics_idx)
            end
        end,
        destroy = function(parent, widget, element, ui_renderer)
            mechanics_btn_widgets[widget.content.mechanics_idx] = nil
        end,
    }

    blueprints.mechanics_text = {
        size = entry_size,
        pass_template = {
            {
                pass_type = "texture",
                style_id = "background",
                value = "content/ui/materials/backgrounds/terminal_basic",
                style = {
                    scale_to_material = true,
                    offset = {
                        -9,
                        -13,
                        -2
                    },
                    color = Color.terminal_grid_background(255, true),
                    size_addition = {
                        18,
                        26,
                    }
                },
            },
            {
                pass_type = "text",
                value = missing_text,
                value_id = "text",
                style = text_style,
                style_id = "text",
            },
            {
                pass_type = "texture",
                style_id = "frame_bottom",
                value = "content/ui/materials/dividers/horizontal_frame_big_lower",
                style = {
                    vertical_alignment = "bottom",
                    size = {
                        nil,
                        36
                    },
                    offset = {
                        0,
                        15,
                        2
                    },
                },
            },
        },
        init = function(parent, widget, element, callback_name)
            widget.visible = false
            widget.accordion_anim_data = {
                start_y = 0,
                end_y = 0,
                text = "",
                start_height = 0,
                end_height = 0,
            }
            mechanics_text_widget = widget
        end,
        destroy = function(parent, widget, element, ui_renderer)
            mechanics_text_widget = nil
            mechanics_current_idx = -1
        end,
    }
end)

-- Add Mechanics tab to inventory view
mod:hook_safe(CLASS.InventoryBackgroundView, "_setup_top_panel", function(self, ...)
    local mechanics_tuples = {
        {
            mechanics_key = "strength",
            mechanics_title = mod:localize("strength_title"),
            mechanics_txt = mod:localize("strength_description"),
        },
        {
            mechanics_key = "agility",
            mechanics_title = mod:localize("agility_title"),
            mechanics_txt = mod:localize("agility_description"),
        },
        {
            mechanics_key = "toughness",
            mechanics_title = mod:localize("toughness_title"),
            mechanics_txt = mod:localize("toughness_description"),
        },
        {
            mechanics_key = "armor_penetration",
            mechanics_title = mod:localize("armor_penetration_title"),
            mechanics_txt = mod:localize("armor_penetration_description"),
        },
    }

    local num_layouts = 1
    local layout_data = {}
    for i = 1, #mechanics_tuples do
        local tuple = mechanics_tuples[i]
        if mod:get(tuple.mechanics_key) then
            local mechanics_entry = {
                scenegraph_id = "mechanics_entry",
                widget_type = "mechanics_button",
                mechanics_idx = num_layouts,
                mechanics_title = tuple.mechanics_title,
                mechanics_txt = tuple.mechanics_txt,
            }
            layout_data[num_layouts] = mechanics_entry
            num_layouts = num_layouts + 1
        end
    end
    layout_data[num_layouts] = {
        scenegraph_id = "mechanics_entry",
        widget_type = "mechanics_text",
    }

    local mechanics_tab = {
        display_name = mod:localize("mechanics_tab_name"),
        view_name = "inventory_view",
        update = function(content, style, dt)
            content.hotspot.disabled = not self:is_inventory_synced()
        end,
        view_context = {
            tabs = {
                {
                    allow_item_hover_information = true,
                    draw_wallet = false,
                    is_grid_layout = false,
                    ui_animation = "mechanics_on_enter",
                    camera_settings = {
                        {
                            "event_inventory_set_target_camera_offset",
                            0.4,
                            1.5,
                            0.3,
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

    local function entry_callback_function()
        self:_on_panel_option_pressed(mechanics_tab_idx)
    end
    local optional_update_function = mechanics_tab.update
    local cb = callback(entry_callback_function)

    self._top_panel:add_entry(mechanics_tab.display_name, cb, optional_update_function)
end)

-- Animations
local accordion_open_init = function(parent, ui_scenegraph, _scenegraph_definition, widget, textbox)
    local anim_data = textbox.accordion_anim_data
    textbox.offset[2] = anim_data.end_y
    textbox.content.text = anim_data.text
    textbox.style.text.text_color[1] = 0
    textbox.visible = anim_data.end_height > 0
end

local accordion_open_update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, textbox)
    local anim_progress = math.easeOutCubic(progress)
    textbox.alpha_multiplier = textbox.visible and anim_progress or 0
    textbox.content.size[2] = textbox.accordion_anim_data.end_height * anim_progress
end

local accordion_text_appear_update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, textbox)
    textbox.style.text.text_color[1] = 255 * progress
end

local accordion_move_update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, textbox)
    local anim_progress = math.easeOutCubic(progress)

    for i = 1, #widgets do
        local widget = widgets[i]
        local anim_data = widget.accordion_anim_data
        widget.offset[2] = anim_data.start_y + anim_progress * (anim_data.end_y - anim_data.start_y)
    end
end

mod:hook(CLASS.InventoryView, "_create_sequence_animator", function(func, self, definitions)
    definitions.animations = definitions.animations or {}
    definitions.animations.mechanics_on_enter = {
        {
            name = "fade_in",
            start_time = 0.0,
            end_time = 0.6,
            init = function(...)
                for i = 1, #mechanics_btn_widgets do
                    mechanics_btn_widgets[i].alpha_multiplier = 0
                end
            end,
        },
        {
            name = "move",
            start_time = 0.35,
            end_time = 0.8,
            update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
                local anim_progress = math.easeOutCubic(progress)

                local x_anim_distance_max = -50
                local x_anim_distance = x_anim_distance_max - x_anim_distance_max * anim_progress
                for i = 1, #mechanics_btn_widgets do
                    local widget = mechanics_btn_widgets[i]
                    widget.alpha_multiplier = anim_progress
                    widget.offset[1] = x_anim_distance * (1.0 + (i - 1) * 0.25)
                end
            end,
        },
    }
    definitions.animations.mechanics_accordion_open = {
        {
            name = "move",
            start_time = 0.0,
            end_time = 0.25,
            update = accordion_move_update,
        },
        {
            name = "open",
            start_time = 0.1,
            end_time = 0.25,
            init = accordion_open_init,
            update = accordion_open_update,
        },
        {
            name = "text_appear",
            start_time = 0.2,
            end_time = 0.4,
            update = accordion_text_appear_update,
        },
    }
    definitions.animations.mechanics_accordion = {
        {
            name = "text_vanish",
            start_time = 0.0,
            end_time = 0.15,
            update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, textbox)
                textbox.style.text.text_color[1] = 255 * (1.0 - math.easeOutCubic(progress))
            end,
        },
        {
            name = "close",
            start_time = 0.0,
            end_time = 0.3,
            update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, textbox)
                local anim_progress = 1.0 - math.easeOutCubic(progress)
                textbox.alpha_multiplier = textbox.visible and anim_progress or 0
                textbox.content.size[2] = textbox.accordion_anim_data.start_height * anim_progress
            end,
        },
        {
            name = "move",
            start_time = 0.2,
            end_time = 0.5,
            update = accordion_move_update,
        },
        {
            name = "open",
            start_time = 0.3,
            end_time = 0.45,
            init = accordion_open_init,
            update = accordion_open_update,
        },
        {
            name = "text_appear",
            start_time = 0.4,
            end_time = 0.6,
            update = accordion_text_appear_update,
        },
    }
    return func(self, definitions)
end)