--[[
--=====================================================================================================--
Script Name: Message Board (utility), for SAPP (PC & CE)
Description:    This mod will announce welcome messages to the newly joined player. 
                These welcome messages are displayed in the rcon console. 
                You can specify how long the messages are displayed on screen.
                
				Change Log [26/12/2017]
                [+] Added custom message board output variables: %server_name%, %player_name%
                
				Change Log [24/3/2019]
                [+] Refactored the code.
    
Copyright (c) 2016-2019, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

-- Do not touch...
local messages, players, gsub = { }, { }, string.gsub
local servername, message_board
--

-- How long should the message be displayed on screen for? (in seconds) --
local duration = 10

-- Message Alignment:
local alignment = "l" -- Left = l,    Right = r,    Center = c,    Tab: t
local message_board = { }

local function set(PlayerIndex)

    -- ==== [ MESSAGE CONFIG ] ==== --

    -- Message Board: 
    -- Use %server_name% variable to output the server name.
    -- Use %player_name% variable to output the joining player's name.

    -- messages --
    message_board[PlayerIndex] = { }
    message_board[PlayerIndex] = {
        "Welcome to %server_name%, %player_name%",
        "Message Board created by Chalwk (Jericho Crosby)",
        "https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS"
    }
    -- ================ [ CONFIG ENDS ] ================ --

    -- Do not touch.
    for _, v in pairs(message_board[PlayerIndex]) do
        for j = 1, #message_board[PlayerIndex] do
            message_board[PlayerIndex][j] = gsub(message_board[PlayerIndex][j], "%%server_name%%", servername)
        end
    end
end

local function cls(p)
    for _ = 1, 25 do
        rprint(p, " ")
    end
end

function messages:show(p)
    set(p)
    players[p] = players[p] or { }
    players[p].timer = 0
    players[p].name = true
    players[p].show = true
end

function messages:hide(p)
    players[p] = nil
    message_board[p] = nil
    cls(p)
end

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
    register_callback(cb['EVENT_GAME_START'], "OnNewGame")
    register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
    for i = 1, 16 do
        if player_present(i) and (players[i] ~= nil) then
            messages:hide(i)
        end
    end
end

function OnNewGame()
    for i = 1, 16 do
        if player_present(i) and (players[i] ~= nil) then
            messages:hide(i)
        end
    end
    local function read_widestring(address, length)
        local count = 0
        local byte_table = {}
        for i = 1, length do
            if read_byte(address + count) ~= 0 then
                byte_table[i] = string.char(read_byte(address + count))
            end
            count = count + 2
        end
        return table.concat(byte_table)
    end
    local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    servername = read_widestring(network_struct + 0x8, 0x42)
end

function OnGameEnd()
    for i = 1, 16 do
        if player_present(i) and (players[i] ~= nil) then
            messages:hide(i)
        end
    end
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and (players[i] ~= nil) and (players[i].show) then
            players[i].timer = players[i].timer + 0.030
            cls(i)
            for _, v in pairs(message_board[i]) do
                if (players[i].name) then
                    players[i].name = false
                    for j = 1, #message_board[i] do
                        message_board[i][j] = gsub(message_board[i][j], "%%player_name%%", get_var(i, "$name"))
                    end
                end
                rprint(i, "|" .. alignment .. " " .. v)
            end
            if players[i].timer >= math.floor(duration) then
                messages:hide(i)
            end
        end
    end
end

function OnPlayerJoin(PlayerIndex)
    messages:show(PlayerIndex)
end

function OnPlayerLeave(PlayerIndex)
    messages:hide(PlayerIndex)
end
