--[[
=====================================================================================
SCRIPT NAME:      game_countdown.lua
DESCRIPTION:      Example script demonstrating:
                  - Game time access functionality

Copyright (c) 2016-2022 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

local timelimit_address
local tick_counter_address
local sv_map_reset_tick_address

function OnScriptLoad()

    local tick_counter_sig = sig_scan("8B2D????????807D0000C644240600")
    if (tick_counter_sig == 0) then return end

    local sv_map_reset_tick_sig = sig_scan("8B510C6A018915????????E8????????83C404")
    if (sv_map_reset_tick_sig == 0) then return end

    local timelimit_location_sig = sig_scan("8B0D????????83C8FF85C97E17")
    if (timelimit_location_sig == 0) then return end

    timelimit_address = read_dword(timelimit_location_sig + 2)
    sv_map_reset_tick_address = read_dword(sv_map_reset_tick_sig + 7)
    tick_counter_address = read_dword(read_dword(tick_counter_sig + 2)) + 0xC
end

local floor, format = math.floor, string.format
local function SecondsToTime(seconds)
    local hr = floor(seconds / 3600)
    local min = floor((seconds % 3600) / 60)
    local sec = floor(seconds % 60)
    return format("%02d:%02d:%02d", hr, min, sec)
end

local function getTimeRemaining()
    local timelimit = read_dword(timelimit_address)
    local tick_counter = read_dword(tick_counter_address)
    local sv_map_reset_tick = read_dword(sv_map_reset_tick_address)
    local time_remaining_in_seconds = floor((timelimit - (tick_counter - sv_map_reset_tick)) / 30)
    return SecondsToTime(time_remaining_in_seconds)
end