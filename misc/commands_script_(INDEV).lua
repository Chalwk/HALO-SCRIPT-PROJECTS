-- Commands Script 1.0 for SAPP (PC/CE)
-- Credits to AelitePrime and Wizard for the original commands script (version 4.2 for Phasor).
-- Converted to SAPP and re-written by Jericho Crosby (Chalwk)

-- [ IN DEVELOPMENT ] -- -- [ IN DEVELOPMENT ] -- -- [ IN DEVELOPMENT ] -- -- [ IN DEVELOPMENT ] --
-- Counts
cur_players = 0
ip_banid = 0
iprange_banid = 0
rcon_passwords_id = 0
rtv_timeout = 1
textbanid = 0
uniques = 0
welcome_msg_duration = 30

Say = say_all
privatesay = say
privateSay = rprint

-- Booleans
notyetshown = true
rtv_initiated = 0
votekicktimeout_table = false
Multi_Control = true
use_logo = true
tbag_detection = true
msga = nil

-- Strings
api_version = '1.11.0.0'
script_version = '1.0'
data_folder = 'sapp\\'
s_chat_dir = 'sapp\\Server Chat.txt'
server_prefix = '** SERVER **'
TimeStamp = os.date("[%d/%m/%Y - %H:%M:%S]")
message_board = {
    "Welcome to the TestBench - by Chalwk",
    "",
    "For updates on my current projects or to request an addon for your server, go to:",
    "https://github.com/Chalwk/HALO-SCRIPT-PROJECTS"
}

-- Tables
welcome_timer = { }
new_timer = { }
players_alive = { }
weapons = { }
vehicles = { }
TIMER = { }
last_damage = { }
access_table = { }
admin_table = { }
bipds_table = { }
eqip_table = { }
afk = { }
banned_hashes = { }
bos_table = { }
boslog_table = { }
crouch = { }
control_table = { }
dmgmultiplier = { }
follow = { }
hidden = { }
gods = { }
ghost_table = { }
ipadmins = { }
ip_banlist = { }
iprange_banlist = { }
loc = { }
mode = { }
mute_table = { }
mute_banlist = { }
name_bans = { }
nukes = { }
Noweapons = { }
slayer_score = { }
spam_table = { }
spamtimeout_table = { }
players_list = { }
player_ping = { }
suspend_table = { }
objects = { }
objspawnid = { }
rcon_passwords = { }
rtv_table = { }
tbag = { }
temp_admins = { }
unique_table = { }
vehicle_drone_table = { }
victim_coords = { }
votekick_table = { }

commands_table = {
    "/a",
    "/ipadminadd",
    "/ipadmindel",
    "/afk",
    "/alias",
    "/ammo",
    "/b",
    "/bos",
    "/boslist",
    "/bosplayers",
    "/banlist",
    "/balance",
    "/deathless",
    "/dmg",
    "/cmds",
    "/count",
    "/c",
    "/e",
    "/crash",
    "/eject",
    "/enter",
    "/falldamage",
    "/f",
    "/getloc",
    "/god",
    "/getip",
    "/hax",
    "/heal",
    "/hitler",
    "/infammo",
    "/give",
    "/gethash",
    "/hide",
    "/invis",
    "/info",
    "/ipban",
    "/ipbanlist",
    "/ipunban",
    "/iprangeban",
    "/iprangebanlist",
    "/iprangeunban",
    "/j",
    "/k",
    "/kill",
    "/lo3",
    "/launch",
    "/m",
    "/mc",
    "/mnext",
    "/mute",
    "/nuke",
    "/noweapons",
    "/nameban",
    "/namebanlist",
    "/nameunban",
    "/os",
    "/pvtsay",
    "/pl",
    "/read",
    "/reset",
    "/resp",
    "/revoke",
    "/resetplayer",
    "/resetweapons",
    "/say",
    "/setammo",
    "/setassists",
    "/setcolor",
    "/setdeaths",
    "/setfrags",
    "/setkills",
    "/setmode",
    "/setresp",
    "/setscore",
    "/setplasmas",
    "/spd",
    "/spawn",
    "/specs",
    "/superban",
    "/suspend",
    "/timelimit",
    "/takeweapons",
    "/textban",
    "/textbanlist",
    "/textunban",
    "/tp",
    "/ts",
    "/unban",
    "/unbos",
    "/unhide",
    "/ungod",
    "/unhax",
    "/uninvis",
    "/unmute",
    "/unsuspend",
    "/viewadmins",
    "/write",
    "/clean"
}

command_access = {
    "sv_k",
    "sv_b",
    "sv_crash",
    "sv_ipban",
    "sv_iprangeban",
    "sv_nameban",
    "sv_superban",
    "sv_kick",
    "sv_ban",
}

default_commands = {
    "sv_chatcommands 1",
    "sv_adminblocker 0",
    "sv_anticaps false",
    "sv_antispam all",
    "sv_deathless false",
    "sv_falldamage true",
    "sv_firstjoin_message true",
    "sv_hash_duplicates true",
    "sv_infinite_ammo false",
    "sv_killspree true",
    "sv_multiteam_vehicles false",
    "sv_noweapons false",
    "sv_pvtmessage 1",
    "sv_respawn_time default",
    "sv_rtv_enabled false",
    "sv_rtv_needed 0.6",
    "sv_serveradmin_message true",
    "sv_scrimmode false",
    "sv_spammax 7",
    "sv_spamtimeout 1",
    "sv_tbagdet true",
    "sv_uniques_enabled true",
    "sv_votekick_enabled false",
    "sv_votekick_needed 0.7",
    "sv_votekick_action kick",
    "sv_welcomeback_message true"
}

