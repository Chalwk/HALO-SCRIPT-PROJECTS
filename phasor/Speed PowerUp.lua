--[[
------------------------------------
Description: HPC Speed PowerUp, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
-- When a player interacts with a camouflage, this script will give them a temporary speed boost.
function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
end
EQUIPMENT = { }
EQUIPMENT_TAGS = { }
EQUIPMENT[1] = { "powerups\\active camouflage" }
SPEED_POWERUP = (2) -- Scale: Amount of speed to give the player: (default: 1)
SPEED_POWERUP_DURATION = (10) -- Time the speed boosts lasts. (in seconds)
DB = " has been given a speed boost"
RESET = "'s Speed Boost was reset!"
function OnNewGame(map)
    for k, v in pairs(EQUIPMENT) do
        local TAG_ID = gettagid("eqip", v[1])
        table.insert(EQUIPMENT_TAGS, TAG_ID)
    end
    Camouflage_Tab_ID = gettagid("eqip", "powerups\\active camouflage")
end

function ApplySpeed(player)
    if player then
        setspeed(player, tonumber(SPEED_POWERUP))
        registertimer(SPEED_POWERUP_DURATION * (1000), "ResetSpeed", player)
        -- 1000 milliseconds (1 second increments)
        privatesay(player, "Speed Boost!", false)
        -- returning false to disable the server prefix!
        -- 	local name = getname(player)
        -- 	respond(getname(player) .. DB)
    end
end

function BeginCountDown(id, count)
    if count == 10 then
        local name = getname(player)
        say("POWERUP RESET!", false)
        respond(getname(player) .. RESET)
        return false
    else
        say("Resetting Powerup in: (" .. 10 - count .. ")", false)
        hprintf("Resetting Powerup in: " .. 10 - count .. ")")
        return true
    end
end

function ResetSpeed(id, count, player)
    setspeed(player, (1.08))
    privatesay(player, "Speed Reset!", false)
    -- Returning false to disable the server prefix!
    local name = getname(player)
    hprintf(name .. "'s Speed Boost was rest!")
    return (0)
    -- Do Not Touch
end

function OnObjectInteraction(player, objId, MapID)
    for i = (0), #EQUIPMENT_TAGS do
        if MapID == EQUIPMENT_TAGS[i] then
            if MapID == Camouflage_Tab_ID then
                -- Camo MapID
                ApplySpeed(player)
                -- Sets player speed (SPEED_POWERUP)
                -- 		CountDown = registertimer(1000, "BeginCountDown")
            end
        end
    end
end