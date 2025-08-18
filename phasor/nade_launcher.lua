--[[
------------------------------------
Description: HPC Nade Launcher, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--
--[[
Changing projectiles of current weapon. Direction and velocity is also applied.
--]]

vel = 0.5 -- Velocity to launch projectile
dist = 0.4 -- Distance from player to spawn projectile

---------------------------------------------------------------------------
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnScriptUnload()
end
---------------------------------------------------------------------------

function OnNewGame(map)
    proj_mapId = gettagid("proj", "weapons\\frag grenade\\frag grenade")
end

function OnObjectCreationAttempt(mapid, parentid, player)
    local name, type = gettaginfo(mapid)
    if type == "proj" and string.find(name, "nade") == nil then
        registertimer(0, "thread_changeprojectile", parentid)
        return false
    end
end

function thread_changeprojectile(id, count, m_objectId)
    changeprojectile(m_objectId)
    return false
end

function changeprojectile(m_objectId)
    if getobject(m_objectId) then
        -- Player still here
        local player = objectidtoplayer(m_objectId)
        if getplayer(player) then
            local m_object = getobject(m_objectId)
            local x_aim = readfloat(m_object, 0x230)
            local y_aim = readfloat(m_object, 0x234)
            local z_aim = readfloat(m_object, 0x238)
            local x = readfloat(m_object, 0x5C)
            local y = readfloat(m_object, 0x60)
            local z = readfloat(m_object, 0x64)
            local projx = x + dist * math.sin(x_aim)
            local projy = y + dist * math.sin(y_aim)
            local projz = z + dist * math.sin(z_aim) + 0.5
            -- Spawn projectile infront of player.
            local projId = createobject(proj_mapId, m_objectId, -1, false, projx, projy, projz)
            -- Write projectile velocity.
            local m_proj = getobject(projId)
            if m_proj then
                writefloat(m_proj, 0x68, vel * math.sin(x_aim))
                writefloat(m_proj, 0x6C, vel * math.sin(y_aim))
                writefloat(m_proj, 0x70, vel * math.sin(z_aim))
            end
        end
    end
end