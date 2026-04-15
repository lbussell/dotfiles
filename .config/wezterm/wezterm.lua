local wezterm = require("wezterm")
local appearance = require("appearance")
local act = wezterm.action
local config = wezterm.config_builder()

config.use_fancy_tab_bar = true
config.tab_max_width = 32
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
config.window_decorations = "RESIZE"
config.window_frame = {
	font_size = 14.0,
}

local tab_bar_colors = {
	["Flexoki Light"] = {
		background = "#cecdc3",
		active_tab = { bg_color = "#fffcf0", fg_color = "#100f0f" },
		inactive_tab = { bg_color = "#cecdc3", fg_color = "#6f6e69" },
		inactive_tab_hover = { bg_color = "#b7b5ac", fg_color = "#100f0f" },
		new_tab = { bg_color = "#cecdc3", fg_color = "#6f6e69" },
		new_tab_hover = { bg_color = "#b7b5ac", fg_color = "#100f0f" },
	},
	["Penumbra Dark Contrast++"] = {
		background = "#0D0F13",
		active_tab = { bg_color = "#181B1F", fg_color = "#DEDEDE" },
		inactive_tab = { bg_color = "#0D0F13", fg_color = "#DEDEDE" },
		inactive_tab_hover = { bg_color = "#3E4044", fg_color = "#DEDEDE" },
		new_tab = { bg_color = "#0D0F13", fg_color = "#DEDEDE" },
		new_tab_hover = { bg_color = "#3E4044", fg_color = "#DEDEDE" },
	},
}

local function scheme_for_appearance(is_dark)
	if is_dark then
		return "Penumbra Dark Contrast++"
	else
		return "Flexoki Light"
	end
end

-- Set initial theme
local initial_scheme = scheme_for_appearance(appearance.is_dark())
config.color_scheme = initial_scheme
config.colors = { tab_bar = tab_bar_colors[initial_scheme] }

-- Dynamically switch color scheme + tab bar when system appearance changes
wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local scheme = scheme_for_appearance(window:get_appearance():find("Dark"))
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		overrides.colors = { tab_bar = tab_bar_colors[scheme] }
		window:set_config_overrides(overrides)
	end
end)

-- Ghostty-compatible keybindings for multiplexing/tiling (macOS defaults)
config.keys = {
	-- ── Splits ──────────────────────────────────────────────────────────
	-- Cmd+D          → new split right
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Cmd+Shift+D    → new split down
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- ── Focus split ─────────────────────────────────────────────────────
	-- Cmd+Option+Arrow → move focus between splits
	{ key = "LeftArrow", mods = "CMD|OPT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CMD|OPT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CMD|OPT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CMD|OPT", action = act.ActivatePaneDirection("Down") },

	-- Cmd+[ / Cmd+]  → focus previous / next split
	{ key = "[", mods = "CMD", action = act.ActivatePaneDirection("Prev") },
	{ key = "]", mods = "CMD", action = act.ActivatePaneDirection("Next") },

	-- ── Zoom ────────────────────────────────────────────────────────────
	-- Cmd+Shift+Enter → toggle split zoom
	{ key = "Enter", mods = "CMD|SHIFT", action = act.TogglePaneZoomState },

	-- ── Resize splits ───────────────────────────────────────────────────
	-- Cmd+Ctrl+Arrow  → resize focused split
	{ key = "LeftArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "RightArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ key = "UpArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "DownArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },

	-- ── Close ───────────────────────────────────────────────────────────
	-- Cmd+W           → close current split (or tab if last split)
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	-- ── Tabs ────────────────────────────────────────────────────────────
	-- Cmd+T           → new tab
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	-- Cmd+Shift+[     → previous tab
	{ key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Cmd+Shift+]     → next tab
	{ key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
	-- Cmd+1-8         → go to tab N
	{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = act.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = act.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = act.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = act.ActivateTab(7) },
	-- Cmd+9           → go to last tab
	{ key = "9", mods = "CMD", action = act.ActivateTab(-1) },
	-- Cmd+Option+Shift+[ → move tab left
	{ key = "[", mods = "CMD|OPT|SHIFT", action = act.MoveTabRelative(-1) },
	-- Cmd+Option+Shift+] → move tab right
	{ key = "]", mods = "CMD|OPT|SHIFT", action = act.MoveTabRelative(1) },

	-- ── Command palette ─────────────────────────────────────────────────
	-- Cmd+Shift+P     → open command palette
	{ key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
}

return config
