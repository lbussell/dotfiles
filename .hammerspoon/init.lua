hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")

PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({

    -- Navigate --      { { "ctrl", "alt", "cmd", "shift" }, "*" },
	focus_left = 	    { {         "alt", "cmd"          }, "h" },
	focus_down = 	    { {         "alt", "cmd"          }, "j" },
	focus_up = 		    { {         "alt", "cmd"          }, "k" },
	focus_right = 	    { {         "alt", "cmd"          }, "l" },

    -- Arrange --       { { "ctrl", "alt", "cmd", "shift" }, "*" },
	swap_left = 	    { {         "alt", "cmd", "shift" }, "h" },
	swap_down = 	    { {         "alt", "cmd", "shift" }, "j" },
	swap_up =   	    { {         "alt", "cmd", "shift" }, "k" },
	swap_right = 	    { {         "alt", "cmd", "shift" }, "l" },

	center_window =     { {         "alt", "cmd"          }, "c" },

	slurp_in =          { {         "alt", "cmd"          }, "i" }, -- Pull left adjacent window into the bottom of current column
	barf_out =          { {         "alt", "cmd"          }, "o" }, -- Expel window from bottom of column to the left

	toggle_floating =   { { "ctrl", "alt", "cmd"          }, "escape" }, -- Attach/detach window to scratch/floating layer
	focus_floating =    { {         "alt", "cmd", "shift" }, "escape" }, -- Toggle scratch/floating layer

    -- Resize --        { { "ctrl", "alt", "cmd", "shift" }, "*" },
	increase_width =    { {         "alt", "cmd"          }, "=" },
	decrease_width =    { {         "alt", "cmd"          }, "-" },
	increase_height =   { {         "alt", "cmd", "shift" }, "=" },
	decrease_height =   { {         "alt", "cmd", "shift" }, "-" },
	full_width =        { {         "alt", "cmd"          }, "f" },
	cycle_width =       { {         "alt", "cmd"          }, "r" },
	cycle_height =      { {         "alt", "cmd", "shift" }, "r" },

    -- Desktops --      { { "ctrl", "alt", "cmd", "shift" }, "*" },
	switch_space_l =    { {         "alt", "cmd"          }, "pageup" },
	switch_space_r =    { {         "alt", "cmd"          }, "pagedown" },

    -- Misc --          { { "ctrl", "alt", "cmd", "shift" }, "*" },
	refresh_windows =   { { "ctrl", "alt", "cmd"          }, "p" },

    -- Stacking --      { { "ctrl", "alt", "cmd", "shift" }, "*" },
	stack =             { { "ctrl", "alt", "cmd"          }, "i" },
	unstack =           { { "ctrl", "alt", "cmd"          }, "o" },
	stack_next =        { {         "alt", "cmd"          }, "]" },
	stack_prev =        { {         "alt", "cmd"          }, "[" },

	------------
	-- Unused --
	------------
	-- reverse_cycle_width = {},
	-- reverse_cycle_height = {},

	-- Focus nth window in current space
	-- focus_window_1 = { { "cmd", "shift" }, "1" },
	-- focus_window_2 = { { "cmd", "shift" }, "2" },
	-- focus_window_3 = { { "cmd", "shift" }, "3" },
	-- focus_window_4 = { { "cmd", "shift" }, "4" },
	-- focus_window_5 = { { "cmd", "shift" }, "5" },
	-- focus_window_6 = { { "cmd", "shift" }, "6" },
	-- focus_window_7 = { { "cmd", "shift" }, "7" },
	-- focus_window_8 = { { "cmd", "shift" }, "8" },
	-- focus_window_9 = { { "cmd", "shift" }, "9" },

	-- Switch to space by number
	switch_space_1 = { { "alt", "cmd" }, "1" },
	switch_space_2 = { { "alt", "cmd" }, "2" },
	switch_space_3 = { { "alt", "cmd" }, "3" },
	switch_space_4 = { { "alt", "cmd" }, "4" },
	-- switch_space_5 = { { "alt", "cmd" }, "5" },
	-- switch_space_6 = { { "alt", "cmd" }, "6" },
	-- switch_space_7 = { { "alt", "cmd" }, "7" },
	-- switch_space_8 = { { "alt", "cmd" }, "8" },
	-- switch_space_9 = { { "alt", "cmd" }, "9" },

	-- Move focused window to space
	move_window_1 = { { "alt", "cmd", "shift" }, "1" },
	move_window_2 = { { "alt", "cmd", "shift" }, "2" },
	move_window_3 = { { "alt", "cmd", "shift" }, "3" },
	move_window_4 = { { "alt", "cmd", "shift" }, "4" },
	-- move_window_5 = { { "alt", "cmd", "shift" }, "5" },
	-- move_window_6 = { { "alt", "cmd", "shift" }, "6" },
	-- move_window_7 = { { "alt", "cmd", "shift" }, "7" },
	-- move_window_8 = { { "alt", "cmd", "shift" }, "8" },
	-- move_window_9 = { { "alt", "cmd", "shift" }, "9" },
})

-- Ghostty is weird since it uses native macOS tabs
PaperWM.window_filter:rejectApp("Ghostty")

-- Scrolling
PaperWM.scroll_window = { "alt", "cmd" }
PaperWM.scroll_gain = 15.0 -- scroll faster (default: 10.0)
-- Hold + drag window to move and retile it
PaperWM.lift_window = { "alt", "cmd", "shift" }
-- Hold + drag window to scroll all windows in the space
PaperWM.drag_window = { "alt", "cmd" }
PaperWM.window_gap = 0
PaperWM.window_peek = 64

PaperWM:start()

local paperWMRunning = true

local function updateMenubar(menubar)
	-- on or off
	if paperWMRunning then
		menubar:setTitle("📄◉")
	else
		menubar:setTitle("📄◎")
	end
end

local function togglePaperWM()
	if paperWMRunning then
		PaperWM:stop()
		hs.alert.show("PaperWM stopped")
	else
		PaperWM:start()
		hs.alert.show("PaperWM started")
	end
	paperWMRunning = not paperWMRunning
	updateMenubar(paperWMMenubar)
end

paperWMMenubar = hs.menubar.new()
updateMenubar(paperWMMenubar)
paperWMMenubar:setClickCallback(togglePaperWM)

hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "P", togglePaperWM)
hs.window.animationDuration = 0 -- seconds

-- Alignment toggle menu bar button
local function updateAlignmentMenubar(menubar)
	-- center or edge aligned
	menubar:setTitle(PaperWM.focus_mode == "center" and "📄⬇️" or "📄️↔️")
end

local function toggleAlignment()
	local next = PaperWM.focus_mode == "center" and "edge" or "center"
	PaperWM:setFocusMode(next)
	updateAlignmentMenubar(alignmentMenubar)
end

alignmentMenubar = hs.menubar.new()
updateAlignmentMenubar(alignmentMenubar)
alignmentMenubar:setClickCallback(toggleAlignment)
