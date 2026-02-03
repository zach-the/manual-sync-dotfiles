-- Define Hyper: Control + Alt + Command + Shift
local hyper = {"ctrl", "alt", "cmd", "shift"}

-- Helper function to focus and move a specific window
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


-- ===================================
-- Ghostty: Hyper + T (New Terminal Window)
-- ===================================

hs.hotkey.bind(hyper, "T", function()
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
end)


-- ===================================
-- Chrome: Hyper + N (New Browser Window)
-- ===================================

hs.hotkey.bind(hyper, "N", function()
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
end)

-- ===================================
-- ADDING KEYBINDS FOR WINDOW THROWING
-- ===================================
-- =====================================================================
-- CONFIGURATION
-- =====================================================================

-- 1. Define Hyper: Control + Alt + Command + Shift
local hyper = {"ctrl", "alt", "cmd", "shift"}

-- 2. Define Gap (in pixels)
local gap = 10 

-- 3. Animation Duration (in seconds)
-- Set to 0 for instant snapping, or 0.3 for smooth animation
hs.window.animationDuration = 0.25

-- =====================================================================
-- HELPER FUNCTIONS
-- =====================================================================

local windowHistory = {}

-- Function to save window state before moving
local function snapshot(win)
    if not win then return end
    local id = win:id()
    if not windowHistory[id] then
        windowHistory[id] = win:frame()
    end
end

-- Core function to move windows with SMART TOP GAPS
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

        -- APPLY GAPS
        
        -- 1. Horizontal Gaps (Left/Right) - Always apply standard gap
        f.x = f.x + gap
        f.w = f.w - (gap * 2)

        -- 2. Vertical Gaps (Top/Bottom) - Smart Top Gap Check
        if y == 0 then
            -- If touching top: No top gap, only subtract bottom gap
            f.h = f.h - gap 
        else
            -- If not touching top: Add top gap, subtract top & bottom gaps
            f.y = f.y + gap
            f.h = f.h - (gap * 2)
        end

        win:setFrame(f)
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
    end
end

-- Function to resize (Make Larger/Smaller)
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
    end
end

-- =====================================================================
-- KEY BINDINGS
-- =====================================================================

-- Halves
hs.hotkey.bind(hyper, "A", move(0, 0, 0.5, 1))      -- Left Half
hs.hotkey.bind(hyper, "D", move(0.5, 0, 0.5, 1))    -- Right Half
hs.hotkey.bind(hyper, "S", move(0.25, 0, 0.5, 1))   -- Center Half
hs.hotkey.bind(hyper, "T", move(0, 0, 1, 0.5))      -- Top Half
hs.hotkey.bind(hyper, "G", move(0, 0.5, 1, 0.5))    -- Bottom Half

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
hs.hotkey.bind(hyper, "F", function()               -- Maximize (respects gaps)
    local win = hs.window.focusedWindow()
    if win then
        snapshot(win)
        move(0,0,1,1)() 
    end
end)

hs.hotkey.bind(hyper, "C", function()               -- Center
    local win = hs.window.focusedWindow()
    if win then 
        snapshot(win)
        win:centerOnScreen() 
    end
end)

hs.hotkey.bind(hyper, "R", function()               -- Restore
    local win = hs.window.focusedWindow()
    if win and windowHistory[win:id()] then
        win:setFrame(windowHistory[win:id()])
        windowHistory[win:id()] = nil 
    end
end)

hs.hotkey.bind(hyper, "-", resize("smaller"))       -- Make Smaller
hs.hotkey.bind(hyper, "=", resize("larger"))        -- Make Larger

-- Displays
hs.hotkey.bind(hyper, "right", moveDisplay("next")) -- Next Display
hs.hotkey.bind(hyper, "left", moveDisplay("prev"))  -- Previous Display


-- =====================================================================
-- SYSTEM
-- =====================================================================

hs.hotkey.bind(hyper, "Z", function()
  hs.reload()
end)
hs.alert.show("Hammerspoon Config Loaded")



