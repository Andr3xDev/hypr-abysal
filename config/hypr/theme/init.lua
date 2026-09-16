-- ---------------------------------------------------------------------------
-- Theme Selector
-- Resolves the active theme by reading the state file, falling back to default
-- ---------------------------------------------------------------------------

local HOME         = os.getenv("HOME")
local STATE_FILE   = HOME .. "/.config/hypr/theme/state.lua"
local DEFAULT      = "abysal-obsidian"

local theme_name = DEFAULT

-- Safely load the state file: it must return a string (the theme name)
local ok, loader = pcall(loadfile, STATE_FILE)
if ok and loader then
	local ok2, result = pcall(loader)
	if ok2 and type(result) == "string" then
		theme_name = result
	end
end

-- Load and return the selected theme module
return require("theme.themes." .. theme_name .. "." .. theme_name)
