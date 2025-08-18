--[[
    ------------------------------------
    Description: OnLastMan (fixed function), Phasor V2+
    Copyright (c) 2016-2018
    * Author: Jericho Crosby
    * IGN: Chalwk
    * Written and Created by Jericho Crosby
    -----------------------------------
]]--
-- 		Called when last man exists
function OnLastMan()
    -- 		Lookup the last man
    for i = 0, 15 do
        if getplayer(i) then
            if getteam(i) == HUMAN_TEAM then
                cur_last_man = i
                -- 				Give the last man speed and extra ammo.
                setspeed(cur_last_man, tonumber(lastman_Speed))
                if getplayer(i) ~= nil then
                    local m_object = getobject(readdword(getplayer(i) + 0x34))
                    if m_object ~= nil then
                        if LastMan_Invulnerable ~= nil and LastMan_Invulnerable > 0 then
                            -- 							Setup the Invulnerable Timer
                            writebit(m_object + 0x10, 7, 1)
                            registertimer(LastMan_Invulnerable * 1000, "RemoveLastmanProtection", m_object)
                        end
                        -- 						Give all weapons 600 ammo
                        for x = 0, 3 do
                            -- 							Get the weapons memory address
                            local m_weaponId = readdword(m_object + 0x2F8 + (x * 4))
                            if m_weaponId ~= 0xffffffff then
                                if getobject(m_weaponId) ~= nil then
                                    -- 								Assign last Man his Ammo (See: LastManAmmoCount at the top of the script.)	
                                    writeword(getobject(m_weaponId) + 0x2B6, tonumber(LastManAmmoCount))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if cur_last_man ~= nil then
        say("**LAST MAN ALIVE**  " .. getname(cur_last_man) .. " is the last man alive and is invisible for 30 seconds!")
        GiveInvis = registertimer(1000, "ApplyCamoToLastMan", cur_last_man)
        -- (1000 = milliseconds)
        lastmanpoints_timer = registertimer(60000, "lastmanpoints", cur_last_man)
    end
end

function ApplyCamoToLastMan(player)
    if cur_last_man ~= nil then
        applycamo(cur_last_man, tonumber(Lastman_InvisTime))
    end
    for i = 0, 15 do
        if getplayer(i) then
            if getteam(i) == HUMAN_TEAM then
                cur_last_man = i
                if getplayer(i) ~= nil then
                    local m_object = getobject(readdword(getplayer(i) + 0x34))
                    if m_object ~= nil then
                        for x = 0, 3 do
                            local m_weaponId = readdword(m_object + 0x2F8 + (x * 4))
                            if m_weaponId ~= 0xffffffff then
                                if getobject(m_weaponId) ~= nil then
                                    writeword(getobject(m_weaponId) + 0x2B6, tonumber(LastManAmmoCount))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    GiveInvis = nil
end                