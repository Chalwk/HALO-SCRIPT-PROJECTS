--[[
------------------------------------
Description: HPC Assign Weapons-Ammo, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

-- Settings
local MAPS = { "beavercreek", "bloodgulch", "ratrace", "timberland", "wizard" }
local AMMO = 4
local CLIP = 3

-- Function to get the required version
function GetRequiredVersion()
    return 200
end

-- Function called when the script is loaded
function OnScriptLoad()
    -- No actions needed on load
end

-- Function called when the script is unloaded
function OnScriptUnload()
    -- No actions needed on unload
end

-- Function to check if the current map is in the list of specified maps
local function IsMapValid(map_name)
    for _, map in ipairs(MAPS) do
        if map_name == map then
            return true
        end
    end
    return false
end

-- Function to clear player's weapons
local function ClearPlayerWeapons(player)
    local m_objectId = getplayerobjectid(player)
    if m_objectId then
        for i = 0, 3 do
            local weapID = readdword(getobject(m_objectId), 0x2F8 + i * 4)
            if weapID ~= 0xFFFFFFFF then
                destroyobject(weapID)
            end
        end
    end
end

-- Function to set player's grenades
local function SetPlayerGrenades(m_object)
    if m_object then
        writebyte(m_object, 0x31E, 4) -- frags
        writebyte(m_object, 0x31F, 4) -- stickies
    end
end

-- Function to assign a weapon to the player
local function AssignWeapon(player, weapon_tag)
    local m_weaponId = createobject(gettagid("weap", weapon_tag), 0, 10, false, 0, 0, 0)
    assignweapon(player, m_weaponId)
    local m_weapon = getobject(m_weaponId)
    if m_weapon then
        writeword(m_weapon + 0x2B6, AMMO)
        writeword(m_weapon + 0x2B8, CLIP)
        updateammo(m_weaponId)
    end
end

-- Function called when a player spawns
function OnPlayerSpawnEnd(player, m_objectId)
    if IsMapValid(map_name) and getplayer(player) then
        local m_objectId = getplayerobjectid(player)
        local m_object = getobject(m_objectId)
        ClearPlayerWeapons(player)
        SetPlayerGrenades(m_object)
        AssignWeapon(player, "weapons\\sniper rifle\\sniper rifle")
    end
end