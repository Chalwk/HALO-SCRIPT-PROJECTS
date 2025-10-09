--[[
=====================================================================================
SCRIPT NAME:      race_assistant.lua
DESCRIPTION:      Enforces vehicle usage in race gametypes with configurable
                  penalties for violations.

FEATURES:         - Visual countdown warnings before penalty
                  - Configurable grace periods for vehicle entry/re-entry
                  - Protected safe zones (map-configurable)
                  - Admin exemption system
                  - Multi-stage violation handling (warnings → kill/kick)

Copyright (c) 2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

---------------------------------
-- CONFIGURATION
---------------------------------
local RaceAssistant = {
    warnings = 3,              -- Warnings before penalty
    initial_grace_period = 30, -- Seconds to find first vehicle
    exit_grace_period = 90,    -- Seconds to re-enter after exiting
    driving_grace_period = 10, -- Seconds driving to clear warnings
    enable_safe_zones = true,  -- Allow safe zones
    allow_exemptions = true,   -- Admins won't be punished
    exempt_admin_levels = {    -- Configurable exemption levels.
        [1] = false,
        [2] = false,
        [3] = true,
        [4] = true
    },
    punishment = "kill", -- kill or kick
    safe_zones = {       -- Map-specific safe zones {x, y, z, radius}
        -- Example: ["bloodgulch"] = {{0, 0, 0, 15}, {100, 100, 0, 10}}
    }
}

-- Do not edit below this line unless you know what you're doing.

api_version = '1.12.0.0'

local map
local players = {}
local time = os.time
local game_in_progress

local function in_vehicle(id)
    local dyn = get_dynamic_player(id)
    if dyn == 0 then return false end
    return read_dword(dyn + 0x11C) ~= 0xFFFFFFFF
end

local function in_safe_zone(id)
    if not RaceAssistant.enable_safe_zones then return false end

    local zones = RaceAssistant.safe_zones[map]
    if not zones then return false end

    local dyn = get_dynamic_player(id)
    if dyn == 0 then return false end
    local x, y, z = read_vector3d(dyn + 0x5C)

    for _, zone in ipairs(zones) do
        local zx, zy, zz, radius = unpack(zone)
        local dist = math.sqrt((x - zx) ^ 2 + (y - zy) ^ 2 + (z - zz) ^ 2)
        if dist <= radius then return true end
    end
    return false
end

local function handle_penalty(id, playerData, currentTime)
    playerData.strikes = playerData.strikes - 1
    playerData.timer = currentTime + RaceAssistant.exit_grace_period

    if playerData.strikes > 0 then
        rprint(id, "Enter a vehicle! Strikes left: " .. playerData.strikes)
		rprint(id, "¡Entra a un vehículo! Avisos restantes: " .. playerData.strikes)
    else
        if RaceAssistant.punishment == "kill" then
            execute_command('kill ' .. id)
            rprint(id, "Killed for not entering a vehicle!")
			rprint(id, "¡Eliminado por no entrar a un vehículo!")
        elseif RaceAssistant.punishment == "kick" then
            execute_command('k ' .. id .. ' "Not entering a vehicle within the required time"')
        end
    end
end

local function reset_strikes(id, playerData)
    local had_strikes = playerData.strikes < RaceAssistant.warnings
    playerData.strikes = RaceAssistant.warnings
    playerData.grace = 0
    if had_strikes then
        rprint(id, "Strikes reset - keep racing!")
        rprint(id, "Avisos reiniciados - ¡sigue compitiendo!")
    end
end

local function proceed(id, playerData)
    return player_present(id)
        and player_alive(id)
        and not in_safe_zone(id)
        and not playerData.exempt()
end

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_VEHICLE_EXIT'], 'OnExit')
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnEnter')

    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end
    game_in_progress = true
    players = {}
    map = get_var(0, "$map")

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
end

function OnEnd()
    game_in_progress = false
end

function OnJoin(id)
    players[id] = {
        strikes = RaceAssistant.warnings,
        timer = time() + RaceAssistant.initial_grace_period,
        grace = 0,
        warned = false,
        exempt = function()
            if not RaceAssistant.allow_exemptions then return false end
            local level = tonumber(get_var(id, '$lvl'))
            return RaceAssistant.exempt_admin_levels[level] or false
        end
    }
end

function OnQuit(id)
    players[id] = nil
end

function OnSpawn(id)
    if not game_in_progress then return end
    local p = players[id]
    if p and not p.exempt() then
        p.strikes = RaceAssistant.warnings
        p.timer = time() + RaceAssistant.initial_grace_period
        p.warned = false
        rprint(id, RaceAssistant.initial_grace_period .. "s to enter a vehicle!")
        rprint(id, RaceAssistant.initial_grace_period .. " segundos para entrar a un vehículo!")
    end
end

function OnEnter(id)
    local p = players[id]
    if p then
        p.timer = 0
        p.grace = time() + RaceAssistant.driving_grace_period
        p.warned = false
    end
end

function OnExit(id)
    if not game_in_progress then return end
    local p = players[id]
    if p and not p.exempt() then
        p.timer = time() + RaceAssistant.exit_grace_period
        p.grace = 0
    end
end

function OnTick()
    if not game_in_progress then return end
    local now = time()

    for id, p in pairs(players) do
        if not proceed(id, p) then goto continue end

        if not in_vehicle(id) then
            if p.timer > 0 and now >= p.timer then
                handle_penalty(id, p, now)
            elseif p.timer > 0 and not p.warned and (p.timer - now) <= 10 then
                rprint(id, "WARNING: " .. (p.timer - now) .. "s to enter a vehicle!")
                rprint(id, "ADVERTENCIA: " .. (p.timer - now) .. " segundos para entrar a un vehículo!")
                p.warned = true
            end
        elseif p.grace > 0 and now >= p.grace then
            reset_strikes(id, p)
        end
        ::continue::
    end
end

function OnScriptUnload() end