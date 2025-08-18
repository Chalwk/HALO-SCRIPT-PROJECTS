--[[
=====================================================================================
SCRIPT NAME:      taunt_your_players_v1.lua
DESCRIPTION:      Displays 1-30 random taunting messages to players on events:
                  OnGameEnd or OnPlayerDie.

Copyright (c) 2016-2018 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]


api_version = "1.12.0.0"

-- Script Settings
local tPrefix = "[TAUNT]"
-- If True, the script will send taunt messages to the victim.
local tauntsonDeath = true
-- If True, the script will send taunt messages to the player.
local tauntsOnGameEnd = true

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_DIE'], "OnPlayerDie")
end

function OnScriptUnload()
end

function OnPlayerDie(PlayerIndex, KillerIndex)
    local victimPlayer = tonumber(KillerIndex)
    if PlayerIndex == victimPlayer then
        return false
    elseif (victimPlayer == 0) then
        return false
    elseif (victimPlayer == -1) then
        return false
    elseif (PlayerIndex == nil) then
        return false

        -- We only want to display messages to the victim if he was killed
        -- by another player, not from suicides and vehicle deaths ect.
    elseif (victimPlayer > 0) and tauntsonDeath == true then
        local tauntMessages = {
            " Aw, " .. get_var(PlayerIndex, "$name") .. ", I seen better shooting at the county fair!",
            " Ees too bad you got manure for brains!!",
            " Hell's full a' retired Gamers, " .. get_var(PlayerIndex, "$name") .. ", And it's time you join em!",
            " Hell! My horse pisses straighter than you shoot!!",
            " Can't you do better than that! I've seen worms move faster!",
            " Not good enough " .. get_var(PlayerIndex, "$name") .. ", not good enough!",
            " Hell - I can already smell your rotting corpse.",
            " Today is a good day to die " .. get_var(PlayerIndex, "$name") .. "!!",
            " Huh, too slow!! You will regret that!!",
            " You insult me, " .. get_var(PlayerIndex, "$name") .. "!!",
            " I'm going to send ya to an early grave!!",
            " Had enough yet?!",
            " Hope ya plant better than ya shoot!!",
            " Damn you and the horse you rode in on!!",
            " Time to fit you for a coffin!!",
            " You have a date with the undertaker!!",
            " Your life ends in the wasteland...",
            " Rest in peace, " .. get_var(PlayerIndex, "$name") .. ".",
            " You fought valiantly... but to no avail.",
            " You're dead. Again, " .. get_var(PlayerIndex, "$name") .. "!",
            " You're dead as a doornail.",
            " Time to reload, " .. get_var(PlayerIndex, "$name") .. ".",
            " Here's a picture of your corpse. Not pretty.",
            " Boy, are you stupid. And dead.",
            " Ha ha ha ha ha. You're dead, moron!",
            " Couldn't charm your way out of that one, " .. get_var(PlayerIndex, "$name") .. ".",
            " Nope. Just Nope.",
            " You have perished. What a Shame.",
            " Sell your PC. Just do it.",
            " You disappoint me, " .. get_var(PlayerIndex, "$name") .. "."
        }
        -- Temporarily modify Server Prefix
        execute_command("msg_prefix " .. tPrefix)
        local tauntPlayer = GetRandomElement(tauntMessages)
        -- Send Taunt
        rprint(PlayerIndex, tauntPlayer)
        -- Restore Server Prefix
        execute_command("msg_prefix \"** SAPP ** \"")
    end
end

function OnGameEnd()
    if tauntsOnGameEnd == true then
        for i = 1, 16 do
            if player_present(i) then
                local kills = tonumber(get_var(i, "$kills"))
                -- Temporarily modify Server Prefix
                execute_command("msg_prefix " .. tPrefix)
                if (kills == 0) then
                    say(i, " You have no kills. Noob alert!")
                elseif (kills == 1) then
                    say(i, " One kill? You must be new at this!!")
                elseif (kills == 2) then
                    say(i, " You have sustained lethal injuries, but you do have 2 kills!")
                elseif (kills == 3) then
                    say(i, " Game Over - Why don't you try harder next time. 3 Kills, really?")
                elseif (kills == 4) then
                    say(i, " Pathetic, you're pathetic! 4 Kills doens't win you a gold medal, sir.")
                elseif (kills == 5) then
                    say_all(get_var(i, "$name") .. ": I ain't scared of you! Not one bit! No sir! Ha-Ha-Ha!!")
                elseif (kills == 6) then
                    say_all(get_var(i, "$name") .. ": Any last requests!? A dyin' man always has last requests!\n…And you just been tried, sentenced and condemned!\nYou lose!")
                elseif (kills == 7) then
                    say_all(get_var(i, "$name") .. ": Look I'm feeling generous today,\nI'm only gonna shoot out your brains - which shouldn't make much difference to you!")
                elseif (kills == 8) then
                    say_all(get_var(i, "$name") .. ": Don't be shy… You can shoot at me next time, I don't mind!")
                elseif (kills == 9) then
                    say_all(get_var(i, "$name") .. ": Is that really a gun in your hand or is it just wishful thinkin'!\nHa, ha, ha, ha, ha, ha, ha, ha, ha, ha!")
                elseif (kills == 10) then
                    say_all(get_var(i, "$name") .. ": Hey, why don't we just sit down and talk about this reasonably.\nHomicidal-maniac to crazed-vengeance- seeking-gamer.\nDo you really think you can beat me? Ha-Ha-Ha!")
                elseif (kills > 11) then
                    say_all(get_var(i, "$name") .. ": Well, well … now what is it my papa used to say?\nOh, yes, yes he used to say,\nSon! Life is wasted on the living!")
                end
            end
        end
    end
    -- Restore Server Prefix
    execute_command("msg_prefix \"** SAPP ** \"")
end

function GetRandomElement(a)
    return a[math.random(#a)]
end