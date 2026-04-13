--   ===============================================================================   --
--    _    _          __  __ __  __ ______ _____   _____ _____   ____   ____  _   _    --
--   | |  | |   /\   |  \/  |  \/  |  ____|  __ \ / ____|  __ \ / __ \ / __ \| \ | |   --
--   | |__| |  /  \  | \  / | \  / | |__  | |__) | (___ | |__) | |  | | |  | |  \| |   --
--   |  __  | / /\ \ | |\/| | |\/| |  __| |  _  / \___ \|  ___/| |  | | |  | | . ` |   --
--   | |  | |/ ____ \| |  | | |  | | |____| | \ \ ____) | |    | |__| | |__| | |\  |   --
--   |_|  |_/_/    \_\_|  |_|_|  |_|______|_|  \_\_____/|_|     \____/ \____/|_| \_|   --
--                                                                                     --
--   ===============================================================================   --

-- =====================================================================
-- INSTRUCTIONS
-- =====================================================================
-- cd ~/ ; ln -s ~/manual-sync-dotfiles/hammerspoon-init.lua ~/.hammerspoon/init.lua

-- =====================================================================
-- DEFINE HYPER : CTRL + OPT + CMD + SHIFT
-- =====================================================================
local hyper = {"ctrl", "alt", "cmd", "shift"}


--==============================================================================--
--  _   _      _                   _____                 _   _                  --
-- | | | | ___| |_ __   ___ _ __  |  ___|   _ _ __   ___| |_(_) ___  _ __  ___  --
-- | |_| |/ _ \ | '_ \ / _ \ '__| | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __| --
-- |  _  |  __/ | |_) |  __/ |    |  _|| |_| | | | | (__| |_| | (_) | | | \__ \ --
-- |_| |_|\___|_| .__/ \___|_|    |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ --
--              |_|                                                             --
--==============================================================================--

-- =====================================================================
-- PER-SCREEN SPACE SWITCHING (WITH WRAP-AROUND)
-- =====================================================================

local function switchSpace(direction)
    local focusedScreen = hs.screen.mainScreen()
    local allScreens = hs.screen.allScreens()
    local currentScreenSpaces = hs.spaces.spacesForScreen(focusedScreen)
    local activeSpace = hs.spaces.activeSpaceOnScreen(focusedScreen)

    -- 1. Create a global list of all spaces to find the "Shortcut Number"
    -- This ensures we hit the right Ctrl + N combination
    local globalSpaces = {}
    for _, screen in ipairs(allScreens) do
        local screenSpaces = hs.spaces.spacesForScreen(screen)
        for _, spaceID in ipairs(screenSpaces) do
            table.insert(globalSpaces, spaceID)
        end
    end

    -- 2. Find the current space's index in the LOCAL screen list
    local localIndex = nil
    for i, spaceID in ipairs(currentScreenSpaces) do
        if spaceID == activeSpace then
            localIndex = i
            break
        end
    end

    if not localIndex then return end

    -- 3. Calculate target LOCAL index with WRAP-AROUND logic
    local targetLocalIndex
    if direction == "next" then
        targetLocalIndex = localIndex + 1
        if targetLocalIndex > #currentScreenSpaces then
            targetLocalIndex = 1 -- Wrap to first desktop
        end
    else
        targetLocalIndex = localIndex - 1
        if targetLocalIndex < 1 then
            targetLocalIndex = #currentScreenSpaces -- Wrap to last desktop
        end
    end

    -- 4. Map the target Space ID back to the GLOBAL index for the keystroke
    local targetSpaceID = currentScreenSpaces[targetLocalIndex]
    local globalIndex = nil
    for i, spaceID in ipairs(globalSpaces) do
        if spaceID == targetSpaceID then
            globalIndex = i
            break
        end
    end

    -- 5. Trigger the jump
    if globalIndex and globalIndex <= 9 then
        hs.eventtap.keyStroke({"ctrl"}, tostring(globalIndex))
    else
        -- Fallback: If you have > 9 spaces, the Ctrl+N shortcuts don't exist
        hs.alert.show("Space index out of shortcut range (1-9)")
    end
end

-- =====================================================================
-- DIRECTIONAL FOCUS
-- =====================================================================
local function moveMouseToWindow(win)
    if win then
        local frame = win:frame()
        local centerPoint = {
            x = frame.x + (frame.w / 2),
            y = frame.y + (frame.h / 2)
        }
        hs.mouse.absolutePosition(centerPoint)
    end
end

local function smartFocus(direction)
    local win = hs.window.focusedWindow()
    -- Safety check: If a tab closed and focus is "lost" to the OS, try to grab the frontmost app's window
    if not win then win = hs.window.frontmostWindow() end
    if not win then return end

    local winFrame = win:frame()
    local winCenter = {x = winFrame.x + winFrame.w/2, y = winFrame.y + winFrame.h/2}

    -- FIX: Use visibleWindows() instead of filters. 
    -- Filters cache state and can "lose" Ghostty after a tab close.
    -- This queries the OS directly for the current truth.
    local allWindows = hs.window.visibleWindows()
    local candidates = {}

    for _, w in ipairs(allWindows) do
        -- Check: Not current window + Visible + Standard (avoids tooltips/popups)
        if w:id() ~= win:id() and w:isVisible() and w:isStandard() then
            local f = w:frame()
            local c = {x = f.x + f.w/2, y = f.y + f.h/2}
            
            -- Calculate deltas
            local deltaX = c.x - winCenter.x
            local deltaY = c.y - winCenter.y
            
            local isCandidate = false
            
            -- Geometric "Cone" Check
            -- We ensure the window is mostly in the target direction (avoids diagonals)
            if direction == "West" then
                if deltaX < 0 and math.abs(deltaX) > math.abs(deltaY) then isCandidate = true end
            elseif direction == "East" then
                if deltaX > 0 and math.abs(deltaX) > math.abs(deltaY) then isCandidate = true end
            elseif direction == "North" then
                if deltaY < 0 and math.abs(deltaY) > math.abs(deltaX) then isCandidate = true end
            elseif direction == "South" then
                if deltaY > 0 and math.abs(deltaY) > math.abs(deltaX) then isCandidate = true end
            end

            if isCandidate then
                local distance = deltaX^2 + deltaY^2
                table.insert(candidates, {window = w, dist = distance})
            end
        end
    end

    -- Sort by distance (closest first)
    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            return a.dist < b.dist
        end)
        
        candidates[1].window:focus()
        moveMouseToWindow(candidates[1].window)
    end
end

-- =====================================================================
-- WINDOW THROWING FUNCTIONS
-- =====================================================================

-- Configuration
local gap = 8
hs.window.animationDuration = 0.25

-- Helper Functions

local windowHistory = {}

-- Function to save window state before moving
local function snapshot(win)
    if not win then return end
    local id = win:id()
    if not windowHistory[id] then
        windowHistory[id] = win:frame()
    end
end

-- Core function to move windows with SMART GAPS (Inner gap is 1/2 size)
local function move(x, y, w, h)
    return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        
        snapshot(win)
        
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        -- Calculate base frame based on unit (0.0 - 1.0)
        f.x = max.x + (max.w * x)
        f.y = max.y + (max.h * y)
        f.w = max.w * w
        f.h = max.h * h

        -- GAP LOGIC ---------------------------------------------------
        -- Outer Gap = gap
        -- Inner Gap = gap / 2 (We subtract gap/2 from each window to achieve this)
        
        local outerGap = gap
        local innerWindowPadding = gap / 2 

        -- 1. Horizontal Gaps
        -- Left Edge
        if x == 0 then 
            f.x = f.x + outerGap
            f.w = f.w - outerGap
        else
            f.x = f.x + innerWindowPadding
            f.w = f.w - innerWindowPadding
        end

        -- Right Edge (check if x + w is approximately 1)
        if (x + w) >= 0.99 then 
            f.w = f.w - outerGap
        else 
            f.w = f.w - innerWindowPadding
        end

        -- 2. Vertical Gaps
        -- Top Edge (Preserving your "Flush Top" preference)
        if y == 0 then
            f.y = f.y + 2
            f.h = f.h - 2
            -- If touching top, no top gap (f.y unchanged)
            -- Only adjust height based on bottom condition
            if (y + h) >= 0.99 then
                f.h = f.h - outerGap -- Touching bottom
            else
                f.h = f.h - innerWindowPadding -- Touching another window below
            end
        else
            -- Not touching top (so it's below something)
            f.y = f.y + innerWindowPadding
            f.h = f.h - innerWindowPadding
            
            -- Bottom adjustment
            if (y + h) >= 0.99 then
                f.h = f.h - outerGap -- Touching bottom
            else
                f.h = f.h - innerWindowPadding -- Touching another window below
            end
        end
        -- -------------------------------------------------------------

        win:setFrame(f)
        moveMouseToWindow(win) -- UPDATE: Move mouse to center
    end
end

-- Function to handle Next/Prev Display
local function moveDisplay(direction)
    return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        snapshot(win)
        
        if direction == "next" then
            win:moveOneScreenEast()
        else
            win:moveOneScreenWest()
        end
        
        -- Optional: Center mouse after moving display as well
        hs.timer.doAfter(0.1, function() moveMouseToWindow(win) end)
    end
end

-- =====================================================================
-- WINDOW MOVEMENT
-- =====================================================================

-- Unminimize All Windows
local function unMinimizeAll()
    local windows = hs.window.allWindows()
    local count = 0
    
    for _, win in ipairs(windows) do
        if win:isMinimized() then
            win:unminimize()
            count = count + 1
        end
    end
    
    if count > 0 then
    else
        hs.alert.show("No minimized windows found")
    end
end

-- Minimize Focused Window
local function minimizeFocused()
    local win = hs.window.focusedWindow()
    if win then
        win:minimize()
    end
end

-- Maximize Focused Window
local function maximize()
    local win = hs.window.focusedWindow()
    if win then
        snapshot(win)
        move(0,0,1,1)() 
        -- Note: move() now handles the mouse centering
    end
end

-- Center Focused Window
local function center()
    local win = hs.window.focusedWindow()
    if win then 
        snapshot(win)
        win:centerOnScreen() 
        moveMouseToWindow(win) -- UPDATE: Move mouse to center
    end
end

-- Resize Focused Window (smaller/larger)
local function resize(action)
    return function()
        local win = hs.window.focusedWindow()
        if not win then return end
        snapshot(win)
        
        local f = win:frame()
        local step = 40 
        
        if action == "larger" then
            f.x = f.x - step / 2
            f.y = f.y - step / 2
            f.w = f.w + step
            f.h = f.h + step
        else
            f.x = f.x + step / 2
            f.y = f.y + step / 2
            f.w = f.w - step
            f.h = f.h - step
        end
        win:setFrame(f)
        moveMouseToWindow(win) -- UPDATE: Move mouse to center
    end
end

local function fullscreen()
    local win = hs.window.focusedWindow()
    if win then
        win:toggleFullScreen()
    end
end

-- Function to minimize all windows except the focused one
local function isolateActiveWindow()
    local activeWindow = hs.window.focusedWindow()
    if not activeWindow then return end
    
    -- Get all visible windows across all screens
    local allWindows = hs.window.visibleWindows()
    
    for _, win in ipairs(allWindows) do
        -- Check if the window is NOT the active one and is NOT already minimized
        if win:id() ~= activeWindow:id() then
            win:minimize()
        end
    end
end

-- =====================================================================
-- HELPER FUNCTION FOR GHOSTTY/CHROME LAUNCH FUNCTIONS
-- =====================================================================
local function moveSpecificWindow(win)
    if not win then
        hs.alert.show("Error: New Kitty window not found.")
        return
    end

    local mouseScreen = hs.mouse.getCurrentScreen()
    if mouseScreen then
        win:moveToScreen(mouseScreen)
        win:focus() -- Force focus on the current window/Space
    end
end


-- =====================================================================
-- LAUNCH GHOSTTY
-- =====================================================================

local function launchGhostty()
    local app = hs.application.get("Ghostty")
    
    if not app then
        -- If Ghostty isn't running at all, just launch it
        hs.application.launchOrFocus("Ghostty")
    else
        -- If it is running, focus it and trigger a new window keystroke
        app:activate()
        hs.eventtap.keyStroke({"cmd"}, "n")
    end

    -- Give the window a split second to exist, then move it to the mouse screen
    hs.timer.doAfter(0.15, function()
        local win = hs.window.focusedWindow()
        if win and win:application():title() == "Ghostty" then
            moveSpecificWindow(win)
        end
    end)
end


-- =====================================================================
-- LAUNCH CHROME
-- =====================================================================

local function launchChrome()
    local app = hs.application.get("Google Chrome")
    
    if not app then
        -- If Chrome isn't running, just launch it (it will open a window naturally)
        hs.application.launchOrFocus("Google Chrome")
    else
        -- If it is already running, tell it to make a new window
        local script = [[
            tell application "Google Chrome"
                make new window
                activate
            end tell
        ]]
        hs.osascript.applescript(script)
    end

    -- Use the timer to ensure the window is ready before moving it
    hs.timer.doAfter(0.2, function()
        local win = hs.window.focusedWindow()
        -- Ensure we are actually moving a Chrome window
        if win and win:application():title() == "Google Chrome" then
            moveSpecificWindow(win)
        end
    end)
end

--==========================================--
--  _  __          _     _           _      --
-- | |/ /___ _   _| |__ (_)_ __   __| |___  --
-- | ' // _ \ | | | '_ \| | '_ \ / _` / __| --
-- | . \  __/ |_| | |_) | | | | | (_| \__ \ --
-- |_|\_\___|\__, |_.__/|_|_| |_|\__,_|___/ --
--           |___/                          --
--==========================================--

-- Bind to Hyper + H (Left) and Hyper + L (Right)
hs.hotkey.bind(hyper, "H", function() switchSpace("prev") end)
hs.hotkey.bind(hyper, "L", function() switchSpace("next") end)

-- Halves
hs.hotkey.bind(hyper, "A", move(0, 0, 0.5, 1))      -- Left Half
hs.hotkey.bind(hyper, "D", move(0.5, 0, 0.5, 1))    -- Right Half
hs.hotkey.bind(hyper, "S", move(0.25, 0, 0.5, 1))   -- Center Half

hs.hotkey.bind(hyper, "G", move(0, 0, 1, 0.5))      -- Top Half
hs.hotkey.bind(hyper, "B", move(0, 0.5, 1, 0.5))    -- Bottom Half

-- Corners (Quarters)
hs.hotkey.bind(hyper, "U", move(0, 0, 0.5, 0.5))    -- Top Left
hs.hotkey.bind(hyper, "I", move(0.5, 0, 0.5, 0.5))  -- Top Right
hs.hotkey.bind(hyper, "J", move(0, 0.5, 0.5, 0.5))  -- Bottom Left
hs.hotkey.bind(hyper, "K", move(0.5, 0.5, 0.5, 0.5))-- Bottom Right

-- Thirds
hs.hotkey.bind(hyper, "1", move(0, 0, 1/3, 1))      -- First Third
hs.hotkey.bind(hyper, "2", move(1/3, 0, 1/3, 1))    -- Center Third
hs.hotkey.bind(hyper, "3", move(2/3, 0, 1/3, 1))    -- Last Third

-- Two Thirds
hs.hotkey.bind(hyper, "W", move(0, 0, 2/3, 1))      -- First Two Thirds
hs.hotkey.bind(hyper, "E", move(1/3, 0, 2/3, 1))    -- Last Two Thirds

-- Sizing & Restoration
hs.hotkey.bind(hyper, "F", maximize)                -- Maximize
hs.hotkey.bind(hyper, "C", center)                  -- Center
hs.hotkey.bind(hyper, "R", unMinimizeAll)           -- Unminimize All
hs.hotkey.bind(hyper, "M", isolateActiveWindow)     -- Minimize All Except Active
hs.hotkey.bind(hyper, "Q", minimizeFocused)         -- Minimize
hs.hotkey.bind(hyper, "return", fullscreen)         -- Fullscreen

hs.hotkey.bind(hyper, "-", resize("smaller"))       -- Make Smaller
hs.hotkey.bind(hyper, "=", resize("larger"))        -- Make Larger

-- Displays
hs.hotkey.bind(hyper, "O", moveDisplay("next")) -- Next Display
hs.hotkey.bind(hyper, "Y", moveDisplay("prev"))  -- Previous Display

-- Keybinds for Focus Shifting
hs.hotkey.bind({"cmd", "alt"}, "H", function() smartFocus("West") end)
hs.hotkey.bind({"cmd", "alt"}, "L", function() smartFocus("East") end)
hs.hotkey.bind({"cmd", "alt"}, "K", function() smartFocus("North") end)
hs.hotkey.bind({"cmd", "alt"}, "J", function() smartFocus("South") end)

-- Ghostty and Chrome
hs.hotkey.bind(hyper, "T", launchGhostty)
hs.hotkey.bind(hyper, "N", launchChrome)

-- =====================================================================
-- CONFIG LOADED MESSAGE
-- =====================================================================
hs.hotkey.bind(hyper, "Z", function()               -- Reload Config
  hs.reload()
end)

hs.alert.show("Hammerspoon Config Loaded")
