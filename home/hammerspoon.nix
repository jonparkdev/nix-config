{
  ...
}:
{
  home.file.".hammerspoon/init.lua".text = ''
    -- Cmd+Shift+K: Open Obsidian and Ghostty side by side
    hs.hotkey.bind({"cmd", "shift"}, "k", function()
      local script = [[
        tell application "Obsidian" to activate
        tell application "Ghostty" to activate

        tell application "Finder"
          set screenBounds to bounds of window of desktop
          set screenWidth to item 3 of screenBounds
          set screenHeight to item 4 of screenBounds
        end tell

        delay 0.5

        tell application "System Events"
          if exists window 1 of application process "Obsidian" then
            set position of window 1 of application process "Obsidian" to {0, 0}
            set size of window 1 of application process "Obsidian" to {screenWidth / 2, screenHeight}
          end if
        end tell

        tell application "System Events"
          if exists window 1 of application process "Ghostty" then
            set position of window 1 of application process "Ghostty" to {screenWidth / 2, 0}
            set size of window 1 of application process "Ghostty" to {screenWidth / 2, screenHeight}
          end if
        end tell
      ]]
      hs.osascript.applescript(script)
    end)
  '';
}
