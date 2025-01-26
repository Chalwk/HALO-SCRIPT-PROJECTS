--[[
--=====================================================================================================--
Script Name: Name Replacer, for SAPP (PC & CE)
Description: Replaces player names with random names from a predefined list.

Copyright (c) 2025, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-----------------------------------------
-- Config starts here, edit as needed --
-----------------------------------------

-- List of blacklisted names that should be replaced.
-- Players with any of these names will have their names changed.
local blacklist = {
    'Butcher', 'Caboose', 'Crazy', 'Cupid', 'Darling', 'Dasher',
    'Disco', 'Donut', 'Dopey', 'Ghost', 'Goat', 'Grumpy',
    'Hambone', 'Hollywood', 'Howard', 'Jack', 'Killer', 'King',
    'Mopey', 'New001', 'Noodle', 'Nuevo001', 'Penguin', 'Pirate',
    'Prancer', 'Saucy', 'Shadow', 'Sleepy', 'Snake', 'Sneak',
    'Stompy', 'Stumpy', 'The Bear', 'The Big L', 'Tooth',
    'Walla Walla', 'Weasel', 'Wheezy', 'Whicker', 'Whisp',
    'Wilshire'
}

-- List of random names that can be assigned to players.
local random_names = {
    'Liam', 'Noah', 'Oliver', 'Elijah', 'William', 'James',
    'Benjamin', 'Lucas', 'Henry', 'Alexander', 'Mason',
    'Michael', 'Ethan', 'Daniel', 'Jacob', 'Logan',
    'Jackson', 'Levi', 'Sebastian', 'Mateo', 'Jack',
    'Owen', 'Theodore', 'Aiden', 'Samuel', 'Joseph',
    'John', 'David', 'Wyatt', 'Matthew', 'Luke',
    'Asher', 'Carter', 'Julian', 'Grayson', 'Leo',
    'Jayden', 'Gabriel', 'Isaac', 'Lincoln', 'Anthony'
}

-- Maximum allowed name length.
-- Names longer than this limit will be truncated.
-- Ensure this matches the in-game name length limit (default: 11).
-- Do not set this value higher than 11, as it may cause issues with in-game display.
local MAX_NAME_LENGTH = 11

-----------------------------------------
-- Config ends here, do not edit below --
-----------------------------------------

api_version = "1.12.0.0"

local random_names_status = {} -- Holds name usage status (used flag).
local players = {} -- Tracks players and their assigned names.
local network_struct
local ce
local byte = string.byte
local char = string.char

-- Script initialization logic.
function OnScriptLoad()
    -- Register callbacks for various game events.
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_PREJOIN'], 'OnPreJoin')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    players = {}
    network_struct = read_dword(sig_scan('F3ABA1????????BA????????C740??????????E8????????668B0D') + 3)
    ce = (halo_type == 'PC' and 0x40 or 0x0)

    -- Initialize the random_names_status table.
    for _, name in ipairs(random_names) do
        random_names_status[name] = {used = false}
    end

    OnStart()
end

-- Generate a random string of a specified length (fallback for random names).
-- Used when no clean random names are available.
local function generateRandomString(length)
    local name = ''
    for _ = 1, length do
        name = name .. char(rand(97, 123)) -- Generate lowercase letters a-z.
    end
    return name
end

-- Get an available random name for a player or fallback to a generated string.
local function getRandomName(player)
    local availableNames = {}

    -- Collect all unused names from the random_names table.
    for name, status in pairs(random_names_status) do
        if not status.used then
            table.insert(availableNames, name)
        end
    end

    -- If there are available names, pick one randomly.
    if #availableNames > 0 then
        local randomIndex = rand(1, #availableNames)
        local chosenName = availableNames[randomIndex]

        players[player] = chosenName
        random_names_status[chosenName].used = true

        return chosenName
    end

    -- If no clean names are available, generate a random string.
    return generateRandomString(MAX_NAME_LENGTH)
end

-- Mark a name as used in the random_names_status table.
local function checkName(name)
    if random_names_status[name] then
        random_names_status[name].used = true
        players[name] = true
    end
end

-- Assign a new name to a player and update the in-game display.
local function setNewName(id, newName)
    local count = 0
    local address = network_struct + 0x1AA + ce + to_real_index(id) * 0x20

    -- Clear the player's existing name.
    for _ = 1, 12 do
        write_byte(address + count, 0)
        count = count + 2
    end

    -- Apply the new name (truncate if longer than MAX_NAME_LENGTH).
    local str = newName:sub(1, MAX_NAME_LENGTH)
    local length = str:len()

    for j = 1, length do
        local new_byte = byte(str:sub(j, j))
        write_byte(address + count, new_byte)
        count = count + 2
    end
end

-- Handle the pre-join event to check and replace blacklisted names.
function OnPreJoin(player)
    local name = get_var(player, '$name')
    checkName(name)

    -- Check if the player's name is blacklisted.
    for _, blacklisted_name in ipairs(blacklist) do
        if name == blacklisted_name then
            local new_name = getRandomName(player)
            print("The new name is: ", new_name)
            setNewName(player, new_name)
            cprint(string.format("[Name Replacer] Player %s's name changed to %s.", name, new_name))
            break
        end
    end
end

-- Handle player quit events to free up their name.
function OnQuit(player)
    local name = players[player]

    if name then
        random_names_status[name].used = false
        players[player] = nil
    end
end

-- Initialize the script and reset name states at the start of a game.
function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}

        -- Reset all names to unused.
        for _, status in pairs(random_names_status) do
            status.used = false
        end

        -- Check the names of currently present players.
        for i = 1, 16 do
            if player_present(i) then
                checkName(get_var(i, '$name'))
            end
        end
    end
end