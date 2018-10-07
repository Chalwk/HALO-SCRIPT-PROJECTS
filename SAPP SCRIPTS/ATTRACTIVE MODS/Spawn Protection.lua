--[[
--=====================================================================================================--
Script Name: Spawn Protection, for SAPP (PC & CE)
Implementing API version: 1.11.0.0
Description: By default, you will spawn with an overshield, invisibility(7s), godmode(7s), and a speed boost(7s/1.3+) for every 10 consecutive deaths.

    This script will allow you to optionally toggle:
        * godmode (invulnerability)
        * speed boost + define amount to boost by, (1.3 by default)
        * invisibility
        * overshield

    There are two modes:
        Mode1: 'consecutive deaths' (editable)
        * If this mode is enabled, for every (default 10) consecutive deaths you will spawn with protection.
        Mode2: Receive protection when you reach a specific amount of deaths (editable threshold)

    TO DO:
        - Detect if Killer is camping
        - Punish Killer
        * Suggestions? https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/issues/5

Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
-- Mode 1 = consecutive deaths (editable)
-- Mode 2 = Specific amout of deaths (editable)
-- Configuration--
local settings = {
    ["Mode1"] = true,
    ["Mode2"] = false,
    ["UseCamo"] = true,
    ["UseOvershield"] = true,
    ["UseSpeedBoost"] = true,
    ["UseInvulnerability"] = true,
}

-- attributes given every (Consecutivedeaths) deaths to victim
Consecutivedeaths = 10
-- When victim spawn protection has been reset, what should their speed be restored to? (Normal running speed = 1.0)
ResetSpeedTo = 1.0
-- Speed boost amount when receiving spawn protection.
SpeedBoost = 1.3
-- Speedboost activation time (in seconds)
SpeedDuration = 7.0
-- Godmode activation time (in seconds)
Invulnerable = 7.0
-- Camo activation time (in seconds)
CamoTime = 7.0
-- Configuration Ends --

-- When using [mode 2] and not [mode 1], victim spawns with protection when they have exactly this many consecutive deaths
-- When you reach exactly 10 deaths you get protection.
-- When you reach exactly 20 deaths you get protection and so on...
death_count = {
    "10",
    "20",
    "30",
    "45",
    "60",
    "75",
    "95",
    "115",
    "135" -- don't put a comma on the last entry.
}

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
end

function OnScriptUnload() end

deaths = { }

function OnPlayerJoin(PlayerIndex)
    deaths[PlayerIndex] = { 0 }
end

function OnPlayerLeave(PlayerIndex)
    deaths[PlayerIndex] = { 0 }
end

function OnGameEnd(PlayerIndex)
    deaths[PlayerIndex] = { 0 }
end

function OnPlayerDeath(VictimIndex, KillerIndex)
    local victim = tonumber(VictimIndex)
    local killer = tonumber(KillerIndex)
    if (killer > 0) then
        deaths[victim][1] = deaths[victim][1] + 1
    end
end

function ApplyCamo(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        execute_command("camo me " .. CamoTime, PlayerIndex)
    else
        return false
    end
end

function ApplyOvershield(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        local ObjectID = spawn_object("eqip", "powerups\\over shield")
        powerup_interact(ObjectID, PlayerIndex)
    else
        return false
    end
end

function Invulnerability(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        timer(Invulnerable * 1000, "ResetInvulnerability", PlayerIndex)
        execute_command("god me", PlayerIndex)
    else
        return false
    end
end

function GiveSpeedBoost(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        local PlayerIndex = tonumber(PlayerIndex)
        local victim = get_player(PlayerIndex)
        timer(SpeedDuration * 1000, "ResetPlayerSpeed", PlayerIndex)
        write_float(victim + 0x6C, SpeedBoost)
    else
        return false
    end
end

function ResetPlayerSpeed(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        local PlayerIndex = tonumber(PlayerIndex)
        local victim = get_player(PlayerIndex)
        write_float(victim + 0x6C, ResetSpeedTo)
        rprint(PlayerIndex, "|cSpeed Boost deactivated!")
    else
        return false
    end
end

function ResetInvulnerability(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        execute_command("ungod me", PlayerIndex)
        rprint(PlayerIndex, "|cGod Mode deactivated!")
    else
        return false
    end
end

function CheckSettings(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        local name = get_var(PlayerIndex, "$name")
        cprint(name .. " received Spawn Protection!", 2 + 8)
        rprint(PlayerIndex, "|cYou have received Spawn Protection!")
        rprint(PlayerIndex, "|n")
        rprint(PlayerIndex, "|n")
        rprint(PlayerIndex, "|n")
        rprint(PlayerIndex, "|n")
        rprint(PlayerIndex, "|n")
        if settings["UseCamo"] then
            timer(0, "ApplyCamo", PlayerIndex)
        end
        if settings["UseSpeedBoost"] then
            GiveSpeedBoost(PlayerIndex)
        end
        if settings["UseInvulnerability"] then
            Invulnerability(PlayerIndex)
        end
        if settings["UseOvershield"] then
            timer(0, "ApplyOvershield", PlayerIndex)
        end
    else
        return false
    end
end

function OnPlayerSpawn(PlayerIndex)
    if (player_present(PlayerIndex)) then
        if settings["Mode1"] and not settings["Mode2"] then
            if (deaths[PlayerIndex][1] == nil) then deaths[PlayerIndex][1] = 0
            elseif (deaths[PlayerIndex][1] == Consecutivedeaths) then
                CheckSettings(PlayerIndex)
                deaths[PlayerIndex][1] = 0
            end
        elseif settings["Mode2"] and not settings["Mode1"] then
            if (deaths[PlayerIndex][1] == nil) then
                deaths[PlayerIndex][1] = 0
            else
                for i = 1, #death_count do
                    if tonumber(deaths[PlayerIndex][1]) == tonumber(death_count[i]) then
                        CheckSettings(PlayerIndex)
                        cprint("running!", 2 + 8)
                    end
                end
            end
        end
    end
end

function OnNewGame()
    if logging then
        if settings["Mode1"] and settings["Mode2"] then
            note = string.format("\n[SCRIPT CONFIGURATION ERROR] - Spawn Protection:\nMode 1 and Mode 2 are both enabled!\nYou can only enable one at a time!\n")
            lognote()
        end
        if not settings["Mode1"] and not settings["Mode2"] then
            note = string.format("\n[SCRIPT CONFIGURATION ERROR] - Spawn Protection:\nMode 1 and Mode 2 are both disabled!\nYou must enable one of them.\n")
            lognote()
        end
        if settings["Mode1"] and settings["UseCamo"] == false and settings["UseSpeedBoost"] == false and settings["UseInvulnerability"] == false and settings["UseOvershield"] == false then
            note = string.format("\n[SCRIPT CONFIGURATION ERROR] - Spawn Protection:\nNo sub-settings enabled for Mode 1\n")
            lognote()
        elseif settings["Mode2"] and settings["UseCamo"] == false and settings["UseSpeedBoost"] == false and settings["UseInvulnerability"] == false and settings["UseOvershield"] == false then
            note = string.format("\n[SCRIPT CONFIGURATION ERROR] - Spawn Protection:\nNo sub-settings enabled for Mode 2\n")
            lognote()
        end
    end
end

function lognote()
    cprint(note, 4 + 8)
    execute_command("log_note \""..note.."\"")
end

function OnError(Message)
    print(debug.traceback())
end
