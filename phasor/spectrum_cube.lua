--[[
------------------------------------
Description: HPC Spectrum Cube Spawner, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

function GetRequiredVersion()
    return
    200
end

function OnScriptUnload()

end

FullSpectrumVision = { }
math.inf = 1 / 0
FullSpectrumVision[1] = { "powerups\\full-spectrum vision", 92.538, -160.213, -0.215 } -- Red base (The four Cabinet Portals)
FullSpectrumVision[2] = { "powerups\\full-spectrum vision", 92.550, -158.581, -0.256 }
FullSpectrumVision[3] = { "powerups\\full-spectrum vision", 98.559, -158.558, -0.253 }
FullSpectrumVision[4] = { "powerups\\full-spectrum vision", 98.541, -160.190, -0.255 }
FullSpectrumVision[5] = { "powerups\\full-spectrum vision", 98.930, -157.614, -0.249 } -- Red Base (Corridor Portal)
FullSpectrumVision[6] = { "powerups\\full-spectrum vision", 95.688, -159.449, -0.100 } -- Red Base (Flag)
FullSpectrumVision[7] = { "powerups\\full-spectrum vision", 63.401, -177.553, 4.204 } -- Red Base (Banshee - Health Pack)
FullSpectrumVision[8] = { "powerups\\full-spectrum vision", 77.567, -131.422, -0.042 } -- Mid Field (Rocket Hog - Health Pack)
FullSpectrumVision[9] = { "powerups\\full-spectrum vision", 84.285, -128.007, 0.522 } -- Mid Field (Rock - the one that can only be entered with Rocket Hog)
FullSpectrumVision[10] = { "powerups\\full-spectrum vision", 120.872, -184.602, 6.512 } -- Fox Hill (Health Pack)
FullSpectrumVision[11] = { "powerups\\full-spectrum vision", 95.527, -97.516, 4.076 } -- Between the Caves (Health Pack infront of the rock that spawns you on-top of Pride Rock)
FullSpectrumVision[12] = { "powerups\\full-spectrum vision", 74.391, -77.651, 5.698 } -- Blue Base (Health Pack on ledge by the tunnel)
FullSpectrumVision[13] = { "powerups\\full-spectrum vision", 70.927, -61.647, 4.204 } -- Blue Base (Banshee - Health Pack)
FullSpectrumVision[14] = { "powerups\\full-spectrum vision", 48.532, -81.789, 0.114 } -- Blue Base (Rock that you can go inside of, in front of the Blue Base)
FullSpectrumVision[15] = { "powerups\\full-spectrum vision", 40.241, -79.123, -0.100 } -- Blue Base (Flag)
FullSpectrumVision[16] = { "powerups\\full-spectrum vision", 43.125, -78.434, -0.273 } -- Blue Base (The four Cabinet Portals)
FullSpectrumVision[17] = { "powerups\\full-spectrum vision", 43.112, -80.069, -0.278 }
FullSpectrumVision[18] = { "powerups\\full-spectrum vision", 37.080, -78.426, -0.238 }
FullSpectrumVision[19] = { "powerups\\full-spectrum vision", 37.105, -80.069, -0.255 }
FullSpectrumVision[20] = { "powerups\\full-spectrum vision", 43.548, -77.159, -0.286 } -- Blue Base (Corridor Portal)
FullSpectrumVision[21] = { "powerups\\full-spectrum vision", 48.046, -153.087, 21.181 } -- Mountain  overlooking the Red Base (Health Pack next to turret)
FullSpectrumVision[22] = { "powerups\\full-spectrum vision", 97.476, -188.912, 15.718 } -- Health pack on the opposite side of the turret (mountain overlooking red base)
FullSpectrumVision[23] = { "powerups\\full-spectrum vision", 111.995, -188.984, 14.651 }
FullSpectrumVision[24] = { "powerups\\full-spectrum vision", 120.906, -188.692, 13.771 }
FullSpectrumVision[25] = { "powerups\\full-spectrum vision", 129.211, -183.764, 17.222 }
FullSpectrumVision[26] = { "powerups\\full-spectrum vision", 131.785, -169.872, 15.951 }
FullSpectrumVision[27] = { "powerups\\full-spectrum vision", 128.141, -136.294, 14.547 }
FullSpectrumVision[28] = { "powerups\\full-spectrum vision", 118.263, -120.761, 17.192 }
FullSpectrumVision[29] = { "powerups\\full-spectrum vision", 116.826, -120.564, 15.109 }
FullSpectrumVision[30] = { "powerups\\full-spectrum vision", 102.011, -117.217, 14.792 }
FullSpectrumVision[31] = { "powerups\\full-spectrum vision", 101.180, -117.061, 14.780 }
FullSpectrumVision[32] = { "powerups\\full-spectrum vision", 90.741, -109.854, 14.751 }
FullSpectrumVision[33] = { "powerups\\full-spectrum vision", 89.496, -115.515, 17.028 }
-- FullSpectrumVision[34] = {"powerups\\full-spectrum vision", 94.333, -97.693, 4.984} -- This was the second Blue Box next to the rock between the caves. There is already one there so this one is now disabled.
FullSpectrumVision[35] = { "powerups\\full-spectrum vision", 12.928, -103.277, 13.990 }
FullSpectrumVision[36] = { "powerups\\full-spectrum vision", 21.916, -61.007, 16.189 }
FullSpectrumVision[37] = { "powerups\\full-spectrum vision", 43.258, -45.365, 20.901 }
FullSpectrumVision[38] = { "powerups\\full-spectrum vision", 78.907, -64.793, 19.836 }
FullSpectrumVision[39] = { "powerups\\full-spectrum vision", 82.459, -73.877, 15.729 }
FullSpectrumVision[40] = { "powerups\\full-spectrum vision", 83.719, -71.297, 16.723 }
FullSpectrumVision[41] = { "powerups\\full-spectrum vision", 98.376, -108.961, 4.327 } -- Edited (this is the cube inside the big cave by the ghost)
FullSpectrumVision[42] = { "powerups\\full-spectrum vision", 56.664, -164.837, 22.795 }
FullSpectrumVision[43] = { "powerups\\full-spectrum vision", 82.837, -114.570, 0.855 }
FullSpectrumVision[44] = { "powerups\\full-spectrum vision", 43.770, -126.267, 0.438 }
FullSpectrumVision[45] = { "powerups\\full-spectrum vision", 40.086, -83.177, 1.815 }
FullSpectrumVision[46] = { "powerups\\full-spectrum vision", 95.588, -155.458, 1.807 }
FullSpectrumVision[47] = { "powerups\\full-spectrum vision", 121.401, -154.189, 13.179 }
FullSpectrumVision[48] = { "powerups\\full-spectrum vision", 56.05, -159.44, 21.23 }
FullSpectrumVision[49] = { "powerups\\full-spectrum vision", 37.886, -79.222, -0.230 } -- New Portal inside blue base that takes you to the ramp.
FullSpectrumVision[50] = { "powerups\\full-spectrum vision", 97.761, -159.405, -0.169 } -- New portal inside the red base that takes you to the rock beside the enterence to the big cave
FullSpectrumVision[51] = { "powerups\\full-spectrum vision", 77.279, -89.107, 22.571 }
FullSpectrumVision[52] = { "powerups\\full-spectrum vision", 105.124, -110.929, 2.028 } -- New Cube inside the center cave (take you to the big cave)

function OnNewGame(map)
    for k, v in pairs(FullSpectrumVision) do
        local tag_id = gettagid("eqip", v[1])
        v[1] = tag_id
        v[5] = createobject(tag_id, 0, 999999, false, v[2], v[3], v[4])
        if getobject(v[5]) == nil then
            hprintf("E R R O R! Object Creation failed. Number: " .. k)
        end
    end
end

function OnScriptLoad(process, game, persistent)
    if game == true or game == "PC" then
        GAME = "PC"
        gametype_base = 0x671340
        map_name = readstring(0x698F21)
        gametype = readbyte(gametype_base + 0x30)
    end
end

function OnObjectInteraction(player, objId, mapId)
    local Pass = nil
    local name, type = gettaginfo(mapId)
    if type == "eqip" then
        if gametype == 1 or gametype == 3 then
            if name == "powerups\\full-spectrum vision" then
                Pass = false
            end
        end
        return Pass
    end
end