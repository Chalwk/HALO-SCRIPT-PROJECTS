--[[
====================================================================================
SCRIPT NAME:      auto_team_balance.lua
DESCRIPTION:      Keeps teams fair by moving players around when the numbers get
                  stupid. Admins can toggle it, force an immediate check, or change
                  settings without reloading the script.

                  Commands:
                  /balance          - force a balance check right now
                  /balance on|1     - turn the balancer on
                  /balance off|0    - turn the balancer off
                  /bal_set <setting> <value>
                    Settings: delay, min_players, max_diff, priority, move_cooldown

Copyright (c) 2016-2026 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
====================================================================================
]]

-- CONFIG START --
api_version = "1.12.0.0"

local DELAY = 300          -- seconds between check-ins
local MIN_PLAYERS = 4      -- total players needed before anything happens
local MAX_DIFF = 2         -- team size gap that triggers a move
local PRIORITY = "smaller" -- "smaller" = fill the small team; "larger" = fill the large team
local MOVE_COOLDOWN = 120  -- seconds before a player can be moved again
-- END CONFIG --

local os_time = os.time
local tonumber = tonumber
local math_abs = math.abs

local last_tick = 0
local balancer_enabled = true
local last_move_time = {}

local function is_admin(id)
    return id == 0 or tonumber(get_var(id, "$lvl")) >= 1
end

local function parse_args(input)
    local parts = {}
    for word in input:gmatch("([^%s]+)") do parts[#parts + 1] = word end
    return parts
end

local function team_counts()
    return tonumber(get_var(0, "$reds")), tonumber(get_var(0, "$blues"))
end

local function notify_admins(msg)
    for i = 1, 16 do
        if player_present(i) and is_admin(i) then
            rprint(i, msg)
        end
    end
end

local function try_switch(id, from_team, to_team)
    if get_var(id, "$team") ~= from_team then return false end

    local now = os_time()
    if last_move_time[id] and now - last_move_time[id] < MOVE_COOLDOWN then return false end

    execute_command("st " .. id .. " " .. to_team)
    last_move_time[id] = now

    local name = get_var(id, "$name")
    local msg = "[AutoBalance] " .. name .. " moved from " .. from_team .. " to " .. to_team
    rprint(id, "You were moved to the " .. to_team .. " team to balance teams.")
    notify_admins(msg)

    return true
end

local function balance()
    if not balancer_enabled then return end

    local reds, blues = team_counts()
    local total = reds + blues

    if total < MIN_PLAYERS or math_abs(reds - blues) <= MAX_DIFF then return end

    local from, to
    if PRIORITY == "smaller" then
        if reds > blues then
            from, to = "red", "blue"
        else
            from, to = "blue", "red"
        end
    else
        -- move from smaller to larger
        if reds < blues then
            from, to = "red", "blue"
        else
            from, to = "blue", "red"
        end
    end

    -- try dead players first
    for i = 1, 16 do
        if player_present(i) and not player_alive(i) then
            if try_switch(i, from, to) then return end
        end
    end

    -- fallback to any living player
    for i = 1, 16 do
        if player_present(i) then
            if try_switch(i, from, to) then return end
        end
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnEnd")
    register_callback(cb["EVENT_GAME_START"], "OnStart")
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    OnStart()
end

function OnStart()
    if get_var(0, "$gt") == "n/a" then return end
    last_tick = 0
    last_move_time = {}
end

function OnEnd()
    last_tick = nil
    last_move_time = {}
end

function OnTick()
    if last_tick == nil then return end

    local now = os_time()
    if now - last_tick >= DELAY then
        last_tick = now
        balance()
    end
end

function OnCommand(id, command)
    local args = parse_args(command)
    if #args == 0 then return end

    local cmd = args[1]:lower()

    if cmd == "balance" then
        if not is_admin(id) then return false end

        local sub = args[2] and args[2]:lower()
        if sub == "on" or sub == "1" then
            balancer_enabled = true
            rprint(id, "Auto-balancer turned ON")
        elseif sub == "off" or sub == "0" then
            balancer_enabled = false
            rprint(id, "Auto-balancer turned OFF")
        else
            last_tick = 0
            rprint(id, "Forcing immediate balance check...")
            balance()
        end
        return false
    end

    if cmd == "bal_set" then
        if not is_admin(id) then return false end
        if #args < 3 then
            rprint(id, "Usage: /bal_set <setting> <value>")
            rprint(id, "Settings: delay, min_players, max_diff, priority, move_cooldown")
            return false
        end

        local setting = args[2]:lower()
        local value = args[3]

        if setting == "delay" then
            local v = tonumber(value)
            if v and v > 0 then
                DELAY = v
                rprint(id, "DELAY set to " .. v)
            else
                rprint(id, "Invalid delay (positive number)")
            end
        elseif setting == "min_players" then
            local v = tonumber(value)
            if v and v > 0 and v <= 16 then
                MIN_PLAYERS = v
                rprint(id, "MIN_PLAYERS set to " .. v)
            else
                rprint(id, "Invalid min_players (1-16)")
            end
        elseif setting == "max_diff" then
            local v = tonumber(value)
            if v and v >= 0 then
                MAX_DIFF = v
                rprint(id, "MAX_DIFF set to " .. v)
            else
                rprint(id, "Invalid max_diff (0 or more)")
            end
        elseif setting == "priority" then
            if value == "smaller" or value == "larger" then
                PRIORITY = value
                rprint(id, "PRIORITY set to " .. value)
            else
                rprint(id, "Priority must be 'smaller' or 'larger'")
            end
        elseif setting == "move_cooldown" then
            local v = tonumber(value)
            if v and v >= 0 then
                MOVE_COOLDOWN = v
                rprint(id, "MOVE_COOLDOWN set to " .. v)
            else
                rprint(id, "Invalid cooldown (0 or more seconds)")
            end
        else
            rprint(id, "Unknown setting. Available: delay, min_players, max_diff, priority, move_cooldown")
        end
        return false
    end
end

function OnScriptUnload() end
