--[[
--=====================================================================================================--
Script Name: Focal Point (beta v2.1), for SAPP (PC & CE)
Implementing API version: 1.11.0.0
Description:    This is my extension of a progression based game that was for Phasor, originally by SlimJim.
                Re-written and converted to SAPP.

Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
AnnounceRank = true
game_started = false
-- Save Player Data every x seconds?
SAVE_PLAYER_DATA = true
processid = 0
kill_count = 0
time = { }        -- Declare time. Used for PlayerIndex's time spent in server.
kills = { }
avenge = { }
killers = { }
xcoords = { }    -- Declare x coords. Used for distance traveled.
ycoords = { }    -- Declare y coords. Used for distance traveled.
zcoords = { }    -- Declare z coords. Used for distance traveled.
messages = { }
jointime = { }    -- Declare Jointime. Used for player's time spent in server.
last_damage = { }
data_folder = 'sapp\\'

-- How often should the server backup player data?
-- Save Data every (seconds)...
save_data = 180
-- How many seconds before players are warned that the server is about to save player data?
-- The reason for this warning is because the Data-Saving Method can cause temporary server lag, and people should be aware of that.
save_data_warning = 165

-- ================================================================]
-- Amount of Credits (cR) required for the next rank
-- Example, 7500 cR required to level up from Recruit >> Private.
-- Example, 10000 cR required to level up from Private >> Corporal.
-- ================================================================]
Recruit = 7500
Private = 10000
Corporal = 15000
Sergeant = 20000
Sergeant_Grade_1 = 26250
Sergeant_Grade_2 = 32500
Warrant_Officer = 45000
Warrant_Officer_Grade_1 = 78000
Warrant_Officer_Grade_2 = 111000
Warrant_Officer_Grade_3 = 144000
Captain = 210000
Captain_Grade_1 = 233000
Captain_Grade_2 = 256000
Captain_Grade_3 = 279000
Major = 325000
Major_Grade_1 = 350000
Major_Grade_2 = 375000
Major_Grade_3 = 400000
Lt_Colonel = 450000
Lt_Colonel_Grade_1 = 480000
Lt_Colonel_Grade_2 = 510000
Lt_Colonel_Grade_3 = 540000
Commander = 600000
Commander_Grade_1 = 650000
Commander_Grade_2 = 700000
Commander_Grade_3 = 750000
Colonel = 850000
Colonel_Grade_1 = 960000
Colonel_Grade_2 = 1070000
Colonel_Grade_3 = 1180000
Brigadier = 1400000
Brigadier_Grade_1 = 1520000
Brigadier_Grade_2 = 1640000
Brigadier_Grade_3 = 1760000
General = 2000000
General_Grade_1 = 2350000
General_Grade_2 = 2500000
General_Grade_3 = 2650000
General_Grade_4 = 3000000
Field_Marshall = 3700000
Hero = 4600000
Legend = 5650000
Mythic = 7000000
Noble = 8500000
Eclipse = 11000000
Nova = 13000000
Forerunner = 16500000
Reclaimer = 20000000
Inheritor = "Ranks Complete"
-- ===============================]
-- ===============================]

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb['EVENT_CHAT'], "OnServerChat")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")
    register_callback(cb["EVENT_GAME_START"], "OnNewGame")
    register_callback(cb['EVENT_PRESPAWN'], "OnPlayerPreSpawn")
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")
    LoadItems()
end

function OnScriptUnload()
    -- Save Tables --
    SaveTableData(sprees, "Sprees.txt")
    SaveTableData(medals, "Medals.txt")
    SaveTableData(stats, "Stats.txt")
    last_damage = { }
    save_data_timer = 0
    save_data_warn = 0
    SAVE_DATA_WARNING = false
    SAVE_DATA = false
end

function CheckType()
    type_is_koth = get_var(1, "$gt") == "koth"
    type_is_oddball = get_var(1, "$gt") == "oddball"
    type_is_race = get_var(1, "$gt") == "race"
    type_is_slayer = get_var(1, "$gt") == "slayer"
    if (type_is_koth) or (type_is_oddball) or (type_is_race) or (type_is_slayer) then
        unregister_callback(cb['EVENT_TICK'])
        unregister_callback(cb["EVENT_JOIN"])
        unregister_callback(cb["EVENT_DIE"])
        unregister_callback(cb['EVENT_CHAT'])
        unregister_callback(cb["EVENT_GAME_END"])
        unregister_callback(cb["EVENT_LEAVE"])
        unregister_callback(cb["EVENT_GAME_START"])
        unregister_callback(cb['EVENT_PRESPAWN'])
        unregister_callback(cb["EVENT_DAMAGE_APPLICATION"])
        cprint("Warning: This script doesn't support KOTH, ODDBALL, RACE or SLAYER", 4 + 8)
    end
end

function OnNewGame()
    CheckType()
    LoadItems()
    game_started = true
    OpenFiles()
    save_data_timer = 0
    save_data_warn = 0
    SAVE_DATA_WARNING = true
    SAVE_DATA = true
    for i = 1, 16 do
        if player_present(i) then
            last_damage[i] = 0
        end
    end
end

function OnGameEnd()
    save_data_timer = 0
    save_data_warn = 0
    SAVE_DATA_WARNING = false
    SAVE_DATA = false
    timer(10, "AssistDelay")
    for i = 1, 16 do
        if getplayer(i) then
            -- If the palyer has less than 3 Deaths on game end, then award them 15+ cR
            if read_word(getplayer(i) + 0xAE) < 3 then
                changescore(i, 15, true)
                SendMessage(i, "+15 (cR) - Less then 3 Deaths")
                killstats[gethash(i)].total.credits = killstats[gethash(i)].total.credits + 15
            end
            extra[gethash(i)].woops.gamesplayed = extra[gethash(i)].woops.gamesplayed + 1
            time = os.time() - jointime[gethash(i)]
            extra[gethash(i)].woops.time = extra[gethash(i)].woops.time + time
        end
    end

    for i = 1, 16 do
        if player_present(i) then
            last_damage[i] = 0
        end
    end

    SaveTableData(killstats, "KillStats.txt")
    SaveTableData(extra, "Extra.txt")
    SaveTableData(done, "CompletedMedals.txt")
    SaveTableData(sprees, "Sprees.txt")
    SaveTableData(stats, "Stats.txt")
    SaveTableData(medals, "Medals.txt")
    SaveTableData(extra, "Extra.txt")

    game_started = false
end

function OnPlayerPreSpawn(PlayerIndex)
    last_damage[PlayerIndex] = 0
end

function WelcomeHandler(PlayerIndex)
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    ServerName = read_widestring(network_struct + 0x8, 0x42)
    execute_command("msg_prefix \"\"")
    say(PlayerIndex, "Welcome to " .. ServerName)
    execute_command("msg_prefix \"** SERVER ** \"")
end

