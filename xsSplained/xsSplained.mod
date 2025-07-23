return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`xsSplained` encountered an error loading the Darktide Mod Framework.")

		new_mod("xsSplained", {
			mod_script       = "xsSplained/xsSplained",
			mod_data         = "xsSplained/xsSplained_data",
			mod_localization = "xsSplained/xsSplained_localization",
		})
	end,
	packages = {},
}
