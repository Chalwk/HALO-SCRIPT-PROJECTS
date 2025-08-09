--[[
    ------------------------------------
    Description: HPC Death Deduction, Phasor V2+
    Copyright (c) 2016-2018
    * Author: Jericho Crosby
    * IGN: Chalwk
    * Written and Created by Jericho Crosby
    Script Version: 2.5
    -----------------------------------
]]--
-- Great for zombie games on HPC - Phasor V2+

ANNOUNCE_LEVEL_UP = " is now a human!"
local HUMAN_MESSAGE = "YOU ARE A HUMAN - KILL THE ZOMBIES!"
local Human_Speed = 1.2

function OnPlayerKill(killer, victim, mode)
    -- mode 0: 		Killed by server
    -- mode 1: 		Killed by fall damage
    -- mode 2: 		Killed by guardians
    -- mode 3: 		Killed by vehicle
    -- mode 4: 		Killed by killer
    -- mode 5: 		Betrayed by killer
    -- mode 6: 		Suicide
    if mode == 4 then
        -- mode 4: Killed by killer
        local kills = readword(getplayer(killer) + 0x96)
        --	Verify killer's team is ZOMBIE_TEAM
        if getteam(killer) == ZOMBIE_TEAM then
            if tonumber(kills) then
                if kills == 3 then
                    OnLevelUp(killer, kill)
                    --				Tell the server that this player has become a human
                    say(getname(killer) .. tostring(ANNOUNCE_LEVEL_UP))
                end
            end
        end
    end

    function OnLevelUp(killer, kill)
        if getteam(killer) == ZOMBIE_TEAM then
            --              Make them human...
            changeteam(killer, false)
            --              Send them the Human Message
            privatesay(killer, "*   " .. tostring(HUMAN_MESSAGE), false)
            kill(killer)
            --      This adds a death deduction so the player isn't charged a death for becoming a human.
            local m_player = getplayer(killer)
            local deaths = readword(getplayer(killer) + 0xAE)
            if tonumber(deaths) then
                -- 0 through 16 deaths - just repeat the structure as you wish.
                if deaths == 1 then
                    writeword(m_player + 0xAE, 0)
                elseif deaths == 2 then
                    writeword(m_player + 0xAE, 1)
                elseif deaths == 3 then
                    writeword(m_player + 0xAE, 2)
                elseif deaths == 4 then
                    writeword(m_player + 0xAE, 3)
                elseif deaths == 5 then
                    writeword(m_player + 0xAE, 4)
                elseif deaths == 6 then
                    writeword(m_player + 0xAE, 5)
                elseif deaths == 7 then
                    writeword(m_player + 0xAE, 6)
                elseif deaths == 8 then
                    writeword(m_player + 0xAE, 7)
                elseif deaths == 9 then
                    writeword(m_player + 0xAE, 8)
                elseif deaths == 10 then
                    writeword(m_player + 0xAE, 9)
                elseif deaths == 11 then
                    writeword(m_player + 0xAE, 10)
                elseif deaths == 12 then
                    writeword(m_player + 0xAE, 11)
                elseif deaths == 13 then
                    writeword(m_player + 0xAE, 12)
                elseif deaths == 14 then
                    writeword(m_player + 0xAE, 13)
                elseif deaths == 15 then
                    writeword(m_player + 0xAE, 14)
                elseif deaths == 16 then
                    writeword(m_player + 0xAE, 15)
                end
            end
            --              Set their speed to the default human speed (Speed when not infected)
            setspeed(killer, tonumber(Human_Speed))
        end
    end
end