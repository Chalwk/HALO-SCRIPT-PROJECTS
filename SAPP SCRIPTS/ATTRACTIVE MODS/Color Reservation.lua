--[[
--=====================================================================================================--
Script Name: Color Reservation, for SAPP (PC & CE)
Description: Reserve spartan armor colors for VIP members)! 

Implementing Lua API version 1.11.0.0 (works fine on the latest version: 1.12.0.0)

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.11.0.0"
color_table = {}
bool = {}

-- Configuration [starts] [!] DO NOT TOUCH THE "Color ID"
--             Color ID     Hash
color_table[1] = {0,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}  -- white (both of these hashes will trigger white)
color_table[2] = {1,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- black
color_table[3] = {2,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- red
color_table[4] = {3,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- blue
color_table[5] = {4,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- gray
color_table[6] = {5,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- yellow
color_table[7] = {6,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- green
color_table[8] = {7,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- pink
color_table[9] = {8,        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- purple
color_table[10] = {9,       "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- cyan
color_table[11] = {10,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- cobalt
color_table[12] = {11,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- orange
color_table[13] = {12,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- teal
color_table[14] = {13,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- sage
color_table[15] = {14,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- brown
color_table[16] = {15,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- tan
color_table[17] = {16,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- maroon
color_table[18] = {17,      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}    -- salmon
-- Note: Make sure you encapsulate hashes in quotes and separate entries with a comma!
-- Like so: color_table[1] = {0, "player hash 1", "player hash 2"}

-- [!] DO NOT TOUCH THE "Color ID"
-- Configuration [ends] -----------------------------------------------------------------

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
end

function OnScriptUnload()

end

function OnNewGame()
    if (get_var(1, "$gt") == "slayer") then
        register_callback(cb['EVENT_JOIN'], "OnPlayerConnect")
        register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    else
        cprint("[!] Warning: Color Reservation doesn't support " .. get_var(0, "$gt") .. "!", 4+8)
    end
end

function OnPlayerConnect(PlayerIndex)
    local hash = getHash(PlayerIndex)
    local player = getPlayer(PlayerIndex)
    for k, v in ipairs(color_table) do
        for i = 1, #v do 
            if not string.find(v[i], tostring(hash)) then 
                -- Check if their color is TEAL | if TRUE then set new color (Shoo's color reservation)
                if (read_byte(player + 0x60) == 12) then
                    bool[PlayerIndex] = true
                    setColor(PlayerIndex, nil, true, hash)
                end
            else
                -- player's hash IS LISTED in the color table | execute: setColor()
                setColor(PlayerIndex, nil, false, hash)
            end
        end
    end
end

function OnPlayerSpawn(PlayerIndex)
    if (bool[PlayerIndex] == true) then
        bool[PlayerIndex] = false
        local player_object = read_dword(get_player(PlayerIndex) + 0x34)
        destroy_object(player_object)
    end
end

function setColor(PlayerIndex, ColorID, param, hash)
    -- Set this player's color to something random (EXCLUDING TEAL)
    local player = getPlayer(PlayerIndex)
    if (param == true) then
        write_byte(player + 0x60, tonumber(selectRandomColor(12)))
    else
        -- iterate over the entire array and set the appropriate color according to table index
        local color
        for k,v in pairs(color_table) do
            for i = 1, #v do 
                if string.find(v[i], tostring(hash)) then
                    color = v[1]
                    write_byte(player + 0x60, color)
                end
            end
        end
    end
end

function selectRandomColor(exclude)
    math.randomseed(os.time())
    math.random(); math.random(); math.random()
    local num = math.random(0, 17)
    -- If the number selected is equal to the value of "exclude", repeat.
    if num == tonumber(exclude) then
        selectRandomColor(exclude)
    else
        return num
    end
end

function getPlayer(PlayerIndex)
    if tonumber(PlayerIndex) then
        if tonumber(PlayerIndex) ~= 0 then
            local player = get_player(PlayerIndex)
            if player ~= 0 then
                return player
            end
        end
    end
    return nil
end

function getHash(PlayerIndex)
    if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
        local hash = get_var(PlayerIndex, "$hash")
        return hash
    end
    return nil
end

function tokenizestring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = { };
    i = 1
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
        t[i] = str
        i = i + 1
    end
    return t
end
