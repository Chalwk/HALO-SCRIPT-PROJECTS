--=====================================================================================--
-- SCRIPT NAME:      Show Player Position
-- DESCRIPTION:      Displays the player's current X, Y, Z coordinates in the console
--                   each tick while enabled. Output message format is configurable.
--                   Can be toggled on/off in-game by typing "show_pos" in the console.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | Chimera
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

clua_version = 2.056

local custom_command = "show_pos"
local enabled = true -- start enabled

local fmt = string.format
-- Use placeholders {x}, {y}, and {z} for coordinates
local output_format = "Player position is X={x}, Y={y}, Z={z}"

function OnTick()
    if not enabled then return end

    local player = get_dynamic_player()
    if player then
        local x = read_float(player + 0x5C)
        local y = read_float(player + 0x60)
        local z = read_float(player + 0x64)

        local xs = fmt("%.2f", x)
        local ys = fmt("%.2f", y)
        local zs = fmt("%.2f", z)

        local message = output_format
            :gsub("{x}", xs)
            :gsub("{y}", ys)
            :gsub("{z}", zs)

        execute_script("cls")
        console_out(message)
    end
end

function OnCommand(command)
    if command:lower() == custom_command then
        enabled = not enabled
        console_out("Position display " .. (enabled and "enabled." or "disabled."))
        return false
    end
end

set_callback("tick", "OnTick")
set_callback("command", "OnCommand")