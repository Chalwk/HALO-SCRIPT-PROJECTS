--=====================================================================================--
-- SCRIPT NAME:      Player Ping Display
-- DESCRIPTION:      Calculates and displays the player's network ping on screen each tick
--                   while enabled. The output message format is configurable with
--                   a placeholder for the ping value. Toggle on/off in-game by typing
--                   the command "show_ping" in the console.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | Chimera
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- === CONFIGURATION ===
local is_enabled = true -- default toggle ON
local command_name = "show_ping"

local display_font = "small"
local display_align = "right"
local display_bounds = { left = 0, top = 460, right = 640, bottom = 20 }

local ping_good_threshold = 80
local ping_medium_threshold = 150

local ping_smooth_window = 5

-- Configurable ping text output.
-- Use {ping} as placeholder for the ping value.
local ping_text_format = "Ping: {ping} ms"
-- CONFIG ENDS HERE ---------------------------------------------------

-- === INTERNAL STATE ===
clua_version = 2.056
local recent_pings = {}
local average_ping = nil

-- Calculate average of recent pings
local function calculate_average_ping()
    local total = 0
    for _, value in ipairs(recent_pings) do
        total = total + value
    end
    return #recent_pings > 0 and total / #recent_pings or 0
end

-- Add new ping and maintain smoothing window
local function update_ping_history(new_ping)
    if #recent_pings >= ping_smooth_window then
        table.remove(recent_pings, 1)
    end
    table.insert(recent_pings, new_ping)
    average_ping = calculate_average_ping()
end

-- Determine color based on ping value (returns alpha, r, g, b)
local function determine_ping_color(ping_val)
    if ping_val <= ping_good_threshold then
        return 1.0, 0.5, 1.0, 0.5   -- cyan bright
    elseif ping_val <= ping_medium_threshold then
        return 1.0, 1.0, 0.5, 0.1   -- pale yellow
    else
        return 1.0, 1.0, 0.25, 0.25 -- soft red
    end
end

function OnTick()
    local local_player = get_player()
    if local_player and server_type == "dedicated" then
        local current_ping = read_dword(local_player + 0xDC)
        if current_ping > 0 and current_ping < 1000 then -- sanity check
            update_ping_history(current_ping)
        else
            average_ping = nil
            recent_pings = {}
        end
    else
        average_ping = nil
        recent_pings = {}
    end
end

function OnPreFrame()
    if is_enabled and average_ping then
        local alpha, red, green, blue = determine_ping_color(average_ping)
        local ping_display = ping_text_format:gsub("{ping}", string.format("%.0f", average_ping))
        draw_text(ping_display,
            display_bounds.left,
            display_bounds.top,
            display_bounds.right,
            display_bounds.bottom,
            display_font,
            display_align,
            alpha, red, green, blue
        )
    end
end

function OnCommand(cmd)
    if cmd:lower() == command_name then
        is_enabled = not is_enabled
        console_out("Ping display " .. (is_enabled and "enabled." or "disabled."))
        return false
    end
    return true
end

function OnMapLoad()
    recent_pings = {}
    average_ping = nil
end

set_callback("tick", "OnTick")
set_callback("preframe", "OnPreFrame")
set_callback("command", "OnCommand")
set_callback("map load", "OnMapLoad")