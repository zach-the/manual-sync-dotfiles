-- =====================================================================
-- DEFINE HYPER : CTRL + OPT + CMD + SHIFT
-- =====================================================================
local hyper = {"ctrl", "alt", "cmd", "shift"}

-- =====================================================================
-- DIRECTIONAL FOCUS FUNCTIONS
-- =====================================================================

-- Helper function to center mouse on a specific window
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

-- Smart Directional Focus Function (now with Mouse Movement)
local function smartFocus(direction)
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local prevWin = win
    local prevScreen = win:screen()
    
    -- 1. Try standard directional focus first
    if direction == "West" then win:focusWindowWest()
    elseif direction == "East" then win:focusWindowEast()
    elseif direction == "North" then win:focusWindowNorth()
    elseif direction == "South" then win:focusWindowSouth()
    end
    
    local currWin = hs.window.focusedWindow()
    local currScreen = currWin:screen()

    -- 2. Detect Failure: Did we get stuck? OR Did we jump in the wrong direction?
    local stuck = (currWin == prevWin)
    local wrongDirection = false

    -- Check for the "Wrap Around" bug
    if direction == "West" and currScreen:frame().x > prevScreen:frame().x then
        wrongDirection = true
    elseif direction == "East" and currScreen:frame().x < prevScreen:frame().x then
        wrongDirection = true
    end

    -- 3. If standard move worked correctly, move mouse and exit
    if not stuck and not wrongDirection then
        moveMouseToWindow(currWin)
        return
    end

    -- 4. If failed, force a Screen Focus in that direction
    local nextScreen = nil
    if direction == "West" then nextScreen = prevScreen:toWest()
    elseif direction == "East" then nextScreen = prevScreen:toEast()
    elseif direction == "North" then nextScreen = prevScreen:toNorth()
    elseif direction == "South" then nextScreen = prevScreen:toSouth()
    end
    
    if nextScreen then
        -- Find the last focused window on that screen and focus it
        local windows = hs.window.filter.default:getWindows()
        for _, w in ipairs(windows) do
            if w:screen() == nextScreen then
                w:focus()
                moveMouseToWindow(w) -- Move mouse to the forced screen window
                return
            end
        end
    end
end

-- Bindings
hs.hotkey.bind({"cmd"}, "H", function() smartFocus("West") end)
hs.hotkey.bind({"cmd"}, "L", function() smartFocus("East") end)
hs.hotkey.bind({"cmd"}, "K", function() smartFocus("North") end)
hs.hotkey.bind({"cmd"}, "J", function() smartFocus("South") end)

-- =====================================================================
-- WINDOW THROWING FUNCTION
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


-- =====================================================================
-- LAUNCH CHROME
-- =====================================================================

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


-- =====================================================================
-- KEY BINDINGS FOR WINDOW THROWING / DIRECTIONAL FOCUS
-- =====================================================================

-- Halves
hs.hotkey.bind(hyper, "A", move(0, 0, 0.5, 1))      -- Left Half
hs.hotkey.bind(hyper, "D", move(0.5, 0, 0.5, 1))    -- Right Half
hs.hotkey.bind(hyper, "S", move(0.25, 0, 0.5, 1))   -- Center Half

-- NOTE: Your 'T' binding for "Top Half" is currently overwritten by 
-- the "Launch Ghostty" binding above. I have commented this out to avoid confusion.
-- hs.hotkey.bind(hyper, "T", move(0, 0, 1, 0.5))      -- Top Half

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
hs.hotkey.bind(hyper, "o", moveDisplay("next")) -- Next Display
hs.hotkey.bind(hyper, "y", moveDisplay("prev"))  -- Previous Display


hs.hotkey.bind(hyper, "Z", function()
  hs.reload()
end)

-- Keybinds for Focus Shifting
hs.hotkey.bind({"cmd"}, "H", function() smartFocus("West") end)
hs.hotkey.bind({"cmd"}, "L", function() smartFocus("East") end)
hs.hotkey.bind({"cmd"}, "K", function() smartFocus("North") end)
hs.hotkey.bind({"cmd"}, "J", function() smartFocus("South") end)

-- =====================================================================
-- CONFIG LOADED MESSAGE
-- =====================================================================
hs.alert.show("Hammerspoon Config Loaded")
