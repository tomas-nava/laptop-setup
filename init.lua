
--
-- HAMMERSPOON CONFIG MANAGEMENT
--

-- reload the config when this file changes
function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config reloaded")

--
-- WINDOW MANAGEMENT
--

-- focused window takes the full screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local screen_frame = focused_window:screen():frame()

    focused_window:setFrame(screen_frame)
end)

-- all the frontmost application's windows centered on whatever screen they're on
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function()
    hs.window.animationDuration = 0
    local app = hs.application.frontmostApplication()
    local app_windows = app:allWindows()

    local screen_frame, window_frame, wide, high

    for _, win in pairs(app_windows) do
        screen_frame = win:screen():frame()
        window_frame = win:frame()
        wide = window_frame.w
        high = window_frame.h
        window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (wide / 2))
        window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (high / 2))
        win:setFrame(window_frame)
    end
end)

-- focused window sized to set dimensions and centered
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()
    local wide = window_frame.w
    local high = window_frame.h

    -- first, try centering the widnow at its current size
    window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (wide / 2))
    window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (high / 2))

    -- some apps may not size to exactly wide x high, so check before and after
    local before_frame = focused_window:frame()
    focused_window:setFrame(window_frame)
    local after_frame = focused_window:frame()

    -- if the window was already centered, resize to set dimensions
    local resized_wide = 801
    local resized_high = 605
    if before_frame == after_frame and (wide ~= resized_wide or high ~= resized_high) then

        window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (resized_wide / 2))
        window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (resized_high / 2))
        window_frame.w = resized_wide
        window_frame.h = resized_high

        focused_window:setFrame(window_frame)

    elseif before_frame == after_frame and wide == resized_wide and high == resized_high then
        -- if the window was already sized and centered, grow it to full screen height
        window_frame.y = screen_frame.y
        window_frame.h = screen_frame.h

        focused_window:setFrame(window_frame)
    end
end)

-- move the passed window to the passed screen
function moveWindowToScreen(window, screen)
    -- shrink the window if it's bigger than the target screen
    local target_screen_frame = screen:frame()
    local window_frame = window:frame()
    local wide = window_frame.w
    local high = window_frame.h
    if wide > target_screen_frame.w then
        wide = target_screen_frame.w
    end
    if high > target_screen_frame.h then
        high = target_screen_frame.h
    end
    -- center the frame in the new screen
    window_frame.x = target_screen_frame.x + ((target_screen_frame.w / 2) - (wide / 2))
    window_frame.y = target_screen_frame.y + ((target_screen_frame.h / 2) - (high / 2))
    window_frame.w = wide
    window_frame.h = high

    window:setFrame(window_frame)
end

-- focused window moved to the next screen (if any) and centered
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "N", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local focused_screen = focused_window:screen()
    local all_screens = hs.screen.allScreens()
    local all_screens_count = #all_screens
    local window_screen_position = 1
    local target_screen_position = 1

    -- if there's more than one screen...
    if all_screens_count > 1 then
        -- find the screen the window's in
        for key, value in pairs(all_screens) do
            if value == focused_screen then
                window_screen_position = key
                break
            end
        end

        -- and pick the next screen in line
        if window_screen_position >= all_screens_count then
            target_screen_position = 1
        else
            target_screen_position = window_screen_position + 1
        end

        -- move the window to the next screen
        moveWindowToScreen(focused_window, all_screens[target_screen_position])
    end
end)

-- all the frontmost application's windows moved to the next screen (if any) and centered
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", function()
    hs.window.animationDuration = 0
    local all_screens = hs.screen.allScreens()
    local all_screens_count = #all_screens

    -- if there's more than one screen...
    if all_screens_count > 1 then
        local focused_window = hs.window.focusedWindow()
        local focused_screen = focused_window:screen()
        local window_screen_position = 1
        local target_screen_position = 1

        -- find the position of the screen the front-most window's in
        for key, value in pairs(all_screens) do
            if value == focused_screen then
                window_screen_position = key
                break
            end
        end

        -- and pick the next screen in line
        if window_screen_position >= all_screens_count then
            target_screen_position = 1
        else
            target_screen_position = window_screen_position + 1
        end

        -- step through the windows and move them to the next screen
        local app = hs.application.frontmostApplication()
        local app_windows = app:allWindows()

        for _, win in pairs(app_windows) do
            -- ignore minimized windows
            if win.isMinimized ~= true then
                -- move the window to the next screen
                moveWindowToScreen(win, all_screens[target_screen_position])
            end
        end
    end
