-- xsSplained_color_utils.lua
local mod = get_mod("xsSplained")

local Utils = {}

-- Попытка загрузить цвета из Enhanced Descriptions (если он включён)
local function try_load_enhanced_descriptions_colors()
	local ed_mod = get_mod("Enhanced_descriptions")
	if not ed_mod or not ed_mod:is_enabled() then
		return nil
	end

	local success, ed_utils = pcall(function()
		return ed_mod.get_utils()
	end)

	if success and ed_utils then
		return {
			CKWord = ed_utils.CKWord,
			CNumb = ed_utils.CNumb,
			CPhrs = ed_utils.CPhrs,
			CNote = ed_utils.CNote,
			DOT_NC = ed_utils.DOT_NC,
			DOT_RED = ed_utils.DOT_RED,
			DOT_GREEN = ed_utils.DOT_GREEN,
			source = "Enhanced Descriptions"
		}
	end
	return nil
end

-- Fallback: загрузка из локальных файлов Colors_Keywords_Numbers/
local function load_fallback_colors()
	local current_lang = "en"
	if Managers and Managers.localization then
		current_lang = Managers.localization._language or "en"
	end

	-- Временная подмена get_mod, чтобы файлы цветов не падали
	local original_get_mod = rawget(_G, "get_mod")
	_G.get_mod = function(name)
		if name == "Enhanced_descriptions" then
			return {
				get = function() return nil end,
				io_dofile = function() error("not implemented") end,
			}
		end
		return nil
	end

	local function load_lang_file(base_name, lang)
		local file_name = base_name
		if lang ~= "en" then
			local suffix = lang:gsub("-", "_")
			file_name = base_name .. "_" .. suffix
		end
		local success, data = pcall(function()
			return mod:io_dofile("xsSplained/Colors_Keywords_Numbers/" .. file_name)
		end)
		if success and data then
			return data
		end
		if lang ~= "en" then
			return load_lang_file(base_name, "en")
		end
		return {}
	end

	local keywords_data = load_lang_file("COLORS_KWords", current_lang)
	local numbers_data = load_lang_file("COLORS_Numbers", "en")

	-- Восстанавливаем оригинальный get_mod
	if original_get_mod then
		_G.get_mod = original_get_mod
	else
		_G.get_mod = nil
	end

	if not keywords_data.keywords and not numbers_data then
		return {
			CKWord = function(fallback) return fallback end,
			CNumb = function(fallback) return fallback end,
			CPhrs = function() return "" end,
			CNote = function() return "" end,
			DOT_NC = "•",
			DOT_RED = "•",
			DOT_GREEN = "•",
			source = "fallback (no colors)"
		}
	end

	local colored_keywords = keywords_data.keywords or {}
	local colored_phrs = keywords_data.phrs or {}
	local colored_nts = keywords_data.nts or {}
	local colored_numbers = numbers_data or {}

	local function CKWord(fallback, key)
		return colored_keywords[key] or fallback
	end

	local function CNumb(fallback, key)
		return colored_numbers[key] or fallback
	end

	local function CPhrs(key)
		return colored_phrs[key] or ""
	end

	local function CNote(key)
		return colored_nts[key] or ""
	end

	return {
		CKWord = CKWord,
		CNumb = CNumb,
		CPhrs = CPhrs,
		CNote = CNote,
		DOT_NC = "•",
		DOT_RED = "•",
		DOT_GREEN = "•",
		source = "local fallback"
	}
end

-- Инициализация
local color_api = try_load_enhanced_descriptions_colors()
if not color_api then
	color_api = load_fallback_colors()
	mod:info("Using fallback color system: " .. color_api.source)
else
	mod:info("Using Enhanced Descriptions color system")
end

Utils.CKWord = color_api.CKWord
Utils.CNumb = color_api.CNumb
Utils.CPhrs = color_api.CPhrs
Utils.CNote = color_api.CNote
Utils.DOT_NC = color_api.DOT_NC or "•"
Utils.DOT_RED = color_api.DOT_RED or "•"
Utils.DOT_GREEN = color_api.DOT_GREEN or "•"

return Utils