function OnServerChat(PlayerIndex, Message)
    local message = string.lower(Message)
    local t = tokenizestring(Message, " ")
    local count = #t

    if PlayerIndex ~= nil then
        local hash = get_var(PlayerIndex, "$hash")
        if message == "@info" then
            rprint(PlayerIndex, "\"@weapons\":  Will display stats for eash weapon.")
            rprint(PlayerIndex, "\"@stats\":  Will display about your kills, deaths etc.")
            rprint(PlayerIndex, "\"@sprees\":  Will display info about your Killing Spreees.")
            rprint(PlayerIndex, "\"@rank\":  Will display info about your rank.")
            rprint(PlayerIndex, "\"@medals\":  Will display info about your medals.")
            return false
        elseif message == "@weapons" then
            -- =========================================================================================================================================================================
            rprint(PlayerIndex, "Assault Rifle: " .. stats[hash].kills.assaultrifle .. " | Banshee: " .. stats[hash].kills.banshee .. " | Banshee Fuel Rod: " .. stats[hash].kills.bansheefuelrod .. " | Chain Hog: " .. stats[hash].kills.chainhog)
            rprint(PlayerIndex, "EMP Blast: " .. extra[hash].woops.empblast .. " | Flame Thrower: " .. stats[hash].kills.flamethrower .. " | Frag Grenade: " .. stats[hash].kills.fragnade .. " | Fuel Rod: " .. stats[hash].kills.fuelrod)
            rprint(PlayerIndex, "Ghost: " .. stats[hash].kills.ghost .. " | Melee: " .. stats[hash].kills.melee .. " | Needler: " .. stats[hash].kills.needler .. " | People Splattered: " .. stats[hash].kills.splatter)
            rprint(PlayerIndex, "Pistol: " .. stats[hash].kills.pistol .. " | Plasma Grenade: " .. stats[hash].kills.plasmanade .. " | Plasma Pistol: " .. stats[hash].kills.plasmapistol .. " | Plasma Rifle: " .. stats[hash].kills.plasmarifle)
            rprint(PlayerIndex, "Rocket Hog: " .. extra[hash].woops.rockethog .. " | Rocket Launcher: " .. stats[hash].kills.rocket .. " | Shotgun: " .. stats[hash].kills.shotgun .. " | Sniper Rifle: " .. stats[hash].kills.sniper)
            rprint(PlayerIndex, "Stuck Grenade: " .. stats[hash].kills.grenadestuck .. " | Tank Machine Gun: " .. stats[hash].kills.tankmachinegun .. " | Tank Shell: " .. stats[hash].kills.tankshell .. " | Turret: " .. stats[hash].kills.turret)
            -- =========================================================================================================================================================================
            return false
        elseif message == "@stats" then
            -- =========================================================================================================================================================================
            local Player_KDR = RetrievePlayerKDR(PlayerIndex)
            local cpm = math.round(killstats[hash].total.credits / extra[hash].woops.gamesplayed, 2)
            if cpm == 0 or cpm == nil then
                cpm = "No credits earned"
            end
            local days, hours, minutes, seconds = secondsToTime(extra[hash].woops.time, 4)
            -- =========================================================================================================================================================================
            rprint(PlayerIndex, "Kills: " .. killstats[hash].total.kills .. " | Deaths: " .. killstats[hash].total.deaths .. " | Assists: " .. killstats[hash].total.assists)
            rprint(PlayerIndex, "KDR: " .. Player_KDR .. " | Suicides: " .. killstats[hash].total.suicides .. " | Betrays: " .. killstats[hash].total.betrays)
            rprint(PlayerIndex, "Games Played: " .. extra[hash].woops.gamesplayed .. " | Time in Server: " .. days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s")
            rprint(PlayerIndex, "Distance Traveled: " .. math.round(extra[hash].woops.distance / 1000, 2) .. " kilometers | Credits Per Map: " .. cpm)
            -- =========================================================================================================================================================================
            return false
        elseif message == "@sprees" then
            -- =========================================================================================================================================================================
            rprint(PlayerIndex, "Double Kill: " .. sprees[hash].count.double .. " | Triple Kill: " .. sprees[hash].count.triple .. " | Overkill: " .. sprees[hash].count.overkill .. " | Killtacular: " .. sprees[hash].count.killtacular)
            rprint(PlayerIndex, "Killtrocity: " .. sprees[hash].count.killtrocity .. " | Killimanjaro " .. sprees[hash].count.killimanjaro .. " | Killtastrophe: " .. sprees[hash].count.killtastrophe .. " | Killpocalypse: " .. sprees[hash].count.killpocalypse)
            rprint(PlayerIndex, "Killionaire: " .. sprees[hash].count.killionaire .. " | Kiling Spree " .. sprees[hash].count.killingspree .. " | Killing Frenzy: " .. sprees[hash].count.killingfrenzy .. " | Running Riot: " .. sprees[hash].count.runningriot)
            rprint(PlayerIndex, "Rampage: " .. sprees[hash].count.rampage .. " | Untouchable: " .. sprees[hash].count.untouchable .. " | Invincible: " .. sprees[hash].count.invincible .. " | Anomgstopkillingme: " .. sprees[hash].count.anomgstopkillingme)
            rprint(PlayerIndex, "Unfrigginbelievable: " .. sprees[hash].count.unfrigginbelievable .. " | Minutes as Last Man Standing: " .. sprees[hash].count.timeaslms)
            -- =========================================================================================================================================================================
            return false
        elseif message == "@rank" then
            local credits = { }
            for k, _ in pairs(killstats) do
                table.insert(credits, { ["hash"] = k, ["credits"] = killstats[k].total.credits })
            end

            table.sort(credits, function(a, b)
                return a.credits > b.credits
            end)

            for k, _ in ipairs(credits) do
                if hash == credits[k].hash then
                    local until_next_rank = CreditsUntilNextPromo(PlayerIndex)
                    -- =========================================================================================================================================================================
                    rprint(PlayerIndex, "You are ranked " .. k .. " out of " .. #credits .. "!")
                    rprint(PlayerIndex, "Credits: " .. killstats[hash].total.credits .. " | Rank: " .. killstats[hash].total.rank)
                    rprint(PlayerIndex, "Credits Until Next Rank: " .. until_next_rank)
                    -- =========================================================================================================================================================================
                end
            end
            return false
        elseif message == "@medals" then
            -- =========================================================================================================================================================================
            rprint(PlayerIndex, "Any Spree: " .. medals[hash].class.sprees .. " (" .. medals[hash].count.sprees .. ") | Assistant: " .. medals[hash].class.assists .. " (" .. medals[hash].count.assists .. ") | Close Quarters: " .. medals[hash].class.closequarters .. " (" .. medals[hash].count.assists .. ")")
            rprint(PlayerIndex, "Crack Shot: " .. medals[hash].class.crackshot .. " (" .. medals[hash].count.crackshot .. ") | Roadrage: " .. medals[hash].class.roadrage .. " (" .. medals[hash].count.roadrage .. ") | Grenadier: " .. medals[hash].class.grenadier .. " (" .. medals[hash].count.grenadier .. ")")
            rprint(PlayerIndex, "Heavy Weapons: " .. medals[hash].class.heavyweapons .. " (" .. medals[hash].count.heavyweapons .. ") | Jack of all Trades: " .. medals[hash].class.jackofalltrades .. " (" .. medals[hash].count.jackofalltrades .. ") | Mobile Asset: " .. medals[hash].class.mobileasset .. " (" .. medals[hash].count.moblieasset .. ")")
            rprint(PlayerIndex, "Multi Kill: " .. medals[hash].class.multikill .. " (" .. medals[hash].count.multikill .. ") | Sidearm: " .. medals[hash].class.sidearm .. " (" .. medals[hash].count.sidearm .. ") | Trigger Man: " .. medals[hash].class.triggerman .. " (" .. medals[hash].count.triggerman .. ")")
            -- =========================================================================================================================================================================
            return false
        end

        if t[1] == "@weapons" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rcon_id
                    if Player then
                        if hash then
                            rprint(PlayerIndex, getname(Player) .. "'s Weapon Stats")
                            rprint(PlayerIndex, "Assault Rifle: " .. stats[hash].kills.assaultrifle .. " | Banshee: " .. stats[hash].kills.banshee .. " | Banshee Fuel Rod: " .. stats[hash].kills.bansheefuelrod .. " | Chain Hog: " .. stats[hash].kills.chainhog)
                            rprint(PlayerIndex, "EMP Blast: " .. extra[hash].woops.empblast .. " | Flame Thrower: " .. stats[hash].kills.flamethrower .. " | Frag Grenade: " .. stats[hash].kills.fragnade .. " | Fuel Rod: " .. stats[hash].kills.fuelrod)
                            rprint(PlayerIndex, "Ghost: " .. stats[hash].kills.ghost .. " | Melee: " .. stats[hash].kills.melee .. " | Needler: " .. stats[hash].kills.needler .. " | People Splattered: " .. stats[hash].kills.splatter)
                            rprint(PlayerIndex, "Pistol: " .. stats[hash].kills.pistol .. " | Plasma Grenade: " .. stats[hash].kills.plasmanade .. " | Plasma Pistol: " .. stats[hash].kills.plasmapistol .. " | Plasma Rifle: " .. stats[hash].kills.plasmarifle)
                            rprint(PlayerIndex, "Rocket Hog: " .. extra[hash].woops.rockethog .. " | Rocket Launcher: " .. stats[hash].kills.rocket .. " | Shotgun: " .. stats[hash].kills.shotgun .. " | Sniper Rifle: " .. stats[hash].kills.sniper)
                            rprint(PlayerIndex, "Stuck Grenade: " .. stats[hash].kills.grenadestuck .. " | Tank Machine Gun: " .. stats[hash].kills.tankmachinegun .. " | Tank Shell: " .. stats[hash].kills.tankshell .. " | Turret: " .. stats[hash].kills.turret)
                            -- =========================================================================================================================================================================
                        end
                    end
                end
            end
            return false
        elseif t[1] == "@stats" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rcon_id
                    if Player then
                        if hash then
                            local Player_KDR = RetrievePlayerKDR(Player)
                            local cpm = math.round(killstats[hash].total.credits / extra[hash].woops.gamesplayed, 2)
                            if cpm == 0 or cpm == nil then
                                cpm = "No credits earned"
                            end
                            local days, hours, minutes, seconds = secondsToTime(extra[hash].woops.time, 4)
                            -- =========================================================================================================================================================================
                            rprint(PlayerIndex, getname(Player) .. "'s Stats.")
                            rprint(PlayerIndex, "Kills: " .. killstats[hash].total.kills .. " | Deaths: " .. killstats[hash].total.deaths .. " | Assists: " .. killstats[hash].total.assists)
                            rprint(PlayerIndex, "KDR: " .. Player_KDR .. " | Suicides: " .. killstats[hash].total.suicides .. " | Betrays: " .. killstats[hash].total.betrays)
                            rprint(PlayerIndex, "Games Played: " .. extra[hash].woops.gamesplayed .. " | Time in Server: " .. days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s")
                            rprint(PlayerIndex, "Distance Traveled: " .. math.round(extra[hash].woops.distance / 1000, 2) .. " kilometers | Credits Per Map: " .. cpm)
                            -- =========================================================================================================================================================================
                        else
                            rprint(PlayerIndex, "Script Error! Please try again!")
                        end
                    else
                        rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@sprees" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rcon_id
                    if Player then
                        if hash then
                            -- =========================================================================================================================================================================
                            rprint(PlayerIndex, getname(Player) .. "'s Spree Stats.")
                            rprint(PlayerIndex, "Double Kill: " .. sprees[hash].count.double .. " | Triple Kill: " .. sprees[hash].count.triple .. " | Overkill: " .. sprees[hash].count.overkill .. " | Killtacular: " .. sprees[hash].count.killtacular)
                            rprint(PlayerIndex, "Killtrocity: " .. sprees[hash].count.killtrocity .. " | Killimanjaro " .. sprees[hash].count.killimanjaro .. " | Killtastrophe: " .. sprees[hash].count.killtastrophe .. " | Killpocalypse: " .. sprees[hash].count.killpocalypse)
                            rprint(PlayerIndex, "Killionaire: " .. sprees[hash].count.killionaire .. " | Kiling Spree " .. sprees[hash].count.killingspree .. " | Killing Frenzy: " .. sprees[hash].count.killingfrenzy .. " | Running Riot: " .. sprees[hash].count.runningriot)
                            rprint(PlayerIndex, "Rampage: " .. sprees[hash].count.rampage .. " | Untouchable: " .. sprees[hash].count.untouchable .. " | Invincible: " .. sprees[hash].count.invincible .. " | Anomgstopkillingme: " .. sprees[hash].count.anomgstopkillingme)
                            rprint(PlayerIndex, "Unfrigginbelievable: " .. sprees[hash].count.unfrigginbelievable .. " | Minutes as Last Man Standing: " .. sprees[hash].count.timeaslms)
                            -- =========================================================================================================================================================================
                        else
                            rprint(PlayerIndex, "Script Error! Please try again!")
                        end
                    else
                        rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@rank" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rcon_id
                    if Player then
                        if hash then
                            local credits = { }
                            for k, _ in pairs(killstats) do
                                table.insert(credits, { ["hash"] = k, ["credits"] = killstats[k].total.credits })
                            end

                            table.sort(credits, function(a, b)
                                return a.credits > b.credits
                            end)

                            for k, _ in ipairs(credits) do
                                if hash == credits[k].hash then
                                    local until_next_rank = CreditsUntilNextPromo(Player)
                                    if until_next_rank == nil then
                                        until_next_rank = "Unknown - " .. getname(Player) .. " is a new PlayerIndex"
                                    end
                                    -- =========================================================================================================================================================================
                                    rprint(PlayerIndex, getname(Player) .. " is ranked " .. k .. " out of " .. #credits .. "!")
                                    rprint(PlayerIndex, "Credits: " .. killstats[hash].total.credits .. " | Rank: " .. killstats[hash].total.rank)
                                    rprint(PlayerIndex, "Credits Until Next Rank: " .. until_next_rank)
                                    -- =========================================================================================================================================================================
                                end
                            end
                        else
                            rprint(PlayerIndex, "Script Error! Please try again!")
                        end
                    else
                        rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        elseif t[1] == "@medals" then
            if t[2] then
                local rcon_id = tonumber(t[2])
                if rcon_id then
                    local Player = rcon_id
                    if Player then
                        if hash then
                            -- =========================================================================================================================================================================
                            rprint(PlayerIndex, getname(Player) .. "'s Medal Stats.")
                            rprint(PlayerIndex, "Any Spree: " .. medals[hash].class.sprees .. " (" .. medals[hash].count.sprees .. ") | Assistant: " .. medals[hash].class.assists .. " (" .. medals[hash].count.assists .. ") | Close Quarters: " .. medals[hash].class.closequarters .. " (" .. medals[hash].count.assists .. ")")
                            rprint(PlayerIndex, "Crack Shot: " .. medals[hash].class.crackshot .. " (" .. medals[hash].count.crackshot .. ") | Roadrage: " .. medals[hash].class.roadrage .. " (" .. medals[hash].count.roadrage .. ") | Grenadier: " .. medals[hash].class.grenadier .. " (" .. medals[hash].count.grenadier .. ")")
                            rprint(PlayerIndex, "Heavy Weapons: " .. medals[hash].class.heavyweapons .. " (" .. medals[hash].count.heavyweapons .. ") | Jack of all Trades: " .. medals[hash].class.jackofalltrades .. " (" .. medals[hash].count.jackofalltrades .. ") | Mobile Asset: " .. medals[hash].class.mobileasset .. " (" .. medals[hash].count.moblieasset .. ")")
                            rprint(PlayerIndex, "Multi Kill: " .. medals[hash].class.multikill .. " (" .. medals[hash].count.multikill .. ") | Sidearm: " .. medals[hash].class.sidearm .. " (" .. medals[hash].count.sidearm .. ") | Trigger Man: " .. medals[hash].class.triggerman .. " (" .. medals[hash].count.triggerman .. ")")
                            -- =========================================================================================================================================================================
                        else
                            rprint(PlayerIndex, "Script Error! Please try again!")
                        end
                    else
                        rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats! They must be in the server!")
                    end
                else
                    rprint(PlayerIndex, "Please enter a number between 1 and 16 to view their stats!")
                end
            end
            return false
        end
    end
end

function OnPlayerJoin(PlayerIndex)
    DeclearNewPlayerStats(gethash(PlayerIndex))
    timer(1000 * 300, "CreditTimer", PlayerIndex)
    GetMedalClasses(PlayerIndex)
    GetPlayerRank(PlayerIndex)
    jointime[gethash(PlayerIndex)] = os.time()
    local player_static = get_player(PlayerIndex)
    xcoords[gethash(PlayerIndex)] = read_float(player_static + 0xF8)
    ycoords[gethash(PlayerIndex)] = read_float(player_static + 0xFC)
    zcoords[gethash(PlayerIndex)] = read_float(player_static + 0x100)
    timer(1000 * 6, "WelcomeHandler", PlayerIndex)
    killers[PlayerIndex] = { }
    if AnnounceRank == true then
        AnnouncePlayerRank(PlayerIndex)
    end
end

function CreditTimer(PlayerIndex)
    if game_started == true then
        if player_present(PlayerIndex) then
            SendMessage(PlayerIndex, "+25 cR - 5 minutes in the server")
            changescore(PlayerIndex, 25, true)
            if killstats[gethash(PlayerIndex)].total.credits ~= nil then
                killstats[gethash(PlayerIndex)].total.credits = killstats[gethash(PlayerIndex)].total.credits + 15
            else
                killstats[gethash(PlayerIndex)].total.credits = 15
            end
        end
        return true
    else
        return false
    end
end

function OnPlayerLeave(PlayerIndex)
    last_damage[PlayerIndex] = nil
    kills[gethash(PlayerIndex)] = 0
    extra[gethash(PlayerIndex)].woops.time = extra[gethash(PlayerIndex)].woops.time + os.time() - jointime[gethash(PlayerIndex)]
end

function OnPlayerDeath(PlayerIndex, KillerIndex)
    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)
    -- Player Name --
    VictimName = get_var(PlayerIndex, "$name")
    KillerName = get_var(KillerIndex, "$name")
    -- Player Team --
    KillerTeam = get_var(KillerIndex, "$team")
    VictimTeam = get_var(PlayerIndex, "$team")

    -- KILLED BY SERVER --
    if (killer == -1) then
        mode = 0
    end
    -- FALL / DISTANCE DAMAGE
    if last_damage[PlayerIndex] == falling_damage or last_damage[PlayerIndex] == distance_damage then
        mode = 1
    end
    -- GUARDIANS / UNKNOWN --
    if (killer == nil) then
        mode = 2
    end
    -- KILLED BY VEHICLE --
    if (killer == 0) then
        mode = 3
    end
    -- KILLED BY KILLER --
    if (killer > 0) and (victim ~= killer) then
        mode = 4
    end
    -- BETRAY / TEAM KILL --
    if (KillerTeam == VictimTeam) and (PlayerIndex ~= KillerIndex) then
        mode = 5
    end
    -- SUICIDE --
    if tonumber(PlayerIndex) == tonumber(KillerIndex) then
        mode = 6
    end

    if mode == 4 then
        local hash = gethash(killer)
        local m_object = read_dword(get_player(victim) + 0x34)
        -- Weapon Melee --
        if last_damage[PlayerIndex] == flag_melee or
                last_damage[PlayerIndex] == ball_melee or
                last_damage[PlayerIndex] == pistol_melee or
                last_damage[PlayerIndex] == needle_melee or
                last_damage[PlayerIndex] == shotgun_melee or
                last_damage[PlayerIndex] == flame_melee or
                last_damage[PlayerIndex] == sniper_melee or
                last_damage[PlayerIndex] == prifle_melee or
                last_damage[PlayerIndex] == ppistol_melee or
                last_damage[PlayerIndex] == assault_melee or
                last_damage[PlayerIndex] == rocket_melee then
            medals[hash].count.closequarters = medals[hash].count.closequarters + 1
            stats[hash].kills.melee = stats[hash].kills.melee + 1
            SendMessage(PlayerIndex, " -10 (cR) - You were Meleed by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 10, false)
            changescore(killer, 13, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
            SendMessage(killer, " +13 (cR)")


            -- Grenades --
        elseif last_damage[PlayerIndex] == frag_explode then
            medals[hash].count.grenadier = medals[hash].count.grenadier + 1
            stats[hash].kills.fragnade = stats[hash].kills.fragnade + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were blown up by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == plasma_attach then
            medals[hash].count.grenadier = medals[hash].count.grenadier + 1
            stats[hash].kills.grenadestuck = stats[hash].kills.grenadestuck + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were blown up by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == plasma_explode then
            medals[hash].count.grenadier = medals[hash].count.grenadier + 1
            stats[hash].kills.plasmanade = stats[hash].kills.plasmanade + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were blown up by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

            -- Vehicle Collision --
        elseif last_damage[PlayerIndex] == veh_damage then
            stats[hash].kills.splatter = stats[hash].kills.splatter + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -10 (cR) - You were run over by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 10, false)
            changescore(killer, 13, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
            SendMessage(killer, " +13 (cR)")

            -- Vehicle Projectiles --
        elseif last_damage[PlayerIndex] == banshee_explode then
            stats[hash].kills.bansheefuelrod = stats[hash].kills.bansheefuelrod + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -10 (cR) - You were blown up by " .. get_var(killer, "$name") .. " with a Banshee Fuel Rod")
            changescore(PlayerIndex, 10, false)
            changescore(killer, 13, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
            SendMessage(killer, " +13 (cR)")

        elseif last_damage[PlayerIndex] == banshee_bolt then
            stats[hash].kills.banshee = stats[hash].kills.banshee + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a Banshee Bolt")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == turret_bolt then
            stats[hash].kills.turret = stats[hash].kills.turret + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -3 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a Turret")
            changescore(PlayerIndex, 3, false)
            changescore(killer, 6, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 6
            SendMessage(killer, " +6 (cR)")

        elseif last_damage[PlayerIndex] == ghost_bolt then
            stats[hash].kills.ghost = stats[hash].kills.ghost + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -4 (cR) - You were shot by " .. get_var(killer, "$name") .. " with ghost bolt")
            changescore(PlayerIndex, 4, false)
            changescore(killer, 7, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 7
            SendMessage(killer, " +7 (cR)")

        elseif last_damage[PlayerIndex] == tank_bullet then
            stats[hash].kills.tankmachinegun = stats[hash].kills.tankmachinegun + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. " with tank bullet")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == tank_shell then
            stats[hash].kills.tankshell = stats[hash].kills.tankshell + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -10 (cR) - You were blown up by " .. get_var(killer, "$name") .. " with tank shell")
            changescore(PlayerIndex, 10, false)
            changescore(killer, 13, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
            SendMessage(killer, " +13 (cR)")

        elseif last_damage[PlayerIndex] == chain_bullet then
            stats[hash].kills.chainhog = stats[hash].kills.chainhog + 1
            medals[hash].count.moblieasset = medals[hash].count.moblieasset + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. "'s Warthog chain gun bullets")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

            -- Weapon Projectiles --
        elseif last_damage[PlayerIndex] == assault_bullet then
            stats[hash].kills.assaultrifle = stats[hash].kills.assaultrifle + 1
            medals[hash].count.triggerman = medals[hash].count.triggerman + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. " with an assault rifle")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == flame_explode then
            medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
            stats[hash].kills.flamethrower = stats[hash].kills.flamethrower + 1
            SendMessage(PlayerIndex, " -3 (cR) - You were burnt to a crisp by " .. get_var(killer, "$name") .. "'s flame thrower")
            changescore(PlayerIndex, 3, false)
            changescore(killer, 6, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 6
            SendMessage(killer, " +6 (cR)")

        elseif last_damage[PlayerIndex] == needle_detonate or last_damage[PlayerIndex] == needle_explode or last_damage[PlayerIndex] == needle_impact then
            medals[hash].count.triggerman = medals[hash].count.triggerman + 1
            stats[hash].kills.needler = stats[hash].kills.needler + 1
            SendMessage(PlayerIndex, " -4 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a needler")
            changescore(PlayerIndex, 4, false)
            changescore(killer, 7, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 7
            SendMessage(killer, " +7 (cR)")

        elseif last_damage[PlayerIndex] == pistol_bullet then
            stats[hash].kills.pistol = stats[hash].kills.pistol + 1
            medals[hash].count.sidearm = medals[hash].count.sidearm + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a pistol")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == ppistol_bolt then
            stats[hash].kills.plasmapistol = stats[hash].kills.plasmapistol + 1
            medals[hash].count.sidearm = medals[hash].count.sidearm + 1
            SendMessage(PlayerIndex, " -3 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a plasma pistol")
            changescore(PlayerIndex, 3, false)
            changescore(killer, 6, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 6
            SendMessage(killer, " +6 (cR)")

        elseif last_damage[PlayerIndex] == ppistol_charged then
            extra[hash].woops.empblast = extra[hash].woops.empblast + 1
            medals[hash].count.jackofalltrades = medals[hash].count.jackofalltrades + 1
            SendMessage(PlayerIndex, " -3 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a charged plasma pistol")
            changescore(PlayerIndex, 3, false)
            changescore(killer, 6, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 6
            SendMessage(killer, " +6 (cR)")

        elseif last_damage[PlayerIndex] == prifle_bolt then
            stats[hash].kills.plasmarifle = stats[hash].kills.plasmarifle + 1
            medals[hash].count.triggerman = medals[hash].count.triggerman + 1
            SendMessage(PlayerIndex, " -4 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a plasma rifle")
            changescore(PlayerIndex, 4, false)
            changescore(killer, 7, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 7
            SendMessage(killer, " +7 (cR)")

        elseif last_damage[PlayerIndex] == pcannon_explode then
            medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
            stats[hash].kills.fuelrod = stats[hash].kills.fuelrod + 1
            SendMessage(PlayerIndex, " -8 (cR) - You were blown up by " .. get_var(killer, "$name") .. " with a plasma cannon")
            changescore(PlayerIndex, 8, false)
            changescore(killer, 11, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 11
            SendMessage(killer, " +11 (cR)")

        elseif last_damage[PlayerIndex] == rocket_explode then
            if m_object then
                if read_byte(m_object + 0x2A0) == 1 then
                    -- obj_crouch
                    extra[hash].woops.rockethog = extra[hash].woops.rockethog + 1
                    SendMessage(PlayerIndex, " -10 (cR) - You were blown up by " .. get_var(killer, "$name") .. "'s Rocket-Hog Rocket")
                    changescore(PlayerIndex, 10, false)
                    changescore(killer, 13, true)
                    killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
                    SendMessage(killer, " +13 (cR)")
                else
                    medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                    stats[hash].kills.rocket = stats[hash].kills.rocket + 1
                    SendMessage(PlayerIndex, " -10 (cR) - You were blown up by " .. get_var(killer, "$name") .. " with a rocket launcher")
                    changescore(PlayerIndex, 10, false)
                    changescore(killer, 13, true)
                    killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
                    SendMessage(killer, " +13 (cR)")
                end
            else
                medals[hash].count.heavyweapons = medals[hash].count.heavyweapons + 1
                stats[hash].kills.rocket = stats[hash].kills.rocket + 1
                SendMessage(PlayerIndex, " -10 (cR) - You were blown up!")
                changescore(PlayerIndex, 10, false)
                changescore(killer, 13, true)
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
                SendMessage(killer, " +13 (cR)")
            end
        elseif last_damage[PlayerIndex] == shotgun_pellet then
            medals[hash].count.closequarters = medals[hash].count.closequarters + 1
            stats[hash].kills.shotgun = stats[hash].kills.shotgun + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a shotgun")
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")

        elseif last_damage[PlayerIndex] == sniper_bullet then
            medals[hash].count.crackshot = medals[hash].count.crackshot + 1
            stats[hash].kills.sniper = stats[hash].kills.sniper + 1
            SendMessage(PlayerIndex, " -10 (cR) - You were shot by " .. get_var(killer, "$name") .. " with a sniper rifle")
            changescore(PlayerIndex, 10, false)
            changescore(killer, 13, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 13
            SendMessage(killer, " +13 (cR)")
        elseif last_damage[PlayerIndex] == "backtap" then
            medals[hash].count.closequarters = medals[hash].count.closequarters + 1
            stats[hash].kills.melee = stats[hash].kills.melee + 1
            SendMessage(PlayerIndex, " -5 (cR) - You were back-tapped by " .. get_var(killer, "$name"))
            changescore(PlayerIndex, 5, false)
            changescore(killer, 8, true)
            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 8
            SendMessage(killer, " +8 (cR)")
        end
    end
    if game_started == true then
        -- 		mode 0: Killed by server
        if mode == 0 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            -- 		mode 1: Killed by fall damage
        elseif mode == 1 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            -- 		mode 2: Killed by guardians
        elseif mode == 2 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            -- 		mode 3: Killed by vehicle
        elseif mode == 3 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            -- 		mode 4: Killed by killer
        elseif mode == 4 then

            if table.find(killers[victim], killer, false) == nil then
                table.insert(killers[victim], killer)
            end

            killstats[gethash(killer)].total.kills = killstats[gethash(killer)].total.kills + 1
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1

            if read_word(getplayer(killer) + 0x9C) == 10 then
                changescore(killer, 5, true)
                SendMessage(killer, "+5 (cR) - 10 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
            elseif read_word(getplayer(killer) + 0x9C) == 20 then
                changescore(killer, 5, true)
                SendMessage(killer, "+5 (cR) - 20 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
            elseif read_word(getplayer(killer) + 0x9C) == 30 then
                changescore(killer, 5, true)
                SendMessage(killer, "+5 (cR) - 30 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
            elseif read_word(getplayer(killer) + 0x9C) == 40 then
                changescore(killer, 5, true)
                SendMessage(killer, "+5 (cR) - 40 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
            elseif read_word(getplayer(killer) + 0x9C) == 50 then
                changescore(killer, 10, true)
                SendMessage(killer, "+10 (cR) - 50 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
            elseif read_word(getplayer(killer) + 0x9C) == 60 then
                changescore(killer, 10, true)
                SendMessage(killer, "+10 (cR) - 60 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
            elseif read_word(getplayer(killer) + 0x9C) == 70 then
                changescore(killer, 10, true)
                SendMessage(killer, "+10 (cR) - 70 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
            elseif read_word(getplayer(killer) + 0x9C) == 80 then
                changescore(killer, 10, true)
                SendMessage(killer, "+10 (cR) - 80 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
            elseif read_word(getplayer(killer) + 0x9C) == 90 then
                changescore(killer, 10, true)
                SendMessage(killer, "+10 (cR) - 90 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
            elseif read_word(getplayer(killer) + 0x9C) == 100 then
                changescore(killer, 20, true)
                SendMessage(killer, "+20 (cR) - 100 total Kills")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 20
            elseif read_word(getplayer(killer) + 0x9C) > 100 then
                changescore(killer, 5, true)
                SendMessage(killer, "+5 (cR) - More than 100 Kills!")
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
            end

            local hash = gethash(killer)
            if read_word(getplayer(killer) + 0x98) == 2 then
                -- if multi kill is equal to 2 then
                SendMessage(killer, "+8 (cR) - Double Kill")
                changescore(killer, 8, true)
                killstats[hash].total.credits = killstats[hash].total.credits + 8
                sprees[hash].count.double = sprees[hash].count.double + 1
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 3 then
                -- if multi kill is equal to 3 then
                SendMessage(killer, "+10 (cR) - Triple Kill")
                changescore(killer, 10, true)
                sprees[hash].count.triple = sprees[hash].count.triple + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 10
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 4 then
                -- if multi kill is equal to 4 then
                SendMessage(killer, "+12 (cR) - Overkill")
                changescore(killer, 12, true)
                sprees[hash].count.overkill = sprees[hash].count.overkill + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 12
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 5 then
                -- if multi kill is equal to 5 then
                SendMessage(killer, "+14 (cR) - Killtacular")
                changescore(killer, 14, true)
                sprees[hash].count.killtacular = sprees[hash].count.killtacular + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 14
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 6 then
                -- if multi kill is equal to 6 then
                SendMessage(killer, "+16 (cR) - Killtrocity")
                changescore(killer, 16, true)
                sprees[hash].count.killtrocity = sprees[hash].count.killtrocity + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 16
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 7 then
                -- if multi kill is equal to 7 then
                SendMessage(killer, "+18 (cR) - Killimanjaro")
                changescore(killer, 18, true)
                sprees[hash].count.killimanjaro = sprees[hash].count.killimanjaro + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 18
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 8 then
                -- if multi kill is equal to 8 then
                SendMessage(killer, "+20 (cR) - Killtastrophe")
                changescore(killer, 20, true)
                sprees[hash].count.killtastrophe = sprees[hash].count.killtastrophe + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 20
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) == 9 then
                -- if multi kill is equal to 9 then
                SendMessage(killer, "+22 (cR) - Killpocalypse")
                changescore(killer, 22, true)
                sprees[hash].count.killpocalypse = sprees[hash].count.killpocalypse + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 22
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            elseif read_word(getplayer(killer) + 0x98) >= 10 then
                -- if multi kill is equal to 10 or more than
                SendMessage(killer, "+25 (cR) - Killionaire")
                changescore(killer, 25, true)
                sprees[hash].count.killionaire = sprees[hash].count.killionaire + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 25
                medals[hash].count.multikill = medals[hash].count.multikill + 1
            end

            if read_word(getplayer(killer) + 0x96) == 5 then
                -- if killing spree is 5 then
                SendMessage(killer, "+5 (cR) - Killing Spree")
                changescore(killer, 5, true)
                sprees[hash].count.killingspree = sprees[hash].count.killingspree + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 5
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 10 then
                -- if killing spree is 10 then
                SendMessage(killer, "+10 (cR) - Killing Frenzy")
                changescore(killer, 10, true)
                sprees[hash].count.killingfrenzy = sprees[hash].count.killingfrenzy + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 10
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 15 then
                -- if killing spree is 15 then
                SendMessage(killer, "+15 (cR) - Running Riot")
                changescore(killer, 15, true)
                sprees[hash].count.runningriot = sprees[hash].count.runningriot + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 15
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 20 then
                -- if killing spree is 20 then
                SendMessage(killer, "+20 (cR) - Rampage")
                changescore(killer, 20, true)
                sprees[hash].count.rampage = sprees[hash].count.rampage + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 20
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 25 then
                -- if killing spree is 25 then
                SendMessage(killer, "+25 (cR) - Untouchable")
                changescore(killer, 25, true)
                sprees[hash].count.untouchable = sprees[hash].count.untouchable + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 25
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 30 then
                -- if killing spree is 30 then
                SendMessage(killer, "+30 (cR) - Invincible")
                changescore(killer, 30, true)
                sprees[hash].count.invincible = sprees[hash].count.invincible + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 30
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) == 35 then
                -- if killing spree is 35 then
                SendMessage(killer, "+35 (cR) - Anomgstopkillingme")
                changescore(killer, 35, true)
                sprees[hash].count.anomgstopkillingme = sprees[hash].count.anomgstopkillingme + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 35
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            elseif read_word(getplayer(killer) + 0x96) >= 40 and sprees % 5 == 0 then
                -- if killing spree is 40 or more (Every 5 it will say this after 40) then
                SendMessage(killer, "+40 (cR) - Unfrigginbelievable")
                changescore(killer, 40, true)
                sprees[hash].count.unfrigginbelievable = sprees[hash].count.unfrigginbelievable + 1
                killstats[hash].total.credits = killstats[hash].total.credits + 40
                medals[hash].count.sprees = medals[hash].count.sprees + 1
            end

            -- Revenge		
            for k, v in pairs(killers[killer]) do
                if v == victim then
                    table.remove(killers[killer], k)
                    medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                    killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
                    SendMessage(killer, "+10 (cR) - Revenge")
                    changescore(killer, 10, true)
                end
            end

            -- Killed from the Grave		
            if PlayerAlive(killer) == false then
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
                SendMessage(killer, "+10 (cR) - Killed from the Grave")
                changescore(killer, 10, true)
            end

            -- roadrage
            if getplayer(killer) then
                if killer ~= nil then
                    if PlayerInVehicle(killer) then
                        local player_object = get_dynamic_player(killer)
                        local VehicleObj = get_object_memory(read_dword(player_object + 0x11c))
                        local seat_index = read_word(player_object + 0x2F0)
                        if (VehicleObj ~= 0) and (seat_index == 0) then
                            medals[gethash(killer)].count.roadrage = medals[gethash(killer)].count.roadrage + 1
                            killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
                            SendMessage(killer, "+5 (cR) - RoadRage")
                            changescore(killer, 5, true)
                        end
                    end
                end
            end

            -- Avenger
            for i = 1, 16 do
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
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
                SendMessage(killer, "+5 (cR) - Avenger")
                changescore(killer, 5, true)
            end

            -- Killjoy
            if killer then
                kills[gethash(killer)] = kills[gethash(killer)] or 1
            end

            if killer and victim then
                if kills[gethash(victim)] ~= nil then
                    if kills[gethash(victim)] >= 5 then
                        medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                        killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
                        SendMessage(killer, "+5 (cR) - Killjoy")
                        changescore(killer, 5, true)
                    end
                end
            end

            kills[gethash(victim)] = 0

            -- Reload This
            local m_object = get_dynamic_player(victim)
            local reloading = read_byte(m_object + 0x2A4)
            if reloading == 5 then
                SendMessage(killer, "+5 (cR) - Reload This!")
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 5
                changescore(killer, 5, true)
            end
            -- First Strike
            kill_count = kill_count + 1

            if kill_count == 1 then
                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
                SendMessage(killer, "+10 (cR) - First Strike")
                changescore(killer, 10, true)
            end

            timer(10, "CloseCall", killer)
            -- mode 5: Betrayed by killer
        elseif mode == 5 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            killstats[gethash(killer)].total.betrays = killstats[gethash(killer)].total.betrays + 1
            changescore(PlayerIndex, 10, false)
            -- mode 6: Suicide
        elseif mode == 6 then
            killstats[gethash(victim)].total.deaths = killstats[gethash(victim)].total.deaths + 1
            killstats[gethash(victim)].total.suicides = killstats[gethash(victim)].total.suicides + 1
            changescore(PlayerIndex, 5, false)
        end

        -- mode 4: Killed by killer
        if mode == 4 then
            GetPlayerRank(killer)
            timer(10, "LevelUp", killer)
        end
    end
    last_damage[PlayerIndex] = 0
end

function getobject(PlayerIndex)
    local m_player = get_player(PlayerIndex)
    if m_player ~= 0 then
        local ObjectId = read_dword(m_player + 0x24)
        return ObjectId
    end
    return nil
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    if game_started == true then
        last_damage[PlayerIndex] = MetaID
    end
end

function SaveDataTimeToSeconds(seconds, places)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    if places == 2 then
        return minutes, seconds
    end
end

function OnTick()
    if SAVE_PLAYER_DATA then
        if (SAVE_DATA_WARNING == true) and (SAVE_DATA == true) then
            save_data_warn = save_data_warn + 0.030
            warning_timer = save_data_warn
            if warning_timer > math.floor(save_data_warning) then
                -- Stop Loop --
                SAVE_DATA_WARNING = false
                -- Announce Warning --
                execute_command("msg_prefix \"\"")
                say_all("** LAG WARNING ** Saving player data in " .. math.floor(save_data - save_data_warning) .. " seconds...")
                execute_command("msg_prefix \"** SERVER ** \"")
            end
        end
        if (SAVE_DATA == true) then
            save_data_timer = save_data_timer + 0.030
            save_data_void = save_data_timer
            if save_data_void >= math.floor(save_data) then
                -- Stop Loop --
                SAVE_DATA = false
                -- Save Data --
                SaveTableData(killstats, "KillStats.txt")
                SaveTableData(extra, "Extra.txt")
                SaveTableData(done, "CompletedMedals.txt")
                SaveTableData(sprees, "Sprees.txt")
                SaveTableData(stats, "Stats.txt")
                SaveTableData(medals, "Medals.txt")
                SaveTableData(extra, "Extra.txt")
                -- Announce Saved --
                execute_command("msg_prefix \"\"")
                say_all("Server data has been saved!")
                execute_command("msg_prefix \"** SERVER ** \"")
                -- reset --
                save_data_timer = 0
                save_data_warn = 0
                SAVE_DATA = true
                SAVE_DATA_WARNING = true
            end
        end
    end
    for i = 1, 16 do
        if (player_alive(i)) then
            GivePlayerMedals(i)
            local player_object = get_dynamic_player(i)
            local x, y, z = read_vector3d(player_object + 0x5C)
            if xcoords[gethash(i)] then
                local x_dist = x - xcoords[gethash(i)]
                local y_dist = y - ycoords[gethash(i)]
                local z_dist = z - zcoords[gethash(i)]
                local dist = math.sqrt(x_dist ^ 2 + y_dist ^ 2 + z_dist ^ 2)
                extra[gethash(i)].woops.distance = extra[gethash(i)].woops.distance + dist
            end
            xcoords[gethash(i)] = x
            ycoords[gethash(i)] = y
            zcoords[gethash(i)] = z
        end
    end
end

function PlayerAlive(PlayerIndex)
    if player_present(PlayerIndex) then
        if (player_alive(PlayerIndex)) then
            return true
        else
            return false
        end
    end
end

function AssistDelay()
    for i = 1, 16 do
        if getplayer(i) then
            if gethash(i) then
                if read_word(getplayer(i) + 0xA4) ~= 0 then
                    killstats[gethash(i)].total.assists = killstats[gethash(i)].total.assists + read_word(getplayer(i) + 0xA4)
                    medals[gethash(i)].count.assists = medals[gethash(i)].count.assists + read_word(getplayer(i) + 0xA4)
                    if (read_word(getplayer(i) + 0xA4) * 3) ~= 0 then
                        killstats[gethash(i)].total.credits = killstats[gethash(i)].total.credits + (read_word(getplayer(i) + 0xA4) * 3)
                        changescore(i, (read_word(getplayer(i) + 0xA4) * 3), true)
                    end
                    if read_word(getplayer(i) + 0xA4) == 1 then
                        SendMessage(i, "+" .. (read_word(getplayer(i) + 0xA4) * 3) .. " (cR) - " .. read_word(getplayer(i) + 0xA4) .. " Assist")
                    else
                        SendMessage(i, "+" .. (read_word(getplayer(i) + 0xA4) * 3) .. " (cR) - " .. read_word(getplayer(i) + 0xA4) .. " Assists")
                    end
                end
            end
        end
    end
end

function CloseCall(killer)
    if getplayer(killer) then
        if killer ~= nil then
            local player_object = get_dynamic_player(killer)
            if player_object ~= nil then
                local m_object = getobject(player_object)
                local shields = read_float(m_object + 0xE4)
                local health = read_float(m_object + 0xE0)
                if shields ~= nil then
                    if shields == 0 then
                        if health then
                            if health ~= 1 then
                                medals[gethash(killer)].count.jackofalltrades = medals[gethash(killer)].count.jackofalltrades + 1
                                killstats[gethash(killer)].total.credits = killstats[gethash(killer)].total.credits + 10
                                SendMessage(killer, "+10 (cR) - Close Call")
                                changescore(killer, 10, true)
                            end
                        end
                    end
                end
            end
        end
    end
end

function OpenFiles()
    stats = LoadTableData("Stats.txt")
    killstats = LoadTableData("KillStats.txt")
    sprees = LoadTableData("Sprees.txt")
    medals = LoadTableData("Medals.txt")
    extra = LoadTableData("Extra.txt")
    done = LoadTableData("CompletedMedals.txt")
end

function RetrievePlayerKDR(PlayerIndex)
    local Player_KDR
    if killstats[gethash(PlayerIndex)].total.kills ~= 0 then
        if killstats[gethash(PlayerIndex)].total.deaths ~= 0 then
            local kdr = killstats[gethash(PlayerIndex)].total.kills / killstats[gethash(PlayerIndex)].total.deaths
            Player_KDR = math.round(kdr, 2)
        else
            Player_KDR = "No Deaths"
        end
    else
        Player_KDR = "No Kills"
    end

    return Player_KDR
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

    if killstats[hash] == nil then
        killstats[hash] = { }
        killstats[hash].total = { }
        killstats[hash].total.kills = 0
        killstats[hash].total.deaths = 0
        killstats[hash].total.assists = 0
        killstats[hash].total.suicides = 0
        killstats[hash].total.betrays = 0
        killstats[hash].total.credits = 0
        killstats[hash].total.rank = 0
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
        medals[hash].count.roadrage = 0
        medals[hash].class.roadrage = "Iron"
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
        done[hash].medal.roadrage = "False"
        done[hash].medal.grenadier = "False"
        done[hash].medal.heavyweapons = "False"
        done[hash].medal.jackofalltrades = "False"
        done[hash].medal.mobileasset = "False"
        done[hash].medal.multikill = "False"
        done[hash].medal.sidearm = "False"
        done[hash].medal.triggerman = "False"
    end
end

function AnnouncePlayerRank(PlayerIndex)
    local rank
    local total
    local hash = get_var(PlayerIndex, "$hash")

    local credits = { }
    for k, _ in pairs(killstats) do
        table.insert(credits, { ["hash"] = k, ["credits"] = killstats[k].total.credits })
    end

    table.sort(credits, function(a, b)
        return a.credits > b.credits
    end)

    for k, _ in ipairs(credits) do
        if hash == credits[k].hash then
            rank = k
            total = #credits
            string = "Server Statistics: You are currently ranked " .. rank .. " out of " .. total .. "."
        end
    end
    return rprint(PlayerIndex, string)
end

function LevelUp(killer)
    local hash = gethash(killer)
    killstats[hash].total.rank = killstats[hash].total.rank or "Recruit"
    killstats[hash].total.credits = killstats[hash].total.credits or 0
    if killstats[hash].total.rank ~= nil and killstats[hash].total.credits ~= 0 then
        execute_command("msg_prefix \"\"")
        if killstats[hash].total.rank == "Recruit" and killstats[hash].total.credits > Recruit then
            killstats[hash].total.rank = "Private"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Private" and killstats[hash].total.credits > Private then
            killstats[hash].total.rank = "Corporal"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Corporal" and killstats[hash].total.credits > Corporal then
            killstats[hash].total.rank = "Sergeant"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Sergeant" and killstats[hash].total.credits > Sergeant then
            killstats[hash].total.rank = "Sergeant Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Sergeant Grade 1" and killstats[hash].total.credits > Sergeant_Grade_1 then
            killstats[hash].total.rank = "Sergeant Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Sergeant Grade 2" and killstats[hash].total.credits > Sergeant_Grade_2 then
            killstats[hash].total.rank = "Warrant Officer"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Warrant Officer" and killstats[hash].total.credits > Warrant_Officer then
            killstats[hash].total.rank = "Warrant Officer Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Warrant Officer Grade 1" and killstats[hash].total.credits > Warrant_Officer_Grade_1 then
            killstats[hash].total.rank = "Warrant Officer Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Warrant Officer Grade 2" and killstats[hash].total.credits > Warrant_Officer_Grade_2 then
            killstats[hash].total.rank = "Warrant Officer Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Warrant Officer Grade 3" and killstats[hash].total.credits > Warrant_Officer_Grade_3 then
            killstats[hash].total.rank = "Captain"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Captain" and killstats[hash].total.credits > Captain then
            killstats[hash].total.rank = "Captain Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Captain Grade 1" and killstats[hash].total.credits > Captain_Grade_1 then
            killstats[hash].total.rank = "Captain Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Captain Grade 2" and killstats[hash].total.credits > Captain_Grade_2 then
            killstats[hash].total.rank = "Captain Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Captain Grade 3" and killstats[hash].total.credits > Captain_Grade_3 then
            killstats[hash].total.rank = "Major"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Major" and killstats[hash].total.credits > Major then
            killstats[hash].total.rank = "Major Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Major Grade 1" and killstats[hash].total.credits > Major_Grade_1 then
            killstats[hash].total.rank = "Major Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Major Grade 2" and killstats[hash].total.credits > Major_Grade_2 then
            killstats[hash].total.rank = "Major Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Major Grade 3" and killstats[hash].total.credits > Major_Grade_3 then
            killstats[hash].total.rank = "Lt. Colonel"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Lt. Colonel" and killstats[hash].total.credits > Lt_Colonel then
            killstats[hash].total.rank = "Lt. Colonel Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Lt. Colonel Grade 1" and killstats[hash].total.credits > Lt_Colonel_Grade_1 then
            killstats[hash].total.rank = "Lt. Colonel Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Lt. Colonel Grade 2" and killstats[hash].total.credits > Lt_Colonel_Grade_2 then
            killstats[hash].total.rank = "Lt. Colonel Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Lt. Colonel Grade 3" and killstats[hash].total.credits > Lt_Colonel_Grade_3 then
            killstats[hash].total.rank = "Commander"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Commander" and killstats[hash].total.credits > Commander then
            killstats[hash].total.rank = "Commander Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Commander Grade 1" and killstats[hash].total.credits > Commander_Grade_1 then
            killstats[hash].total.rank = "Commander Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Commander Grade 2" and killstats[hash].total.credits > Commander_Grade_2 then
            killstats[hash].total.rank = "Commander Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Commander Grade 3" and killstats[hash].total.credits > Commander_Grade_3 then
            killstats[hash].total.rank = "Colonel"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Colonel" and killstats[hash].total.credits > Colonel then
            killstats[hash].total.rank = "Colonel Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Colonel Grade 1" and killstats[hash].total.credits > Colonel_Grade_1 then
            killstats[hash].total.rank = "Colonel Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Colonel Grade 2" and killstats[hash].total.credits > Colonel_Grade_2 then
            killstats[hash].total.rank = "Colonel Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Colonel Grade 3" and killstats[hash].total.credits > Colonel_Grade_3 then
            killstats[hash].total.rank = "Brigadier"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Brigadier" and killstats[hash].total.credits > Brigadier then
            killstats[hash].total.rank = "Brigadier Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Brigadier Grade 1" and killstats[hash].total.credits > Brigadier_Grade_1 then
            killstats[hash].total.rank = "Brigadier Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Brigadier Grade 2" and killstats[hash].total.credits > Brigadier_Grade_2 then
            killstats[hash].total.rank = "Brigadier Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Brigadier Grade 3" and killstats[hash].total.credits > Brigadier_Grade_3 then
            killstats[hash].total.rank = "General"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "General" and killstats[hash].total.credits > General then
            killstats[hash].total.rank = "General Grade 1"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "General Grade 1" and killstats[hash].total.credits > General_Grade_1 then
            killstats[hash].total.rank = "General Grade 2"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "General Grade 2" and killstats[hash].total.credits > General_Grade_2 then
            killstats[hash].total.rank = "General Grade 3"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "General Grade 3" and killstats[hash].total.credits > General_Grade_3 then
            killstats[hash].total.rank = "General Grade 4"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "General Grade 4" and killstats[hash].total.credits > General_Grade_4 then
            killstats[hash].total.rank = "Field Marshall"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Field Marshall" and killstats[hash].total.credits > Field_Marshall then
            killstats[hash].total.rank = "Hero"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Hero" and killstats[hash].total.credits > Hero then
            killstats[hash].total.rank = "Legend"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Legend" and killstats[hash].total.credits > Legend then
            killstats[hash].total.rank = "Mythic"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Mythic" and killstats[hash].total.credits > Mythic then
            killstats[hash].total.rank = "Noble"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Noble" and killstats[hash].total.credits > Noble then
            killstats[hash].total.rank = "Eclipse"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Eclipse" and killstats[hash].total.credits > Eclipse then
            killstats[hash].total.rank = "Nova"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Nova" and killstats[hash].total.credits > Nova then
            killstats[hash].total.rank = "Forerunner"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Forerunner" and killstats[hash].total.credits > Forerunner then
            killstats[hash].total.rank = "Reclaimer"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        elseif killstats[hash].total.rank == "Reclaimer" and killstats[hash].total.credits > Reclaimer then
            killstats[hash].total.rank = "Inheritor"
            say_all(getname(killer) .. " is now a " .. killstats[hash].total.rank .. "!")
        end
        execute_command("msg_prefix \"** SERVER ** \"")
    end
end

function GivePlayerMedals(PlayerIndex)
    local hash = get_var(PlayerIndex, "$hash")
    if hash then
        if done[hash].medal.sprees == "False" then
            if medals[hash].class.sprees == "Iron" and medals[hash].count.sprees >= 5 then
                medals[hash].class.sprees = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree Iron!")
            elseif medals[hash].class.sprees == "Bronze" and medals[hash].count.sprees >= 50 then
                medals[hash].class.sprees = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree Bronze!")
            elseif medals[hash].class.sprees == "Silver" and medals[hash].count.sprees >= 250 then
                medals[hash].class.sprees = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree Silver!")
            elseif medals[hash].class.sprees == "Gold" and medals[hash].count.sprees >= 1000 then
                medals[hash].class.sprees = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Any Spree : Gold")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.sprees == "Onyx" and medals[hash].count.sprees >= 4000 then
                medals[hash].class.sprees = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2000
                SendMessage(PlayerIndex, " +2000 cR - Any Spree : Onyx")
                changescore(PlayerIndex, 2000, true)
            elseif medals[hash].class.sprees == "MAX" and medals[hash].count.sprees == 10000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Any Spree MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 3000
                SendMessage(PlayerIndex, " +3000 cR - Any Spree : MAX")
                changescore(PlayerIndex, 3000, true)
                done[hash].medal.sprees = "True"
            end
        end

        if done[hash].medal.assists == "False" then
            if medals[hash].class.assists == "Iron" and medals[hash].count.assists >= 50 then
                medals[hash].class.assists = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant Iron!")
            elseif medals[hash].class.assists == "Bronze" and medals[hash].count.assists >= 250 then
                medals[hash].class.assists = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant Bronze!")
            elseif medals[hash].class.assists == "Silver" and medals[hash].count.assists >= 1000 then
                medals[hash].class.assists = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant Silver!")
            elseif medals[hash].class.assists == "Gold" and medals[hash].count.assists >= 4000 then
                medals[hash].class.assists = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Assistant : Gold")
                changescore(PlayerIndex, 1500, true)
            elseif medals[hash].class.assists == "Onyx" and medals[hash].count.assists >= 8000 then
                medals[hash].class.assists = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2500
                SendMessage(PlayerIndex, " +2500 cR - Assistant : Onyx")
                changescore(PlayerIndex, 2500, true)
            elseif medals[hash].class.assists == "MAX" and medals[hash].count.assists == 20000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Assistant MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 3500
                SendMessage(PlayerIndex, " +3500 cR - Assistant : MAX")
                changescore(PlayerIndex, 3500, true)
                done[hash].medal.assists = "True"
            end
        end

        if done[hash].medal.closequarters == "False" then
            if medals[hash].class.closequarters == "Iron" and medals[hash].count.closequarters >= 50 then
                medals[hash].class.closequarters = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters Iron!")
            elseif medals[hash].class.closequarters == "Bronze" and medals[hash].count.closequarters >= 125 then
                medals[hash].class.closequarters = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters Bronze!")
            elseif medals[hash].class.closequarters == "Silver" and medals[hash].count.closequarters >= 400 then
                medals[hash].class.closequarters = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters Silver!")
            elseif medals[hash].class.closequarters == "Gold" and medals[hash].count.closequarters >= 1600 then
                medals[hash].class.closequarters = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 750
                SendMessage(PlayerIndex, " +750 cR - Close Quarters : Gold")
                changescore(PlayerIndex, 750, true)
            elseif medals[hash].class.closequarters == "Onyx" and medals[hash].count.closequarters >= 4000 then
                medals[hash].class.closequarters = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Close Quarters : Onyx")
                changescore(PlayerIndex, 1500, true)
            elseif medals[hash].class.closequarters == "MAX" and medals[hash].count.closequarters == 8000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Close Quarters MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2250
                SendMessage(PlayerIndex, "2250 cR - Close Quarters : MAX")
                changescore(PlayerIndex, 2250, true)
                done[hash].medal.closequarters = "True"
            end
        end

        if done[hash].medal.crackshot == "False" then
            if medals[hash].class.crackshot == "Iron" and medals[hash].count.crackshot >= 100 then
                medals[hash].class.crackshot = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot Iron!")
            elseif medals[hash].class.crackshot == "Bronze" and medals[hash].count.crackshot >= 500 then
                medals[hash].class.crackshot = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot Bronze!")
            elseif medals[hash].class.crackshot == "Silver" and medals[hash].count.crackshot >= 4000 then
                medals[hash].class.crackshot = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot Silver!")
            elseif medals[hash].class.crackshot == "Gold" and medals[hash].count.crackshot >= 10000 then
                medals[hash].class.crackshot = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Crack Shot : Gold")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.crackshot == "Onyx" and medals[hash].count.crackshot >= 20000 then
                medals[hash].class.crackshot = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2000
                SendMessage(PlayerIndex, " +2000 cR - Crack Shot : Onyx")
                changescore(PlayerIndex, 2000, true)
            elseif medals[hash].class.crackshot == "MAX" and medals[hash].count.crackshot == 32000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Crack Shot MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 3000
                SendMessage(PlayerIndex, " +3000 cR - Crack Shot : MAX")
                changescore(PlayerIndex, 3000, true)
                done[hash].medal.crackshot = "True"
            end
        end

        if done[hash].medal.roadrage == "False" then
            if medals[hash].class.roadrage == "Iron" and medals[hash].count.roadrage >= 5 then
                medals[hash].class.roadrage = "Bronze"
                say_all(getnamye(PlayerIndex) .. " has earned a medal : roadrage Iron!")
            elseif medals[hash].class.roadrage == "Bronze" and medals[hash].count.roadrage >= 50 then
                medals[hash].class.roadrage = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : roadrage Bronze!")
            elseif medals[hash].class.roadrage == "Silver" and medals[hash].count.roadrage >= 750 then
                medals[hash].class.roadrage = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : roadrage Silver!")
            elseif medals[hash].class.roadrage == "Gold" and medals[hash].count.roadrage >= 4000 then
                medals[hash].class.roadrage = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : roadrage Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 500
                SendMessage(PlayerIndex, " +500 cR - roadrage : Gold")
                changescore(PlayerIndex, 500, true)
            elseif medals[hash].class.roadrage == "Onyx" and medals[hash].count.roadrage >= 8000 then
                medals[hash].class.roadrage = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : roadrage Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - roadrage : Onyx")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.roadrage == "MAX" and medals[hash].count.roadrage == 20000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : roadrage MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - roadrage : MAX")
                changescore(PlayerIndex, 1500, true)
                done[hash].medal.roadrage = "True"
            end
        end

        if done[hash].medal.grenadier == "False" then
            if medals[hash].class.grenadier == "Iron" and medals[hash].count.grenadier >= 25 then
                medals[hash].class.grenadier = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier Iron!")
            elseif medals[hash].class.grenadier == "Bronze" and medals[hash].count.grenadier >= 125 then
                medals[hash].class.grenadier = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier Bronze!")
            elseif medals[hash].class.grenadier == "Silver" and medals[hash].count.grenadier >= 500 then
                medals[hash].class.grenadier = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier Silver!")
            elseif medals[hash].class.grenadier == "Gold" and medals[hash].count.grenadier >= 4000 then
                medals[hash].class.grenadier = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 750
                SendMessage(PlayerIndex, " +750 cR - Grenadier : Gold")
                changescore(PlayerIndex, 750, true)
            elseif medals[hash].class.grenadier == "Onyx" and medals[hash].count.grenadier >= 8000 then
                medals[hash].class.grenadier = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Grenadier : Onyx")
                changescore(PlayerIndex, 1500, true)
            elseif medals[hash].class.grenadier == "MAX" and medals[hash].count.grenadier == 14000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Grenadier MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2250
                SendMessage(PlayerIndex, " +2250 cR - Grenadier : MAX")
                changescore(PlayerIndex, 2250, true)
                done[hash].medal.grenadier = "True"
            end
        end

        if done[hash].medal.heavyweapons == "False" then
            if medals[hash].class.heavyweapons == "Iron" and medals[hash].count.heavyweapons >= 25 then
                medals[hash].class.heavyweapons = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon Iron!")
            elseif medals[hash].class.heavyweapons == "Bronze" and medals[hash].count.heavyweapons >= 150 then
                medals[hash].class.heavyweapons = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon Bronze!")
            elseif medals[hash].class.heavyweapons == "Silver" and medals[hash].count.heavyweapons >= 750 then
                medals[hash].class.heavyweapons = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon Silver!")
            elseif medals[hash].class.heavyweapons == "Gold" and medals[hash].count.heavyweapons >= 3000 then
                medals[hash].class.heavyweapons = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 500
                SendMessage(PlayerIndex, " +500 cR - Heavy Weapon : Gold")
                changescore(PlayerIndex, 500, true)
            elseif medals[hash].class.heavyweapons == "Onyx" and medals[hash].count.heavyweapons >= 7000 then
                medals[hash].class.heavyweapons = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Heavy Weapon : Onyx")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.heavyweapons == "MAX" and medals[hash].count.heavyweapons == 14000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Heavy Weapon MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Heavy Weapon : MAX")
                changescore(PlayerIndex, 1500, true)
                done[hash].medal.heavyweapons = "True"
            end
        end

        if done[hash].medal.jackofalltrades == "False" then
            if medals[hash].class.jackofalltrades == "Iron" and medals[hash].count.jackofalltrades >= 50 then
                medals[hash].class.jackofalltrades = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades Iron!")
            elseif medals[hash].class.jackofalltrades == "Bronze" and medals[hash].count.jackofalltrades >= 125 then
                medals[hash].class.jackofalltrades = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades Bronze!")
            elseif medals[hash].class.jackofalltrades == "Silver" and medals[hash].count.jackofalltrades >= 400 then
                medals[hash].class.jackofalltrades = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades Silver!")
            elseif medals[hash].class.jackofalltrades == "Gold" and medals[hash].count.jackofalltrades >= 1600 then
                medals[hash].class.jackofalltrades = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 500
                SendMessage(PlayerIndex, " +500 cR - Jack of all Trades : Gold")
                changescore(PlayerIndex, 500, true)
            elseif medals[hash].class.jackofalltrades == "Onyx" and medals[hash].count.jackofalltrades >= 4800 then
                medals[hash].class.jackofalltrades = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Jack of all Trades : Onyx")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.jackofalltrades == "MAX" and medals[hash].count.jackofalltrades == 9600 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Jack of all Trades MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Jack of all Trades : MAX")
                changescore(PlayerIndex, 1500, true)
                done[hash].medal.jackofalltrades = "True"
            end
        end

        if done[hash].medal.mobileasset == "False" then
            if medals[hash].class.mobileasset == "Iron" and medals[hash].count.moblieasset >= 25 then
                medals[hash].class.mobileasset = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset Iron!")
            elseif medals[hash].class.mobileasset == "Bronze" and medals[hash].count.moblieasset >= 125 then
                medals[hash].class.mobileasset = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset Bronze!")
            elseif medals[hash].class.mobileasset == "Silver" and medals[hash].count.moblieasset >= 500 then
                medals[hash].class.mobileasset = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset Silver!")
            elseif medals[hash].class.mobileasset == "Gold" and medals[hash].count.moblieasset >= 4000 then
                medals[hash].class.mobileasset = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 750
                SendMessage(PlayerIndex, " +750 cR - Mobile Asset : Gold")
                changescore(PlayerIndex, 750, true)
            elseif medals[hash].class.mobileasset == "Onyx" and medals[hash].count.moblieasset >= 8000 then
                medals[hash].class.mobileasset = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Mobile Asset : Onyx")
                changescore(PlayerIndex, 1500, true)
            elseif medals[hash].class.mobileasset == "MAX" and medals[hash].count.moblieasset == 14000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Mobile Asset MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2250
                SendMessage(PlayerIndex, " +2250 cR - Mobile Asset : MAX")
                changescore(PlayerIndex, 2250, true)
                done[hash].medal.mobileasset = "True"
            end
        end

        if done[hash].medal.multikill == "False" then
            if medals[hash].class.multikill == "Iron" and medals[hash].count.multikill >= 10 then
                medals[hash].class.multikill = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Multikill Iron!")
            elseif medals[hash].class.multikill == "Bronze" and medals[hash].count.multikill >= 125 then
                medals[hash].class.multikill = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Multikill Bronze!")
            elseif medals[hash].class.multikill == "Silver" and medals[hash].count.multikill >= 500 then
                medals[hash].class.multikill = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Multikill Silver!")
            elseif medals[hash].class.multikill == "Gold" and medals[hash].count.multikill >= 2500 then
                medals[hash].class.multikill = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Multikill Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 500
                SendMessage(PlayerIndex, " +500 cR - Multikill : Gold")
                changescore(PlayerIndex, 500, true)
            elseif medals[hash].class.multikill == "Onyx" and medals[hash].count.multikill >= 5000 then
                medals[hash].class.multikill = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Multikill Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Multikill : Onyx")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.multikill == "MAX" and medals[hash].count.multikill == 15000 then
                say_all(getname(PlayerIndex) .. " has earned a mdeal : Multikill MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1500
                SendMessage(PlayerIndex, " +1500 cR - Multikill : MAX")
                changescore(PlayerIndex, 1500, true)
                done[hash].medal.multikill = "True"
            end
        end

        if done[hash].medal.sidearm == "False" then
            if medals[hash].class.sidearm == "Iron" and medals[hash].count.sidearm >= 50 then
                medals[hash].class.sidearm = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm Iron!")
            elseif medals[hash].class.sidearm == "Bronze" and medals[hash].count.sidearm >= 250 then
                medals[hash].class.sidearm = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm Bronze!")
            elseif medals[hash].class.sidearm == "Silver" and medals[hash].count.sidearm >= 1000 then
                medals[hash].class.sidearm = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm Silver!")
            elseif medals[hash].class.sidearm == "Gold" and medals[hash].count.sidearm >= 4000 then
                medals[hash].class.sidearm = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Sidearm : Gold")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.sidearm == "Onyx" and medals[hash].count.sidearm >= 8000 then
                medals[hash].class.sidearm = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2000
                SendMessage(PlayerIndex, " +2000 cR - Sidearm : Onyx")
                changescore(PlayerIndex, 2000, true)
            elseif medals[hash].class.sidearm == "MAX" and medals[hash].count.sidearm == 10000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Sidearm MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 3000
                SendMessage(PlayerIndex, " +3000 cR - Sidearm : MAX")
                changescore(PlayerIndex, 3000, true)
                done[hash].medal.sidearm = "True"
            end
        end

        if done[hash].medal.triggerman == "False" then
            if medals[hash].class.triggerman == "Iron" and medals[hash].count.triggerman >= 100 then
                medals[hash].class.triggerman = "Bronze"
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman Iron!")
            elseif medals[hash].class.triggerman == "Bronze" and medals[hash].count.triggerman >= 500 then
                medals[hash].class.triggerman = "Silver"
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman Bronze!")
            elseif medals[hash].class.triggerman == "Silver" and medals[hash].count.triggerman >= 4000 then
                medals[hash].class.triggerman = "Gold"
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman Silver!")
            elseif medals[hash].class.triggerman == "Gold" and medals[hash].count.triggerman >= 10000 then
                medals[hash].class.triggerman = "Onyx"
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman Gold!")
                killstats[hash].total.credits = killstats[hash].total.credits + 1000
                SendMessage(PlayerIndex, " +1000 cR - Triggerman : Gold")
                changescore(PlayerIndex, 1000, true)
            elseif medals[hash].class.triggerman == "Onyx" and medals[hash].count.triggerman >= 20000 then
                medals[hash].class.triggerman = "MAX"
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman Onyx!")
                killstats[hash].total.credits = killstats[hash].total.credits + 2000
                SendMessage(PlayerIndex, " +2000 cR - Triggerman : Onyx")
                changescore(PlayerIndex, 2000, true)
            elseif medals[hash].class.triggerman == "MAX" and medals[hash].count.triggerman == 32000 then
                say_all(getname(PlayerIndex) .. " has earned a medal : Triggerman MAX!")
                killstats[hash].total.credits = killstats[hash].total.credits + 3000
                SendMessage(PlayerIndex, " +3000 cR - Triggerman : MAX")
                changescore(PlayerIndex, 3000, true)
                done[hash].medal.triggerman = "True"
            end
        end
    end
end

function GetMedalClasses(PlayerIndex)

    local hash = get_var(PlayerIndex, "$hash")

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

    if medals[hash].count.roadrage > 5 and medals[hash].count.roadrage < 50 then
        medals[hash].class.roadrage = "Bronze"
    elseif medals[hash].count.roadrage > 50 and medals[hash].count.roadrage < 750 then
        medals[hash].class.roadrage = "Silver"
    elseif medals[hash].count.roadrage > 750 and medals[hash].count.roadrage < 4000 then
        medals[hash].class.roadrage = "Gold"
    elseif medals[hash].count.roadrage > 4000 and medals[hash].count.roadrage < 8000 then
        medals[hash].class.roadrage = "Onyx"
    elseif medals[hash].count.roadrage > 8000 and medals[hash].count.roadrage < 20000 then
        medals[hash].count.roadrage = "MAX"
    elseif medals[hash].count.roadrage > 20000 then
        medals[hash].count.roadrage = "MAX"
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
    elseif medals[hash].count.moblieasset > 125 and medals[hash].count.moblieasset < 500 then
        medals[hash].class.mobileasset = "Silver"
    elseif medals[hash].count.moblieasset > 500 and medals[hash].count.moblieasset < 4000 then
        medals[hash].class.mobileasset = "Gold"
    elseif medals[hash].count.moblieasset > 4000 and medals[hash].count.moblieasset < 8000 then
        medals[hash].class.mobileasset = "Onyx"
    elseif medals[hash].count.moblieasset > 8000 and medals[hash].count.moblieasset < 14000 then
        medals[hash].class.mobileasset = "MAX"
    elseif medals[hash].count.moblieasset > 14000 then
        medals[hash].class.mobileasset = "MAX"
    end

    if medals[hash].count.multikill > 10 and medals[hash].count.multikill < 125 then
        medals[hash].class.multikill = "Bronze"
    elseif medals[hash].count.multikill > 125 and medals[hash].count.multikill < 500 then
        medals[hash].class.multikill = "Silver"
    elseif medals[hash].count.multikill > 500 and medals[hash].count.multikill < 2500 then
        medals[hash].class.multikill = "Gold"
    elseif medals[hash].count.multikill > 2500 and medals[hash].count.multikill < 5000 then
        medals[hash].class.multikill = "Onyx"
    elseif medals[hash].count.multikill > 5000 and medals[hash].count.multikill < 15000 then
        medals[hash].class.multikill = "MAX"
    elseif medals[hash].count.multikill > 15000 then
        medals[hash].class.multikill = "MAX"
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

function getname(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local name = get_var(PlayerIndex, "$name")
        return name
    end
    return nil
end

function getplayer(PlayerIndex)
    if tonumber(PlayerIndex) then
        if tonumber(PlayerIndex) ~= 0 then
            local m_player = get_player(PlayerIndex)
            if m_player ~= 0 then
                return m_player
            end
        end
    end
    return nil
end

function getteam(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local team = get_var(PlayerIndex, "$team")
        return team
    end
    return nil
end

function gethash(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local hash = get_var(PlayerIndex, "$hash")
        return hash
    end
    return nil
end

function SendMessage(PlayerIndex, message)
    if getplayer(PlayerIndex) then
        rprint(PlayerIndex, "|c" .. message)
    end
end

function GetPlayerRank(PlayerIndex)
    local hash = get_var(PlayerIndex, "$hash")
    if hash then
        killstats[hash].total.credits = killstats[hash].total.credits or 0
        if killstats[hash].total.credits >= 0 and killstats[hash].total.credits ~= nil and killstats[hash].total.rank ~= nil then
            if killstats[hash].total.credits >= 0 and killstats[hash].total.credits < Recruit then
                killstats[hash].total.rank = "Recruit"
            elseif killstats[hash].total.credits > Recruit and killstats[hash].total.credits < Private then
                killstats[hash].total.rank = "Private"
            elseif killstats[hash].total.credits > Private and killstats[hash].total.credits < Corporal then
                killstats[hash].total.rank = "Corporal"
            elseif killstats[hash].total.credits > Corporal and killstats[hash].total.credits < Sergeant then
                killstats[hash].total.rank = "Sergeant"
            elseif killstats[hash].total.credits > Sergeant and killstats[hash].total.credits < Sergeant_Grade_1 then
                killstats[hash].total.rank = "Sergeant Grade 1"
            elseif killstats[hash].total.credits > Sergeant_Grade_1 and killstats[hash].total.credits < Sergeant_Grade_2 then
                killstats[hash].total.rank = "Sergeant Grade 2"
            elseif killstats[hash].total.credits > Sergeant_Grade_2 and killstats[hash].total.credits < Warrant_Officer then
                killstats[hash].total.rank = "Warrant Officer"
            elseif killstats[hash].total.credits > Warrant_Officer and killstats[hash].total.credits < Warrant_Officer_Grade_1 then
                killstats[hash].total.rank = "Warrant Officer Grade 1"
            elseif killstats[hash].total.credits > Warrant_Officer_Grade_1 and killstats[hash].total.credits < Warrant_Officer_Grade_2 then
                killstats[hash].total.rank = "Warrant Officer Grade 2"
            elseif killstats[hash].total.credits > Warrant_Officer_Grade_2 and killstats[hash].total.credits < Warrant_Officer_Grade_3 then
                killstats[hash].total.rank = "Warrant Officer Grade 3"
            elseif killstats[hash].total.credits > Warrant_Officer_Grade_3 and killstats[hash].total.credits < Captain then
                killstats[hash].total.rank = "Captain"
            elseif killstats[hash].total.credits > Captain and killstats[hash].total.credits < Captain_Grade_1 then
                killstats[hash].total.rank = "Captain Grade 1"
            elseif killstats[hash].total.credits > Captain_Grade_1 and killstats[hash].total.credits < Captain_Grade_2 then
                killstats[hash].total.rank = "Captain Grade 2"
            elseif killstats[hash].total.credits > Captain_Grade_2 and killstats[hash].total.credits < Captain_Grade_3 then
                killstats[hash].total.rank = "Captain Grade 3"
            elseif killstats[hash].total.credits > Captain_Grade_3 and killstats[hash].total.credits < Major then
                killstats[hash].total.rank = "Major"
            elseif killstats[hash].total.credits > Major and killstats[hash].total.credits < Major_Grade_1 then
                killstats[hash].total.rank = "Major Grade 1"
            elseif killstats[hash].total.credits > Major_Grade_1 and killstats[hash].total.credits < Major_Grade_2 then
                killstats[hash].total.rank = "Major Grade 2"
            elseif killstats[hash].total.credits > Major_Grade_2 and killstats[hash].total.credits < Major_Grade_3 then
                killstats[hash].total.rank = "Major Grade 3"
            elseif killstats[hash].total.credits > Major_Grade_3 and killstats[hash].total.credits < Lt_Colonel then
                killstats[hash].total.rank = "Lt. Colonel"
            elseif killstats[hash].total.credits > Lt_Colonel and killstats[hash].total.credits < Lt_Colonel_Grade_1 then
                killstats[hash].total.rank = "Lt. Colonel Grade 1"
            elseif killstats[hash].total.credits > Lt_Colonel_Grade_1 and killstats[hash].total.credits < Lt_Colonel_Grade_2 then
                killstats[hash].total.rank = "Lt. Colonel Grade 2"
            elseif killstats[hash].total.credits > Lt_Colonel_Grade_2 and killstats[hash].total.credits < Lt_Colonel_Grade_3 then
                killstats[hash].total.rank = "Lt. Colonel Grade 3"
            elseif killstats[hash].total.credits > Lt_Colonel_Grade_3 and killstats[hash].total.credits < Commander then
                killstats[hash].total.rank = "Commander"
            elseif killstats[hash].total.credits > Commander and killstats[hash].total.credits < Commander_Grade_1 then
                killstats[hash].total.rank = "Commander Grade 1"
            elseif killstats[hash].total.credits > Commander_Grade_1 and killstats[hash].total.credits < Commander_Grade_2 then
                killstats[hash].total.rank = "Commander Grade 2"
            elseif killstats[hash].total.credits > Commander_Grade_2 and killstats[hash].total.credits < Commander_Grade_3 then
                killstats[hash].total.rank = "Commander Grade 3"
            elseif killstats[hash].total.credits > Commander_Grade_3 and killstats[hash].total.credits < Colonel then
                killstats[hash].total.rank = "Colonel"
            elseif killstats[hash].total.credits > Colonel and killstats[hash].total.credits < Colonel_Grade_1 then
                killstats[hash].total.rank = "Colonel Grade 1"
            elseif killstats[hash].total.credits > Colonel_Grade_1 and killstats[hash].total.credits < Colonel_Grade_2 then
                killstats[hash].total.rank = "Colonel Grade 2"
            elseif killstats[hash].total.credits > Colonel_Grade_2 and killstats[hash].total.credits < Colonel_Grade_3 then
                killstats[hash].total.rank = "Colonel Grade 3"
            elseif killstats[hash].total.credits > Colonel_Grade_3 and killstats[hash].total.credits < Brigadier then
                killstats[hash].total.rank = "Brigadier"
            elseif killstats[hash].total.credits > Brigadier and killstats[hash].total.credits < Brigadier_Grade_1 then
                killstats[hash].total.rank = "Brigadier Grade 1"
            elseif killstats[hash].total.credits > Brigadier_Grade_1 and killstats[hash].total.credits < Brigadier_Grade_2 then
                killstats[hash].total.rank = "Brigadier Grade 2"
            elseif killstats[hash].total.credits > Brigadier_Grade_2 and killstats[hash].total.credits < Brigadier_Grade_3 then
                killstats[hash].total.rank = "Brigadier Grade 3"
            elseif killstats[hash].total.credits > Brigadier_Grade_3 and killstats[hash].total.credits < General then
                killstats[hash].total.rank = "General"
            elseif killstats[hash].total.credits > General and killstats[hash].total.credits < General_Grade_1 then
                killstats[hash].total.rank = "General Grade 1"
            elseif killstats[hash].total.credits > General_Grade_1 and killstats[hash].total.credits < General_Grade_2 then
                killstats[hash].total.rank = "General Grade 2"
            elseif killstats[hash].total.credits > General_Grade_2 and killstats[hash].total.credits < General_Grade_3 then
                killstats[hash].total.rank = "General Grade 3"
            elseif killstats[hash].total.credits > General_Grade_3 and killstats[hash].total.credits < General_Grade_4 then
                killstats[hash].total.rank = "General Grade 4"
            elseif killstats[hash].total.credits > General_Grade_4 and killstats[hash].total.credits < Field_Marshall then
                killstats[hash].total.rank = "Field Marshall"
            elseif killstats[hash].total.credits > Field_Marshall and killstats[hash].total.credits < Hero then
                killstats[hash].total.rank = "Hero"
            elseif killstats[hash].total.credits > Hero and killstats[hash].total.credits < Legend then
                killstats[hash].total.rank = "Legend"
            elseif killstats[hash].total.credits > Legend and killstats[hash].total.credits < Mythic then
                killstats[hash].total.rank = "Mythic"
            elseif killstats[hash].total.credits > Mythic and killstats[hash].total.credits < Noble then
                killstats[hash].total.rank = "Noble"
            elseif killstats[hash].total.credits > Noble and killstats[hash].total.credits < Eclipse then
                killstats[hash].total.rank = "Eclipse"
            elseif killstats[hash].total.credits > Eclipse and killstats[hash].total.credits < Nova then
                killstats[hash].total.rank = "Nova"
            elseif killstats[hash].total.credits > Nova and killstats[hash].total.credits < Forerunner then
                killstats[hash].total.rank = "Forerunner"
            elseif killstats[hash].total.credits > Forerunner and killstats[hash].total.credits < Reclaimer then
                killstats[hash].total.rank = "Reclaimer"
            elseif killstats[hash].total.credits > Reclaimer and killstats[hash].total.credits < Reclaimer then
                killstats[hash].total.rank = "Inheritor"
            end
        end
    end
end

function CreditsUntilNextPromo(PlayerIndex)
    local hash = get_var(PlayerIndex, "$hash")
    killstats[hash].total.rank = killstats[hash].total.rank or "Recruit"
    killstats[hash].total.credits = killstats[hash].total.credits or 0
    if killstats[hash].total.rank == "Recruit" then
        return Recruit - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Private" then
        return Private - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Corporal" then
        return Corporal - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Sergeant" then
        return Sergeant - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Sergeant Grade 1" then
        return Sergeant_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Sergeant Grade 2" then
        return Sergeant_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Warrant Officer" then
        return Warrant_Officer - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Warrant Officer Grade 1" then
        return Warrant_Officer_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Warrant Officer Grade 2" then
        return Warrant_Officer_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Warrant Officer Grade 3" then
        return Warrant_Officer_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Captain" then
        return Captain - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Captain Grade 1" then
        return Captain_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Captain Grade 2" then
        return Captain_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Captain Grade 3" then
        return Captain_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Major" then
        return Major - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Major Grade 1" then
        return Major_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Major Grade 2" then
        return Major_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Major Grade 3" then
        return Major_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Lt. Colonel" then
        return Lt_Colonel - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Lt. Colonel Grade 1" then
        return Lt_Colonel_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Lt. Colonel Grade 2" then
        return Lt_Colonel_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Lt. Colonel Grade 3" then
        return Lt_Colonel_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Commander" then
        return Commander - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Commander Grade 1" then
        return Commander_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Commander Grade 2" then
        return Commander_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Commander Grade 3" then
        return Commander_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Colonel" then
        return Colonel - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Colonel Grade 1" then
        return Colonel_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Colonel Grade 2" then
        return Colonel_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Colonel Grade 3" then
        return Colonel_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Brigadier" then
        return Brigadier - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Brigadier Grade 1" then
        return Brigadier_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Brigadier Grade 2" then
        return Brigadier_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Brigadier Grade 3" then
        return Brigadier_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "General" then
        return General - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "General Grade 1" then
        return General_Grade_1 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "General Grade 2" then
        return General_Grade_2 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "General Grade 3" then
        return General_Grade_3 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "General Grade 4" then
        return General_Grade_4 - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Field Marshall" then
        return Field_Marshall - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Hero" then
        return Hero - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Legend" then
        return Legend - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Mythic" then
        return Mythic - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Noble" then
        return Noble - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Eclipse" then
        return Eclipse - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Nova" then
        return Nova - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Forerunner" then
        return Forerunner - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Reclaimer" then
        return Reclaimer - killstats[hash].total.credits
    elseif killstats[hash].total.rank == "Inheritor" then
        return "Ranks Complete"
    end
end

-- Check if player is in a Vehicle. Returns boolean --
function PlayerInVehicle(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        local VehicleID = read_dword(player_object + 0x11C)
        if VehicleID == 0xFFFFFFFF then
            return false
        else
            return true
        end
    else
        return false
    end
end

-- [function get_tag_info] - Thanks to 002
function get_tag_info(tagclass, tagname)
    local tagarray = read_dword(0x40440000)
    for i = 0, read_word(0x4044000C) - 1 do
        local tag = tagarray + i * 0x20
        local class = string.reverse(string.sub(read_string(tag), 1, 4))
        if (class == tagclass) then
            if (read_string(read_dword(tag + 0x10)) == tagname) then
                return read_dword(tag + 0xC)
            end
        end
    end
    return nil
end

function LoadItems()
    -- fall damage --
    falling_damage = get_tag_info("jpt!", "globals\\falling")
    distance_damage = get_tag_info("jpt!", "globals\\distance")

    -- vehicle collision --
    veh_damage = get_tag_info("jpt!", "globals\\vehicle_collision")

    -- vehicle projectiles --
    ghost_bolt = get_tag_info("jpt!", "vehicles\\ghost\\ghost bolt")
    tank_bullet = get_tag_info("jpt!", "vehicles\\scorpion\\bullet")
    chain_bullet = get_tag_info("jpt!", "vehicles\\warthog\\bullet")
    turret_bolt = get_tag_info("jpt!", "vehicles\\c gun turret\\mp bolt")
    banshee_bolt = get_tag_info("jpt!", "vehicles\\banshee\\banshee bolt")
    tank_shell = get_tag_info("jpt!", "vehicles\\scorpion\\shell explosion")
    banshee_explode = get_tag_info("jpt!", "vehicles\\banshee\\mp_fuel rod explosion")

    -- weapon projectiles --
    pistol_bullet = get_tag_info("jpt!", "weapons\\pistol\\bullet")
    prifle_bolt = get_tag_info("jpt!", "weapons\\plasma rifle\\bolt")
    shotgun_pellet = get_tag_info("jpt!", "weapons\\shotgun\\pellet")
    ppistol_bolt = get_tag_info("jpt!", "weapons\\plasma pistol\\bolt")
    needle_explode = get_tag_info("jpt!", "weapons\\needler\\explosion")
    assault_bullet = get_tag_info("jpt!", "weapons\\assault rifle\\bullet")
    needle_impact = get_tag_info("jpt!", "weapons\\needler\\impact damage")
    flame_explode = get_tag_info("jpt!", "weapons\\flamethrower\\explosion")
    sniper_bullet = get_tag_info("jpt!", "weapons\\sniper rifle\\sniper bullet")
    rocket_explode = get_tag_info("jpt!", "weapons\\rocket launcher\\explosion")
    needle_detonate = get_tag_info("jpt!", "weapons\\needler\\detonation damage")
    ppistol_charged = get_tag_info("jpt!", "weapons\\plasma rifle\\charged bolt")
    pcannon_melee = get_tag_info("jpt!", "weapons\\plasma_cannon\\effects\\plasma_cannon_melee")
    pcannon_explode = get_tag_info("jpt!", "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion")

    -- grenades --
    frag_explode = get_tag_info("jpt!", "weapons\\frag grenade\\explosion")
    plasma_attach = get_tag_info("jpt!", "weapons\\plasma grenade\\attached")
    plasma_explode = get_tag_info("jpt!", "weapons\\plasma grenade\\explosion")

    -- weapon melee --
    flag_melee = get_tag_info("jpt!", "weapons\\flag\\melee")
    ball_melee = get_tag_info("jpt!", "weapons\\ball\\melee")
    pistol_melee = get_tag_info("jpt!", "weapons\\pistol\\melee")
    needle_melee = get_tag_info("jpt!", "weapons\\needler\\melee")
    shotgun_melee = get_tag_info("jpt!", "weapons\\shotgun\\melee")
    flame_melee = get_tag_info("jpt!", "weapons\\flamethrower\\melee")
    sniper_melee = get_tag_info("jpt!", "weapons\\sniper rifle\\melee")
    prifle_melee = get_tag_info("jpt!", "weapons\\plasma rifle\\melee")
    ppistol_melee = get_tag_info("jpt!", "weapons\\plasma pistol\\melee")
    assault_melee = get_tag_info("jpt!", "weapons\\assault rifle\\melee")
    rocket_melee = get_tag_info("jpt!", "weapons\\rocket launcher\\melee")
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

function setscore(PlayerIndex, score)
    if tonumber(score) then
        if get_var(0, "$gt") == "ctf" then
            local m_player = getplayer(PlayerIndex)
            if score >= 0x7FFF then
                write_word(m_player + 0xC8, 0x7FFF)
            elseif score <= -0x7FFF then
                write_word(m_player + 0xC8, -0x7FFF)
            else
                write_word(m_player + 0xC8, score)
            end
        end
    end
end

function changescore(PlayerIndex, number, bool)
    local m_player = getplayer(PlayerIndex)
    if m_player then
        local player_scores = read_word(m_player + 0xC8)
        if bool ~= nil then
            if bool == true then
                local score = player_scores + number
                setscore(PlayerIndex, score)
            elseif bool == false then
                local score = player_scores + math.abs(number)
                setscore(PlayerIndex, -score)
            end
        end
    end
end

function getprofilepath()
    local folder_directory = data_folder
    return folder_directory
end

function SaveTableData(t, filename)
    local dir = getprofilepath()
    local file = io.open(dir .. filename, "w")
    local spaces = 0
    local function tab()
        local str = ""
        for _ = 1, spaces do
            str = str .. " "
        end
        return str
    end
    local function format()
        spaces = spaces + 4
        local str = "{ "
        for k, v in opairs(t) do
            -- Key datatypes
            if type(k) == "string" then
                k = string.format("%q", k)
            elseif k == math.inf then
                k = "1 / 0"
            end
            k = tostring(k)
            -- Value datatypes
            if type(v) == "string" then
                v = string.format("%q", v)
            elseif v == math.inf then
                v = "1 / 0"
            end
            if type(v) == "table" then
                if tablelen(v) > 0 then
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
    for k, _ in pairs(t) do
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
        if unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function spaces(n, delimiter)
    delimiter = delimiter or ""
    local str = ""
    for i = 1, n do
        if i == math.floor(n / 2) then
            str = str .. delimiter
        end
        str = str .. " "
    end
    return str
end

function LoadTableData(filename)
    local dir = getprofilepath()
    local file = loadfile(dir .. filename)
    if file then
        return file() or { }
    end
    return { }
end

function tablelen(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
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

function math.round(input, precision)
    return math.floor(input * (10 ^ precision) + 0.5) / (10 ^ precision)
end

function read_widestring(address, length)
    local count = 0
    local byte_table = { }
    for i = 1, length do
        if read_byte(address + count) ~= 0 then
            byte_table[i] = string.char(read_byte(address + count))
        end
        count = count + 2
    end
    return table.concat(byte_table)
end

function tokenizestring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = { };
    i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
