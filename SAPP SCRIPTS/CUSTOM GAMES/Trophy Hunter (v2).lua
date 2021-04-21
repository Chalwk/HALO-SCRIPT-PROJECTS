--[[
--=====================================================================================================--
Script Name: Trophy Hunter (v2), for SAPP (PC & CE)
Description: This is an adaptation of Kill-Confirmed from Call of Duty.
             When you kill someone, a trophy will fall at your victim's death location.
             In order to actually score you have to collect the trophy.
             
             This mod is designed for stock maps only!
             Message me on GitHub (see below) if you want this mod to be designed for a specific map(s).
             
             This mod is also currently only available for Slayer (FFA) gametypes.

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"
local mod = { }

function mod:init()
    mod.settings = {

        scoring = {

            -- Index 1: (Killer) Points added for claiming your victim's trophy
            -- Index 2: (Victim) Points deducted because your killer claimed their trophy
            ['claim'] = { 1, -1 },

            -- Index 1: (Player) Points added for claiming someone else's trophy
            -- Index 2: (Victim) Points deducted because a player claimed your killers trophy
            ['claim_other'] = { 1, -1 },

            -- Index 1: (Killer) Points deducted because your victim claimed your trophy
            -- Index 2: (Victim) Points added for claiming your killers trophy
            ['claim_self'] = { -1, 2 },

            -- Index 1: (Victim) Points deducted because you were killed (pVP)
            ['death_penalty'] = { -1 },

            -- Index 1: (Victim) Points deducted because you committed suicide
            ['suicide_penalty'] = { -1 },


            -- DYNAMIC SCORING SYSTEM --
            -- The game will end when this scorelimit is reached.
            ['scorelimit'] = {
                [1] = 10, -- 4 players or less
                [2] = 15, -- 4-8 players
                [3] = 20, -- 8-12 players
                [4] = 25, -- 12-16 players
                txt = "Score limit changed to: %scorelimit%"
            },
        },

        -- Some functions temporarily remove the server prefix while broadcasting a message.
        -- This prefix will be restored to 'server_prefix' when the message relay is done.
        -- Enter your servers default prefix here:
        server_prefix = "** SERVER **",

        -- If true, trophies belonging to players players who just quit will despawn after 'time_until_despawn' seconds.
        despawn = true,
        -- Amount of time (in seconds) until trophies are despawned:
        time_until_despawn = 15,

        -- These messages are relayed in chat when you pick up/deny someone's trophy.
        on_claim = {
            "%killer% collected %victim%'s trophy!",
            "%victim% denied %killer%'s trophy!",
            "%player% stole %killer%'s trophy!",
        },

        -- If enabled, a welcome message will be displayed (see below)
        show_welcome_message = true,
        welcome = {
            "Welcome to Trophy Hunter",
            "Your victim will drop a trophy when they die!",
            "Collect this trophy to get points!",
            "Type /%info_command% for more information.",
        },

        -- Type this command to learn how to play:
        info_command = "info",

        -- If enabled, the 'info_command' will display the following information:
        enable_info_command = true,
        info = {
            "|l-- POINTS --",
            "|lCollect your victims trophy:           |rYou: (+%claim1% pt%c1%), Victim: (%claim2% pt%c2%)",
            "|lCollect somebody else's trophy:        |rYou: (+%claim_other1% pt%c3%), Victim: (%claim_other2% pt%c4%)",
            "|lCollect your killer's trophy:          |rKiller: (%claim_self1% pt%c5%), You: (+%claim_self2% pt%c6%)",
            "|lDeath Penalty:                         |r(%death_penalty% pt%c7%)",
            "|lSuicide Penalty:                       |r(%suicide_penalty% pt%c8%)",
            "|lCollecting trophies is the only way to score!",
            "|l ",
            "|l ",
            "-- DYNAMIC SCORING --",
            "|lScorelimit is dynamically set based on current player count:",
            "|l%score1% pt%c9%) -> 4 players or less",
            "|l%score2% pt%c10%) -> 4-8 players",
            "|l%score3% pt%c11%) -> 8-12 players",
            "|l%score4% pt%c12%) -> 12-16 players",
            "|lCurrent Scorelimit: %scorelimit%",
        },

        -- Global Message sent when the game ends:
        win = {
            "|c--<->--<->--<->--<->--<->--<->--<->--",
            "|c%name% WON THE GAME!",
            "|c--<->--<->--<->--<->--<->--<->--<->--",
        },

        on_despawn = {

            -- Message sent when a player quits (if has trophies on the playing field)
            "%victim%'s trophies will despawn in %seconds% seconds",

            -- Message sent if player doesn't return before 'time_until_despawn' seconds elapsed.
            "%victim%'s trophies have despawned!",

            -- Message sent if player returns before 'time_until_despawn' seconds has elapsed.
            "%victim%' has returned! Their trophies will no longer despawn!",
        },
    }
end

-- Variables for String Library:
local format = string.format
local sub, gsub = string.sub, string.gsub
local lower, upper = string.lower, string.upper
local match, gmatch = string.match, string.gmatch

-- Variables for Math Library:
local floor, sqrt = math.floor, math.sqrt

-- Game Variables:
local game_over
local current_scorelimit

-- Game Tables: 
local trophies, console_messages = { }, { }
local ip_table = { }

local time_scale = 1/30
-- ...

function OnScriptLoad()

    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnPlayerConnect")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerDisconnect")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
    register_callback(cb['EVENT_WEAPON_PICKUP'], "OnWeaponPickup")

    if (get_var(0, '$gt') ~= 'n/a') then
        local trophy = mod:getGametype()
        if (trophy) then
		
            trophies, console_messages = { }, { }
            mod:init()
            mod.settings.trophy = trophy
            game_over = false

            for i = 1, 16 do
                if player_present(i) then
                    ip_table[i] = get_var(i, '$ip')
                end
            end

            current_scorelimit = 0
            mod:modifyScorelimit()
        end
    end
end

function OnScriptUnload()
    for k, v in pairs(trophies) do
        if (k) then
            destroy_object(v.trophy)
        end
    end
end

function OnNewGame()
    local trophy = mod:getGametype()
    if (trophy) then
        mod:init()
        mod.settings.trophy = trophy
        game_over = false

        current_scorelimit = 0
        local scoreTable = mod:GetScoreLimit()
        mod:SetScorelimit(scoreTable[1])
    end
end

function OnGameEnd()
    game_over = true
end

function OnPlayerConnect(PlayerIndex)
    ip_table[PlayerIndex] = get_var(PlayerIndex, '$ip')

    local set = mod.settings
    local ip = mod:GetIP(PlayerIndex)

    mod:modifyScorelimit()

    if (set.despawn) then

        local trigger
        for k, v in pairs(trophies) do
            if (k) then
                if (v.vip == ip and v.despawn_trigger == true) then
                    trigger = v.despawn_trigger
                    v.despawn_trigger, v.time = false, 0
                end
            end
        end
        if (trigger) then
            execute_command("msg_prefix \"\"")
            for k, message in pairs(set.on_despawn) do
                if (k == 3) then
                    local name = get_var(PlayerIndex, "$name")
                    say_all(gsub(message, "%%victim%%", name))
                end
            end
            execute_command("msg_prefix \"" .. set.server_prefix .. "\" ")
        end
    end

    if (set.show_welcome_message) then
        for i, message in pairs(set.welcome) do
            set.welcome[i] = gsub(message, "%%info_command%%", set.info_command)
        end
        mod:NewConsoleMessage(set.welcome, 10, PlayerIndex, "welcome")
        return false
    end
end

function OnPlayerDisconnect(PlayerIndex)
    local set = mod.settings
    local ip = mod:GetIP(PlayerIndex)

    mod:modifyScorelimit()

    if (set.despawn) then
        local duration = nil
        for k, v in pairs(trophies) do
            if (k) then
                if (v.vip == ip) then
                    v.despawn_trigger = true
                    duration = v.duration
                end
            end
        end
        if (duration) then
            execute_command("msg_prefix \"\"")
            for k, message in pairs(set.on_despawn) do
                if (k == 1) then
                    local name = get_var(PlayerIndex, "$name")
                    say_all(gsub(gsub(message, "%%victim%%", name), "%%seconds%%", duration))
                end
            end
            execute_command("msg_prefix \"" .. set.server_prefix .. "\" ")
        end
    end
end

local function distanceFromPlayer(pX, pY, pZ, tX, tY, tZ)
    return sqrt((pX - tX) ^ 2 + (pY - tY) ^ 2 + (pZ - tZ) ^ 2)
end

function OnTick()
    if (#console_messages > 0) then
        for k, v in pairs(console_messages) do
            if v.player and player_present(v.player) then
                v.time = v.time + time_scale

                mod:cls(v.player)
                if type(v.message) == "table" then
                    for i = 1, #v.message do
                        rprint(v.player, v.message[i])
                    end
                else
                    rprint(v.player, v.message)
                end

                if (v.time >= v.duration) then
                    if (v.type == "endgame") then
                        trophies = { }
                    end
                    console_messages[k] = nil
                end
            end
        end
    end

    if (mod.settings.despawn) then
        local names = {}
        for k, v in pairs(trophies) do
            if (k) then
                if (v.despawn_trigger) then
                    v.time = v.time + time_scale
                    if (v.time >= v.duration) then
                        names[#names + 1] = v.vn
                        trophies[k] = nil
                    end
                end
            end
        end
        local M = {}
        for _, V in pairs(names) do
            if (not M[V]) then
                execute_command("msg_prefix \"\"")
                for k, message in pairs(mod.settings.on_despawn) do
                    if (k == 2) then
                        say_all(gsub(message, "%%victim%%", V))
                    end
                end
                execute_command("msg_prefix \"" .. mod.settings.server_prefix .. "\" ")
                M[V] = true
            end
        end
    end
end

function OnPlayerChat(PlayerIndex, Message, type)
    if (type ~= 6) then

        local msg = mod:stringSplit(Message)
        if (#msg == 0) then
            return nil
        end

        local set = mod.settings
        local is_command = (sub(msg[1], 1, 1) == "/") or (sub(msg[1], 1, 1) == "\\")

        if (is_command) then

            msg = gsub(gsub(msg[1], "/", ""), "\\", "")
            if (set.enable_info_command and msg == set.info_command) then

                local words = {
                    ["%%claim1%%"] = set.scoring["claim"][1],
                    ["%%claim2%%"] = set.scoring["claim"][2],

                    ["%%claim_other1%%"] = set.scoring["claim_other"][1],
                    ["%%claim_other2%%"] = set.scoring["claim_other"][2],

                    ["%%claim_self1%%"] = set.scoring["claim_self"][1],
                    ["%%claim_self2%%"] = set.scoring["claim_self"][2],

                    ["%%death_penalty%%"] = set.scoring["death_penalty"][1],
                    ["%%suicide_penalty%%"] = set.scoring["suicide_penalty"][1],
                    ["%%scorelimit%%"] = current_scorelimit,

                    ["%%score1%%"] = set.scoring["scorelimit"][1],
                    ["%%score2%%"] = set.scoring["scorelimit"][2],
                    ["%%score3%%"] = set.scoring["scorelimit"][3],
                    ["%%score4%%"] = set.scoring["scorelimit"][4],

                    ["%%c1%%"] = mod:getChar(set.scoring["claim"][1]),
                    ["%%c2%%"] = mod:getChar(set.scoring["claim"][2]),

                    ["%%c3%%"] = mod:getChar(set.scoring["claim_other"][1]),
                    ["%%c4%%"] = mod:getChar(set.scoring["claim_other"][2]),

                    ["%%c5%%"] = mod:getChar(set.scoring["claim_self"][1]),
                    ["%%c6%%"] = mod:getChar(set.scoring["claim_self"][2]),

                    ["%%c7%%"] = mod:getChar(set.scoring["death_penalty"][1]),
                    ["%%c8%%"] = mod:getChar(set.scoring["suicide_penalty"][1]),

                    ["%%c9%%"] = mod:getChar(set.scoring["scorelimit"][1]),
                    ["%%c10%%"] = mod:getChar(set.scoring["scorelimit"][2]),
                    ["%%c11%%"] = mod:getChar(set.scoring["scorelimit"][3]),
                    ["%%c12%%"] = mod:getChar(set.scoring["scorelimit"][4]),
                }

                for i, _ in pairs(set.info) do
                    for k, v in pairs(words) do
                        set.info[i] = gsub(set.info[i], k, v)
                    end
                end

                mod:NewConsoleMessage(set.info, 10, PlayerIndex, "info")
                return false
            end
        end
    end
end

function OnWeaponPickup(PlayerIndex, WeaponIndex, Type)
    if (tonumber(Type) == 1) then
        mod:OnTrophyPickup(PlayerIndex, WeaponIndex)
    end
end

function OnPlayerDeath(PlayerIndex, KillerIndex)

    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)

    local params = { }
    params.kname, params.vname = get_var(killer, "$name"), get_var(victim, "$name")
    params.victim, params.killer = victim, killer
    params.vip, params.kip = mod:GetIP(victim), mod:GetIP(killer)

    if (killer > 0) then
        -- Prevent killer from getting a point.
        -- They have to "claim" their trophy to be rewarded a point.
        execute_command("score " .. killer .. " -1")

        -- Victim loses a point for dying:
        params.type = "death_penalty"
        mod:UpdateScore(params)
        mod:spawnTrophy(params)

    elseif (victim == killer) then
        params.type = "suicide_penalty"
        mod:UpdateScore(params)
        return false
    end
end

function mod:OnTrophyPickup(PlayerIndex, WeaponIndex)

    local player_object = get_dynamic_player(PlayerIndex)
    local WeaponID = read_dword(player_object + 0x118)
    local set = mod.settings

    if (WeaponID ~= 0) then

        local weapon = read_dword(player_object + 0x2F8 + (tonumber(WeaponIndex) - 1) * 4)

        local WeaponObject = get_object_memory(weapon)
        if (mod:ObjectTagID(WeaponObject) == set.trophy[2]) then

            for k, v in pairs(trophies) do
                if (k == weapon) then

                    local params = { }

                    params.killer, params.victim = v.kid, v.vid
                    params.kname, params.vname = v.kn, v.vn
                    params.vip, params.kip = v.vip, v.kip
                    params.name = get_var(PlayerIndex, "$name")

                    local msg = function(table, index)
                        return gsub(gsub(gsub(table[index], "%%killer%%", params.kname), "%%victim%%", params.vname), "%%player%%", params.name)
                    end

                    execute_command("msg_prefix \"\"")

                    if (PlayerIndex == params.killer) then
                        params.type = "claim"
                        say_all(msg(set.on_claim, 1))
                    elseif (PlayerIndex == params.victim) then
                        params.type = "claim_self"
                        say_all(msg(set.on_claim, 2))
                    elseif (PlayerIndex ~= params.killer and PlayerIndex ~= params.victim) then
                        params.type = "claim_other"
                        say_all(msg(set.on_claim, 3))
                    end
                    execute_command("msg_prefix \"" .. set.server_prefix .. "\" ")

                    destroy_object(weapon)
                    trophies[k] = nil

                    mod:UpdateScore(params)
                end
            end
        end
    end
end

function mod:UpdateScore(params)
    local params = params or nil
    if (params ~= nil) then

        local set = mod.settings

        local killer = params.killer
        local victim = params.victim
        local kname = params.kname

        local score, ks, vs = select(1, mod:ScoreType(params))

        if (params.type == "claim") then
            execute_command("score " .. killer .. " " .. ks + score[1])
            execute_command("score " .. victim .. " " .. vs + score[2])

        elseif (params.type == "claim_self") then
            execute_command("score " .. killer .. " " .. ks + score[1])
            execute_command("score " .. victim .. " " .. vs + score[2])

        elseif (params.type == "claim_other") then
            execute_command("score " .. killer .. " " .. ks + score[1])
            execute_command("score " .. victim .. " " .. vs + score[2])

        elseif (params.type == "suicide_penalty") then
            execute_command("score " .. victim .. " " .. vs + score[1])

        elseif (params.type == "death_penalty") then
            execute_command("score " .. victim .. " " .. vs + score[1])
        end

        if tonumber(get_var(killer, "$score")) >= current_scorelimit then
            game_over = true

            for k, v in pairs(set.win) do
                set.win[k] = gsub(set.win[k], "%%name%%", kname)
            end

            for i = 1, 16 do
                if player_present(i) then
                    mod:NewConsoleMessage(set.win, 5, i, "endgame")
                end
            end
        end

        -- Prevent player scores from going into negatives:
        local _, ks, vs = select(1, mod:ScoreType(params))

        if (ks <= -1) then
            execute_command("score " .. killer .. " 0")
        end
        if (vs <= -1) then
            execute_command("score " .. victim .. " 0")
        end
    end
end


----- FOR A FUTURE UPDATE -----
--===============================================================================
-- function mod:getGametype()
-- local gametype = get_var(1, "$gt")
-- if (gametype == "oddball" or gametype == "race") then
-- unregister_callback(cb['EVENT_DIE'])
-- unregister_callback(cb['EVENT_TICK'])
-- unregister_callback(cb['EVENT_JOIN'])
-- unregister_callback(cb['EVENT_CHAT'])
-- unregister_callback(cb['EVENT_LEAVE'])
-- unregister_callback(cb['EVENT_GAME_END'])
-- unregister_callback(cb['EVENT_WEAPON_PICKUP'])
-- cprint("Trophy Hunter GAME TYPE ERROR!", 4 + 8)
-- cprint("This script doesn't support " .. gametype, 4 + 8)
-- return false
-- elseif (gametype == "slayer" or gametype == "koth") then
-- if (get_var(0, "$ffa") == "0") then
-- return {"weap", "weapons\\ball\\ball"}
-- else
-- return {"eqip", "powerups\\full-spectrum vision"}
-- end
-- elseif (gametype == "ctf") then
-- return {"eqip", "powerups\\flamethrower ammo\\flamethrower ammo"}
-- end
-- end
--===============================================================================

function mod:getGametype()
    local gametype = get_var(1, "$gt")

    local unload = function()
        unregister_callback(cb['EVENT_DIE'])
        unregister_callback(cb['EVENT_TICK'])
        unregister_callback(cb['EVENT_JOIN'])
        unregister_callback(cb['EVENT_CHAT'])
        unregister_callback(cb['EVENT_LEAVE'])
        unregister_callback(cb['EVENT_GAME_END'])
        unregister_callback(cb['EVENT_WEAPON_PICKUP'])
        cprint("Trophy Hunter GAME TYPE ERROR!", 4 + 8)
        cprint("This script doesn't support " .. gametype, 4 + 8)
    end

    if (gametype == "oddball" or gametype == "race" or gametype == "ctf") then
        unload()
        return false
    elseif (gametype == "slayer" or gametype == "koth") then
        if (get_var(0, "$ffa") == "0") then
            -- Team
            unload()
            return false
        else
            return { "weap", "weapons\\ball\\ball" }
        end
    end
end

function mod:spawnTrophy(params)
    local params = params or nil
    if (params ~= nil) then

        local set = mod.settings

        local coords = mod:getXYZ(params)
        local x, y, z, offset = coords.x, coords.y, coords.z, coords.offset
        local object = spawn_object(set.trophy[1], set.trophy[2], x, y, z + offset)

        local trophy = get_object_memory(object)
        trophies[object] = {

            kid = params.killer,
            vid = params.victim,
            kn = params.kname,
            vn = params.vname,
            vip = params.vip,
            kip = params.kip,

            trophy = object,
            object = trophy,
            time = 0,
            duration = set.time_until_despawn,
            despawn_trigger = false,
        }
    end
end

function mod:ScoreType(params)
    local params = params or nil
    if (params ~= nil) then

        local ks = tonumber(get_var(params.killer, "$score"))
        local vs = tonumber(get_var(params.victim, "$score"))

        local table = mod.settings.scoring
        for k, v in pairs(table) do
            if (params.type == k) then
                return table[k], ks, vs
            end
        end
    end
end

function mod:GetScoreLimit()
    return (mod.settings.scoring["scorelimit"])
end

function mod:getXYZ(params)
    local params = params or nil
    if (params ~= nil) then
        local player_object = get_dynamic_player(params.victim)
        if (player_object ~= 0) then

            local coords = { }
            local x, y, z = 0, 0, 0

            if mod:isInVehicle(params.victim) then
                local VehicleID = read_dword(player_object + 0x11C)
                local vehicle = get_object_memory(VehicleID)
                coords.invehicle, coords.offset = true, 0.5
                x, y, z = read_vector3d(vehicle + 0x5c)
            else
                coords.invehicle, coords.offset = false, 0.3
                x, y, z = read_vector3d(player_object + 0x5c)
            end
            coords.x, coords.y, coords.z = format("%0.3f", x), format("%0.3f", y), format("%0.3f", z)
            return coords
        end
    end
end

function mod:NewConsoleMessage(Message, Duration, Player, Type)

    local function Add(a, b, c, d)
        return {
            message = a,
            duration = b,
            player = c,
            type = d,
            time = 0,
        }
    end

    table.insert(console_messages, Add(Message, Duration, Player, Type))
end

function mod:GetIP(p)

    if (halo_type == 'PC') then
        ip_address = ip_table[p]
    else
        ip_address = get_var(p, '$ip')
    end
    if ip_address ~= nil then
        return ip_address:match('(%d+.%d+.%d+.%d+:%d+)')
    else
        error(debug.traceback())
    end
end

function mod:GetPlayerCount()
    return tonumber(get_var(0, "$pn"))
end

function mod:modifyScorelimit()
    local player_count = mod:GetPlayerCount()
    local scoreTable = mod:GetScoreLimit()

    local msg = nil

    if (player_count <= 4 and current_scorelimit ~= scoreTable[1]) then
        mod:SetScorelimit(scoreTable[1])
        msg = gsub(gsub(scoreTable.txt, "%%scorelimit%%", scoreTable[1]), "%%s%%", mod:getChar(scoreTable[1]))

    elseif (player_count > 4 and player_count <= 8 and current_scorelimit ~= scoreTable[2]) then
        mod:SetScorelimit(scoreTable[2])
        msg = gsub(gsub(scoreTable.txt, "%%scorelimit%%", scoreTable[2]), "%%s%%", mod:getChar(scoreTable[2]))

    elseif (player_count >= 9 and player_count <= 12 and current_scorelimit ~= scoreTable[3]) then
        mod:SetScorelimit(scoreTable[3])
        msg = gsub(gsub(scoreTable.txt, "%%scorelimit%%", scoreTable[3]), "%%s%%", mod:getChar(scoreTable[3]))

    elseif (player_count >= 13 and current_scorelimit ~= scoreTable[4]) then
        mod:SetScorelimit(scoreTable[4])
        msg = gsub(gsub(scoreTable.txt, "%%scorelimit%%", scoreTable[4]), "%%s%%", mod:getChar(scoreTable[4]))
    end

    if (msg ~= nil) then
        say_all(msg)
    end
end

function mod:SetScorelimit(score)
    current_scorelimit = score
    execute_command("scorelimit " .. score)
end

function mod:isInVehicle(PlayerIndex)
    if (get_dynamic_player(PlayerIndex) ~= 0) then
        local VehicleID = read_dword(get_dynamic_player(PlayerIndex) + 0x11C)
        if VehicleID == 0xFFFFFFFF then
            return false
        else
            return true
        end
    else
        return false
    end
end

function mod:cls(player)
    if (player) then
        for _ = 1, 25 do
            rprint(player, " ")
        end
    end
end

function mod:ObjectTagID(object)
    if (object ~= nil and object ~= 0) then
        return read_string(read_dword(read_word(object) * 32 + 0x40440038))
    else
        return ""
    end
end

function mod:stringSplit(inp, sep)
    if (sep == nil) then
        sep = "%s"
    end
    local t, i = {}, 1
    for str in gmatch(inp, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function mod:getChar(input)
    local char = ""
    if (tonumber(input) > 1) then
        char = "s"
    elseif (tonumber(input) <= 1) then
        char = ""
    end
    return char
end
