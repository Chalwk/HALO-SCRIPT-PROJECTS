-- Name: caomo_speed.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

-- Settings
local EQUIPMENT = { "powerups\\active camouflage" }
local EQUIPMENT_TAGS = {}
local SPEED_POWERUP = 2 -- Scale
local SPEED_POWERUP_DURATION = 10 -- Seconds
local Camouflage_Tag_ID

-- Function to get the required version
function GetRequiredVersion()
    return 200
end

-- Function called when the script is loaded
function OnScriptLoad(processid, game, persistent)
    -- No actions needed on load
end

-- Function called when the script is unloaded
function OnScriptUnload()
    -- No actions needed on unload
end

-- Function called when a new game starts
function OnNewGame(map)
    for _, tag in ipairs(EQUIPMENT) do
        local TAG_ID = gettagid("eqip", tag)
        table.insert(EQUIPMENT_TAGS, TAG_ID)
    end
    Camouflage_Tag_ID = gettagid("eqip", "powerups\\active camouflage")
end

-- Function to apply speed to a player
local function ApplySpeed(player)
    if player then
        setspeed(player, SPEED_POWERUP)
        registertimer(SPEED_POWERUP_DURATION * 1000, "ResetSpeed", player)
    end
end

-- Function to reset the player's speed
function ResetSpeed(id, count, player)
    setspeed(player, 1.08)
    return false
end

-- Function called when a player interacts with an object
function OnObjectInteraction(player, objId, MapID)
    for _, tag in ipairs(EQUIPMENT_TAGS) do
        if MapID == tag and MapID == Camouflage_Tag_ID then
            ApplySpeed(player)
        end
    end
end