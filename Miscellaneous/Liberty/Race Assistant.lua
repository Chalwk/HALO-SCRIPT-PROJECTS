--=====================================================================================--
-- SCRIPT NAME:      Race Assistant (Enhanced)
-- DESCRIPTION:      Ensures fair racing by requiring players to use vehicles. Features:
--                   - Configurable grace periods with visual warnings
--                   - Vehicle lock enforcement
--                   - Safe zones protection (players in these zones will not be punished)
--                   - Player exemptions
--                   - Grace period extension option
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- TODO: Only tell the player their strikes have been rest if they had any in the first place

local RaceAssistant = {
    -- Configuration Options:
    warnings = 2,                       --  Warnings before respawn
    initial_grace_period = 30,          --  Seconds to find first vehicle
    exit_grace_period = 10,             --  Seconds to re-enter after exiting
    driving_grace_period = 10,          --  Seconds driving to clear warnings
    enable_safe_zones = true,           --  Allow safe zones
    allow_exemptions = true,            --  Admins level >= 1 won't be punished
    safe_zones = {                      --  Map-specific safe zones {x, y, z, radius}
        -- Example: ["bloodgulch"] = {{0, 0, 0, 15}, {100, 100, 0, 10}}
    }
}

api_version = '1.12.0.0'

local map
local players = {}
local time = os.time

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function register_events(f)
    for event, callback in pairs({
        ['EVENT_TICK'] = 'OnTick',
        ['EVENT_JOIN'] = 'OnJoin',
        ['EVENT_LEAVE'] = 'OnQuit',
        ['EVENT_SPAWN'] = 'OnSpawn',
        ['EVENT_GAME_END'] = 'OnEnd',
        ['EVENT_VEHICLE_EXIT'] = 'OnExit',
        ['EVENT_VEHICLE_ENTER'] = 'OnEnter'
    }) do
        f(cb[event], callback)
    end
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then
        return
    end
    players = {}
    map = get_var(0, "$map")

    for i = 1, 16 do
        if player_present(i) then
            OnJoin(i)
        end
    end
    register_events(register_callback)
end

function OnEnd()
    register_events(unregister_callback)
end

function OnJoin(playerId)
    players[playerId] = {
        strikes = RaceAssistant.warnings,
        timer = time() + RaceAssistant.initial_grace_period,
        grace = 0,
        warned = false,
        exempt = function()
            return RaceAssistant.allow_exemptions and tonumber(get_var(playerId, '$lvl')) >= 1 or false
        end
    }
end

function OnQuit(playerId)
    players[playerId] = nil
end

function OnSpawn(playerId)
    local p = players[playerId]
    if p then
        if not p.exempt() then
            p.strikes = RaceAssistant.warnings
            p.timer = time() + RaceAssistant.initial_grace_period
            p.warned = false
            rprint(playerId, "You have " .. RaceAssistant.initial_grace_period .. "s to enter a vehicle!")
        end
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
    local p = players[playerId]
    if p and not p.exempt() then
        p.timer = time() + RaceAssistant.exit_grace_period
        rprint(playerId, "Re-enter vehicle within " .. RaceAssistant.exit_grace_period .. "s!")
        p.grace = 0
    end
end

function in_vehicle(playerId)
    local dyn = get_dynamic_player(playerId)
    if dyn == 0 then return false end
    return read_dword(dyn + 0x11C) ~= 0xFFFFFFFF
end

function in_safe_zone(playerId)
    if not RaceAssistant.enable_safe_zones then return false end

    local zones = RaceAssistant.safe_zones[map]
    if not zones then return false end

    local dyn = get_dynamic_player(playerId)
    if dyn == 0 then return false end
    local x, y, z = read_vector3d(dyn + 0x5C)

    for _, zone in ipairs(zones) do
        local zx, zy, zz, radius = unpack(zone)
        local dist = math.sqrt((x - zx) ^ 2 + (y - zy) ^ 2 + (z - zz) ^ 2)
        if dist <= radius then return true end
    end
    return false
end

function OnTick()
    local now = time()

    for i, p in pairs(players) do
        if not player_present(i) or not player_alive(i) then goto continue end

        -- Safe Zone Check
        if in_safe_zone(i) then goto continue end

        -- Exemption Check
        if p.exempt() then goto continue end

        -- Vehicle Check Logic
        if not in_vehicle(i) then
            if p.timer > 0 then
                -- Warn when 10s remain
                if not p.warned and (p.timer - now) <= 10 then
                    rprint(i, "WARNING: " .. (p.timer - now) .. "s to enter a vehicle!")
                    p.warned = true
                end

                if now >= p.timer then
                    p.strikes = p.strikes - 1
                    p.timer = now + RaceAssistant.exit_grace_period

                    if p.strikes > 0 then
                        rprint(i, "Enter a vehicle! Strikes left: " .. p.strikes)
                    else
                        execute_command('kill ' .. i)
                        rprint(i, "Killed for not entering a vehicle!")
                        p.strikes = RaceAssistant.warnings
                        p.timer = now + RaceAssistant.initial_grace_period
                    end
                end
            end
        elseif p.grace > 0 and now >= p.grace then
            local had_strikes = p.strikes < RaceAssistant.warnings
            p.strikes = RaceAssistant.warnings
            p.grace = 0
            if had_strikes then
                rprint(i, "Strikes reset - keep racing!")
            end
        end
        :: continue ::
    end
end

function OnScriptUnload()
    -- Cleanup if needed
end