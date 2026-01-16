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
