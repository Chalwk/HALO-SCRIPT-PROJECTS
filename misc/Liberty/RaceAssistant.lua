--=====================================================================================--
-- SCRIPT NAME:      Race Assistant
-- DESCRIPTION:      Ensures fair racing by requiring players to use vehicles. Features:
--                   - Configurable grace periods with visual warnings
--                   - Safe zones protection (players in these zones will not be punished)
--                   - Admin exemptions
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT © 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:         MIT License
--                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

---------------------------------
-- CONFIGURATION
---------------------------------
local RaceAssistant = {
    warnings = 2,                   -- Warnings before penalty
    initial_grace_period = 10,      -- Seconds to find first vehicle
    exit_grace_period = 10,         -- Seconds to re-enter after exiting
    driving_grace_period = 10,      -- Seconds driving to clear warnings
    enable_safe_zones = true,       -- Allow safe zones
    allow_exemptions = true,        -- Admins won't be punished
    exempt_admin_levels = {         -- Configurable exemption levels.
        [1] = false,
        [2] = false,
        [3] = true,
        [4] = true
    },
    punishment = "kill",            -- kill or kick
    safe_zones = {                  -- Map-specific safe zones {x, y, z, radius}
        -- Example: ["bloodgulch"] = {{0, 0, 0, 15}, {100, 100, 0, 10}}
    }
}

-- Do not edit below this line unless you know what you're doing.

api_version = '1.12.0.0'

local map
local players = {}
local time = os.time
local game_in_progress

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

function OnScriptUnload()
    -- N/A
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

function OnJoin(playerId)
    players[playerId] = {
        strikes = RaceAssistant.warnings,
        timer = time() + RaceAssistant.initial_grace_period,
        grace = 0,
        warned = false,
        exempt = function()
            if not RaceAssistant.allow_exemptions then return false end
            local level = tonumber(get_var(playerId, '$lvl'))
            return RaceAssistant.exempt_admin_levels[level] or false
        end
    }
end

function OnQuit(playerId)
    players[playerId] = nil
end

function OnSpawn(playerId)
    if not game_in_progress then return end
    local p = players[playerId]
    if p and not p.exempt() then
        p.strikes = RaceAssistant.warnings
        p.timer = time() + RaceAssistant.initial_grace_period
        p.warned = false
        rprint(playerId, "You have " .. RaceAssistant.initial_grace_period .. "s to enter a vehicle!")
    end
end

function OnEnter(playerId)
    local p = players[playerId]
    if p then
        p.timer = 0
        p.grace = time() + RaceAssistant.driving_grace_period
        p.warned = false
    end
end

function OnExit(playerId)
    if not game_in_progress then return end
    local p = players[playerId]
    if p and not p.exempt() then
        p.timer = time() + RaceAssistant.exit_grace_period
        p.grace = 0
    end
end

local function in_vehicle(playerId)
    local dyn = get_dynamic_player(playerId)
    if dyn == 0 then return false end
    return read_dword(dyn + 0x11C) ~= 0xFFFFFFFF
end

local function in_safe_zone(playerId)
    if not RaceAssistant.enable_safe_zones then return false end

    local zones = RaceAssistant.safe_zones[map]
    if not zones then return false end

    local dyn = get_dynamic_player(playerId)
    if dyn == 0 then return false end
    local x, y, z = read_vector3d(dyn + 0x5C)

    for _, zone in ipairs(zones) do
        local zx, zy, zz, radius = unpack(zone)
        local dist = math.sqrt((x - zx)^2 + (y - zy)^2 + (z - zz)^2)
        if dist <= radius then return true end
    end
    return false
end

local function handle_penalty(playerId, playerData, currentTime)
    playerData.strikes = playerData.strikes - 1
    playerData.timer = currentTime + RaceAssistant.exit_grace_period

    if playerData.strikes > 0 then
        rprint(playerId, "Enter a vehicle! Strikes left: " .. playerData.strikes)
    else
        if RaceAssistant.punishment == "kill" then
            execute_command('kill ' .. playerId)
            rprint(playerId, "Killed for not entering a vehicle!")
        elseif RaceAssistant.punishment == "kick" then
            execute_command('k ' .. playerId .. ' "Not entering a vehicle within the required time"')
        end
    end
end

local function reset_strikes(playerId, playerData)
    local had_strikes = playerData.strikes < RaceAssistant.warnings
    playerData.strikes = RaceAssistant.warnings
    playerData.grace = 0
    if had_strikes then
        rprint(playerId, "Strikes reset - keep racing!")
    end
end

local function proceed(playerId, playerData)
    return player_present(playerId)
            and player_alive(playerId)
            and not in_safe_zone(playerId)
            and not playerData.exempt()
end

function OnTick()
    if not game_in_progress then return end
    local now = time()

    for playerId, p in pairs(players) do
        if not proceed(playerId, p) then goto continue end

        if not in_vehicle(playerId) then
            if p.timer > 0 and now >= p.timer then
                handle_penalty(playerId, p, now)
            elseif p.timer > 0 and not p.warned and (p.timer - now) <= 10 then
                rprint(playerId, "WARNING: " .. (p.timer - now) .. "s to enter a vehicle!")
                p.warned = true
            end
        elseif p.grace > 0 and now >= p.grace then
            reset_strikes(playerId, p)
        end
        ::continue::
    end
end