-- The only required line is this one.
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
-- Some empty tables for later use
local config = {}
local keys = {}

local key_tables = {}
local copy_mode_keys = wezterm.gui.default_key_tables().copy_mode
key_tables.copy_mode = copy_mode_keys

local mouse_bindings = {}
local launch_menu = {}

local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

--- Key bindings
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

table.insert(keys, {
	key = "c",
	mods = "LEADER|CTRL",
	action = act.SpawnTab("CurrentPaneDomain"),
})

table.insert(keys, {
	key = "c",
	mods = "LEADER",
	action = wezterm.action.CloseCurrentPane({ confirm = false }),
})

table.insert(keys, {
	key = "v",
	mods = "LEADER",
	action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
})

table.insert(keys, {
	key = "s",
	mods = "LEADER",
	action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
})

table.insert(keys, {
	key = "j",
	mods = "LEADER",
	action = act.ActivatePaneDirection("Down"),
})

table.insert(keys, {
	key = "k",
	mods = "LEADER",
	action = act.ActivatePaneDirection("Up"),
})

table.insert(keys, {
	key = "h",
	mods = "LEADER",
	action = act.ActivatePaneDirection("Left"),
})

table.insert(keys, {
	key = "l",
	mods = "LEADER",
	action = act.ActivatePaneDirection("Right"),
})

table.insert(keys, {
	key = "J",
	mods = "LEADER",
	action = act.AdjustPaneSize({ "Down", 5 }),
})

table.insert(keys, {
	key = "K",
	mods = "LEADER",
	action = act.AdjustPaneSize({ "Up", 5 }),
})

table.insert(keys, {
	key = "H",
	mods = "LEADER",
	action = act.AdjustPaneSize({ "Left", 5 }),
})

table.insert(keys, {
	key = "L",
	mods = "LEADER",
	action = act.AdjustPaneSize({ "Right", 5 }),
})

table.insert(keys, {
	key = ";",
	mods = "LEADER",
	action = wezterm.action.ActivateCommandPalette,
})

table.insert(keys, {
	key = "z",
	mods = "LEADER",
	action = wezterm.action.TogglePaneZoomState,
})

table.insert(keys, {
	key = "p",
	mods = "LEADER",
	action = act.PaneSelect({
		alphabet = "1234567890",
	}),
})

for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

table.insert(keys, {
	key = "a",
	mods = "LEADER|CTRL",
	action = wezterm.action.ActivateLastTab,
})

table.insert(keys, {
	key = "c",
	mods = "SHIFT|CTRL",
	action = wezterm.action.CopyTo("ClipboardAndPrimarySelection"),
})

table.insert(keys, {
	key = "v",
	mods = "SHIFT|CTRL",
	action = act.PasteFrom("Clipboard"),
})

table.insert(keys, {
	key = "[",
	mods = "LEADER|CTRL",
	action = wezterm.action.ActivateCopyMode,
})

--- COPY MODE

table.insert(copy_mode_keys, { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") })
table.insert(copy_mode_keys, { key = "d", mods = "CTRL", action = act.CopyMode("PageDown") })

table.insert(copy_mode_keys, { key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") })
table.insert(copy_mode_keys, { key = "u", mods = "CTRL", action = act.CopyMode("PageUp") })

---

if is_windows then
	config.default_prog = { "C:/Program Files/Git/bin/bash.exe" }
end

-- Plugins
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
table.insert(keys, {
	key = "o",
	mods = "LEADER",
	action = workspace_switcher.switch_workspace(),
})

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
table.insert(keys, {
	key = "s",
	mods = "LEADER|CTRL",
	action = wezterm.action_callback(function(win, pane)
		resurrect.save_state(resurrect.workspace_state.get_workspace_state())
	end),
})
table.insert(keys, {
	key = "r",
	mods = "LEADER|CTRL",
	action = wezterm.action_callback(function(win, pane)
		resurrect.fuzzy_load(win, pane, function(id, label)
			local type = string.match(id, "^([^/]+)") -- match before '/'
			id = string.match(id, "([^/]+)$") -- match after '/'
			id = string.match(id, "(.+)%..+$") -- remove file extention
			local opts = {
				relative = true,
				restore_text = true,
				on_pane_restore = resurrect.tab_state.default_on_pane_restore,
			}
			if type == "workspace" then
				local state = resurrect.load_state(id, "workspace")
				resurrect.workspace_state.restore_workspace(state, opts)
			elseif type == "window" then
				local state = resurrect.load_state(id, "window")
				resurrect.window_state.restore_window(pane:window(), state, opts)
			elseif type == "tab" then
				local state = resurrect.load_state(id, "tab")
				resurrect.tab_state.restore_tab(pane:tab(), state, opts)
			end
		end)
	end),
})

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	extensions = { "smart_workspace_switcher", "resurrect" },
})
tabline.apply_to_config(config)

---

--- Default config settings
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12
config.launch_menu = launch_menu
config.default_cursor_style = "BlinkingBar"
config.disable_default_key_bindings = true
config.keys = keys
config.key_tables = key_tables
config.mouse_bindings = mouse_bindings

config.window_background_opacity = 0.9
config.window_decorations = "NONE"

if is_windows then
	wezterm.on("gui-startup", function(cmd)
		local tab, pane, window = mux.spawn_window(cmd or {})
		window:gui_window():maximize()
	end)
end
---

return config
