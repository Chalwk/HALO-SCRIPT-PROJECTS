--[[
=====================================================================================
SCRIPT NAME:      race_assistant.lua
DESCRIPTION:      Enforces vehicle usage in race gametypes with configurable
                  penalties for violations.

LAST UPDATED:     14/10/25

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG START ------------------------------------------------------------
local GRACE_PERIOD = 25   -- Seconds to enter vehicle
local PUNISHMENT = "kill" -- "kill" or "kick"

local ALLOW_EXEMPTIONS = true
local EXEMPT_ADMIN_LEVELS = {
    [1] = false,
    [2] = false,
    [3] = true,
    [4] = true
}
-- CONFIG END --------------------------------------------------------------

api_version = '1.12.0.0'

local players = {}
local game_in_progress = false

local os_time = os.time
local tonumber = tonumber
local math_ceil = math.ceil

local rprint = rprint
local get_var = get_var
local read_dword = read_dword
local player_alive = player_alive
local player_present = player_present
local get_dynamic_player = get_dynamic_player

local function inVehicle(id)
    local dyn = get_dynamic_player(id)
    return dyn ~= 0 and read_dword(dyn + 0x11C) ~= 0xFFFFFFFF
end

local function resetPlayer(id)
    players[id] = {
        timer = os_time() + GRACE_PERIOD,
        warned = false
    }
end

local function isExempt(id)
    if not ALLOW_EXEMPTIONS then return false end
    local level = tonumber(get_var(id, '$lvl'))
    return EXEMPT_ADMIN_LEVELS[level] or false
end

local function penalize(id)
    if PUNISHMENT == "kill" then
        execute_command('kill ' .. id)
        rprint(id, "Killed for not racing!")
    else
        execute_command('k ' .. id .. ' "Not racing!"')
    end
end

local function proceed(id)
    if player_present(id) and player_alive(id) and not isExempt(id) then
        return players[id] or nil
    end
    return nil
end

function OnScriptLoad()
    timer(1000, "CheckPlayers")
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnEnter')
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end

    players = {}
    game_in_progress = true

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    game_in_progress = false
    players = {}
end

function OnJoin(id)
    resetPlayer(id)
end

function OnQuit(id)
    players[id] = nil
end

function OnSpawn(id)
    if not game_in_progress then return end
    resetPlayer(id)
end

function OnEnter(id)
    if players[id] then
        players[id].timer = 0 -- Reset timer (in vehicle)
        players[id].warned = false
    end
end

function CheckPlayers()
    if game_in_progress then
        local current_time = os_time()

        for i = 1, 16 do
            local player = proceed(i)
            if not player then goto continue end

            -- Player is in vehicle, skip checks
            if inVehicle(i) then goto continue end

            -- Player not in vehicle and timer is active
            if player.timer > 0 then
                local time_left = player.timer - current_time
                local half_time = GRACE_PERIOD / 2

                -- Warning at half grace period
                if not player.warned and time_left <= half_time then
                    rprint(i, "WARNING: Enter a vehicle in " .. math_ceil(time_left) .. "s!")
                    rprint(i, "Type /vlist to see available vehicles.")
                    player.warned = true
                end

                -- Penalize when timer expires
                if time_left <= 0 then
                    penalize(i)
                    player.timer = current_time + GRACE_PERIOD -- Reset for next violation
                    player.warned = false
                end
            else
                -- Player exited vehicle, start new grace period
                player.timer = current_time + GRACE_PERIOD
                player.warned = false
            end

            ::continue::
        end
    end
    return true
end

function OnScriptUnload() end