scrim_mode_commands = {
    "crash",
    "cheat_hax",
    "deathless",
    "enter",
    "eject",
    "falldamage",
    "follow",
    "setgod",
    "god",
    "dmg",
    "damage",
    "heal",
    "hide",
    "hitler",
    "hax",
    "infinite_ammo",
    "infammo",
    "kill",
    "move",
    "j",
    "os",
    "resetweapons",
    "resp",
    "spawn",
    "give",
    "setammo",
    "setassists",
    "setcolor",
    "setdeaths",
    "setfrags",
    "setkills",
    "setmode",
    "setscore",
    "setplasmas",
    "setspeed",
    "spd",
    "suspend",
    "takeweapons",
    "teleport_pl",
    "tp",
    "time_cur",
}

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
    register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_PREJOIN'], "OnPlayerPrejoin")
    register_callback(cb['EVENT_COMMAND'], "OnServerCommand")
    register_callback(cb['EVENT_PRESPAWN'], "OnPlayerPrespawn")
    register_callback(cb['EVENT_OBJECT_SPAWN'], "OnObjectSpawn")
    register_callback(cb['EVENT_VEHICLE_ENTER'], "OnVehicleEntry")
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamageApplication")
    profilepath = getprofilepath()
    GetGameAddresses()
    LoadTags()
    if halo_type == "PC" then
        ce = 0x0
    else
        ce = 0x40
    end
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    if get_var(0, "$gt") ~= "n/a" then
    end
    local rf = sig_scan("B8????????E8??000000A1????????55")
    if rf ~= 0 then
        msga = read_dword(rf + 1)
        safe_write(true)
        write_byte(msga, 0)
        safe_write(false)
    end
    -- if halo_type == "PC" then
    -- gametype_base = 0x671340
    -- else
    -- gametype_base = 0x5F5498
    -- end
    -- if read_byte(gametype_base + 0x34) == 1 then
    -- compatible = false
    -- else
    -- compatible = true
    -- end
    team_play = getteamplay()
    for i = 1, 16 do
        if getplayer(i) then
            local ip = getip(i)
            cur_players = cur_players + 1
            tbag[i] = { }
            dmgmultiplier[ip] = 1.0
            local player_id = get_var(i, "$n")
            players_alive[player_id] = { }
            players_alive[player_id].pl_afk = nil
            players_alive[player_id].pl_vehicle = nil
            players_alive[player_id].invis_time = 0
            players_alive[player_id].new_timer = 0
            players_alive[player_id].new_timer = 0
        end
        gameend = false
        vehicle_drone_table[i] = { }
        players_list[i] = { }
        loc[i + 1] = { }
        control_table[i + 1] = { }
    end
    local file = io.open(profilepath .. "commands_ipbanlist.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            ip_banlist[tostring(words[2])] = { }
            local time = tonumber(words[3]) or -1
            table.insert(ip_banlist[tostring(words[2])], { ["name"] = words[1], ["ip"] = words[2], ["time"] = time, ["id"] = ip_banid })
            ip_banid = ip_banid + 1
        end
        file:close()
    end
    local file = io.open(profilepath .. "commands_iprangebanlist.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            iprange_banlist[tostring(words[2])] = { }
            local time = tonumber(words[3]) or -1
            table.insert(iprange_banlist[tostring(words[2])], { ["name"] = words[1], ["ip"] = words[2], ["time"] = time, ["id"] = iprange_banid })
            iprange_banid = iprange_banid + 1
        end
        file:close()
    end
    local file = io.open(profilepath .. "commands_textbanlist.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            mute_banlist[tostring(words[3])] = { }
            local time = tonumber(words[4]) or -1
            table.insert(mute_banlist[tostring(words[3])], { ["name"] = words[1], ["hash"] = words[2], ["ip"] = words[3], ["time"] = time, ["id"] = textbanid })
            textbanid = textbanid + 1
        end
        file:close()
    end
    local file = io.open(profilepath .. "commands_namebans.txt", "r")
    if file then
        for line in file:lines() do
            table.insert(name_bans, line)
        end
        file:close()
    end
    local file = io.open(profilepath .. "changelog_" .. script_version .. ".txt", "r")
    if file then
        changelog = true
        file:close()
    else
        WriteChangeLog()
    end
    local file = io.open(profilepath .. "commands_admin.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            if #words >= 3 and tonumber(words[3]) then
                if not admin_table then
                    admin_table = { }
                end
                if not admin_table[words[2]] then
                    admin_table[words[2]] = { }
                end
                admin_table[words[2]].name = words[1]
                admin_table[words[2]].level = words[3]
            end
            if #words == 4 and tonumber(words[3]) then
                if not ipadmins[words[4]] then
                    ipadmins[words[4]] = { }
                end
                ipadmins[words[4]].name = words[1]
                ipadmins[words[4]].level = words[3]
            end
        end
        file:close()
    end
    local file = io.open(profilepath .. "commands_admins.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            if not admin_table[words[2]] then
                admin_table[words[2]] = { }
            end
            admin_table[words[2]].name = words[1]
            admin_table[words[2]].level = words[3]
            if #words == 4 and tonumber(words[3]) then
                if not ipadmins[words[4]] then
                    ipadmins[words[4]] = { }
                end
                ipadmins[words[4]].name = words[1]
                ipadmins[words[4]].level = words[3]
            end
        end
        file:close()
    else
        local file = io.open(profilepath .. "commands_admins.txt", "w")
        for k, v in pairs(ipadmins) do
            file:write(tostring(ipadmins[k].name .. "," .. k .. "," .. ipadmins[k].level) .. "\n")
        end
        file:close()
    end
    local file = io.open(profilepath .. "commands_ipadmins.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            if #words == 3 and tonumber(words[3]) then
                if not ipadmins[words[2]] then
                    ipadmins[words[2]] = { }
                end
                ipadmins[words[2]].name = words[1]
                ipadmins[words[2]].level = words[3]
            end
        end
        file:close()
    else
        local file = io.open(profilepath .. "commands_ipadmins.txt", "w")
        for k, v in pairs(ipadmins) do
            file:write(tostring(ipadmins[k].name .. "," .. k .. "," .. ipadmins[k].level) .. "\n")
        end
        file:close()
    end
    local access_levels = 0
    local datas = 0
    local file = io.open(profilepath .. "commands_access.ini", "r")
    if file then
        for line in file:lines() do
            if string.sub(line, 1, 1) == "[" then
                access_levels = access_levels + 1
            elseif string.sub(line, 1, 4) == "data" then
                datas = datas + 1
            end
        end
        file:close()
    end
    if access_levels == datas then
        local file = io.open(profilepath .. "commands_access.ini", "r")
        if file then
            local level
            for line in file:lines() do
                if level == nil then
                    local start = string.sub(line, 2, 2)
                    level = tonumber(start)
                    if level == nil then
                        break
                    end
                else
                    if string.sub(line, 1, 1) ~= "[" then
                        local words = tokenizestring(line, ",")
                        words[1] = string.sub(words[1], 6)
                        for i = 1, #words do
                            if words[i] == "-1" then
                                access_table[level] = -1
                                break
                            end
                            if access_table[level] == nil then
                                access_table[level] = "" .. words[i]
                            else
                                access_table[level] = access_table[level] .. "," .. words[i]
                            end
                        end
                        level = level + 1
                    end
                end
            end
            file:close()
            AccessMerging()
        else
            file = io.open(profilepath .. "commands_access.ini", "w")
            file:write("[0]\n")
            file:write("data=-1\n")
            file:write("[1]\n")
            file:write("data=sv_admin_add,sv_admin_cur,sv_admin_list,sv_alias,sv_alias_hash,sv_alias_search,sv_ban,sv_banlist,sv_changeteam,sv_commands,sv_end_game,sv_gethash,sv_invis,sv_kick,sv_kill,sv_map,sv_map_next,sv_map_reset,sv_mapcycle,sv_mapcycle_begin,sv_maplist,sv_password,sv_players,sv_reloadaccess,sv_reloadscripts,sv_say,sv_setspeed,sv_status,sv_teams_balance,sv_teleport,sv_teleport_list,sv_timelimit,sv_unban,sv_viewadmins,sv_setafk,sv_ipadmin_add,sv_ipadmindel,sv_revoke,sv_launch,sv_getip,sv_crash,sv_nameban,sv_namebanlist,sv_nameunban,sv_ipban,sv_ipbanlist,sv_ipunban,sv_superban,sv_hide,sv_textban,sv_textbanlist,sv_textunban,sv_pvtsay,sv_unhide,sv_setammo,sv_help,sv_setmode,sv_eject,sv_getloc,sv_ghost,sv_unghost,sv_setgod,sv_heal,sv_ungod,sv_hitler,sv_move,sv_scrim,sv_mute,sv_noweapons,sv_resp,sv_enter,sv_setassists,sv_setdeaths,sv_setfrags,sv_setkills,sv_setscore,sv_respawn_time,sv_setplasmas,sv_spawn,sv_give,sv_suspend,sv_teleport_pl,sv_unmute,sv_unsuspend,sv_bos,sv_takeweapons,sv_resetweapons,sv_boslist,sv_unbos,sv_kill,sv_help\n")
            file:write("[2]\n")
            file:write("data=sv_alias,sv_alias_hash,sv_alias_search,sv_ban,sv_banlist,sv_changeteam,sv_commands,sv_end_game,sv_gethash,sv_invis,sv_kick,sv_kill,sv_map,sv_map_next,sv_map_reset,sv_mapcycle,sv_mapcycle_begin,sv_maplist,sv_players,sv_say,sv_setspeed,sv_status,sv_teams_balance,sv_teleport,sv_teleport_list,sv_timelimit,sv_unban,sv_viewadmins,sv_setafk,sv_launch,sv_getip,sv_crash,sv_nameban,sv_namebanlist,sv_nameunban,sv_ipban,sv_ipbanlist,sv_ipunban,sv_superban,sv_hide,sv_textban,sv_textbanlist,sv_textunban,sv_pvtsay,sv_unhide,sv_help,sv_setmode,sv_eject,sv_getloc,sv_ghost,sv_unghost,sv_heal,sv_ungod,sv_move,sv_scrim,sv_mute,sv_noweapons,sv_resp,sv_enter,sv_respawn_time,sv_spawn,sv_give,sv_suspend,sv_teleport_pl,sv_unmute,sv_unsuspend,sv_bos,sv_resetweapons,sv_boslist,sv_unbos,sv_kill,sv_help\n")
            file:write("[3]\n")
            file:write("data=sv_kick,sv_ban,sv_unban,sv_ipban,sv_ipunban,sv_mute,sv_unmute,sv_textban,sv_textunban,sv_alias,sv_suspend,sv_unsuspend\n")
            file:write("[4]\n")
            file:write("data=sv_kick,sv_ban,sv_unban,sv_ipban,sv_ipunban,sv_mute,sv_unmute,sv_textban,sv_textunban,sv_alias,sv_alias_hash,sv_suspend,sv_unsuspend")
            access_table[0] = -1
            file:close()
        end
    else
        access_error = true
    end
    local file = io.open(profilepath .. "commands_bos.data", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            local count = #words
            words[1] = words[1]:gsub(" ", "", 1)
            table.insert(boslog_table, words[1] .. "," .. words[2] .. "," .. words[3])
            table.insert(banned_hashes, words[2])
        end
        file:close()
    end
    table.sort(boslog_table)
    local file = io.open(profilepath .. "commands_bannedhashes.data", "r")
    if file then
        for line in file:lines() do
            local bool = true
            for k, v in pairs(banned_hashes) do
                if v == line then
                    bool = false
                    break
                end
            end
            if bool then
                table.insert(banned_hashes, line)
            end
        end
        file:close()
    end
    local file = io.open(profilepath .. "\\data\\rconpasswords.data", "r")
    if file then
        for line in file:lines() do
            local word = tokenizestring(line, ",")
            if #word == 2 then
                rcon_passwords[rcon_passwords_id] = { }
                table.insert(rcon_passwords[rcon_passwords_id], { ["password"] = word[1], ["level"] = word[2] })
                rcon_passwords_id = rcon_passwords_id + 1
            end
        end
        rcon_passwords_id = rcon_passwords_id + 1
    end
end

function OnScriptUnload()
    local file = io.open(profilepath .. "commands_bos.data", "w")
    for k, v in pairs(boslog_table) do
        if v then
            file:write(v .. "\n")
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_bannedhashes.data", "w")
    for k, v in pairs(banned_hashes) do
        if v then
            file:write(v .. "\n")
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_ipadmins.txt", "w")
    for k, v in pairs(ipadmins) do
        file:write(tostring(ipadmins[k].name .. "," .. k .. "," .. ipadmins[k].level) .. "\n")
    end
    file:close()
    local file = io.open(profilepath .. "commands_admins.txt", "w")
    for k, v in pairs(admin_table) do
        file:write(tostring(admin_table[k].name .. "," .. k .. "," .. admin_table[k].level) .. "\n")
    end
    file:close()
    local file = io.open(profilepath .. "commands_uniques.txt", "w")
    for k, v in pairs(unique_table) do
        file:write(tostring(k .. "," .. v[1] .. "," .. v[2]) .. "\n")
    end
    file:close()
    local file = io.open(profilepath .. "commands_textbanlist.txt", "w")
    for k, v in pairs(mute_banlist) do
        for key, value in pairs(mute_banlist[k]) do
            file:write(tostring(mute_banlist[k][key].name .. "," .. mute_banlist[k][key].hash .. "," .. mute_banlist[k][key].ip .. "," .. mute_banlist[k][key].time) .. "\n")
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_ipbanlist.txt", "w")
    for k, v in pairs(ip_banlist) do
        for key, value in pairs(ip_banlist[k]) do
            file:write(tostring(ip_banlist[k][key].name .. "," .. ip_banlist[k][key].ip .. "," .. ip_banlist[k][key].time) .. "\n")
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_iprangebanlist.txt", "w")
    for k, v in pairs(iprange_banlist) do
        for key, value in pairs(iprange_banlist[k]) do
            file:write(tostring(iprange_banlist[k][key].name .. "," .. iprange_banlist[k][key].ip .. "," .. iprange_banlist[k][key].time) .. "\n")
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_rconpasswords.data", "w")
    for k, v in pairs(rcon_passwords) do
        if rcon_passwords[k] ~= nil or rcon_passwords[k] ~= { } then
            for key, value in ipairs(rcon_passwords[k]) do
                file:write(rcon_passwords[k][key].password .. "," .. rcon_passwords[k][key].level .. "\n")
            end
        end
    end
    file:close()
    local file = io.open(profilepath .. "commands_namebans.txt", "w")
    for k, v in pairs(name_bans) do
        file:write(tostring(v) .. "\n")
    end
    file:close()
    local file = io.open(profilepath .. "temp.tmp", "w")
    if admin_blocker then
        file:write("sv_adminblocker " .. tostring(admin_blocker) .. "\n")
    else
        file:write("sv_adminblocker 0\n")
    end
    if anticaps then
        file:write("sv_anticaps true\n")
    else
        file:write("sv_anticaps false\n")
    end
    if antispam then
        file:write("sv_antispam " .. tostring(antispam) .. "\n")
    end
    if chatcommands then
        file:write("sv_chatcommands true\n")
    else
        file:write("sv_chatcommands false\n")
    end
    if deathless then
        file:write("sv_deathless true\n")
    else
        file:write("sv_deathless false\n")
    end
    if falldamage then
        file:write("sv_falldamage true\n")
    else
        file:write("sv_falldamage false\n")
    end
    if firstjoin_message then
        file:write("sv_firstjoin_message true\n")
    else
        file:write("sv_firstjoin_message false\n")
    end
    if hash_duplicates then
        file:write("sv_hash_duplicates true\n")
    else
        file:write("sv_hash_duplicates false\n")
    end
    if infammo then
        file:write("sv_infinite_ammo true\n")
    else
        file:write("sv_infinite_ammo false\n")
    end
    if killing_spree then
        file:write("sv_killspree true\n")
    else
        file:write("sv_killspree false\n")
    end
    if multiteam_vehicles then
        file:write("sv_multiteam_vehicles true\n")
    else
        file:write("sv_multiteam_vehicles false\n")
    end
    if noweapons then
        file:write("sv_noweapons true\n")
    else
        file:write("sv_noweapons false\n")
    end
    if pm_enabled then
        file:write("sv_pvtmessage true\n")
    else
        file:write("sv_pvtmessage false\n")
    end
    if respset then
        file:write("sv_respawn_time " .. tostring(resptime) .. "\n")
    else
        file:write("sv_respawn_time default\n")
    end
    if rockthevote then
        file:write("sv_rtv_enabled true\n")
    else
        file:write("sv_rtv_enabled false\n")
    end
    if tonumber(rtv_required) then
        file:write("sv_rtv_needed " .. tostring(rtv_required) .. "\n")
    else
        file:write("sv_rtv_needed 0.6\n")
    end
    if sa_message then
        file:write("sv_serveradmin_message true\n")
    else
        file:write("sv_serveradmin_message false\n")
    end
    if scrim_mode then
        file:write("sv_scrimmode true\n")
    else
        file:write("sv_scrimmode false\n")
    end
    if tonumber(spam_max) then
        file:write("sv_spammax " .. tostring(spam_max) .. "\n")
    else
        file:write("sv_spammax 7\n")
    end
    if tonumber(spam_timeout) then
        file:write("sv_spamtimeout " .. tostring(round(spam_timeout / 60, 1)) .. "\n")
    else
        file:write("sv_spamtimeout 1\n")
    end
    if tbag_detection then
        file:write("sv_tbagdet true\n")
    else
        file:write("sv_tbagdet false\n")
    end
    if uniques_enabled then
        file:write("sv_uniques_enabled true\n")
    else
        file:write("sv_uniques_enabled false\n")
    end
    if votekick_allowed then
        file:write("sv_votekick_enabled true\n")
    else
        file:write("sv_votekick_enabled false\n")
    end
    if tonumber(votekick_required) then
        file:write("sv_votekick_needed " .. tostring(votekick_required) .. "\n")
    else
        file:write("sv_votekick_needed 0.7\n")
    end
    if votekick_action then
        file:write("sv_votekick_action " .. tostring(votekick_action) .. "\n")
    else
        file:write("sv_votekick_action kick \n")
    end
    if wb_message then
        file:write("sv_welcomeback_message true\n")
    else
        file:write("sv_welcomeback_message false\n")
    end
    file:close()
    for i = 1, 16 do
        cleanupdrones(i)
        timer(0, "cleanupdrones", i)
    end
    if msga ~= nil then
        safe_write(true)
        write_byte(msga, 0x72)
        safe_write(false)
    end
end

function secondsToTime(seconds, places)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    if places == 2 then
        return minutes, seconds
    end
end

function cls(PlayerIndex)
    for clear_cls = 1, 25 do
        rprint(PlayerIndex, " ")
    end
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) then
            if (welcome_timer[i] == true) then
                local player_id = get_var(i, "$n")
                players_alive[player_id].new_timer = players_alive[player_id].new_timer + 0.030
                cls(i)
                for k, v in pairs(message_board) do
                    rprint(i, "" .. v)
                end
                if players_alive[player_id].new_timer >= math.floor(welcome_msg_duration) then
                    welcome_timer[i] = false
                    players_alive[player_id].new_timer = 0
                end
            end
        end
    end
    for i = 1, 16 do
        if player_present(i) then
            if (player_alive(i)) then
                if noweapons or Noweapons[getip(i)] then
                    local player_object = get_dynamic_player(i)
                    local weaponId = read_dword(player_object + 0x118)
                    if weaponId ~= 0 then
                        for j = 0, 3 do
                            local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                            destroy_object(m_weapon)
                        end
                    end
                end
            end
        end
    end
    for i = 1, 16 do
        if player_present(i) then
            if getplayer(i) then
                local ip = getip(i)
                if ghost_table[ip] == true then
                    camo(i, 1)
                elseif ghost_table[ip] and ghost_table[ip] > 0 then
                    camo(i, ghost_table[ip])
                    if (TIMER[i] ~= false and PlayerAlive(i) == true) then
                        local player_id = get_var(i, "$n")
                        players_alive[player_id].invis_time = players_alive[player_id].invis_time + 0.030
                        if players_alive[player_id].invis_time >= math.floor(invisibility_time) then
                            TIMER[i] = false
                            ghost_table[ip] = nil
                            invisibility_time = 0
                            privateSay(i, "You are no longer invisible")
                        end
                    end
                end
            end
        end
    end
    for i = 1, 16 do
        if (player_alive(i)) then
            if isinvehicle(i) then
                local player = get_dynamic_player(i)
                local current_vehicle = read_dword(player + 0x11C)
                if (current_vehicle ~= 0xFFFFFFFF) then
                    local vehicle = get_object_memory(current_vehicle)
                    local player_id = get_var(i, "$n")
                    players_alive[player_id].pl_vehicle = current_vehicle
                end
            end
        end
    end
    for i = 1, 16 do
        if player_present(i) then
            if tbag_detection then
                if tbag[i] == nil then
                    tbag[i] = { }
                end
                if tbag[i].name and tbag[i].x then
                    if not isinvehicle(i) then
                        if inSphere(i, tbag[i].x, tbag[i].y, tbag[i].z, 5) then
                            local m_objectId = getplayerobjectid(i)
                            local obj_crouch = read_byte(m_objectId + 0x2A0)
                            local id = resolveplayer(i)
                            if obj_crouch == 3 and crouch[id] == nil then
                                crouch[id] = OnPlayerCrouch(i)
                            elseif obj_crouch ~= 3 and crouch[id] ~= nil then
                                crouch[id] = nil
                            end
                        end
                    end
                end
            end
            local player_object_id = read_dword(getplayer(i) + 0x34)
            local player_object = get_object_memory(player_object_id)
            local m_player = get_dynamic_player(i)
            if player_object ~= 0 then
                local id = resolveplayer(i)
                local x_aim = read_float(player_object + 0x230)
                local y_aim = read_float(player_object + 0x234)
                local z_aim = read_float(player_object + 0x238)
                local z = read_float(m_player + 0x100)
                local obj_forward = read_float(player_object + 0x278)
                local obj_left = read_float(player_object + 0x27C)
                local obj_crouch = read_byte(player_object + 0x2A0)
                local player_id = get_var(i, "$n")
                if players_alive[player_id] ~= nil then
                    if (i == players_alive[player_id].pl_afk) then
                        local afk_x = x_aim
                        local afk_y = y_aim
                        local afk_z = z_aim
                        write_bit(player_object + 0x10, 7, 1)
                        if x_aim ~= afk_x or y_aim ~= afk_y or z_aim ~= afk_z or obj_forward ~= 0 or obj_left ~= 0 then
                            write_bit(player_object + 0x10, 7, 0)
                            privateSay(i, "You are no longer afk")
                            players_alive[player_id].pl_afk = nil
                        else
                            write_float(m_player + 0x100, z - 1000)
                        end
                    end
                end
                if hidden[id] then
                    write_vector3d(get_player(i) + 0xF8, math.pow(2, 10), math.pow(2, 10), -math.pow(2, 10))
                    local player_object = get_dynamic_player(i)
                    local flags = read_dword(player_object + 0x10)
                    if (bit.band(flags, 1) == 0) then
                        flags = flags + 1
                    end
                    if (bit.band(flags, math.pow(2, 24)) ~= 0) then
                        flags = flags - math.pow(2, 24)
                    end
                    write_dword(player_object + 0x10, flags)
                    write_word(player_object + 0x31E, 0x7F7F)
                end
            end
        end
    end
    return true
end

function getprofilepath()
    local folder_directory = data_folder
    return folder_directory
end

function getteamplay()
    if get_var(0, "$ffa") == "0" then
        return true
    else
        return false
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

function getname(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local name = get_var(PlayerIndex, "$name")
        return name
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

function getip(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local ip = get_var(PlayerIndex, "$ip")
        return ip
    end
    return nil
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

function OnPlayerPrejoin(PlayerIndex)
    os.execute("echo \7")
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    local client_network_struct = network_struct + 0x1AA + ce + to_real_index(PlayerIndex) * 0x20
    local name = read_widestring(client_network_struct, 12)
    local hash = get_var(PlayerIndex, "$hash")
    local ip = get_var(PlayerIndex, "$ip")
    local id = get_var(PlayerIndex, "$n")
    players_alive[id] = nil
    cprint("---------------------------------------------------------------------------------------------------")
    cprint("              - - |   P L A Y E R   J O I N   | - -")
    cprint("     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    cprint("Player: " .. name, 10)
    cprint("CD Hash: " .. hash)
    cprint("IP Address: " .. ip)
    cprint("IndexID: " .. id)
    for k, v in pairs(name_bans) do
        if v == name then
            return false, "Player"
        end
    end
    local temp = tokenizestring(ip, ".")
    local ip2 = temp[1] .. "." .. temp[2]
    for k, v in pairs(ip_banlist) do
        if ip_banlist[k] ~= { } then
            for key, value in pairs(ip_banlist[k]) do
                if ip_banlist[k][key].ip == tostring(ip) then
                    return false
                end
            end
        end
    end
    for k, v in pairs(iprange_banlist) do
        if iprange_banlist[k] ~= { } then
            for key, value in pairs(iprange_banlist[k]) do
                if iprange_banlist[k][key].ip == tostring(ip2) then
                    return false
                end
            end
        end
    end
    for k, v in pairs(boslog_table) do
        local words = tokenizestring(v, ",")
        if words[3] == ip then
            local entry_name = words[1]
            for i = 1, 16 do
                if getplayer(i) and (ipadmins[getip(i)] or admin_table[gethash(i)]) then
                    -- Tell Admins currently in server that this player is banned from BoS
                    privateSay(i, "Rejecting " .. entry_name .. " - banned from BoS.")
                    privateSay(i, "Entry: " .. entry_name .. " - " .. words[2] .. " - " .. words[3])
                    -- Log to dedicated server console
                    cprint("Rejecting " .. entry_name .. " - banned from BoS.", 10)
                    cprint("Entry: " .. entry_name .. " - " .. words[2] .. " - " .. words[3], 10)
                    -- Send message to banned player.
                    privateSay(PlayerIndex, "Unable to connect. You are currently banned!")
                    execute_command("k" .. " " .. i)
                end
            end
            BanReason(entry_name .. " was Banned on Sight")
            table.insert(name_bans, name)
            table.insert(banned_hashes, hash)
            ip_banlist[ip] = { }
            table.insert(ip_banlist[ip], { ["name"] = entry_name, ["ip"] = ip, ["time"] = -1, ["id"] = ip_banid })
            ip_banid = ip_banid + 1
            -- iprange_banlist[ip] = { }
            -- local words = tokenizestring(ip, ".")
            -- local ip2 = words[1] .. "." .. words[2]
            -- table.insert(iprange_banlist[ip2], { ["name"] = entry_name, ["ip"] = ip2, ["time"] = - 1, ["id"] = iprange_banid })
            -- iprange_banid = ip_banid + 1
            -- table.remove(boslog_table, k)
            return false
        end
    end
    return nil
end

function OnNewGame()
    gameend = false
    rtv_initiated = 0
    rtv_table = { }
    bos_table = { }
    votekicktimeout_table = false
    team_play = getteamplay()
    LoadTags()
    GetGameAddresses()
    DefaultSvTimer()
    for i = 1, 16 do
        if getplayer(i) then
            local ip = getip(i)
            cur_players = cur_players + 1
            tbag[i] = { }
            dmgmultiplier[ip] = 1.0
            local player_id = get_var(i, "$n")
            if player_present(i) then
                players_alive[player_id].pl_afk = nil
                players_alive[player_id].invis_time = 0
                players_alive[player_id].pl_vehicle = nil
                players_alive[player_id].new_timer = 0
            end
        end
        gameend = false
        vehicle_drone_table[i] = { }
        players_list[i] = { }
        loc[i + 1] = { }
        control_table[i + 1] = { }
    end
    local file = io.open(s_chat_dir, "a+")
    if file ~= nil then
        local map = get_var(0, "$map")
        local gt = get_var(0, "$mode")
        local n1 = "\n"
        local t1 = os.date("[%A %d %B %Y] - %X - A new game has started on " .. tostring(map) .. ", Mode: " .. tostring(gt))
        local n2 = "\n---------------------------------------------------------------------------------------------\n"
        file:write(n1, t1, n2)
        file:close()
    end
end

function OnGameEnd()
    gameend = true
    for i = 1, 16 do
        if player_present(i) then
            TIMER[i] = false
            local player_id = get_var(i, "$n")
            players_alive[player_id].pl_afk = nil
            players_alive[player_id].invis_time = 0
            players_alive[player_id].pl_vehicle = nil
            players_alive[player_id].new_timer = 0
            timer(0, "cleanupdrones", i)
        end
    end
    rtvtimer = nil
    votekicktimeouttimer = nil
    rtv_initiated = -1
    votekick_allowed = false
    local file = io.open(profilepath .. "commands_bos.data", "w")
    if file then
        for k, v in pairs(boslog_table) do
            if v then
                file:write(v .. "\n")
            end
        end
        file:close()
    end
    local file = io.open(s_chat_dir, "a+")
    if file ~= nil then
        local data = os.date("[%A %d %B %Y] - %X - The game is ending - ")
        file:write(data)
        file:close()
    end
end

function OnPlayerChat(PlayerIndex, Message, type)
    local Message = tostring(Message)
    local Command = tokenizestring(Message)
    local name = get_var(PlayerIndex, "$name")
    local s_chat_name = get_var(PlayerIndex, "$name")
    local s_chat_id = get_var(PlayerIndex, "$n")
    local s_chat_ip = get_var(PlayerIndex, "$ip")
    local s_chat_hash = get_var(PlayerIndex, "$hash")
    iscommand = nil
    if string.sub(Command[1], 1, 1) == "/" or string.sub(Command[1], 1, 1) == "\\" then
        iscommand = true
        ChatType = "[COMMAND] "
    else
        iscommand = false
    end
    if type == 0 then
        Type = "[GLOBAL]  "
    elseif type == 1 then
        Type = "[TEAM]    "
    elseif type == 2 then
        Type = "[VEHICLE] "
    end
    if (player_present(PlayerIndex) ~= nil) then
        if iscommand then
            WriteData(s_chat_dir, "   " .. ChatType .. "     " .. s_chat_name .. " [" .. s_chat_id .. "]: " .. Message)
            cprint(ChatType .. " " .. s_chat_name .. " [" .. s_chat_id .. "]: " .. Message, 11)
        else
            WriteData(s_chat_dir, "   " .. Type .. "     " .. s_chat_name .. " [" .. s_chat_id .. "]: " .. Message)
            cprint(Type .. " " .. s_chat_name .. " [" .. s_chat_id .. "]: " .. Message, 11)
        end
    end
    local response = nil
    local name = "PlayerIndex"
    local hash = "hash"
    local ip = "ip"
    if PlayerIndex then
        name = getname(PlayerIndex)
        hash = gethash(PlayerIndex)
        ip = getip(PlayerIndex)
    end
    local access
    if mute_table[ip] then
        return false
    elseif spamtimeout_table[ip] then
        return false
    else
        for k, v in pairs(mute_banlist) do
            if mute_banlist[k] ~= { } then
                for key, value in ipairs(mute_banlist[k]) do
                    if mute_banlist[k][key].hash == hash or mute_banlist[k][key].ip == ip then
                        return false
                    end
                end
            end
        end
    end
    ct = tokenizestring(Message, " ")
    local count = #ct
    if ct[1] == nil then
        return nil
    end
    if ct[1] == "votekick" then
        response = false
        if count == 2 then
            if votekick_allowed and votekicktimeout_table == false then
                local votekick_count = 0
                local votekick_number = round(cur_players * votekick_required, 0)
                local player2 = tonumber(ct[2]) - 1
                if getplayer(player2) then
                    local name2 = getname(player2)
                    local hash2 = gethash(player2)
                    local ip2 = getip(player2)
                    local admin
                    for i = 1, 16 do
                        if getplayer(i) then
                            if votekick_table[getip(i)] == 1 then
                                votekick_count = votekick_count + 1
                            end
                        end
                    end
                    if PlayerIndex ~= player2 then
                        if admin_table[hash2] or ipadmins[ip2] then
                            admin = true
                        end
                        if not admin then
                            votekick_allowed = player2
                            votekick_table[ip] = 1
                            votekick_count = votekick_count + 1
                            say(name .. " has initiated a votekick on " .. name2 .. "")
                            say("Type \"kick\" to join the vote")
                            votekicktimeout_table = true
                        else
                            privatesay(PlayerIndex, "Admins cannot be votekicked")
                        end
                    else
                        privatesay(PlayerIndex, "You cannot votekick yourself")
                    end
                    if votekick_count >= votekick_number then
                        votekick(name2, player2)
                    end
                else
                    privatesay(PlayerIndex, "Invalid Player")
                end
            elseif votekick_allowed and votekicktimeout_table then
                privatesay(PlayerIndex, "Votekick will be available shortly")
            else
                privatesay(PlayerIndex, "You cannot initiate a votekick at this time")
            end
        else
            privatesay(PlayerIndex, "You did not specify who to votekick")
        end
    elseif ct[1] == "kick" then
        if count == 1 then
            response = false
            if votekick_allowed ~= true and votekick_allowed and votekicktimeout_table then
                local votekick_count = 0
                local votekick_number = round(cur_players * votekick_required, 0)
                local name2 = getname(votekick_allowed)
                local player2 = resolveplayer(votekick_allowed)
                for i = 1, 16 do
                    if getplayer(i) then
                        if votekick_table[getip(i)] == 1 then
                            votekick_count = votekick_count + 1
                        end
                    end
                end
                if PlayerIndex ~= votekick_allowed then
                    if votekick_table[ip] == 1 then
                        privatesay(PlayerIndex, "You have already voted")
                    elseif votekick_table[ip] == nil then
                        votekick_table[ip] = 1
                        votekick_count = votekick_count + 1
                        say(name .. " has voted to kick " .. name2 .. "")
                        say(votekick_count .. " of " .. votekick_number .. " votes required to kick")
                    end
                else
                    privatesay(PlayerIndex, "You are not allowed to vote")
                end
                if votekick_count >= votekick_number then
                    votekick(name2, player2)
                end
            else
                privatesay(PlayerIndex, "A votekick has not been initiated")
            end
        end
    elseif pm_enabled and string.sub(ct[1], 1, 1) == "@" then
        response = false
        local receiverID = string.sub(ct[1], 2, ct[1]:len())
        local players = getvalidplayers(receiverID, PlayerIndex)
        if players then
            for i,player in pairs(players) do
                if PlayerIndex ~= i then
                    local privatemessage = table.concat(ct, " ", 2, #ct)
                    privateSay(PlayerIndex, "to " .. getname(players[i]) .. " (" .. players[i] + 1 .. ") :  " .. privatemessage)
                    privateSay(players[i], getname(PlayerIndex) .. " (" .. players[i] + 1 .. ") :  " .. privatemessage)
                end
                privatesay(PlayerIndex, "Message Sent")
            end
        else
            privatesay(PlayerIndex, "There is no player with an ID of " .. receiverID .. ".")
        end
        return false
    end
    if response == nil then
        access = getaccess(PlayerIndex)
    end
    if spam_max == nil then
        spam_max = 7
    end
    if spam_timeout == nil then
        spam_timeout = 60
    end
    if response == nil and antispam ~= "off" and spam_max > 0 and spam_timeout > 0 and type >= 0 and type <= 2 then
        if antispam == "all" then
            if not spam_table[ip] then
                spam_table[ip] = 1
            else
                spam_table[ip] = spam_table[ip] + 1
            end
        elseif antispam == "players" and not access then
            if not spam_table[ip] then
                spam_table[ip] = 1
            else
                spam_table[ip] = spam_table[ip] + 1
            end
        end
    end
    if response == nil and anticaps and PlayerIndex ~= nil then
        return true, string.lower(Message)
    end
    return response
end

function OnServerCommand(PlayerIndex, Command, Environment)
    local response = nil
    local temp = tokenizestring(Command)
    local cmd = temp[1]
    local access = getaccess(PlayerIndex)
    local permission
    local rcmd = string.lower(Command)
    if (Environment == 1) then
        use_console = true
    end
    if (Environment == 2) then
        use_console = false
    end
    if cmd ~= nil then
        if cmd ~= "cls" then
            if "sv_" ~= string.sub(cmd, 0, 3) then
                Command = "sv_" .. Command
            end
        end
    end
    t = tokenizestring(Command)
    count = #t
    invisibility_time = tonumber(t[3])
    invisibility_time = invisibility_time
    if (Environment == 0) then
        permission = true
    end
    if PlayerIndex ~= nil and PlayerIndex ~= 255 then
        if (next(admin_table) ~= nil or next(ipadmins) ~= nil) and access then
            permission = checkaccess(t[1], access, PlayerIndex)
        elseif next(admin_table) == nil and next(ipadmins) == nil then
            permission = false
        end
    elseif PlayerIndex == nil or PlayerIndex == 255 then
        permission = true
    end
    if permission and scrim_mode then
        local Command = t[1]
        if string.sub(Command, 0, 3) == "sv_" then
            Command = string.sub(Command, 4)
        end
        for i = 0, #scrim_mode_commands do
            if scrim_mode_commands[i] then
                if Command == scrim_mode_commands[i] then
                    sendresponse("This command is currently disabled.\nTurn Scrim Mode off to reenable this command.", t[1], PlayerIndex)
                    local name = "The Server"
                    if PlayerIndex then
                        name = getname(PlayerIndex)
                    end
                    cmdlog(name .. " attempted to use " .. t[1] .. " during scrim mode.")
                    return false
                end
            end
        end
    end
    if permission then
        if not ischatcommand then
            if t[1] == "sv_addrcon" then
                response = false
                Command_AddRconPassword(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setafk" or t[1] == "sv_afk" then
                response = false
                Command_AFK(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_admin_list" or t[1] == "sv_a" and t[2] == "list" then
                response = false
                Command_AdminList(PlayerIndex, t[1], count)
            elseif t[1] == "sv_a" and t[2] == "del" then
                response = false
                Command_Admindel(PlayerIndex, t[1] .. " " .. t[2], t[3], count)
            elseif t[1] == "sv_admin_add" or t[1] == "sv_a" then
                response = false
                Command_Adminadd(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_admin_del" then
                response = false
                Command_Admindel(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_revoke" then
                response = false
                Command_Adminrevoke(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_alias" or t[1] == "alias" then
                response = false
                Command_Alias(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_adminblocker" then
                response = false
                Command_AdminBlocker(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_anticaps" then
                response = false
                Command_AntiCaps(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_antispam" then
                response = false
                Command_AntiSpam(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_ban" and PlayerIndex == nil then
                response = Command_Ban(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_balance" then
                response = false
                Command_BalanceTeams(PlayerIndex, t[1], count)
            elseif (t[1] == "sv_b" or t[1] == "sv_ban") and PlayerIndex ~= nil then
                response = false
                Command_Ban2(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_bos" then
                response = false
                Command_Bos(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_boslist" then
                response = false
                Command_Boslist(PlayerIndex, t[1], count)
            elseif t[1] == "sv_bosplayers" then
                response = false
                Command_Bosplayers(PlayerIndex, t[1], count)
            elseif t[1] == "sv_chatcommands" then
                response = false
                Command_ChatCommands(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_change_level" or t[1] == "sv_cl" then
                response = false
                Command_ChangeLevel(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_changeteam" or t[1] == "sv_ts" then
                response = false
                Command_Changeteam(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_crash" then
                response = false
                Command_Crash(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_cmds" then
                response = false
                Command_Commands(PlayerIndex, t[1], count)
            elseif t[1] == "sv_c" or t[1] == "sv_control" then
                response = false
                Command_Control(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_count" then
                response = false
                Command_Count(PlayerIndex, t[1], count)
            elseif t[1] == "sv_uniques_enabled" or t[1] == " sv_uniquecount" then
                response = false
                Command_CountUniques(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_damage" or t[1] == "sv_dmg" then
                response = false
                Command_DamageMultiplier(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_deathless" or t[1] == "sv_d" then
                response = false
                Command_Deathless(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_delrcon" then
                response = false
                Command_DelRconPassword(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_eject" or t[1] == "sv_e" then
                response = false
                Command_Eject(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_falldamage" then
                response = false
                Command_Falldamage(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_firstjoin_message" then
                response = false
                Command_FirstJoinMessage(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_follow" or t[1] == "sv_f" then
                response = false
                Command_Follow(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_gethash" then
                response = false
                Command_Gethash(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_getip" then
                response = false
                Command_Getip(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_getloc" then
                response = false
                Command_Getloc(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_setgod" or t[1] == "sv_god" then
                response = false
                Command_Godmode(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_hash_check" then
                Command_Hashcheck(t[2])
            elseif t[1] == "sv_hash_duplicates" then
                response = false
                Command_HashDuplicates(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_cheat_hax" or t[1] == "sv_hax" then
                response = false
                Command_Hax(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_heal" or t[1] == "sv_h" then
                response = false
                Command_Heal(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_help" then
                response = false
                sendresponse(GetHelp(t[2]), t[1], PlayerIndex)
            elseif t[1] == "sv_hide" then
                response = false
                Command_Hide(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_hitler" then
                response = false
                if count == 1 then
                    for c = 1, 16 do
                        if getplayer(c) then
                            kill(c)
                            sendresponse(getname(c) .. " was given a lethal injection", t[1], PlayerIndex)
                        end
                    end
                else
                    sendresponse("Invalid Syntax: sv_hitler", t[1], PlayerIndex)
                end
            elseif t[1] == "sv_ipadminadd" then
                response = false
                Command_Ipadminadd(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_ipadmindel" then
                response = false
                Command_Ipadmindel(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_ipban" then
                response = false
                Command_Ipban(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_ipbanlist" then
                response = false
                Command_Ipbanlist(PlayerIndex, t[1], count)
            elseif t[1] == "sv_iprangeban" then
                response = false
                Command_Iprangeban(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_iprangebanlist" then
                response = false
                Command_Iprangebanlist(PlayerIndex, t[1], count)
            elseif t[1] == "sv_info" or t[1] == "sv_i" then
                response = false
                Command_Info(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_infinite_ammo" or t[1] == "sv_infammo" then
                response = false
                Command_Infammo(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_ipunban" then
                response = false
                Command_Ipunban(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_iprangeunban" then
                response = false
                Command_Iprangeunban(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_invis" then
                response = false
                Command_Invis(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_k" or t[1] == "sv_kick" and PlayerIndex ~= nil then
                response = false
                Command_Kick(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_kill" then
                response = false
                Command_Kill(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_killspree" then
                response = false
                Command_KillingSpree(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_launch" then
                response = false
                Command_Launch(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_list" then
                response = false
                Command_List(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_scrim" or t[1] == "sv_lo3" then
                response = false
                Command_Lo3(PlayerIndex, t[1], count)
            elseif t[1] == "sv_login" or t[1] == "sv_l" then
                response = false
                Command_Login(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_map" then
                if command:find("commands") == nil then
                    response = false
                    Command_Map(PlayerIndex, command)
                end
            elseif t[1] == "sv_mnext" then
                response = false
                Command_Mapnext(PlayerIndex, t[1], count)
            elseif t[1] == "sv_reset" then
                response = false
                Command_Mapreset(PlayerIndex, t[1], count)
            elseif t[1] == "sv_move" or t[1] == "sv_j" then
                response = false
                Command_Move(PlayerIndex, t[1], t[2], t[3], t[4], t[5], count)
            elseif t[1] == "sv_mute" then
                response = false
                Command_Mute(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_multiteam_vehicles" or t[1] == "mtv" then
                response = false
                Command_MultiTeamVehicles(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_nameban" or t[1] == "sv_n" then
                response = false
                Command_Nameban(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_namebanlist" then
                response = false
                Command_Namebanlist(PlayerIndex, t[1], count)
            elseif t[1] == "sv_nameunban" then
                response = false
                Command_Nameunban(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_noweapons" then
                response = false
                Command_Noweapons(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_nuke" then
                Command_Nuke(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_os" or t[1] == "sv_o" then
                response = false
                Command_Overshield(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_pvtmessage" or t[1] == "sv_p" then
                response = false
                Command_PrivateMessage(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_pvtsay" or t[1] == "sv_privatesay" then
                response = false
                Command_Privatesay(PlayerIndex, t, count)
            elseif t[1] == "sv_players_more" or t[1] == "sv_pl" and t[2] == "more" then
                response = false
                Command_PlayersMore(PlayerIndex, t[1], count)
            elseif t[1] == "sv_players" or t[1] == "sv_pl" then
                response = false
                Command_Players(PlayerIndex, t[1], count)
            elseif t[1] == "sv_rconlist" then
                response = false
                Command_RconPasswordList(PlayerIndex, t[1], count)
            elseif t[1] == "sv_read" then
                response = false
                Command_Read(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6], count)
            elseif t[1] == "sv_resetplayer" then
                response = false
                Command_ResetPlayer(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_resetweapons" then
                response = false
                Command_Resetweapons(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_resp" or t[1] == "sv_r" then
                response = false
                Command_Resp(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_rtv_enabled" then
                response = false
                Command_RTVEnabled(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_rtv_needed" then
                response = false
                Command_RTVRequired(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_serveradmin_message" then
                response = false
                Command_SAMessage(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_say" then
                response = false
                Command_Say(PlayerIndex, t, count)
            elseif t[1] == "sv_scrimmode" then
                response = false
                Command_ScrimMode(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_load" then
                response = false
                Command_ScriptLoad(PlayerIndex, command, count)
            elseif t[1] == "sv_unload" then
                response = false
                Command_ScriptUnload(PlayerIndex, command, count)
            elseif t[1] == "sv_enter" then
                response = false
                Command_Spawn(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6], "enter", count)
            elseif t[1] == "sv_spawn" or t[1] == "sv_s" then
                response = false
                Command_Spawn(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6], "spawn", count)
            elseif t[1] == "sv_give" then
                response = false
                Command_Spawn(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6], "give", count)
            elseif t[1] == "sv_spammax" then
                response = false
                Command_SpamMax(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_spamtimeout" then
                response = false
                Command_SpamTimeOut(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_setammo" then
                response = false
                Command_Setammo(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_setassists" then
                response = false
                Command_Setassists(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setcolor" then
                response = false
                Command_Setcolor(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setdeaths" then
                response = false
                Command_Setdeaths(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setfrags" then
                response = false
                Command_Setfrags(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setkills" then
                response = false
                Command_Setkills(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setmode" then
                response = false
                Command_Setmode(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_pass" then
                response = false
                Command_Setpassword(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_setscore" then
                response = false
                Command_Setscore(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_respawn_time" then
                response = false
                Command_Setresp(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_setplasmas" then
                response = false
                Command_Setplasmas(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_setspeed" or t[1] == "sv_spd" then
                response = false
                Command_Setspeed(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_specs" then
                response = false
                Command_Specs(PlayerIndex, t[1], count)
            elseif t[1] == "sv_mc" then
                response = false
                Command_StartMapcycle(PlayerIndex, t[1], count)
            elseif t[1] == "sv_superban" then
                response = false
                Command_Superban(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_suspend" then
                response = false
                Command_Suspend(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_status" then
                response = false
                Command_Status(PlayerIndex, t[1], count)
            elseif t[1] == "sv_takeweapons" then
                response = false
                Command_Takeweapons(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_tbagdet" then
                response = false
                Command_TbagDetection(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_test" then
                response = false
                Command_Test(PlayerIndex, t[1], t[2], t[3], t[4], t[5], count)
            elseif t[1] == "sv_teleport_pl" or t[1] == "sv_tp" then
                response = false
                Command_Teletoplayer(PlayerIndex, t[1], t[2], t[3], count)
            elseif t[1] == "sv_textban" then
                response = false
                Command_Textban(PlayerIndex, t[1], t[2], t[3], t[4], count)
            elseif t[1] == "sv_textbanlist" then
                response = false
                Command_Textbanlist(PlayerIndex, t[1], count)
            elseif t[1] == "sv_textunban" then
                response = false
                Command_Textunban(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_time_cur" then
                response = false
                Command_Timelimit(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_unbos" then
                response = false
                Command_Unbos(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_cheat_unhax" or t[1] == "sv_unhax" then
                response = false
                Command_Unhax(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_unhide" then
                response = false
                Command_Unhide(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_ungod" then
                response = false
                Command_Ungod(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_uninvis" then
                response = false
                Command_Uninvis(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_unmute" then
                response = false
                Command_Unmute(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_unsuspend" then
                response = false
                Command_Unsuspend(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_viewadmins" or t[1] == "sv_cur_admins" then
                response = false
                Command_Viewadmins(PlayerIndex, t[1], count)
            elseif t[1] == "sv_votekick_enabled" then
                response = false
                Command_VotekickEnabled(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_votekick_needed" then
                response = false
                Command_VotekickRequired(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_votekick_action" then
                response = false
                Command_VotekickAction(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_version_check" then
                Command_Versioncheck(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_welcomeback_message" then
                response = false
                Command_WelcomeBackMessage(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_write" or t[1] == "sv_w" then
                response = false
                Command_Write(PlayerIndex, t[1], t[2], t[3], t[4], t[5], t[6], count)
            elseif t[1] == "sv_clean" then
                response = false
                Command_Clean(PlayerIndex, t[1], t[2], count)
            elseif t[1] == "sv_stickman" then
                response = false
                timer(200, "Stickman")
            end
            if PlayerIndex ~= nil and response == false then
                cmdlog(getname(PlayerIndex) .. " (Hash:" .. gethash(PlayerIndex) .. " IP: " .. getip(PlayerIndex) .. ") has executed: '" .. Command .. "'")
            end
        end
    elseif access and not permission then
        response = false
        cmdlog(getname(PlayerIndex) .. " (Hash:" .. gethash(PlayerIndex) .. " IP: " .. getip(PlayerIndex) .. ") tried to execute: '" .. Command .. "'")
        sendresponse("You do not have permission to execute that command.", t[1], PlayerIndex)
        return false
    else
        response = false
        if PlayerIndex then
            cmdlog("Security Alert: " .. getname(PlayerIndex) .. " (Hash:" .. gethash(PlayerIndex) .. " IP: " .. getip(PlayerIndex) .. ") tried to execute: '" .. Command .. "'")
        end
        sendresponse("You are not an admin. Access denied.", t[1], PlayerIndex)
    end
    if (Environment == 0) then
        response = true
    end
    return response
end

function WelcomeHandler(PlayerIndex)
    execute_command("msg_prefix \"\"")
    say(PlayerIndex, "Welcome to the TestBench")
    say(PlayerIndex, "Currently running: Classic CTF (no mods)")
    say(PlayerIndex, "https://github.com/Chalwk/HALO-SCRIPT-PROJECTS")
    execute_command("msg_prefix \"** SERVER ** \"")
end

function OnPlayerJoin(PlayerIndex)
    if compatible then
        write_byte(getplayer(PlayerIndex) + 0x20, 0)
    end
    local s_chat_name = get_var(PlayerIndex, "$name")
    local s_chat_id = get_var(PlayerIndex, "$n")
    local s_chat_ip = get_var(PlayerIndex, "$ip")
    local s_chat_hash = get_var(PlayerIndex, "$hash")
    local TimeStamp = os.date("[%d/%m/%Y - %H:%M:%S]")
    local file = io.open(s_chat_dir, "a+")
    if file ~= nil then
        file:write(TimeStamp .. "    [JOIN]    Name: " .. s_chat_name .. "    ID: [" .. s_chat_id .. "]    IP: [" .. s_chat_ip .. "]    CD-Key Hash: [" .. s_chat_hash .. "]\n")
        file:close()
    end
    cur_players = cur_players + 1
    local name = getname(PlayerIndex)
    local hash = gethash(PlayerIndex)
    local ip = getip(PlayerIndex)
    local player_id = get_var(PlayerIndex, "$n")
    players_alive[player_id] = { }
    players_alive[player_id].pl_afk = nil
    players_alive[player_id].pl_vehicle = nil
    players_alive[player_id].invis_time = 0
    players_alive[player_id].new_timer = 0
    players_alive[player_id].new_timer = 0
    welcome_timer[PlayerIndex] = true
    tbag[PlayerIndex] = { }
    players_list[PlayerIndex].name = name
    players_list[PlayerIndex].hash = hash
    players_list[PlayerIndex].ip = ip
    dmgmultiplier[ip] = 1.0

    bos_table[PlayerIndex] = name .. "," .. gethash(PlayerIndex) .. "," .. ip

    for k, v in pairs(banned_hashes) do
        if v == hash then
            table.remove(banned_hashes, k)
            execute_command("sv_ban " .. PlayerIndex + 1)
        end
    end
    if uniques_enabled then
        local bool
        for k, v in pairs(unique_table) do
            if hash == v[1] or ip == v[2] then
                bool = true
                if wb_message then
                    privatesay(PlayerIndex, "Welcome back " .. name .. "")
                end
                break
            end
        end
        if not bool then
            unique_table[name] = { hash, ip }
            uniques = uniques + 1
            if firstjoin_message then
                say("This is " .. name .. "'s first time in the server - unique player #: " .. tostring(uniques))
            end
        end
    end
    if sa_message then
        if ipadmins[ip] or admin_table[hash] then
            cprint("Server Admin: " .. name)
            Say("Server Admin - " .. name, 1)
        end
    end
    if multiteam_vehicles then
        write_byte(getplayer(PlayerIndex) + 0x20, 0)
    end
    local timestamp = os.date("%A %d %B %Y - %X")
    cprint("Join Time: " .. timestamp)
    cprint("Status: connected successfully.")
    cprint("---------------------------------------------------------------------------------------------------")
end

function OnPlayerLeave(PlayerIndex)
    welcome_timer[PlayerIndex] = false
    local s_chat_name = get_var(PlayerIndex, "$name")
    local s_chat_id = get_var(PlayerIndex, "$n")
    local s_chat_ip = get_var(PlayerIndex, "$ip")
    local s_chat_hash = get_var(PlayerIndex, "$hash")
    local file = io.open(s_chat_dir, "a+")
    if file ~= nil then
        file:write(TimeStamp .. "    [QUIT]    Name: " .. s_chat_name .. "    ID: [" .. s_chat_id .. "]    IP: [" .. s_chat_ip .. "]    CD-Key Hash: [" .. s_chat_hash .. "]\n")
        file:close()
    end
    timer(0, "cleanupdrones", PlayerIndex)
    cur_players = cur_players - 1
    local id = resolveplayer(PlayerIndex)
    local name = getname(PlayerIndex)
    local ip = getip(PlayerIndex)
    if temp_admins[ip] then
        temp_admins[ip] = nil
    end
    dmgmultiplier[ip] = 1.0
    bos_table[PlayerIndex] = name .. "," .. gethash(PlayerIndex) .. "," .. ip
    hidden[id] = nil
    gods[ip] = nil
    player_ping[id] = 0
    for k, v in pairs(boslog_table) do
        local words = tokenizestring(v, ",")
        if words[3] == ip then
        else
            local player_id = get_var(PlayerIndex, "$n")
            players_alive[player_id].pl_afk = nil
            players_alive[player_id].invis_time = 0
            players_alive[player_id].new_timer = 0
            last_damage[PlayerIndex] = nil
        end
    end
    local name = get_var(PlayerIndex, "$name")
    local hash = get_var(PlayerIndex, "$hash")
    local id = get_var(PlayerIndex, "$n")
    local ping = get_var(PlayerIndex, "$ping")
    local timestamp = os.date("%A %d %B %Y - %X")
    cprint("---------------------------------------------------------------------------------------------------")
    cprint(name .. " quit the game!", 12)
    cprint("CD Hash: " .. hash)
    cprint("IndexID: " .. id)
    cprint("Player Ping: " .. ping)
    cprint("Time: " .. timestamp)
    cprint("---------------------------------------------------------------------------------------------------")
    cprint("")
end

function OnPlayerDeath(PlayerIndex, KillerIndex)
    local victim = tonumber(PlayerIndex)
    local killer = tonumber(KillerIndex)

    -- Player Team --
    KillerTeam = get_var(KillerIndex, "$team")
    VictimTeam = get_var(PlayerIndex, "$team")

    hidden[resolveplayer(victim)] = nil
    gods[getip(victim)] = nil

    if respset then
        local player = getplayer(PlayerIndex)
        write_dword(player + 0x2C, resptime * 33)
    end

    -- KILLED BY SERVER --
    if (killer == -1) then
        kill_mode = 0
    end
    -- FALL / DISTANCE DAMAGE
    if last_damage[PlayerIndex] == global_distanceId or last_damage[PlayerIndex] == global_fallingId then
        kill_mode = 1
    end
    -- GUARDIANS / UNKNOWN --
    if (killer == nil) then
        kill_mode = 2
    end
    -- KILLED BY VEHICLE --
    if (killer == 0) then
        kill_mode = 3
    end
    -- KILLED BY KILLER --
    if (killer > 0) and (victim ~= killer) then
        kill_mode = 4
    end
    -- BETRAY / TEAM KILL --
    if (KillerTeam == VictimTeam) and (PlayerIndex ~= KillerIndex) then
        kill_mode = 5
    end
    -- SUICIDE --
    if tonumber(PlayerIndex) == tonumber(KillerIndex) then
        kill_mode = 6
    end
    if kill_mode == 4 then
        if tbag_detection then
            tbag[victim] = { }
            tbag[killer] = { }
            tbag[killer].count = 0
            tbag[killer].name = getname(victim)
            if victim_coords[victim] == nil then
                victim_coords[victim] = { }
            end
            if victim_coords[victim].x then
                tbag[killer].x = victim_coords[victim].x
                tbag[killer].y = victim_coords[victim].y
                tbag[killer].z = victim_coords[victim].z
            end
        end
        if killing_spree then
            local k_player = getplayer(killer)
            local k_name = getname(killer)
            local spree = readword(k_player + 0x96)
            local multikill = readword(k_player + 0x98)
            if multikill == 2 then
                privateSay(killer, "Double Kill")
            elseif multikill == 3 then
                privateSay(killer, "Triple Kill")
            elseif multikill == 4 then
                privateSay(killer, "OverKill")
            elseif multikill == 5 then
                privateSay(killer, "Killtacular")
            elseif multikill == 6 then
                privateSay(killer, "Killtrocity")
            elseif multikill == 7 then
                privateSay(killer, "Killimanjaro")
            elseif multikill == 8 then
                privateSay(killer, "Killtastrophe")
            elseif multikill == 9 then
                privateSay(killer, "Killpocalypse")
            elseif multikill >= 10 then
                privateSay(killer, "Killionaire")
            end
            if spree == 5 then
                Say(k_name .. " is on a Killing Spree", 1, killer)
                privateSay(killer, "Killing Spree")
            elseif spree == 10 then
                Say(k_name .. " is on a Killing Frenzy", 1, killer)
                privateSay(killer, "Killing Frenzy")
            elseif spree == 15 then
                Say(k_name .. " is on a Running Riot", 1, killer)
                privateSay(killer, "Running Riot")
            elseif spree == 20 then
                Say(k_name .. " is on a Rampage", 1, killer)
                privateSay(killer, "Rampage")
            elseif spree == 25 then
                Say(k_name .. " is Untouchable", 1, killer)
                privateSay(killer, "Untouchable")
            elseif spree == 30 then
                Say(k_name .. " is Invincible", 1, killer)
                privateSay(killer, "Invincible")
            elseif spree == 35 then
                Say(k_name .. " is Inconceivable", 1, killer)
                privateSay(killer, "Inconceivable")
            elseif spree >= 40 and spree % 5 == 0 then
                Say(k_name .. " is Unfrigginbelievable", killer)
                privateSay(killer, "Unfrigginbelievable")
            end
        end
    end
    timer(0, "cleanupdrones", PlayerIndex)
    last_damage[PlayerIndex] = 0
end

function OnPlayerCrouch(PlayerIndex)
    if tbag[PlayerIndex].count == nil then
        tbag[PlayerIndex].count = 0
    end
    tbag[PlayerIndex].count = tbag[PlayerIndex].count + 1
    if tbag[PlayerIndex].count == 4 then
        tbag[PlayerIndex].count = 0
        say_all(getname(PlayerIndex) .. " is t-bagging " .. tbag[PlayerIndex].name)
        tbag[PlayerIndex].name = nil
    end
    return true
end

function OnPlayerPrespawn(PlayerIndex)
    -- Not currently used
end

function OnPlayerSpawn(PlayerIndex)
    TIMER[PlayerIndex] = true
    local player_id = get_var(PlayerIndex, "$n")
    players_alive[player_id].invis_time = 0
    local ip = getip(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if player_object then
        if deathless then
            local m_object = get_object_memory(player_object)
            write_float(m_object + 0xE0, 9999999999)
            write_float(m_object + 0xE4, 9999999999)
        end
        if noweapons or Noweapons[ip] then
            local weaponId = read_dword(player_object + 0x118)
            if weaponId ~= 0 then
                for j = 0, 3 do
                    local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                    destroy_object(m_weapon)
                end
            end
        end
        if colorspawn == nil then
            colorspawn = { }
        end
        if colorspawn[PlayerIndex] == nil then
            colorspawn[PlayerIndex] = { }
        end
        if (player_object ~= 0) then
            if colorspawn[PlayerIndex][1] then
                write_vector3d(get_dynamic_player(PlayerIndex) + 0x5C, colorspawn[PlayerIndex][1], colorspawn[PlayerIndex][2], colorspawn[PlayerIndex][3])
                colorspawn[PlayerIndex] = { }
            end
        end
        if suspend_table[ip] then
            suspend_table[ip] = nil
        end
        if ghost_table[ip] then
            ghost_table[ip] = nil
        end
    end
end

function OnObjectInteraction(PlayerIndex, objId, mapId)
    local Pass = nil
    if noweapons or Noweapons[getip(PlayerIndex)] then
        local name, type = gettaginfo(mapId)
        if type == "weap" then
            Pass = false
        end
    end
    return Pass
end

function OnWeaponReload(PlayerIndex, weapon)
    local reload = nil
    if infammo then
        write_word(getobject(weapon) + 0x2B6, 9999)
        write_word(getobject(weapon) + 0x2B8, 9999)
        updateammo(weapon)
        reload = false
    end
    return reload
end

function OnVehicleEntry(PlayerIndex, Seat)

end

function OnVehicleEject(PlayerIndex, forceEject, relevant)
    local m_objectId = get_dynamic_player(PlayerIndex)
    if m_objectId then
        local m_object = getobject(m_objectId)
        local vehicleId = read_dword(m_object + 0x11C)
        if vehicleId then
            write_bit(getobject(vehicleId) + 0x10, 7, 0)
        end
    end
    return nil
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    last_damage[PlayerIndex] = MetaID
    if tbag_detection then
        local player_object = get_dynamic_player(PlayerIndex)
        if player_object then
            local x, y, z = read_vector3d(player_object + 0x5C)
            if victim_coords[PlayerIndex] == nil then
                victim_coords[PlayerIndex] = { }
            end
            if victim_coords[PlayerIndex] then
                victim_coords[PlayerIndex].x = x
                victim_coords[PlayerIndex].y = y
                victim_coords[PlayerIndex].z = z
            end
        end
    end
    if CauserIndex then
        if PlayerIndex then
            if mode[getip(CauserIndex)] == "destroy" then
                if MetaID ~= 0xE63504C1 then
                    destroy_object(MetaID)
                end
            elseif mode[getip(CauserIndex)] == "entergun" then
                enter_vehicle(MetaID, PlayerIndex, 0)
            end
        end
    end
end

function getobject(PlayerIndex)
    local m_player = get_player(PlayerIndex)
    if m_player ~= 0 then
        local ObjectId = read_dword(m_player + 0x24)
        return ObjectId
    end
    return nil
end

function OnPositionUpdate(PlayerIndex, m_objectId, x, y, z)
    local id = resolveplayer(PlayerIndex)
    if control_table ~= nil and control_table[id] and control_table[id][1] then
        for i = 1, #control_table[id] do
            local victim = control_table[id][i]
            local m_playerObjId = get_dynamic_player(victim)
            if m_playerObjId then
                local m_object = getobject(m_playerObjId)
                if m_object then
                    local m_vehicle = getobject(read_dword(m_object + 0x11C))
                    if m_vehicle == nil then
                        local m_controlObject = getobject(m_objectId)
                        local x_vel = read_float(m_controlObject + 0x68)
                        local y_vel = read_float(m_controlObject + 0x6C)
                        write_float(m_object + 0x68, x_vel)
                        write_float(m_object + 0x6C, y_vel)
                    end
                end
            end
        end
    end
    return 1
end

function Command_AddRconPassword(executor, command, password, level, count)
    if count == 2 or count == 3 then
        local bool = true
        for k, v in pairs(rcon_passwords) do
            if rcon_passwords[k] ~= { } and rcon_passwords[k] ~= nil then
                for key, value in ipairs(rcon_passwords[k]) do
                    if rcon_passwords[k][key].password == password then
                        bool = false
                    end
                end
            end
        end
        if bool then
            if string.len(password) > 3 then
                if level then
                    if access_table[tonumber(level)] then
                        rcon_passwords[rcon_passwords_id] = { }
                        table.insert(rcon_passwords[rcon_passwords_id], { ["password"] = password, ["level"] = level })
                        rcon_passwords_id = rcon_passwords_id + 1
                        sendresponse(password .. " has been added as an rcon password", command, executor)
                    else
                        sendresponse("That is not a level", command, executor)
                    end
                else
                    rcon_passwords[rcon_passwords_id] = { }
                    table.insert(rcon_passwords[rcon_passwords_id], { ["password"] = password, ["level"] = -1 })
                    rcon_passwords_id = rcon_passwords_id + 1
                    sendresponse(password .. " has been added as an rcon password", command, executor)
                end
            else
                sendresponse(password .. " is too short to be an rcon password", command, executor)
            end
        else
            sendresponse(password .. " is already an rcon password", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [password] {level}", command, executor)
    end
end

function Command_Adminadd(executor, command, PlayerIndex, nickname, level, count)
    if count == 4 and tonumber(level) then
        if string.len(PlayerIndex) < 32 then
            local PlayerIndex = tonumber(PlayerIndex) - 1
            if getplayer(PlayerIndex) then
                local hash = gethash(PlayerIndex)
                if not admin_table[hash] then
                    if tonumber(level) <= #access_table then
                        admin_table[hash] = { }
                        admin_table[hash].level = level
                        admin_table[hash].name = nickname
                        sendresponse(getname(PlayerIndex) .. " is now a hash admin", command, executor)
                        local file = io.open(profilepath .. "commands_admins.txt", "a")
                        for k, v in pairs(admin_table) do
                            file:write(tostring(admin_table[k].name .. "," .. k .. "," .. admin_table[k].level) .. "\n")
                        end
                        file:close()
                    else
                        sendresponse("Invalid Level", command, executor)
                    end
                else
                    sendresponse(getname(PlayerIndex) .. " is already a hash admin", command, executor)
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        elseif string.len(PlayerIndex) == 32 then
            if nickname then
                if not admin_table[PlayerIndex] then
                    if tonumber(level) <= #access_table then
                        admin_table[PlayerIndex] = { }
                        admin_table[PlayerIndex].level = level
                        admin_table[PlayerIndex].name = nickname
                        sendresponse(nickname .. " is now a hash admin", command, executor)
                        local file = io.open(profilepath .. "commands_admins.txt", "a")
                        for k, v in pairs(admin_table) do
                            file:write(tostring(admin_table[k].name .. "," .. k .. "," .. admin_table[k].level) .. "\n")
                        end
                        file:close()
                    else
                        sendresponse("Invalid Level", command, executor)
                    end
                else
                    sendresponse(nickname .. " is already an admin", command, executor)
                end
            end
        else
            sendresponse("Invalid Hash", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player or hash] [nickname] [level]", command, executor)
    end
end

function Command_Admindel(executor, command, nickname, count)
    if count == 2 and tonumber(ID) or count == 3 and (t[2] == "del") then
        if type(admin_table) ~= nil then
            local bool = true
            for k, v in pairs(admin_table) do
                if admin_table[k] then
                    if admin_table[k].name == nickname then
                        admin_table[k] = nil
                        bool = false
                    end
                end
            end
            if bool then
                sendresponse("There are no hash admins with a nickname of '" .. nickname .. "'", command, executor)
            else
                sendresponse(nickname .. " is no longer a hash admin", command, executor)
            end
        else
            sendresponse("There are no hash admins on this server.", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [nickname]", command, executor)
    end
end

function Command_Adminrevoke(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for j = 1, #players do
                local hash = gethash(players[j])
                local ip = getip(players[j])
                if ipadmins[ip] or admin_table[hash] then
                    admin_table[hash] = nil
                    ipadmins[ip] = nil
                    sendresponse(getname(players[j]) .. " is no longer an admin", command, executor)
                else
                    sendresponse(getname(players[j]) .. " is not an admin", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_AFK(executor, command, Expression, count)
    if count == 1 then
        if executor ~= nil then
            local player = tonumber(executor)
            if player ~= -1 and player >= 1 and player < 16 then
                local id = resolveplayer(executor)
                local player_id = get_var(executor, "$n")
                players_alive[player_id].pl_afk = executor
                sendresponse("You are now afk", command, executor)
            else
                sendresponse("The server cannot be afk", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 2 then
        local players = getvalidplayers(Expression, executor)
        if players then
            for i = 1, #players do
                if player_present(players[i]) then
                    local id = get_var(players[i], "$n")
                    local player_id = get_var(id, "$n")
                    players_alive[player_id].pl_afk = id
                    sendresponse(getname(players[i]) .. " is now afk", command, executor)
                else
                    sendresponse("Invalid Player", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_AdminList(executor, command, count)
    if count == 1 or t[2] == "list" then
        sendresponse("Showing both IP Admins and Hash Admins.", command, executor)
        sendresponse("[Name] - [Level] - [Admin Type]", command, executor)
        local admins = { }
        for k, v in pairs(admin_table) do
            local name = admin_table[k].name
            local level = admin_table[k].level
            admins[name] = { "hash", "notip", level }
        end
        for k, v in pairs(ipadmins) do
            local name = ipadmins[k].name
            local level = ipadmins[k].level
            if admins[name] and admins[name] ~= { } then
                admins[name][2] = "ip"
            else
                admins[name] = { "nothash", "ip", level }
            end
        end
        for k, v in pairs(admins) do
            local message = ""
            if admins[k][1] == "hash" and admins[k][2] == "ip" then
                message = k .. " - " .. admins[k][3] .. " - Hash admin  IP Admin"
            elseif admins[k][1] == "hash" then
                message = k .. " - " .. admins[k][3] .. " - Hash admin"
            elseif admins[k][2] == "ip" then
                message = k .. " - " .. admins[k][3] .. " - IP Admin"
            end
            sendresponse(message, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Alias(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            if executor ~= nil then
                for i = 1, #players do
                    execute_command("alias " .. resolveplayer(players[i]), executor)
                end
            else
                for i = 1, #players do
                    execute_command("alias " .. resolveplayer(players[i]), false)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_AdminBlocker(executor, command, type, count)
    if count == 1 then
        if admin_blocker == 0 then
            sendresponse("Admins can kick/ban another admin", command, executor)
        elseif admin_blocker == 1 then
            sendresponse("Admins can't kick/ban another admin with higher level.", command, executor)
        elseif admin_blocker == 2 then
            sendresponse("Admins can't kick/ban another admin with higher or equal level.", command, executor)
        elseif admin_blocker == 3 then
            sendresponse("Admins can't kick/ban another admins unless they can do all commands.", command, executor)
        end
    elseif count == 2 then
        if tonumber(type) then
            type = tonumber(type)
            if type == 0 then
                admin_blocker = 0
                sendresponse("Admins can kick/ban another admin", command, executor)
            elseif type == 1 then
                admin_blocker = 1
                sendresponse("Admins can't kick/ban another admin with higher level.", command, executor)
            elseif type == 2 then
                admin_blocker = 2
                sendresponse("Admins can't kick/ban another admin with higher or equal level.", command, executor)
            elseif type == 3 then
                admin_blocker = 3
                sendresponse("Admins can't kick/ban another admins unless they can do all commands..", command, executor)
            else
                sendresponse("Type: 0 Admin can kick/ban another admin.\nType: 1 Admin can't kick/ban another admin with higher level.\nType: 2 Admin can't kick/ban another admin with higher or equal level.\nType: 3 Admins can't kick/ban another admins unless they can do all commands.", command, executor)
            end
        else
            sendresponse("Type: 0 Admin can kick/ban another admin.\nType: 1 Admin can't kick/ban another admin with higher level.\nType: 2 Admin can't kick/ban another admin with higher or equal level.\nAdmins can't kick/ban another admins unless they can do all commands.", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. commannd .. " {type}", command, executor)
    end
end

function Command_AntiCaps(executor, command, boolean, count)
    if count == 1 then
        if anticaps then
            sendresponse("AntiCaps is currently on", command, executor)
        else
            sendresponse("AntiCaps is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and anticaps ~= true then
            anticaps = true
            sendresponse("AntiCaps is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and anticaps == true then
            sendresponse("AntiCaps is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and anticaps ~= false then
            anticaps = false
            sendresponse("AntiCaps is now disabled", command, executor)
        elseif anticaps == nil then
            anticaps = false
            sendresponse("AntiCaps is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and anticaps == false then
            sendresponse("AntiCaps is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_AntiSpam(executor, command, type, count)
    if count == 1 then
        if antispam == nil then
            antispam = "all"
        end
        sendresponse("AntiSpam is set to " .. antispam, command, executor)
    elseif count == 2 then
        type = string.lower(type)
        if type == "all" or type == "players" or type == "off" then
            antispam = type
            sendresponse("AntiSpam now set to " .. antispam, command, executor)
        else
            type = "off"
            sendresponse("Invalid Type", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {all | players | off}", command, executor)
    end
end

function Command_BalanceTeams(executor, command, count)
    if team_play then
        if count == 1 then
            local msg = ""
            if getteamsize(1) == getteamsize(0) then
                msg = "Teams are balanced"
            elseif getteamsize(1) + 1 == getteamsize(0) then
                msg = "Teams are balanced"
            elseif getteamsize(1) == getteamsize(0) + 1 then
                msg = "Teams are balanced"
            elseif getteamsize(1) > getteamsize(0) then
                changeteam(SelectPlayer(1), true)
                execute_command_sequence("wait 0;st " .. SelectPlayer(1))
                msg = "Balancing Teams"
                say(msg)
            elseif getteamsize(1) < getteamsize(0) then
                execute_command_sequence("wait 0;st " .. SelectPlayer(1))
                msg = "Balancing Teams"
                say(msg)
            end
            sendresponse(msg, command, executor)
        else
            sendresponse("Invalid Syntax: " .. command, command, executor)
        end
    else
        sendresponse("This command is disabled since it is not a team based game.", command, executor)
    end
end

function Command_Ban(executor, command, PlayerIndex, time, count)
    local bool = false
    if count == 2 or count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                if CheckAccess(executor, command, players[i], getaccess(executor)) then
                    local msg = getname(players[i]) .. " has been banned from the server"
                    cprint(msg)
                    bool = true
                else
                    local Command = getvalidformat(command)
                    sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                    sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. ' [PlayerIndex] {time}.', command, executor)
    end
    return bool
end

function Command_Ban2(executor, command, PlayerIndex, message, time, count)
    if count >= 2 and count <= 4 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            local name = "the Server"
            if executor ~= nil then
                name = getname(executor)
            end
            for i = 1, #players do
                if CheckAccess(executor, command, players[i], getaccess(executor)) then
                    local playername = getname(players[i])
                    message = tostring(message) or "None Given"
                    BanReason(playername .. " was banned by " .. name .. " Reason: " .. message .. " Type: Hash Ban")
                    say(playername .. " was banned by " .. name .. " Reason: " .. message)
                    sendresponse(getname(players[i]) .. " has been banned from the server", command, executor)
                    if time then
                        execute_command("sv_ban " .. resolveplayer(players[i]) .. " " .. time)
                    else
                        execute_command("sv_ban " .. resolveplayer(players[i]))
                    end
                else
                    local Command = getvalidformat(command)
                    sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                    sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {reason} {time}", command, executor)
    end
end

function Command_Bos(executor, command, PlayerIndex, count)
    if count == 2 then
        local player_number = tonumber(PlayerIndex)
        local bos_entry = bos_table[player_number]
        if bos_entry == nil then
            sendresponse("Invalid Player", command, executor)
        else
            local words = tokenizestring(bos_entry, ",")
            local bool = true
            for k, v in pairs(boslog_table) do
                if bos_entry == v then
                    bool = false
                end
            end
            if bool then
                sendresponse("Adding " .. words[1] .. " to BoS.", command, executor)
                sendresponse("Entry: " .. words[1] .. " - " .. words[2] .. " - " .. words[3], command, executor)
                table.insert(boslog_table, bos_entry)
                local file = io.open(profilepath .. "commands_bos.data", "w")
                if file then
                    for k, v in pairs(boslog_table) do
                        if v then
                            cprint("Adding " .. words[1] .. " to BoS.", 2 + 8)
                            cprint("Entry: " .. words[1] .. " - " .. words[2] .. " - " .. words[3], 2 + 8)
                            file:write(v .. "\n")
                        end
                    end
                    file:close()
                end
            else
                sendresponse(words[1] .. " is already on the BoS", command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Banlist(executor, command, count)
    if count == 1 then
        local response = execute_command("sv_banlist", true)
        sendresponse(response[1], command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Boslist(executor, command, count)
    if count == 1 then
        local response = "[ID - Name - Hash - IP]\n"
        for k, v in pairs(boslog_table) do
            if v then
                local words = tokenizestring(v, ",")
                response = response .. "\n[" .. k .. " " .. words[1] .. " - " .. words[2] .. " - " .. words[3] .. "]"
            end
        end
        sendresponse(response, command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Bosplayers(executor, command, count)
    if count == 1 then
        local response = "ID  |  Name\n"
        for i = 1, 16 do
            if bos_table[i] then
                local words = tokenizestring(bos_table[i], ",")
                response = response .. "\n" .. i .. "  |  " .. words[1]
            end
        end
        sendresponse(response, command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_ChatCommands(executor, command, boolean, count)
    if count == 1 then
        if chatcommands then
            sendresponse("Chat Commands are currently on", command, executor)
        else
            sendresponse("Chat Commands are currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and chatcommands ~= true then
            chatcommands = true
            sendresponse("Chat Commands are now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and chatcommands == true then
            sendresponse("Chat Commands are already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and chatcommands ~= false then
            chatcommands = false
            sendresponse("Chat Commands are now disabled", command, executor)
        elseif chatcommands == nil then
            chatcommands = true
            sendresponse("Chat Commands are now enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and chatcommands == false then
            sendresponse("Chat Commands are already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_ChangeLevel(executor, command, nickname, level, count)
    local bool_hash = false
    local bool_ip = false
    if count == 2 then
        if admin_table or ipadmins then
            local level_hash
            local level_ip
            if admin_table then
                for k, v in pairs(admin_table) do
                    if admin_table[k].name == nickname then
                        level_hash = admin_table[k].level
                        bool_hash = true
                        break
                    end
                end
            end
            if ipadmins then
                for k, v in pairs(ipadmins) do
                    if ipadmins[k].name == nickname then
                        level_ip = ipadmins[k].level
                        bool_ip = true
                        break
                    end
                end
            end
            if bool_hash and bool_ip then
                sendresponse(nickname .. " is a level: " .. level_hash .. " Hash and a level: " .. level_ip .. " IP Admin", command, executor)
            elseif bool_hash and not bool_ip then
                sendresponse(nickname .. " is a level: " .. level_hash .. " Hash admin", command, executor)
            elseif bool_ip and not bool_hash then
                sendresponse(nickname .. " is a level: " .. level_ip .. " IP admin", command, executor)
            elseif not bool_hash and not bool_ip then
                sendresponse("Invalid nickname", command, executor)
            end
        else
            sendresponse("No admins in the server", command, executor)
        end
    elseif count == 3 and tonumber(level) then
        if admin_table or ipadmins then
            if access_table[tonumber(level)] then
                if admin_table then
                    for k, v in pairs(admin_table) do
                        if admin_table[k].name == nickname then
                            admin_table[k].level = level
                            bool_hash = true
                            break
                        end
                    end
                end
                if ipadmins then
                    for k, v in pairs(ipadmins) do
                        if ipadmins[k].name == nickname then
                            ipadmins[k].level = level
                            bool_ip = true
                            break
                        end
                    end
                end
                if bool_hash and bool_ip then
                    sendresponse(nickname .. " is now a level: " .. level .. " Hash and now a level: " .. level .. " IP Admin", command, executor)
                elseif bool_hash and not bool_ip then
                    sendresponse(nickname .. " is now a level: " .. level .. " Hash admin", command, executor)
                elseif bool_ip and not bool_hash then
                    sendresponse(nickname .. " is now a level: " .. level .. " IP admin", command, executor)
                elseif not bool_hash and not bool_ip then
                    sendresponse("Invalid nickname", command, executor)
                end
            else
                sendresponse("Invalid level", command, executor)
            end
        else
            sendresponse("No admins in the server", command, executor)
        end
    elseif count == 3 and not tonumber(level) then
        sendresponse("The level needs to be a number", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command .. " [nickname] {level}", command, executor)
    end
end

function Command_Changeteam(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                changeteam(players[i], false)
                kill(players[i])
                sendresponse(getname(players[i]) .. " has been forced to change teams", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Control(executor, command, victim, Controller, count)
    if count == 3 then
        local victims = getvalidplayers(victim)
        local controller = getvalidplayers(Controller)
        if victims and controller then
            if controller[2] == nil then
                for i = 1, #victims do
                    local id = resolveplayer(controller[1])
                    local m_playerObjId = get_dynamic_player(controller[1])
                    if m_playerObjId then
                        if victims[i] ~= controller[1] then
                            table.insert(control_table[id], victims[i])
                            sendresponse(getname(victims[i]) .. " is now being controlled by " .. getname(controller[1]), command, executor)
                            local m_objectId = get_dynamic_player(victims[i])
                            if m_objectId then
                                local m_object = getobject(m_objectId)
                                if m_object then
                                    local m_vehicleId = read_dword(m_object + 0x11C)
                                    local m_vehicle = getobject(m_vehicleId)
                                    if m_vehicle then
                                        local seat = readword(m_vehicle + 0x120)
                                        exitvehicle(victims[i])
                                        entervehicle(controller[i], m_vehicleId, seat)
                                        local x, y, z = getobjectcoords(m_playerObjId)
                                        local vehid = createobject(ghost_tag_id, 0, 30, false, x, y, z + 5)
                                        entervehicle(controller[i], vehid, 0)
                                        timer(200, "DelayEject", controller[1])
                                        movobjectcoords(m_playerObjId, x, y, z + 0.5)
                                        entervehicle(victims[i], m_vehicleId, seat)
                                    end
                                end
                            end
                        elseif victims[i] == controller[1] then
                            local bool = false
                            for j = 1, 16 do
                                for k = 1, 16 do
                                    if control_table[j][k] == victims[i] then
                                        control_table[j][k] = nil
                                        bool = true
                                        break
                                    end
                                end
                                if bool then
                                    break
                                end
                            end
                            local m_objectId = get_dynamic_player(controller[1])
                            if m_objectId then
                                local m_object = getobject(m_objectId)
                                local m_vehicleId = read_dword(m_object + 0x11C)
                                local m_vehicle = getobject(m_vehicleId)
                                if m_vehicle then
                                    local seat = readword(m_object + 0x120)
                                    entervehicle(controller[1], m_vehicleId, 0)
                                    entervehicle(controller[1], m_vehicleId, seat)
                                    sendresponse(getname(controller[1]) .. " is now being controlled by " .. getname(controller[1]), command, executor)
                                else
                                    sendresponse(getname(controller[1]) .. " is no longer being controlled", command, executor)
                                end
                            end
                        end
                    end
                end
            else
                sendresponse("Victims can only be controlled by one person.", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [victims] [controller]", command, executor)
    end
end

function Command_Count(executor, command, count)
    if count == 1 and uniques_enabled then
        sendresponse("There are " .. tostring(uniques) .. " unique users that have been to this server", command, executor)
    elseif not uniques_enabled then
        sendresponse("'sv_uniques_enabled' is currently disabled.", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_CountUniques(executor, command, boolean, count)
    if count == 1 then
        if uniques_enabled then
            sendresponse("Unique Player Counting is currently on", command, executor)
        else
            sendresponse("Unique Player Counting is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and uniques_enabled ~= true then
            uniques_enabled = true
            sendresponse("Unique Player Counting is now enabled", command, executor)
            local file = io.open(profilepath .. "uniques.txt", "r")
            if file then
                for line in file:lines() do
                    local words = tokenizestring(line, ",")
                    local count = #words
                    if count == 3 then
                        unique_table[words[1]] = { words[2], words[3] }
                        uniques = uniques + 1
                    end
                end
                file:close()
            end
        elseif (boolean == "1" or boolean == "true") and uniques_enabled == true then
            sendresponse("Unique Player Counting is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and uniques_enabled ~= false then
            uniques_enabled = false
            sendresponse("Unique Player Counting is now disabled", command, executor)
        elseif uniques_enabled == nil then
            uniques_enabled = false
            sendresponse("Unique Player Counting is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and uniques_enabled == false then
            sendresponse("Unique Player Counting is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Commands(executor, command, count)
    if count == 1 and executor ~= nil then
        local access
        local level
        if admin_table[gethash(executor)] then
            access = tonumber(admin_table[gethash(executor)].level)
        elseif ipadmins[getip(executor)] then
            access = tonumber(ipadmins[getip(executor)].level)
        end
        sendresponse("Commands: ", command, executor)
        if access == 0 then
            sendresponse("All Commands", command, executor)
        else
            local words = tokenizestring(access_table[access], ",")
            local count = #words
            local response = ""
            for i = 1, count do
                response = response .. " - " .. words[i]
                if i % 3 == 0 then
                    response = response .. "\n"
                end
            end
            sendresponse(response, command, executor)
        end
    elseif executor == nil then
        sendresponse("All Commands", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Crash(executor, command, PlayerIndex, count)
    if count == 2 and not gameend then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_object = get_dynamic_player(players[i])
                if (player_object ~= 0) then
                    local x, y, z = read_vector3d(player_object + 0x5C)
                    local vehicleId = spawn_object("vehi", "vehicles\\rwarthog\\rwarthog", x, y, z)
                    local veh_obj = get_object_memory(vehicleId)
                    if (veh_obj ~= 0) then
                        for j = 0, 20 do
                            enter_vehicle(vehicleId, players[i], j)
                            exit_vehicle(players[i])
                        end
                        destroy_object(vehicleId)
                        sendresponse(getname(players[i]) .. " had their game crashed by an admin", command, executor)
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif gameend then
        sendresposne("You cannot crash a player while the game is ending. Wait until next game.", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_DamageMultiplier(executor, command, PlayerIndex, value, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                sendresponse(getname(players[i]) .. " has a damage multiplier of " .. dmgmultiplier[getip(players[i])], command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 3 then
        value = tonumber(value)
        if value then
            local players = getvalidplayers(PlayerIndex, executor)
            if players then
                for i = 1, #players do
                    dmgmultiplier[getip(players[i])] = value
                    sendresponse(getname(players[i]) .. " has had his damage multiplier changed to " .. value, command, executor)
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        else
            sendresponse("Invalid Damage Multiplier", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [damage multiplier]", command, executor)
    end
end

function Command_Deathless(executor, command, boolean, count)
    if count == 1 then
        if deathless then
            sendresponse("Deathless is currently enabled.", command, executor)
        else
            sendresponse("Deathless is currently disabled", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and not deathless then
            sendresponse("Deathless player is now on. You cannot die.", command, executor)
            deathless = true
        elseif boolean == "1" or boolean == "true" then
            sendresponse("Deathless is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and deathless then
            sendresponse("Deathless player is now off.", command, executor)
            deathless = false
        elseif deathless == nil then
            sendresponse("Deathless player is now off.", command, executor)
            deathless = false
        elseif boolean == "0" or boolean == "false" then
            sendresponse("Deathless is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_DelRconPassword(executor, command, password, count)
    if count == 2 then
        local bool = false
        for k, v in pairs(rcon_passwords) do
            if rcon_passwords[k] ~= nil and rcon_passwords[k] ~= { } then
                for key, value in ipairs(rcon_passwords[k]) do
                    if rcon_passwords[k][key].password == password then
                        table.remove(rcon_passwords, k)
                        bool = true
                    end
                end
            end
        end
        if bool then
            sendresponse(password .. " is no longer an rcon password", command, executor)
        else
            sendresponse(password .. " is not an rcon password", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [password]", command, executor)
    end
end

function Command_Execute(executor, command, access)
    local t = tokenizestring(command)
    if t[2] == nil or t[2] == "sv_script_reload" then
        return
    end
    if CheckAccess(executor, t[2], t[3], access) then
        sendresponse("Executed " .. string.sub(command, 4), command, executor)
        local response = execute_command(string.sub(command, 4), true)
        if response then
            if type(response) == "table" then
                local Response = response[1]
                local count = #response
                while (count > 1) do
                    Response = Response .. " " .. response[count]
                    count = count - 1
                end
                sendresponse(Response, command, executor)
            else
                sendresponse(response[1], command, executor)
            end
        end
    else
        local Command = getvalidformat(t[2])
        sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
        sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
    end
end

function Command_Eject(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local m_objectId = get_dynamic_player(executor)
        if m_objectId then
            local m_object = getobject(m_objectId)
            if m_object then
                if isinvehicle(executor) then
                    exitvehicle(executor)
                    sendresponse("Ejecting you from your vehicle", command, executor)
                else
                    sendresponse("You are not in a vehicle", command, executor)
                end
            else
                sendresponse("You are dead", command, executor)
            end
        end
    elseif count == 1 and executor == nil then
        sendresponse("The Server cannot be ejected froma vehicle", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    local m_object = getobject(m_objectId)
                    if m_object then
                        if isinvehicle(players[i]) then
                            exitvehicle(players[i])
                            sendresponse("Ejecting " .. getname(players[i]) .. " from his/her vehicle", command, executor)
                        else
                            sendresponse(getname(players[i]) .. " is not in a vehicle", command, executor)
                        end
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Falldamage(executor, command, boolean, count)
    if count == 1 then
        if falldamage then
            sendresponse("Fall damage is currently on", command, executor)
        else
            sendresponse("Fall damage is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and not falldamage then
            falldamage = true
            sendresponse("Fall damage is now on", command, executor)
        elseif (boolean == "1" or boolean == "true") then
            sendresponse("Fall damage is already on", command, executor)
        elseif boolean ~= "0" and boolean ~= "false" then
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        elseif (boolean == "0" or boolean == "false") and (falldamage or falldamage == nil) then
            falldamage = false
            sendresponse("Fall damage is now off", command, executor)
        elseif boolean == "0" or boolean == "false" then
            sendresponse("Fall damage is already off", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [boolean]", command, executor)
    end
end

function Command_FirstJoinMessage(executor, command, boolean, count)
    if count == 1 then
        if firstjoin_message then
            sendresponse("First Join Message is currently on", command, executor)
        else
            sendresponse("First Join Message is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and firstjoin_message ~= true then
            firstjoin_message = true
            sendresponse("First Join Message is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and firstjoin_message == true then
            sendresponse("First Join Message is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and firstjoin_message ~= false then
            firstjoin_message = false
            sendresponse("First Join Message is now disabled", command, executor)
        elseif firstjoin_message == nil then
            firstjoin_message = false
            sendresponse("First Join Message is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and firstjoin_message == false then
            sendresponse("First Join Message is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Follow(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                if executor ~= players[i] then
                    sendresponse(getname(executor) .. " is now following " .. getname(players[i]), command, executor)
                    local id = resolveplayer(executor)
                    local arguments = { executor, players[i] }
                    follow[id] = timer(20, "FollowTimer", arguments)
                else
                    sendresponse("You cannot follow yourself", command, executor)
                end
            end
        elseif PlayerIndex == "stop" or PlayerIndex == "none" then
            local id = resolveplayer(executor)
            if follow[id] then
                sendresponse(getname(executor) .. " is no longer following", command, executor)
                if follow[id] then
                    removetimer(follow[id])
                    follow[id] = nil
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Gethash(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                sendresponse(getname(players[i]) .. ": " .. gethash(players[i]), command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Getip(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local id = resolveplayer(players[i])
                local ip = getip(players[i])
                sendresponse(getname(players[i]) .. ": " .. tostring(ip), command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Getloc(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local player_object = get_dynamic_player(executor)
        if player_object then
            local x, y, z = getobjectcoords(player_object)
            x = round(x, 2)
            y = round(y, 2)
            z = round(z, 2)
            sendresponse("Your coords are: X: " .. x .. "  Y: " .. y .. "  Z: " .. z, command, executor)
        else
            sendresponse("You are dead", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server does not have a location.", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                if player_present(players[i]) then
                    local player_object = get_dynamic_player(players[i])
                    if player_object then
                        local x, y, z = getobjectcoords(player_object)
                        x = round(x, 2)
                        y = round(y, 2)
                        z = round(z, 2)
                        sendresponse(getname(players[i]) .. "'s coords are: X: " .. x .. "  Y: " .. y .. "  Z: " .. z, command, executor)
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                else
                    sendresponse("Invalid Player", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function getobjectcoords(player_object)
    local x, y, z = read_vector3d(player_object + 0x5C)
    if player_object then
        return x, y, z
    end
end

function Command_Godmode(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        if deathless ~= 1 then
            local pl = getvalidplayers(PlayerIndex, executor)
            if executor ~= pl then
                cprint("Server cannot be on god mode!", 2 + 8)
            else
                local m_object = get_dynamic_player(executor)
                if m_object then
                    local ip = getip(executor)
                    if not gods[ip] then
                        write_float(m_object + 0xE0, 99999999)
                        write_float(m_object + 0xE4, 99999999)
                        sendresponse("You have been given godmode.", command, executor)
                        gods[ip] = 0
                    else
                        sendresponse("You are already in godmode", command, executor)
                    end
                else
                    sendresponse("You are dead", command, executor)
                end
            end
        else
            sendresponse("Deathless is now enabled You cannot give out godmode", command, executor)
        end
    elseif count == 2 then
        if deathless ~= 1 then
            local players = getvalidplayers(PlayerIndex, executor)
            if players then
                for i = 1, #players do
                    local m_object = get_dynamic_player(players[i])
                    if m_object then
                        local ip = getip(players[i])
                        if not gods[ip] then
                            write_float(m_object + 0xE0, 99999999)
                            write_float(m_object + 0xE4, 99999999)
                            sendresponse(getname(players[i]) .. " has been given godmode", command, executor)
                            gods[ip] = 0
                        else
                            sendresponse(getname(players[i]) .. " is already in godmode", command, executor)
                        end
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        else
            sendresponse("Deathless is now enabled You cannot give out godmode", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_Hashcheck(boolean)
    if (boolean == "1" or boolean == "true") and not hash_check then
        hash_check = true
        write_byte(hashcheck_addr, 0x74)
    elseif (boolean == "0" or boolean == "false") and hash_check then
        hash_check = false
        write_byte(hashcheck_addr, 0xEB)
    elseif hash_check == nil then
        hash_check = false
        write_byte(hashcheck_addr, 0xEB)
    end
end

function Command_HashDuplicates(executor, command, boolean, count)
    if count == 1 then
        if hash_duplicates then
            sendresponse("Hash Duplicate Checking is currently enabled", command, executor)
        else
            sendresponse("Hash Duplicate Checking is currently disabled", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and not hash_duplicates then
            hash_duplicates = true
            write_bit(hash_duplicate_patch, 0, 1)
            sendresponse("Hash Duplicate Checking is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") then
            sendresponse("Hash Duplicate Checking is already enabled", command, executor)
        elseif boolean ~= "0" and boolean ~= "false" then
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        elseif (boolean == "0" or boolean == "false") and hash_duplicates or (hash_duplicates == nil) then
            hash_duplicates = false
            write_bit(hash_duplicate_patch, 0, 0)
            sendresponse("Hash Duplicate Checking is now disabled", command, executor)
        elseif boolean == "0" or boolean == "false" then
            sendresponse("Hash Duplicate Checking is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [boolean]", command, executor)
    end
end

function Command_Hax(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                setscore(players[i], 9999)
                write_word(m_player + 0x9C, 9999)
                write_word(m_player + 0xA4, 9999)
                write_word(m_player + 0xAC, 9999)
                write_word(m_player + 0xAE, 9999)
                write_word(m_player + 0xB0, 9999)
                sendresponse(getname(players[i]) .. " has been haxed", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Heal(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local m_playerObjId = get_dynamic_player(executor)
        if m_playerObjId then
            local m_object = getobject(m_playerObjId)
            if m_object then
                local obj_health = read_float(m_object + 0xE0)
                if obj_health < 1 then
                    local m_vehicleId = read_dword(m_object + 0x11C)
                    if m_vehicleId == nil then
                        local x, y, z = getobjectcoords(m_playerObjId)
                        local healthpack = createobject(healthpack_tag_id, 0, 0, false, x, y, z + 0.5)
                        if healthpack ~= nil then
                            write_float(getobject(healthpack) + 0x70, -2)
                        end
                    else
                        write_float(m_object + 0xE0, 1)
                    end
                    sendresponse("You have been healed", command, executor)
                else
                    sendresponse("You are already at full health", command, executor)
                end
            else
                sendresponse("You are dead", command, executor)
            end
        else
            sendresponse("You are dead", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The Server cannot be healed", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_playerObjId = get_dynamic_player(players[i])
                if m_playerObjId then
                    local m_object = getobject(m_playerObjId)
                    if m_object then
                        local obj_health = read_float(m_object + 0xE0)
                        if obj_health < 1 then
                            local m_vehicleId = read_dword(m_object + 0x11C)
                            if m_vehicleId == nil then
                                local x, y, z = getobjectcoords(m_playerObjId)
                                local healthpack = createobject(healthpack_tag_id, 0, 0, false, x, y, z + 0.5)
                                if healthpack ~= nil then
                                    write_float(getobject(healthpack) + 0x70, -2)
                                end
                            else
                                write_float(m_object + 0xE0, 1)
                            end
                            sendresponse(getname(players[i]) .. " has been healed", command, executor)
                        else
                            sendresponse(getname(players[i]) .. " is already at full health", command, executor)
                        end
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_Hide(executor, command, Expression, count)
    if count == 1 and executor ~= nil then
        local player = tonumber(executor)
        if player ~= -1 and player >= 1 and player < 16 then
            local id = resolveplayer(executor)
            if id ~= nil then
                if hidden[id] == nil then
                    sendresponse("You are now hidden", command, executor)
                    hidden[id] = true
                else
                    sendresponse("You are already hidden", command, executor)
                end
            end
        else
            sendresponse("The server cannot hide itself", command, executor)
        end
    elseif count == 2 then
        local players = getvalidplayers(Expression, executor)
        if players then
            for i = 1, #players do
                if player_present(players[i]) then
                    local id = resolveplayer(players[i])
                    if hidden[id] == nil then
                        sendresponse(getname(players[i]) .. " is now hidden", command, executor)
                        hidden[id] = true
                    else
                        sendresponse(getname(players[i]) .. " is already hidden", command, executor)
                    end
                else
                    sendresponse("Invalid Player", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_Infammo(executor, command, boolean, count)
    if count == 1 then
        if infammo then
            sendresponse("Infinite ammo is currently enabled", command, executor)
        else
            sendresponse("Infinite ammo is currently disabled", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and not infammo then
            nadetimer = timer(300, "nadeTimer")
            for c = 1, 16 do
                if getplayer(c) then
                    local m_ObjId = get_dynamic_player(c)
                    if m_ObjId then
                        local m_Object = getobject(m_ObjId)
                        for i = 0, 3 do
                            local m_weaponId = read_dword(m_Object + 0x2F8 + (i * 4))
                            if m_weaponId then
                                write_word(getobject(m_weaponId) + 0x2B6, 9999)
                            end
                        end
                    end
                end
            end
            infammo = true
            sendresponse("Infinite Ammo is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") then
            sendresponse("Infammo is already enabled", command, executor)
        elseif boolean ~= "0" and boolean ~= "false" then
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        elseif (boolean == "0" or boolean == "false") and infammo then
            for c = 1, 16 do
                if getplayer(c) then
                    local m_ObjId = get_dynamic_player(c)
                    if m_ObjId then
                        local m_Object = getobject(m_ObjId)
                        write_byte(m_Object + 0x31E, 0)
                        write_byte(m_Object + 0x31F, 0)
                    end
                end
            end
            infammo = false
            sendresponse("Infinite Ammo is now disabled", command, executor)
        elseif infammo == nil then
            sendresponse("Infinite Ammo is now disabled", command, executor)
            infammo = false
        elseif boolean == "0" or boolean == "false" then
            sendresponse("Infammo is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [boolean]", command, executor)
    end
end

function resolveplayer(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local p_id = get_var(PlayerIndex, "$n")
        return p_id
    else
        -- nil
    end
    return nil
end

function Command_Info(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_number = resolveplayer(players[i])
                local m_player = getplayer(players[i])
                local hash = gethash(players[i])
                local ip = getip(players[i])
                local m_playerObjId = get_dynamic_player(players[i])
                if m_playerObjId then
                    local m_object = getobject(m_playerObjId)
                    if m_object then
                        local gametype_maximum_health = read_float(0x671340 + 0x54)
                        local player_name = getname(players[i])
                        local player_team = getteam(players[i])
                        local player_respawn_time = read_dword(m_player + 0x2C)
                        local player_invis_time = readword(m_player + 0x68)
                        local player_speed = read_float(m_player + 0x6C)
                        local player_objective_mode = read_byte(m_player + 0x74)
                        local player_objective_mode2 = read_byte(m_player + 0x7A)
                        local player_killstreak = readword(m_player + 0x96)
                        local player_kills = readword(m_player + 0x9C)
                        local player_assists = readword(m_player + 0xA4)
                        local player_betrays = readword(m_player + 0xAC)
                        local player_deaths = readword(m_player + 0xAE)
                        local player_suicides = readword(m_player + 0xB0)
                        local player_ping = readword(m_player + 0xDC)
                        local player_x_coord, player_y_coord, player_z_coord = getobjectcoords(m_playerObjId)

                        local obj_max_health = read_float(m_object + 0xD8)
                        local obj_max_shields = read_float(m_object + 0xDC)
                        local obj_health = read_float(m_object + 0xE0)
                        local obj_shields = read_float(m_object + 0xE4)
                        local obj_flashlight_mode = read_byte(m_object + 0x206)
                        local obj_crouch = read_byte(m_object + 0x2A0)
                        local obj_weap_type = read_byte(m_object + 0x2F2)
                        local obj_nade_type = read_byte(m_object + 0x31C)
                        local obj_primary_nades = read_byte(m_object + 0x31E)
                        local obj_secondary_nades = read_byte(m_object + 0x31F)
                        local obj_flashlight_level = read_float(m_object + 0x344)
                        local obj_invis_scale = read_float(m_object + 0x37C)
                        local obj_airborne = read_byte(m_object + 0x4CC)

                        local obj_primary_weap_id = read_dword(m_object + 0x2F8)
                        local obj_secondary_weap_id = read_dword(m_object + 0x2FC)
                        if obj_primary_weap_id then
                            primary_weap = getobject(obj_primary_weap_id)
                        end
                        if obj_secondary_weap_id then
                            secondary_weap = getobject(obj_secondary_weap_id)
                        end

                        local m_vehicle = getobject(m_playerObjId)
                        if obj_crouch == 1 or obj_crouch == 5 or obj_crouch == 6 or obj_crouch == 13 or obj_crouch == 17 then
                            primary_weap = getobject(read_dword(m_vehicle + 0x2F8))
                        end
                        if primary_weap then
                            primary_weap_heat = read_float(primary_weap + 0x23C)
                            primary_weap_age = read_float(primary_weap + 0x240)
                            primary_weap_ammo = readword(primary_weap + 0x2B6)
                            primary_weap_clip = readword(primary_weap + 0x2B8)
                        end
                        if secondary_weap then
                            secondary_weap_heat = read_float(secondary_weap + 0x23C)
                            secondary_weap_age = read_float(secondary_weap + 0x240)
                            secondary_weap_ammo = readword(secondary_weap + 0x2B6)
                            secondary_weap_clip = readword(secondary_weap + 0x2B8)
                        end

                        local teamsize = getteamsize(player_team)
                        if team_play then
                            if player_team == 0 then
                                player_team = "Red"
                            elseif player_team == 1 then
                                player_team = "Blue"
                            else
                                player_team = "Hidden"
                            end
                        else
                            player_team = "FFA"
                        end

                        if player_objective_mode == 0x22 and player_objective_mode2 == 0x71 then
                            player_objective_mode = "Hill"
                        elseif player_objective_mode == 0x23 and player_objective_mode2 == 0x71 then
                            player_objective_mode = "Juggernaut"
                        elseif player_objective_mode == 0x23 and player_objective_mode2 == 0x72 then
                            player_objective_mode = "It"
                        elseif player_objectivemode == 0x29 and player_objective_mode2 == 0x70 then
                            player_objective_mode = "Ball"
                        else
                            player_objective_mode = "None"
                        end

                        if obj_weap_type == 2 and player_objective_mode == "None" then
                            player_objective_mode = "Flag"
                        end

                        player_respawn_time = round(player_respawn_time / 30, 2)
                        player_invis_time = round(player_invis_time / 30, 2)

                        player_betrays = player_betrays - player_suicides

                        player_x_coord = round(player_x_coord)
                        player_y_coord = round(player_y_coord)
                        player_z_coord = round(player_z_coord)

                        obj_invis_scale = round(obj_invis_scale * 100, 2)

                        if obj_invis_scale == 0 then
                            obj_invis_scale = "No"
                        else
                            obj_invis_scale = obj_invis_scale .. "%"
                        end

                        local invis_info = "Invis: " .. obj_invis_scale

                        if obj_invis_scale ~= "No" then
                            invis_info = "Invis: " .. obj_invis_scale .. " (" .. player_invis_time .. " secs)"
                        end

                        if obj_flashlight_mode == 8 then
                            obj_flashlight_mode = "On"
                        else
                            obj_flashlight_mode = "Off"
                        end

                        obj_flashlight_level = round(obj_flashlight_level * 100)

                        if primary_weap_age == 0 then
                            if primary_weap_ammo ~= 0 or primary_weap_clip ~= 0 then
                                if primary_weap then
                                    write_float(primary_weap + 0x240, 1)
                                    primary_weap_age = 1
                                end
                            end
                        end

                        if secondary_weap_age == 0 then
                            if secondary_weap_ammo ~= 0 or secondary_weap_clip ~= 0 then
                                if secondary_weap then
                                    write_float(secondary_weap + 0x240, 1)
                                    secondary_weap_age = 1
                                end
                            end
                        end

                        if obj_weap_type == 1 then
                            primary_weap_heat = read_float(secondary_weap + 0x23C)
                            primary_weap_age = read_float(secondary_weap + 0x240)
                            primary_weap_ammo = readword(secondary_weap + 0x2B6)
                            primary_weap_clip = readword(secondary_weap + 0x2B8)
                            secondary_weap_heat = read_float(primary_weap + 0x23C)
                            secondary_weap_age = read_float(primary_weap + 0x240)
                            secondary_weap_ammo = readword(primary_weap + 0x2B6)
                            secondary_weap_clip = readword(primary_weap + 0x2B8)
                        end

                        if primary_weap_heat ~= nil then
                            primary_weap_heat = round(primary_weap_heat * 100)
                        end
                        if primary_weap_age ~= nil then
                            primary_weap_age = round((1 - primary_weap_age) * 100)
                        end
                        if secondary_weap_heat ~= nil then
                            secondary_weap_heat = round(secondary_weap_heat * 100)
                        end
                        if secondary_weap_age ~= nil then
                            secondary_weap_age = round((1 - secondary_weap_age) * 100)
                        end

                        local primary_weap_info = "Primary: Empty"
                        local secondary_weap_info = "Secondary: Empty"

                        if obj_health ~= 0 then
                            if obj_crouch == 1 or obj_crouch == 5 or obj_crouch == 6 or obj_crouch == 13 or obj_crouch == 17 then
                                if primary_weap_age == 100 and primary_weap_ammo == 0 and primary_weap_clip == 0 then
                                    primary_weap_info = "Primary: Infinite"
                                else
                                    primary_weap_info = "Primary Ammo: " .. primary_weap_clip .. " / " .. primary_weap_ammo
                                end
                            else

                                if primary_weap then
                                    if primary_weap_age == 0 then
                                        if primary_weap_ammo ~= 0 or primary_weap_clip ~= 0 then
                                            primary_weap_info = "Primary Ammo: " .. primary_weap_clip .. " / " .. primary_weap_ammo
                                        end
                                    else
                                        primary_weap_info = "Primary Battery: " .. primary_weap_heat .. "% / " .. primary_weap_age .. "%"
                                    end
                                end

                                if secondary_weap then
                                    if secondary_weap_age == 0 then
                                        if secondary_weap_ammo ~= 0 or secondary_weap_clip ~= 0 then
                                            secondary_weap_info = "Secondary Ammo: " .. secondary_weap_clip .. " / " .. secondary_weap_ammo
                                        end
                                    else
                                        secondary_weap_info = "Secondary Battery: " .. secondary_weap_heat .. "% / " .. secondary_weap_age .. "%"
                                    end
                                end

                            end
                        end

                        local nade_info = "Frag Grenades: " .. obj_primary_nades .. " | " .. "Plasma Grenades: " .. obj_secondary_nades
                        if obj_nade_type == 1 then
                            nade_info = "Plasma Grenades: " .. obj_secondary_nades .. " | " .. "Frag Grenades: " .. obj_primary_nades
                        end

                        if obj_crouch == 0 then
                            obj_crouch = "Warthog: Driver"
                        elseif obj_crouch == 1 then
                            obj_crouch = "Warthog: Gunner"
                        elseif obj_crouch == 2 then
                            obj_crouch = "Warthog: Passenger"
                        elseif obj_crouch == 3 then
                            obj_crouch = "Stance: Crouching"
                        elseif obj_crouch == 4 then
                            obj_crouch = "Stance: Standing"
                        elseif obj_crouch == 5 then
                            obj_crouch = "Ghost: Driver"
                        elseif obj_crouch == 6 then
                            obj_crouch = "Banshee: Pilot"
                        elseif obj_crouch == 13 then
                            obj_crouch = "Scorpion: Driver"
                        elseif obj_crouch == 17 then
                            obj_crouch = "Shade: Gunner"
                        elseif obj_crouch == 20 or obj_crouch == 21 or obj_crouch == 22 or obj_crouch == 23 then
                            obj_crouch = "Scorpion: Passenger"
                        end

                        if obj_crouch == "Stance: Crouching" or obj_crouch == "Stance: Standing" then
                            if obj_airborne == 1 then
                                obj_crouch = "Stance: Airborne"
                            end
                        end

                        if obj_health == 0 and obj_shields == 0 then
                            obj_crouch = "Stance: Dead"
                        end

                        obj_max_health = round(obj_health * obj_max_health)
                        obj_max_shields = round(obj_shields * obj_max_shields)
                        obj_health = round(obj_health * 100)
                        obj_shields = round(obj_shields * 100)

                        local health_info = "Health: " .. obj_health .. "% (" .. obj_max_health .. ") | " .. "Shields: " .. obj_shields .. "% (" .. obj_max_shields .. ")"

                        if obj_health == 0 and obj_shields == 0 and player_respawn_time ~= 0 then
                            if player_respawn_time == 1 then
                                health_info = "Respawn: " .. player_respawn_time .. " sec"
                            else
                                health_info = "Respawn: " .. player_respawn_time .. " secs"
                            end
                        end

                        if suspend_table[ip] == 2 then
                            health_info = "Respawn: Never"
                        end
                        if hidden[player_number] then
                            hidden_boolean = "True"
                        else
                            hidden_boolean = "False"
                        end
                        if gods[ip] then
                            god_boolean = "True"
                        else
                            god_boolean = "False"
                        end
                        if players_alive[player_number].pl_afk == true then
                            afk_boolean = "True"
                        else
                            afk_boolean = "False"
                        end
                        if admin_table[hash] or ipadmins[ip] then
                            admin_status = "True"
                        else
                            admin_status = "False"
                        end
                        sendresponse("----------", command, executor)
                        sendresponse("Name: " .. player_name .. " (" .. player_number .. ") | " .. "Team: " .. player_team .. " (" .. teamsize .. ")  |  Speed: " .. round(player_speed, 2) .. " | " .. "Location: " .. player_x_coord .. ", " .. player_y_coord .. ", " .. player_z_coord, command, executor)
                        sendresponse("Hash: " .. hash .. " | " .. " IP: " .. ip, command, executor)
                        sendresponse("Admin: " .. admin_status .. " | " .. "Ping: " .. player_ping .. " | " .. obj_crouch, command, executor)
                        sendresponse("Kills: " .. player_kills .. " (" .. player_killstreak .. ") | " .. "Assists: " .. player_assists .. " | " .. "Betrays: " .. player_betrays .. " | " .. "Suicides: " .. player_suicides .. " | " .. "Deaths: " .. player_deaths, command, executor)
                        sendresponse(health_info .. " | " .. invis_info .. "\n" .. "Light: " .. obj_flashlight_mode .. " (" .. obj_flashlight_level .. "%)", command, executor)
                        sendresponse(primary_weap_info .. " | " .. secondary_weap_info .. " | " .. "Objective: " .. player_objective_mode, command, executor)
                        sendresponse(nade_info, command, executor)
                        sendresponse("Hidden: " .. hidden_boolean .. " | God: " .. god_boolean .. " | AFK: " .. afk_boolean, command, executor)
                        sendresponse("----------", command, executor)
                    else
                        sendresponse("The selected player is dead", command, executor)
                    end
                else
                    sendresponse("The selected player is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Ipadminadd(executor, command, PlayerIndex, nickname, level, count)
    if count == 4 and tonumber(level) then
        local words = tokenizestring(PlayerIndex, ".")
        local count = #words
        if count == 4 then
            if ipadmins[PlayerIndex] then
                sendresponse(nickname .. " is already an IP admin", command, executor)
            elseif not nickname:find(",") then
                if tonumber(level) <= #access_table then
                    ipadmins[PlayerIndex] = ipadmins[PlayerIndex] or { }
                    ipadmins[PlayerIndex].name = nickname
                    ipadmins[PlayerIndex].level = level
                    sendresponse(nickname .. " is now an IP admin", tostring(command), tostring(executor))
                    reloadadmins()
                else
                    sendresponse("That level does not exist.", command, executor)
                end
            else
                sendresponse("Nicknames must contain no commas.", command, executor)
            end
        elseif count > 1 then
            sendresponse("Invalid IP Address Format (xxx.xxx.xxx.xxx)", command, executor)
        else
            local players = getvalidplayers(PlayerIndex, executor)
            if players then
                if not players[2] then
                    local ip = getip(players[1])
                    if ipadmins[ip] then
                        sendresponse(getname(tostring(players[1])) .. " is already an IP admin", command, executor)
                    elseif not nickname:find(",") then
                        if tonumber(level) <= #access_table then
                            ipadmins[ip] = ipadmins[ip] or { }
                            ipadmins[ip].name = nickname
                            ipadmins[ip].level = level
                            sendresponse(getname(tostring(players[1])) .. " is now an IP admin", tostring(command), tostring(executor))
                            local file = io.open(profilepath .. "commands_ipadmins.txt", "w")
                            for k, v in pairs(ipadmins) do
                                file:write(tostring(ipadmins[k].name .. "," .. k .. "," .. ipadmins[k].level) .. "\n")
                            end
                            reloadadmins()
                        else
                            sendresponse("That level does not exist.", command, executor)
                        end
                    else
                        sendresponse("Nicknames must contain no commas.", command, executor)
                    end
                else
                    sendresponse("You cannot add more than one admin with the same nickname", command, executor)
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player or IP] [nickname] [level]", command, executor)
    end
end

function Command_Ipadmindel(executor, command, nickname, count)
    if count == 2 then
        if type(ipadmins) ~= nil then
            local bool = true
            for k, v in pairs(ipadmins) do
                if ipadmins[k] then
                    if ipadmins[k].name == nickname then
                        ipadmins[k] = nil
                        bool = false
                    end
                end
            end
            if bool then
                sendresponse("There are no IP admins with a nickname of '" .. nickname .. "'", command, executor)
            else
                sendresponse(nickname .. " is no longer an IP admin", command, executor)
            end
        else
            sendresponse("There are no IP admins on this server.", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [nickname]", command, executor)
    end
end
-- Changed sdfgsdfg
function Command_Ipban(executor, command, PlayerIndex, time, message, count)
    ipcount = 0
    if PlayerIndex then
        local words = tokenizestring(PlayerIndex, ".")
        ipcount = #words
    end
    if ipcount == 4 then
        local ipbantime = wordtotime(time) or -1
        local name = "the Server"
        if executor ~= nil then
            name = getname(executor)
        end
        message = tostring(message) or "None Given"
        BanReason("The IP: " .. PlayerIndex .. " was banned by " .. name .. " Reason: " .. message .. " Type: IP Ban")
        ip_banlist[PlayerIndex] = { }
        table.insert(ip_banlist[PlayerIndex], { ["name"] = "Player", ["ip"] = PlayerIndex, ["time"] = ipbantime, ["id"] = ip_banid })
        ip_banid = ip_banid + 1
        sendresponse(PlayerIndex .. " has been banned from the server", command, executor)
    elseif ipcount > 1 then
        sendresponse("Invalid IP Address Format (xxx.xxx.xxx.xxx)", command, executor)
    else
        if count >= 2 and count <= 4 then
            local players = getvalidplayers(PlayerIndex, executor)
            if players then
                local name = "the Server"
                if executor ~= nil then
                    name = getname(executor)
                end
                for i = 1, #players do
                    if CheckAccess(executor, command, players[i], getaccess(executor)) then
                        local ipbantime = wordtotime(time) or -1
                        message = tostring(message) or "None Given"
                        BanReason(getname(players[i]) .. " was banned by " .. name .. " Reason: " .. message .. " Type: IP Ban")
                        say(getname(players[i]) .. " was IP banned by " .. name .. " Reason: " .. message)
                        local ip = getip(players[i])
                        ip_banlist[ip] = { }
                        table.insert(ip_banlist[ip], { ["name"] = getname(players[i]), ["ip"] = getip(players[i]), ["time"] = ipbantime, ["id"] = ip_banid })
                        ip_banid = ip_banid + 1
                        Ipban(players[i])
                        msg = getname(players[i]) .. " has been IP banned from the server"
                        cprint(msg)
                        sendresponse(msg, command, executor)
                    else
                        local Command = getvalidformat(command)
                        sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                        sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                    end
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " [player or ip] {time} {message} ", command, executor)
        end
    end
end

function Command_Ipbanlist(executor, command, count)
    if count == 1 then
        if ip_banlist ~= { } then
            local response = "ID - Name - IP - Time"
            local response_table = { }
            local bool = true
            for k, v in pairs(ip_banlist) do
                if ip_banlist[k] ~= { } then
                    for key, value in pairs(ip_banlist[k]) do
                        local id = ip_banlist[k][key].id
                        response_table[id] = id .. "  |  " .. ip_banlist[k][key].name .. "  |  " .. ip_banlist[k][key].ip .. "  |  " .. timetoword(ip_banlist[k][key].time)
                    end
                end
            end
            for i = 0, ip_banid do
                if response_table[i] then
                    bool = false
                    response = response .. "\n" .. response_table[i]
                end
            end
            if bool then
                response = "IP Banlist is empty"
            end
            sendresponse(response, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Ipunban(executor, command, ID, count)
    if count == 2 and tonumber(ID) then
        ID = tonumber(ID)
        local response = "Invalid ID"
        if ID <= ip_banid then
            local bool = false
            for k, v in pairs(ip_banlist) do
                if ip_banlist[k] ~= { } then
                    for key, value in pairs(ip_banlist[k]) do
                        if ip_banlist[k][key].id == ID then
                            bool = true
                            response = k .. " has been unipbanned"
                            table.remove(ip_banlist[k])
                            break
                        end
                    end
                end
                if bool then
                    break
                end
            end
            sendresponse(response, command, executor)
        else
            sendresponse(response, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [ID]", command, executor)
    end
end

function Command_Iprangeban(executor, command, PlayerIndex, time, message, count)
    local ipcount = 0
    if PlayerIndex then
        local words = tokenizestring(PlayerIndex, ".")
        ipcount = #words
    end
    if ipcount == 2 then
        local ipbantime = wordtotime(time) or -1
        local name = "the Server"
        if executor ~= nil then
            name = getname(executor)
        end
        message = tostring(message) or "None Given"
        BanReason("The IP: " .. PlayerIndex .. " was banned by " .. name .. " Reason: " .. message .. " Type: IP Range Ban")
        iprange_banlist[PlayerIndex] = { }
        table.insert(iprange_banlist[PlayerIndex], { ["name"] = "Player", ["ip"] = PlayerIndex, ["time"] = ipbantime, ["id"] = ip_banid })
        iprange_banid = iprange_banid + 1
        sendresponse(PlayerIndex .. " has been banned from the server", command, executor)
    elseif ipcount > 1 then
        sendresponse("Invalid IP Address Format (xxx.xxx)", command, executor)
    else
        if count >= 2 and count <= 4 then
            local players = getvalidplayers(PlayerIndex, executor, command)
            if players then
                local name = "the Server"
                if executor ~= nil then
                    name = getname(executor)
                end
                for i = 1, #players do
                    if CheckAccess(executor, command, players[i], getaccess(executor)) then
                        local ipbantime = wordtotime(time) or -1
                        message = tostring(message) or "None Given"
                        BanReason(getname(players[i]) .. " was banned by " .. name .. " Reason: " .. message .. " Type: IP Range Ban")
                        say(getname(players[i]) .. " was IP banned by " .. name .. " Reason: " .. message)
                        local ip = getip(players[i])
                        local words = tokenizestring(ip, ".")
                        local ip2 = words[1] .. "." .. words[2]
                        iprange_banlist[ip2] = { }
                        table.insert(iprange_banlist[ip2], { ["name"] = getname(players[i]), ["ip"] = ip2, ["time"] = ipbantime, ["id"] = iprange_banid })
                        iprange_banid = iprange_banid + 1
                        Ipban(players[i])
                        msg = getname(players[i]) .. " has been IP banned from the server"
                        cprint(msg)
                        sendresponse(msg, command, executor)
                    else
                        local Command = getvalidformat(command)
                        sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                        sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                    end
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " [player or ip] {time} {message} ", command, executor)
        end
    end
end

function Command_Iprangebanlist(executor, command, count)
    if count == 1 then
        if iprange_banlist ~= { } then
            local response = "ID - Name - IP - Time"
            local response_table = { }
            local bool = true
            for k, v in pairs(iprange_banlist) do
                if iprange_banlist[k] ~= { } then
                    for key, value in pairs(iprange_banlist[k]) do
                        local id = iprange_banlist[k][key].id
                        response_table[id] = id .. "  |  " .. iprange_banlist[k][key].name .. "  |  " .. iprange_banlist[k][key].ip .. "  |  " .. timetoword(iprange_banlist[k][key].time)
                    end
                end
            end
            for i = 0, iprange_banid do
                if response_table[i] then
                    bool = false
                    response = response .. "\n" .. response_table[i]
                end
            end
            if bool then
                response = "IP Range Banlist is empty"
            end
            sendresponse(response, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Iprangeunban(executor, command, ID, count)
    if count == 2 and tonumber(ID) then
        ID = tonumber(ID)
        local response = "Invalid ID"
        if ID <= iprange_banid then
            local bool = false
            for k, v in pairs(iprange_banlist) do
                if iprange_banlist[k] ~= { } then
                    for key, value in pairs(iprange_banlist[k]) do
                        if iprange_banlist[k][key].id == ID then
                            bool = true
                            response = k .. " has been uniprangebanned"
                            table.remove(iprange_banlist[k])
                            break
                        end
                    end
                end
                if bool then
                    break
                end
            end
            sendresponse(response, command, executor)
        else
            sendresponse(response, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [ID]", command, executor)
    end
end

function Command_Invis(executor, command, PlayerIndex, time, count)
    if count == 1 and executor ~= nil then
        local m_objectId = get_dynamic_player(executor)
        if m_objectId then
            if ghost_table[getip(executor)] == nil then
                ghost_table[getip(executor)] = true
                sendresponse("You are now invisible", command, executor)
            elseif ghost_table[getip(executor)] then
                sendresponse("You are already invisible", command, executor)
            else
                sendresponse("You are dead dead", command, executor)
            end
        else
            sendresponse("You are dead dead", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server cannot be invisible", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if ghost_table[getip(players[i])] == nil then
                        ghost_table[getip(players[i])] = true
                        sendresponse(getname(players[i]) .. " is now invisible", command, executor)
                    elseif ghost_table[getip(players[i])] then
                        sendresponse(getname(players[i]) .. " is already invisible", command, executor)
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if ghost_table[getip(players[i])] == nil then
                        ghost_table[getip(players[i])] = invisibility_time
                        sendresponse(getname(players[i]) .. " is now invisible for " .. invisibility_time .. " seconds", command, executor)
                        privatesay(players[i], "You are now invisible for " .. invisibility_time .. " seconds.")
                    elseif ghost_table[getip(players[i])] then
                        sendresponse(getname(players[i]) .. " is already invisible", command, executor)
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {time}", command, executor)
    end
end

function Command_Kick(executor, command, PlayerIndex, message, count)
    if count == 2 or count == 3 then
        local players = getvalidplayers(PlayerIndex, executor, command)
        if players then
            local name = "the Server"
            if executor ~= nil then
                name = getname(executor)
            end
            for i = 1, #players do
                if CheckAccess(executor, command, players[i], getaccess(executor)) then
                    if executor ~= players[i] then
                        message = message or "None Given"
                        WriteLog(profilepath .. "commands_KickReasons.log", getname(players[i]) .. " was kicked by " .. name .. " Reason: " .. message)
                        say(getname(players[i]) .. " was kicked by " .. name .. " Reason: " .. message)
                        msg = getname(players[i]) .. " has been kicked from the server"
                        cprint(msg)
                        sendresponse(msg, command, executor)
                        execute_command("sv_kick " .. resolveplayer(players[i]))
                    else
                        sendresponse("You cannot kick yourself", command, executor)
                    end
                else
                    local Command = getvalidformat(command)
                    sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                    sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. ' [player] {reason}', command, executor)
    end
end

function Command_Kill(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                kill(players[i])
                sendresponse(getname(players[i]) .. " has been killed", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_KillingSpree(executor, command, boolean, count)
    if count == 1 then
        if killing_spree then
            sendresponse("Killing Spree Notifications is currently on", command, executor)
        else
            sendresponse("Killing Spree Notifications is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and killing_spree ~= true then
            killing_spree = true
            sendresponse("Killing Spree Notifications is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and killing_spree == true then
            sendresponse("Killing Spree Notifications is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and killing_spree ~= false then
            killing_spree = false
            sendresponse("Killing Spree Notifications is now disabled", command, executor)
        elseif killing_spree == nil then
            killing_spree = false
            sendresponse("Killing Spree Notifications is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and killing_spree == false then
            sendresponse("Killing Spree Notifications is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Launch(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_object = get_dynamic_player(players[i])
                if player_object then
                    local VehicleID = read_dword(player_object + 0x11C)
                    local m_vehicle = get_object_memory(VehicleID)
                    if m_vehicle ~= 0 then
                        sendresponse(getname(players[i]) .. " has been launched", command, executor)
                        write_bit(m_vehicle + 0x10, 2, 0)
                        if GetTagName(m_vehicle) == "vehicles\\scorpion\\scorpion_mp" then
                            write_float(m_vehicle + 0x94, 15)
                            write_float(m_vehicle + 0x70, 0.35)
                            write_float(m_vehicle + 0x6C, 0.35)
                        elseif GetTagName(m_vehicle) == "vehicles\\banshee\\banshee_mp" then
                            write_float(m_vehicle + 0x90, 30)
                            write_float(m_vehicle + 0x70, 0.35)
                            write_float(m_vehicle + 0x6C, -0.4)
                        elseif GetTagName(m_vehicle) == "vehicles\\ghost\\ghost_mp" then
                            write_float(m_vehicle + 0x8C, 7)
                            write_float(m_vehicle + 0x70, 0.35)
                        elseif GetTagName(m_vehicle) == "vehicles\\warthog\\mp_warthog" then
                            write_float(m_vehicle + 0x94, 10)
                            write_float(m_vehicle + 0x70, 0.35)
                        elseif GetTagName(m_vehicle) == "vehicles\\rwarthog\\rwarthog" then
                            write_float(m_vehicle + 0x94, 15)
                            write_float(m_vehicle + 0x70, 0.35)
                        else
                            write_float(m_vehicle + 0x94, 10)
                            write_float(m_vehicle + 0x70, 0.35)
                        end
                    else
                        sendresponse(getname(players[i]) .. " is not in a vehicle", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_List(executor, command, word, count)
    local word = tonumber(word)
    if count == 2 then
        if word == 1 then
            sendresponse("sv_setafk, sv_admin_list, sv_admin_add, sv_admin_del, sv_revoke, sv_alias", command, executor)
            sendresponse("sv_adminblocker, sv_anticaps, sv_antispam, sv_ban", command, executor)
        elseif word == 2 then
            sendresponse("sv_bos, sv_boslist, sv_bosplayers, sv_chatcommands, sv_change_level", command, executor)
            sendresponse("sv_changeteam, sv_crash, sv_commands, sv_control, sv_count", command, executor)
        elseif word == 3 then
            sendresponse("sv_uniques_enabled, sv_deathless, sv_eject, sv_falldamage, sv_firstjoin_message", command, executor)
            sendresponse("sv_follow, sv_gethash, sv_getip, sv_getloc, sv_setgod", command, executor)
        elseif word == 4 then
            sendresponse("sv_cheat_hax, sv_heal, sv_help, sv_hide, sv_hitler, sv_ipadminadd, sv_ipadmindel", command, executor)
            sendresponse("sv_ipban, sv_ipbanlist, sv_info", command, executor)
        elseif word == 5 then
            sendresponse("sv_infinite_ammo, sv_ipunban, sv_invis, sv_kick, sv_kill, sv_killspree, sv_launch", command, executor)
            sendresponse("sv_list, sv_scrim, sv_login", command, executor)
        elseif word == 6 then
            sendresponse("sv_map, sv_mnext, sv_reset, sv_move, sv_mute, sv_nameban, sv_namebanlist", command, executor)
            sendresponse("sv_nameunban, sv_noweapons, sv_os, ", command, executor)
        elseif word == 7 then
            sendresponse("sv_pvtmessage, sv_pvtsay, sv_players_more, sv_players, sv_resetweapons, sv_resp", command, executor)
            sendresponse("sv_rtv_enabled, sv_rtv_needed, sv_serveradmin_message, sv_scrimmode, ", command, executor)
        elseif word == 8 then
            sendresponse("sv_spawn, sv_give, sv_spammax, sv_spamtimeout, sv_setammo, sv_setassists", command, executor)
            sendresponse("sv_setcolor, sv_setdeaths, sv_setfrags, sv_setkills, ", command, executor)
        elseif word == 9 then
            sendresponse("sv_setmode, sv_pass, sv_setscore, sv_respawn_time, sv_setplasmas, sv_setspeed", command, executor)
            sendresponse("sv_specs, sv_mc, sv_superban, sv_suspend, ", command, executor)
        elseif word == 10 then
            sendresponse("sv_status, sv_takeweapons, sv_tbagdet, sv_test, sv_textban, sv_textbanlist", command, executor)
            sendresponse("sv_textunban, sv_time_cur, sv_unbos, sv_cheat_unhax, ", command, executor)
        elseif word == 11 then
            sendresponse("sv_unhide, sv_ungod, sv_uninvis, sv_unmute, sv_unsuspend, sv_viewadmins", command, executor)
            sendresponse("sv_votekick_enabled, sv_votekick_needed, sv_votekick_action, sv_welcomeback_message, ", command, executor)
        elseif word == 12 then
            sendresponse("sv_write, sv_balance, sv_stickman, sv_addrcon, sv_delrcon, sv_rconlist", command, executor)
            sendresponse("sv_iprangeban, sv_iprangeunban, sv_iprangebanlist, sv_read", command, executor)
        elseif word == 13 then
            sendresponse("sv_load, sv_unload, sv_resetplayer, sv_damage, sv_hash_duplicates", command, executor)
            sendresponse("sv_multiteam_vehicles", command, executor)
        else
            sendresponse("The commands list is only 13 pages", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {page} - Valid Pages are: 1-13", command, executor)
    end
end

function Command_Lo3(executor, command, count)
    if count == 1 then
        if lo3_timer == nil then
            lo3_timer = timer(2000, "lo3Timer")
        end
        sendresponse("Live on three.", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Login(executor, command, username, password, count)
    if count == 1 and executor ~= nil and next(admin_table) == nil and next(admin_table) == nil then
        temp_admins[getip(executor)] = true
        sendresponse("You have successfully logged in, you are now able to use chat commands.", command, executor)
    elseif executor == nil then
        sendresponse("The server cannot use this command.", command, executor)
    elseif next(admin_table) ~= nil and next(admin_table) ~= nil then
        sendresponse("This command is currently unavailable", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Map(executor, command)
    local args = tokenizestring(command)
    local count = #args
    if count > 2 and tonumber(args) == nil then
        local found = false
        local arguments = ""
        for i = 4, #args do
            if arguments == nil then
                arguments = args[i]
            else
                arguments = arguments .. " " .. args[i]
            end
            if args[i] == "commands" and args[i] ~= args[1] and args[i] ~= args[2] and args[i] ~= args[3] and not Persistent then
                found = true
            end
        end
        if not found then
            arguments = arguments .. " commands"
        end
        arguments = string.gsub(arguments, "  ", " ")
        if tonumber(arguments) == nil then
            local response = ""
            if string.sub(args[1], 1, 2) ~= "sv" then
                response = execute_command("sv_map " .. args[2] .. " \"" .. args[3] .. "\" " .. tostring(arguments), true)
            else
                response = execute_command("sv_map " .. args[2] .. " \"" .. args[3] .. "\" " .. tostring(arguments), true)
            end
            if response == "" or response == nil then
                return
            end
            sendresponse(response, args[1], executor)
        else
            sendresponse("Internal Error Occured Check the Command Script Errors log", args[1], executor)
            cmderrors("Error Occured at Command_Map")
        end
    else
        sendresponse("Invalid Syntax: " .. args[1] .. " [map] [gametype] {script1} {script2}...", args[1], executor)
    end
end

function Command_Mapnext(executor, command, count)
    if count == 1 then
        if executor then
            execute_command("sv_map_next", executor)
        else
            execute_command("sv_map_next", true)
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Mapreset(executor, command, count)
    if count == 1 then
        sendresponse("[MAP RESET] The map has been reset", command, executor)
        execute_command("sv_map_reset")
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Move(executor, command, PlayerIndex, X, Y, Z, count)
    if count == 5 then
        if tonumber(X) and tonumber(Y) and tonumber(Z) then
            local players = getvalidplayers(PlayerIndex, executor)
            if players then
                for i = 1, #players do
                    local m_playerObjId = get_dynamic_player(players[i])
                    if m_playerObjId then
                        local m_objectId = nil
                        if isinvehicle(players[i]) then
                            local m_vehicleId = read_dword(getobject(m_playerObjId) + 0x11C)
                            m_objectId = m_vehicleId
                        elseif m_playerObjId then
                            m_objectId = m_playerObjId
                        end
                        if m_objectId then
                            local x, y, z = getobjectcoords(m_objectId)
                            movobjectcoords(m_objectId, x + X, y + Y, z + Z)
                            sendresponse(getname(players[i]) .. " has been moved", command, executor)
                            sendresponse("You have been moved.", "\\", players[i])
                        end
                    else
                        sendresponse(getname(players[i]) .. " is dead", command, executor)
                    end
                end
            else
                sendresponse("Invalid Player", command, executor)
            end
        else
            sendresponse("They must all be numbers", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [x] [y] [z]", command, executor)
    end
end

function Command_Mute(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                local mute
                if admin_table[gethash(players[i])] or ipadmins[ip] then
                    mute = true
                    sendresponse(getname(players[i]) .. " is an Admin, you cannot mute them", command, executor)
                    break
                end
                if not mute then
                    if not mute_table[ip] and not spamtimeout_table[ip] then
                        mute_table[ip] = true
                        sendresponse(getname(players[i]) .. " was muted by an admin", command, executor)
                    else
                        sendresponse(getname(players[i]) .. " has already been muted.", command, executor)
                    end
                else
                    sendresponse("Admins cannot be muted.", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_MultiTeamVehicles(executor, command, boolean, count)
    if gametype == 2 and not team_play then
        if count == 1 then
            if multiteam_vehicles then
                sendresponse("Multi Team Vehicles are currently enabled", command, executor)
            else
                sendresponse("Multi Team Vehicles are currently disabled", command, executor)
            end
        elseif count == 2 then
            if (boolean == "1" or boolean == "true") and not multiteam_vehicles then
                multiteam_vehicles = true
                for i = 1, 16 do
                    local m_player = getplayer(i)
                    if m_player then
                        write_byte(m_player + 0x20, 1)
                    end
                end
                sendresponse("Multi Team Vehicles are now enabled", command, executor)
            elseif (boolean == "1" or boolean == "true") and multiteam_vehicles then
                sendresponse("Multi Team Vehicles are already enabled", command, executor)
            elseif (boolean == "0" or boolean == "false") and multiteam_vehicles or multiteam_vehicles == nil then
                multiteam_vehicles = false
                for i = 1, 16 do
                    local m_player = getplayer(i)
                    if m_player then
                        write_byte(m_player + 0x20, i)
                    end
                end
                sendresponse("Multi Team Vehicles are now disabled", command, executor)
            elseif (boolean == "0" or boolean == "false") and not multiteam_vehicles then
                sendresponse("Multi Team Vehicles are already disabled", command, executor)
            else
                sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
        end
    else
        sendresponse("This command is currently disabled for this game", command, executor)
    end
end

function Command_Nameban(executor, command, PlayerIndex, count)
    if count == 2 and tonumber(command) == nil then
        local players = getvalidplayers(PlayerIndex, executor, command)
        if players then
            for i = 1, #players do
                if CheckAccess(executor, command, players[i], getaccess(executor)) then
                    local name = getname(players[i])
                    local bool = true
                    for i = 1, #name_bans do
                        if name_bans[i] == name then
                            bool = false
                            break
                        end
                    end
                    if bool then
                        table.insert(name_bans, name)
                        Ipban(players[i])
                        msg = name .. " has been name banned from the server"
                        sendresponse(msg, "/", executor)
                    end
                else
                    local Command = getvalidformat(command)
                    sendresponse("You cannot execute " .. Command .. " on this admin.", command, executor)
                    sendresponse(tostring(getname(executor)) .. " attemped to use " .. Command .. " on you", command, players[i])
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Namebanlist(executor, command, count)
    if count == 1 then
        if name_bans == { } or name_bans == nil or #name_bans == 0 then
            sendresponse("There are no names banned from the server.", command, executor)
            return
        end
        for i = 1, #name_bans do
            if name_bans[i] then
                sendresponse("[" .. i .. "] " .. name_bans[i], command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Nameunban(executor, command, ID, count)
    if count == 2 then
        local ID = tonumber(ID)
        if name_bans[ID] then
            sendresponse(name_bans[ID] .. " is now allowed in the server again.", command, executor)
            name_bans[ID] = nil
        else
            sendresponse("That name has not been banned.", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [ID]", command, executor)
    end
end

function Command_Noweapons(executor, command, boolean, count)
    if count == 1 then
        if noweapons then
            sendresponse("Noweapons mode is currently enabled.", command, executor)
        else
            sendresponse("Noweapons mode is currently disabled.", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and not noweapons then
            for i = 1, 16 do
                if getplayer(i) then
                    local player_object = get_dynamic_player(i)
                    local weaponId = read_dword(player_object + 0x118)
                    if weaponId ~= 0 then
                        for j = 0, 3 do
                            local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                            destroy_object(m_weapon)
                        end
                    end
                end
            end
            sendresponse("Noweapons is now on. You cannot pick up weapons.", command, executor)
            noweapons = true
        elseif boolean == "1" or boolean == "true" then
            sendresponse("Noweapons is already enabled", command, executor)
        elseif boolean ~= "0" and boolean ~= "false" then
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        elseif (boolean == "0" or boolean == "false") and noweapons then
            for i = 1, 16 do
                if getplayer(i) and get_dynamic_player(i) then
                    local ip = getip(i)
                    if Noweapons[ip] then
                        Noweapons[ip] = nil
                    end
                    resetweapons(i)
                end
            end
            sendresponse("Noweapons mode is now off.", command, executor)
            noweapons = false
        elseif noweapons == nil then
            sendresponse("Noweapons mode is now off.", command, executor)
            noweapons = false
        elseif boolean == "0" or boolean == "false" then
            sendresponse("Noweapons is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [boolean]", command, executor)
    end
end

function Command_Nuke(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local name = getname(players[i])
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId ~= nil then
                    local player_object = get_dynamic_player(players[i])
                    local x, y, z = read_vector3d(player_object + 0x5C)
                    for j = 1, 10 do
                        local nukeproj = spawn_object("proj", "weapons\\rocket launcher\\rocket", x, y, z + 10)
                        table.insert(nukes, nukeproj)
                        local m_proj = get_object_memory(nukeproj)
                        write_float(m_proj + 0x70, -5)
                    end
                    sendresponse(name .. " was nuked!", command, executor)
                    sendresponse(name .. " You were nuked!", command, players[i])
                else
                    sendresponse("Cannot nuke " .. name .. " because they are dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Overshield(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local player_object = get_dynamic_player(executor)
        if (player_object ~= 0) then
            local shields = read_float(player_object + 0xE4)
            if shields <= 1 then
                if not isinvehicle(executor) then
                    local x, y, z = getobjectcoords(player_object)
                    local overshield = spawn_object("eqip", "powerups\\over shield", x, y, z + 0.5)
                else
                    write_float(player_object + 0xE4, 3)
                end
                sendresponse("You have given yourself an overshield", command, executor)
            else
                sendresponse("You already have an overshield", command, executor)
            end
        else
            sendresponse("You are dead", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server cannot have an over shield.", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_object = get_dynamic_player(players[i])
                if (player_object ~= 0) then
                    local shields = read_float(player_object + 0xE4)
                    if shields <= 1 then
                        if not isinvehicle(players[i]) then
                            local x, y, z = getobjectcoords(player_object)
                            local overshield = spawn_object("eqip", "powerups\\over shield", x, y, z + 0.5)
                        else
                            write_float(player_object + 0xE4, 3)
                        end
                        sendresponse(getname(players[i]) .. " has been given an overshield", command, executor)
                    else
                        sendresponse(getname(players[i]) .. " already has an overshield", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_Players(executor, command, count)
    if count == 1 then
        sendresponse("Player Search:", command, executor)
        sendresponse("[ ID.    -    Name.    -    Team.    -    IP. ]", command, executor)
        for i = 1, 16 do
            if getplayer(i) then
                local name = getname(i)
                local id = resolveplayer(i)
                local player_team = getteam(i)
                local ip = getip(i)
                local hash = gethash(i)
                if team_play then
                    if player_team == "red" then
                        player_team = "Red Team"
                    elseif player_team == "blue" then
                        player_team = "Blue Team"
                    else
                        player_team = "Hidden"
                    end
                else
                    player_team = "FFA"
                end
                sendresponse("" .. id .. ".   " .. name .. "   |   " .. player_team .. "  -  IP: " .. ip, command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_PlayersMore(executor, command, count)
    if count == 1 or count == 2 and t[2] == "more" then
        sendresponse("[ID - Name -  Team - Status - IP]", command, executor)
        for i = 1, 16 do
            if getplayer(i) then
                local ip = getip(i)
                local player_team = getteam(i)
                if team_play then
                    if player_team == 0 then
                        player_team = "Red"
                    elseif player_team == 1 then
                        player_team = "Blue"
                    else
                        player_team = "Hidden"
                    end
                else
                    player_team = "FFA"
                end
                if admin_table[gethash(i)] or ipadmins[ip] then
                    ifadmin = "Admin"
                else
                    ifadmin = "Regular"
                end
                sendresponse(get_var(i, "$n") .. " - " .. getname(i) .. " - " .. player_team .. " - " .. ifadmin .. " - " .. ip, command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_PrivateMessage(executor, command, boolean, count)
    if count == 1 then
        if pm_enabled then
            sendresponse("Private Messaging is currently on", command, executor)
        else
            sendresponse("Private Messaging is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and pm_enabled ~= true then
            pm_enabled = true
            sendresponse("Private Messaging is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and pm_enabled == true then
            sendresponse("Private Messaging is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and pm_enabled ~= false then
            pm_enabled = false
            sendresponse("Private Messaging is now disabled", command, executor)
        elseif pm_enabled == nil then
            pm_enabled = false
            sendresponse("Private Messaging is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and pm_enabled == false then
            sendresponse("Private Messaging is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Privatesay(executor, args, count)
    if count >= 3 and tonumber(args[1]) == nil then
        local players = getvalidplayers(args[2], executor)
        if players then
            local message = ""
            for i = 3, #args do
                message = message .. args[i] .. " "
            end
            for i = 1, #players do
                privateSay(players[i], tostring(message))
            end
            sendresponse("Private messages sent.", args[1], executor)
        else
            sendresponse("Invalid Player", args[1], executor)
        end
    else
        sendresponse("Invalid Syntax: " .. args[1] .. " [player] [message]", args[1], executor)
    end
end

function Command_RconPasswordList(executor, command, count)
    if count == 1 then
        local Response = "[rcon] - [level]\n"
        for k, v in pairs(rcon_passwords) do
            if rcon_passwords[k] ~= nil and rcon_passwords[k] ~= { } then
                for key, value in ipairs(rcon_passwords[k]) do
                    Response = Response .. "[ " .. rcon_passwords[k][key].password .. " ] - [ " .. rcon_passwords[k][key].level .. " ]\n"
                end
            end
        end
        sendresponse(Response, command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Read(executor, command, type, struct, offset, value, PlayerIndex, count)
    local offset = tonumber(offset)
    if count > 4 and count < 7 and tonumber(type) == nil and tonumber(struct) == nil and offset then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if struct == "PlayerIndex" then
                        struct = getplayer(players[i])
                    elseif struct == "object" then
                        struct = getobject(m_objectId)
                        if struct == nil then
                            sendresponse(getname(players[i]) .. " is not alive.", command, executor)
                            return
                        end
                    elseif getobject(m_objectId) == nil then
                        sendresponse(getname(players[i]) .. " is not alive.", command, executor)
                        return
                    elseif struct == "weapon" then
                        local m_object = getobject(m_objectId)
                        struct = getobject(read_dword(m_object + 0x118))
                        if struct == nil then
                            sendresponse(getname(players[i]) .. " is not holding a weapon", command, executor)
                            return
                        end
                    elseif tonumber(struct) == nil then
                        sendresponse("Invalid Struct. Valid structs are: player, object, and weapon", command, executor)
                        return
                    end
                end
                if value then
                    if type == "byte" then
                        response = tostring(read_byte(struct + offset, value))
                    elseif type == "float" then
                        response = tostring(read_float(struct + offset, value))
                    elseif type == "word" then
                        response = tostring(readword(struct + offset, value))
                    elseif type == "dword" then
                        response = tostring(read_dword(struct + offset, value))
                    else
                        sendresponse("Invalid Type. Valid types are byte, float, word, and dword", command, executor)
                        return
                    end
                    sendresponse("Reading " .. tostring(value) .. " to struct " .. tostring(struct) .. " at offset " .. tostring(offset) .. " was a success", command, executor)
                    sendrespose(response, command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [type] [struct] [offset] [value] [player]", command, executor)
    end
end

function Command_ResetPlayer(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                local m_objectId = get_dynamic_player(players[i])
                local m_object
                if m_objectId then
                    m_object = getobject(m_objectId)
                end
                local id = resolveplayer(players[i])
                local m_player = getplayer(players[i])
                follow[id] = nil
                resetweapons(players[i])
                timer(0, "cleanupdrones", players[i])
                if m_object then
                    write_float(m_object + 0xE0, 1)
                    write_float(m_object + 0xE4, 1)
                end
                write_dword(m_player + 0x2C, 0)
                ghost_table[ip] = nil
                mode[ip] = nil
                gods[ip] = nil
                hidden[id] = nil
                Noweapons[ip] = nil
                -- for j = 1, 16 do
                -- for k = 1, 16 do
                -- if control_table[j][k] == players[i] then
                -- control_table[j][k] = nil
                -- bool = true
                -- break
                -- end
                -- end
                -- if bool then
                -- break
                -- end
                -- end
                sendresponse(getname(players[i]) .. " has been reset.", command, executor)
            end
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Resetweapons(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                if ip then
                    if Noweapons[ip] then
                        Noweapons[ip] = nil
                        local player_object = get_dynamic_player(players[i])
                        if player_object then
                            resetweapons(players[i])
                            sendresponse(getname(players[i]) .. " had their weapons reset", command, executor)
                        end
                    else
                        sendresponse(getname(players[i]) .. " never had their weapons taken away", command, executor)
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Resp(executor, command, PlayerIndex, time, count)
    if count == 3 and tonumber(time) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId == nil then
                    write_dword(m_player + 0x2c, time * 33)
                    sendresponse("Setting " .. getname(players[i]) .. "'s respawn time to " .. time .. " seconds", command, executor)
                else
                    sendresponse(getname(players[i]) .. " is alive. You cannot execute this command on him.", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [time]", command, executor)
    end
end

function Command_RTVEnabled(executor, command, boolean, count)
    if count == 1 then
        if rockthevote then
            sendresponse("RockTheVote is currently on", command, executor)
        else
            sendresponse("RockTheVote is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and rockthevote ~= true then
            rockthevote = true
            if rtv_required == nil then
                rtv_required = 0.6
            end
            sendresponse("RockTheVote is now enabled The default percentage needed is 60%.", command, executor)
            sendresponse("Change this with sv_rtv_needed", command, executor)
        elseif (boolean == "1" or boolean == "true") and rockthevote == true then
            sendresponse("RockTheVote is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and rockthevote ~= false then
            rockthevote = false
            sendresponse("RockTheVote is now disabled", command, executor)
        elseif rockthevote == nil then
            rockthevote = false
            sendresponse("RockTheVote is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and rockthevote == false then
            sendresponse("RockTheVote is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_RTVRequired(executor, command, percent, count)
    if count == 1 then
        if rtv_required == nil then
            rtv_required = 0.6
        end
        sendresponse(tostring(rtv_required * 100) .. "% votes required for RTV", command, executor)
    elseif count == 2 and tonumber(percent) then
        if tonumber(percent) <= 1 then
            sendresponse("Votes required for RTV has been set to " .. tonumber(percent) * 100 .. "%", command, executor)
            rtv_required = tonumber(percent)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [votes required (as a decimal)]", command, executor)
    end
end

function Command_SAMessage(executor, command, boolean, count)
    if count == 1 then
        if sa_message then
            sendresponse("Server Admin Message is currently on", command, executor)
        else
            sendresponse("Server Admin Message is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and sa_message ~= true then
            sa_message = true
            sendresponse("Server Admin Message is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and sa_message == true then
            sendresponse("Server Admin Message is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and sa_message ~= false then
            sa_message = false
            sendresponse("Server Admin Message is now disabled", command, executor)
        elseif sa_message == nil then
            sa_message = false
            sendresponse("Server Admin Message is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and sa_message == false then
            sendresponse("Server Admin Message is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Say(executor, arg, count)
    if count >= 2 then
        local message = ""
        for i = 2, #arg do
            message = message .. arg[i] .. " "
        end
        Say(server_prefix .. " " .. message, 5)
        sendresponse("Message sent.", arg[1], executor)
    else
        sendresponse("Invalid Syntax: " .. arg[1] .. " [message]", arg[1], executor)
    end
end

function Command_ScrimMode(executor, command, boolean, count)
    if count == 1 then
        if scrim_mode then
            sendresponse("Scrim Mode is currently on", command, executor)
        else
            sendresponse("Scrim Mode is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and scrim_mode ~= true then
            scrim_mode = true
            falldamage = true
            deathless = false
            for i = 1, 16 do
                if getplayer(i) and get_dynamic_player(i) then
                    local ip = getip(i)
                    local m_objectId = get_dynamic_player(i)
                    local m_object
                    if m_objectId then
                        m_object = getobject(m_objectId)
                    end
                    local id = resolveplayer(i)
                    local m_player = getplayer(i)
                    follow[id] = nil
                    resetweapons(i)
                    timer(0, "cleanupdrones", i)
                    dmgmultiplier[ip] = 1.0
                    if m_object then
                        write_float(m_object + 0xE0, 1)
                        write_float(m_object + 0xE4, 1)
                    end
                    write_dword(m_player + 0x2C, 0)
                    ghost_table[ip] = nil
                    mode[ip] = nil
                    gods[ip] = nil
                    hidden[id] = nil
                    if Noweapons[ip] then
                        Noweapons[ip] = nil
                    end
                    if infammo then
                        kill(i)
                    end
                end
            end
            for i = 1, 16 do
                for j = 1, 16 do
                    if control_table[j] then
                        for k = 1, 16 do
                            if control_table[j][k] == i then
                                control_table[j][k] = nil
                                bool = true
                                break
                            end
                        end
                    end
                    if bool then
                        break
                    end
                end
            end
            infammo = false
            control_table = { }
            follow = { }
            hidden = { }
            gods = { }
            ghost_table = { }
            mode = { }
            Noweapons = { }
            nukes = { }
            objects = { }
            objspawnid = { }
            suspend_table = { }
            vehicle_drone_table = { }
            sendresponse("Scrim Mode is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and scrim_mode == true then
            sendresponse("Scrim Mode is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and scrim_mode ~= false then
            scrim_mode = false
            sendresponse("Scrim Mode is now disabled", command, executor)
        elseif scrim_mode == nil then
            scrim_mode = false
            sendresponse("Scrim Mode is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and scrim_mode == false then
            sendresponse("Scrim Mode is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_ScriptLoad(executor, command, count)
    if count >= 1 then
        local arg = tokenizestring(command)
        command = "lua_load"
        for i = 2, #arg do
            command = command .. " " .. arg[i]
        end
        if executor then
            execute_command(command, executor)
        else
            response = execute_command(command)
            sendresponse(response, arg[1], executor)
        end
    end
end

function Command_ScriptUnload(executor, command, count)
    if count >= 1 then
        local arg = tokenizestring(command)
        command = "lua_unload"
        for i = 2, #arg do
            if arg[i] ~= "commands" and arg[i] ~= "command" and arg[i] ~= "cmd" and arg[i] ~= "cmds" then
                command = command .. " " .. arg[i]
            end
        end
        if executor then
            execute_command(command, executor)
        else
            response = execute_command(command)
            sendresponse(response, arg[1], executor)
        end
    end
end

function Command_Setammo(executor, command, PlayerIndex, type, ammo, count)
    if count == 4 and tonumber(ammo) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_object = get_dynamic_player(players[i])
                if player_object then
                    local m_weaponId = read_dword(player_object + 0x118)
                    local weapon_id = get_object_memory(m_weaponId)
                    sync_ammo(m_weaponId)
                    if type == "unloaded" or type == "1" then
                        safe_write(true)
                        write_dword(weapon_id + 0x2B6, tonumber(ammo))
                        safe_write(false)
                        sendresponse(getname(players[i]) .. " had their unloaded ammo changed to " .. ammo, command, executor)
                    elseif type == "2" or type == "loaded" then
                        safe_write(true)
                        write_dword(weapon_id + 0x2B8, tonumber(ammo))
                        safe_write(false)
                        sync_ammo(m_weaponId)
                        sendresponse(getname(players[i]) .. " had their loaded ammo changed to " .. ammo, command, executor)
                    else
                        sendresponse("Invalid type: 1 for unloaded, 2 for loaded ammo", command, executor)
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [type] [ammo]", command, executor)
    end
end

function Command_Setassists(executor, command, PlayerIndex, assists, count)
    if count == 3 and tonumber(assists) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                local Assists = tonumber(assists)
                if Assists > 0x7FFF then
                    write_wordsigned(m_player + 0xA4, 0x7FFF)
                elseif Assists < -0x7FFF then
                    write_wordsigned(m_player + 0xA4, -0x7FFF)
                else
                    write_wordsigned(m_player + 0xA4, Assists)
                end
                sendresponse(getname(players[i]) .. " had their assists set to " .. assists, command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [assists]", command, executor)
    end
end

function Command_Setcolor(executor, command, PlayerIndex, color, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                sendresponse(getname(players[i]) .. " is currently " .. getcolor(players[i]), command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local player_object = get_dynamic_player(players[i])
                local player_obj_id = read_dword(get_player(i) + 0x34)
                local m_player = getplayer(players[i])
                if player_object then
                    local x, y, z = read_vector3d(player_object + 0x5C)
                    if color == "white" or color == "0" or color == '"white"' or color == '"0"' then
                        write_byte(m_player + 0x60, 0)
                    elseif color == "black" or color == '"black"' or color == '"1"' then
                        write_byte(m_player + 0x60, 1)
                    elseif color == "red" or color == '"red"' or color == '"2"' then
                        write_byte(m_player + 0x60, 2)
                    elseif color == "blue" or color == '"blue"' or color == '"3"' then
                        write_byte(m_player + 0x60, 3)
                    elseif color == "gray" or color == '"gray"' or color == '"4"' then
                        write_byte(m_player + 0x60, 4)
                    elseif color == "yellow" or color == '"yellow"' or color == '"5"' then
                        write_byte(m_player + 0x60, 5)
                    elseif color == "green" or color == '"green"' or color == '"6"' then
                        write_byte(m_player + 0x60, 6)
                    elseif color == "pink" or color == '"pink"' or color == '"7"' then
                        write_byte(m_player + 0x60, 7)
                    elseif color == "purple" or color == '"purple"' or color == '"8"' then
                        write_byte(m_player + 0x60, 8)
                    elseif color == "cyan" or color == '"cyan"' or color == '"9"' then
                        write_byte(m_player + 0x60, 9)
                    elseif color == "cobalt" or color == '"cobalt"' or color == '"10"' then
                        write_byte(m_player + 0x60, 10)
                    elseif color == "orange" or color == '"orange"' or color == '"11"' then
                        write_byte(m_player + 0x60, 11)
                    elseif color == "teal" or color == '"teal"' or color == '"12"' then
                        write_byte(m_player + 0x60, 12)
                    elseif color == "sage" or color == '"sage"' or color == '"13"' then
                        write_byte(m_player + 0x60, 13)
                    elseif color == "brown" or color == '"brown"' or color == '"14"' then
                        write_byte(m_player + 0x60, 14)
                    elseif color == "tan" or color == '"tan"' or color == '"15"' then
                        write_byte(m_player + 0x60, 15)
                    elseif color == "maroon" or color == '"maroon"' or color == '"16"' then
                        write_byte(m_player + 0x60, 16)
                    elseif color == "salmon" or color == '"salmon"' or color == '"17"' then
                        write_byte(m_player + 0x60, 17)
                    else
                        sendresponse("Invalid Color", command, executor)
                        return
                    end
                    sendresponse(getname(players[i]) .. " had their color changed to " .. color .. "", command, executor)
                    if player_obj_id ~= nil then
                        destroy_object(player_obj_id)
                        if colorspawn == nil then
                            colorspawn = { }
                        end
                        if colorspawn[players[i]] == nil then
                            colorspawn[players[i]] = { }
                        end
                        colorspawn[players[i]][1] = x
                        colorspawn[players[i]][2] = y
                        colorspawn[players[i]][3] = z
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {color}", command, executor)
    end
end

function Command_Setdeaths(executor, command, PlayerIndex, deaths, count)
    if count == 3 and tonumber(deaths) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                Deaths = tonumber(deaths)
                if Deaths > 0x7FFF then
                    write_wordsigned(m_player + 0xAE, 0x7FFF)
                elseif Deaths < -0x7FFF then
                    write_wordsigned(m_player + 0xAE, -0x7FFF)
                else
                    write_wordsigned(m_player + 0xAE, Deaths)
                end
                sendresponse(getname(players[i]) .. " had their deaths set to " .. deaths, command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [deaths]", command, executor)
    end
end

function Command_Setfrags(executor, command, PlayerIndex, frags, count)
    if count == 3 and tonumber(frags) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if tonumber(frags) <= 255 then
                        write_byte(m_objectId + 0x31E, frags)
                        sendresponse("Setting " .. getname(players[i]) .. "'s frag grenades to " .. frags, command, executor)
                        sendresponse("Your frag grenades were set to " .. frags, command, players[i])
                    else
                        write_byte(m_objectId + 0x31E, 255)
                        sendresponse("Setting " .. getname(players[i]) .. "'s frag grenades to " .. frags, command, executor)
                        sendresponse("Your frag grenades were set to " .. frags, command, players[i])
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [amount]", command, executor)
    end
end

function Command_Setkills(executor, command, PlayerIndex, kills, count)
    if count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                kills = tonumber(kills)
                if kills > 0x7FFF then
                    write_wordsigned(m_player + 0x9C, 0x7FFF)
                elseif kills < -0x7FFF then
                    write_wordsigned(m_player + 0x9C, -0x7FFF)
                else
                    write_wordsigned(m_player + 0x9C, kills)
                end
                sendresponse(getname(players[i]) .. " had their kills set to " .. kills, command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [kills]", command, executor)
    end
end

function Command_Setmode(executor, command, PlayerIndex, Mode, object, count)
    if PlayerIndex == nil then
        sendresponse("Invalid Syntax: " .. command .. " [player] [mode] {object (for spawngun only)}", command, executor)
        return
    end
    local players = getvalidplayers(PlayerIndex, executor)
    if players then
        if count == 3 then
            for i = 1, #players do
                if Mode == "destroy" then
                    mode[getip(players[i])] = "destroy"
                    sendresponse(getname(players[i]) .. " is now in destroy mode", command, executor)
                elseif Mode == "portalgun" then
                    mode[getip(players[i])] = "portalgun"
                    sendresponse(getname(players[i]) .. " is now in portalgun mode", command, executor)
                elseif Mode == "entergun" then
                    mode[getip(players[i])] = "entergun"
                    sendresponse(getname(players[i]) .. " is now in entergun mode", command, executor)
                elseif Mode == "normal" or Mode == "none" or Mode == "regular" then
                    objspawnid[getip(players[i])] = nil
                    mode[getip(players[i])] = nil
                    sendresponse(getname(players[i]) .. " is now in normal mode", command, executor)
                else
                    sendresponse("Invalid Mode\n-- destroy\n-- portalgun\n-- entergun\n-- spawngun\n-- normal", command, executor)
                end
            end
        elseif count == 4 then
            for i = 1, #players do
                if Mode == "spawngun" then
                    local objexists = false
                    objspawnid[getip(players[i])] = nil
                    mode[getip(players[i])] = nil
                    for j = 1, #objects do
                        if object == objects[j][1] then
                            mode[getip(players[i])] = "spawngun"
                            obj_type = objects[j][2]
                            objspawnid[getip(players[i])] = objects[j][3]
                            sendresponse(getname(players[i]) .. " is now spawning " .. objects[j][1] .. "", command, executor)
                            objexists = true
                            break
                        end
                    end
                    if objexists == false then
                        sendresponse("Object does not exist. Make sure you are spelling it right.", command, executor)
                    end
                end
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " [player] [mode] {object}", command, executor)
            sendresponse("Modes:\n-- destroy\n-- portalgun\n-- entergun\n-- spawngun\n-- normal", command, executor)
        end
    else
        sendresponse("Invalid Player", command, executor)
    end
end

function Command_Setpassword(executor, command, password, count)
    if count == 1 then
        local response = execute_command("sv_password", true)
        if response then
            sendresponse(response, command, executor)
        else
            sendresponse("Critical Error: " .. passwrd .. "'", command, executor)
        end
    elseif count == 2 then
        if password == "" then
            execute_command('sv_password ""')
            sendresponse("Password has been taken off", command, executor)
            passwrd = nil
        elseif passwrd then
            execute_command('sv_password ' .. password)
            sendresponse("The password is now " .. password, command, executor)
            passwrd = password
        else
            sendresponse("Internal Error Occured Check the Command Script Errors log", command, executor)
            cmderrors("Error Occured at Command_Setpassword")
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {password}", command, executor)
    end
end

function Command_Setplasmas(executor, command, PlayerIndex, plasmas, count)
    if count == 3 and tonumber(plasmas) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = getplayerobjectid(players[i])
                if m_objectId then
                    if tonumber(plasmas) <= 255 then
                        write_byte(m_objectId + 0x31F, tonumber(plasmas))
                        sendresponse("Setting " .. getname(players[i]) .. "'s plasma grenades to: " .. plasmas, command, executor)
                        sendresponse("Your plasma grenades were set to: " .. plasmas, command, players[i])
                    else
                        write_byte(m_objectId + 0x31F, 255)
                        sendresponse("Setting " .. getname(players[i]) .. "'s plasma grenades to " .. plasmas, command, executor)
                        sendresponse("Your plasma grenades were set to: " .. plasmas, command, players[i])
                    end
                else
                    sendresponse(getname(players[i]) .. " is dead!", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: sv_setplasmas [player] [amount]", command, executor)
    end
end

function Command_Setresp(executor, command, time, count)
    if count == 2 then
        if time == "default" then
            respset = false
            sendresponse("Respawn time set to the gametype's default setting", command, executor)
        elseif tonumber(time) then
            resptime = time
            respset = true
            sendresponse("Respawn time set to " .. time .. " seconds", command, executor)
        elseif respset == nil then
            sendresponse("Respawn time not set. Defaulting to gametype's default setting.", command, executor)
        else
            sendresponse("Invalid Syntax: " .. command .. " [seconds]", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [seconds]", command, executor)
    end
end

function Command_Setscore(executor, command, PlayerIndex, score, count)
    if count == 3 and tonumber(score) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                setscore(players[i], tonumber(score))
                sendresponse(getname(players[i]) .. " had their score set to " .. score .. "", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [score]", command, executor)
    end
end

function Command_Setspeed(executor, command, PlayerIndex, speed, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                local cur_speed = read_float(m_player + 0x6C)
                sendresponse(getname(players[i]) .. "'s speed is currently " .. cur_speed, command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 3 and tonumber(speed) then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                setspeed(players[i], speed)
                sendresponse(getname(players[i]) .. " had their speed changed to " .. speed, command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {speed}", command, executor)
    end
end

function Command_Setteleport(executor, command, locname, PlayerIndex, count)
    if count == 2 then
        response = false
        sendresponse("Invalid Syntax: " .. command .. " [locname] [player]", command, executor)
    elseif count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if getobject(m_objectId) then
                        execute_command("sv_teleport_add " .. tostring(locname), players[i])
                        if string.find(response, "corresponds") then
                            sendresponse("Teleport location " .. locname .. " now corresponds to " .. getname(players[i]) .. "'s location", command, executor)
                        else
                            say(tostring(response))
                            sendresponse(locname .. " is already added", command, executor)
                        end
                    else
                        sendresponse("Cannot add teleport because the player is dead.", command, executor)
                    end
                else
                    sendresponse("Cannot add teleport because the player is dead.", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [locname] [player]", command, executor)
    end
end

function Command_TeleportList(executor, command, count)
    if count == 2 then
        local response = execute_command("sv_teleport_list", true)
        sendresponse(tostring(response), command, executor)
    end
end

function Command_Spawn(executor, command, object, PlayerIndex, amount, resptime, recycle, type, count)
    local bool = true
    if type == "enter" then
        if count == 2 then
            if executor ~= nil then
                PlayerIndex = get_var(executor, "$n")
            else
                sendresponse("what are you doing, the server isn't a player!, it can't enter a vehicle...", command, executor)
                return
            end
        elseif count == 3 then
            if string.lower(PlayerIndex) == "me" and executor ~= nil then
                PlayerIndex = get_var(executor, "$n")
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " [vehicle] {player}", command, executor)
            return
        end
        message = command .. " " .. object .. " " .. PlayerIndex
    elseif type == "give" then
        if count == 2 then
            if executor ~= nil then
                PlayerIndex = get_var(executor, "$n")
            else
                sendresponse("what are you doing, the server isn't a player, it can't be given a weapon...", command, executor)
                return
            end
        elseif count == 3 then
            if string.lower(PlayerIndex) == "me" and executor ~= nil then
                PlayerIndex = get_var(executor, "$n")
            end
        else
            sendresponse("Invalid Syntax: " .. command .. " [weapon] {player}", command, executor)
            return
        end
        message = command .. " " .. object .. " " .. PlayerIndex
    elseif type == "spawn" then
        if object then
            if count == 2 then
                if executor ~= nil then
                    message = command .. " " .. object .. " " .. get_var(executor, "$n")
                else
                    sendresponse("what are you doing, the server isn't a player, you can't spawn at its locations...", command, executor)
                    return
                end
            elseif count == 3 then
                if string.lower(PlayerIndex) == "me" and executor ~= nil then
                    PlayerIndex = get_var(executor, "$n")
                end
                message = command .. " " .. object .. " " .. PlayerIndex
            elseif count == 4 then
                message = command .. " " .. object .. " " .. PlayerIndex .. " " .. amount
            elseif count == 5 then
                message = command .. " " .. object .. " " .. PlayerIndex .. " " .. amount .. " " .. resptime
            elseif count == 6 then
                message = command .. " " .. object .. " " .. PlayerIndex .. " " .. amount .. " " .. resptime .. " " .. recycle
            else
                sendresponse("Invalid Syntax: " .. command .. " [object] {player} {amount} {resptime} {recycle}", command, executor)
                return
            end
        else
            sendresponse("Missing Object", command, executor)
            return
        end
    else
        sendresponse("An unknown error has occured.", command, executor)
    end
    if type == "spawn" then
        bool = true
        if object == "cyborg" or object == "bot" or object == "mastercheif" or object == "biped" or object == "bipd" or object == '"cyborg"' or object == '"bot"' or object == '"mastercheif"' or object == '"biped"' or object == '"bipd"' then
            object_to_spawn = bipds_table[1][2]
            Spawn(message, "Cyborg", "bipd", object_to_spawn, executor, type)
        elseif object == "captain" or object == "keyes" or object == '"captain"' or object == '"keyes"' then
            object_to_spawn = bipds_table[2][2]
            Spawn(message, "Captain Keyes", "bipd", object_to_spawn, executor, type)
        elseif object == "cortana" or object == '"cortana"' then
            object_to_spawn = bipds_table[3][2]
            Spawn(message, "Cortana", "bipd", object_to_spawn, executor, type)
        elseif object == "cortana2" or object == '"cortana2"' then
            object_to_spawn = bipds_table[4][2]
            Spawn(message, "Cortana2", "bipd", object_to_spawn, executor, type)
        elseif object == "crewman" or object == '"crewman"' then
            object_to_spawn = bipds_table[5][2]
            Spawn(message, "Crewman", "bipd", object_to_spawn, executor, type)
        elseif object == "elite" or object == '"elite"' then
            object_to_spawn = bipds_table[6][2]
            Spawn(message, "elite", "bipd", object_to_spawn, executor, type)
        elseif object == "elite2" or object == '"elite2"' then
            object_to_spawn = bipds_table[7][2]
            Spawn(message, "Elite Special", "bipd", object_to_spawn, executor, type)
        elseif object == "engineer" or bject == '"engineer"' then
            object_to_spawn = bipds_table[8][2]
            Spawn(message, "Engineer", "bipd", object_to_spawn, executor, type)
        elseif object == "flood" or object == '"flood"' then
            object_to_spawn = bipds_table[9][2]
            Spawn(message, "Flood Captain", "bipd", object_to_spawn, executor, type)
        elseif object == "flood2" or object == '"flood2"' then
            object_to_spawn = bipds_table[10][2]
            Spawn(message, "Flood Infection", "bipd", object_to_spawn, executor, type)
        elseif object == "flood3" or object == '"flood3"' then
            object_to_spawn = bipds_table[11][2]
            Spawn(message, "Flood Carrier", "bipd", object_to_spawn, executor, type)
        elseif object == "floodelite" or object == '"floodelite"' then
            object_to_spawn = bipds_table[12][2]
            Spawn(message, "FloodCombat Elite", "bipd", object_to_spawn, executor, type)
        elseif object == "floodhuman" or object == '"floodhuman"' then
            object_to_spawn = bipds_table[13][2]
            Spawn(message, "FloodCombat Human", "bipd", object_to_spawn, executor, type)
        elseif object == "pedobear" or object == "grunt" or object == '"pedobear"' or object == '"grunt"' then
            object_to_spawn = bipds_table[14][2]
            Spawn(message, "Pedobear", "bipd", object_to_spawn, executor, type)
        elseif object == "hunter" or object == '"hunter"' then
            object_to_spawn = bipds_table[15][2]
            Spawn(message, "Hunter", "bipd", object_to_spawn, executor, type)
        elseif object == "marine" or bject == '"marine"' then
            object_to_spawn = bipds_table[16][2]
            Spawn(message, "Marine", "bipd", object_to_spawn, executor, type)
        elseif object == "marinesuicide" or object == "marine2" or object == '"marinesuicide"' or object == '"marine2"' then
            object_to_spawn = bipds_table[17][2]
            Spawn(message, "Marine Suicidal", "bipd", object_to_spawn, executor, type)
        elseif object == "monitor" or object == '"monitor"' then
            object_to_spawn = bipds_table[18][2]
            Spawn(message, "Monitor", "bipd", object_to_spawn, executor, type)
        elseif object == "sentinel" or object == '"sentinel"' then
            object_to_spawn = bipds_table[19][2]
            Spawn(message, "Sentinel", "bipd", object_to_spawn, executor, type)
        elseif object == "johnson" or object == '"johnson"' then
            object_to_spawn = bipds_table[20][2]
            Spawn(message, "Sgt. Johnson", "bipd", object_to_spawn, executor, type)
        elseif object == "camo" or object == "camouflage" or object == '"camo"' or object == '"camouflage"' then
            object_to_spawn = eqip_table[1][2]
            Spawn(message, "Camouflage", "eqip", object_to_spawn, executor, type)
        elseif object == "healthpack" or object == '"healthpack"' then
            object_to_spawn = eqip_table[2][2]
            Spawn(message, "Health Pack", "eqip", object_to_spawn, executor, type)
        elseif object == "overshield" or object == "os" or object == '"overshield"' or object == '"os"' then
            object_to_spawn = eqip_table[3][2]
            Spawn(message, "Overshield", "eqip", object_to_spawn, executor, type)
        elseif object == "dblspd" or object == '"dblspd"' then
            object_to_spawn = eqip_table[4][2]
            Spawn(message, "Double Speed", "eqip", object_to_spawn, executor, type)
        elseif object == "fullspec" or object == '"fullspec"' then
            object_to_spawn = eqip_table[5][2]
            Spawn(message, "Full-Spectrum Vision", "eqip", object_to_spawn, executor, type)
        elseif object == "fnade" or object == "nades" or object == '"fnade"' or object == '"nades"' then
            object_to_spawn = eqip_table[6][2]
            Spawn(message, "Frag Grenade", "eqip", object_to_spawn, executor, type)
        elseif object == "pnade" or object == '"pnade"' then
            object_to_spawn = eqip_table[7][2]
            Spawn(message, "Plasma Grenade", "eqip", object_to_spawn, executor, type)
        elseif object == "rifleammo" or object == '"rifleammo"' then
            object_to_spawn = eqip_table[8][2]
            Spawn(message, "Assault Rifle Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "needlerammo" or object == '"needlerammo"' then
            object_to_spawn = eqip_table[9][2]
            Spawn(message, "Needler Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "pistolammo" or object == '"pistolammo"' then
            object_to_spawn = eqip_table[10][2]
            Spawn(message, "Pistol Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "rocketammo" or object == '"rocketammo"' then
            object_to_spawn = eqip_table[11][2]
            Spawn(message, "Rocket Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "shottyammo" or object == '"shottyammo"' then
            object_to_spawn = eqip_table[12][2]
            Spawn(message, "Shotgun Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "sniperammo" or object == '"sniperammo"' then
            object_to_spawn = eqip_table[13][2]
            Spawn(message, "Sniper Ammo", "eqip", object_to_spawn, executor, type)
        elseif object == "flameammo" or object == '"flameammo"' then
            object_to_spawn = eqip_table[14][2]
            Spawn(message, "Flamethrower Ammo", "eqip", object_to_spawn, executor, type)
        else
            bool = false
        end
        if bool then
            return
        end
    end
    if type ~= "enter" then
        bool = true
        if object == "rifle" or object == "arifle" or object == "assaultrifle" or object == '"rifle"' or object == '"arifle"' or object == '"assaultrifle"' then
            object_to_spawn = weapons[1][2]
            Spawn(message, "Assault Rifle", "weap", object_to_spawn, executor, type)
        elseif object == "ball" or object == "oddball" or object == '"ball"' or object == '"oddball"' then
            object_to_spawn = weapons[2][2]
            Spawn(message, "Oddball", "weap", object_to_spawn, executor, type)
        elseif object == "flag" or object == '"flag"' then
            object_to_spawn = weapons[3][2]
            Spawn(message, "Flag", "weap", object_to_spawn, executor, type)
        elseif object == "flamethrower" or object == "flame" or object == '"flamethrower"' or object == '"flame"' then
            object_to_spawn = weapons[4][2]
            Spawn(message, "Flame Thrower", "weap", object_to_spawn, executor, type)
        elseif object == "ggun" or object == "gravitygun" or object == '"ggun"' or object == '"gravitygun"' then
            object_to_spawn = weapons[5][2]
            Spawn(message, "Gravity Gun", "weap", object_to_spawn, executor, type)
        elseif object == "needler" or object == '"needler"' then
            object_to_spawn = weapons[6][2]
            Spawn(message, "Needler", "weap", object_to_spawn, executor, type)
        elseif object == "pistol" then
            object_to_spawn = weapons[7][2]
            Spawn(message, "Pistol", "weap", object_to_spawn, executor, type)
        elseif object == "ppistol" or object == "plasmapistol" or object == '"ppistol"' or object == '"plasmapistol"' then
            object_to_spawn = weapons[8][2]
            Spawn(message, "Plasma Pistol", "weap", object_to_spawn, executor, type)
        elseif object == "prifle" or object == "plasmarifle" or object == '"prifle"' or object == '"plasmarifle"' then
            object_to_spawn = weapons[9][2]
            Spawn(message, "Plasma Rifle", "weap", object_to_spawn, executor, type)
        elseif object == "frg" or object == "fuelrod" or object == "rod" or object == "plasmacannon" or object == '"frg"' or object == '"fuelrod"' or object == '"rod"' or object == '"plasmacannon"' then
            object_to_spawn = weapons[10][2]
            Spawn(message, "Fuel Rod", "weap", object_to_spawn, executor, type)
        elseif object == "rocket" or object == "rocketlauncher" or object == "rox" or object == '"rocket"' or object == '"rocketlauncher"' or object == '"rox"' then
            object_to_spawn = weapons[11][2]
            Spawn(message, "Rocket Launcher", "weap", object_to_spawn, executor, type)
        elseif object == "shotty" or object == "shotgun" or object == '"shotty"' or object == '"shotgun"' then
            object_to_spawn = weapons[12][2]
            Spawn(message, "Shotgun", "weap", object_to_spawn, executor, type)
        elseif object == "sniper" or object == '"sniper"' then
            object_to_spawn = weapons[13][2]
            Spawn(message, "Sniper Rifle", "weap", object_to_spawn, executor, type)
        elseif object == "energysword" or object == "esword" or object == '"energysword"' or object == '"esword"' then
            object_to_spawn = weapons[14][2]
            Spawn(message, "Energy Sword", "weap", object_to_spawn, executor, type)
        else
            bool = false
        end
        if bool then
            return
        end
    end
    if type ~= "give" then
        bool = true
        if object == "hog" or object == "warthog" or object == '"hog"' or object == '"warthog"' then
            object_to_spawn = vehicles[1][2]
            Spawn(message, "Warthog", "vehi", object_to_spawn, executor, type)
        elseif object == "ghost" or object == '"ghost"' then
            object_to_spawn = vehicles[2][2]
            Spawn(message, "Ghost", "vehi", object_to_spawn, executor, type)
        elseif object == "rhog" or object == "rocketwarthog" or object == '"rhog"' or object == '"rocketwarthog"' then
            object_to_spawn = vehicles[3][2]
            Spawn(message, "Rocket Warthog", "vehi", object_to_spawn, executor, type)
        elseif object == "shee" or object == "banshee" or object == '"shee"' or object == '"banshee"' then
            object_to_spawn = vehicles[4][2]
            Spawn(message, "Banshee", "vehi", object_to_spawn, executor, type)
        elseif object == "tank" or object == "scorpion" or object == '"tank"' or object == '"scorpion"' then
            object_to_spawn = vehicles[5][2]
            Spawn(message, "Tank", "vehi", object_to_spawn, executor, type)
        elseif object == "turret" or object == "shade" or object == '"turret"' or object == '"shade"' then
            object_to_spawn = vehicles[6][2]
            Spawn(message, "Gun Turret", "vehi", object_to_spawn, executor, type)
        else
            bool = false
        end
        if bool then
            return
        end
    end
    if bool == false then
        if type == "give" then
            sendresponse("Invalid Weapon", command, executor)
        elseif type == "enter" then
            sendresponse("Invalid Vehicle.", command, executor)
        elseif type == "spawn" then
            sendresponse("Invalid Object", command, executor)
        end
    end
end

function Command_SpamMax(executor, command, value, count)
    if count == 1 then
        spam_max = tonumber(spam_max) or 7
        sendresponse("Spam max is " .. spam_max, command, executor)
    elseif count == 2 and tonumber(value) then
        if value == 0 and antispam ~= false then
            antispam = false
            sendresponse("AntiSpam is now disabled", command, executor)
        elseif value == 0 and antispam == false then
            sendresponse("AntiSpam is already disabled", command, executor)
        else
            spam_max = tonumber(value)
            sendresponse("The Spam max is now " .. value, command, executor)
        end
    else
        sendresponse("Invalid Syntax:  " .. command .. " [value]", command, executor)
    end
end

function Command_SpamTimeOut(executor, command, time, count)
    if count == 1 then
        spam_timeout = tonumber(spam_timeout) or 60
        sendresponse("Spam timeout is " .. round(spam_timeout / 60, 1) .. " minute(s)", command, executor)
    elseif count == 2 and tonumber(time) then
        time = tonumber(time)
        if time == 0 and antispam ~= false then
            antispam = false
            sendresponse("AntiSpam is now disabled", command, executor)
        elseif time == 0 and antispam == false then
            sendresponse("AntiSpam is already disabled", command, executor)
        else
            spam_timeout = tonumber(time * 60)
            sendresponse("The Spam timeout is now " .. tostring(time) .. " minute(s)", command, executor)
        end
    else
        sendresponse("Invalid Syntax:  " .. command .. " [time]", command, executor)
    end
end

function Command_Specs(executor, command, count)
    if count == 1 then
        local specs = readtagname(specs_addr)
        sendresponse("The server specs are: " .. tostring(specs), command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_StartMapcycle(executor, command, count)
    if count == 1 then
        local response = execute_command("sv_mapcycle_begin", true)
        sendresponse(response[1], command, executor)
        execute_command("sv_mapcycle_begin")
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Status(executor, command, count)
    if count == 1 then
        local response = "Admin Blocker: " .. tostring(admin_blocker) .. "  |  Anti Caps: " .. tostring(anticaps) .. "  |  Anti Spam: " .. tostring(antispam) .. "\n"
        response = response .. "" .. "Chat Commands: " .. tostring(chatcommands) .. "  |  Deathless: " .. tostring(deathless) .. "  |  Falldamage: " .. tostring(falldamage) .. "\n"
        response = response .. "" .. "First Join Message: " .. tostring(firstjoin_message) .. "  |  Hash Check: " .. tostring(hash_check) .. "  |  Infinite Ammo: " .. tostring(infammo) .. "\n"
        response = response .. "" .. "Killspree: " .. tostring(killing_spree) .. "  |  Noweapons: " .. tostring(noweapons) .. "\n"
        response = response .. "" .. "Pvtmessage: " .. tostring(pm_enabled) .. "  |  Respawn_time: " .. tostring(respset) .. "  |  Rtv_enabled: " .. tostring(rockthevote) .. "\n"
        response = response .. "" .. "Rtv_needed: " .. tostring(rtv_required) .. "  |  Serveradmin_message: " .. tostring(sa_message) .. "  |  Spam Max: " .. tostring(spam_max) .. "\n"
        response = response .. "" .. "Spamtimeout: " .. tostring(spam_timeout) .. "seconds  |  Tbagdet: " .. tostring(tbag_detection) .. "  |  Uniques Enabled: " .. tostring(uniques_enabled) .. "\n"
        response = response .. "" .. "Version Check: " .. tostring(version_check) .. "  |  Version: " .. tostring(Version) .. "  |  Votekick Enabled: " .. tostring(votekick_allowed) .. "\n"
        response = response .. "" .. "Votekick Needed: " .. tostring(votekick_required) .. "  |  Votekick Action: " .. tostring(votekick_action) .. "  |  Welcomeback Message: " .. tostring(wb_message)
        sendresponse(response, command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Superban(executor, command, PlayerIndex, message, count)
    if count == 2 or count == 3 then
        local players = getvalidplayers(PlayerIndex, executor, command)
        if players then
            local name = "the Server"
            if executor ~= nil then
                name = getname(executor)
            end
            for i = 1, #players do
                message = tostring(message) or "None Given"
                BanReason(getname(players[i]) .. " was banned by " .. name .. " Reason: " .. message .. " Type: Super Ban")
                say(getname(players[i]) .. " was Super banned by " .. name .. " Reason: " .. message)
                table.insert(name_bans, getname(players[i]))
                local ip = getip(players[i])
                ip_banlist[ip] = { }
                table.insert(ip_banlist[ip], { ["name"] = getname(players[i]), ["ip"] = ip, ["time"] = -1, ["id"] = ip_banid })
                ip_banid = ip_banid + 1
                local words = tokenizestring(ip, ".")
                local ip2 = words[1] .. "." .. words[2]
                iprange_banlist[ip2] = { }
                table.insert(iprange_banlist[ip2], { ["name"] = getname(players[i]), ["ip"] = ip2, ["time"] = ipbantime, ["id"] = iprange_banid })
                iprange_banid = iprange_banid + 1
                execute_command("sv_ban " .. resolveplayer(players[i]))
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {reason}", command, executor)
    end
end

function Command_Suspend(executor, command, PlayerIndex, time, count)
    local players = getvalidplayers(PlayerIndex, executor)
    if players then
        for i = 1, #players do
            if suspend_table[getip(players[i])] == nil then
                local m_player = getplayer(players[i])
                local player_respawn_time = read_dword(m_player + 0x2c)
                if count == 2 then
                    kill(players[i])
                    write_dword(m_player + 0x2C, 2592000)
                    suspend_table[getip(players[i])] = 2
                    sendresponse(getname(players[i]) .. " was suspended by an admin", command, executor)
                elseif count == 3 then
                    kill(players[i])
                    write_dword(m_player + 0x2C, time * 30)
                    suspend_table[getip(players[i])] = 1
                    if tonumber(time) == 1 then
                        sendresponse(getname(players[i]) .. " was suspended by an admin for " .. time .. " second", command, executor)
                    else
                        sendresponse(getname(players[i]) .. " was suspended by an admin for " .. time .. " seconds", command, executor)
                    end
                else
                    sendresponse("Invalid Syntax: sv_suspend [player] {time}", command, executor)
                end
            else
                sendresponse(getname(players[i]) .. " has already been suspended.", command, executor)
            end
        end
    else
        sendresponse("Invalid Player", command, executor)
    end
end

function Command_Takeweapons(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                if Noweapons[ip] == nil then
                    Noweapons[ip] = 1
                    local player_object = get_dynamic_player(i)
                    local weaponId = read_dword(player_object + 0x118)
                    if weaponId ~= 0 then
                        for j = 0, 3 do
                            local m_weapon = read_dword(player_object + 0x2F8 + j * 4)
                            destroy_object(m_weapon)
                        end
                    end
                    sendresponse(getname(players[i]) .. " now has no weapons", command, executor)
                else
                    sendresponse(getname(players[i]) .. " already has no weapons", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_TbagDetection(executor, command, boolean, count)
    if count == 1 then
        if tbag_detection then
            sendresponse("Tbag Detection is currently on", command, executor)
        else
            sendresponse("Tbag Detection is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and tbag_detection ~= true then
            tbag_detection = true
            sendresponse("Tbag Detection is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and tbag_detection == true then
            sendresponse("Tbag Detection is already enabled", command, executor)
        elseif (boolean ~= "0" and boolean ~= "false") then
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        elseif (boolean == "0" or boolean == "false") and tbag_detection ~= false then
            tbag_detection = false
            sendresponse("Tbag Detection is now disabled", command, executor)
        elseif tbag_detection == nil then
            tbag_detection = true
            sendresponse("Tbag Detection is now enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and tbag_detection == false then
            sendresponse("Tbag Detection is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_TeleportDelete(executor, command, location, count)
    if count == 3 then
        tostring(location)
        local response = execute_command("sv_teleport_del " .. location, true)
        sendresponse(tostring(response[1]), command, executor)
    else
        sendresponse("Invalid Syntax: " .. command .. " [ID]", command, executor)
    end
end

function Command_Teleport(executor, command, PlayerIndex, location, y, z, count)
    if count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local response = execute_command("sv_teleport " .. resolveplayer(players[i]) .. " " .. location, true)
                if string.find(response[1], "valid") then
                    sendresponse("Location '" .. tostring(location) .. "' does not exist for this map", command, executor)
                else
                    sendresponse("Teleporting " .. getname(players[i]) .. " to location '" .. location .. "'", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    elseif count == 5 then
        location = tonumber(t[3])
        y = tonumber(t[4])
        z = tonumber(t[5])
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local response = execute_command("sv_teleport " .. resolveplayer(players[i]) .. " " .. location .. " " .. y .. " " .. z, true)
                if string.find(response[1], "valid") then
                    sendresponse("Location '" .. tostring(location) .. "' does not exist for this map", command, executor)
                else
                    sendresponse("Teleporting " .. getname(players[i]) .. " to location '" .. location .. "'", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [location] or [x] [y] [z]", command, executor)
    end
end

function Command_Test(executor, command, arg1, arg2, arg3, arg4, count)
    if count == 1 then
        cprint("arguments: " .. tostring(count), 2 + 8)
    elseif count == 2 then
        cprint("arguments: " .. tostring(count), 2 + 8)
    elseif count == 3 then
        cprint("arguments: " .. tostring(count), 2 + 8)
    elseif count == 4 then
        cprint("arguments: " .. tostring(count), 2 + 8)
    elseif count == 5 then
        cprint("arguments: " .. tostring(count), 2 + 8)
    else
        cprint("arguments: " .. tostring(count), 2 + 8)
    end
end

function Command_Textban(executor, command, PlayerIndex, time, message, count)
    if count >= 2 and count <= 4 then
        local textbantime = wordtotime(time)
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            local name = "the Server"
            if executor ~= nil then
                name = getname(executor)
            end
            for i = 1, #players do
                local name = getname(players[i])
                local ip = getip(players[i])
                local hash = gethash(players[i])
                if admin_table[hash] or ipadmins[ip] then
                    sendresponse("Admins cannot be banned from the chat.", command, executor)
                else
                    local bool = true
                    for k, v in pairs(mute_banlist) do
                        for key, value in pairs(mute_banlist[k]) do
                            if mute_banlist[k][key].ip == ip or mute_banlist[k][key].hash == hash then
                                bool = false
                                sendresponse(name .. " is already textbanned", command, executor)
                                break
                            end
                        end
                        if not bool then
                            break
                        end
                    end
                    if bool then
                        message = tostring(message) or "None Given"
                        BanReason(getname(players[i]) .. " was text banned by " .. name .. " Reason: " .. message)
                        say(getname(players[i]) .. " was text banned by " .. name .. " Reason: " .. message)
                        mute_banlist[ip] = { }
                        table.insert(mute_banlist[ip], { ["name"] = name, ["hash"] = hash, ["ip"] = ip, ["time"] = textbantime, ["id"] = textbanid })
                        textbanid = textbanid + 1
                        local msg = ""
                        if textbantime == -1 then
                            msg = name .. " has been banned from the chat indefinitely"
                        else
                            msg = name .. " has been banned from the chat for " .. time .. ""
                        end
                        sendresponse(msg, command, executor)
                        cprint(msg)
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] {time} {reason}", command, executor)
    end
end

function Command_Textbanlist(executor, command, count)
    if count == 1 then
        local response = "[ID   |   Name   |   Time Left ]\n"
        local response_table = { }
        for k, v in pairs(mute_banlist) do
            for key, value in ipairs(mute_banlist[k]) do
                local time = timetoword(mute_banlist[k][key].time)
                response_table[tonumber(mute_banlist[k][key].id)] = mute_banlist[k][key].name .. "  |  " .. time .. "\n"
            end
        end
        for i = 0, textbanid do
            if response_table[i] then
                response = response .. "" .. i .. "  |  " .. response_table[i]
            end
        end
        sendresponse(response, command, executor)
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_Textunban(executor, command, ID, count)
    if count == 2 and tonumber(ID) then
        ID = tonumber(ID)
        local response = "Invalid ID"
        if ID <= textbanid then
            local bool = false
            for k, v in pairs(mute_banlist) do
                if mute_banlist[k] ~= { } then
                    for key, value in ipairs(mute_banlist[k]) do
                        if mute_banlist[k][key].id == ID then
                            bool = true
                            response = mute_banlist[k][key].name .. " has been untextbanned"
                            table.remove(mute_banlist[k], key)
                            break
                        end
                    end
                end
                if bool then
                    break
                end
            end
            sendresponse(response, command, executor)
        else
            sendresponse(response, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [ID]", command, executor)
    end
end

function Command_Teletoplayer(executor, command, PlayerIndex, player2, count)
    if count == 3 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local name = getname(players[i])
                local player_object = get_dynamic_player(players[i])
                if player_object then
                    local players2 = getvalidplayers(player2, executor)
                    if players2 then
                        local player_object_2 = get_dynamic_player(players2[1])
                        if player_object_2 then
                            if players2[2] == nil and players[i] ~= players2[1] then
                                local t_name = getname(players2[1])
                                local x, y, z = read_vector3d(player_object_2 + 0x5C)
                                if isinvehicle(executor) then
                                    local vehicleId = read_dword(player_object + 0x11C)
                                    moveobject(vehicleId, x, y + 1.6, z + 0.5)
                                    sendresponse(name .. " was teleported to " .. t_name, command, executor)
                                else
                                    write_vector3d(player_object + 0x5C, x, y + 1.5, z)
                                    sendresponse(name .. " was teleported to " .. t_name, command, executor)
                                end
                            end
                        else
                            sendresponse("The player you are trying to teleport to is dead", command, executor)
                        end
                    else
                        sendresponse("Invalid Player", command, executor)
                    end
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player] [player]", command, executor)
    end
end

function Command_Timelimit(executor, command, time, count)
    if count == 1 then
        local time_passed = read_dword(read_dword(gametime_base) + 0xC) / 1800
        local timelimit = read_dword(gametype_base + 0x78) / 1800
        local time_left = timelimit - time_passed
        local Timelimit = read_dword(timelimit_address)
        sendresponse("Current Timelimit is " .. round(timelimit) .. " minutes. Time remaining: " .. tostring(round(time_left, 0)) .. " minutes.", command, executor)
    elseif count == 2 and tonumber(time) then
        settimelimit(time)
        sendresponse("Timelimit set to " .. time .. " minutes", command, executor)
    else
        sendresponse("Invalid Syntax: " .. command .. " {time}", command, executor)
    end
end

function Command_Unban(executor, command, id, count)
    if count == 2 and tonumber(id) then
        local response = execute_command("sv_unban " .. tonumber(id), true)
        if response then
            if string.find(response[1], "Unbanning") then
                sendresponse(response[1], command, executor)
            else
                sendresponse("That ID has not been banned.", command, executor)
            end
        else
            sendresponse("An unknown error has occured getting the reply from execute_command.", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [Banlist ID]", command, executor)
    end
end

function Command_Unbos(executor, command, ID, count)
    if count == 2 then
        local entry = boslog_table[tonumber(ID)]
        local words = { }
        if entry == nil then
            sendresponse("Invalid Entry", command, executor)
        else
            local words = tokenizestring(entry, ",")
            local count = #words
            sendresponse("Removing " .. words[1] .. " - " .. words[2] .. " from BoS.", command, executor)
            table.remove(boslog_table, tonumber(ID))
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [entry]", command, executor)
    end
end

function Command_Ungod(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local m_playerObjId = get_dynamic_player(executor)
        if m_playerObjId then
            local m_object = getobject(m_playerObjId)
            if m_object then
                local ip = getip(executor)
                if gods[ip] then
                    write_float(m_object + 0xE0, 1)
                    write_float(m_object + 0xE4, 1)
                    sendresponse("You are no longer in godmode.", command, executor, command, executor)
                    gods[ip] = nil
                else
                    sendresponse("You are not in godmode", command, executor)
                end
            else
                sendresponse("You are dead", command, executor)
            end
        else
            sendresponse("You are dead", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server is always god", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_playerObjId = get_dynamic_player(players[i])
                if m_playerObjId then
                    local m_object = getobject(m_playerObjId)
                    if m_object then
                        local ip = getip(players[i])
                        if gods[ip] then
                            write_float(m_object + 0xE0, 1)
                            write_float(m_object + 0xE4, 1)
                            gods[ip] = nil
                            sendresponse(getname(players[i]) .. " is no longer in godmode", command, executor)
                        else
                            sendresponse(getname(players[i]) .. " is not in godmode", command, executor)
                        end
                    else
                        sendresponse("The selected player is dead", command, executor)
                    end
                else
                    sendresponse("The selected player is dead", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Unhax(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_player = getplayer(players[i])
                setscore(players[i], 0)
                write_word(m_player + 0x9C, 0)
                write_word(m_player + 0xA4, 0)
                write_word(m_player + 0xAC, 0)
                write_word(m_player + 0xAE, 0)
                write_word(m_player + 0xB0, 0)
                sendresponse(getname(players[i]) .. " has been unhaxed", command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Unhide(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local id = resolveplayer(executor)
        if id ~= nil then
            if hidden[id] then
                sendresponse("You are no longer hidden", command, executor)
                hidden[id] = nil
            else
                sendresponse("You are not hidden", command, executor)
            end
        else
            sendresponse("The server cannot unhide itself", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server is always hidden", command, executor)
    elseif count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local id = resolveplayer(players[i])
                if hidden[id] then
                    sendresponse(getname(players[i]) .. " is no longer hidden", command, executor)
                    hidden[id] = nil
                else
                    sendresponse(getname(players[i]) .. " was never hidden", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {player}", command, executor)
    end
end

function Command_Uninvis(executor, command, PlayerIndex, count)
    if count == 1 and executor ~= nil then
        local ip = getip(executor)
        if ghost_table[ip] == nil then
            sendresponse("You are not invisible", command, executor)
        else
            ghost_table[ip] = nil
            sendresponse("You are no longer invisible", command, executor)
        end
    elseif count == 1 and executor == nil then
        sendresponse("The server is always invisible", command, executor)
    elseif count == 2 and tonumber(command) == nil then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                if ghost_table[ip] == nil then
                    sendresponse(getname(players[i]) .. " is not invisible", command, executor)
                else
                    ghost_table[ip] = nil
                    sendresponse(getname(players[i]) .. " is no longer invisible", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Unmute(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local ip = getip(players[i])
                if mute_table[ip] or spam_table[ip] ~= 0 then
                    mute_table[ip] = nil
                    spamtimeout_table[ip] = nil
                    spam_table[ip] = 0
                    sendresponse(getname(players[i]) .. " has been unmuted", command, executor)
                else
                    sendresponse(getname(players[i]) .. " has not been muted.", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Unsuspend(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                if suspend_table[getip(players[i])] then
                    write_dword(getplayer(players[i]) + 0x2C, 0)
                    sendresponse(getname(players[i]) .. " has been unsuspended", command, executor)
                else
                    sendresponse(getname(players[i]) .. " has not been suspended.", command, executor)
                end
            end
        else
            sendresponse("Invalid Player")
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]")
    end
end

function DelayCleanUpDrones(PlayerIndex, command, executor)
    if getplayer(PlayerIndex) then
        if vehicle_drone_table[PlayerIndex] ~= nil then
            for k, v in pairs(vehicle_drone_table[PlayerIndex]) do
                if vehicle_drone_table[PlayerIndex][k] > 0 then
                    if v then
                        if drone_obj then
                            destroy_object(v)
                        end
                        vehicle_drone_table[PlayerIndex][k] = nil
                    end
                end
            end
            sendresponse("Cleaning up " .. drone_name .. "'s vehicles.", command, executor)
        else
            sendresponse("Nothing to clean up!", command, executor)
        end
    end
end

function Command_Clean(executor, command, PlayerIndex, count)
    if count == 2 then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                drone_name = getname(players[i])
                timer(0, "DelayCleanUpDrones", players[i], command, executor)
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [player]", command, executor)
    end
end

function Command_Versioncheck(executor, command, boolean, count)
    if (boolean == "1" or boolean == "true" or boolean == '"1"' or boolean == '"true"') and version_check ~= true then
        version_check = true
        safe_write(true)
        write_byte(versioncheck_addr, 0x7D)
        safe_write(false)
        sendresponse("Version checking is enabled", command, executor)
    elseif (boolean == "0" or boolean == "false" or boolean == '"0"' or boolean == '"false"') and version_check then
        version_check = false
        safe_write(true)
        write_byte(versioncheck_addr, 0xEB)
        safe_write(false)
        sendresponse("Version checking is disabled", command, executor)
    elseif version_check == nil then
        version_check = false
        safe_write(true)
        write_byte(versioncheck_addr, 0xEB)
        safe_write(false)
        sendresponse("Version checking is disabled", command, executor)
    end
end

function Command_Viewadmins(executor, command, boolean, count)
    if count == 1 then
        sendresponse("The current admins in the server are listed below:", command, executor)
        sendresponse("[Level] Name: [Admin Type]", command, executor)
        local admins = { }
        for i = 1, 16 do
            local m_player = getplayer(i)
            if m_player then
                local hash = gethash(i)
                local name = getname(i)
                if admin_table[hash] then
                    admins[name] = { "hash", "notip", admin_table[hash].level }
                end
                if ipadmins[getip(i)] then
                    if admins[name] and admins[name] ~= { } then
                        admins[name][2] = "ip"
                    else
                        admins[name] = { "nothash", "ip", ipadmins[getip(i)].level }
                    end
                end
            end
        end
        for k, v in pairs(admins) do
            local message = ""
            if admins[k][1] == "hash" and admins[k][2] == "ip" then
                message = "[" .. admins[k][3] .. "] " .. k .. "  :  Hash Admin and IP Admin"
            elseif admins[k][1] == "hash" then
                message = "[" .. admins[k][3] .. "] " .. k .. "  :  Hash Admin"
            elseif admins[k][2] == "ip" then
                message = "[" .. admins[k][3] .. "] " .. k .. "  :  IP Admin"
            end
            sendresponse(message, command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command, command, executor)
    end
end

function Command_VotekickAction(executor, command, action, count)
    if count == 1 then
        sendresponse("The current action for people who are votekicked is '" .. tostring(votekick_action) .. "'", command, executor)
        sendresponse("Valid actions are 'kick' and 'ban'", command, executor)
    elseif count == 2 and (action == "kick" or action == "ban") then
        sendresponse("The current VoteKick action has been changed to '" .. action .. "'", command, executor)
        votekick_action = tostring(action)
    else
        sendresponse("Invalid Syntax: " .. command .. " {action}", command, executor)
    end
end

function Command_VotekickEnabled(executor, command, boolean, count)
    if count == 1 then
        if votekick_allowed then
            sendresponse("VoteKick is currently on", command, executor)
        else
            sendresponse("VoteKick is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and votekick_allowed ~= true then
            votekick_allowed = true
            if rtv_required == nil then
                rtv_required = 0.7
            end
            sendresponse("VoteKick is now enabled The default percentage needed is 70%.", command, executor)
            sendresponse("Change this with sv_votekick_needed", command, executor)
        elseif (boolean == "1" or boolean == "true") and votekick_allowed == true then
            sendresponse("VoteKick is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and votekick_allowed ~= false then
            votekick_allowed = false
            sendresponse("VoteKick is now disabled", command, executor)
        elseif votekick_allowed == nil then
            votekick_allowed = false
            sendresponse("VoteKick is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and votekick_allowed == false then
            sendresponse("VoteKick is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_VotekickRequired(executor, command, percent, count)
    if count == 1 then
        if votekick_required == nil then
            votekick_required = 0.7
        end
        sendresponse(tostring(votekick_required * 100) .. "% votes required for VoteKick", command, executor)
    elseif count == 2 and tonumber(percent) then
        if tonumber(percent) <= 1 then
            sendresponse("Votes required for VoteKick has been set to " .. tonumber(percent) * 100 .. "%", command, executor)
            votekick_required = tonumber(percent)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [votes required (as a decimal)]", command, executor)
    end
end

function Command_WelcomeBackMessage(executor, command, boolean, count)
    if count == 1 then
        if wb_message then
            sendresponse("Welcome Back Message is currently on", command, executor)
        else
            sendresponse("Welcome Back Message is currently off", command, executor)
        end
    elseif count == 2 then
        if (boolean == "1" or boolean == "true") and wb_message ~= true then
            wb_message = true
            sendresponse("Welcome Back Message is now enabled", command, executor)
        elseif (boolean == "1" or boolean == "true") and wb_message == true then
            sendresponse("Welcome Back Message is already enabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and wb_message ~= false then
            wb_message = false
            sendresponse("Welcome Back Message is now disabled", command, executor)
        elseif wb_message == nil then
            wb_message = false
            sendresponse("Welcome Back Message is now disabled", command, executor)
        elseif (boolean == "0" or boolean == "false") and wb_message == false then
            sendresponse("Welcome Back Message is already disabled", command, executor)
        else
            sendresponse("Invalid Boolean: 0 for false, 1 for true", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " {boolean}", command, executor)
    end
end

function Command_Write(executor, command, type, struct, offset, value, PlayerIndex, count)
    local offset = tonumber(offset)
    if count > 4 and count < 7 and tonumber(type) == nil and tonumber(struct) == nil and offset then
        local players = getvalidplayers(PlayerIndex, executor)
        if players then
            for i = 1, #players do
                local m_objectId = get_dynamic_player(players[i])
                if m_objectId then
                    if struct == "PlayerIndex" then
                        struct = getplayer(players[i])
                    elseif struct == "object" then
                        struct = getobject(m_objectId)
                        if struct == nil then
                            sendresponse(getname(players[i]) .. " is not alive.", command, executor)
                            return
                        end
                    elseif getobject(m_objectId) == nil then
                        sendresponse(getname(players[i]) .. " is not alive.", command, executor)
                        return
                    elseif struct == "weapon" then
                        local m_object = getobject(m_objectId)
                        struct = getobject(read_dword(m_object + 0x118))
                        if struct == nil then
                            sendresponse(getname(players[i]) .. " is not holding a weapon", command, executor)
                            return
                        end
                    elseif tonumber(struct) == nil then
                        sendresponse("Invalid Struct. Valid structs are: player, object, and weapon", command, executor)
                        return
                    end
                end
                if value then
                    if type == "byte" then
                        write_byte(struct + offset, value)
                    elseif type == "float" then
                        write_float(struct + offset, value)
                    elseif type == "word" then
                        write_word(struct + offset, value)
                    elseif type == "dword" then
                        write_dword(struct + offset, value)
                    else
                        sendresponse("Invalid Type. Valid types are byte, float, word, and dword", command, executor)
                        return
                    end
                    sendresponse("Writing " .. tostring(value) .. " to struct " .. tostring(struct) .. " at offset " .. tostring(offset) .. " was a success", command, executor)
                end
            end
        else
            sendresponse("Invalid Player", command, executor)
        end
    else
        sendresponse("Invalid Syntax: " .. command .. " [type] [struct] [offset] [value] [player]", command, executor)
    end
end

function AccessMerging()
    for i = 0, #access_table do
        if access_table[i] ~= -1 then
            if string.find(access_table[i], ",sv_kick,") then
                access_table[i] = access_table[i] .. ",sv_k"
            end
            if string.find(access_table[i], ",sv_admin_cur,") then
                access_table[i] = access_table[i] .. ",sv_viewadmins"
            end
            if string.find(access_table[i], ",sv_admin") then
                access_table[i] = access_table[i] .. ",sv_a"
            end
            if string.find(access_table[i], ",sv_setafk,") then
                access_table[i] = access_table[i] .. ",sv_afk"
            end
            if string.find(access_table[i], ",sv_setammo,") then
                access_table[i] = access_table[i] .. ",sv_ammo"
            end
            if string.find(access_table[i], ",sv_ban,") then
                access_table[i] = access_table[i] .. ",sv_b"
            end
            if string.find(access_table[i], ",sv_setinvis,") then
                access_table[i] = access_table[i] .. ",sv_invis"
            end
            if string.find(access_table[i], ",sv_map,") then
                access_table[i] = access_table[i] .. ",sv_m"
            end
            if string.find(access_table[i], ",sv_mapcycle_begin,") then
                access_table[i] = access_table[i] .. ",sv_mc"
            end
            if string.find(access_table[i], ",sv_map_next,") then
                access_table[i] = access_table[i] .. ",sv_mnext"
            end
            if string.find(access_table[i], ",sv_players,") then
                access_table[i] = access_table[i] .. ",sv_pl"
            end
            if string.find(access_table[i], ",sv_map_reset,") then
                access_table[i] = access_table[i] .. ",sv_reset"
            end
            if string.find(access_table[i], ",sv_password,") then
                access_table[i] = access_table[i] .. ",sv_pass"
            end
            if string.find(access_table[i], ",sv_admin_del,") then
                access_table[i] = access_table[i] .. ",sv_revoke"
            end
            if string.find(access_table[i], ",sv_respawn_time,") then
                access_table[i] = access_table[i] .. ",sv_setresp"
            end
            if string.find(access_table[i], ",sv_teleport_add,") then
                access_table[i] = access_table[i] .. ",sv_st"
            end
            if string.find(access_table[i], ",sv_teleport") then
                access_table[i] = access_table[i] .. ",sv_t"
            end
            if string.find(access_table[i], ",sv_changeteam,") then
                access_table[i] = access_table[i] .. ",sv_ts"
            end
            if string.find(access_table[i], ",sv_teleport_pl,") then
                access_table[i] = access_table[i] .. ",sv_tp"
            end
            if string.find(access_table[i], ",sv_control,") then
                access_table[i] = access_table[i] .. ",sv_c"
            end
            if string.find(access_table[i], ",sv_follow,") then
                access_table[i] = access_table[i] .. ",sv_f"
            end
            if string.find(access_table[i], ",sv_cheat_hax,") then
                access_table[i] = access_table[i] .. ",sv_hax"
            end
            if string.find(access_table[i], ",sv_cheat_unhax,") then
                access_table[i] = access_table[i] .. ",sv_unhax"
            end
            if string.find(access_table[i], ",sv_infinite_ammo,") then
                access_table[i] = access_table[i] .. ",sv_infammo"
            end
            if string.find(access_table[i], ",sv_move,") then
                access_table[i] = access_table[i] .. ",sv_j"
            end
            if string.find(access_table[i], ",sv_scrim,") then
                access_table[i] = access_table[i] .. ",sv_lo3"
            end
            if string.find(access_table[i], ",sv_setspeed,") then
                access_table[i] = access_table[i] .. ",sv_spd"
            end
            if string.find(access_table[i], ",sv_time_cur,") then
                access_table[i] = access_table[i] .. ",sv_timelimit"
            end
            if string.find(access_table[i], ",sv_setgod,") and not string.find(access_table[i], ",sv_god,") then
                access_table[i] = access_table[i] .. ",sv_god"
            end
            if access_table[i] ~= -1 then
                if not access_table or not access_table[i] or not access_table[i]:len() then
                    cprint("ACCESS.INI IS INCORRECTLY FORMATTED")
                    return
                end
                if string.sub(access_table[i], access_table[i]:len(), access_table[i]:len()) ~= "," then
                    access_table[i] = access_table[i] .. ","
                end
            end
        end
    end
end

function BanReason(message)
    WriteLog(profilepath .. "commands_BanReasons.log", tostring(message))
end

function cmderrors(message)
    WriteLog(profilepath .. "CommandScriptErrors.log", tostring(message))
end

function cmdlog(message)
    WriteLog(profilepath .. "command_logs.log", tostring(message))
end

function checkaccess(Command, access, PlayerIndex, type)
    if Command and tonumber(access) >= 0 then
        local command_list = access_table[tonumber(access)]
        local command = Command:gsub("/", "sv_")
        if command_list == -1 or command_list == "data=-1" then
            return true
        else
            local found = command_list:find("," .. command .. ",")
            if found then
                return true
            end
        end
    else
        cprint("Missing command")
    end
    return false
end

function CheckAccess(executor, command, PlayerIndex, access, type)
    if tonumber(PlayerIndex) and admin_blocker > 0 and command and tonumber(access) then
        local access_player = getaccess(tonumber(PlayerIndex))
        if access_player then
            local Command = getvalidformat(command)
            for i = 0, #command_access do
                if Command == command_access[i] then
                    if admin_blocker == 1 and access > access_player then
                        return false
                    elseif admin_blocker == 2 and access >= access_player then
                        return false
                    elseif admin_blocker == 3 and access_table[tonumber(access)] == -1 then
                        return false
                    end
                end
            end
        end
    end
    return true
end

function inSphere(PlayerIndex, x, y, z, radius)
    if PlayerIndex then
        local player_static = get_player(PlayerIndex)
        local obj_x = read_float(player_static + 0xF8)
        local obj_y = read_float(player_static + 0xFC)
        local obj_z = read_float(player_static + 0x100)
        local x_diff = x - obj_x
        local y_diff = y - obj_y
        local z_diff = z - obj_z
        local dist_from_center = math.sqrt(x_diff ^ 2 + y_diff ^ 2 + z_diff ^ 2)
        if dist_from_center <= radius then
            return true
        end
    end
    return false
end

function check_sphere(m_objectId, X, Y, Z, R)
    local Pass = false
    if getobject(m_objectId) then
        local x, y, z = getobjectcoords(m_objectId)
        if (X - x) ^ 2 + (Y - y) ^ 2 + (Z - z) ^ 2 <= R then
            Pass = true
        end
    end
    return Pass
end

function cleanupdrones(PlayerIndex)
    if vehicle_drone_table[PlayerIndex] then
        for k, v in pairs(vehicle_drone_table[PlayerIndex]) do
            if v then
                if drone_obj then
                    destroy_object(v)
                end
            end
            vehicle_drone_table[PlayerIndex][k] = nil
        end
    end
end

function DefaultSvTimer()
    local defaults_lines = #default_commands
    local temp_lines = 0
    local temp_commands_executed = { }
    local file = io.open(profilepath .. 'commands_defaults.txt', "r")
    if file then
        for i = 0, defaults_lines + 1 do
            if default_commands[i] then
                execute_command(default_commands[i])
            end
        end
        file:close()
        temp_lines = defaults_lines
    else
        local file = io.open(profilepath .. 'commands_defaults.txt', "w")
        cprint("Defaults.txt not found. File will be created.", 4 + 8)
        for i = 0, defaults_lines + 1 do
            if default_commands[i] then
                execute_command(default_commands[i])
                file:write(default_commands[i] .. "\n")
            end
        end
        file:close()
        temp_lines = defaults_lines
    end
    if not changelog then
        cprint("Change log Version " .. script_version .. " is being written")
    end
    if access_error then
        cprint("access.ini is not setup correctly", 4 + 8)
    end
    if use_logo then
        cprint("===================================================================================================", 2 + 8)
        cprint("")
        cprint("          ..|'''.|                                                     '||         ", 4 + 8)
        cprint("          .|'     '    ...   .. .. ..   .. .. ..    ....   .. ...      .. ||   ....  ", 4 + 8)
        cprint("          ||         .|  '|.  || || ||   || || ||  '' .||   ||  ||   .'  '||  ||. '  ", 4 + 8)
        cprint("          '|.      . ||   ||  || || ||   || || ||  .|' ||   ||  ||   |.   ||  . '|.. ", 4 + 8)
        cprint("          ''|....'   '|..|' .|| || ||. .|| || ||. '|..'|' .||. ||.  '|..'||. |'..|' ", 4 + 8)
        cprint("                      ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-")
        cprint("                            Commands Script Version " .. script_version .. " for SAPP 10.0")
        cprint("                      ->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-<->-")
        cprint("")
        cprint("===================================================================================================", 2 + 8)
    end
    -- timer(0, "deleteadmins")
    return false
end

function DelayEject(id, count, PlayerIndex)
    exit_vehicle(PlayerIndex)
    return false
end

function deleteadmins(id, count)
    local file = io.open(profilepath .. 'commands_admin.txt', "r")
    if file then
        local file2 = io.open(profilepath .. "commands_old-admin.txt", "w")
        for line in file:lines() do
            words = tokenizestring(line, ",")
            execute_command("sv_admin_del " .. words[3])
            file2:write(line)
        end
        file2:close()
        file:close()
        os.remove(profilepath .. 'commands_admin.txt')
    end
    return false
end

function endian(address, offset, length)
    local data_table = { }
    local data = ""
    for i = 0, length do
        local hex = string.format("%X", read_byte(address + offset + i))
        if tonumber(hex, 16) < 16 then
            hex = 0 .. hex
        end
        table.insert(data_table, hex)
    end
    for k, v in pairs(data_table) do
        data = v .. data
    end
    return data
end

function FollowTimer(id, count, arguments)
    local PlayerIndex = arguments[1]
    local player2 = arguments[2]
    if getplayer(PlayerIndex) and getplayer(player2) then
        local m_objectId = get_dynamic_player(PlayerIndex)
        local m_playerObjId = get_dynamic_player(player2)
        if m_objectId and m_playerObjId then
            if getplayer(PlayerIndex) and getobject(m_objectId) then
                if getplayer(player2) and getobject(m_playerObjId) then
                    local m_object = getobject(m_playerObjId)
                    local m_Object = getobject(m_objectId)
                    if x == nil then
                        x, y, z = getobjectcoords(m_playerObjId)
                        movobjectcoords(m_objectId, x, y, z + 0.5)
                    end
                    local obj_x_vel = read_float(m_object + 0x68)
                    local obj_y_vel = read_float(m_object + 0x6C)
                    local obj_z_vel = read_float(m_object + 0x70)
                    write_float(m_Object + 0x68, obj_x_vel)
                    write_float(m_Object + 0x6C, obj_y_vel)
                    write_float(m_Object + 0x70, obj_z_vel)
                elseif getplayer(player2) then
                    x, y, z = nil
                else
                    local id = resolveplayer(PlayerIndex)
                    follow[id] = nil
                    return false
                end
            end
        end
    else
        return false
    end
    return true
end

function getaccess(PlayerIndex, Environment)
    if PlayerIndex and getplayer(PlayerIndex) then
        local hash = gethash(PlayerIndex)
        local ip = getip(PlayerIndex)
        local hash2
        local ip2
        if players_list[PlayerIndex] then
            hash2 = players_list[PlayerIndex].hash
            ip2 = players_list[PlayerIndex].ip
        end
        if hash and ip then
            if admin_table[hash] then
                return tonumber(admin_table[hash].level)
            elseif ipadmins[ip] then
                return tonumber(ipadmins[ip].level)
            elseif temp_admins[ip] then
                return 0
            end
        elseif hash2 and ip2 then
            if admin_table[hash2] then
                return tonumber(admin_table[hash2].level)
            elseif ipadmins[ip2] then
                return tonumber(ipadmins[ip2].level)
            end
        end
    end
    return
end

function GetGameAddresses()
    if halo_type == "PC" then
        -- oddball_globals = 0x639E18
        -- specs_addr = 0x662D04
        --hashcheck_addr = 0x59c280
        -- versioncheck_addr = 0x5152E7
        -- map_pointer = 0x63525c
        -- gametype_base = 0x671340
        -- gametime_base = 0x671420
        -- machine_pointer = 0x745BA0
        -- timelimit_address = 0x626630
        -- special_chars = 0x517D6B
        -- gametype_patch = 0x481F3C
        -- devmode_patch1 = 0x4A4DBF
        -- devmode_patch2 = 0x4A4E7F
        -- hash_duplicate_patch = 0x59C516
        -- obj_header_pointer = 0x744C18
    else
        --oddball_globals = 0x5BDEB8
        --specs_addr = 0x5E6E63
        --hashcheck_addr = 0x530130
        --obj_header_pointer = 0x6C69F0
        --versioncheck_addr = 0x4CB587
        --map_pointer = 0x5B927C
        --gametype_base = 0x5F5498
        -- gametime_base = 0x5F55BC
        -- machine_pointer = 0x6C7980
        -- timelimit_address = 0x5AA5B0
        -- special_chars = 0x4CE0CD
        -- gametype_patch = 0x45E50C
        -- devmode_patch1 = 0x47DF0C
        -- devmode_patch2 = 0x47DFBC
        -- hash_duplicate_patch = 0x5302E6
    end
end

function GetHelp(command)
    local response = ""
    if command == "sv_admin_add" or command == "sv_a" then
        response = "-- Admin Add\n-- Syntax: sv_admin_add [player or hash] [nickname] [level]\n-- Add's a player to the admin list via player number"
    elseif command == "sv_admin_del" then
        response = "-- Admin Delete\n-- Syntax: sv_admin_del [ID]\n-- Remove Admin\n"
    elseif command == "sv_revoke" then
        response = "-- Admin Revoke \n-- Syntax: sv_revoke [player]\n-- Remove admin via Hash and IP\n"
    elseif command == "sv_ipadminadd" or command == "sv_ipadminadd" then
        response = "-- IP Admin Add\n-- Syntax: sv_ipadminadd [player] [nickname] [level]\n-- Add admin via there IP instead of their hash."
    elseif command == "sv_ipadmindel" or command == "sv_ipadmindel" then
        response = "-- IP Admin Delete\n-- Syntax: sv_ipadmindel [ID]\n-- Delete the selected IP admin from the admin list."
    elseif command == "sv_admin_list" or command == "sv_adminlist" then
        response = "-- Admin List\n-- Syntax: sv_admin_list\n-- Shows a list of all Admins"
    elseif command == "sv_viewadmins" then
        response = "-- Viewadmins\n-- Syntax: sv_viewadmins\n-- Shows Current Admins in the Server"
    elseif command == "sv_alias" then
        response = "-- Alias\n-- Syntax: sv_alias [player]\n-- Shows all names used with the hash"
    elseif command == "sv_map" then
        response = "-- Map Command\n-- Syntax: sv_map [map] [gametype] commands {script2} {script3}"
    elseif command == "sv_mc" then
        response = "-- Start MapCycle\n-- Syntax: sv_mc\n-- Shortcut for sv_mapcycle_begin"
    elseif command == "sv_mnext" then
        response = "-- Map Next\n-- Syntax: sv_mnext\n-- Shortcut for sv_map_next"
    elseif command == "sv_time_cur" then
        response = "-- Current Time\n-- Syntax: sv_time_cur {time}\n-- Displays remaining time in the match, and change the remaining time in the match"
    elseif command == "sv_reset" or command == "sv_mapreset" then
        response = "-- Map Reset\n-- Syntax: sv_reset\n-- Shortcut for sv_map_reset"
    elseif command == "sv_respawn_time" then
        response = "-- Respawn Time for Server\n-- Syntax: sv_respawn_time [time]\n-- Change the server's respawn time"
    elseif command == "sv_rtv_enabled" then
        response = "-- RTV Boolean\n-- Syntax: sv_rtv_enabled [boolean]\n-- Enable or disable RTV"
    elseif command == "sv_rtv_needed" then
        response = "-- RTV Needed\n-- Syntax: sv_rtv_needed [decimal 0 to 1]\n-- Change the number of votes needed for RTV to change the map."
    elseif command == "sv_specs" then
        response = "-- Specs\n-- Syntax: sv_specs\n-- Display the server specs (like processor, RAM, model, etc)"
    elseif command == "sv_votekick_enabled" then
        response = "-- VoteKick Boolean\n-- Syntax: sv_votekick_enabled [boolean]\n-- Allow you to enable or disable votekick, Boolean can be 0, false, 1, or true"
    elseif command == "sv_votekick_needed" then
        response = "-- Vote Kick Needed\n-- Syntax: sv_votekick_needed [decimal 0 to 1]\n-- Allow you to change the number of votes needed for VoteKick to kick the PlayerIndex."
    elseif command == "sv_votekick_action" then
        response = "-- Vote Kick Action\n-- Syntax: sv_votekick_action [kick/ban]\n-- Allows you to either ban or kick the PlayerIndex that has been voted out."
    elseif command == "sv_bos" then
        response = "-- Ban on Sight\n-- Syntax: sv_bos [PlayerIndex]\n-- Add the specified PlayerIndex to the Ban On Sight list."
    elseif command == "sv_boslist" then
        response = "-- Ban on Sight List\n-- Syntax: sv_boslist\n-- Display the Ban On Sight list"
    elseif command == "sv_unbos" then
        response = "-- Remove from Ban on Sight List\n-- Syntax: sv_unbos [ID]\n-- Remove selected index off of the ban on sight list"
    elseif command == "sv_cl" or command == "sv_change_level" then
        response = "-- Change Level Command\n-- Syntax: sv_change_level [nickname] {level}\n-- Change the specified admins' level"
    elseif command == "sv_ts" or command == "sv_changeteam" then
        response = "-- Change team Command\n-- Syntax: sv_changeteam [PlayerIndex]\n-- Change the specified players team"
    elseif command == "sv_ipban" then
        response = "-- IP Ban\n-- Syntax: sv_ipban [PlayerIndex or ip] {time} {message}\n-- Ban the specified PlayerIndex via their IP, not their hash"
    elseif command == "sv_ipbanlist" then
        response = "-- IP Ban List\n-- Syntax: sv_ipbanlist\n-- Display the IP banlist"
    elseif command == "sv_ipunban" then
        response = "-- IP Unban\n-- Syntax: sv_ipunban [ID]\n-- Remove selected index off of the IP banlist"
    elseif command == "sv_superban" then
        response = "-- Superban\n-- Syntax: sv_superban [PlayerIndex] {time} {message}\n-- Ban the selected player via hash and IP"
    elseif command == "sv_falldamage" then
        response = "-- Fall Damage\n-- Syntax: sv_falldamage [boolean]\n-- Enable/Disable the damage players receive from falling."
    elseif command == "sv_firstjoin_message" then
        response = "-- First Join Message\n-- Syntax: sv_firstjoin_message [boolean]\n-- Enable/Disable the First Join Message. So the message the very first time they join the server."
    elseif command == "sv_gethash" then
        response = "-- Get Hash\n-- Syntax: sv_gethash [PlayerIndex]\n-- Get the specified PlayerIndex's hash"
    elseif command == "sv_getip" then
        response = "-- Get IP\n-- Syntax: sv_getip [PlayerIndex]\n-- Get the specified playersIP address"
    elseif command == "sv_info" then
        response = "-- Info\n-- Syntax: sv_info [PlayerIndex]\n-- Returns a lot of info of the specified PlayerIndex"
    elseif command == "sv_deathless" then
        response = "-- Deathless\n-- Syntax: sv_deathless [boolean]\n-- Enable/Disable Deathless Player Mode.\n-- Boolean can be true or 1 for on, and false or 0 for off"
    elseif command == "sv_setafk" then
        response = "-- Set AFK\n-- Syntax: sv_setafk [PlayerIndex]\n-- Set the PlayerIndex to be AFK."
    elseif command == "sv_textban" then
        response = "-- Text Ban\n-- Syntax: sv_textban [PlayerIndex] {time} {message}\n-- Ban the specified people from the chat permanently"
    elseif command == "sv_textbanlist" then
        response = "-- Text Banlist\n-- Syntax: sv_textbanlist\n-- Display the text banlist"
    elseif command == "sv_textunban" then
        response = "-- Text Unban\n-- Syntax: sv_textunban [ID]\n--  Remove selected index off of the text banlist"
    elseif command == "sv_mute" then
        response = "-- Mute\n-- Syntax: sv_mute [PlayerIndex]\n-- Mute the specified players(For the match only). Admins cannot be muted"
    elseif command == "sv_unmute" then
        response = "-- Unmute\n-- Syntax: sv_unmute [PlayerIndex]\n-- Unmute the specified PlayerIndex."
    elseif command == "sv_getloc" then
        response = "-- Get Location\n-- Syntax: sv_getloc [PlayerIndex]\n-- Get the specified players' coordinates in the server"
    elseif command == "sv_lo3" or command == "sv_scrim" then
        response = "-- Live on Three \n-- Syntax: sv_scrim\n-- This command will reset the map 3 times"
    elseif command == "sv_say" then
        response = "-- Say\n-- Syntax: sv_say [message]\n-- This will allow you to s a message as the server"
    elseif command == "sv_infammo" or command == "sv_infinite_ammo" then
        response = "-- Infinite Ammo \n-- Syntax: sv_infinite_ammo [boolean]\n-- Enable or disable infinite ammo mode"
    elseif command == "sv_crash" then
        response = "-- Crash\n-- Syntax: sv_crash [PlayerIndex]\n-- This command will crash the players halo, This will not affect the server"
    elseif command == "sv_control" then
        response = "-- Control\n-- Syntax: sv_control [player_1] [player_2]\n-- Allows you to control a PlayerIndex. [player_2] is the PlayerIndex being controlled"
    elseif command == "sv_count" then
        response = "-- Count\n-- Syntax: sv_count\n-- It will display the number of unique users."
    elseif command == "sv_uniques_enabled" then
        response = "-- Unique Counting\n-- Syntax: sv_uniques_enabled \n-- Enables/Disables the Unique Counting feature."
    elseif command == "sv_eject" then
        response = "-- Eject\n-- Syntax: sv_eject [PlayerIndex]\n-- Force the specified players to exit their vehicle"
    elseif command == "sv_follow" then
        response = "-- Follow\n-- Syntax: sv_follow [PlayerIndex]\n-- Allows you to follow the specified PlayerIndex"
    elseif command == "sv_setgod" then
        response = "-- Set God\n-- Syntax: sv_setgod [PlayerIndex]\n-- Gives you a lot of health"
    elseif command == "sv_hax" or command == "sv_cheat_hax" then
        response = "-- Cheat Hax\n-- Syntax: sv_cheat_hax [PlayerIndex]\n-- Secret"
    elseif command == "sv_unhax" or command == "sv_cheat_unhax" then
        response = "-- Cheat Unhax\n-- Syntax: sv_cheat_unhax [PlayerIndex]\n-- Secret"
    elseif command == "sv_heal" then
        response = "-- Heal\n-- Syntax: sv_heal [PlayerIndex]\n-- Heal the specified players"
    elseif command == "sv_help" then
        response = "-- Help\n-- Syntax: sv_help [command]\n-- If you type a correct command, it will display its syntax and its function."
    elseif command == "sv_hide" then
        response = "-- Hide\n-- Syntax: sv_hide [PlayerIndex]\n-- You are invisible. Not Camo."
    elseif command == "sv_hitler" then
        response = "-- Hitler\n-- Syntax: sv_hitler [PlayerIndex]\n-- A letha injection is given to the specified PlayerIndex."
    elseif command == "sv_invis" then
        response = "-- Invis\n-- Syntax: sv_invis [PlayerIndex] {time}\n-- Give the specified PlayerIndex an invis/camo"
    elseif command == "sv_kill" then
        response = "-- Kill\n-- Syntax: sv_kill [PlayerIndex]\n-- Kills the Player."
    elseif command == "sv_killingspree" or command == "sv_killspree" then
        response = "-- Killing Spree Detection\n-- Syntax: sv_killspree [boolean]\n-- Enable/Disable Killing Spree Notifications"
    elseif command == "sv_launch" then
        response = "-- Launch\n-- Syntax: sv_launch [PlayerIndex]\n-- Launches the person in a random direction."
    elseif command == "sv_move" then
        response = "-- Move\n-- Syntax: sv_move [PlayerIndex] [x] [y] [z]\n-- Move the PlayerIndex by the set number of coords."
    elseif command == "sv_nameban" then
        response = "-- Name Ban\n-- Syntax: sv_nameban [PlayerIndex]\n-- Ban a person via their name"
    elseif command == "sv_namebanlist" then
        response = "-- Name Ban List\n-- Syntax: sv_namebanlist\n-- Lists the names banned"
    elseif command == "sv_nameunban" then
        response = "-- Name Unban\n-- Syntax: sv_nameunban [ID]\n--  Remove selected index off of the Name banlist"
    elseif command == "sv_noweapons" then
        response = "-- No Weapons\n-- Syntax: sv_noweapons [boolean]\n-- Enable/disable the use of weapons in a server."
    elseif command == "sv_os" then
        response = "-- OverShield\n-- Syntax: sv_os [PlayerIndex]\n-- Give specified players an overshield(os)"
    elseif command == "sv_privatemessaging" or command == "sv_pvtmessage" then
        response = "-- Private Messaging\n-- Syntax: sv_pvtmessage [boolean]\n-- Enable/Disable Private Messaging"
    elseif command == "sv_resetweapons" then
        response = "-- Reset Weapons\n-- Syntax: sv_resetweapons [PlayerIndex]\n-- Reset the weapons of the specified players"
    elseif command == "sv_serveradmin_message" then
        response = "-- Server Admin Message\n-- Syntax: sv_serveradmin_message [boolean]\n-- Enable/Disable Server Admin Message"
    elseif command == "sv_enter" then
        response = "-- Enter\n-- Syntax: sv_enter [vehicle] [PlayerIndex]\n-- Force specified PlayerIndex into specified vehicle"
    elseif command == "sv_spawn" then
        response = "-- Spawn\n-- Syntax: sv_spawn [object] [PlayerIndex]\n-- Spawns specified object near specified PlayerIndex"
    elseif command == "sv_give" then
        response = "-- Give\n-- Syntax: sv_give [object] [PlayerIndex]\n-- Gives specified PlayerIndex the specified weapon"
    elseif command == "sv_setammo" then
        response = "-- Set Ammo\n-- Syntax: sv_setammo [PlayerIndex] [type] [ammo]\n-- Set the ammo of the players specified\n-- Mode means type of ammo, use 1 for unloaded ammo and 2 for loaded ammo"
    elseif command == "sv_" then
        response = "-- Set Assists\n-- Syntax: sv_setassists [PlayerIndex] [assists]\n-- Set the assists for the specified players"
    elseif command == "sv_setcolor" then
        response = "-- Set Color\n-- Syntax: sv_setcolor [PlayerIndex] [color]\n-- Change the color of the selected player. Works on FFA Only"
    elseif command == "sv_setdeaths" then
        response = "-- Set Deaths\n-- Syntax: sv_setdeaths [PlayerIndex] [deaths]\n-- Set the deaths for the specified players"
    elseif command == "sv_setfrags" then
        response = "-- Set Frags\n-- Syntax: sv_setfrags [PlayerIndex] [frags]\n-- Set the frags for the specified players"
    elseif command == "sv_setmode" then
        response = "-- Mode\n-- Syntax: sv_setmode [PlayerIndex] [mode] {object(for spawngun)}\n-- Set the PlayerIndex into the specified mode, There are 4 modes. They are listed here:\n-- Portalgun\n-- Entergun\n-- Destroy, be very careful with this mode.\n-- Spawngun\n-- To turn your modes off, just do /setmode [PlayerIndex] none."
    elseif command == "sv_setscore" then
        response = "-- Set Score\n-- Syntax: sv_setscore [PlayerIndex] [score]\n-- Set the score for the specified players"
    elseif command == "sv_setplasmas" then
        response = "-- Set Plasmas\n-- Syntax: sv_setplasmas [PlayerIndex] [plasmas]\n-- Set the plasmas for the specified players"
    elseif command == "sv_spd" or command == "sv_setspeed" then
        response = "-- Set Speed\n-- Syntax: sv_setspeed [PlayerIndex] {speed}\n-- Allow you to view the selected players speed and it will allow you to change it if you want"
    elseif command == "sv_pass" then
        response = "-- Password\n-- Syntax: sv_pass {password}\n-- Shortcut to change the server password."
    elseif command == "sv_resp" then
        response = "-- Respawn Time for Player\n-- Syntax: sv_resp [PlayerIndex] [time]\n-- Set the respawn time for the PlayerIndex (they must be dead)."
    elseif command == "sv_tbagdet" or command == "tbag" then
        response = "-- Tbag Detection\n-- Syntax: sv_tbagdet [boolean]\n-- Enable/Disable Tbagging"
    elseif command == "sv_tp" or command == "sv_teleport_pl" then
        response = "-- Teleport to Player\n-- Syntax: sv_teleport_pl [player_1] [player_2]\n-- Teleport player_1 to player_2"
    elseif command == "sv_suspend" then
        response = "-- Suspend\n-- Syntax: sv_suspend [PlayerIndex] {time}\n-- Suspend the specified players indefinitely, or for the specified time, \nby suspendingthat means they will not spawn"
    elseif command == "sv_takeweapons" then
        response = "-- Take Weapons\n-- Syntax: sv_takeweapons [PlayerIndex]\n-- Take all the weapons away from the specified PlayerIndex."
    elseif command == "sv_unban" then
        response = "-- Unban\n-- Syntax: sv_unban [ID]\n-- Unbans the specified PlayerIndex."
    elseif command == "sv_unhax" then
        response = "-- Cheat Unhax\n-- Syntax: sv_cheat_unhax [PlayerIndex]\n-- Unhaxs the specified PlayerIndex."
    elseif command == "sv_unhide" then
        response = "-- Unhide\n-- Syntax: sv_unhide [PlayerIndex]\n-- Unhides the specified PlayerIndex."
    elseif command == "sv_ungod" then
        response = "-- Ungod\n-- Syntax: sv_ungod [PlayerIndex]\n-- Ungods the specified PlayerIndex."
    elseif command == "sv_uninvis" then
        response = "-- Uninvis\n-- Syntax: sv_uninvis [PlayerIndex]\n-- Uninvises the specified PlayerIndex."
    elseif command == "sv_unsuspend" then
        response = "-- Unsusp\n-- Syntax: sv_unsuspend [PlayerIndex]\n-- Unsuspsend the specified PlayerIndex."
    elseif command == "sv_welcomeback_message" then
        response = "-- Welcome Back Message\n-- Syntax: sv_welcomeback_message [boolean]\n-- Enable/Disable Welcome Back Message"
    elseif command == "sv_write" then
        response = "-- Write\n-- Syntax: sv_write [type] [struct] [offset] [value] [PlayerIndex]\n-- Read the Guide for info on this command"
    elseif command == "sv_balance" then
        response = "-- Balance\n-- Syntax: sv_balance\n-- Balances Teams"
    elseif command == "sv_ pl" or command == "sv_players" then
        response = "-- Player list\n-- Syntax: sv_players\n-- sv_players command modified\n-- Shows Player ID, Player Name, and Player Team"
    elseif command == "sv_plmore" or command == "sv_players_more" then
        response = "-- Player list more\n-- Syntax: sv_players_more\n-- Shows Player ID, Player Name, Player Team, \nStatus(Admin/Regular), IP, and Hash"
    elseif command == "sv_stickman" then
        response = "-- Stickman Animation\n-- Syntax: sv_stickman\n"
    elseif command == "sv_kick" then
        response = "-- Kick\n-- Syntax: sv_kick [PlayerIndex] {message}\n-- Kicks the PlayerIndex out of the server with a reason written to the KickReason.log"
    elseif command == "sv_ban" then
        response = "-- Ban\n-- Syntax: sv_ban[PlayerIndex] {message} {time}\n-- Bans the PlayerIndex out of the server with a reason written to the BanReason.log"
    elseif command == "sv_chatcommands" then
        response = "-- ChatCommands\n-- Syntax: sv_chatcommands {boolean}\n-- Enables or Disables the chat commands in the sevrer"
    elseif command == "sv_login" then
        response = "-- Login\n-- Syntax: sv_login\n-- If there are no admins in the admin_table or ipadmins then you will be able to login with this command\n so you are able to use Chat commands even without being a hash or IP admin, it is only temporary."
    elseif command == "sv_status" then
        response = "-- Status\n-- Syntax: sv_status\n-- Shows a list of all the defaults.txt commands and their status."
    elseif command == "sv_adminblocker" then
        response = "-- Admin Blocker\n-- Syntax: sv_adminblocker {type}\n-- Enables, disables or limits the abiliy of an admin to kick/ban another admin"
    elseif command == "sv_anticaps" then
        response = "-- AntiCaps\n-- Syntax sv_anticaps {boolean} \n-- Enables or Disables the use of caps in the server"
    elseif command == "sv_antispam" then
        response = "-- AntiSpam\n-- Syntax sv_antispam {all | players | off} \n-- All = All Players\n-- Players = all players execept admins\n-- Off = Disables AntiSpam"
    elseif command == "sv_spammax" then
        response = "-- SpamMax\n-- Syntax: sv_spammax {value}\n-- Changes the max amount of messages that can be sent in 1 minute"
    elseif command == "sv_spamtimeout" then
        response = "-- SpamTimeout\n-- Syntax: sv_spamtimeout {time}\n-- Changes the time you are muted for spamming"
    elseif command == "sv_bosplayers" then
        response = "-- BosPlayers\n-- Syntax: sv_bosplayers\n-- Shows the available players that can be banned on sight."
    elseif command == "sv_scrimmode" then
        response = "-- Scrim Mode\n-- Syntax: sv_scrimmode {boolean}\n-- Enables/Disables the ability to you Cheat/Troll Commands."
    elseif command == "sv_credits" then
        response = "Version: " .. script_version .. " Credits: Aelite, Wizard, and Nuggets \nBase script created by: Smiley"
    elseif command == "sv_list" then
        response = "-- List\n-- Syntax: sv_list {page}\n-- Lists all commands"
    elseif command == "sv_pvtsay" then
        response = "-- Private Say\n--Syntax sv_pvtsay {PlayerIndex} {message}\n--Sends a private message to the specifed PlayerIndex"
    elseif command == "sv_cmds" then
        response = "-- Commands\n--Syntax sv_cmds\n-- Lists the commands you are allowed to executed"
    elseif command == "sv_setkills" then
        response = "-- Set Kills\n--Syntax sv_setkills {PlayerIndex}\n-- Sets the kills for the specified players"
    elseif command == "sv_setassists" then
        response = "-- Set Assists\n--Syntax sv_setassists {PlayerIndex}\n-- Sets the assists for the specified players"
    elseif command == "sv_addrcon" then
        response = "-- Add Rcon Password\n-- Syntax sv_addrcon [password] {level}\n--Allows the use of more than one rcon password in the server"
    elseif command == "sv_delrcon" then
        response = "-- Delete Rcon Password\n-- Syntax sv_delrcon {password}\n-- Deletes the rcon password."
    elseif command == "sv_rconlist" then
        response = "-- Rcon Password List\n-- Syntax sv_rconlist\n-- Lists all available rcon passwords except the main rcon password"
    elseif command == "sv_iprangebanlist" then
        response = "-- IP Range Ban list\n-- Syntax sv_iprangebanlist\n-- Lists all players IP range banned."
    elseif command == "sv_iprangeban" then
        response = "-- IP Range Ban\n-- Syntax sv_iprangeban [PlayerIndex or ip] {time} {message}\n-- Bans an entire IP Range Ex: 192.198.0.0 - 192.168.255.255"
    elseif command == "sv_iprangeunban" then
        response = "-- IP Range Unban\n-- Syntax sv_iprangeunban [ID]\n-- Remove selected index off of the IP Range banlist"
    elseif command == "sv_read" then
        response = "-- Read\n-- Syntax: sv_read [type] [struct] [offset] [value] [PlayerIndex]\n-- Read the Guide for info on this command"
    elseif command == "sv_load" then
        response = "-- Script Load\n-- Syntax: sv_load\n-- Shortcut for sv_script_load"
    elseif command == "sv_unload" then
        response = "-- Script Unload\n-- Syntax: sv_unload\n-- Shortcut for sv_script_unload"
    elseif command == "sv_resetplayer" then
        response = "-- Reset Player\n-- Syntax: sv_resetplayer [PlayerIndex]\n-- Removes all troll settings from specified PlayerIndex"
    elseif command == "sv_dmg" or command == "sv_damage" then
        response = "-- Damage Multiplier\n-- Syntax: sv_damage [PlayerIndex] [damage multiplier]\n-- Increases the amount of damage the PlayerIndex does."
    elseif command == "sv_hash_duplicates" then
        response = "-- Hash Duplicate Checking\n-- Syntax: sv_hash_duplicates {boolean}\n-- Enables/Disables the server from checking if the hash key is already in the server."
    elseif command == "sv_multiteam_vehicles" then
        response = "-- Multi Team Vehicles\n-- Syntax: sv_multiteam_vehicles {boolean}\n-- Enables/Disables the ability to enter a vehicle with another PlayerIndex in FFA."
    else
        return "Invalid Command Use sv_list for list of commands"
    end
    return response .. "\n-- For more information check out the command script guide\n-- http://phasorscripts.wordpress.com/command-script-guide/"
end

function getobjecttag(m_objectId)
    if m_objectId then
        local m_object = getobject(m_objectId)
        if m_object then
            local object_map_id = read_dword(m_object)
            local map_base = read_dword(map_pointer)
            local map_tag_count = todec(endian(map_base, 0xC, 0x3))
            local tag_table_base = map_base + 0x28
            local tag_table_size = 0x20
            for i = 0, (map_tag_count - 1) do
                local tag_id = todec(endian(tag_table_base, 0xC + (tag_table_size * i), 0x3))
                if tag_id == object_map_id then
                    local tag_class = read_string(tag_table_base + (tag_table_size * i), 0x3, 1)
                    local tag_name_address = endian(tag_table_base, 0x10 + (tag_table_size * i), 0x3)
                    local tag_name = readtagname("0x" .. tag_name_address)
                    return tag_name, tag_class
                end
            end
        end
    end
end

function getvalidformat(command)
    local Command
    if string.sub(command, 1, 1) == "\\" or string.sub(command, 1, 1) == "/" then
        Command = "sv_" .. string.sub(command, 2)
    elseif string.sub(command, 1, 1) ~= "\\" and string.sub(command, 1, 1) ~= "/" and string.sub(command, 0, 3) ~= "sv_" then
        Command = "sv_" .. command
    else
        Command = command
    end
    return Command
end

function getteam(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local team = get_var(PlayerIndex, "$team")
        return team
    end
    return nil
end

function getvalidplayers(expression, PlayerIndex)
    if cur_players ~= 0 then
        local players = { }
        if expression == "*" or expression == '"*"' then
            for i = 1, 16 do
                if getplayer(i) then
                    table.insert(players, i)
                end
            end
        elseif expression == "me" or expression == '"me"' then
            if PlayerIndex ~= nil and PlayerIndex ~= -1 and PlayerIndex then
                table.insert(players, PlayerIndex)
            end
        elseif string.sub(expression, 1, 3) == "red" or string.sub(expression, 1, 3) == '"red"' then
            for i = 1, 16 do
                if getplayer(i) and getteam(i) == "red" then
                    table.insert(players, i)
                end
            end
        elseif string.sub(expression, 1, 4) == "blue" or string.sub(expression, 1, 4) == '"blue"' then
            for i = 1, 16 do
                if getplayer(i) and getteam(i) == "blue" then
                    table.insert(players, i)
                end
            end
        elseif (tonumber(expression) or 0) >= 1 and (tonumber(expression) or 0) <= 16 then
            local expression = tonumber(expression)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"1"' then
            val = 1
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"2"' then
            val = 2
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"3"' then
            val = 3
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"4"' then
            val = 4
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"5"' then
            val = 5
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"6"' then
            val = 6
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"7"' then
            val = 7
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"8"' then
            val = 8
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"9"' then
            val = 9
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"10"' then
            val = 10
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"11"' then
            val = 11
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"12"' then
            val = 12
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"13"' then
            val = 13
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"14"' then
            val = 14
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"15"' then
            val = 15
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == '"16"' then
            val = 16
            local expression = tonumber(val)
            if resolveplayer(expression) then
                table.insert(players, resolveplayer(expression))
            end
        elseif expression == "random" or expression == "rand" or expression == '"random"' or expression == '"rand"' then
            if cur_players == 1 and PlayerIndex ~= nil then
                table.insert(players, PlayerIndex)
                return players
            end
            local bool = false
            while not bool do
                num = math.random(1, 16)
                if getplayer(num) and num ~= PlayerIndex then
                    bool = true
                end
            end
            table.insert(players, num)
        else
            for i = 1, 16 do
                if getplayer(i) then
                    if string.wild(getname(i), expression) == true then
                        table.insert(players, i)
                    end
                end
            end
        end
        if players[1] then
            return players
        end
    end
    return false
end

function Ipban(PlayerIndex, bool)
    local hash = gethash(PlayerIndex)
    execute_command("sv_ban " .. resolveplayer(PlayerIndex))
    if not bool then
        local file = io.open(profilepath .. "commands_banned.txt", "r")
        if file then
            local Lines = 0
            for line in file:lines() do
                Lines = Lines + 1
                if line and line ~= "" then
                    if string.find(line, hash) then
                        execute_command("sv_unban " .. Lines - 2)
                    end
                end
            end
        end
    end
end

function lo3Timer(id, count)
    if gameend == true then
        return false
    end
    if count >= 3 then
        if scrim_mode then
            say("Scrim Mode is currently on")
        else
            say("Scrim Mode is currently off")
        end
        say("Start your match")
        execute_command("sv_map_reset")
        lo3_timer = nil
        return false
    else
        execute_command("sv_map_reset")
        return true
    end
end

function get_tag_info(tagclass, tagname)
    -- Credits to 002 for this function. Return metaid
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

function LoadTags()
    -- bipd --
    bipds_table[1] = { "bipd", "characters\\cyborg_mp\\cyborg_mp" }
    bipds_table[2] = { "bipd", "characters\\captain\\captain" }
    bipds_table[3] = { "bipd", "characters\\cortana\\cortana" }
    bipds_table[4] = { "bipd", "characters\\cortana\\halo_enhanced\\halo_enhanced" }
    bipds_table[5] = { "bipd", "characters\\crewman\\crewman" }
    bipds_table[6] = { "bipd", "characters\\elite\\elite" }
    bipds_table[7] = { "bipd", "characters\\elite\\elite special" }
    bipds_table[8] = { "bipd", "characters\\engineer\\engineer" }
    bipds_table[9] = { "bipd", "characters\\flood_captain\\flood_captain" }
    bipds_table[10] = { "bipd", "characters\\flood_infection\\flood_infection" }
    bipds_table[11] = { "bipd", "characters\\floodcarrier\\floodcarrier" }
    bipds_table[12] = { "bipd", "characters\\floodcombat elite\\floodcombat elite" }
    bipds_table[13] = { "bipd", "characters\\floodcombat_human\\floodcombat_human" }
    bipds_table[14] = { "bipd", "characters\\grunt\\grunt" }
    bipds_table[15] = { "bipd", "characters\\hunter\\hunter" }
    bipds_table[16] = { "bipd", "characters\\marine\\marine" }
    bipds_table[17] = { "bipd", "characters\\marine_suicidal\\marine_suicidal" }
    bipds_table[18] = { "bipd", "characters\\monitor\\monitor" }
    bipds_table[19] = { "bipd", "characters\\sentinel\\sentinel" }
    bipds_table[20] = { "bipd", "characters\\johnson\\johnson" }

    -- equipment --
    eqip_table[1] = { "eqip", "powerups\\active camouflage" }
    eqip_table[2] = { "eqip", "powerups\\health pack" }
    eqip_table[3] = { "eqip", "powerups\\over shield" }
    eqip_table[4] = { "eqip", "powerups\\double speed" }
    eqip_table[5] = { "eqip", "powerups\\full-spectrum vision" }
    eqip_table[6] = { "eqip", "weapons\\frag grenade\\frag grenade" }
    eqip_table[7] = { "eqip", "weapons\\plasma grenade\\plasma grenade" }
    eqip_table[8] = { "eqip", "powerups\\assault rifle ammo\\assault rifle ammo" }
    eqip_table[9] = { "eqip", "powerups\\needler ammo\\needler ammo" }
    eqip_table[10] = { "eqip", "powerups\\pistol ammo\\pistol ammo" }
    eqip_table[11] = { "eqip", "powerups\\rocket launcher ammo\\rocket launcher ammo" }
    eqip_table[12] = { "eqip", "powerups\\shotgun ammo\\shotgun ammo" }
    eqip_table[13] = { "eqip", "powerups\\sniper rifle ammo\\sniper rifle ammo" }
    eqip_table[14] = { "eqip", "powerups\\flamethrower ammo\\flamethrower ammo" }

    -- vehicles --
    vehicles[1] = { "vehi", "vehicles\\warthog\\mp_warthog" }
    vehicles[2] = { "vehi", "vehicles\\ghost\\ghost_mp" }
    vehicles[3] = { "vehi", "vehicles\\rwarthog\\rwarthog" }
    vehicles[4] = { "vehi", "vehicles\\banshee\\banshee_mp" }
    vehicles[5] = { "vehi", "vehicles\\scorpion\\scorpion_mp" }
    vehicles[6] = { "vehi", "vehicles\\c gun turret\\c gun turret_mp" }

    -- weapons --
    weapons[1] = { "weap", "weapons\\assault rifle\\assault rifle" }
    weapons[2] = { "weap", "weapons\\ball\\ball" }
    weapons[3] = { "weap", "weapons\\flag\\flag" }
    weapons[4] = { "weap", "weapons\\flamethrower\\flamethrower" }
    weapons[5] = { "weap", "weapons\\gravity rifle\\gravity rifle" }
    weapons[6] = { "weap", "weapons\\needler\\mp_needler" }
    weapons[7] = { "weap", "weapons\\pistol\\pistol" }
    weapons[8] = { "weap", "weapons\\plasma pistol\\plasma pistol" }
    weapons[9] = { "weap", "weapons\\plasma rifle\\plasma rifle" }
    weapons[10] = { "weap", "weapons\\plasma_cannon\\plasma_cannon" }
    weapons[11] = { "weap", "weapons\\rocket launcher\\rocket launcher" }
    weapons[12] = { "weap", "weapons\\shotgun\\shotgun" }
    weapons[13] = { "weap", "weapons\\sniper rifle\\sniper rifle" }
    weapons[14] = { "weap", "weapons\\energy sword\\energy sword" }

    -- Globals
    global_distanceId = get_tag_info("jpt!", "globals\\distance")
    global_fallingId = get_tag_info("jpt!", "globals\\falling")

    objects[1] = { "cyborg", "bipd", "characters\\cyborg_mp\\cyborg_mp" }
    objects[2] = { "camo", "eqip", "powerups\\active camouflage" }
    objects[3] = { "health", "eqip", "powerups\\health pack" }
    objects[4] = { "overshield", "eqip", "powerups\\over shield" }
    objects[5] = { "frag", "eqip", "weapons\\frag grenade\\frag grenade" }
    objects[6] = { "plasma", "eqip", "weapons\\plasma grenade\\plasma grenade" }
    objects[7] = { "banshee", "vehi", "vehicles\\banshee\\banshee_mp" }
    objects[8] = { "turret", "vehi", "vehicles\\c gun turret\\c gun turret_mp" }
    objects[9] = { "ghost", "vehi", "vehicles\\ghost\\ghost_mp" }
    objects[11] = { "tank", "vehi", "vehicles\\scorpion\\scorpion_mp" }
    objects[10] = { "rhog", "vehi", "vehicles\\rwarthog\\rwarthog" }
    objects[12] = { "hog", "vehi", "vehicles\\warthog\\mp_warthog" }
    objects[13] = { "rifle", "weap", "weapons\\assault rifle\\assault rifle" }
    objects[14] = { "ball", "weap", "weapons\\ball\\ball" }
    objects[15] = { "flag", "weap", "weapons\\flag\\flag" }
    objects[16] = { "flamethrower", "weap", "weapons\\flamethrower\\flamethrower" }
    objects[17] = { "needler", "weap", "weapons\\needler\\mp_needler" }
    objects[18] = { "pistol", "weap", "weapons\\pistol\\pistol" }
    objects[19] = { "ppistol", "weap", "weapons\\plasma pistol\\plasma pistol" }
    objects[20] = { "prifle", "weap", "weapons\\plasma rifle\\plasma rifle" }
    objects[21] = { "frg", "weap", "weapons\\plasma_cannon\\plasma_cannon" }
    objects[22] = { "rocket", "weap", "weapons\\rocket launcher\\rocket launcher" }
    objects[23] = { "shotgun", "weap", "weapons\\shotgun\\shotgun" }
    objects[24] = { "sniper", "weap", "weapons\\sniper rifle\\sniper rifle" }
    objects[25] = { "sheebolt", "proj", "vehicles\\banshee\\banshee bolt" }
    objects[26] = { "sheerod", "proj", "vehicles\\banshee\\mp_banshee fuel rod" }
    objects[27] = { "turretbolt", "proj", "vehicles\\c gun turret\\mp gun turret" }
    objects[28] = { "ghostbolt", "proj", "vehicles\\ghost\\ghost bolt" }
    objects[29] = { "tankbullet", "proj", "vehicles\\scorpion\\bullet" }
    objects[30] = { "tankshell", "proj", "vehicles\\scorpion\\tank shell" }
    objects[31] = { "hogbullet", "proj", "vehicles\\warthog\\bullet" }
    objects[32] = { "riflebullet", "proj", "weapons\\assault rifle\\bullet" }
    objects[33] = { "flame", "proj", "weapons\\flamethrower\\flame" }
    objects[34] = { "needle", "proj", "weapons\\needler\\mp_needle" }
    objects[35] = { "pistolbullet", "proj", "weapons\\pistol\\bullet" }
    objects[36] = { "ppistolbolt", "proj", "weapons\\plasma pistol\\bolt" }
    objects[37] = { "priflebolt", "proj", "weapons\\plasma rifle\\bolt" }
    objects[38] = { "priflecbolt", "proj", "weapons\\plasma rifle\\charged bolt" }
    objects[39] = { "rocketproj", "proj", "weapons\\rocket launcher\\rocket" }
    objects[40] = { "shottyshot", "proj", "weapons\\shotgun\\pellet" }
    objects[41] = { "snipershot", "proj", "weapons\\sniper rifle\\sniper bullet" }
    objects[42] = { "fuelrodshot", "proj", "weapons\\plasma_cannon\\plasma_cannon" }
end

function isinvehicle(PlayerIndex)
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

function multiteamtimer(player, count)
    if compatible then
        write_byte(getplayer(player) + 0x20, 0)
    end
    return false
end

function nadeTimer(id, count)
    for c = 1, 16 do
        if getplayer(c) then
            local m_objectId = get_dynamic_player(c)
            if m_objectId then
                local m_object = getobject(m_objectId)
                if m_object then
                    write_byte(m_object + 0x31E, 3)
                    write_byte(m_object + 0x31F, 3)
                end
            end
        end
    end
    if infammo then
        return true
    elseif infammo then
        return true
    end
end

function read_string(address, length, endian)
    local char_table = { }
    local string = ""
    local offset = offset or 0x0
    if length == nil then
        if read_byte(address + offset + 1) == 0 and read_byte(address + offset) ~= 0 then
            length = 51000
        else
            length = 256
        end
    end
    for i = 0, length do
        if read_byte(address + (offset + i)) ~= 0 then
            table.insert(char_table, string.char(read_byte(address + (offset + i))))
        elseif i % 2 == 0 and read_byte(address + offset + i) == 0 then
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

function readtagname(address)
    local char_table = { }
    local i = 0
    local string = ""
    while read_byte(address + i) ~= 0 do
        table.insert(char_table, string.char(read_byte(address + i)))
        i = i + 1
    end
    for k, v in pairs(char_table) do
        string = string .. v
    end
    return string
end

function reloadadmins(id, count)
    local file = io.open(profilepath .. "commands_admin.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            local count = #words
            if not admin_table[words[2]] then
                admin_table[words[2]] = { }
            end
            admin_table[words[2]].name = words[1]
            admin_table[words[2]].level = words[3]
            if count == 4 and tonumber(words[3]) then
                if not ipadmins[words[4]] then
                    ipadmins[words[4]] = { }
                end
                ipadmins[words[4]].name = words[1]
                ipadmins[words[4]].level = words[3]
            end
        end
        file:close()
    end
    file = io.open(profilepath .. "commands_ipadmins.txt", "r")
    if file then
        for line in file:lines() do
            local words = tokenizestring(line, ",")
            local count = #words
            if not ipadmins[words[2]] then
                ipadmins[words[2]] = { }
            end
            ipadmins[words[2]].name = words[1]
            ipadmins[words[2]].level = words[3]
        end
        file:close()
    end
    return false
end

-- DO TO:
-- Store previous weapons in a table - On resetweapons() - restore to this weapon layout.

function resetweapons(PlayerIndex)
    if getplayer(PlayerIndex) then
        local player_object = get_dynamic_player(PlayerIndex)
        if player_object ~= 0 then
            local weaponId = read_dword(player_object + 0x118)
            if weaponId ~= 0 then
                local x, y, z = read_vector3d(player_object + 0x5C)
                local weapid = assign_weapon(spawn_object("weap", "weapons\\pistol\\pistol", x, y, z + 0.5), PlayerIndex)
                local weapid = assign_weapon(spawn_object("weap", "weapons\\assault rifle\\assault rifle", x, y, z + 0.5), PlayerIndex)
            end
        end
    end
end

function round(val, decimal)
    if (decimal) then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

function rtvTimer(id, count)
    if gameend == true then
        return false
    end
    if count == 1 then
        rtv_initiated = rtv_timeout
        rtv_table = { }
        say("The current rtv has expired")
        return false
    else
        return true
    end
end

function moveobject(ObjectID, x, y, z)
    local object = get_object_memory(ObjectID)
    if get_object_memory(ObjectID) ~= 0 then
        local veh_obj = get_object_memory(read_dword(object + 0x11C))
        write_vector3d((veh_obj ~= 0 and veh_obj or object) + 0x5C, x, y, z)
    end
end

function OnObjectSpawn(PlayerIndex, MapID, ParentID, ObjectID)
    if PlayerIndex then
        if mode[getip(PlayerIndex)] == "portalgun" then
            timer(20, "portalgunTimer", PlayerIndex)
        elseif mode[getip(PlayerIndex)] == "spawngun" then
            timer(20, "spawngunTimer", PlayerIndex)
        end
    end
end

function portalgunTimer(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    local firing_state = read_float(player_object + 0x490)
    if firing_state and firing_state == 1 then
        execute_command("boost " .. PlayerIndex)
    end
end

function spawngunTimer(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    local x1, y1, z1 = read_vector3d(player_object + 0x5c)
    local camera_x = read_float(player_object + 0x230)
    local camera_y = read_float(player_object + 0x234)
    local height = 0
    local distance = 5
    local x2 = x1 + camera_x * distance
    local y2 = y1 + camera_y * distance
    local z2 = z1 + height
    local odj = spawn_object(obj_type, objspawnid[getip(PlayerIndex)], x2, y2, z2)
    return false
end

function getplayerobjectid(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local player_object = get_dynamic_player(PlayerIndex)
        return player_object
    end
    return nil
end

function sendresponse(message, command, PlayerIndex)
    if message then
        if message == "" then
            return
        elseif type(message) == "table" then
            message = message[1]
        end
        PlayerIndex = tonumber(PlayerIndex)
        if command then
            if PlayerIndex ~= -1 and PlayerIndex >= 1 and PlayerIndex < 16 then
                if not use_console then
                    execute_command("msg_prefix \"\"")
                    privatesay(PlayerIndex, message)
                    execute_command("msg_prefix \"** SERVER ** \"")
                elseif use_console then
                    rprint(PlayerIndex, message)
                end
            else
                cprint(message .. "", 2 + 8)
            end
            if PlayerIndex ~= nil and PlayerIndex ~= -1 and PlayerIndex then
                cmdlog("Response to " .. getname(PlayerIndex) .. ": " .. message)
            end
        else
            cprint("Internal Error Occured - Check the Command Script Errors log for details.", 4 + 8)
            cprint("Error Occured at [function] sendresponse: [NO COMMAND] - Helpful info: " .. message .. "", 4 + 8)
            cmderrors("Error Occured at [function] sendresponse: [NO COMMAND] - Helpful info: " .. message)
        end
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
        if get_var(0, "$gt") == "slayer" then
            if score >= 0x7FFF then
                execute_command("score " .. PlayerIndex .. " +1")
            elseif score <= -0x7FFF then
                execute_command("score " .. PlayerIndex .. " -1")
            else
                execute_command("score " .. PlayerIndex .. " " .. score)
            end
        end
        if gametype == 3 then
            local oddball_game = read_byte(gametype_base + 0x8C)
            if oddball_game == 0 or oddball_game == 1 then
                if score * 30 >= 0x7FFFFFFF then
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, 0x7FFFFFFF)
                elseif score * 30 <= -0x7FFFFFFF then
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, -1 * 0x7FFFFFFF)
                else
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, score * 30)
                end
            else
                if score > 0x7FFFFC17 then
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, 0x7FFFFC17)
                elseif score <= -0x7FFFFC17 then
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, -0x7FFFFC17)
                else
                    write_word(oddball_globals + 0x84 + PlayerIndex * 4, score)
                end
            end
        elseif gametype == 4 then
            local m_player = getplayer(PlayerIndex)
            if score * 30 >= 0x7FFF then
                write_word(m_player + 0xC4, 0x7FFF)
            elseif score * 30 <= -0x7FFF then
                write_word(m_player + 0xC4, -0x7FFF)
            else
                write_word(m_player + 0xC4, score * 30)
            end
        elseif gametype == 5 then
            local m_player = getplayer(PlayerIndex)
            if score >= 0x7FFF then
                write_word(m_player + 0xC6, 0x7FFF)
            elseif score <= -0x7FFF then
                write_word(m_player + 0xC6, -0x7FFF)
            else
                write_word(m_player + 0xC6, score)
            end
        end
    end
end

function pack(...)
    local arg = { ... }
    return arg
end

function math.round(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function string.findchar(str, char)
    local chars = string.split(str, "")
    local indexes = { }
    for k, v in ipairs(chars) do
        if v == char then
            table.insert(indexes, k)
        end
    end
    return table.unpack(indexes)
end

function string.split(str, ...)
    local subs = { }
    local sub = ""
    local i = 1
    for _, v in ipairs(arg) do
        if v == "" then
            for x = 1, string.len(str) do
                table.insert(subs, string.sub(str, x, x))
            end
            return subs
        end
    end
    for _, v in ipairs(arg) do
        if string.sub(str, 1, 1) == v then
            table.insert(subs, "")
            break
        end
    end
    while i <= string.len(str) do
        local bool, bool2
        for x = 1, #arg do
            if arg[x] ~= "" then
                local length = string.len(arg[x])
                if string.sub(str, i, i + (length - 1)) == arg[x] then
                    if i == string.len(str) then
                        bool2 = true
                    else
                        bool = true
                    end
                    i = i + (length - 1)
                    break
                end
            else
                for q = 1, string.len(str) do
                    subs = { }
                    table.insert(subs, string.sub(str, q, q))
                    i = string.len(str)
                    break
                end
            end
        end
        if not bool then
            sub = sub .. string.sub(str, i, i)
        end
        if bool or i == string.len(str) then
            if sub ~= "" then
                table.insert(subs, sub)
                sub = ""
            end
        end
        if bool2 then
            table.insert(subs, "")
        end
        i = i + 1
    end
    for k, v in ipairs(subs) do
        for _, d in ipairs(arg) do
            subs[k] = string.gsub(v, d, "")
        end
    end
    return subs
end

function string.wild(match, wild, case_sensative)
    if not case_sensative then
        match, wild = string.lower(match), string.lower(wild)
    end
    if string.sub(wild, 1, 1) == "?" then
        wild = string.gsub(wild, "?", string.sub(match, 1, 1), 1)
    end
    if string.sub(wild, string.len(wild), string.len(wild)) == "?" then
        wild = string.gsub(wild, "?", string.sub(match, string.len(match), string.len(match)), 1)
    end
    if not string.find(wild, "*") and not string.find(wild, "?") and wild ~= match then
        return false
    end
    if string.sub(wild, 1, 1) ~= string.sub(match, 1, 1) and string.sub(wild, 1, 1) ~= "*" then
        return false
    end
    if string.sub(wild, string.len(wild), string.len(wild)) ~= string.sub(match, string.len(match), string.len(match)) and string.sub(wild, string.len(wild), string.len(wild)) ~= "*" then
        return false
    end
    local substrings = string.split(wild, "*")
    local begin = 1
    for k, v in ipairs(substrings) do
        local sublength = string.len(v)
        local temp_begin = begin
        local temp_end = begin + sublength - 1
        local matchsub = string.sub(match, begin, temp_end)
        local bool
        repeat
            local wild = v
            local indexes = pack(string.findchar(wild, "?"))
            if #indexes > 0 then
                for _, i in ipairs(indexes) do
                    wild = string.gsub(wild, "?", string.sub(matchsub, i, i), 1)
                end
            end
            if matchsub == wild then
                bool = true
                break
            end
            matchsub = string.sub(match, temp_begin, temp_end)
            temp_begin = temp_begin + 1
            temp_end = temp_end + 1
        until temp_end >= string.len(match)
        if not bool then
            return false
        end
        begin = sublength + 1
    end
    return true
end

function SelectPlayer(team)
    local t = { }
    for i = 1, 16 do
        if getplayer(i) and getteam(i) == team then
            table.insert(t, i)
        end
    end
    if #t > 0 then
        return t[rand(1, #t + 1)]
    end
    return nil
end

function settimelimit(value)
    if tonumber(value) then
        write_dword(timelimit_address, tonumber(value))
        local time_passed = read_dword(read_dword(gametime_base) + 0xC)
        write_dword(gametype_base + 0x78, 30 * 60 * value + time_passed)
    end
end

function Timer(id, count)
    if spam_max == nil then
        spam_max = 7
    end
    if spam_timeout == nil then
        spam_timeout = 60
    end
    for i = 1, 16 do
        if getplayer(i) then
            local ip = getip(i)
            if spam_table[ip] == nil then
                spam_table[ip] = 0
            end
            if spam_table[ip] < tonumber(spam_max) then
                if spam_table[ip] > 0 then
                    spam_table[ip] = spam_table[ip] - 0.25
                end
            else
                say(getname(i) .. " has been muted for " .. spam_timeout .. " seconds for spamming")
                spam_table[ip] = -1
            end
            if spam_table[ip] == -1 then
                if spamtimeout_table[ip] == nil then
                    spamtimeout_table[ip] = tonumber(spam_timeout)
                else
                    spamtimeout_table[ip] = spamtimeout_table[ip] - 1
                end
                if spamtimeout_table[ip] == 0 then
                    say(getname(i) .. " has been unmuted")
                    spamtimeout_table[ip] = nil
                    spam_table[ip] = 0
                end
            end
        end
    end
    for k, v in pairs(ip_banlist) do
        if ip_banlist[k] ~= { } then
            for key, value in ipairs(ip_banlist[k]) do
                if tonumber(ip_banlist[k][key].time) then
                    ip_banlist[k][key].time = tonumber(ip_banlist[k][key].time)
                else
                    ip_banlist[k][key].time = -1
                end
                if ip_banlist[k][key].time > 0 then
                    ip_banlist[k][key].time = ip_banlist[k][key].time - 1
                    if ip_banlist[k][key].time == 0 then
                        table.remove(ip_banlist[k], key)
                    end
                end
            end
        end
    end
    for k, v in pairs(mute_banlist) do
        if mute_banlist[k] ~= { } then
            for key, value in ipairs(mute_banlist[k]) do
                if tonumber(mute_banlist[k][key].time) then
                    mute_banlist[k][key].time = tonumber(mute_banlist[k][key].time)
                else
                    mute_banlist[k][key].time = -1
                end
                if mute_banlist[k][key].time > 0 then
                    mute_banlist[k][key].time = mute_banlist[k][key].time - 1
                    if mute_banlist[k][key].time == 0 then
                        table.remove(mute_banlist[k], key)
                    end
                end
            end
        end
    end

    for k, v in pairs(iprange_banlist) do
        if iprange_banlist[k] ~= { } then
            for key, value in ipairs(iprange_banlist[k]) do
                if tonumber(iprange_banlist[k][key].time) then
                    iprange_banlist[k][key].time = tonumber(iprange_banlist[k][key].time)
                else
                    iprange_banlist[k][key].time = -1
                end
                if iprange_banlist[k][key].time > 0 then
                    iprange_banlist[k][key].time = iprange_banlist[k][key].time - 1
                    if iprange_banlist[k][key].time == 0 then
                        table.remove(iprange_banlist[k], key)
                    end
                end
            end
        end
    end
    return true
end

-- destroy old vehicle --
function DestroyVehicle(Vehicle_ID)
    if Vehicle_ID then
        destroy_object(Vehicle_ID)
    end
end

-- message | name | "vehi" | tag_id | Player | Type
function Spawn(message, objname, objtype, mapId, PlayerIndex, type)
    vehicle_id = 0
    local m = tokenizestring(message, " ")
    local count = #m
    if count >= 3 and count <= 6 then
        local players = getvalidplayers(m[3], PlayerIndex)
        if players then
            for i = 1, #players do
                if players[i] == nil then
                    break
                end
                if getplayer(players[i]) then
                    local m_playerObjId = get_dynamic_player(players[i])
                    if m_playerObjId then
                        if isinvehicle(players[i]) then
                            VehicleID = read_dword(m_playerObjId + 0x11C)
                            if (VehicleID == 0xFFFFFFFF) then
                                return false
                            end
                            local obj_id = get_object_memory(VehicleID)
                            x, y, z = read_vector3d(obj_id + 0x5c)
                        else
                            x, y, z = read_vector3d(m_playerObjId + 0x5c)
                            local camera_x = read_float(m_playerObjId + 0x230)
                            local camera_y = read_float(m_playerObjId + 0x234)
                            x = x + camera_x * 2
                            y = y + camera_y * 2
                            z = z + 2
                        end
                        if count == 3 then
                            if objtype == "weap" and type == "give" then
                                local player_object = get_dynamic_player(players[i])
                                local x, y, z = read_vector3d(player_object + 0x5C)
                                local weapid = assign_weapon(spawn_object("weap", object_to_spawn, x, y, z + 0.5), players[i])
                                sendresponse(objname .. " given to " .. getname(players[i]), message, PlayerIndex)
                                sendresponse(getname(players[i]) .. " has been given a " .. objname .. ".", "//", players[i])
                            elseif type == "spawn" and objtype == "vehi" then
                                local vehicle_id = spawn_object("vehi", object_to_spawn, x, y, z)
                                sendresponse(objname .. " spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                                vehicle_drone_table[players[i]] = vehicle_drone_table[players[i]] or { }
                                table.insert(vehicle_drone_table[players[i]], vehicle_id)
                                drone_obj = get_object_memory(vehicle_id)
                            elseif type == "spawn" and objtype == "weap" then
                                local weap = spawn_object("weap", object_to_spawn, x, y, z)
                                sendresponse(objname .. " spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                            elseif type == "spawn" and objtype == "bipd" then
                                local bipd = spawn_object("bipd", object_to_spawn, x, y, z)
                                sendresponse(objname .. " spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                            elseif type == "spawn" and objtype == "eqip" then
                                local eqip = spawn_object("eqip", object_to_spawn, x, y, z)
                                sendresponse(objname .. " spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                            elseif type == "enter" then
                                local vehicle_id = spawn_object("vehi", object_to_spawn, x, y, z)
                                if Multi_Control == true and not isinvehicle(players[i]) then
                                    enter_vehicle(vehicle_id, players[i], 0)
                                    sendresponse(getname(players[i]) .. " was forced to enter a " .. objname, message, PlayerIndex)
                                elseif Multi_Control == true and isinvehicle(players[i]) then
                                    enter_vehicle(vehicle_id, players[i], 0)
                                    sendresponse(getname(players[i]) .. " was forced to enter a " .. objname, message, PlayerIndex)
                                elseif Multi_Control == false and not isinvehicle(players[i]) then
                                    enter_vehicle(vehicle_id, players[i], 0)
                                    sendresponse(getname(players[i]) .. " was forced to enter a " .. objname, message, PlayerIndex)
                                elseif Multi_Control == false and isinvehicle(players[i]) then
                                    local player_object = get_dynamic_player(players[i])
                                    local Vehicle_ID = read_dword(player_object + 0x11C)
                                    local obj_id = get_object_memory(Vehicle_ID)
                                    exit_vehicle(players[i])
                                    timer(0, "DestroyVehicle", Vehicle_ID)
                                    enter_vehicle(vehicle_id, players[i], 0)
                                    sendresponse(getname(players[i]) .. " was forced to enter a " .. objname, message, PlayerIndex)
                                end
                                if vehicle_id ~= nil then
                                    vehicle_drone_table[players[i]] = vehicle_drone_table[players[i]] or { }
                                    table.insert(vehicle_drone_table[players[i]], vehicle_id)
                                    drone_obj = get_object_memory(vehicle_id)
                                end
                            end
                        elseif count == 4 then
                            if m[4] ~= 0 then
                                for i = 1, m[4] do
                                    spawn_object(mapId, 0, 0, false, x, y, z)
                                end
                                sendresponse(m[4] .. " " .. objname .. "s spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                                privatesay(players[i], objname .. " spawned above you.")
                            else
                                sendresponse("You didn't spawn anything")
                            end
                        elseif count == 5 then
                            if m[4] ~= 0 then
                                for i = 1, m[4] do
                                    spawn_object(mapId, 0, m[5], false, x, y, z)
                                end
                                sendresponse(m[4] .. " " .. objname .. "s spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                                privatesay(players[i], objname .. " spawned above you.")
                            else
                                sendresponse("You didn't spawn anything")
                            end
                        elseif count == 6 then
                            if m[4] ~= 0 then
                                for i = 1, m[4] do
                                    spawn_object(mapId, 0, m[5], m[6], x, y, z)
                                end
                                sendresponse(m[4] .. " " .. objname .. "s spawned at " .. getname(players[i]) .. "'s location.", message, PlayerIndex)
                                privatesay(players[i], objname .. " spawned above you.")
                            else
                                sendresponse("You didn't spawn anything", message, PlayerIndex)
                            end
                        end
                    elseif type ~= "give" then
                        sendresponse("Could not spawn next to " .. getname(players[i]) .. ". Player is dead.", message, PlayerIndex)
                    elseif type == "give" then
                        sendresponse("Could not give " .. getname(players[i]) .. " a " .. objname .. ". Player is dead.", message, PlayerIndex)
                    end
                else
                    sendresponse("Player is nil", message, PlayerIndex)
                end
            end
        else
            sendresponse("Invalid Player", message, PlayerIndex)
        end
    end
    return vehicle_id
end

function Stickman(id, count)
    if count == 1 then
        cprint("    _._    ")
        cprint("   / O \\   ")
        cprint("   \\| |/   ")
        cprint("O--+=-=+--O")
    elseif count == 2 then
        execute_command("cls")
        cprint("   ,-O-,   ")
        cprint("O--=---=--O")
        cprint("    2-2    ")
        cprint("    - -    ")
    elseif count == 3 then
        execute_command("cls")
        cprint("   ,_O_,   ")
        cprint("O--(---)--O")
        cprint("    >'>    ")
        cprint("    - -    ")
    elseif count == 4 then
        execute_command("cls")
        cprint("   ._O_.   ")
        cprint("O--<-+->--O")
        cprint("     X     ")
        cprint("    / \\    ")
        cprint("   -   -   ")
    elseif count == 5 then
        execute_command("cls")
        cprint("O--=-O-=--O")
        cprint("    '-'    ")
        cprint("     v     ")
        cprint("    / )    ")
        cprint("   ~  z    ")
    elseif count == 6 then
        execute_command("cls")
        cprint("O--,---,--O")
        cprint("   \\ O /   ")
        cprint("    - -    ")
        cprint("     -     ")
        cprint("    // \\    ")
        cprint("   =   =   ")
    elseif count == 7 then
        execute_command("cls")
        cprint("O--=-O-=--O")
        cprint("    '-'    ")
        cprint("     v     ")
        cprint("    / )    ")
        cprint("   ~  z    ")
    elseif count == 8 then
        execute_command("cls")
        cprint("   ._O_.   ")
        cprint("O--<-+->--O")
        cprint("     X     ")
        cprint("    / \\    ")
        cprint("   -   -   ")
    elseif count == 9 then
        execute_command("cls")
        cprint("   ,_O_,   ")
        cprint("O--(---)--O")
        cprint("    >'>    ")
        cprint("    - -    ")
    elseif count == 10 then
        execute_command("cls")
        cprint("   ,-O-,   ")
        cprint("O--=---=--O")
        cprint("    2-2    ")
        cprint("    - -    ")
    elseif count == 11 then
        execute_command("cls")
        cprint("    _._    ")
        cprint("   / O \\   ")
        cprint("   \\| |//   ")
        cprint("O--+=-=+--O")
    elseif count >= 12 then
        execute_command("cls")
        return false
    end
    return true
end

function todec(number)
    return tonumber(number, 16)
end

function GetTagName(obj)
    if (obj ~= nil and obj ~= 0) then
        return read_string(read_dword(read_word(obj) * 32 + 0x40440038))
    else
        return ""
    end
end

function timetoword(time)
    if time == -1 or time == "-1" then
        return -1
    elseif tonumber(time) then
        local returntime = ""
        local seconds = tonumber(time)
        local days = math.floor(seconds / 86400)
        seconds = seconds - days * 86400
        local hours = math.floor(seconds / 3600)
        seconds = seconds - hours * 3600
        local minutes = math.floor(seconds / 60)
        seconds = seconds - minutes * 60
        if seconds ~= 0 then
            returntime = seconds .. "s"
        end
        if minutes ~= 0 then
            if returntime == "" then
                returntime = minutes .. "m"
            else
                returntime = minutes .. "m " .. returntime
            end
        end
        if hours ~= 0 then
            if returntime == "" then
                returntime = hours .. "h"
            else
                returntime = hours .. "h " .. returntime
            end
        end
        if days ~= 0 then
            if returntime == "" then
                returntime = days .. "d"
            else
                returntime = days .. "d " .. returntime
            end
        end
        if returntime == "" then
            returntime = "0s"
        end
        return returntime
    else
        return -1
    end
end

function WriteData(s_chat_dir, value)
    local file = io.open(s_chat_dir, "a+")
    if file ~= nil then
        local chatValue = string.format("%s\t%s\n", TimeStamp, tostring(value))
        file:write(chatValue)
        file:close()
    end
end

function votekick(name, PlayerIndex)
    votekick_table = { }
    votekick_allowed = true
    if not votekicktimeouttimer then
        votekicktimeouttimer = timer(60000, "votekicktimeoutTimer")
    end
    say("Kicking " .. name .. "")
    if votekick_action == "ban" then
        execute_command("sv_ban " .. PlayerIndex + 1 .. " 5m")
    else
        execute_command("sv_kick " .. PlayerIndex + 1)
    end
end

function votekicktimeoutTimer(id, count)
    votekicktimeout_table = false
    say("VoteKick is now available again")
    return false
end

function wordtotime(time)
    if time then
        if tonumber(time) then
            return tonumber(time)
        else
            local timeban = 0
            local num = ""
            for i = 1, string.len(time) do
                local char = string.sub(time, i, i)
                if tonumber(char) then
                    num = num .. char
                else
                    local holder = 0
                    if char == "s" then
                        holder = tonumber(num)
                    elseif char == "m" then
                        holder = tonumber(num) * 60
                    elseif char == "h" then
                        holder = tonumber(num) * 60 * 60
                    elseif char == "d" then
                        holder = tonumber(num) * 60 * 60 * 24
                    else
                        holder = 0
                    end
                    if holder and timeban then
                        timeban = timeban + holder
                    else
                        if timeban then
                            timeban = timeban + 1
                        end
                    end
                    num = ""
                end
            end
            if timeban > 0 then
                return tonumber(timeban)
            end
        end
    else
        return -1
    end
end

function write_wordsigned(address, word)
    value = tonumber(word)
    if value == nil then
        value = tonumber(word, 16)
    end
    if value and value > 0x7FFF then
        local max = 0xFFFF
        local difference = max - value
        value = -1 - difference
    end
    write_word(address, value)
end

function WriteChangeLog()
    local file = io.open(profilepath .. "changelog_" .. script_version .. ".txt", "w")
    file:write("Converted to SAPP\n")
    file:close()
end

function WriteLog(filename, value)
    local file = io.open(filename, "a")
    if file then
        local timestamp = os.date("%Y/%m/%d %H:%M:%S")
        local line = string.format("%s\t%s\n", timestamp, tostring(value))
        file:write(line)
        file:close()
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
