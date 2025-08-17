--[[
------------------------------------
Script Name: HPC Zombies Stats Script, for PhasorV2+

Heavily Modified version by Jericho Crosby
* Credits to the original creator(s): SlimJim | Kennan

Copyright (c) 2016 Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE

* IGN: Chalwk

-----------------------------------
]]--

-- STRINGS --
local HUMAN_MESSAGE = "YOU ARE A HUMAN - KILL THE ZOMBIES!"
local ZOMBIE_MESSAGE = "YOU ARE A ZOMBIE - INFECT THE HUMANS!"
local TEAMKILL_MESSAGE = "Please do not betray your Team Mates!"
local ZOMBIEINVISIBLE_MESSAGE = "BEWARE: The zombies are now invisible for 30 seconds!"
local TIMER_TEAM_CHANGE_MESSAGE = "Thank you. The game will now continue"
local BLOCKTEAMCHANGE_MESSAGE = "Sorry. You're not allowed to change teams!"
local INFECTED_MESSAGE = " has been infected! WATCH OUT, YOU COULD BE NEXT!"
local ZOMBIEVEHICLE_MESSAGE = "Zombies are not allowed to use this type of vehicle!"
local HUMANVEHICLE_MESSAGE = "Humans are not allowed to use this type of vehicle!"
local REJOIN_MESSAGE = "Please don't leave and rejoin. You've been put back onto your last team."
local ANNOUNCE_LEVEL_UP = " is now a human!"
local KILLED_BY_GUARDIANS = " was killed by a mysterious force..."
local ZOMBIE_BACKTAP_MESSAGE = "Nice backtap!"
local HUMAN_BACKTAP_MESSAGE = "%s slaughtered you from behind."
-- =================================================================================================================================================================--
-- COUNTS --
local ZOMBIE_TEAM = 1                    -- 0 is Red, 1 is Blue.
local HUMAN_TEAM = 1 - ZOMBIE_TEAM
local Invis_Time = 2                    -- 		In seconds how long the zombies should be invisible when they crouch.
local ZOMBIES_INVIS_TIME = 30.00            -- 	All Zombies Invisible (in seconds)
local Human_Speed = 1.2                -- 	Speed when not infected.
local Zombie_Speed = 1.7                -- 		Zombie Speed.
local lastman_Speed = 1.5                -- 		Last Man Speed.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Reset_Speed = 1                    -- 		Resets their speed after receiving speed boost from picking up a 'doublespeed_id' or 'full_spec_id'.
local Speed_Powerup = 2                    -- 		Speed Quality - after picking up 'doublespeed_id' or 'full_spec_id'.
local Speed_Powerup_duration = 20            -- 	Speed when they pickup 'doublespeed_id' or 'full_spec_id'.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Zombie_Speed_Powerup_duration = (20)        -- (in seconds) - Speed when they pickup 'doublespeed_id' or 'full_spec_id'.
local Human_Speed_Powerup_duration = (15)        -- (in seconds) - Speed when they pickup 'doublespeed_id' or 'full_spec_id'.
local Reset_To_Zombie_Speed = 1.7            -- 		Resets their speed after receiving speed boost from picking up a 'doublespeed_id' or 'full_spec_id'.
local Reset_To_Human_Speed = 1.2            -- 		Resets their speed after receiving speed boost from picking up a 'doublespeed_id' or 'full_spec_id'.
local Zombie_Speed_Powerup = 2                -- 		Speed Quality - after picking up 'doublespeed_id' or 'full_spec_id'.
local Human_Speed_Powerup = 2                -- 		Speed Quality - after picking up 'doublespeed_id' or 'full_spec_id'.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Zombie_Count = 0.17                -- 		If value is less than 1 is it used as a percentage, more than or equal to one is absolute count.
local Zombie_Frag_Count = 1                -- 		Number of frag nades they spawn with.
local Zombie_Ammo_Count = 0                -- 		Backpack ammo.
local Zombie_Clip_Count = 0                -- 		Number of shots in clip for zombies once there are not only alpha zombies.
local Lastman_InvisTime = 30                -- 		In seconds.
local Zombie_Plasma_Count = 1                -- 		Number of plasma nades they spawn with.
local Minimum_Zombie_Count = 2                -- 		This caps what the zombie count would be w/ ratio (nil is disable).
local LastMan_Invulnerable = 5                -- 		Time (in seconds) the last man is invulnerable for: replace with nil to disable.
local AlphaZombie_Ammo_Count = 1            -- 		Backpack ammo.
local AlphaZombie_Frag_Count = 2            -- 		Number of frag nades they spawn with.
local AlphaZombie_Clip_Count = 50            -- 		Number of shots in clip.
local Max_Ticks_Between_Taps = 17
local AlphaZombie_Plasma_Count = 2            -- 		Number of plasma nades they spawn with.
local LastMan_DamageModifier = 1.8            -- 		Damage Modifier for the last man (on top of human damage).
local Zombie_DamageModifier = 5            -- 	Damage midifier for the last man (on top of human damage).
local LastManAmmoCount = 600                -- 		Ammo count for the last man's weapons.
local Max_Zombie_Count = 2                -- 		This caps what the zombie count would be w/ ratio (nil is disable)
local Max_Ticks_Before_Restart = 17
local Burst_Time = 1                    -- Speed Boost Duration (Zombies Only)
local Speed_Amount = 2.5                -- Speed Boost Amount
local Burst_Overheat = 1
local Human_ReSpawn_Time = 2.5                -- Spawn time for humans in seconds. Leave "default" for default spawn time.
local Zombie_ReSpawnTime = 2.5                -- Spawn time for zombies in seconds. Leave "default" for default spawn time.
-- Booleans --
local AnnounceRank = true                -- Announce Player Rank on Join?
local Infect_On_Fall = true                -- Infect player on fall?
local Infect_On_Suicide = true                -- Infect player on suicide?
local Allow_Speed_Boost = true                -- Allow / Disallow players to use their FlashLight for SpeedBoost.
local Infect_On_Betray = false                -- infect Player on Betray?
local Last_Man_Next_Zombie = true            -- 	If this value is true, then last man standing becomes the next zombie, if false then it's random.
local Infect_On_Guardians = false            -- Infect player on Guardians ?
local Broadcast_Zombies_Invisible = true        -- If the zombies are ALL made invisible, do you want the entire server to know?  true/false.
local Announce_Killed_By_Guardians = true        -- Only used if Infect_On_Guardians is false.
local Spawn_Where_Killed = false            -- If this is true, players will spawn where they were killed.
local Drop_PowerUp = false                -- If this is true, 'Drop Powerup on Death' will drop a powerup at the victims death location.
local Write_To_File = true                -- 		Write Game Stats to file?
local allow_player_invis = true            -- NOT USED
local HowMuch = 0.1                    -- (time in seconds))
-- ==========================================================================================--
-- Prefix Globals --
default_script_prefix = "" -- Can be anything you like. Default Prefix: **SERVER**
phasor_privatesay = privatesay
phasor_say = say
function say(message, script_prefix)
    if GAME == "PC" then
        phasor_say((script_prefix or default_script_prefix) .. " " .. message, false)
    else
        phasor_say(message, false)
    end
end

function privatesay(player, message, script_prefix)
    if GAME == "PC" then
        phasor_privatesay(player, (script_prefix or default_script_prefix) .. " " .. message, false)
    else
        phasor_privatesay(player, message, false)
    end
end

function Say(message, time, exception)
    time = time or 1
    for i = 0, 15 do
        if getplayer(i) and exception ~= i then
            privateSay(i, message, time)
        end
    end
end

function privateSay(player, message, time)
    local time = time or 3
    if message then
        sendconsoletext(player, message, time)
    end
end
-- =========================================================================================================================================================================
-- 	Do Not Modify unless you know what you're doing!
-- AllowThisPlayerInVehicle = false
local vehicleTag = nil
local cur_last_man = nil
game_started = false
allow_change = false
Change_Map = true
processid = 0
kill_count = 0
local cur_players = 0
local LAST_MAN_HASH = 0
local New_Game_Timer = 0
local cur_human_count = 0
local cur_zombie_count = 0
local alpha_zombie_count = 0
local player_change_timer = 0
local Current_Map = ""
ZOMBIE_VEHICLES = ""
HUMAN_VEHICLES = ""
HUMAN_VEHICLE_BLOCK = ""
ZOMBIE_VEHICLE_ALLOWED = ""
time = { }        -- Declare time. Used for player's time spent in server.
kills = { }
avenge = { }
warned = { }
killers = { }
xcoords = { }    -- Declare x coords. Used for distance traveled.
ycoords = { }    -- Declare y coords. Used for distance traveled.
zcoords = { }    -- Declare z coords. Used for distance traveled.
Forward = { }
messages = { }
jointime = { }    -- Declare Jointime. Used for a player's time spent in server.
hash_table = { }
Double_Tap = { }
last_damage = { }
OverHeating = { }
Player_Timer = { }
usedFlashlight = { }
First_TapTimeOut = { }
DoubleTap_TimeOut = { }
local KILL_COMMAND_COUNT = { }
local logging = true
local RED_ALLOW = false
local BLUE_ALLOW = true
players = { }        -- Spawn Where Killed
EQUIPMENT = { }        -- Drop PowerUp on Death
DEATH_LOCATION = { } -- For 'Spawn Where Killed' and 'Drop Powerup on Death'.
EQUIPMENT_TAGS = { }
EQUIPMENT[1] = { "powerups\\active camouflage" }
EQUIPMENT[2] = { "powerups\\health pack" }
EQUIPMENT[3] = { "powerups\\over shield" }
EQUIPMENT[4] = { "powerups\\assault rifle ammo\\assault rifle ammo" }
EQUIPMENT[5] = { "powerups\\needler ammo\\needler ammo" }
EQUIPMENT[6] = { "powerups\\pistol ammo\\pistol ammo" }
EQUIPMENT[7] = { "powerups\\rocket launcher ammo\\rocket launcher ammo" }
EQUIPMENT[8] = { "powerups\\shotgun ammo\\shotgun ammo" }
EQUIPMENT[9] = { "powerups\\sniper rifle ammo\\sniper rifle ammo" }
EQUIPMENT[10] = { "powerups\\flamethrower ammo\\flamethrower ammo" }
-- 	EQUIPMENT[11] 	= 	{"powerups\\double speed"}
-- 	EQUIPMENT[12] 	= 	{"powerups\\full-spectrum vision"}
ZOMBIE_WEAPON = { }
ZOMBIE_WEAPON[1] = "weapons\\ball\\ball" -- Primary weapon for zombies
ZOMBIE_WEAPON[2] = ""    -- Secondary weapon for zombies.
ZOMBIE_WEAPON[3] = ""    -- Tertiary weapon for zombies.
ZOMBIE_WEAPON[4] = ""    -- Quarternary weapon for zombies.
for i = 0, 15 do
    DEATH_LOCATION[i] = { }
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processId, game, persistent)
    profilepath = getprofilepath()
    local file = io.open(string.format("%s\\data\\auth_" .. tostring(process) .. ".key", profilepath), "r")
    if file then
        server_id = file:read("*line")
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            server_token = words[1]
            server_id = words[2]
        end
    else
        server_id = AuthorizeServer()
    end
    server_id = AuthorizeServer()
    GAME = game
    GetGameAddresses(game)
    if game == true or game == "PC" then
        GAME = "PC"
    else
        GAME = "CE"
    end
    if readbyte(gametype_base, 0x34) == 2 -- Slayer
            or readbyte(gametype_base, 0x34) == 3 -- Oddball
            or readbyte(gametype_base, 0x34) == 4 -- King of the Hill
            or readbyte(gametype_base, 0x34) == 5-- Race
    then
        registertimer(2300, "Terminate", {
            "=============================================================",
            "               ~~~~~~~~~~~~~~~~WARNING~~~~~~~~~~~~~~~~~",
            "               ~~~~~This script only supports CTF!~~~~~",
            "               ~~~~~~~~~~SCRIPT CANNOT BE USED~~~~~~~~~",
            "============================================================="
        })
    end
    processid = process
    Persistent = persistent
    profilepath = getprofilepath()
    logging = true
    OpenFiles()
    processid = processId
    Server_Name = getservername()
    game_started = true
    if game == "PC" then
        gametype_base = 0x671340
    elseif game == "CE" then
        gametype_base = 0x5F5498
    end
    if persistent == true then
        -- Script does not support persistence, therefore terminate.
        registertimer(2300, "Terminate", {
            "=============================================================",
            "        ~~~~~~~~~~~~~~~~~~~WARNING~~~~~~~~~~~~~~~~~~",
            "        ~~~~~~~PERSISTENCE MODE NOT SUPPORTED~~~~~~",
            "        ~~~~~~~~~~~~~SCRIPT CANNOT BE USED~~~~~~~~",
            "============================================================="
        })
    end
    if readstring(gametype_base, 0x2C) == "zombies_stats" then
        -- Verify game mode is setup correctly, else terminate...
    else
        registertimer(2300, "Terminate", {
            "=============================================================",
            "         ~~~~~~~~~~~~~~~~~~~WARNING~~~~~~~~~~~~~~~~",
            "         ~~~~~~~GAME MODE NOT SET UP CORRECTLY~~~~~~",
            "         ~~~~~~~~~~~~SCRIPT CANNOT BE USED~~~~~~~~~~",
            "Game Mode must be called 'zombies_stats' and the Game Type must be CTF!",
            "============================================================="
        })
    end
    -- 		Recalculate team counters.
    cur_zombie_count = getteamsize(ZOMBIE_TEAM)
    cur_human_count = getteamsize(HUMAN_TEAM)
    cur_players = cur_zombie_count + cur_human_count
    -- 		Recalculate how many "alpha" zombies there are.
    alpha_zombie_count = getalphacount()
    checkstance = registertimer(66, "CheckStance")
    registertimer(200, "CheckGameState", -1)
    -- 		load the last man hash (if there is one)
    local file = io.open("lasthash_" .. processid .. ".tmp", "r")
    if file ~= nil then
        LAST_MAN_HASH = file:read("*line")
        file:close()
        -- 		Delete the file...
        os.remove("lasthash_" .. processid .. ".tmp")
    end
    LoadTags()
    team_play = getteamplay()
    registertimer(200, "CheckGameState", -1)
end

function LogGameStats(filename, value)
    -- Stats Logging.
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%I:%M:%S%p  -  %A %d %Y")
            -- 12 hour clock
            -- 			%S 	Second (00-61)
            -- 			%t	Horizontal-tab character ('\t')
            -- 			%n	New-line character ('\n')
            local line = string.format("%s\t%s\n", timestamp, tostring(value))
            file:write(line)
            file:close()
        end
    end
end

function WriteLine(filename, value)
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%I:%M:%S%p  -  %A %d %Y")
            -- 12 hour clock
            -- 			%S 	Second (00-61)
            -- 			%t	Horizontal-tab character ('\t')
            -- 			%n	New-line character ('\n')
            local Line_0 = string.format("%s\t%s\n", timestamp, tostring(value))
            Line_break = " \n"
            Line_0 = (timestamp)
            Line_1 = "\n------------------------------------------------------------------------------------------------------------------------------------------------\n"
            Line_2 = "N E W  G A M E\n"
            Line_3 = "\n"
            file:write(Line_break, Line_0, Line_1, Line_2, Line_3)
            file:close()
        end
    end
end

function PrintPlayerRank(filename, value)
    -- Stats Logging.
    local file = io.open(filename, "a")
    if Write_To_File == true then
        if file then
            local timestamp = os.date("%I:%M:%S%p  -  %A %d %Y")
            -- 12 hour clock
            -- 			%S 	Second (00-61)
            -- 			%t	Horizontal-tab character ('\t')
            -- 			%n	New-line character ('\n')
            local line = string.format("%s\t%s\n", timestamp, tostring(value))
            file:write(line)
            file:close()
        end
    end
end

function Terminate(id, count, message)
    if message then
        for v = 1, #message do
            hprintf(message[v])
        end
    end
    svcmd("sv_end_game")
    return 0
end

function OnScriptUnload()
    writedword(ctf_score_patch, 0xFFFDE9E8)
    writebyte(ctf_score_patch1, 0xFF)
    writebyte(slayer_score_patch, 0x74)
    writebyte(slayer_score_patch2, 0x75)
    writedword(koth_score_patch, 0xDA850F)
    writebyte(koth_score_patch2, 0x75)
    table.save(sprees, "Sprees.txt")
    table.save(medals, "Medals.txt")
    table.save(stats, "Stats.txt")
end

function getteamplay()
    -- Confirmed. (Off = 0) (On = 1)
    if readbyte(gametype_base + 0x34) == 1 then
        return true
    else
        return false
    end
end

function OnNewGame(map)
    Current_Map = map
    LoadTags()
    team_play = getteamplay()
    map_name = tostring(map)
    SetVehicleSettings()
    -- 	Reset Variables
    cur_zombie_count = 0
    cur_human_count = 0
    cur_players = 0
    resptime = 5
    -- Game hasn't started yet. (Not until the timer counts down)
    game_started = false
    Rule_Timer = registertimer(1000, "RuleTimer")
    gametype = readbyte(gametype_base + 0x30, 0x0)
    New_Game_Timer = registertimer(1000, "CountdownToGameStart")
    registertimer(0, "CheckGameState", -1)
    WriteLine(profilepath .. "\\logs\\Zombies Game Stats.txt")
    -- Vehicles
    ghost_Map_ID = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_Map_ID = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_Map_ID = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_Map_ID = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_Map_ID = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_Map_ID = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    -- Vehicles
    Ghost_MapID = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    ChainGunHog_MapID = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    Scorpiontank_MapID = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    Banshee_MapID = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    Turret_MapID = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    RocketHog_Map_ID = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    for k, v in pairs(EQUIPMENT) do
        local tag_id = gettagid("eqip", v[1])
        table.insert(EQUIPMENT_TAGS, tag_id)
    end
    -- Equipment
    doublespeed_id = gettagid("eqip", "powerups\\double speed")
    full_spec_id = gettagid("eqip", "powerups\\full-spectrum vision")
    -- 	Map Name
    map_name = tostring(map)
end

function GetGameAddresses(game)
    if game == "PC" then
        map_pointer = 0x63525c
        ctf_globals = 0x639B98
        flag_respawn_addr = 0x488A7E
        gametype_base = 0x671340
        slayer_globals = 0x63A0E8
        team_koth_score_array = 0x639BD0

        ctf_score_patch = 0x488602
        ctf_score_patch1 = 0x488606

        slayer_score_patch = 0x48F428
        slayer_score_patch2 = 0x48F23E

        koth_score_patch = 0x48A798
        koth_score_patch2 = 0x48A76D
    else
        map_pointer = 0x5B927C
        ctf_globals = 0x5BDBB8
        flag_respawn_addr = 0x4638EE
        gametype_base = 0x5F5498
        slayer_globals = 0x5BE108
        team_koth_score_array = 0x5BDBF0

        ctf_score_patch = 0x463472
        ctf_score_patch1 = 0x463476

        slayer_score_patch = 0x469CF8
        slayer_score_patch2 = 0x4691CE

        koth_score_patch = 0x465458
        koth_score_patch2 = 0x46542D
    end
end

function AuthorizeServer()
    local file = io.open(string.format("%s\\data\\Authenticate.key", profilepath), "r")
    if file then
        value = file:read("*line")
        file:close()
    else
        registertimer(2000, "DelayTerminate", {
            "=============================================================",
            "~~~~~~~~~~~~WARNING~~~~~~~~~~~",
            "~~~~~~NO SERVER KEY FOUND~~~~~",
            "~~YOU CANNOT USE THIS SCRIPT~~",
            "============================================================="
        })
    end
    return value or "undefined"
end

function DelayTerminate(id, count, message)
    if message then
        for v = 1, #message do
            hprintf(message[v])
        end
    end
    svcmd("sv_end_game")
    return 0
end

function OnGameEnd(stage)
    -- stage 1: F1 Screen
    -- stage 2: PGCR Appears
    -- stage 3: Players may quit
    if stage == 2 then
        for i = 0, 15 do
            if readword(getplayer(i) + 0x9C) == 0 then
                privatesay(i, "You have no kills... noob alert!")
            end
            if readword(getplayer(i) + 0x9C) == 1 then
                privatesay(i, "One kill? You must be new at this...")
            end
            if readword(getplayer(i) + 0x9C) == 2 then
                privatesay(i, "Eh, two kills... not bad. But you still suck.")
            end
            if readword(getplayer(i) + 0x9C) == 3 then
                privatesay(i, "Relax sonny! 3 kills, and you be like... mad bro?")
            end
            if readword(getplayer(i) + 0x9C) == 4 then
                privatesay(i, "Dun dun dun... them 4 kills though!")
            end
            if readword(getplayer(i) + 0x9C) > 4 then
                privatesay(i, "Well, you've got more than 4 kills... #AchievingTheImpossible")
            end
        end
    end
    if stage == 1 then
        if New_Game_Timer then
            New_Game_Timer = nil
        end
        if lastmanpoints_timer then
            lastmanpoints_timer = nil
        end
        if credit_timer then
            credit_timer = nil
        end
        if Rule_Timer then
            Rule_Timer = nil
        end
        registertimer(10, "AssistDelay")
        for i = 0, 15 do
            if getplayer(i) then
                if getteam(i) == HUMAN_TEAM then
                    changescore(i, 50, plus)
                    SendMessage(i, "Awarded:    +50 cR - Survivor")
                    KillStats[gethash(i)].total.credits = KillStats[gethash(i)].total.credits + 50
                end
                if readword(getplayer(i) + 0xAE) < 3 then
                    -- Player Deaths
                    changescore(i, 15, plus)
                    SendMessage(i, "Awarded:    +15 cR - Less than 3 Deaths")
                    KillStats[gethash(i)].total.credits = KillStats[gethash(i)].total.credits + 15
                end
                extra[gethash(i)].woops.gamesplayed = extra[gethash(i)].woops.gamesplayed + 1
                time = os.time() - jointime[gethash(i)]
                extra[gethash(i)].woops.time = extra[gethash(i)].woops.time + time
            end
        end
    end
    if stage == 1 then
        table.save(KillStats, "KillStats.txt")
        table.save(extra, "Extra.txt")
        table.save(done, "CompletedMedals.txt")
    end
    if stage == 2 then
        table.save(sprees, "Sprees.txt")
    end
    if stage == 3 then
        table.save(stats, "Stats.txt")
        table.save(medals, "Medals.txt")
        table.save(extra, "Extra.txt")
    end
    if stage == 1 then
        if checkstance then
            checkstance = nil
        end
    end
    CheckGameState(-1)
    game_started = false
end

