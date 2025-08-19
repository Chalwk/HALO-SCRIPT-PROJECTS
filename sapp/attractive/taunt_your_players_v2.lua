--[[
=====================================================================================
SCRIPT NAME:      taunt_your_players_v2.lua
DESCRIPTION:      Sends humorous taunt messages to players when they die and
                  personalized remarks based on their kill count at game end.

FEATURES:
                  - Configurable death taunts (toggle on/off)
                  - Configurable end-game kill count remarks
                  - Customizable message alignment
                  - Random message selection from predefined lists

Copyright (c) 2019 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

api_version = "1.12.0.0"

local taunt = {}
local gsub = string.gsub

function taunt.Init()
    -- Configuration [starts] -----------------------------------------------------

    -- If "true", the script will send a taunt message to a player when they die.
    taunt.OnDeath = true

    -- Message Alignment Setting:
    -- Left = l, Right = r, Centre = c, Tab: t
    taunt.message_alignment = "|l"

    -- If true, the script will send a taunt message to the player.
    taunt.OnGameOver = true

    -- CUSTOM VARIABLE:
    -- Use "%victim%" (without the quotes) to output the victim's name.
    taunt.deathmessages = {
        " Aw, %victim%, I seen better shooting at the county fair!",
        " Ees too bad you got manure for brains!!",
        " Hell's full a' retired Gamers, %victim%, And it's time you join em!",
        " Hell! My horse pisses straighter than you shoot!!",
        " Can't you do better than that! I've seen worms move faster!",
        " Not good enough %victim%, not good enough!",
        " Hell - I can already smell your rotting corpse.",
        " Today is a good day to die %victim%!!",
        " Huh, too slow!! You will regret that!!",
        " You insult me, %victim%!!",
        " I'm going to send ya to an early grave!!",
        " Had enough yet?!",
        " Hope ya plant better than ya shoot!!",
        " Damn you and the horse you rode in on!!",
        " Time to fit you for a coffin!!",
        " You have a date with the undertaker!!",
        " Your life ends in the wasteland...",
        " Rest in peace, %victim%.",
        " You fought valiantly... but to no avail.",
        " You're dead. Again, %victim%!",
        " You're dead as a doornail.",
        " Time to reload, %victim%.",
        " Here's a picture of your corpse. Not pretty.",
        " Boy, are you stupid. And dead.",
        " Ha ha ha ha ha. You're dead, moron!",
        " Couldn't charm your way out of that one, %victim%.",
        " Nope. Just Nope.",
        " You have perished. What a Shame.",
        " Sell your PC. Just do it.",
        " You disappoint me, %victim%.",
    }

    -- CUSTOM VARIABLES:
    -- Use "%name%" to output the players name.
    -- Use "%kills%" to output the players kill count.
    taunt.gameover_messages = {

        -- The script will select and send one random message from this array,
        -- in respect to how many kills the player has.

        ["0"] = { -- No Kills
            "%name%, You have no kills. Noob alert!",

            -- You can have multiple entries per kill-threshold.
            -- Only one of these messages will be selected at random (per player)
            "You're not here to spectate, %name%! What were you doing?",
        },
        ["4"] = { -- 4 kills
            "%kills% kill? You must be new at this!!",
        },
        ["6"] = { -- 6 kills
            "You have sustained lethal injuries, but you do have %kills% kills!",
        },
        ["8"] = { -- 8 kills
            "Game Over - Why don't you try harder next time. %kills% Kills, really?",
        },
        ["10"] = { -- 10 kills
            "Pathetic, you're pathetic! %kills% Kills doesn't win you a gold medal, sir.",
        },
        -- Repeat the structure to add more entries.
    }

    -- Configuration [ends] -----------------------------------------------------
end

function OnScriptLoad()

    taunt.Init()

    -- Register needed Event Callbacks: 

    if (taunt.OnGameOver) then
        register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    end

    if (taunt.OnDeath) then
        register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    end
end

function OnScriptUnload()
    -- Not Used
end

-- Returns a random array element:
local function GetMessage(table)
    math.randomseed(os.time())
    math.random();
    math.random();
    math.random()
    return table[math.random(#table)]
end

function OnPlayerDeath(PlayerIndex, KillerIndex)

    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)

    -- Check if the player committed suicide:
    -- Returns false if they did and a taunt message wont be sent. 
    if (victim == killer) then
        return false

        -- Check if the player was killed by a vehicle (squashed & unoccupied):
        -- Returns false if they were and a taunt message wont be sent.
    elseif (killer == 0) then
        return false

        -- Check if the player was killed by the server:
        -- Returns false if they were and a taunt message wont be sent.
    elseif (killer == -1) then
        return false

        -- Check if the killer was Guardians or Unknown:
        -- Returns false if it was either of these and a taunt message wont be sent.
    elseif (killer == nil) then
        return false

        -- 1). Check if the killer is a valid player.
        -- 2). Send victim a random message from the taunt.deathmessages table:
    elseif (killer > 0) then
        local name = get_var(victim, "$name")
        local message = gsub(GetMessage(taunt.deathmessages), "%%victim%%", name)
        rprint(PlayerIndex, taunt.message_alignment .. " " .. message)
    end
end

function OnGameEnd()
    for i = 1, 16 do
        if player_present(i) then

            local kills = tonumber(get_var(i, "$kills"))

            for key, value in pairs(taunt.gameover_messages) do
                if (key) and (kills == tonumber(key)) then

                    local name = get_var(i, "$name")
                    local message = gsub(gsub(GetMessage(value), "%%name%%", name), "%%kills%%", kills)
                    rprint(i, taunt.message_alignment .. " " .. message)

                end
            end
        end
    end
end