end)

-- focused window moves to left edge of screen, then fills the left half of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    if window_frame.x == screen_frame.x then
        -- fill the left half of the screen
        window_frame.y = screen_frame.y
        window_frame.w = screen_frame.w / 2
        window_frame.h = screen_frame.h
    else
        -- just move to the left edge of the screen
        window_frame.x = screen_frame.x
    end

    focused_window:setFrame(window_frame)
end)

-- focused window moves to right edge of screen, then fills the right half of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    if window_frame.x == screen_frame.x + screen_frame.w - window_frame.w then
        -- fill the right half of the screen
        local half_width = math.floor(screen_frame.w / 2)
        window_frame.x = screen_frame.x + screen_frame.w - half_width
        window_frame.y = screen_frame.y
        window_frame.w = half_width
        window_frame.h = screen_frame.h
    else
        -- just move to the right edge of the screen
        window_frame.x = screen_frame.x + screen_frame.w - window_frame.w
    end

    focused_window:setFrame(window_frame)
end)

-- focused window moves to top edge of screen, then fills the top half of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    if window_frame.y == screen_frame.y then
        -- fill the top half of the screen
        window_frame.x = screen_frame.x
        window_frame.w = screen_frame.w
        window_frame.h = math.floor(screen_frame.h / 2)
    else
        -- just move to the top edge of the screen
        window_frame.y = screen_frame.y
    end

    focused_window:setFrame(window_frame)
end)

-- focused window moves to bottom edge of screen, then fills the bottom half of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "J", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    if window_frame.y == screen_frame.y + screen_frame.h - window_frame.h then
        -- fill the bottom half of the screen
        local half_height = math.floor(screen_frame.h / 2)
        window_frame.y = screen_frame.y + screen_frame.h - half_height
        window_frame.x = screen_frame.x
        window_frame.w = screen_frame.w
        window_frame.h = half_height
    else
        -- just move to the bottom edge of the screen
        window_frame.y = screen_frame.y + screen_frame.h - window_frame.h
    end

    focused_window:setFrame(window_frame)
end)

-- focused window's width increased by set amount
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    local grow_width = 60

    window_frame.x = math.max(window_frame.x - (grow_width / 2), screen_frame.x)
    window_frame.w = math.min(window_frame.w + grow_width, screen_frame.w)

    focused_window:setFrame(window_frame)
end)

-- focused window's width decreased by set amount
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    local shrink_width = 60
    local min_width = 570

    local new_width = math.max(window_frame.w - shrink_width, min_width)

    -- stick to the edges of the screen
    local window_not_on_left_edge = window_frame.x ~= screen_frame.x
    local window_on_right_edge = window_frame.x + window_frame.w == screen_frame.x + screen_frame.w
    local window_center = window_frame.x + (window_frame.w / 2)

    if window_not_on_left_edge and window_on_right_edge then
        window_frame.x = screen_frame.x + screen_frame.w - new_width
    elseif window_not_on_left_edge then
        window_frame.x = window_center - (new_width / 2)
    end

    window_frame.w = new_width

    focused_window:setFrame(window_frame)
end)

-- focused window's height increased by set amount
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    local grow_height = 60

    window_frame.y = math.max(window_frame.y - (grow_height / 2), screen_frame.y)
    window_frame.h = math.min(window_frame.h + grow_height, screen_frame.h)

    focused_window:setFrame(window_frame)
end)

-- focused window's height decreased by set amount
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function()
    hs.window.animationDuration = 0
    local focused_window = hs.window.focusedWindow()
    local window_frame = focused_window:frame()
    local screen_frame = focused_window:screen():frame()

    local shrink_height = 60
    local min_height = 570

    local new_height = math.max(window_frame.h - shrink_height, min_height)

    -- stick to the edges of the screen
    local window_not_on_top_edge = window_frame.y ~= screen_frame.y
    local window_on_bottom_edge = window_frame.y + window_frame.h == screen_frame.y + screen_frame.h
    local window_center = window_frame.y + (window_frame.h / 2)

    if window_on_bottom_edge then
        window_frame.y = screen_frame.y + screen_frame.h - new_height
    elseif window_not_on_top_edge then
        window_frame.y = window_center - (new_height / 2)
    end

    window_frame.h = new_height

    focused_window:setFrame(window_frame)
end)