function OnServerChat(player, type, message)

    local Message = string.lower(message)
    local t = tokenizestring(Message, " ")
    local count = #t

    if player ~= nil then
        local hash = gethash(player)
        if Message == "@kill" then
            if getteam(player) ~= HUMAN_TEAM then
                if isplayerdead(player) == false then
                    if KILL_COMMAND_COUNT[hash] <= 5 then
                        KILL_COMMAND_COUNT[hash] = KILL_COMMAND_COUNT[hash] + 1
                        kill(player)
                        say(getname(player) .. " killed themselves")
                    else
                        privatesay(player, "Sorry, but you can only kill yourself 5 times in a match!")
                    end
                else
                    privatesay(player, "You are dead! You can not kill yourself!")
                end
            else
                privatesay(player, "You are a Human, you can not kill yourself!")
            end
            return false
        elseif Message == "@stuck" then
            sendconsoletext(player, "If you're stuck in the wall you can:")
            sendconsoletext(player, "1. Get out of your vehicle and walk!")
            sendconsoletext(player, "2. Type \"@kill\" and respawn again.")
            return false
        elseif Message == "@info" then
            privatesay(player, "\"@weapons\":  Will display stats for each weapon you've used..")
            privatesay(player, "\"@stats\":  Will display information about your kills, deaths etc.")
            privatesay(player, "\"@sprees\":  Will display info about your Killing Spreees.")
            privatesay(player, "\"@rank\":  Will display info about your Current Rank.")
            privatesay(player, "\"@medals\":  Will display info about your Medals.")
            privatesay(player, "\"@stuck\":  Find out how to get unstuck!")
            return false
        elseif Message == "@weapons" then
            -- =========================================================================================================================================================================
            privatesay(player, "Assault Rifle: " .. stats[hash].kills.assaultrifle .. " | Banshee: " .. stats[hash].kills.banshee .. " | Banshee Fuel Rod: " .. stats[hash].kills.bansheefuelrod .. " | Chain Hog: " .. stats[hash].kills.chainhog)
            privatesay(player, "EMP Blast: " .. extra[hash].woops.empblast .. " | Flame Thrower: " .. stats[hash].kills.flamethrower .. " | Frag Grenade: " .. stats[hash].kills.fragnade .. " | Fuel Rod: " .. stats[hash].kills.fuelrod)
            privatesay(player, "Ghost: " .. stats[hash].kills.ghost .. " | Melee: " .. stats[hash].kills.melee .. " | Needler: " .. stats[hash].kills.needler .. " | People Splattered: " .. stats[hash].kills.splatter)
            privatesay(player, "Pistol: " .. stats[hash].kills.pistol .. " | Plasma Grenade: " .. stats[hash].kills.plasmanade .. " | Plasma Pistol: " .. stats[hash].kills.plasmapistol .. " | Plasma Rifle: " .. stats[hash].kills.plasmarifle)
            privatesay(player, "Rocket Hog: " .. extra[hash].woops.rockethog .. " | Rocket Launcher: " .. stats[hash].kills.rocket .. " | Shotgun: " .. stats[hash].kills.shotgun .. " | Sniper Rifle: " .. stats[hash].kills.sniper)
            privatesay(player, "Stuck Grenade: " .. stats[hash].kills.grenadestuck .. " | Tank Machine Gun: " .. stats[hash].kills.tankmachinegun .. " | Tank Shell: " .. stats[hash].kills.tankshell .. " | Turret: " .. stats[hash].kills.turret)
            -- =========================================================================================================================================================================
            return false
        elseif Message == "@stats" then
            local PLAYER_KDR = ResolvePlayerKDR(player)
            local cpm = math.round(KillStats[hash].total.credits / extra[hash].woops.gamesplayed, 2)
            if cpm == 0 or cpm == nil then
                cpm = "No credits earned"
            end
            local days, hours, minutes, seconds = secondsToTime(extra[hash].woops.time, 4)
            -- =========================================================================================================================================================================
            privatesay(player, "Kills: " .. KillStats[hash].total.kills .. " | Deaths: " .. KillStats[hash].total.deaths .. " | Assists: " .. KillStats[hash].total.assists)
            privatesay(player, "KDR: " .. PLAYER_KDR .. " | Suicides: " .. KillStats[hash].total.suicides .. " | Betrays: " .. KillStats[hash].total.betrays)
            privatesay(player, "Games Played: " .. extra[hash].woops.gamesplayed .. " | Time in Server: " .. days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s")
            privatesay(player, "Distance Traveled: " .. math.round(extra[hash].woops.distance / 1000, 2) .. " kilometers | Credits Per Map: " .. cpm)
            -- =========================================================================================================================================================================
            return false
        elseif Message == "@sprees" then
            -- =========================================================================================================================================================================
            privatesay(player, "Double Kill: " .. sprees[hash].count.double .. " | Triple Kill: " .. sprees[hash].count.triple .. " | Overkill: " .. sprees[hash].count.overkill .. " | Killtacular: " .. sprees[hash].count.killtacular)
            privatesay(player, "Killtrocity: " .. sprees[hash].count.killtrocity .. " | Killimanjaro " .. sprees[hash].count.killimanjaro .. " | Killtastrophe: " .. sprees[hash].count.killtastrophe .. " | Killpocalypse: " .. sprees[hash].count.killpocalypse)
            privatesay(player, "Killionaire: " .. sprees[hash].count.killionaire .. " | Kiling Spree " .. sprees[hash].count.killingspree .. " | Killing Frenzy: " .. sprees[hash].count.killingfrenzy .. " | Running Riot: " .. sprees[hash].count.runningriot)
            privatesay(player, "Rampage: " .. sprees[hash].count.rampage .. " | Untouchable: " .. sprees[hash].count.untouchable .. " | Invincible: " .. sprees[hash].count.invincible .. " | Anomgstopkillingme: " .. sprees[hash].count.anomgstopkillingme)
            privatesay(player, "Unfrigginbelievable: " .. sprees[hash].count.unfrigginbelievable .. " | Minutes as Last Man Standing: " .. sprees[hash].count.timeaslms)
            -- =========================================================================================================================================================================
            return false
        elseif Message == "@rank" then
            local credits = { }
            for k, _ in pairs(KillStats) do
                table.insert(credits, { ["hash"] = k, ["credits"] = KillStats[k].total.credits })
            end

            table.sort(credits, function(a, b)
                return a.credits > b.credits
            end)

            for k, v in ipairs(credits) do
                if hash == credits[k].hash then
                    local UNTIL_NEXT_RANK = CreditsUntilNextPromo(player)
                    -- =========================================================================================================================================================================
                    privatesay(player, "You are ranked " .. k .. " out of " .. #credits .. "!")
                    privatesay(player, "Credits: " .. KillStats[hash].total.credits .. " | Rank: " .. KillStats[hash].total.rank)
                    privatesay(player, "Credits Until Next Rank: " .. UNTIL_NEXT_RANK)
                    -- =========================================================================================================================================================================
                end
            end
            return false
        elseif Message == "@medals" then
            -- =========================================================================================================================================================================
            privatesay(player, "Any Spree: " .. medals[hash].class.sprees .. " (" .. medals[hash].count.sprees .. ") | Assistant: " .. medals[hash].class.assists .. " (" .. medals[hash].count.assists .. ") | Close Quarters: " .. medals[hash].class.closequarters .. " (" .. medals[hash].count.assists .. ")")
            privatesay(player, "Crack Shot: " .. medals[hash].class.crackshot .. " (" .. medals[hash].count.crackshot .. ") | Downshift: " .. medals[hash].class.downshift .. " (" .. medals[hash].count.downshift .. ") | Grenadier: " .. medals[hash].class.grenadier .. " (" .. medals[hash].count.grenadier .. ")")
            privatesay(player, "Heavy Weapons: " .. medals[hash].class.heavyweapons .. " (" .. medals[hash].count.heavyweapons .. ") | Jack of all Trades: " .. medals[hash].class.jackofalltrades .. " (" .. medals[hash].count.jackofalltrades .. ") | Mobile Asset: " .. medals[hash].class.mobileasset .. " (" .. medals[hash].count.moblieasset .. ")")
            privatesay(player, "Multi Kill: " .. medals[hash].class.multikill .. " (" .. medals[hash].count.multikill .. ") | Sidearm: " .. medals[hash].class.sidearm .. " (" .. medals[hash].count.sidearm .. ") | Trigger Man: " .. medals[hash].class.triggerman .. " (" .. medals[hash].count.triggerman .. ")")
            -- =========================================================================================================================================================================
            return false
        elseif Message == "@vehicles" then
            privatesay(player, "Current Zombie Vehicles are: " .. tostring(ZOMBIE_VEHICLES)
            --[[ .. "\n" .. tostring(HUMAN_VEHICLES) ]]
            )
            return false
        end

        if t[1] == "@weapons" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rresolveplayer(rcon_id)
                    if Player then
                        local hash = gethash(Player)
                        if hash then
                            privatesay(player, getname(Player) .. "'s Weapon Stats")
                            privatesay(player, "Assault Rifle: " .. stats[hash].kills.assaultrifle .. " | Banshee: " .. stats[hash].kills.banshee .. " | Banshee Fuel Rod: " .. stats[hash].kills.bansheefuelrod .. " | Chain Hog: " .. stats[hash].kills.chainhog)
                            privatesay(player, "EMP Blast: " .. extra[hash].woops.empblast .. " | Flame Thrower: " .. stats[hash].kills.flamethrower .. " | Frag Grenade: " .. stats[hash].kills.fragnade .. " | Fuel Rod: " .. stats[hash].kills.fuelrod)
                            privatesay(player, "Ghost: " .. stats[hash].kills.ghost .. " | Melee: " .. stats[hash].kills.melee .. " | Needler: " .. stats[hash].kills.needler .. " | People Splattered: " .. stats[hash].kills.splatter)
                            privatesay(player, "Pistol: " .. stats[hash].kills.pistol .. " | Plasma Grenade: " .. stats[hash].kills.plasmanade .. " | Plasma Pistol: " .. stats[hash].kills.plasmapistol .. " | Plasma Rifle: " .. stats[hash].kills.plasmarifle)
                            privatesay(player, "Rocket Hog: " .. extra[hash].woops.rockethog .. " | Rocket Launcher: " .. stats[hash].kills.rocket .. " | Shotgun: " .. stats[hash].kills.shotgun .. " | Sniper Rifle: " .. stats[hash].kills.sniper)
                            privatesay(player, "Stuck Grenade: " .. stats[hash].kills.grenadestuck .. " | Tank Machine Gun: " .. stats[hash].kills.tankmachinegun .. " | Tank Shell: " .. stats[hash].kills.tankshell .. " | Turret: " .. stats[hash].kills.turret)
                            -- =========================================================================================================================================================================
                        else
                            privatesay(player, "Script Error! Please try again!")
                        end
                    else
                        privatesay(player, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    privatesay(player, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@stats" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rresolveplayer(rcon_id)
                    if Player then
                        local hash = gethash(Player)
                        if hash then
                            local PLAYER_KDR = ResolvePlayerKDR(Player)
                            local cpm = math.round(KillStats[hash].total.credits / extra[hash].woops.gamesplayed, 2)
                            if cpm == 0 or cpm == nil then
                                cpm = "No credits earned"
                            end
                            local days, hours, minutes, seconds = secondsToTime(extra[hash].woops.time, 4)
                            -- =========================================================================================================================================================================
                            privatesay(player, getname(Player) .. "'s Stats.")
                            privatesay(player, "Kills: " .. KillStats[hash].total.kills .. " | Deaths: " .. KillStats[hash].total.deaths .. " | Assists: " .. KillStats[hash].total.assists)
                            privatesay(player, "KDR: " .. PLAYER_KDR .. " | Suicides: " .. KillStats[hash].total.suicides .. " | Betrays: " .. KillStats[hash].total.betrays)
                            privatesay(player, "Games Played: " .. extra[hash].woops.gamesplayed .. " | Time in Server: " .. days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s")
                            privatesay(player, "Distance Traveled: " .. math.round(extra[hash].woops.distance / 1000, 2) .. " kilometers | Credits Per Map: " .. cpm)
                            -- =========================================================================================================================================================================
                        else
                            privatesay(player, "Script Error! Please try again!")
                        end
                    else
                        privatesay(player, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    privatesay(player, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@sprees" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rresolveplayer(rcon_id)
                    if Player then
                        local hash = gethash(Player)
                        if hash then
                            -- =========================================================================================================================================================================
                            privatesay(player, getname(Player) .. "'s Spree Stats.")
                            privatesay(player, "Double Kill: " .. sprees[hash].count.double .. " | Triple Kill: " .. sprees[hash].count.triple .. " | Overkill: " .. sprees[hash].count.overkill .. " | Killtacular: " .. sprees[hash].count.killtacular)
                            privatesay(player, "Killtrocity: " .. sprees[hash].count.killtrocity .. " | Killimanjaro " .. sprees[hash].count.killimanjaro .. " | Killtastrophe: " .. sprees[hash].count.killtastrophe .. " | Killpocalypse: " .. sprees[hash].count.killpocalypse)
                            privatesay(player, "Killionaire: " .. sprees[hash].count.killionaire .. " | Kiling Spree " .. sprees[hash].count.killingspree .. " | Killing Frenzy: " .. sprees[hash].count.killingfrenzy .. " | Running Riot: " .. sprees[hash].count.runningriot)
                            privatesay(player, "Rampage: " .. sprees[hash].count.rampage .. " | Untouchable: " .. sprees[hash].count.untouchable .. " | Invincible: " .. sprees[hash].count.invincible .. " | Anomgstopkillingme: " .. sprees[hash].count.anomgstopkillingme)
                            privatesay(player, "Unfrigginbelievable: " .. sprees[hash].count.unfrigginbelievable .. " | Minutes as Last Man Standing: " .. sprees[hash].count.timeaslms)
                            -- =========================================================================================================================================================================
                        else
                            privatesay(player, "Script Error! Please try again!")
                        end
                    else
                        privatesay(player, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    privatesay(player, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@rank" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rresolveplayer(rcon_id)
                    if Player then
                        local hash = gethash(Player)
                        if hash then
                            local credits = { }
                            for k, _ in pairs(KillStats) do
                                table.insert(credits, { ["hash"] = k, ["credits"] = KillStats[k].total.credits })
                            end

                            table.sort(credits, function(a, b)
                                return a.credits > b.credits
                            end)

                            for k, v in ipairs(credits) do
                                if hash == credits[k].hash then
                                    local UNTIL_NEXT_RANK = CreditsUntilNextPromo(Player)
                                    if UNTIL_NEXT_RANK == nil then
                                        UNTIL_NEXT_RANK = "Unknown - " .. getname(Player) .. " is a new player"
                                    end
                                    -- =========================================================================================================================================================================
                                    privatesay(player, getname(Player) .. " is ranked " .. k .. " out of " .. #credits .. "!")
                                    privatesay(player, "Credits: " .. KillStats[hash].total.credits .. " | Rank: " .. KillStats[hash].total.rank)
                                    privatesay(player, "Credits Until Next Rank: " .. UNTIL_NEXT_RANK)
                                    -- =========================================================================================================================================================================
                                end
                            end
                        else
                            privatesay(player, "Script Error! Please try again!")
                        end
                    else
                        privatesay(player, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    privatesay(player, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@medals" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rresolveplayer(rcon_id)
                    if Player then
                        local hash = gethash(Player)
                        if hash then
                            -- =========================================================================================================================================================================
                            privatesay(player, getname(Player) .. "'s Medal Stats.")
                            privatesay(player, "Any Spree: " .. medals[hash].class.sprees .. " (" .. medals[hash].count.sprees .. ") | Assistant: " .. medals[hash].class.assists .. " (" .. medals[hash].count.assists .. ") | Close Quarters: " .. medals[hash].class.closequarters .. " (" .. medals[hash].count.assists .. ")")
                            privatesay(player, "Crack Shot: " .. medals[hash].class.crackshot .. " (" .. medals[hash].count.crackshot .. ") | Downshift: " .. medals[hash].class.downshift .. " (" .. medals[hash].count.downshift .. ") | Grenadier: " .. medals[hash].class.grenadier .. " (" .. medals[hash].count.grenadier .. ")")
                            privatesay(player, "Heavy Weapons: " .. medals[hash].class.heavyweapons .. " (" .. medals[hash].count.heavyweapons .. ") | Jack of all Trades: " .. medals[hash].class.jackofalltrades .. " (" .. medals[hash].count.jackofalltrades .. ") | Mobile Asset: " .. medals[hash].class.mobileasset .. " (" .. medals[hash].count.moblieasset .. ")")
                            privatesay(player, "Multi Kill: " .. medals[hash].class.multikill .. " (" .. medals[hash].count.multikill .. ") | Sidearm: " .. medals[hash].class.sidearm .. " (" .. medals[hash].count.sidearm .. ") | Trigger Man: " .. medals[hash].class.triggerman .. " (" .. medals[hash].count.triggerman .. ")")
                            -- =========================================================================================================================================================================
                        else
                            privatesay(player, "Script Error! Please try again!")
                        end
                    else
                        privatesay(player, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    privatesay(player, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        end
    end
end

function OnServerCommand(admin, command)

    local size = tokenizecmdstring(command)
    local count = #size

    if count > 0 then
        local cmd = size[1]
        if cmd == "sv_switch" and count == 2 then
            local arg = size[2]
            local player = rresolveplayer(arg)
            local Phash = gethash(player)
            if Phash ~= nil then
                if getteam(player) == ZOMBIE_TEAM then
                    MakeHuman(player, true)
                    privatesay(player, "*   " .. HUMAN_MESSAGE, false)
                    -- hprintf(HUMAN_MESSAGE)
                elseif getteam(player) == HUMAN_TEAM then
                    MakeZombie(player, true)
                    privatesay(player, "*   " .. ZOMBIE_MESSAGE, false)
                    -- hprintf(ZOMBIE_MESSAGE)
                end
                respond("The player's team has been changed!")
            else
                respond("The specified player is not a valid player!")
            end
        end
    end
end

function OnPlayerJoin(player)

    DeclearNewPlayerStats(gethash(player))
    KILL_COMMAND_COUNT[gethash(player)] = 0
    credit_timer = registertimer(60000, "CreditTimer", player)
    -- Update the player counts
    cur_players = cur_players + 1
    GetMedalClasses(player)
    alpha_zombie_count = getalphacount()
    local alreadyExists = false
    GetPlayerRank(player)
    jointime[gethash(player)] = os.time()
    xcoords[gethash(player)] = readfloat(getplayer(player) + 0xF8)
    ycoords[gethash(player)] = readfloat(getplayer(player) + 0xFC)
    zcoords[gethash(player)] = readfloat(getplayer(player) + 0x100)
    -- 'SERVER_NAME' will print the name of the server as defined in the .init file, to the joining player.
    privatesay(player, "Welcome to " .. Server_Name)
    local thisTeamSize = 0
    killers[player] = { }
    if AnnounceRank == true then
        AnnouncePlayerRank(player)
    end

    if table.find(hash_table, gethash(player), false) then
        for k, v in pairs(hash_table) do
            if v ~= getteam(player) then
                changeteam(player, true)
            end
            privatesay(player, REJOIN_MESSAGE)
            alreadyExists = true
            break
        end
    end
    -- 	Add Team Entry for player Hash
    if alreadyExists == false then
        hash_table[gethash(player)] = getteam(player)
    end

    if game_started == true then
        -- 	Check if the player is a zombie.
        if getteam(player) == ZOMBIE_TEAM then
            -- 	We don't need to update the counters since they're already on the zombie team.
            MakeZombie(player, false)
            -- 		Send them the Zombie message.
            privatesay(player, "*   " .. ZOMBIE_MESSAGE, false)
        else
            -- 		If we're at last man, then make this player a zombie.
            if cur_last_man ~= nil then
                -- 			Make them a zombie...
                MakeZombie(player, true)
                -- 		Send them the Zombie message.				
                privatesay(player, "*   " .. ZOMBIE_MESSAGE, false)
            else
                -- 		 Make them a human...
                MakeHuman(player, false)
                -- 		Send them the Human message.	
                privatesay(player, "*   " .. HUMAN_MESSAGE, false)
            end
        end
        CheckGameState(-1)
        -- 	registertimer(200,"CheckGameState",-1)
    end

    if getteam(player) == ZOMBIE_TEAM then
        cur_zombie_count = cur_zombie_count + 1
        thisTeamSize = cur_zombie_count
    else
        cur_human_count = cur_human_count + 1
        thisTeamSize = cur_human_count
    end
end

function OnPlayerLeave(player)
    for i = 1, 3 do
        -- For 'Spawn Where Killed' and 'Drop Powerup on Death'.
        DEATH_LOCATION[player][i] = nil
    end
    -- 	Update Player Counts
    cur_players = cur_players - 1
    CheckGameState(-1)
    -- registertimer(1000,"CheckGameState",-1)
    hash_table[gethash(player)] = getteam(player)
    kills[gethash(player)] = 0
    extra[gethash(player)].woops.time = extra[gethash(player)].woops.time + os.time() - jointime[gethash(player)]

    if getteam(player) == ZOMBIE_TEAM then
        cur_zombie_count = cur_zombie_count - 1
    elseif getteam(player) == HUMAN_TEAM then
        cur_human_count = cur_human_count - 1
    end

    if cur_last_man == player then
        cur_last_man = nil
        registertimer(0, "CheckGameState", -1)
    end
end

function ADD_KILL(player)
    if getplayer(player) then
        local kills = players[player][2]
        players[player][2] = kills + 1
    end
end

function OnPlayerKill(killer, victim, mode)
    -- mode 0: Killed by server
    -- mode 1: Killed by fall damage
    -- mode 2: Killed by guardians
    -- mode 3: Killed by vehicle
    -- mode 4: Killed by killer
    -- mode 5: Betrayed by killer
    -- mode 6: Suicide
    -- =======================================================================================================================================================--
    -- Spawn Where Killed Settings (SWK)
    if mode == 4 then
        -- Killed by a player
        if Spawn_Where_Killed == true then
            ADD_KILL(killer)
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    elseif mode == 5 then
        if Spawn_Where_Killed == true then
            ADD_KILL(killer)
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    elseif mode == 6 then
        if Spawn_Where_Killed == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
        end
    end
    -- =======================================================================================================================================================--	
    -- Drop Powerup on Death Settings
    if mode == 4 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    elseif mode == 5 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    elseif mode == 6 then
        if Drop_PowerUp == true then
            local x, y, z = getobjectcoords(getplayerobjectid(victim))
            DEATH_LOCATION[victim][1] = x
            DEATH_LOCATION[victim][2] = y
            DEATH_LOCATION[victim][3] = z
            DropPowerup(x, y, z)
        end
    end
    -- =======================================================================================================================================================--
    -- Set Player Respawn: (Human_ReSpawn_Time), (Zombie_ReSpawnTime)
    if victim then
        if resptime then
            writedword(getplayer(victim) + 0x2c, resptime * 33)
        elseif tonumber(Human_ReSpawn_Time) and team ~= ZOMBIE_TEAM then
            writedword(getplayer(victim) + 0x2C, tonumber(Human_ReSpawn_Time) * 33)
        elseif tonumber(Zombie_ReSpawnTime) and team == ZOMBIE_TEAM then
            writedword(getplayer(victim) + 0x2C, tonumber(Zombie_ReSpawnTime) * 33)
        end
    end
    -- =======================================================================================================================================================--		
    if mode == 4 then
        registertimer(200, "CheckGameState", victim)
        local hash = gethash(killer)
        local vhash = gethash(victim)
        local m_player = getplayer(killer)
        local m_object = getobject(readdword(m_player + 0x34))
        -- ================================================================--	
        -- 				MAKE HUMAN function.
        -- I added a death deduction (see: OnLevelUp() ) so the human isn't charged a death for becoming a human.
        local kills = readword(getplayer(killer) + 0x9C)
        if getteam(killer) == ZOMBIE_TEAM then
            if tonumber(kills) then
                if kills == 3 then
                    OnLevelUp(killer, kill)
                    if getteam(victim) == HUMAN_TEAM then
                        MakeZombie(victim, false)
                    end
                    privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                    changescore(killer, 50, plus)
                    KillStats[gethash(killer)].total.deaths = KillStats[gethash(killer)].total.deaths - 1
                    say(getname(killer) .. ANNOUNCE_LEVEL_UP)
                    SendMessage(killer, "Awarded:    +50 cR - 3 kills as Zombie")
                end
            end
        end
        -- ================================================================--
        --[[

-- To Do: Make this Player Specific
--		Allow Player In ghost upon achieving 2 kills
		local kills = readword(getplayer(killer) + 0x98)
		local kills = readword(getplayer(killer) + 0x96)
		if getteam(killer) == ZOMBIE_TEAM then
			if tonumber(kills) then
				if kills == 1 then
				AllowThisPlayerInVehicle = true
				end
			end
		end
]]
        -- ================================================================--	
        -- Make Sure the game ends when the human has 50 kills.
        local kills = readword(getplayer(killer) + 0x9C)
        if getteam(killer) == HUMAN_TEAM then
            if tonumber(kills) then
                if kills == 50 then
                    svcmd("sv_mnext")
                end
            end
        end
        -- ================================================================--		
        -- 	Make sure this kill doesn't add to the score so that the game won't end prematurely
        -- if gametype == "Slayer" and killer and getplayer(killer) then writedword(slayer_globals + 0x40 + killer*4, 0) end
        if last_damage[vhash] then
            if string.find(last_damage[vhash], "melee") then
                medals[hash].count.closequarters = medals[hash].count.closequarters + 1
                stats[hash].kills.melee = stats[hash].kills.melee + 1
            elseif last_damage[vhash] == "globals\\vehicle_collision" then
                stats[hash].kills.splatter = stats[hash].kills.splatter + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\banshee\\mp_fuel rod explosion" then
                stats[hash].kills.bansheefuelrod = stats[hash].kills.bansheefuelrod + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\banshee\\banshee bolt" then
                stats[hash].kills.banshee = stats[hash].kills.banshee + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\c gun turret\\mp bolt" then
                stats[hash].kills.turret = stats[hash].kills.turret + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\ghost\\ghost bolt" then
                stats[hash].kills.ghost = stats[hash].kills.ghost + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\scorpion\\bullet" then
                stats[hash].kills.tankmachinegun = stats[hash].kills.tankmachinegun + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\scorpion\\shell explosion" then
                stats[hash].kills.tankshell = stats[hash].kills.tankshell + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "vehicles\\warthog\\bullet" then
                stats[hash].kills.chainhog = stats[hash].kills.chainhog + 1
                medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            elseif last_damage[vhash] == "weapons\\assault rifle\\bullet" then
                stats[hash].kills.assaultrifle = stats[hash].kills.assaultrifle + 1
                medals[hash].count.triggerman = medals[hash].count.triggerman + 1
            elseif last_damage[vhash] == "weapons\\flamethrower\\burning" or last_damage[vhash] == "weapons\\flamethrower\\explosion" or last_damage[vhash] == "weapons\\flamethrower\\impact damage" then
                medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                stats[hash].kills.flamethrower = stats[hash].kills.flamethrower + 1
            elseif last_damage[vhash] == "weapons\\frag grenade\\explosion" then
                medals[hash].count.grenadier = medals[hash].count.grenadier + 1
                stats[hash].kills.fragnade = stats[hash].kills.fragnade + 1
            elseif last_damage[vhash] == "weapons\\needler\\detonation damage" or last_damage[vhash] == "weapons\\needler\\explosion" or last_damage[vhash] == "weapons\\needler\\impact damage" then
                medals[hash].count.triggerman = medals[hash].count.triggerman + 1
                stats[hash].kills.needler = stats[hash].kills.needler + 1
            elseif last_damage[vhash] == "weapons\\pistol\\bullet" then
                stats[hash].kills.pistol = stats[hash].kills.pistol + 1
                medals[hash].count.sidearm = medals[hash].count.sidearm + 1
            elseif last_damage[vhash] == "weapons\\plasma grenade\\attached" then
                medals[hash].count.grenadier = medals[hash].count.grenadier + 1
                stats[hash].kills.grenadestuck = stats[hash].kills.grenadestuck + 1
            elseif last_damage[vhash] == "weapons\\plasma grenade\\explosion" then
                medals[hash].count.grenadier = medals[hash].count.grenadier + 1
                stats[hash].kills.plasmanade = stats[hash].kills.plasmanade + 1
            elseif last_damage[vhash] == "weapons\\plasma pistol\\bolt" then
                stats[hash].kills.plasmapistol = stats[hash].kills.plasmapistol + 1
                medals[hash].count.sidearm = medals[hash].count.sidearm + 1
            elseif last_damage[vhash] == "weapons\\plasma rifle\\charged bolt" then
                extra[hash].woops.empblast = extra[hash].woops.empblast + 1
                medals[hash].count.jackofalltrades = medals[hash].count.jackofalltrades + 1
                -- EMP Blast
            elseif last_damage[vhash] == "weapons\\plasma rifle\\bolt" then
                stats[hash].kills.plasmarifle = stats[hash].kills.plasmarifle + 1
                medals[hash].count.triggerman = medals[hash].count.triggerman + 1
            elseif last_damage[vhash] == "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion" or last_damage[vhash] == "weapons\\plasma_cannon\\impact damage" then
                medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                stats[hash].kills.fuelrod = stats[hash].kills.fuelrod + 1
            elseif last_damage[vhash] == "weapons\\rocket launcher\\explosion" then
                if m_object then
                    if readbyte(m_object + 0x2A0) == 1 then
                        -- obj_crouch
                        extra[hash].woops.rockethog = extra[hash].woops.rockethog + 1
                    else
                        medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                        stats[hash].kills.rocket = stats[hash].kills.rocket + 1
                    end
                else
                    medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                    stats[hash].kills.rocket = stats[hash].kills.rocket + 1
                end
            elseif last_damage[vhash] == "weapons\\shotgun\\pellet" then
                medals[hash].count.closequarters = medals[hash].count.closequarters + 1
                stats[hash].kills.shotgun = stats[hash].kills.shotgun + 1
            elseif last_damage[vhash] == "weapons\\sniper rifle\\sniper bullet" then
                medals[hash].count.crackshot = medals[hash].count.crackshot + 1
                stats[hash].kills.sniper = stats[hash].kills.sniper + 1
            elseif last_damage[vhash] == "backtap" then
                medals[hash].count.closequarters = medals[hash].count.closequarters + 1
                stats[hash].kills.melee = stats[hash].kills.melee + 1
            end
        end
    end

    if game_started == true then
        if mode == 0 then
            registertimer(200, "CheckGameState", victim)
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
        elseif mode == 1 then
            registertimer(200, "CheckGameState", victim)
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
            if Infect_On_Fall then
                if getteam(victim) == HUMAN_TEAM then
                    say("** INFECTED **    " .. getname(victim) .. INFECTED_MESSAGE)
                    say("** DEATH **   " .. getname(victim) .. " fell and perished!", false)
                    MakeZombie(victim, false)
                    privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                end
            end
        elseif mode == 2 then
            -- killed by guardians
            registertimer(200, "CheckGameState", victim)
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
            -- =======================================================================================================================================================--			
            if Announce_Killed_By_Guardians then
                say("**THE FORCE**  " .. getname(victim) .. KILLED_BY_GUARDIANS)
            end
            -- Only used if Infect_On_Guardians is false.
            if Infect_On_Guardians then
                -- Make Zombie if killed by Guardians.
                if getteam(victim) == HUMAN_TEAM or getteam(victim) == ZOMBIE_TEAM then
                    say("** INFECTED **    " .. getname(victim) .. INFECTED_MESSAGE)
                    MakeZombie(victim, false)
                    privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                end
            end
            -- =======================================================================================================================================================--			
        elseif mode == 3 then
            registertimer(200, "CheckGameState", victim)
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
        elseif mode == 4 then
            registertimer(200, "CheckGameState", victim)
            if table.find(killers[victim], killer, false) == nil then
                table.insert(killers[victim], killer)
            end
            KillStats[gethash(killer)].total.kills = KillStats[gethash(killer)].total.kills + 1
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
            if getteam(killer) == ZOMBIE_TEAM then
                say("** INFECTED **    " .. getname(victim) .. INFECTED_MESSAGE)
                MakeZombie(victim, false)
                privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                changescore(killer, 15, plus)
                SendMessage(killer, "Awarded:    +15 cR - Infection")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 15
                if victim == cur_last_man then
                    changescore(killer, 20, plus)
                    SendMessage(killer, "Awarded:    +20 cR - Last Man Standing Infection")
                    KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 20
                end
            else
                if cur_last_man == killer then
                    changescore(killer, 15, plus)
                    SendMessage(killer, "Awarded:    +15 cR - Last Man Standing Zombie Kill")
                    KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 15
                else
                    changescore(killer, 10, plus)
                    SendMessage(killer, "Awarded:    +10 cR - Zombie Kill")
                    KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
                end
            end

            if readword(getplayer(killer) + 0x9C) == 10 then
                changescore(killer, 5, plus)
                SendMessage(killer, "Awarded:    +5 cR - 10 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
            elseif readword(getplayer(killer) + 0x9C) == 20 then
                changescore(killer, 5, plus)
                SendMessage(killer, "Awarded:    +5 cR - 20 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
            elseif readword(getplayer(killer) + 0x9C) == 30 then
                changescore(killer, 5, plus)
                SendMessage(killer, "Awarded:    +5 cR - 30 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
            elseif readword(getplayer(killer) + 0x9C) == 40 then
                changescore(killer, 5, plus)
                SendMessage(killer, "Awarded:    +5 cR - 40 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
            elseif readword(getplayer(killer) + 0x9C) == 50 then
                changescore(killer, 10, plus)
                SendMessage(killer, "Awarded:    +10 cR - 50 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
            elseif readword(getplayer(killer) + 0x9C) == 60 then
                changescore(killer, 10, plus)
                SendMessage(killer, "Awarded:    +10 cR - 60 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
            elseif readword(getplayer(killer) + 0x9C) == 70 then
                changescore(killer, 10, plus)
                SendMessage(killer, "Awarded:    +10 cR - 70 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
            elseif readword(getplayer(killer) + 0x9C) == 80 then
                changescore(killer, 10, plus)
                SendMessage(killer, "Awarded:    +10 cR - 80 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
            elseif readword(getplayer(killer) + 0x9C) == 90 then
                changescore(killer, 10, plus)
                SendMessage(killer, "Awarded:    +10 cR - 90 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
            elseif readword(getplayer(killer) + 0x9C) == 100 then
                changescore(killer, 20, plus)
                SendMessage(killer, "Awarded:    +20 cR - 100 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 20
            elseif readword(getplayer(killer) + 0x9C) > 100 then
                changescore(killer, 5, plus)
                SendMessage(killer, "Awarded:    +5 cR - More then 100 Kills")
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
            end

            local hash = gethash(killer)
            if readword(getplayer(killer) + 0x98) == 2 then
                -- If Multi Kill is equal to 2 then
                SendMessage(killer, "Awarded:    +8 cR - Double Kill")
                changescore(killer, 8, plus)
                KillStats[hash].total.credits = KillStats[hash].total.credits + 8
                sprees[hash].count.double = sprees[hash].count.double + 1
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 3 then
                -- If Multi Kill is equal to 3 then
                SendMessage(killer, "Awarded:    +10 cR - Triple Kill")
                changescore(killer, 10, plus)
                sprees[hash].count.triple = sprees[hash].count.triple + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 10
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 4 then
                -- If Multi Kill is equal to 4 then
                SendMessage(killer, "Awarded:    +12 cR - Overkill")
                changescore(killer, 12, plus)
                sprees[hash].count.overkill = sprees[hash].count.overkill + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 12
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 5 then
                -- If Multi Kill is equal to 5 then
                SendMessage(killer, "Awarded:    +14 cR - Killtacular")
                changescore(killer, 14, plus)
                sprees[hash].count.killtacular = sprees[hash].count.killtacular + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 14
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 6 then
                -- If Multi Kill is equal to 6 then
                SendMessage(killer, "Awarded:    +16 cR - Killtrocity")
                changescore(killer, 16, plus)
                sprees[hash].count.killtrocity = sprees[hash].count.killtrocity + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 16
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 7 then
                -- If Multi Kill is equal to 7 then
                SendMessage(killer, "Awarded:    +18 cR - Killimanjaro")
                changescore(killer, 18, plus)
                sprees[hash].count.killimanjaro = sprees[hash].count.killimanjaro + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 18
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 8 then
                -- If Multi Kill is equal to 8 then
                SendMessage(killer, "Awarded:    +20 cR - Killtastrophe")
                changescore(killer, 20, plus)
                sprees[hash].count.killtastrophe = sprees[hash].count.killtastrophe + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 20
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) == 9 then
                -- If Multi Kill is equal to 9 then
                privatesay(killer, "Awarded:    +22 cR - Killpocalypse")
                changescore(killer, 22, plus)
                sprees[hash].count.killpocalypse = sprees[hash].count.killpocalypse + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 22
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif readword(getplayer(killer) + 0x98) >= 10 then
                -- If Multi Kill is equal to 10 or more then
                SendMessage(killer, "Awarded:    +25 cR - Killionaire")
                changescore(killer, 25, plus)
                sprees[hash].count.killionaire = sprees[hash].count.killionaire + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 25
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            end

            if readword(getplayer(killer) + 0x96) == 5 then
                -- If Killing Spree is 5 then
                SendMessage(killer, "Awarded:    +5 cR - Killing Spree")
                changescore(killer, 5, plus)
                sprees[hash].count.killingspree = sprees[hash].count.killingspree + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 5
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 10 then
                -- If Killing Spree is 10 then
                SendMessage(killer, "Awarded:    +10 cR - Killing Frenzy")
                changescore(killer, 10, plus)
                sprees[hash].count.killingfrenzy = sprees[hash].count.killingfrenzy + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 10
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 15 then
                -- If Killing Spree is 15 then
                SendMessage(killer, "Awarded:    +15 cR - Running Riot")
                changescore(killer, 15, plus)
                sprees[hash].count.runningriot = sprees[hash].count.runningriot + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 15
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 20 then
                -- If Killing Spree is 20 then
                SendMessage(killer, "Awarded:    +20 cR - Rampage")
                changescore(killer, 20, plus)
                sprees[hash].count.rampage = sprees[hash].count.rampage + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 20
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 25 then
                -- If Killing Spree is 25 then
                SendMessage(killer, "Awarded:    +25 cR - Untouchable")
                changescore(killer, 25, plus)
                sprees[hash].count.untouchable = sprees[hash].count.untouchable + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 25
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 30 then
                -- If Killing Spree is 30 then
                SendMessage(killer, "Awarded:    +30 cR - Invincible")
                changescore(killer, 30, plus)
                sprees[hash].count.invincible = sprees[hash].count.invincible + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 30
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif readword(getplayer(killer) + 0x96) == 35 then
                -- If Killing Spree is 35 then
                SendMessage(killer, "Awarded:    +35 cR - Anomgstopkillingme")
                changescore(killer, 35, plus)
                sprees[hash].count.anomgstopkillingme = sprees[hash].count.anomgstopkillingme + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 35
                medals[hash].count.sprees = medals[hash].count.sprees + 1
                -- 		elseif readword(getplayer(killer) + 0x96) >= 40 and spree%5 == 0 then -- If Killing Spree is 40 or more (Every 5 it will say this after 40) then
            elseif readword(getplayer(killer) + 0x96) >= 40 and sprees % 5 == 0 then
                -- If Killing Spree is 40 or more (Every 5 it will say this after 40) then
                SendMessage(killer, "Awarded:    +40 cR - Unfrigginbelievable")
                changescore(killer, 40, plus)
                sprees[hash].count.unfrigginbelievable = sprees[hash].count.unfrigginbelievable + 1
                KillStats[hash].total.credits = KillStats[hash].total.credits + 40
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            end
            -- 			Revenge		
            for k, v in pairs(killers[killer]) do
                if v == victim then
                    table.remove(killers[killer], k)
                    medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                    KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
                    SendMessage(killer, "Awarded:    +10 cR - Revenge")
                    changescore(killer, 10, plus)
                end
            end
            -- 			Killed from the Grave		
            if isplayerdead(killer) == true then
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
                SendMessage(killer, "Awarded:    +10 cR - Killed from the Grave")
                changescore(killer, 10, plus)
            end
            -- 			Downshift
            if getplayer(killer) then
                if killer ~= nil then
                    local objectid = getplayerobjectid(killer)
                    if objectid ~= nil then
                        local m_object = getobject(objectid)
                        local kvehicleid = readdword(m_object + 0x11C)
                        -- Fixed
                        local seat_index = readword(m_object + 0x2F0)
                        if kvehicleid ~= nil then
                            if seat_index == 1 or seat_index == 2 or seat_index == 3 or seat_index == 4 then
                                for i = 0, 15 do
                                    if getplayer(i) then
                                        local m_object = getobject(getplayerobjectid(i))
                                        local loopvehicleid = readdword(m_object + 0x11C)
                                        -- Fixed
                                        local seat_index = readword(m_object + 0x2F0)
                                        if kvehicleid == loopvehicleid then
                                            if seat_index == 0 then
                                                if getteam(killer) == getteam(i) then
                                                    medals[gethash(i)].count.downshift = medals[gethash(i)].count.downshift + 1
                                                    KillStats[gethash(i)].total.credits = KillStats[gethash(i)].total.credits + 5
                                                    SendMessage(i, "Awarded:    +5 cR - Downshift")
                                                    changescore(i, 5, plus)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            -- 			Avenger
            for i = 0, 15 do
                if getplayer(i) then
                    if i ~= victim then
                        if gethash(i) then
                            if getteam(i) == getteam(victim) then
                                avenge[gethash(i)] = gethash(killer)
                            end
                        end
                    end
                end
            end

            if avenge[gethash(killer)] == gethash(victim) then
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
                SendMessage(killer, "Awarded:    +5 cR - Avenger")
                changescore(killer, 5, plus)
            end

            -- 			Killjoy

            if killer then
                kills[gethash(killer)] = kills[gethash(killer)] or 1
            end

            if killer and victim then
                -- Works
                if kills[gethash(victim)] ~= nil then
                    if kills[gethash(victim)] >= 5 then
                        medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                        KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
                        SendMessage(killer, "Awarded:    +5 cR - Killjoy")
                        changescore(killer, 5, plus)
                    end
                end
            end
            kills[gethash(victim)] = 0

            -- 			Reload This
            local object = getplayerobjectid(victim)
            local m_object = getobject(object)
            local reloading = readbyte(m_object + 0x2A4)
            if reloading == 5 then
                SendMessage(killer, "Awarded:    +5 cR - Reload This!")
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 5
                changescore(killer, 5, plus)
            end
            -- 			First Strike
            kill_count = kill_count + 1

            if kill_count == 1 then
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
                SendMessage(killer, "Awarded:    +10 cR - First Strike")
                changescore(killer, 10, plus)
            end

            registertimer(10, "CloseCall", killer)
        elseif mode == 5 then
            registertimer(200, "CheckGameState", victim)
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
            KillStats[gethash(killer)].total.betrays = KillStats[gethash(killer)].total.betrays + 1
            privatesay(killer, TEAMKILL_MESSAGE)
            if Infect_On_Betray then
                if getteam(killer) == HUMAN_TEAM then
                    say("** INFECTED **    " .. getname(victim) .. INFECTED_MESSAGE)
                    MakeZombie(victim, false)
                    privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                end
            end
            -- =======================================================================================================================================================--			
        elseif mode == 6 then
            -- mode 6 == Suicide.
            KillStats[gethash(victim)].total.deaths = KillStats[gethash(victim)].total.deaths + 1
            KillStats[gethash(victim)].total.suicides = KillStats[gethash(victim)].total.suicides + 1
            registertimer(200, "CheckGameState", victim)
            if Infect_On_Suicide then
                if getteam(victim) == HUMAN_TEAM then
                    say("** INFECTED **    " .. getname(victim) .. INFECTED_MESSAGE)
                    MakeZombie(victim, false)
                    privatesay(victim, "*   " .. ZOMBIE_MESSAGE, false)
                end
            end
            -- =======================================================================================================================================================--			
            if mode == 4 then
                GetPlayerRank(killer)
                registertimer(10, "LevelUp", killer)
            end
        end
    end
    registertimer(200, "CheckGameState", victim)
end

function DropPowerup(x, y, z)
    local num = getrandomnumber(1, #EQUIPMENT_TAGS)
    createobject(EQUIPMENT_TAGS[num], 0, 10, false, x, y, z + 0.5)
end

function ApplySpeed(player)
    if player then
        -- 	Retrieve player's team.
        if getteam(player) == ZOMBIE_TEAM then
            -- 	Give player speed. (User defined at the the top of the script: Zombie_Speed_Powerup)
            setspeed(player, tonumber(Zombie_Speed_Powerup))
            -- 		How long the speed lasts, then reset after "Zombie_Speed_Powerup_duration" is met.
            registertimer(Zombie_Speed_Powerup_duration * 1000, "ResetSpeed", player)
            privatesay(player, "Speed Powerup!")
            -- 	Retrieve player's team.	
        elseif getteam(player) == HUMAN_TEAM then
            -- 	Give player speed. (User defined at the the top of the script: Human_Speed_Powerup)
            setspeed(player, tonumber(Human_Speed_Powerup))
            -- 		How long the speed lasts, then reset after "Human_Speed_Powerup_duration" is met.
            registertimer(Human_Speed_Powerup_duration * 1000, "ResetSpeed", player)
            privatesay(player, "Speed Powerup!")
        end
    end
end

function ResetSpeed(id, count, player)
    if getteam(player) == ZOMBIE_TEAM then
        setspeed(player, tonumber(Reset_To_Zombie_Speed))
        privatesay(player, "Speed Reset!")
    elseif getteam(player) == HUMAN_TEAM then
        setspeed(player, tonumber(Reset_To_Human_Speed))
        privatesay(player, "Speed Reset!")
    end
    return 0
end

function OnPlayerSpawn(player)
    -- =======================================================================================================================================================--
    if getplayer(player) then
        -- For 'Spawn Where Killed'.
        if Spawn_Where_Killed == true then
            if DEATH_LOCATION[player][1] ~= nil and DEATH_LOCATION[player][2] ~= nil then
                movobjectcoords(getplayerobjectid(player), DEATH_LOCATION[player][1], DEATH_LOCATION[player][2], DEATH_LOCATION[player][3])
                for i = 1, 3 do
                    DEATH_LOCATION[player][i] = nil
                end
            end
        end
    end
    -- =======================================================================================================================================================--
    -- =================================================--
    -- For 'Drop Powerup on Death'.
    if getplayer(player) then
        for i = 1, 3 do
            DEATH_LOCATION[player][i] = nil
        end
    end
    -- =================================================--
    usedFlashlight[player] = false
    if getteam(player) == ZOMBIE_TEAM and game_started == true then
        local m_objectId = getplayerobjectid(player)
        local m_object = getobject(m_objectId)
        if m_object ~= nil then
            writebyte(m_object + 0x31E, Zombie_Frag_Count)
            writebyte(m_object + 0x31F, Zombie_Plasma_Count)
            local clipcount = AlphaZombie_Clip_Count
            local ammocount = AlphaZombie_Ammo_Count
            if cur_zombie_count > alpha_zombie_count then
                clipcount = Zombie_Clip_Count
                ammocount = Zombie_Ammo_Count
            else
                writebyte(m_object + 0x31E, AlphaZombie_Frag_Count)
                writebyte(m_object + 0x31F, AlphaZombie_Plasma_Count)
            end

            for i = 0, 3 do
                local m_weaponId = readdword(m_object + 0x2F8 + (i * 4))
                if m_weaponId ~= 0xffffffff then
                    local m_weapon = getobject(m_weaponId)
                    if m_weapon ~= nil then
                        writeword(m_weapon + 0x2B6, ammocount)
                        writeword(m_weapon + 0x2B8, clipcount)
                        updateammo(m_weaponId)
                    end
                end
            end
        end
    end
end

function destroyweapons(player)
    for i = 0, 3 do
        -- loop through the player's weapons (primary to quartenary)
        local m_weaponId = getweaponobjectid(player, i)
        if m_weaponId ~= 0xFFFFFFFF then
            destroyobject(m_weaponId)
        end
    end
end

function OnPlayerSpawnEnd(player, m_objectId)
    if getteam(player) == ZOMBIE_TEAM then
        setspeed(player, tonumber(Zombie_Speed))
    else
        setspeed(player, tonumber(Human_Speed))
    end

    if player == cur_last_man then
        setspeed(player, tonumber(lastman_Speed))
    end

    if getteam(player) == ZOMBIE_TEAM then
        DestroyGuns(m_objectId)
        local hrand = math.random(0, 3)
        local crand = math.random(0, 2)

        -- 	Do Not Touch!
        if hrand == 0 then
            htag = "weapons\\assault rifle\\assault rifle"
        elseif hrand == 1 then
            htag = "weapons\\pistol\\pistol"
        elseif hrand == 2 then
            htag = "weapons\\shotgun\\shotgun"
        elseif hrand == 3 then
            htag = "weapons\\shotgun\\shotgun"
            if gethash(player) == "6c8f0bc306e0108b4904812110185edd" and string.find(map_name, "bloodgulch") then
                htag = "weapons\\shotgun\\shotgun"
            end
        end

        if crand == 0 then
            ctag = "weapons\\plasma rifle\\plasma rifle"
        elseif crand == 1 then
            ctag = "weapons\\plasma pistol\\plasma pistol"
        elseif crand == 2 then
            ctag = "weapons\\needler\\mp_needler"
        end

        local hgun = createobject(gettagid("weap", htag), 0, 1, false, 0, 0, 0)
        local cgun = createobject(gettagid("weap", ctag), 0, 1, false, 0, 0, 0)
        if getobject(hgun) and getobject(cgun) then
            assignweapon(player, cgun)
            assignweapon(player, hgun)
        end

        local m_object = getobject(getplayerobjectid(player))
        if m_object then
            for i = 0, 3 do
                local m_weaponId = readdword(m_object + 0x2F8 + i * 4)
                local m_weapon = getobject(m_weaponId)
                if m_weapon then
                    writeword(m_weapon + 0x2B6, 0)
                    writeword(m_weapon + 0x2B8, 0)
                    writefloat(m_weapon + 0x240, math.abs(0 - 1))
                    updateammo(m_weaponId)
                end
            end
        end
    end
end

function DelayDestroyObject(id, count, objId)
    if objId then
        destroyobject(objId)
    end
    return 0
end

function OnObjectInteraction(player, objId, mapId)
    -- ===============================================================================--
    -- Drop Powerup on Death
    for i = 0, #EQUIPMENT_TAGS do
        if mapId == EQUIPMENT_TAGS[i] then
            if mapId == doublespeed_id or mapId == full_spec_id then
                registertimer(500, "DelayDestroyObject", objId)
                if mapId == full_spec_id then
                    ApplySpeed(player)
                else
                end
                return 0
            end
            return 1
        end
    end
    -- ===============================================================================--	
    local tagName, tagType = gettaginfo(mapId)
    if game_started == true then
        if tagType == "weap" then
            if tagName == "weapons\\flag\\flag" then
                return false
                -- Blocks the Flag.
            end
        end
        if getteam(player) == ZOMBIE_TEAM then
            if tagType == "weap" then
                return false
            elseif tagType == "eqip" then
                if tagName == "weapons\\frag grenade\\frag grenade" or tagName == "weapons\\plasma grenade\\plasma grenade" then
                    return false
                elseif tagName == "powerups\\active camouflage" then
                    if isplayerinvis(player) == false then
                        if getrandomnumber(1, 11) > 6 then
                            for i = 0, 15 do
                                if getplayer(i) and getteam(i) == ZOMBIE_TEAM then
                                    applycamo(i, tonumber(ZOMBIES_INVIS_TIME))
                                end
                            end
                            if Broadcast_Zombies_Invisible == true then
                                say(ZOMBIEINVISIBLE_MESSAGE)
                                hprintf(ZOMBIEINVISIBLE_MESSAGE)
                            end
                        end
                    end
                end
            end
        end
    end
    return true
end

function OnTeamDecision(team)
    local dest_team = ZOMBIE_TEAM
    if game_started == true then
        if cur_players == 0 then
            dest_team = HUMAN_TEAM
        elseif cur_zombie_count > 0 and cur_human_count == 0 then
            dest_team = HUMAN_TEAM
        end
    end
    return dest_team
end

function OnTeamChange(player, old_team, new_team, relevant)
    local name = getname(player)
    local player_team = getteam(player)
    if team_play then
        if player_team == 0 then
            player_team = "Blue Team"
        elseif player_team == 1 then
            player_team = "Red Team"
        end
    end
    if relevant == 1 or relevant == true then
        if not allow_change then
            privatesay(player, "*   " .. BLOCKTEAMCHANGE_MESSAGE)
            -- 		hprintf("SERVER TO:    " ..name.. ": " .. BLOCKTEAMCHANGE_MESSAGE .. "\nThey're trying to switch to " ..player_team)
        elseif new_team == ZOMBIE_TEAM then
            changeteam(player, true)
        end
        return false
    elseif new_team ~= old_team then
        if new_team == ZOMBIE_TEAM then
            cur_human_count = cur_human_count - 1
            cur_zombie_count = cur_zombie_count + 1
        elseif new_team == HUMAN_TEAM then
            cur_human_count = cur_human_count + 1
            cur_zombie_count = cur_zombie_count - 1
        end
        if allow_change == true and new_team == ZOMBIE_TEAM then
            allow_change = false
            removetimer(player_change_timer)
            player_change_timer = 0
            say("*   " .. TIMER_TEAM_CHANGE_MESSAGE)
            -- hprintf(TIMER_TEAM_CHANGE_MESSAGE)
        end
        if game_started == true then
            if new_team == ZOMBIE_TEAM then
                MakeZombie(player, false)
            elseif new_team == HUMAN_TEAM then
                MakeHuman(player, false)
            end
            CheckGameState(player)
            registertimer(200, "CheckGameState", player)
        end
        hash_table[gethash(player)] = new_team
    end
    registertimer(200, "CheckGameState", -1)
    return true
end

function OnDamageLookup(receiver, causer, mapId)

    local tagname, tagtype = gettaginfo(mapId)
    if causer ~= nil then
        if getobject(causer) then
            local cplayer = objectaddrtoplayer(causer)
        else
            local cplayer = nil
        end
    end
    if string.find(tagname, "melee") then
        odl_multiplier(1000)
    end
    if cplayer ~= nil then
        if getteam(cplayer) ~= nil then
            if getteam(cplayer) == HUMAN_TEAM then
                local modifier = 1.0
                if cur_last_man ~= nil then
                    modifier = LastMan_DamageModifier
                end
                odl_multiplier(modifier)
            end
        end
    end
    ------------------------------------------------------------------------------
    if string.find(tagname, "melee") then
        odl_multiplier(5000)
    end
    if cplayer ~= nil then
        if getteam(cplayer) ~= nil then
            if getteam(cplayer) == ZOMBIE_TEAM then
                local modifier = 1.0
                if cplayer ~= nil then
                    modifier = Zombie_DamageModifier
                end
                odl_multiplier(modifier)
            end
        end
    end
    ------------------------------------------------------------------------------
end

function OnDamageApplication(receiving, causing, tagid, hit, backtap)
    if backtap and causing and receiving then
        local causer = objectidtoplayer(causing)
        local receiver = objectidtoplayer(receiving)
        if causer and receiver then
            if getteam(causer) == ZOMBIE_TEAM and getteam(receiver) == HUMAN_TEAM then
                privatesay(causer, ZOMBIE_BACKTAP_MESSAGE)
                privatesay(receiver, string.format(HUMAN_BACKTAP_MESSAGE, getname(causer)))
            end
        end
    end
    if receiving then
        local r_object = getobject(receiving)
        if r_object then
            local receiver = objectaddrtoplayer(r_object)
            if receiver then
                if not backtap then
                    local tagname, tagtype = gettaginfo(tagid)
                    last_damage[gethash(receiver)] = tagname
                else
                    last_damage[gethash(receiver)] = "melee"
                end
            end
        end
    end
end

function LoadTags()
    --   for i = 1,4 do
    --    	if ZOMBIE_WEAPON[i] == "weapons\\ball\\ball" or ZOMBIE_WEAPON[i] == "weapons\\flag\\flag" then
    -- 		oddball_or_flag = gettagid("weap", ZOMBIE_WEAPON[i])
    -- 	end
    -- end
    -- Weapons
    oddball_tag_id = gettagid("weap", "weapons\\ball\\ball")
    flag_tag_id = gettagid("weap", "weapons\\flag\\flag")
    -- Vehicles
    ghost_Map_ID = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    hog_Map_ID = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    tank_Map_ID = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    banshee_Map_ID = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_Map_ID = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    rhog_Map_ID = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    -- Vehicles
    Ghost_MapID = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    ChainGunHog_MapID = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    Scorpiontank_MapID = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    Banshee_MapID = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    Turret_MapID = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    RocketHog_Map_ID = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    -------------------------------------------------------------------------------------------
    --  Additional Tags for a project I am working on, for a Custom Map for PC
    cyb_tag_id = gettagid("bipd", "revolution\\biped\\cyborg")
    cyborg_tag_id = gettagid("bipd", "characters\\cyborg_mp\\cyborg_mp")
    captain_tag_id = gettagid("bipd", "characters\\captain\\captain")
    cortana_tag_id = gettagid("bipd", "characters\\cortana\\cortana")
    cortana2_tag_id = gettagid("bipd", "characters\\cortana\\halo_enhanced\\halo_enhanced")
    crewman_tag_id = gettagid("bipd", "characters\\crewman\\crewman")
    elite_tag_id = gettagid("bipd", "characters\\elite\\elite")
    elite2_tag_id = gettagid("bipd", "characters\\elite\\elite special")
    engineer_tag_id = gettagid("bipd", "characters\\engineer\\engineer")
    flood_tag_id = gettagid("bipd", "characters\\flood_captain\\flood_captain")
    flood2_tag_id = gettagid("bipd", "characters\\flood_infection\\flood_infection")

    -- Equipment --
    camouflage_tag_id = gettagid("eqip", "powerups\\active camouflage")
    healthpack_tag_id = gettagid("eqip", "powerups\\health pack")
    overshield_tag_id = gettagid("eqip", "powerups\\over shield")
    doublespeed_tag_id = gettagid("eqip", "powerups\\double speed")
    fullspec_tag_id = gettagid("eqip", "powerups\\full-spectrum vision")
    fragnade_tag_id = gettagid("eqip", "weapons\\frag grenade\\frag grenade")
    plasmanade_tag_id = gettagid("eqip", "weapons\\plasma grenade\\plasma grenade")
    rifleammo_tag_id = gettagid("eqip", "powerups\\assault rifle ammo\\assault rifle ammo")
    needlerammo_tag_id = gettagid("eqip", "powerups\\needler ammo\\needler ammo")
    pistolammo_tag_id = gettagid("eqip", "powerups\\pistol ammo\\pistol ammo")
    rocketammo_tag_id = gettagid("eqip", "powerups\\rocket launcher ammo\\rocket launcher ammo")
    shotgunammo_tag_id = gettagid("eqip", "powerups\\shotgun ammo\\shotgun ammo")
    sniperammo_tag_id = gettagid("eqip", "powerups\\sniper rifle ammo\\sniper rifle ammo")
    flameammo_tag_id = gettagid("eqip", "powerups\\flamethrower ammo\\flamethrower ammo")

    -- Vehicles --
    banshee_tag_id = gettagid("vehi", "vehicles\\banshee\\banshee_mp")
    turret_tag_id = gettagid("vehi", "vehicles\\c gun turret\\c gun turret_mp")
    ghost_tag_id = gettagid("vehi", "vehicles\\ghost\\ghost_mp")
    rwarthog_tag_id = gettagid("vehi", "vehicles\\rwarthog\\rwarthog")
    scorpion_tag_id = gettagid("vehi", "vehicles\\scorpion\\scorpion_mp")
    warthog_tag_id = gettagid("vehi", "vehicles\\warthog\\mp_warthog")
    wraith_tag_id = gettagid("vehi", "vehicles\\wraith\\wraith")
    pelican_tag_id = gettagid("vehi", "vehicles\\pelican\\pelican")
    yohog_tag_id = gettagid("vehi", "vehicles\\yohog\\yohog")
    fhog_tag_id = gettagid("vehi", "vehicles\\fwarthog\\fwarthog")

    -- Weapons --
    assaultrifle_tag_id = gettagid("weap", "weapons\\assault rifle\\assault rifle")
    oddball_tag_id = gettagid("weap", "weapons\\ball\\ball")
    flag_tag_id = gettagid("weap", "weapons\\flag\\flag")
    flamethrower_tag_id = gettagid("weap", "weapons\\flamethrower\\flamethrower")
    gravityrifle_tag_id = gettagid("weap", "weapons\\gravity rifle\\gravity rifle")
    needler_tag_id = gettagid("weap", "weapons\\needler\\mp_needler")
    pistol_tag_id = gettagid("weap", "weapons\\pistol\\pistol")
    plasmapistol_tag_id = gettagid("weap", "weapons\\plasma pistol\\plasma pistol")
    plasmarifle_tag_id = gettagid("weap", "weapons\\plasma rifle\\plasma rifle")
    plasmacannon_tag_id = gettagid("weap", "weapons\\plasma_cannon\\plasma_cannon")
    rocketlauncher_tag_id = gettagid("weap", "weapons\\rocket launcher\\rocket launcher")
    shotgun_tag_id = gettagid("weap", "weapons\\shotgun\\shotgun")
    sniper_tag_id = gettagid("weap", "weapons\\sniper rifle\\sniper rifle")
    energysword_tag_id = gettagid("weap", "weapons\\energy sword\\energy sword")
    carbine_tag_id = gettagid("weap", "revolution\\weapons\\carbine\\carbine")
    revsniper_tag_id = gettagid("weap", "revolution\\weapons\\sniper\\revolution sniper")
    covspiker_tag_id = gettagid("weap", "cmt\\weapons\\covenant\\spiker\\spiker")
    covplasmarifle_tag_id = gettagid("weap", "cmt\\weapons\\covenant\\brute_plasma_rifle\\brute plasma rifle")
    covpp_tag_id = gettagid("weap", "cmt\\weapons\\covenant\\brute_plasma_pistol\\brute plasma pistol")
    covsmg_tag_id = gettagid("weap", "cmt\\weapons\\human\\smg\\silenced smg")
    covbr_tag_id = gettagid("weap", "cmt\\weapons\\human\\battle_rifle\\battle_rifle_specops")

    -- Projectiles --
    bansheebolt_tag_id = gettagid("proj", "vehicles\\banshee\\banshee bolt")
    bansheeblast_tag_id = gettagid("proj", "vehicles\\banshee\\mp_banshee fuel rod")
    turretfire_tag_id = gettagid("proj", "vehicles\\c gun turret\\mp gun turret")
    ghostbolt_tag_id = gettagid("proj", "vehicles\\ghost\\ghost bolt")
    tankshot_tag_id = gettagid("proj", "vehicles\\scorpion\\bullet")
    tankblast_tag_id = gettagid("proj", "vehicles\\scorpion\\tank shell")
    warthogshot_tag_id = gettagid("proj", "vehicles\\warthog\\bullet")
    rifleshot_tag_id = gettagid("proj", "weapons\\assault rifle\\bullet")
    flame_tag_id = gettagid("proj", "weapons\\flamethrower\\flame")
    needlerfire_tag_id = gettagid("proj", "weapons\\needler\\mp_needle")
    pistolshot_tag_id = gettagid("proj", "weapons\\pistol\\bullet")
    plasmapistolbolt_tag_id = gettagid("proj", "weapons\\plasma pistol\\bolt")
    plasmariflebolt_tag_id = gettagid("proj", "weapons\\plasma rifle\\bolt")
    plasmarifleblast_tag_id = gettagid("proj", "weapons\\plasma rifle\\charged bolt")
    plasmacannonshot_tag_id = gettagid("proj", "weapons\\plasma_cannon\\plasma_cannon")
    rocket_tag_id = gettagid("proj", "weapons\\rocket launcher\\rocket")
    shotgunshot_tag_id = gettagid("proj", "weapons\\shotgun\\pellet")
    snipershot_tag_id = gettagid("proj", "weapons\\sniper rifle\\sniper bullet")
end

function OnVehicleEntry(player, vehiId, seat, mapId, relevant)
    local name = getname(player)
    local tagname, tagtype = gettaginfo(mapId)
    if game_started == true and relevant == true then
        if getteam(player) == ZOMBIE_TEAM then
            if isoktoenter("zombies", tagname) == false then
                privatesay(player, "*   " .. ZOMBIEVEHICLE_MESSAGE)
                return false
                -- NOT COMPLETED
                -- 		elseif isoktoenter("zombies", tagname) == true and AllowThisPlayerInVehicle == true then say("SUCCESS SUCCESS SUCCESS")	
            elseif isoktoenter("zombies", tagname) == true then
                return true
            end
        elseif getteam(player) == HUMAN_TEAM then
            if isoktoenter("humans", tagname) == false then
                privatesay(player, "*   " .. HUMANVEHICLE_MESSAGE)
                return false
            elseif isoktoenter("humans", tagname) == true then
                return true
            end
        end
    end
end

function isoktoenter(team, tagname)
    local allow = nil
    if team == "zombies" then
        if string.find(tostring(ZOMBIE_VEHICLE_ALLOWED), tagname) then
            allow = true
        else
            allow = false
        end
        --[[		
-- NOT COMPLETED
	elseif team == "zombies" then
		if string.find(tostring(ALLOW_PLAYER_IN_VEHICLE_UPON_LEVELUP), tagname) then
			allow = true
		else
			allow = false
		end
--]]
    elseif team == "humans" then
        if string.find(tostring(HUMAN_VEHICLE_BLOCK), tagname) then
            allow = false
        else
            allow = true
        end
    end
    return allow
end

function InSphere(m_objectId, X, Y, Z, R)
    local Pass = false
    if getobject(m_objectId) then
        local x, y, z = getobjectcoords(m_objectId)
        if (X - x) ^ 2 + (Y - y) ^ 2 + (Z - z) ^ 2 <= R then
            Pass = true
        end
    end
    return Pass
end

function CheckStance(id, count)
    for i = 0, 15 do
        if getplayer(i) then
            local m_objectId = getplayerobjectid(i)
            if m_objectId then
                if readbit(getobject(m_objectId) + 0x208, 0) and not isinvehicle(i) then
                    OnPlayerCrouch(i)
                elseif readbyte(getobject(m_objectId) + 0x2A0) == 4 then
                    OnPlayerStand(i)
                end
            end
        end
    end
    return true
end

function OnPlayerCrouch(player)
    if getplayer(player) then
        local team = getteam(player)
        local m_objectId = getplayerobjectid(player)
        if m_objectId then
            if readdword(getobject(m_objectId) + 0x204) == 0x41 then
                if (team == 0 and RED_ALLOW) or (team == 1 and BLUE_ALLOW) then
                    applycamo(player, tonumber(Invis_Time))
                end
            end
        end
    end
end

function OnPlayerStand(player)
    if getplayer(player) then
        local team = getteam(player)
        local m_objectId = getplayerobjectid(player)
        if m_objectId then
            if readdword(getobject(m_objectId) + 0x204) == 0x51 then
                if (team == 0 and RED_ALLOW) or (team == 1 and BLUE_ALLOW) then
                    applycamo(player, 0.1)
                end
            end
        end
    end
end
-- ==============================================================================================================--
function burstOverheat(id, count, player)
    OverHeating[player] = nil
    Forward[player] = true
    Double_Tap[player] = 6
    return false
end

function removeSpeed(id, count, player)
    local m_player = getplayer(player)
    if m_player then
        -- Change the player's speed
        setspeed(player, tonumber(Zombie_Speed))
    end
    Double_Tap[player] = 4
    return false
end
-- ==============================================================================================================--
function OnClientUpdate(player)
    -----------------------------------------------------------------------------------
    -- Invis on Crouch - NOT USED - Managed elsewhere.
    -- if allow_player_invis = true then
    -- 	if readbyte(m_object + 0x2A0) == 3 then
    -- 		if getteam(player) == ZOMBIE_TEAM then
    -- 			applycamo(player, tonumber(HowMuch))
    -- 		end
    -- 	end
    -- 	else respond("Oh oh! Something went wrong!")
    -- end
    -----------------------------------------------------------------------------------
    -- Speed Boost Start
    if getteam(player) == ZOMBIE_TEAM and Allow_Speed_Boost then
        local m_player = getplayer(player)
        if m_player then
            local m_objectId = getplayerobjectid(player)
            if m_objectId and m_objectId ~= 0xFFFFFFFF then
                local m_object = getobject(m_objectId)
                if m_object then
                    local forward = readfloat(m_object + 0x278)
                    if forward == 1 and not Double_Tap[player] and not OverHeating[player] then
                        Double_Tap[player] = 1
                        First_TapTimeOut[player] = 0
                    elseif forward ~= 1 and forward ~= 0 and not OverHeating[player] and Double_Tap[player] and Double_Tap[player] <= 2 then
                        Double_Tap[player] = 7
                    elseif forward == 0 and Double_Tap[player] == 1 then
                        Double_Tap[player] = 2
                        DoubleTap_TimeOut[player] = 0
                    elseif forward == 1 and Double_Tap[player] == 2 then
                        Double_Tap[player] = 3
                        DoubleTap_TimeOut[player] = nil
                        First_TapTimeOut[player] = nil
                        setspeed(player, tonumber(Speed_Amount))
                        Player_Timer[player] = registertimer(Burst_Time * 1000, "removeSpeed", player)
                    elseif forward == 0 and Double_Tap[player] == 3 and not OverHeating[player] then
                        removetimer(Player_Timer[player])
                        Player_Timer[player] = nil
                        setspeed(player, tonumber(Zombie_Speed))
                        OverHeating[player] = registertimer(Burst_Overheat * 1000, "burstOverheat", player)
                    elseif Double_Tap[player] == 4 and not OverHeating[player] then
                        Double_Tap[player] = 5
                        setspeed(player, tonumber(Zombie_Speed))
                        OverHeating[player] = registertimer(Burst_Overheat * 1000, "burstOverheat", player)
                    elseif Double_Tap[player] == 6 then
                        Double_Tap[player] = 7
                    elseif Double_Tap[player] == 7 and forward == 0 then
                        Double_Tap[player] = nil
                    end
                    if DoubleTap_TimeOut[player] then
                        if DoubleTap_TimeOut[player] >= Max_Ticks_Between_Taps then
                            Double_Tap[player] = nil
                            DoubleTap_TimeOut[player] = nil
                        else
                            DoubleTap_TimeOut[player] = DoubleTap_TimeOut[player] + 1
                        end
                    end
                    if First_TapTimeOut[player] then
                        if First_TapTimeOut[player] >= Max_Ticks_Before_Restart then
                            First_TapTimeOut[player] = nil
                            Double_Tap[player] = 7
                        else
                            First_TapTimeOut[player] = First_TapTimeOut[player] + 1
                        end
                    end
                end
            end
        end
    end
    -- Speed Boost End
    -----------------------------------------------------------------------------------
    -- ==============================================================================================================--
    -- ==============================================================================================================--
    --[[
    local m_objectId = getplayerobjectid(player)
    if m_objectId == nil then return end
	local m_object = getobject(m_objectId)
	local team = getteam(player)
	if Current_Map == "bloodgulch" then
		if getteam(player) == HUMAN_TEAM or getteam(player) == ZOMBIE_TEAM then
		if InSphere(m_objectId, 80.96, -149.33, 3.1, 4) or InSphere(m_objectId, 39.21, -96.36, 1.76, 4) then
			sendconsoletext(player, "You have been moved by the server: This area is out of bounds.")
			say(getname(player) .. " was teleported by the server because they were in a forbidden area on the map.", false)
			movobjectcoords(m_objectId, 39.263, -79.115, -0.100)	
		elseif InSphere(m_objectId, 92.38, -93.65, 9.33, 6) then
			sendconsoletext(player, "You have been moved by the server: This area is out of bounds.")
			say(getname(player) .. " was teleported by the server because they were in a forbidden area on the map.", false)
			movobjectcoords(m_objectId, 39.263, -79.115, -0.100)	
			end
		end
	end]]
    AwardPlayerMedals(player)
    if getplayerobjectid(player) then
        local x, y, z = getobjectcoords(getplayerobjectid(player))
        if xcoords[gethash(player)] then
            local x_dist = x - xcoords[gethash(player)]
            local y_dist = y - ycoords[gethash(player)]
            local z_dist = z - zcoords[gethash(player)]
            local dist = math.sqrt(x_dist ^ 2 + y_dist ^ 2 + z_dist ^ 2)
            extra[gethash(player)].woops.distance = extra[gethash(player)].woops.distance + dist
        end
        xcoords[gethash(player)] = x
        ycoords[gethash(player)] = y
        zcoords[gethash(player)] = z
    end
end
-- 1).	Banshee: 			vehicles\\banshee\\banshee_mp
-- 2). 	Ghost: 				vehicles\\ghost\\ghost_mp
-- 3). 	Rocket Hog: 		vehicles\\rwarthog\\rwarthog
-- 4). 	Warthog: 			vehicles\\warthog\\mp_warthog
-- 5). 	Tank: 				vehicles\\scorpion\\scorpion_mp
-- 6). 	Turret: 			vehicles\\c gun turret\\c gun turret_mp
-- 	vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp
function SetVehicleSettings()
    if map_name == "bloodgulch" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            -- 		ALLOW_PLAYER_IN_VEHICLE_UPON_LEVELUP = "vehicles\\ghost\\ghost_mp"
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
            HUMAN_VEHICLES = ""
        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        end
    elseif map_name == "dangercanyon" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            -- 		ALLOW_PLAYER_IN_VEHICLE_UPON_LEVELUP = "vehicles\\ghost\\ghost_mp"
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        end
    elseif map_name == "deathisland" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        end
    elseif map_name == "hangemhigh" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "icefields" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "infinity" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "sidewinder" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "timberland" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "boardingaction" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "gephyrophobia" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "ratrace" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "carousel" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        elseif readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "beavercreek" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"

        end
    elseif map_name == "damnation" then
        if readstring(gametype_base, 0x2C) == "zombies_stats" then
            ZOMBIE_VEHICLE_ALLOWED = "vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog"
            HUMAN_VEHICLE_BLOCK = "vehicles\\banshee\\banshee_mp | vehicles\\ghost\\ghost_mp | vehicles\\rwarthog\\rwarthog | vehicles\\warthog\\mp_warthog | vehicles\\scorpion\\scorpion_mp | vehicles\\c gun turret\\c gun turret_mp"
            ZOMBIE_VEHICLES = "Rocket Hogs and Chain Gun Hogs!"
        end
    end
end

function table.save(t, filename)

    local dir = getprofilepath()
    local file = io.open(dir .. "\\data\\" .. filename, "w")
    local spaces = 0

    local function tab()

        local str = ""
        for i = 1, spaces do
            str = str .. " "
        end

        return str
    end

    local function format(t)

        spaces = spaces + 4
        local str = "{ "

        for k, v in opairs(t) do
            if type(k) == "string" then
                k = string.format("%q", k)
            elseif k == math.inf then
                k = "1 / 0"
            end

            if type(v) == "string" then
                v = string.format("%q", v)
            elseif v == math.inf then
                v = "1 / 0"
            end

            if type(v) == "table" then
                if table.len(v) > 0 then
                    str = str .. "\n" .. tab() .. "[" .. k .. "] = " .. format(v) .. ","
                else
                    str = str .. "\n" .. tab() .. "[" .. k .. "] = {},"
                end
            else
                str = str .. "\n" .. tab() .. "[" .. k .. "] = " .. tostring(v) .. ","
            end
        end

        spaces = spaces - 4

        return string.sub(str, 1, string.len(str) - 1) .. "\n" .. tab() .. "}"
    end

    file:write("return " .. format(t))
    file:close()
end

function opairs(t)

    local keys = { }
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys,
            function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                end
                an = string.lower(tostring(a))
                bn = string.lower(tostring(b))
                if an ~= bn then
                    return an < bn
                else
                    return tostring(a) < tostring(b)
                end
            end)
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function table.load(filename)

    local dir = getprofilepath()
    local file = loadfile(dir .. "\\data\\" .. filename)
    if file then
        return file() or { }
    end

    return { }
end

function table.len(t)

    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end

    return count
end

function adjustedtimestamp()
    local strMonth = os.date("%m")
    local strYear = os.date("%Y")
    local strMin = os.date("%M")
    local strSec = os.date("%S")
    local intDay = tonumber(os.date("%d"))
    local intHour = tonumber(os.date("%H"))
    if intHour < 7 then
        local intDiff = 7 - intHour
        intHour = 24 - intDiff
        intDay = intDay - 1
    elseif intHour >= 7 then
        intHour = intHour - 7
    end
    local strMonthFinal = string.format("%02.0f", strMonth)
    local strYearFinal = string.format("%04.0f", strYear)
    local strMinFinal = string.format("%02.0f", strMin)
    local strSecFinal = string.format("%02.0f", strSec)
    local intDayFinal = string.format("%02.0f", intDay)
    local intHourFinal = string.format("%02.0f", intHour)
    local temp = "[" .. strMonthFinal .. "/" .. intDayFinal .. "/" .. strYearFinal .. " " .. intHourFinal .. ":" .. strMinFinal .. ":" .. strSecFinal .. "]"
    local timestamp = tostring(temp)
    return timestamp
end

function isplayerdead(player)

    local m_objectId = getplayerobjectid(player)
    if m_objectId then
        local m_object = getobject(m_objectId)
        if m_object then
            return false
        else
            return true
        end
    end
end

function isplayerinvis(player)

    if player ~= nil then
        local m_playerObjId = readdword(getplayer(player) + 0x34)
        local m_object = getobject(m_playerObjId)
        local obj_invis_scale = readfloat(m_object + 0x37C)
        if obj_invis_scale == 0 then
            return false
        else
            return true
        end
    end
end

function CreditTimer(id, count, player)

    if game_started == true then
        if getplayer(player) then
            SendMessage(player, "Awarded:    +15 cR - 1 Minute In Server")
            changescore(player, 15, plus)
            if KillStats[gethash(player)].total.credits ~= nil then
                KillStats[gethash(player)].total.credits = KillStats[gethash(player)].total.credits + 15
            else
                KillStats[gethash(player)].total.credits = 15
            end
        end
        return true
    else
        return false
    end
end

function AssistDelay(id, count)

    for i = 0, 15 do
        if getplayer(i) then
            if gethash(i) then
                if readword(getplayer(i) + 0xA4) ~= 0 then
                    KillStats[gethash(i)].total.assists = KillStats[gethash(i)].total.assists + readword(getplayer(i) + 0xA4)
                    medals[gethash(i)].count.assists = medals[gethash(i)].count.assists + readword(getplayer(i) + 0xA4)
                    if (readword(getplayer(i) + 0xA4) * 3) ~= 0 then
                        KillStats[gethash(i)].total.credits = KillStats[gethash(i)].total.credits + (readword(getplayer(i) + 0xA4) * 3)
                        changescore(i, (readword(getplayer(i) + 0xA4) * 3), plus)
                    end
                    if readword(getplayer(i) + 0xA4) == 1 then
                        SendMessage(i, "Awarded:    +" .. (readword(getplayer(i) + 0xA4) * 3) .. " cR - " .. readword(getplayer(i) + 0xA4) .. " Assist")
                    else
                        SendMessage(i, "Awarded:    +" .. (readword(getplayer(i) + 0xA4) * 3) .. " cR - " .. readword(getplayer(i) + 0xA4) .. " Assists")
                    end
                end
            end
        end
    end
end

function CloseCall(id, count, killer)
    -- Cleared

    if getplayer(killer) then
        if killer ~= nil then
            local objectid = getplayerobjectid(killer)
            if objectid ~= nil then
                local m_object = getobject(objectid)
                local shields = readfloat(m_object + 0xE4)
                local health = readfloat(m_object + 0xE0)
                if shields ~= nil then
                    if shields == 0 then
                        if health then
                            if health ~= 1 then
                                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                                KillStats[gethash(killer)].total.credits = KillStats[gethash(killer)].total.credits + 10
                                SendMessage(killer, "Awarded:    +10 cR - Close Call")
                                changescore(killer, 10, plus)
                            end
                        end
                    end
                end
            end
        end
    end
end

function PutUnderMap(id, count, m_objectId)
    local m_object = getobject(m_objectId)
    if m_object then
        local x, y, z = getobjectcoords(m_objectId)
        movobjectcoords(m_objectId, x, y, z - 20)
    end
    return false
end

function OnObjectCreationAttempt(mapId, parentId, player)
    if gametype == "CTF" and mapId == flag_tag_id and parentId == nil then
        registertimer(0, "PutUnderMap", readdword(ctf_globals + 0x8))
    end
    return nil
end

function CountdownToGameStart(id, count)
    if count == 6 then
        registertimer(200, "CheckGameState", -1)
        say("Begin!")
        hprintf("The game has begun!")
        if cur_players ~= 0 then
            local newgame_zombie_count = 0
            for i = 0, 15 do
                if getplayer(i) then
                    if getteam(i) ~= nil then
                        if getteam(i) == ZOMBIE_TEAM then
                            changeteam(i, false)
                            registertimer(200, "CheckGameState", -1)
                        end
                    end
                end
            end
            local possible_count = 0
            for i = 0, 15 do
                if getplayer(i) ~= nil then
                    possible_count = possible_count + 1
                    registertimer(200, "CheckGameState", -1)
                end
            end

            local finalZombies = 0
            if Zombie_Count >= 1 then
                finalZombies = Zombie_Count
                registertimer(200, "CheckGameState", -1)
            else
                finalZombies = round((possible_count * Zombie_Count) + 0.5)
                registertimer(200, "CheckGameState", -1)
            end

            local last_man_index = -1

            if Last_Man_Next_Zombie == true and cur_players > 1 then
                for i = 0, 15 do
                    if getplayer(i) then
                        if gethash(i) ~= nil then
                            if LAST_MAN_HASH == gethash(i) then
                                MakeZombie(i, true)
                                newgame_zombie_count = 1
                                last_man_index = i
                                registertimer(200, "CheckGameState", -1)
                                break
                            end
                        end
                    end
                end
            end

            LAST_MAN_HASH = 0
            registertimer(200, "CheckGameState", -1)
            if finalZombies == cur_players then
                finalZombies = finalZombies - 1
                registertimer(200, "CheckGameState", -1)
            elseif finalZombies > possible_count then
                finalZombies = possible_count
                registertimer(200, "CheckGameState", -1)
            elseif Minimum_Zombie_Count ~= nil and finalZombies > Minimum_Zombie_Count then
                finalZombies = Minimum_Zombie_Count
                registertimer(200, "CheckGameState", -1)
            elseif finalZombies < 0 then
                finalZombies = 0
                registertimer(200, "CheckGameState", -1)
            end
            -- 			Set counters so ChangeTeam wont end the game
            cur_zombie_count = 16
            cur_human_count = 16
            -- 			Loop through the players, randomly selecting ones to become zombies
            while (newgame_zombie_count < finalZombies) do
                -- randomly choose a player
                local newzomb = ChooseRandomPlayer(ZOMBIE_TEAM)
                registertimer(200, "CheckGameState", -1)
                if newzomb == nil then
                    break
                elseif newzomb ~= last_man_index then
                    MakeZombie(newzomb, true)
                    newgame_zombie_count = newgame_zombie_count + 1
                    registertimer(200, "CheckGameState", -1)
                end
            end
            -- 			Fix the team counters
            cur_zombie_count = newgame_zombie_count
            cur_human_count = cur_players - finalZombies
            -- 			Reset the map
            if map_name ~= "bloodgulch" or map_name ~= "sidewinder" or map_name ~= "boardingaction" then
                svcmd("sv_map_reset")
                registertimer(200, "CheckGameState", -1)
            else
                for i = 0, 15 do
                    if getplayer(i) ~= nil then
                        if getplayerobjectid(i) ~= 0xffffffff then
                            destroyobject(getplayerobjectid(i))
                            registertimer(200, "CheckGameState", -1)
                        end
                    end
                end
            end
            for i = 0, 15 do
                if getplayer(i) then
                    if getteam(i) ~= nil then
                        -- 						Check if they're a Zombie
                        if getteam(i) == ZOMBIE_TEAM then
                            privatesay(i, "*   " .. ZOMBIE_MESSAGE, false)
                            registertimer(200, "CheckGameState", -1)
                        else
                            privatesay(i, "*   " .. HUMAN_MESSAGE, false)
                            registertimer(200, "CheckGameState", -1)
                            registertimer(200, "CheckGameState", -1)
                        end
                    end
                end
            end
        end
        -- 		Assume the game is running.
        game_started = true
        resptime = nil
        return false
        -- remove timer
    else
        say("**GAME**   Match will start in: (" .. 6 - count .. ")")
        registertimer(200, "CheckGameState", -1)
        hprintf("The game will start in: (" .. 6 - count .. ")")
        return true
        -- Keep Timer
    end
end

function PlayerChangeTimer(id, count)

    if count ~= 10 then
        local zombsize = cur_zombie_count
        if allow_change == false or zombsize > 0 then
            allow_change = false
            say("Thank you, the game can continue.")
            return false
            -- Block team Change
        end

        say("In (" .. 10 - count .. ") seconds a player will be forced to become a zombie!")
        -- 	hprintf("In (" .. 10 - count .. ") seconds a player will be forced to become a zombie!")

        return true
    else
        allow_change = false
        local newZomb = ChooseRandomPlayer(ZOMBIE_TEAM)
        if newZomb ~= nil then
            MakeZombie(newZomb, true)
            privatesay(newZomb, ZOMBIE_MESSAGE)
        end
        return false
    end
end
--[[
math.randomseed(os.time())
getrandom = math.random
function math.random(low, high)
	low = tonumber(low) or raiseerror("Bad argument #1 to 'math.random' (number expected, got " .. tostring(type(low)) .. ")")
	high = tonumber(high) or raiseerror("Bad argument #2 to 'math.random' (number expected, got " .. tostring(type(high)) .. ")")
	getrandom(low, high) getrandom(low, high) getrandom(low, high)
	return getrandom(low, high)
end
]]
-- Searches through current players and selects a random one
function ChooseRandomPlayer(excludeTeam)
    -- 	Loop through all 16 possible spots and add to table
    local t = GetPlayerTable(excludeTeam)
    if #t > 0 then
        -- 		Generate a random number that we will use to select a player
        local r = getrandomnumber(1, #t + 1)
        return t[r]
    else
        return nil
    end
end

function GetPlayerTable(excludeTeam)
    local players = ""
    for i = 0, 15 do
        if getplayer(i) and getteam(i) ~= excludeTeam then
            if players == nil then
                players = i .. ","
            else
                players = players .. i .. ","
            end
        end
    end
    return tokenizestring(players, ",")
end

function PlayerInHill(player)
    player = tonumber(player)
    local bool = false
    local m_player = getplayer(player)
    if m_player then
        local InHill = readbyte(team_koth_score_array + player + 0x80)
        if InHill == 1 then
            bool = true
        end
    end
    return bool
end

function takenavsaway(lastman)
    for i = 0, 15 do
        local m_player = getplayer(i)
        if m_player then
            writeword(m_player, 0x88, i)
        end
    end
end

function RemoveLastmanProtection(id, count, m_object)
    writebit(m_object + 0x10, 7, 0)
    return false
end
-- 		There are no zombies left...
function noZombiesLeft()
    allow_change = true
    say("There are no zombies left. Someone needs to change teams, otherwise a random player will be forced to!")
    player_change_timer = registertimer(1000, "PlayerChangeTimer")
end

function OnFFATeamChange(player, cur_team, dest_team, updatecounters)
    -- 		Update team counts
    if not updatecounters then
        if dest_team == zombie_team then
            cur_human_count = cur_human_count - 1
            cur_zombie_count = cur_zombie_count + 1
        elseif dest_team ~= zombie_team then
            cur_human_count = cur_human_count + 1
            cur_zombie_count = cur_zombie_count - 1
        end
    end
    -- 	OnNewGame(): Check if the game has started yet.
    if game_started == true then
        registertimer(0, "checkgamestate", player)
    end
    -- 	Update team
    local thisHash = gethash(player)
    hash_table[thisHash] = dest_team
end

-- 		Called when last man exists
function OnLastMan()
    -- 		Lookup the last man
    for i = 0, 15 do
        if getplayer(i) then
            if getteam(i) == HUMAN_TEAM then
                cur_last_man = i
                -- 	WriteNavsToZombies - NOT COMPLETED, as the script isn't yet configured to run on Team Slayer (yet).
                -- 			if gametype == "Slayer" then WriteNavsToZombies(x) end
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

function lastmanpoints(id, count, cur_last_man)
    if getplayer(cur_last_man) and gethash(cur_last_man) then
        changescore(cur_last_man, 10, plus)
        SendMessage(cur_last_man, "Awarded:    +10 cR - Alive for 1 minute as Last Man Standing")
        KillStats[gethash(cur_last_man)].total.credits = KillStats[gethash(cur_last_man)].total.credits + 10
        sprees[gethash(cur_last_man)].count.timeaslms = sprees[gethash(cur_last_man)].count.timeaslms + 1
    end
    return true
end
--[[
== equal to
~= not equal to
< less than
> greater than
<= less than or equal to
>= greater than or equal to
]]

function CheckGameState(player)
    -- Do Not Touch!
    -- Check if the game has started...
    if game_started == true then
        local Zombie_Count = cur_zombie_count
        local human_count = cur_human_count
        -- Human count equal to 0, and zombie count greater than 0, then all players are zombies. Result - End the Game.
        if human_count == 0 and Zombie_Count > 0 then
            -- All players are Zombies
            All_Players_Zombies(player)
            -- Human count greater than 1, and zombie count equal to 0, then there are no zombies left...
        elseif human_count > 1 and Zombie_Count == 0 then
            -- No Zombies Left
            noZombiesLeft()
            -- Human count equal to 1, and zombie count greater than 0, then the human is last man.
        elseif human_count == 1 and Zombie_Count > 0 and cur_last_man == nil then
            -- Last Man Standing
            OnLastMan()
        elseif cur_last_man ~= nil and Zombie_Count == 0 then
            MakeHuman(cur_last_man, false)
            cur_last_man = nil
        end
    end
end

-- 	This function writes navpoints to zombies which will point to the last man.
-- 	NOT COMPLETED as the script isn't setup for Team Slayer (yet).
function WriteNavsToZombies(cur_last_man)
    for i = 0, 15 do
        if getplayer(i) then
            local team = getteam(i)
            if team == zombie_team then
                local m_player = getplayer(i)
                if m_player then
                    local slayer_target = readword(m_player, 0x88)
                    if slayer_target < 16 and slayer_target > -1 then
                        writeword(m_player, 0x88, cur_last_man)
                    end
                end
            end
        end
    end
end

-- Not used
--------------------------------------------------------------------------------
function destroyweaps(id, count, m_weaponId)
    if m_weaponId then
        local m_weapon = getobject(m_weaponId)
        if m_weapon then
            writefloat(m_weapon + 0x5C, readfloat(m_weapon + 0x5C) - 1000)
        end
    end
    return false
end
--------------------------------------------------------------------------------

function All_Players_Zombies(player)
    if player ~= nil and player ~= -1 and getplayer(player) then
        local file = io.open("lasthash_" .. processid .. ".tmp", "w")
        if (file ~= nil) then
            file:write(gethash(player))
            file:close()
        end
    end
    if Change_Map == true then
        svcmd("sv_map_next")
    end
    Change_Map = false
end

function MakeZombie(player, forcekill)
    setspeed(player, tonumber(Zombie_Speed))
    if getteam(player) == HUMAN_TEAM then
        changeteam(player, forcekill)
    end
end

function MakeHuman(player, forcekill)
    setspeed(player, tonumber(Human_Speed))
    if getteam(player) == ZOMBIE_TEAM then
        changeteam(player, forcekill)
    end
end

function Guardian_MakeZombie(player, forcekill)
    setspeed(player, tonumber(Zombie_Speed))
    if getteam(player) == HUMAN_TEAM then
        changeteam(player, forcekill)
    end
end

function OnLevelUp(killer, kill)
    if getteam(killer) == ZOMBIE_TEAM then
        -- 	Make them human...
        changeteam(killer, false)
        -- 	Send them the Human Message
        privatesay(killer, "*   " .. HUMAN_MESSAGE, false)
        kill(killer)
        if getteam(killer) == HUMAN_TEAM and killer == cur_last_man then
            say("**LAST MAN ALIVE**  " .. getname(cur_last_man) .. " is the last man alive.")
            GiveInvis = registertimer(1000, "ApplyCamoToLastMan", cur_last_man)
        end
        -- 	This adds a death deduction so the player isn't charged a death for becoming a human.
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
        -- 	Set their speed to the default human speed (Speed when not infected)
        setspeed(killer, tonumber(Human_Speed))
    end
end

-- 	Gets the number of alpha zombies
function getalphacount()
    -- 	Recalculate how many "alpha" zombies there are
    if Zombie_Count < 1 then
        alpha_zombie_count = round((cur_players * Zombie_Count) + 0.5)
    else
        alpha_zombie_count = Zombie_Count
    end

    if alpha_zombie_count > Max_Zombie_Count then
        alpha_zombie_count = Max_Zombie_Count
    end
    return alpha_zombie_count
end

-- Rounds the number
function round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

function OpenFiles()
    stats = table.load("Stats.txt")
    KillStats = table.load("KillStats.txt")
    sprees = table.load("Sprees.txt")
    medals = table.load("Medals.txt")
    extra = table.load("Extra.txt")
    done = table.load("CompletedMedals.txt")
end

function ResolvePlayerKDR(player)

    local PLAYER_KDR = nil
    if KillStats[gethash(player)].total.kills ~= 0 then
        if KillStats[gethash(player)].total.deaths ~= 0 then
            local kdr = KillStats[gethash(player)].total.kills / KillStats[gethash(player)].total.deaths
            PLAYER_KDR = math.round(kdr, 2)
        else
            PLAYER_KDR = "No Deaths"
        end
    else
        PLAYER_KDR = "No Kills"
    end

    return PLAYER_KDR
end

function DeclearNewPlayerStats(hash)

    if stats[hash] == nil then
        stats[hash] = { }
        stats[hash].kills = { }
        stats[hash].kills.melee = 0
        stats[hash].kills.fragnade = 0
        stats[hash].kills.plasmanade = 0
        stats[hash].kills.grenadestuck = 0
        stats[hash].kills.sniper = 0
        stats[hash].kills.shotgun = 0
        stats[hash].kills.rocket = 0
        stats[hash].kills.fuelrod = 0
        stats[hash].kills.plasmarifle = 0
        stats[hash].kills.plasmapistol = 0
        stats[hash].kills.pistol = 0
        stats[hash].kills.needler = 0
        stats[hash].kills.flamethrower = 0
        stats[hash].kills.flagmelee = 0
        stats[hash].kills.oddballmelee = 0
        stats[hash].kills.assaultrifle = 0
        stats[hash].kills.chainhog = 0
        stats[hash].kills.tankshell = 0
        stats[hash].kills.tankmachinegun = 0
        stats[hash].kills.ghost = 0
        stats[hash].kills.turret = 0
        stats[hash].kills.bansheefuelrod = 0
        stats[hash].kills.banshee = 0
        stats[hash].kills.splatter = 0
    end

    if KillStats[hash] == nil then
        KillStats[hash] = { }
        KillStats[hash].total = { }
        KillStats[hash].total.kills = 0
        KillStats[hash].total.deaths = 0
        KillStats[hash].total.assists = 0
        KillStats[hash].total.suicides = 0
        KillStats[hash].total.betrays = 0
        KillStats[hash].total.credits = 0
        KillStats[hash].total.rank = 0
    end

    if sprees[hash] == nil then
        sprees[hash] = { }
        sprees[hash].count = { }
        sprees[hash].count.double = 0
        sprees[hash].count.triple = 0
        sprees[hash].count.overkill = 0
        sprees[hash].count.killtacular = 0
        sprees[hash].count.killtrocity = 0
        sprees[hash].count.killimanjaro = 0
        sprees[hash].count.killtastrophe = 0
        sprees[hash].count.killpocalypse = 0
        sprees[hash].count.killionaire = 0
        sprees[hash].count.killingspree = 0
        sprees[hash].count.killingfrenzy = 0
        sprees[hash].count.runningriot = 0
        sprees[hash].count.rampage = 0
        sprees[hash].count.untouchable = 0
        sprees[hash].count.invincible = 0
        sprees[hash].count.anomgstopkillingme = 0
        sprees[hash].count.unfrigginbelievable = 0
        sprees[hash].count.timeaslms = 0
    end

    if medals[hash] == nil then
        medals[hash] = { }
        medals[hash].count = { }
        medals[hash].class = { }
        medals[hash].count.sprees = 0
        medals[hash].class.sprees = "Iron"
        medals[hash].count.assists = 0
        medals[hash].class.assists = "Iron"
        medals[hash].count.closequarters = 0
        medals[hash].class.closequarters = "Iron"
        medals[hash].count.crackshot = 0
        medals[hash].class.crackshot = "Iron"
        medals[hash].count.downshift = 0
        medals[hash].class.downshift = "Iron"
        medals[hash].count.grenadier = 0
        medals[hash].class.grenadier = "Iron"
        medals[hash].count.heavyweapons = 0
        medals[hash].class.heavyweapons = "Iron"
        medals[hash].count.jackofalltrades = 0
        medals[hash].class.jackofalltrades = "Iron"
        medals[hash].count.moblieasset = 0
        medals[hash].class.mobileasset = "Iron"
        medals[hash].count.multikill = 0
        medals[hash].class.multikill = "Iron"
        medals[hash].count.sidearm = 0
        medals[hash].class.sidearm = "Iron"
        medals[hash].count.triggerman = 0
        medals[hash].class.triggerman = "Iron"
    end

    if extra[hash] == nil then
        extra[hash] = { }
        extra[hash].woops = { }
        extra[hash].woops.rockethog = 0
        extra[hash].woops.falldamage = 0
        extra[hash].woops.empblast = 0
        extra[hash].woops.gamesplayed = 0
        extra[hash].woops.time = 0
        extra[hash].woops.distance = 0
    end

    if done[hash] == nil then
        done[hash] = { }
        done[hash].medal = { }
        done[hash].medal.sprees = "False"
        done[hash].medal.assists = "False"
        done[hash].medal.closequarters = "False"
        done[hash].medal.crackshot = "False"
        done[hash].medal.downshift = "False"
        done[hash].medal.grenadier = "False"
        done[hash].medal.heavyweapons = "False"
        done[hash].medal.jackofalltrades = "False"
        done[hash].medal.mobileasset = "False"
        done[hash].medal.multikill = "False"
        done[hash].medal.sidearm = "False"
        done[hash].medal.triggerman = "False"
    end
end

function AnnouncePlayerRank(player)
    _info = "@info "
    local rank = nil
    local total = nil
    local hash = gethash(player)
    local name = getname(player)
    local credits = { }
    for k, _ in pairs(KillStats) do
        table.insert(credits, { ["hash"] = k, ["credits"] = KillStats[k].total.credits })
    end

    table.sort(credits, function(a, b)
        return a.credits > b.credits
    end)

    for k, v in ipairs(credits) do
        if hash == credits[k].hash then
            rank = k
            total = #credits
            string = "Server Statistics: You are currently ranked " .. rank .. " out of " .. total .. "."
            PrintPlayerRank(profilepath .. "\\logs\\PlayerRanks.txt", name .. " has joined the server, they're ranked " .. rank .. " out of " .. total .. "!")
        end
    end
    return sendconsoletext(player, string)
end

function table.find(t, v, case)

    if case == nil then
        case = true
    end

    for k, val in pairs(t) do
        if case then
            if v == val then
                return k
            end
        else
            if string.lower(v) == string.lower(val) then
                return k
            end
        end
    end
end

function DestroyGuns(object)

    for i = 0, 3 do
        if getobject(object) then
            local weapID = readdword(getobject(object) + 0x2F8 + i * 4)
            if getobject(weapID) then
                destroyobject(weapID)
            end
        end
    end
end

function math.round(input, precision)
    return math.floor(input * (10 ^ precision) + 0.5) / (10 ^ precision)
end

function LevelUp(id, count, killer)

    local hash = gethash(killer)

    KillStats[hash].total.rank = KillStats[hash].total.rank or "Recruit"
    KillStats[hash].total.credits = KillStats[hash].total.credits or 0

    if KillStats[hash].total.rank ~= nil and KillStats[hash].total.credits ~= 0 then
        if KillStats[hash].total.rank == "Recruit" and KillStats[hash].total.credits > 7500 then
            KillStats[hash].total.rank = "Private"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Private" and KillStats[hash].total.credits > 10000 then
            KillStats[hash].total.rank = "Corporal"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Corporal" and KillStats[hash].total.credits > 15000 then
            KillStats[hash].total.rank = "Sergeant"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Sergeant" and KillStats[hash].total.credits > 20000 then
            KillStats[hash].total.rank = "Sergeant Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Sergeant Grade 1" and KillStats[hash].total.credits > 26250 then
            KillStats[hash].total.rank = "Sergeant Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Sergeant Grade 2" and KillStats[hash].total.credits > 32500 then
            KillStats[hash].total.rank = "Warrant Officer"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Warrant Officer" and KillStats[hash].total.credits > 45000 then
            KillStats[hash].total.rank = "Warrant Officer Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Warrant Officer Grade 1" and KillStats[hash].total.credits > 78000 then
            KillStats[hash].total.rank = "Warrant Officer Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Warrant Officer Grade 2" and KillStats[hash].total.credits > 111000 then
            KillStats[hash].total.rank = "Warrant Officer Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Warrant Officer Grade 3" and KillStats[hash].total.credits > 144000 then
            KillStats[hash].total.rank = "Captain"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Captain" and KillStats[hash].total.credits > 210000 then
            KillStats[hash].total.rank = "Captain Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Captain Grade 1" and KillStats[hash].total.credits > 233000 then
            KillStats[hash].total.rank = "Captain Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Captain Grade 2" and KillStats[hash].total.credits > 256000 then
            KillStats[hash].total.rank = "Captain Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Captain Grade 3" and KillStats[hash].total.credits > 279000 then
            KillStats[hash].total.rank = "Major"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Major" and KillStats[hash].total.credits > 325000 then
            KillStats[hash].total.rank = "Major Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Major Grade 1" and KillStats[hash].total.credits > 350000 then
            KillStats[hash].total.rank = "Major Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Major Grade 2" and KillStats[hash].total.credits > 375000 then
            KillStats[hash].total.rank = "Major Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Major Grade 3" and KillStats[hash].total.credits > 400000 then
            KillStats[hash].total.rank = "Lt. Colonel"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Lt. Colonel" and KillStats[hash].total.credits > 450000 then
            KillStats[hash].total.rank = "Lt. Colonel Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Lt. Colonel Grade 1" and KillStats[hash].total.credits > 480000 then
            KillStats[hash].total.rank = "Lt. Colonel Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Lt. Colonel Grade 2" and KillStats[hash].total.credits > 510000 then
            KillStats[hash].total.rank = "Lt. Colonel Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Lt. Colonel Grade 3" and KillStats[hash].total.credits > 540000 then
            KillStats[hash].total.rank = "Commander"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Commander" and KillStats[hash].total.credits > 600000 then
            KillStats[hash].total.rank = "Commander Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Commander Grade 1" and KillStats[hash].total.credits > 650000 then
            KillStats[hash].total.rank = "Commander Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Commander Grade 2" and KillStats[hash].total.credits > 700000 then
            KillStats[hash].total.rank = "Commander Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Commander Grade 3" and illstats[hash].total.credits > 750000 then
            KillStats[hash].total.rank = "Colonel"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Colonel" and KillStats[hash].total.credits > 850000 then
            KillStats[hash].total.rank = "Colonel Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Colonel Grade 1" and KillStats[hash].total.credits > 960000 then
            KillStats[hash].total.rank = "Colonel Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Colonel Grade 2" and KillStats[hash].total.credits > 1070000 then
            KillStats[hash].total.rank = "Colonel Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Colonel Grade 3" and KillStats[hash].total.credits > 1180000 then
            KillStats[hash].total.rank = "Brigadier"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Brigadier" and KillStats[hash].total.credits > 1400000 then
            KillStats[hash].total.rank = "Brigadier Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Brigadier Grade 1" and KillStats[hash].total.credits > 1520000 then
            KillStats[hash].total.rank = "Brigadier Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Brigadier Grade 2" and KillStats[hash].total.credits > 1640000 then
            KillStats[hash].total.rank = "Brigadier Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Brigadier Grade 3" and KillStats[hash].total.credits > 1760000 then
            KillStats[hash].total.rank = "General"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "General" and KillStats[hash].total.credits > 2000000 then
            KillStats[hash].total.rank = "General Grade 1"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "General Grade 1" and KillStats[hash].total.credits > 2200000 then
            KillStats[hash].total.rank = "General Grade 2"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "General Grade 2" and KillStats[hash].total.credits > 2350000 then
            KillStats[hash].total.rank = "General Grade 3"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "General Grade 3" and KillStats[hash].total.credits > 2500000 then
            KillStats[hash].total.rank = "General Grade 4"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "General Grade 4" and KillStats[hash].total.credits > 2650000 then
            KillStats[hash].total.rank = "Field Marshall"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Field Marshall" and KillStats[hash].total.credits > 3000000 then
            KillStats[hash].total.rank = "Hero"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Hero" and KillStats[hash].total.credits > 3700000 then
            KillStats[hash].total.rank = "Legend"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Legend" and KillStats[hash].total.credits > 4600000 then
            KillStats[hash].total.rank = "Mythic"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Mythic" and KillStats[hash].total.credits > 5650000 then
            KillStats[hash].total.rank = "Noble"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Noble" and KillStats[hash].total.credits > 7000000 then
            KillStats[hash].total.rank = "Eclipse"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Eclipse" and KillStats[hash].total.credits > 8500000 then
            KillStats[hash].total.rank = "Nova"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Nova" and KillStats[hash].total.credits > 11000000 then
            KillStats[hash].total.rank = "Forerunner"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Forerunner" and KillStats[hash].total.credits > 13000000 then
            KillStats[hash].total.rank = "Reclaimer"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        elseif KillStats[hash].total.rank == "Reclaimer" and KillStats[hash].total.credits > 16500000 then
            KillStats[hash].total.rank = "Inheritor"
            say(getname(killer) .. " is now a " .. KillStats[hash].total.rank .. "!")
        end
    end
end

function AwardPlayerMedals(player)

    local hash = gethash(player)
    -- Get the player's hash.
    if hash then
        if done[hash].medal.sprees == "False" then
            if medals[hash].class.sprees == "Iron" and medals[hash].count.sprees >= 5 then
                -- If the class is iron and the count is more then 5,
                medals[hash].class.sprees = "Bronze"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Any Spree Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.sprees == "Bronze" and medals[hash].count.sprees >= 50 then
                -- If the class is bronze and the count is more then 50.
                medals[hash].class.sprees = "Silver"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Any Spree Bronze!")
                -- Tell them what they earned.
            elseif medals[hash].class.sprees == "Silver" and medals[hash].count.sprees >= 250 then
                -- If the class is silver and the clount is more then 250.
                medals[hash].class.sprees = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Any Spree Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.sprees == "Gold" and medals[hash].count.sprees >= 1000 then
                -- If the class is gold and the count is more then 1000.
                medals[hash].class.sprees = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Any Spree Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Any Spree : Gold")
                changescore(player, 1000, plus)
            elseif medals[hash].class.sprees == "Onyx" and medals[hash].count.sprees >= 4000 then
                -- If the class is onyx and the count is more then 4000.
                medals[hash].class.sprees = "MAX"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Any Spree Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2000
                privatesay(player, "Awarded:    +2000 cR - Any Spree : Onyx")
                changescore(player, 2000, plus)
            elseif medals[hash].class.sprees == "MAX" and medals[hash].count.sprees == 10000 then
                -- if the class is max and the count is 10000.
                say(getname(player) .. " has earned a medal : Any Spree MAX!")
                -- Tell them what they have earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 3000
                privatesay(player, "Awarded:    +3000 cR - Any Spree : MAX")
                changescore(player, 3000, plus)
                done[hash].medal.sprees = "True"
            end
        end

        if done[hash].medal.assists == "False" then
            if medals[hash].class.assists == "Iron" and medals[hash].count.assists >= 50 then
                -- If the class is iron and the count is more then 50.
                medals[hash].class.assists = "Bronze"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Assistant Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.assists == "Bronze" and medals[hash].count.assists >= 250 then
                -- If the class is bronze and the count is more then 250.
                medals[hash].class.assists = "Silver"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Assistant Bronze!")
                -- Tell them what they earned.
            elseif medals[hash].class.assists == "Silver" and medals[hash].count.assists >= 1000 then
                -- If the class is silver and the count is more then 1000.
                medals[hash].class.assists = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Assistant Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.assists == "Gold" and medals[hash].count.assists >= 4000 then
                -- If the class is gold and the count is more then 4000.
                medals[hash].class.assists = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Assistant Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Assistant : Gold")
                changescore(player, 1500, plus)
            elseif medals[hash].class.assists == "Onyx" and medals[hash].count.assists >= 8000 then
                -- If the class is onyx and the count is more then 8000.
                medals[hash].class.assists = "MAX"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Assistant Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2500
                privatesay(player, "Awarded:    +2500 cR - Assistant : Onyx")
                changescore(player, 2500, plus)
            elseif medals[hash].class.assists == "MAX" and medals[hash].count.assists == 20000 then
                -- If the class is max and the count is 20000.
                say(getname(player) .. " has earned a medal : Assistant MAX!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 3500
                privatesay(player, "Awarded:    +3500 cR - Assistant : MAX")
                changescore(player, 3500, plus)
                done[hash].medal.assists = "True"
            end
        end

        if done[hash].medal.closequarters == "False" then
            if medals[hash].class.closequarters == "Iron" and medals[hash].count.closequarters >= 50 then
                -- If the class is iron and the count is more then 50.
                medals[hash].class.closequarters = "Bronze"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Close Quarters Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.closequarters == "Bronze" and medals[hash].count.closequarters >= 125 then
                -- If the class is bronze and the count is more then 125.
                medals[hash].class.closequarters = "Silver"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Close Quarters Bronze!")
                -- Tell them what they earned.
            elseif medals[hash].class.closequarters == "Silver" and medals[hash].count.closequarters >= 400 then
                -- If the class is silver and the count is more then 400.
                medals[hash].class.closequarters = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Close Quarters Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.closequarters == "Gold" and medals[hash].count.closequarters >= 1600 then
                -- If the class is gold and the count is more then 1600.
                medals[hash].class.closequarters = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Close Quarters Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 750
                privatesay(player, "Awarded:    +750 cR - Close Quarters : Gold")
                changescore(player, 750, plus)
            elseif medals[hash].class.closequarters == "Onyx" and medals[hash].count.closequarters >= 4000 then
                -- If the class is onyx and the count is more then 4000.
                medals[hash].class.closequarters = "MAX"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Close Quarters Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Close Quarters : Onyx")
                changescore(player, 1500, plus)
            elseif medals[hash].class.closequarters == "MAX" and medals[hash].count.closequarters == 8000 then
                -- If the class is max and the count is 8000.
                say(getname(player) .. " has earned a medal : Close Quarters MAX!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2250
                privatesay(player, "2250 cR - Close Quarters : MAX")
                changescore(player, 2250, plus)
                done[hash].medal.closequarters = "True"
            end
        end

        if done[hash].medal.crackshot == "False" then
            if medals[hash].class.crackshot == "Iron" and medals[hash].count.crackshot >= 100 then
                -- If the class is iron and the count is more then 100 .
                medals[hash].class.crackshot = "Bronze"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Crack Shot Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.crackshot == "Bronze" and medals[hash].count.crackshot >= 500 then
                -- If the class is bronze and the count is more then 500.
                medals[hash].class.crackshot = "Silver"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Crack Shot Bronze!")
                -- Tell them what they earned.
            elseif medals[hash].class.crackshot == "Silver" and medals[hash].count.crackshot >= 4000 then
                -- If the class is silver and the count is more then 4000.
                medals[hash].class.crackshot = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Crack Shot Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.crackshot == "Gold" and medals[hash].count.crackshot >= 10000 then
                -- If the class is gold and the count is more then 10000.
                medals[hash].class.crackshot = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Crack Shot Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Crack Shot : Gold")
                changescore(player, 1000, plus)
            elseif medals[hash].class.crackshot == "Onyx" and medals[hash].count.crackshot >= 20000 then
                -- If the class is onyx and the count is more then 20000.
                medals[hash].class.crackshot = "MAX"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Crack Shot Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2000
                privatesay(player, "Awarded:    +2000 cR - Crack Shot : Onyx")
                changescore(player, 2000, plus)
            elseif medals[hash].class.crackshot == "MAX" and medals[hash].count.crackshot == 32000 then
                -- If the class is max and the count is 32000.
                say(getname(player) .. " has earned a medal : Crack Shot MAX!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 3000
                privatesay(player, "Awarded:    +3000 cR - Crack Shot : MAX")
                changescore(player, 3000, plus)
                done[hash].medal.crackshot = "True"
            end
        end

        if done[hash].medal.downshift == "False" then
            if medals[hash].class.downshift == "Iron" and medals[hash].count.downshift >= 5 then
                -- If the class is iron and count is more then 5.
                medals[hash].class.downshift = "Bronze"
                -- Level it up.
                say(getnamye(player) .. " has earned a medal : Downshift Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.downshift == "Bronze" and medals[hash].count.downshift >= 50 then
                -- If the class is bronze and count is more then 50.
                medals[hash].class.downshift = "Silver"
                -- Level it up
                say(getname(player) .. " has earned a medal : Downshift Bronze!")
                -- Tell them what the earned.
            elseif medals[hash].class.downshift == "Silver" and medals[hash].count.downshift >= 750 then
                -- If the class is silver and count is more then 750.
                medals[hash].class.downshift = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Downshift Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.downshift == "Gold" and medals[hash].count.downshift >= 4000 then
                -- If the class is gold and count is more then 4000.
                medals[hash].class.downshift = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Downshift Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 500
                privatesay(player, "Awarded:    +500 cR - Downshift : Gold")
                changescore(player, 500, plus)
            elseif medals[hash].class.downshift == "Onyx" and medals[hash].count.downshift >= 8000 then
                -- If the class is onyx and count is more then 8000.
                medals[hash].class.downshift = "MAX"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Downshift Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Downshift : Onyx")
                changescore(player, 1000, plus)
            elseif medals[hash].class.downshift == "MAX" and medals[hash].count.downshift == 20000 then
                -- If the class is max and count is 20000.
                say(getname(player) .. " has earned a medal : Downshift MAX!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Downshift : MAX")
                changescore(player, 1500, plus)
                done[hash].medal.downshift = "True"
            end
        end

        if done[hash].medal.grenadier == "False" then
            if medals[hash].class.grenadier == "Iron" and medals[hash].count.grenadier >= 25 then
                -- If the class is iron and count is more then 25.
                medals[hash].class.grenadier = "Bronze"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Grenadier Iron!")
                -- Tell them what they earned.
            elseif medals[hash].class.grenadier == "Bronze" and medals[hash].count.grenadier >= 125 then
                -- If the class is bronze and count is more then 125.
                medals[hash].class.grenadier = "Silver"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Grenadier Bronze!")
                -- Tell them what they earned.
            elseif medals[hash].class.grenadier == "Silver" and medals[hash].count.grenadier >= 500 then
                -- If the class is silver and count is more then 500.
                medals[hash].class.grenadier = "Gold"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Grenadier Silver!")
                -- Tell them what they earned.
            elseif medals[hash].class.grenadier == "Gold" and medals[hash].count.grenadier >= 4000 then
                -- If the class is gold and count is more then 4000.
                medals[hash].class.grenadier = "Onyx"
                -- Level it up.
                say(getname(player) .. " has earned a medal : Grenadier Gold!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 750
                privatesay(player, "Awarded:    +750 cR - Grenadier : Gold")
                changescore(player, 750, plus)
            elseif medals[hash].class.grenadier == "Onyx" and medals[hash].count.grenadier >= 8000 then
                -- If the class is onyx and count is more then 8000.
                medals[hash].class.grenadier = "MAX"
                -- Level it up
                say(getname(player) .. " has earned a medal : Grenadier Onyx!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Grenadier : Onyx")
                changescore(player, 1500, plus)
            elseif medals[hash].class.grenadier == "MAX" and medals[hash].count.grenadier == 14000 then
                -- If the class is max and count is 14000.
                say(getname(player) .. " has earned a medal : Grenadier MAX!")
                -- Tell them what they earned.
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2250
                privatesay(player, "Awarded:    +2250 cR - Grenadier : MAX")
                changescore(player, 2250, plus)
                done[hash].medal.grenadier = "True"
            end
        end

        if done[hash].medal.heavyweapons == "False" then
            if medals[hash].class.heavyweapons == "Iron" and medals[hash].count.heavyweapons >= 25 then
                medals[hash].class.heavyweapons = "Bronze"
                say(getname(player) .. " has earned a medal : Heavy Weapon Iron!")
            elseif medals[hash].class.heavyweapons == "Bronze" and medals[hash].count.heavyweapons >= 150 then
                medals[hash].class.heavyweapons = "Silver"
                say(getname(player) .. " has earned a medal : Heavy Weapon Bronze!")
            elseif medals[hash].class.heavyweapons == "Silver" and medals[hash].count.heavyweapons >= 750 then
                medals[hash].class.heavyweapons = "Gold"
                say(getname(player) .. " has earned a medal : Heavy Weapon Silver!")
            elseif medals[hash].class.heavyweapons == "Gold" and medals[hash].count.heavyweapons >= 3000 then
                medals[hash].class.heavyweapons = "Onyx"
                say(getname(player) .. " has earned a medal : Heavy Weapon Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 500
                privatesay(player, "Awarded:    +500 cR - Heavy Weapon : Gold")
                changescore(player, 500, plus)
            elseif medals[hash].class.heavyweapons == "Onyx" and medals[hash].count.heavyweapons >= 7000 then
                medals[hash].class.heavyweapons = "MAX"
                say(getname(player) .. " has earned a medal : Heavy Weapon Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Heavy Weapon : Onyx")
                changescore(player, 1000, plus)
            elseif medals[hash].class.heavyweapons == "MAX" and medals[hash].count.heavyweapons == 14000 then
                say(getname(player) .. " has earned a medal : Heavy Weapon MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Heavy Weapon : MAX")
                changescore(player, 1500, plus)
                done[hash].medal.heavyweapons = "True"
            end
        end

        if done[hash].medal.jackofalltrades == "False" then
            if medals[hash].class.jackofalltrades == "Iron" and medals[hash].count.jackofalltrades >= 50 then
                -- Create the jackofalltrades count table.
                medals[hash].class.jackofalltrades = "Bronze"
                say(getname(player) .. " has earned a medal : Jack of all Trades Iron!")
            elseif medals[hash].class.jackofalltrades == "Bronze" and medals[hash].count.jackofalltrades >= 125 then
                medals[hash].class.jackofalltrades = "Silver"
                say(getname(player) .. " has earned a medal : Jack of all Trades Bronze!")
            elseif medals[hash].class.jackofalltrades == "Silver" and medals[hash].count.jackofalltrades >= 400 then
                medals[hash].class.jackofalltrades = "Gold"
                say(getname(player) .. " has earned a medal : Jack of all Trades Silver!")
            elseif medals[hash].class.jackofalltrades == "Gold" and medals[hash].count.jackofalltrades >= 1600 then
                medals[hash].class.jackofalltrades = "Onyx"
                say(getname(player) .. " has earned a medal : Jack of all Trades Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 500
                privatesay(player, "Awarded:    +500 cR - Jack of all Trades : Gold")
                changescore(player, 500, plus)
            elseif medals[hash].class.jackofalltrades == "Onyx" and medals[hash].count.jackofalltrades >= 4800 then
                medals[hash].class.jackofalltrades = "MAX"
                say(getname(player) .. " has earned a medal : Jack of all Trades Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Jack of all Trades : Onyx")
                changescore(player, 1000, plus)
            elseif medals[hash].class.jackofalltrades == "MAX" and medals[hash].count.jackofalltrades == 9600 then
                say(getname(player) .. " has earned a medal : Jack of all Trades MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Jack of all Trades : MAX")
                changescore(player, 1500, plus)
                done[hash].medal.jackofalltrades = "True"
            end
        end

        if done[hash].medal.mobileasset == "False" then
            if medals[hash].class.mobileasset == "Iron" and medals[hash].count.moblieasset >= 25 then
                medals[hash].class.mobileasset = "Bronze"
                say(getname(player) .. " has earned a medal : Mobile Asset Iron!")
            elseif medals[hash].class.mobileasset == "Bronze" and medals[hash].count.moblieasset >= 125 then
                medals[hash].class.mobileasset = "Silver"
                say(getname(player) .. " has earned a medal : Mobile Asset Bronze!")
            elseif medals[hash].class.mobileasset == "Silver" and medals[hash].count.moblieasset >= 500 then
                medals[hash].class.mobileasset = "Gold"
                say(getname(player) .. " has earned a medal : Mobile Asset Silver!")
            elseif medals[hash].class.mobileasset == "Gold" and medals[hash].count.moblieasset >= 4000 then
                medals[hash].class.mobileasset = "Onyx"
                say(getname(player) .. " has earned a medal : Mobile Asset Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 750
                privatesay(player, "Awarded:    +750 cR - Mobile Asset : Gold")
                changescore(player, 750, plus)
            elseif medals[hash].class.mobileasset == "Onyx" and medals[hash].count.moblieasset >= 8000 then
                medals[hash].class.mobileasset = "MAX"
                say(getname(player) .. " has earned a medal : Mobile Asset Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Mobile Asset : Onyx")
                changescore(player, 1500, plus)
            elseif medals[hash].class.mobileasset == "MAX" and medals[hash].count.moblieasset == 14000 then
                say(getname(player) .. " has earned a medal : Mobile Asset MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2250
                privatesay(player, "Awarded:    +2250 cR - Mobile Asset : MAX")
                changescore(player, 2250, plus)
                done[hash].medal.mobileasset = "True"
            end
        end

        if done[hash].medal.multikill == "False" then
            if medals[hash].class.multikill == "Iron" and medals[hash].count.multikill >= 10 then
                medals[hash].class.multikill = "Bronze"
                say(getname(player) .. " has earned a medal : Multikill Iron!")
            elseif medals[hash].class.multikill == "Bronze" and medals[hash].count.multikill >= 125 then
                medals[hash].class.multikill = "Silver"
                say(getname(player) .. " has earned a medal : Multikill Bronze!")
            elseif medals[hash].class.multikill == "Silver" and medals[hash].count.multikill >= 500 then
                medals[hash].class.multikill = "Gold"
                say(getname(player) .. " has earned a medal : Multikill Silver!")
            elseif medals[hash].class.multikill == "Gold" and medals[hash].count.multikill >= 2500 then
                medals[hash].class.multikill = "Onyx"
                say(getname(player) .. " has earned a medal : Multikill Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 500
                privatesay(player, "Awarded:    +500 cR - Multikill : Gold")
                changescore(player, 500, plus)
            elseif medals[hash].class.multikill == "Onyx" and medals[hash].count.multikill >= 5000 then
                medals[hash].class.multikill = "MAX"
                say(getname(player) .. " has earned a medal : Multikill Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Multikill : Onyx")
                changescore(player, 1000, plus)
            elseif medals[hash].class.multikill == "MAX" and medals[hash].count.multikill == 15000 then
                say(getname(player) .. " has earned a mdeal : Multikill MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1500
                privatesay(player, "Awarded:    +1500 cR - Multikill : MAX")
                changescore(player, 1500, plus)
                done[hash].medal.multikill = "True"
            end
        end

        if done[hash].medal.sidearm == "False" then
            if medals[hash].class.sidearm == "Iron" and medals[hash].count.sidearm >= 50 then
                medals[hash].class.sidearm = "Bronze"
                say(getname(player) .. " has earned a medal : Sidearm Iron!")
            elseif medals[hash].class.sidearm == "Bronze" and medals[hash].count.sidearm >= 250 then
                medals[hash].class.sidearm = "Silver"
                say(getname(player) .. " has earned a medal : Sidearm Bronze!")
            elseif medals[hash].class.sidearm == "Silver" and medals[hash].count.sidearm >= 1000 then
                medals[hash].class.sidearm = "Gold"
                say(getname(player) .. " has earned a medal : Sidearm Silver!")
            elseif medals[hash].class.sidearm == "Gold" and medals[hash].count.sidearm >= 4000 then
                medals[hash].class.sidearm = "Onyx"
                say(getname(player) .. " has earned a medal : Sidearm Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Sidearm : Gold")
                changescore(player, 1000, plus)
            elseif medals[hash].class.sidearm == "Onyx" and medals[hash].count.sidearm >= 8000 then
                medals[hash].class.sidearm = "MAX"
                say(getname(player) .. " has earned a medal : Sidearm Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2000
                privatesay(player, "Awarded:    +2000 cR - Sidearm : Onyx")
                changescore(player, 2000, plus)
            elseif medals[hash].class.sidearm == "MAX" and medals[hash].count.sidearm == 10000 then
                say(getname(player) .. " has earned a medal : Sidearm MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 3000
                privatesay(player, "Awarded:    +3000 cR - Sidearm : MAX")
                changescore(player, 3000, plus)
                done[hash].medal.sidearm = "True"
            end
        end

        if done[hash].medal.triggerman == "False" then
            if medals[hash].class.triggerman == "Iron" and medals[hash].count.triggerman >= 100 then
                medals[hash].class.triggerman = "Bronze"
                say(getname(player) .. " has earned a medal : Triggerman Iron!")
            elseif medals[hash].class.triggerman == "Bronze" and medals[hash].count.triggerman >= 500 then
                medals[hash].class.triggerman = "Silver"
                say(getname(player) .. " has earned a medal : Triggerman Bronze!")
            elseif medals[hash].class.triggerman == "Silver" and medals[hash].count.triggerman >= 4000 then
                medals[hash].class.triggerman = "Gold"
                say(getname(player) .. " has earned a medal : Triggerman Silver!")
            elseif medals[hash].class.triggerman == "Gold" and medals[hash].count.triggerman >= 10000 then
                medals[hash].class.triggerman = "Onyx"
                say(getname(player) .. " has earned a medal : Triggerman Gold!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 1000
                privatesay(player, "Awarded:    +1000 cR - Triggerman : Gold")
                changescore(player, 1000, plus)
            elseif medals[hash].class.triggerman == "Onyx" and medals[hash].count.triggerman >= 20000 then
                medals[hash].class.triggerman = "MAX"
                say(getname(player) .. " has earned a medal : Triggerman Onyx!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 2000
                privatesay(player, "Awarded:    +2000 cR - Triggerman : Onyx")
                changescore(player, 2000, plus)
            elseif medals[hash].class.triggerman == "MAX" and medals[hash].count.triggerman == 32000 then
                say(getname(player) .. " has earned a medal : Triggerman MAX!")
                KillStats[hash].total.credits = KillStats[hash].total.credits + 3000
                privatesay(player, "Awarded:    +3000 cR - Triggerman : MAX")
                changescore(player, 3000, plus)
                done[hash].medal.triggerman = "True"
            end
        end
    end
end

function GetMedalClasses(player)

    local hash = gethash(player)

    if medals[hash].count.sprees > 5 and medals[hash].count.sprees < 50 then
        medals[hash].class.sprees = "Bronze"
    elseif medals[hash].count.sprees > 50 and medals[hash].count.sprees < 250 then
        medals[hash].class.sprees = "Silver"
    elseif medals[hash].count.sprees > 250 and medals[hash].count.sprees < 1000 then
        medals[hash].class.sprees = "Gold"
    elseif medals[hash].count.sprees > 1000 and medals[hash].count.sprees < 4000 then
        medals[hash].class.sprees = "Onyx"
    elseif medals[hash].count.sprees > 4000 and medals[hash].count.sprees < 10000 then
        medals[hash].class.sprees = "MAX"
    elseif medals[hash].count.sprees > 10000 then
        medals[hash].class.sprees = "MAX"
    end

    if medals[hash].count.assists > 50 and medals[hash].count.assists < 250 then
        medals[hash].class.assists = "Bronze"
    elseif medals[hash].count.assists > 250 and medals[hash].count.assists < 1000 then
        medals[hash].class.assists = "Silver"
    elseif medals[hash].count.assists > 1000 and medals[hash].count.assists < 4000 then
        medals[hash].class.assists = "Gold"
    elseif medals[hash].count.assists > 4000 and medals[hash].count.assists < 8000 then
        medals[hash].class.assists = "Onyx"
    elseif medals[hash].count.assists > 8000 and medals[hash].count.assists < 20000 then
        medals[hash].class.assists = "MAX"
    elseif medals[hash].count.assists > 20000 then
        medals[hash].class.assists = "MAX"
    end

    if medals[hash].count.closequarters > 50 and medals[hash].count.closequarters < 150 then
        medals[hash].class.closequarters = "Bronze"
    elseif medals[hash].count.closequarters > 150 and medals[hash].count.closequarters < 400 then
        medals[hash].class.closequarters = "Silver"
    elseif medals[hash].count.closequarters > 400 and medals[hash].count.closequarters < 1600 then
        medals[hash].class.closequarters = "Gold"
    elseif medals[hash].count.closequarters > 1600 and medals[hash].count.closequarters < 4000 then
        medals[hash].class.closequarters = "Onyx"
    elseif medals[hash].count.closequarters > 4000 and medals[hash].count.closequarters < 8000 then
        medals[hash].count.closequarters = "MAX"
    elseif medals[hash].count.closequarters > 8000 then
        medals[hash].count.closequarters = "MAX"
    end

    if medals[hash].count.crackshot > 100 and medals[hash].count.crackshot < 500 then
        medals[hash].class.crackshot = "Bronze"
    elseif medals[hash].count.crackshot > 500 and medals[hash].count.crackshot < 4000 then
        medals[hash].class.crackshot = "Silver"
    elseif medals[hash].count.crackshot > 4000 and medals[hash].count.crackshot < 10000 then
        medals[hash].class.crackshot = "Gold"
    elseif medals[hash].count.crackshot > 10000 and medals[hash].count.crackshot < 20000 then
        medals[hash].class.crackshot = "Onyx"
    elseif medals[hash].count.crackshot > 20000 and medals[hash].count.crackshot < 32000 then
        medals[hash].class.crackshot = "MAX"
    elseif medals[hash].count.crackshot > 32000 then
        medals[hash].class.crackshot = "MAX"
    end

    if medals[hash].count.downshift > 5 and medals[hash].count.downshift < 50 then
        medals[hash].class.downshift = "Bronze"
    elseif medals[hash].count.downshift > 50 and medals[hash].count.downshift < 750 then
        medals[hash].class.downshift = "Silver"
    elseif medals[hash].count.downshift > 750 and medals[hash].count.downshift < 4000 then
        medals[hash].class.downshift = "Gold"
    elseif medals[hash].count.downshift > 4000 and medals[hash].count.downshift < 8000 then
        medals[hash].class.downshift = "Onyx"
    elseif medals[hash].count.downshift > 8000 and medals[hash].count.downshift < 20000 then
        medals[hash].count.downshift = "MAX"
    elseif medals[hash].count.downshift > 20000 then
        medals[hash].count.downshift = "MAX"
    end

    if medals[hash].count.grenadier > 25 and medals[hash].count.grenadier < 125 then
        medals[hash].class.grenadier = "Bronze"
    elseif medals[hash].count.grenadier > 125 and medals[hash].count.grenadier < 500 then
        medals[hash].class.grenadier = "Silver"
    elseif medals[hash].count.grenadier > 500 and medals[hash].count.grenadier < 4000 then
        medals[hash].class.grenadier = "Gold"
    elseif medals[hash].count.grenadier > 4000 and medals[hash].count.grenadier < 8000 then
        medals[hash].class.grenadier = "Onyx"
    elseif medals[hash].count.grenadier > 8000 and medals[hash].count.grenadier < 14000 then
        medals[hash].class.grenadier = "MAX"
    elseif medals[hash].count.grenadier > 14000 then
        medals[hash].class.grenadier = "MAX"
    end

    if medals[hash].count.heavyweapons > 25 and medals[hash].count.heavyweapons < 150 then
        medals[hash].class.heavyweapons = "Bronze"
    elseif medals[hash].count.heavyweapons > 150 and medals[hash].count.heavyweapons < 750 then
        medals[hash].class.heavyweapons = "Silver"
    elseif medals[hash].count.heavyweapons > 750 and medals[hash].count.heavyweapons < 3000 then
        medals[hash].class.heavyweapons = "Gold"
    elseif medals[hash].count.heavyweapons > 3000 and medals[hash].count.heavyweapons < 7000 then
        medals[hash].class.heavyweapons = "Onyx"
    elseif medals[hash].count.heavyweapons > 7000 and medals[hash].count.heavyweapons < 14000 then
        medals[hash].class.heavyweapons = "MAX"
    elseif medals[hash].count.heavyweapons > 14000 then
        medals[hash].class.heavyweapons = "MAX"
    end

    if medals[hash].count.jackofalltrades > 50 and medals[hash].count.jackofalltrades < 125 then
        medals[hash].class.jackofalltrades = "Bronze"
    elseif medals[hash].count.jackofalltrades > 125 and medals[hash].count.jackofalltrades < 400 then
        medals[hash].class.jackofalltrades = "Silver"
    elseif medals[hash].count.jackofalltrades > 400 and medals[hash].count.jackofalltrades < 1600 then
        medals[hash].class.jackofalltrades = "Gold"
    elseif medals[hash].count.jackofalltrades > 1600 and medals[hash].count.jackofalltrades < 4800 then
        medals[hash].class.jackofalltrades = "Onyx"
    elseif medals[hash].count.jackofalltrades > 4800 and medals[hash].count.jackofalltrades < 9600 then
        medals[hash].class.jackofalltrades = "MAX"
    elseif medals[hash].count.jackofalltrades > 9600 then
        medals[hash].class.jackofalltrades = "MAX"
    end

    if medals[hash].count.moblieasset > 25 and medals[hash].count.moblieasset < 125 then
        medals[hash].class.mobileasset = "Bronze"
        -- Declear the medal's class.
    elseif medals[hash].count.moblieasset > 125 and medals[hash].count.moblieasset < 500 then
        medals[hash].class.mobileasset = "Silver"
        -- Declear the medal's class.
    elseif medals[hash].count.moblieasset > 500 and medals[hash].count.moblieasset < 4000 then
        medals[hash].class.mobileasset = "Gold"
        -- Declear the medal's class.
    elseif medals[hash].count.moblieasset > 4000 and medals[hash].count.moblieasset < 8000 then
        medals[hash].class.mobileasset = "Onyx"
        -- Declear the medal's class.
    elseif medals[hash].count.moblieasset > 8000 and medals[hash].count.moblieasset < 14000 then
        medals[hash].class.mobileasset = "MAX"
        -- Declear the medal's class.
    elseif medals[hash].count.moblieasset > 14000 then
        medals[hash].class.mobileasset = "MAX"
        -- Declear the medal's class.
    end

    if medals[hash].count.multikill > 10 and medals[hash].count.multikill < 125 then
        medals[hash].class.multikill = "Bronze"
        -- Declear the medal's class.
    elseif medals[hash].count.multikill > 125 and medals[hash].count.multikill < 500 then
        medals[hash].class.multikill = "Silver"
        -- Declear the medal's class.
    elseif medals[hash].count.multikill > 500 and medals[hash].count.multikill < 2500 then
        medals[hash].class.multikill = "Gold"
        -- Declear the medal's class.
    elseif medals[hash].count.multikill > 2500 and medals[hash].count.multikill < 5000 then
        medals[hash].class.multikill = "Onyx"
        -- Declear the medal's class.
    elseif medals[hash].count.multikill > 5000 and medals[hash].count.multikill < 15000 then
        medals[hash].class.multikill = "MAX"
        -- Declear the medal's class.
    elseif medals[hash].count.multikill > 15000 then
        medals[hash].class.multikill = "MAX"
        -- Declear the medal's class.
    end

    if medals[hash].count.sidearm > 50 and medals[hash].count.sidearm < 250 then
        medals[hash].class.sidearm = "Bronze"
    elseif medals[hash].count.sidearm > 250 and medals[hash].count.sidearm < 1000 then
        medals[hash].class.sidearm = "Silver"
    elseif medals[hash].count.sidearm > 1000 and medals[hash].count.sidearm < 4000 then
        medals[hash].class.sidearm = "Gold"
    elseif medals[hash].count.sidearm > 4000 and medals[hash].count.sidearm < 8000 then
        medals[hash].class.sidearm = "Onyx"
    elseif medals[hash].count.sidearm > 8000 and medals[hash].count.sidearm < 10000 then
        medals[hash].class.sidearm = "MAX"
    elseif medals[hash].count.sidearm > 10000 then
        medals[hash].class.sidearm = "MAX"
    end

    if medals[hash].count.triggerman > 100 and medals[hash].count.triggerman < 500 then
        medals[hash].class.triggerman = "Bronze"
    elseif medals[hash].count.triggerman > 500 and medals[hash].count.triggerman < 4000 then
        medals[hash].class.triggerman = "Silver"
    elseif medals[hash].count.triggerman > 4000 and medals[hash].count.triggerman < 10000 then
        medals[hash].class.triggerman = "Gold"
    elseif medals[hash].count.triggerman > 10000 and medals[hash].count.triggerman < 20000 then
        medals[hash].class.triggerman = "Onyx"
    elseif medals[hash].count.triggerman > 20000 and medals[hash].count.triggerman < 32000 then
        medals[hash].class.triggerman = "MAX"
    elseif medals[hash].count.triggerman > 32000 then
        medals[hash].class.triggerman = "MAX"
    end
end

function SendMessage(player, message)

    if getplayer(player) then
        sendconsoletext(player, message)
    end
end

function GetPlayerRank(player)

    local hash = gethash(player)
    -- Get the hash of the player.
    if hash then
        KillStats[hash].total.credits = KillStats[hash].total.credits or 0
        if KillStats[hash].total.credits > 0 and KillStats[hash].total.credits ~= nil and KillStats[hash].total.rank ~= nil then
            if KillStats[hash].total.credits >= 0 and KillStats[hash].total.credits < 7500 then
                -- 0 - 7,500
                KillStats[hash].total.rank = "Recruit"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 7500 and KillStats[hash].total.credits < 10000 then
                -- 7,500 - 10,000
                KillStats[hash].total.rank = "Private"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 10000 and KillStats[hash].total.credits < 15000 then
                -- 10,000 - 15,000
                KillStats[hash].total.rank = "Corporal"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 15000 and KillStats[hash].total.credits < 20000 then
                -- 15,000 - 20,000
                KillStats[hash].total.rank = "Sergeant"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 20000 and KillStats[hash].total.credits < 26250 then
                -- 20,000 - 26,250
                KillStats[hash].total.rank = "Sergeant Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 26250 and KillStats[hash].total.credits < 32500 then
                -- 26,250 - 32,500
                KillStats[hash].total.rank = "Sergeant Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 32500 and KillStats[hash].total.credits < 45000 then
                -- 32,500 - 45,000
                KillStats[hash].total.rank = "Warrant Officer"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 45000 and KillStats[hash].total.credits < 78000 then
                -- 45,000 - 78,000
                KillStats[hash].total.rank = "Warrant Officer Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 78000 and KillStats[hash].total.credits < 111000 then
                -- 78,000 - 111,000
                KillStats[hash].total.rank = "Warrant Officer Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 111000 and KillStats[hash].total.credits < 144000 then
                -- 111,000 - 144,000
                KillStats[hash].total.rank = "Warrant Officer Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 144000 and KillStats[hash].total.credits < 210000 then
                -- 144,000 - 210,000
                KillStats[hash].total.rank = "Captain"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 210000 and KillStats[hash].total.credits < 233000 then
                -- 210,000 - 233,000
                KillStats[hash].total.rank = "Captain Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 233000 and KillStats[hash].total.credits < 256000 then
                -- 233,000 - 256,000
                KillStats[hash].total.rank = "Captain Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 256000 and KillStats[hash].total.credits < 279000 then
                -- 256,000 - 279,000
                KillStats[hash].total.rank = "Captain Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 279000 and KillStats[hash].total.credits < 325000 then
                -- 279,000 - 325,000
                KillStats[hash].total.rank = "Major"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 325000 and KillStats[hash].total.credits < 350000 then
                -- 325,000 - 350,000
                KillStats[hash].total.rank = "Major Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 350000 and KillStats[hash].total.credits < 375000 then
                -- 350,000 - 375,000
                KillStats[hash].total.rank = "Major Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 375000 and KillStats[hash].total.credits < 400000 then
                -- 375,000 - 400,000
                KillStats[hash].total.rank = "Major Grade 3"
                -- Decide his rank
            elseif KillStats[hash].total.credits > 400000 and KillStats[hash].total.credits < 450000 then
                -- 400,000 - 450,000
                KillStats[hash].total.rank = "Lt. Colonel"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 450000 and KillStats[hash].total.credits < 480000 then
                -- 450,000 - 480,000
                KillStats[hash].total.rank = "Lt. Colonel Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 480000 and KillStats[hash].total.credits < 510000 then
                -- 480,000 - 510,000
                KillStats[hash].total.rank = "Lt. Colonel Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 510000 and KillStats[hash].total.credits < 540000 then
                -- 510,000 - 540,000
                KillStats[hash].total.rank = "Lt. Colonel Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 540000 and KillStats[hash].total.credits < 600000 then
                -- 540,000 - 600,000
                KillStats[hash].total.rank = "Commander"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 600000 and KillStats[hash].total.credits < 650000 then
                -- 600,000 - 650,000
                KillStats[hash].total.rank = "Commander Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 650000 and KillStats[hash].total.credits < 700000 then
                -- 650,000 - 700,000
                KillStats[hash].total.rank = "Commander Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 700000 and KillStats[hash].total.credits < 750000 then
                -- 700,000 - 750,000
                KillStats[hash].total.rank = "Commander Grade 3"
                -- Decide his rank
            elseif KillStats[hash].total.credits > 750000 and KillStats[hash].total.credits < 850000 then
                -- 750,000 - 850,000
                KillStats[hash].total.rank = "Colonel"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 850000 and KillStats[hash].total.credits < 960000 then
                -- 850,000 - 960,000
                KillStats[hash].total.rank = "Colonel Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 960000 and KillStats[hash].total.credits < 1070000 then
                -- 960,000 - 1,070,000
                KillStats[hash].total.rank = "Colonel Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 1070000 and KillStats[hash].total.credits < 1180000 then
                -- 1,070,000 - 1,180,000
                KillStats[hash].total.rank = "Colonel Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 1180000 and KillStats[hash].total.credits < 1400000 then
                -- 1,180,000 - 1,400,000
                KillStats[hash].total.rank = "Brigadier"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 1400000 and KillStats[hash].total.credits < 1520000 then
                -- 1,400,000 - 1,520,000
                KillStats[hash].total.rank = "Brigadier Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 1520000 and KillStats[hash].total.credits < 1640000 then
                -- 1,520,000 - 1,640,000
                KillStats[hash].total.rank = "Brigadier Grade 2"
                -- Decide his rank
            elseif KillStats[hash].total.credits > 1640000 and KillStats[hash].total.credits < 1760000 then
                -- 1,640,000 - 1,760,000
                KillStats[hash].total.rank = "Brigadier Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 1760000 and KillStats[hash].total.credits < 2000000 then
                -- 1,760,000 - 2,000,000
                KillStats[hash].total.rank = "General"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 2000000 and KillStats[hash].total.credits < 2200000 then
                -- 2,000,000 - 2,200,000
                KillStats[hash].total.rank = "General Grade 1"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 2200000 and KillStats[hash].total.credits < 2350000 then
                -- 2,200,000 - 2,350,000
                KillStats[hash].total.rank = "General Grade 2"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 2350000 and KillStats[hash].total.credits < 2500000 then
                -- 2,350,000 - 2,500,000
                KillStats[hash].total.rank = "General Grade 3"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 2500000 and KillStats[hash].total.credits < 2650000 then
                -- 2,500,000 - 2,650,000
                KillStats[hash].total.rank = "General Grade 4"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 2650000 and KillStats[hash].total.credits < 3000000 then
                -- 2,650,000 - 3,000,000
                KillStats[hash].total.rank = "Field Marshall"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 3000000 and KillStats[hash].total.credits < 3700000 then
                -- 3,000,000 - 3,700,000
                KillStats[hash].total.rank = "Hero"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 3700000 and KillStats[hash].total.credits < 4600000 then
                -- 3,700,000 - 4,600,000
                KillStats[hash].total.rank = "Legend"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 4600000 and KillStats[hash].total.credits < 5650000 then
                -- 4,600,000 - 5,650,000
                KillStats[hash].total.rank = "Mythic"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 5650000 and KillStats[hash].total.credits < 7000000 then
                -- 5,650,000 - 7,000,000
                KillStats[hash].total.rank = "Noble"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 7000000 and KillStats[hash].total.credits < 8500000 then
                -- 7,000,000 - 8,500,000
                KillStats[hash].total.rank = "Eclipse"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 8500000 and KillStats[hash].total.credits < 11000000 then
                -- 8,500,000 - 11,000,000
                KillStats[hash].total.rank = "Nova"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 11000000 and KillStats[hash].total.credits < 13000000 then
                -- 11,000,000 - 13,000,000
                KillStats[hash].total.rank = "Forerunner"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 13000000 and KillStats[hash].total.credits < 16500000 then
                -- 13,000,000 - 16,500,000
                KillStats[hash].total.rank = "Reclaimer"
                -- Decide his rank.
            elseif KillStats[hash].total.credits > 16500000 and KillStats[hash].total.credits < 20000000 then
                -- 16,500,000 - 20,000,000
                KillStats[hash].total.rank = "Inheritor"
                -- Decide his rank.
            end
        end
    end
end

function CreditsUntilNextPromo(player)

    local hash = gethash(player)
    KillStats[hash].total.rank = KillStats[hash].total.rank or "Recruit"
    KillStats[hash].total.credits = KillStats[hash].total.credits or 0

    if KillStats[hash].total.rank == "Recruit" then
        return 7500 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Private" then
        return 10000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Corporal" then
        return 15000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Sergeant" then
        return 20000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Sergeant Grade 1" then
        return 26250 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Sergeant Grade 2" then
        return 32500 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Warrant Officer" then
        return 45000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Warrant Officer Grade 1" then
        return 78000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Warrant Officer Grade 2" then
        return 111000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Warrant Officer Grade 3" then
        return 144000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Captain" then
        return 210000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Captain Grade 1" then
        return 233000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Captain Grade 2" then
        return 256000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Captain Grade 3" then
        return 279000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Major" then
        return 325000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Major Grade 1" then
        return 350000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Major Grade 2" then
        return 375000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Major Grade 3" then
        return 400000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Lt. Colonel" then
        return 450000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Lt. Colonel Grade 1" then
        return 480000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Lt. Colonel Grade 2" then
        return 510000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Lt. Colonel Grade 3" then
        return 540000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Commander" then
        return 600000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Commander Grade 1" then
        return 650000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Commander Grade 2" then
        return 700000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Commander Grade 3" then
        return 750000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Colonel" then
        return 850000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Colonel Grade 1" then
        return 960000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Colonel Grade 2" then
        return 1070000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Colonel Grade 3" then
        return 1180000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Brigadier" then
        return 1400000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Brigadier Grade 1" then
        return 1520000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Brigadier Grade 2" then
        return 1640000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Brigadier Grade 3" then
        return 1760000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "General" then
        return 2000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "General Grade 1" then
        return 2350000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "General Grade 2" then
        return 2500000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "General Grade 3" then
        return 2650000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "General Grade 4" then
        return 3000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Field Marshall" then
        return 3700000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Hero" then
        return 4600000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Legend" then
        return 5650000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Mythic" then
        return 7000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Noble" then
        return 8500000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Eclipse" then
        return 11000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Nova" then
        return 13000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Forerunner" then
        return 16500000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Reclaimer" then
        return 20000000 - KillStats[hash].total.credits
    elseif KillStats[hash].total.rank == "Inheritor" then
        return "Ranks Complete"
    end
end

function RuleTimer(id, count)

    local number = getvalidcount(count)
    if number ~= nil then
        if number == 1 then
            say("Blocking Ports / Pathways / Tunnels, Glitching into rocks/trees/out of map is not allowed.")
        elseif number == 2 then
            say("Team Grenading / Flipping / Shooting / Meleeing / Ramming is not allowed.")
        elseif number == 3 then
            say("For more indepth rules please go to \"www.OneWorldVirtual.ProBoards.com\"")
        elseif number == 4 then
            say("If you get stuck, you can type \"@stuck\" to find a way out.")
        elseif number == 5 then
            say("Type \"@info\" for all the commands to view your stats.")
        end
    end
    return true
end

function getvalidcount(count)

    local number = nil
    if table.find({ "180", "360", "540", "720", "900", "1080" }, count) then
        number = 1
    elseif table.find({ "182", "362", "542", "722", "902", "1082" }, count) then
        number = 2
    elseif table.find({ "184", "364", "544", "724", "904", "1084" }, count) then
        number = 3
    elseif table.find({ "186", "366", "546", "726", "906", "1086" }, count) then
        number = 4
    elseif table.find({ "188", "368", "548", "728", "908", "1088" }, count) then
        number = 5
    end

    return number
end

function secondsToTime(seconds, places)

    local years = math.floor(seconds / (60 * 60 * 24 * 365))
    seconds = seconds % (60 * 60 * 24 * 365)
    local weeks = math.floor(seconds / (60 * 60 * 24 * 7))
    seconds = seconds % (60 * 60 * 24 * 7)
    local days = math.floor(seconds / (60 * 60 * 24))
    seconds = seconds % (60 * 60 * 24)
    local hours = math.floor(seconds / (60 * 60))
    seconds = seconds % (60 * 60)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    if places == 6 then
        return string.format("%02d:%02d:%02d:%02d:%02d:%02d", years, weeks, days, hours, minutes, seconds)
    elseif places == 5 then
        return string.format("%02d:%02d:%02d:%02d:%02d", weeks, days, hours, minutes, seconds)
    elseif not places or places == 4 then
        return days, hours, minutes, seconds
    elseif places == 3 then
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    elseif places == 2 then
        return string.format("%02d:%02d", minutes, seconds)
    elseif places == 1 then
        return string.format("%02", seconds)
    end
end

WriteLog = function(filename, value)
    local dir = getprofilepath() .. "\\logs\\"
    local file = io.open(dir .. filename, "a")
    if file then
        local timestamp = os.date("%Y/%m/%d %H:%M:%S")
        local line = string.format("%s\t%s\n", timestamp, tostring(value))
        file:write(line)
        file:close()
    end
end

function setscore(player, score)
    if tonumber(score) then
        if gametype == 1 then
            -- CTF
            local m_player = getplayer(player)
            if score >= 0x7FFF then
                writewordsigned(m_player + 0xC8, 0x0, 0x7FFF)
            elseif score <= -0x7FFF then
                writewordsigned(m_player + 0xC8, 0x0, -0x7FFF)
            else
                writewordsigned(m_player + 0xC8, 0x0, score)
            end
        elseif gametype == 2 then
            -- Slayer
            if score >= 0x7FFFFFFF then
                writedwordsigned(slayer_globals + 0x40 + player * 4, 0x0, 0x7FFFFFFF)
            elseif score <= -0x7FFFFFFF then
                writedwordsigned(slayer_globals + 0x40 + player * 4, 0x0, -0x7FFFFFFF)
            else
                writedwordsigned(slayer_globals + 0x40 + player * 4, 0x0, score)
            end
        elseif gametype == 3 then
            -- Oddball
            local oddball_game = readbyte(gametype_base, 0x8C)
            if oddball_game == 0 or oddball_game == 1 then
                if score * 30 >= 0x7FFFFFFF then
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, 0x7FFFFFFF)
                elseif score * 30 <= -0x7FFFFFFF then
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, -1 * 0x7FFFFFFF)
                else
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, score * 30)
                end
            else
                if score > 0x7FFFFC17 then
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, 0x7FFFFC17)
                elseif score <= -0x7FFFFC17 then
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, -0x7FFFFC17)
                else
                    writedwordsigned(oddball_globals + 0x84 + player * 4, 0x0, score)
                end
            end
        elseif gametype == 4 then
            -- KOTH
            local m_player = getplayer(player)
            if score * 30 >= 0x7FFF then
                writewordsigned(m_player, 0xC4, 0x7FFF)
            elseif score * 30 <= -0x7FFF then
                writewordsigned(m_player, 0xC4, -0x7FFF)
            else
                writewordsigned(m_player, 0xC4, score * 30)
            end
        elseif gametype == 5 then
            -- Race
            local m_player = getplayer(player)
            if score >= 0x7FFF then
                writewordsigned(m_player + 0xC6, 0x0, 0x7FFF)
            elseif score <= -0x7FFF then
                writewordsigned(m_player + 0xC6, 0x0, -0x7FFF)
            else
                writewordsigned(m_player + 0xC6, 0x0, score)
            end
        end
    end
end

function writewordsigned(address, offset, word)
    value = tonumber(word)
    if value == nil then
        value = tonumber(word, 16)
    end
    if value and value > 0x7FFF then
        local max = 0xFFFF
        local difference = max - value
        value = -1 - difference
    end
    writeword(address, offset, value)
end

function writedwordsigned(address, offset, dword)
    value = tonumber(dword)
    if value == nil then
        value = tonumber(dword, 16)
    end
    if value and value > 0x7FFFFFFF then
        local max = 0xFFFFFFFF
        local difference = max - value
        value = -1 - difference
    end
    writedword(address, offset, value)
end

function changescore(player, number, type)
    local m_player = getplayer(player)
    if m_player then
        local player_flag_scores = readword(m_player + 0xC8)
        if type == plus or type == add then
            local score = player_flag_scores + number
            setscore(player, score)
        elseif type == take or type == minus or type == subtract then
            local score = player_flag_scores + math.abs(number)
            setscore(player, score)
        end
    end
end

function readstring(address, length, endian)
    local char_table = { }
    local string = ""
    local offset = offset or 0x0
    if length == nil then
        if readbyte(address + offset + 1) == 0 and readbyte(address + offset) ~= 0 then
            length = 51000
        else
            length = 256
        end
    end
    for i = 0, length do
        if readbyte(address + (offset + i)) ~= 0 then
            table.insert(char_table, string.char(readbyte(address + (offset + i))))
        elseif i % 2 == 0 and readbyte(address + offset + i) == 0 then
            break
        end
    end
    for k, v in pairs(char_table) do
        if endian == 1 then
            string = v .. string
        else
            string = string .. v
        end
    end
    return string
end

console = { }
console.__index = console
registertimer(100, "ConsoleTimer")
phasor_sendconsoletext = sendconsoletext
math.inf = 1 / 0

function sendconsoletext(player, message, time, order, func)
    console[player] = console[player] or { }

    local temp = { }
    temp.player = player
    temp.id = nextid(player, order)
    temp.message = message or ""
    temp.time = time or 3
    temp.remain = temp.time
    if type(func) == "function" then
        temp.func = func
    elseif type(func) == "string" then
        temp.func = _G[func]
    end

    console[player][temp.id] = temp
    setmetatable(console[player][temp.id], console)
    return console[player][temp.id]
end

function nextid(player, order)

    if not order then
        local x = 0
        for k, v in pairs(console[player]) do
            if k > x + 1 then
                return x + 1
            end

            x = x + 1
        end

        return x + 1
    else
        local original = order
        while console[player][order] do
            order = order + 0.001
            if order == original + 0.999 then
                break
            end
        end

        return order
    end
end

function getmessage(player, order)

    if console[player] then
        if order then
            return console[player][order]
        end
    end
end

function getmessages(player)

    return console[player]
end

function getmessageblock(player, order)

    local temp = { }

    for k, v in opairs(console[player]) do
        if k >= order and k < order + 1 then
            table.insert(temp, console[player][k])
        end
    end

    return temp
end

function console:getmessage()

    return self.message
end

function console:append(message, reset)

    if console[self.player] then
        if console[self.player][self.id] then
            if getplayer(self.player) then
                if reset then
                    if reset == true then
                        console[self.player][self.id].remain = console[self.player][self.id].time
                    elseif tonumber(reset) then
                        console[self.player][self.id].time = tonumber(reset)
                        console[self.player][self.id].remain = tonumber(reset)
                    end
                end

                console[self.player][self.id].message = message or ""
                return true
            end
        end
    end
end

function console:shift(order)

    local temp = console[self.player][self.id]
    console[self.player][self.id] = console[self.player][order]
    console[self.player][order] = temp
end

function console:pause(time)

    console[self.player][self.id].pausetime = time or 5
end

function console:delete()

    console[self.player][self.id] = nil
end

function ConsoleTimer(id, count)

    for i, _ in opairs(console) do
        if tonumber(i) then
            if getplayer(i) then
                for k, v in opairs(console[i]) do
                    if console[i][k].pausetime then
                        console[i][k].pausetime = console[i][k].pausetime - 0.1
                        if console[i][k].pausetime <= 0 then
                            console[i][k].pausetime = nil
                        end
                    else
                        if console[i][k].func then
                            if not console[i][k].func(i) then
                                console[i][k] = nil
                            end
                        end

                        if console[i][k] then
                            console[i][k].remain = console[i][k].remain - 0.1
                            if console[i][k].remain <= 0 then
                                console[i][k] = nil
                            end
                        end
                    end
                end

                if table.len(console[i]) > 0 then

                    local paused = 0
                    for k, v in pairs(console[i]) do
                        if console[i][k].pausetime then
                            paused = paused + 1
                        end
                    end

                    if paused < table.len(console[i]) then
                        local str = ""
                        for i = 0, 30 do
                            str = str .. " \n"
                        end

                        phasor_sendconsoletext(i, str)

                        for k, v in opairs(console[i]) do
                            if not console[i][k].pausetime then
                                if console[i][k].align == "right" or console[i][k].align == "center" then
                                    phasor_sendconsoletext(i, consolecenter(string.sub(console[i][k].message, 1, 78)))
                                else
                                    phasor_sendconsoletext(i, string.sub(console[i][k].message, 1, 78))
                                end
                            end
                        end
                    end
                end
            else
                console[i] = nil
            end
        end
    end

    return true
end

function consolecenter(text)

    if text then
        local len = string.len(text)
        for i = len + 1, 78 do
            text = " " .. text
        end

        return text
    end
end

function opairs(t)

    local keys = { }
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys,
            function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                end
                an = string.lower(tostring(a))
                bn = string.lower(tostring(b))
                if an ~= bn then
                    return an < bn
                else
                    return tostring(a) < tostring(b)
                end
            end)
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function table.len(t)

    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end

    return count
end
-- ====================================================================================================================================================================================================--
-- WILL BE USED IN A LATER UPDATE!
-- Zombies will be able to pickup the "Staff" - aka - flag, and it will give them special powers.
FLAG = { }
FLAG["beavercreek"] = { { 29.055599212646, 13.732000350952, -0.10000000149012 }, { -0.86037802696228, 13.764800071716, -0.0099999997764826 }, { 14.01514339447, 14.238339424133, -0.91193699836731 } }
FLAG["bloodgulch"] = { { 95.687797546387, -159.44900512695, -0.10000000149012 }, { 40.240600585938, -79.123199462891, -0.10000000149012 }, { 65.749893188477, -120.40949249268, 0.11860413849354 } }
FLAG["boardingaction"] = { { 1.723109960556, 0.4781160056591, 0.60000002384186 }, { 18.204000473022, -0.53684097528458, 0.60000002384186 }, { 4.3749675750732, -12.832932472229, 7.2201852798462 } }
FLAG["carousel"] = { { 5.6063799858093, -13.548299789429, -3.2000000476837 }, { -5.7499198913574, 13.886699676514, -3.2000000476837 }, { 0.033261407166719, 0.0034416019916534, -0.85620224475861 } }
FLAG["chillout"] = { { 7.4876899719238, -4.49059009552, 2.5 }, { -7.5086002349854, 9.750340461731, 0.10000000149012 }, { 1.392117857933, 4.7001452445984, 3.108856678009 } }
FLAG["damnation"] = { { 9.6933002471924, -13.340399742126, 6.8000001907349 }, { -12.17884349823, 14.982703208923, -0.20000000298023 }, { -2.0021493434906, -4.3015551567078, 3.3999974727631 } }
FLAG["dangercanyon"] = { { -12.104507446289, -3.4351840019226, -2.2419033050537 }, { 12.007399559021, -3.4513700008392, -2.2418999671936 }, { -0.47723594307899, 55.331966400146, 0.23940123617649 } }
FLAG["deathisland"] = { { -26.576030731201, -6.9761986732483, 9.6631727218628 }, { 29.843469619751, 15.971487045288, 8.2952880859375 }, { -30.282138824463, 31.312761306763, 16.601940155029 } }
FLAG["gephyrophobia"] = { { 26.884338378906, -144.71551513672, -16.049139022827 }, { 26.727857589722, 0.16621616482735, -16.048349380493 }, { 63.513668060303, -74.088592529297, -1.0624552965164 } }
FLAG["hangemhigh"] = { { 13.047902107239, 9.0331249237061, -3.3619771003723 }, { 32.655700683594, -16.497299194336, -1.7000000476837 }, { 21.020147323608, -4.6323413848877, -4.2290902137756 } }
FLAG["icefields"] = { { 24.85000038147, -22.110000610352, 2.1110000610352 }, { -77.860000610352, 86.550003051758, 2.1110000610352 }, { -26.032163619995, 32.365093231201, 9.0070295333862 } }
FLAG["infinity"] = { { 0.67973816394806, -164.56719970703, 15.039022445679 }, { -1.8581243753433, 47.779975891113, 11.791272163391 }, { 9.6316251754761, -64.030670166016, 7.7762198448181 } }
FLAG["longest"] = { { -12.791899681091, -21.6422996521, -0.40000000596046 }, { 11.034700393677, -7.5875601768494, -0.40000000596046 }, { -0.80207985639572, -14.566205024719, 0.16665624082088 } }
FLAG["prisoner"] = { { -9.3684597015381, -4.9481601715088, 5.6999998092651 }, { 9.3676500320435, 5.1193399429321, 5.6999998092651 }, { 0.90271377563477, 0.088873945176601, 1.392499089241 } }
FLAG["putput"] = { { -18.89049911499, -20.186100006104, 1.1000000238419 }, { 34.865299224854, -28.194700241089, 0.10000000149012 }, { -2.3500289916992, -21.121452331543, 0.90232092142105 } }
FLAG["ratrace"] = { { -4.2277698516846, -0.85564690828323, -0.40000000596046 }, { 18.613000869751, -22.652599334717, -3.4000000953674 }, { 8.6629104614258, -11.159770965576, 0.2217468470335 } }
FLAG["sidewinder"] = { { -32.038200378418, -42.066699981689, -3.7000000476837 }, { 30.351499557495, -46.108001708984, -3.7000000476837 }, { 2.0510597229004, 55.220195770264, -2.8019363880157 } }
FLAG["timberland"] = { { 17.322099685669, -52.365001678467, -17.751399993896 }, { -16.329900741577, 52.360000610352, -17.741399765015 }, { 1.2504668235779, -1.4873152971268, -21.264007568359 } }
FLAG["wizard"] = { { -9.2459697723389, 9.3335800170898, -2.5999999046326 }, { 9.1828498840332, -9.1805400848389, -2.5999999046326 }, { -5.035900592804, -5.0643291473389, -2.7504394054413 } }

-- ====================================================================================================================================================================================================--
-- Credits to the original creator(s): {FC}[ZÃ…]SlimJim														
-- 	Credits to Kennan for what ever he did to it.
-- This version of Zombies and Vehicles has been "Heavily Modified" by Chalwk: (Jericho Crosby)
-- I will add my change logs later. later.