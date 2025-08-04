--=====================================================================================--
-- SCRIPT NAME:      Race Assistant
-- DESCRIPTION:      Monitors player behavior to encourage participation in racing.
--                   Players are warned if not in a vehicle after a delay, and are
--                   respawned if they exceed a configurable number of warnings.
--                   Strikes reset after a grace period of vehicle usage.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- COPYRIGHT (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
-- NOTICE:           You may use this script subject to the following license:
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

local RaceAssistant = {

    -- Number of warnings before a player is respawned:
    --
    warnings = 5,

    -- Number of seconds before a player is warned:
    --
    time_until_warn = 3,

    -- If true, admins will be exempt from being warned:
    --
    ignore_admins = false,

    -- Number of seconds a player must been driving before their warnings are reset:
    --
    grace_period = 10,
}

api_version = '1.12.0.0'
local players = {}
local time = os.time

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

function RaceAssistant:NewPlayer(o)
    setmetatable(o, self)
    self.__index = self
    o.strikes = self.warnings
    return o
end

function RaceAssistant:NewTimer(finish)
    return {
        start = time,
        finish = time() + finish,
    }
end

local function RegSAPPEvents(f)
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
    if (get_var(0, '$gt') ~= 'n/a') then
        players = {}
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
        RegSAPPEvents(register_callback)
    end
end

function OnEnd()
    RegSAPPEvents(unregister_callback)
end

function OnJoin(Ply)
    players[Ply] = RaceAssistant:NewPlayer({})
end

function OnQuit(Ply)
    players[Ply] = nil
end

function OnSpawn(Ply)
    local p = players[Ply]
    if (p) then
        p.strikes = p.warnings
        p.timer = p:NewTimer(p.time_until_warn)
    end
end

function OnEnter(Ply)
    local p = players[Ply]
    if (p) then
        p.timer = nil
        p.grace = p:NewTimer(p.grace_period)
    end
end

function OnExit(Ply)
    local p = players[Ply]
    if (p) then
        p.timer = p:NewTimer(p.time_until_warn)
        p.grace = nil
    end
end

local function InVehicle(Ply)
    local p = players[Ply]
    local dyn = get_dynamic_player(Ply)
    if (dyn ~= 0) then

        local vehicle = read_dword(dyn + 0x11C)
        local object = get_object_memory(vehicle)
        return vehicle ~= 0xFFFFFFFF and object ~= 0
    end

    p.grace = nil -- just in case
    return false
end

local function IgnoreAdmin(Ply)
    return (tonumber(get_var(Ply, '$lvl')) >= 1)
end

function OnTick()
    for i, v in pairs(players) do
        if (v.ignore_admins and IgnoreAdmin(i)) then
            goto next
        elseif (v.timer and player_alive(i) and not InVehicle(i)) then
            if (v.timer.start() >= v.timer.finish) then
                if (v.strikes > 0) then
                    v.strikes = v.strikes - 1
                    v.timer = v:NewTimer(v.time_until_warn)
                    say(i, 'Please enter a vehicle. You have (' .. v.strikes .. ') strikes remaining.')
                elseif (v.strikes == 0) then
                    execute_command_sequence('kill ' .. i .. '; say ' .. i .. ' "You have been respawned"')
                end
            end
        elseif (v.grace and player_alive(i) and InVehicle(i)) then
            if (v.grace.start() >= v.grace.finish) then
                v.strikes = v.warnings
            end
        end
        :: next ::
    end
end

function OnScriptUnload()
    -- N/A
end